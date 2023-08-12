ENT.Type = "brush"

function ENT:Initialize()
	self:SetTrigger(true)
	self.PlayersInside = {}
end

function ENT:KeyValue(key, value)
	if string.sub(key, 1, 2) == "On" then
		self:StoreOutput(key, value)
		return
	end
	local key1 = string.lower(key)
	if key1 == "disabled" then
		self.Disabled = tonumber(value) == 1
		return
	end
	if key1 == "active" then
		self.Disabled = tonumber(value) == 0
		return
	end
	if key1 == "team" then
		self.Team = tonumber(value)
		return
	end
	if key1 == "effect" then
		self.Effect = tonumber(value)
		return
	end
	if key1 == "damage" then
		self.Damage = tonumber(value)
		return
	end
	if key1 == "health_limit" then
		self.HealthLimit = tonumber(value)
		return
	end
	if key1 == "speed_effect" then
		self.SpeedEffect = tonumber(value)
		return
	end
end

function ENT:AcceptInput(name, activator)
	if string.sub(name, 1, 2) == "On" then
		self:TriggerOutput(name, activator)
		return true
	end
	local name1 = string.lower(name)
	if name1 == "enable" then
		self.Disabled = false
		return true
	end
	if name1 == "disable" then
		self.Disabled = true
		return true
	end
	if name1 == "toggle" then
		self.Disabled = not self.Disabled
		return true
	end
end

function ENT:Enter(ent)
	ent.LimitBrush = self

	if ent:Team() == TEAM_SURVIVOR and self.SpeedEffect and self.SpeedEffect >= 0 then
		local priority = 14
		if self.SpeedEffect > 200 and ent:Team() == TEAM_SURVIVOR then
			priority = 5
		end
		ent:AddSpeedEffect("limitedZone", self.SpeedEffect, priority)
	end

	SlashCo.SendValue(ent, "limitedZone", self.Effect or 1)

	self:TriggerOutput("OnEnter", ent)
	if table.IsEmpty(self.PlayersInside) then
		self:TriggerOutput("OnEnterAll", ent)
	end

	self.PlayersInside[ent] = true
end

function ENT:Leave(ent)
	ent.LimitBrush = nil
	self.PlayersInside[ent] = nil

	if ent:Team() == TEAM_SURVIVOR then
		ent:RemoveSpeedEffect("limitedZone")
	end

	SlashCo.SendValue(ent, "limitedZone", 0)

	self:TriggerOutput("OnExit", ent)
	if table.IsEmpty(self.PlayersInside) then
		self:TriggerOutput("OnExitAll", ent)
	end
end

local damageSounds = {
	[1] = function(ent, damage)
		--default
		if damage <= 10 then
			ent:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav")
		elseif damage >= ent:Health() then
			ent:EmitSound("physics/flesh/flesh_bloody_break.wav")
		else
			ent:EmitSound("physics/flesh/flesh_strider_impact_bullet" .. math.random(1, 3) .. ".wav")
		end
	end,
	[2] = function(ent, damage)
		--blizzard
		if damage >= ent:Health() and damage > 10 then
			ent:EmitSound("physics/glass/glass_pottery_break" .. math.random(1, 4) .. ".wav")
		else
			ent:EmitSound("physics/glass/glass_strain" .. math.random(1, 4) .. ".wav")
		end
	end,
	[3] = function(ent)
		--poison
		ent:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav")
	end,
	[4] = function(ent, damage)
		--blood
		if damage >= ent:Health() and damage > 10 then
			ent:EmitSound("physics/flesh/flesh_bloody_break.wav")
		else
			ent:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav")
		end
	end,
	[6] = function(ent, damage)
		--black snow
		if damage >= ent:Health() and damage > 10 then
			ent:EmitSound("physics/glass/glass_pottery_break" .. math.random(1, 4) .. ".wav")
		else
			ent:EmitSound("physics/glass/glass_strain" .. math.random(1, 4) .. ".wav")
		end
	end
}

function ENT:Touch(ent)
	if not ent:IsPlayer() or ent.LimitBrush ~= self then
		self:StartTouch(ent) --helps for when a player exits a limited zone to immediately enter another
		return
	end

	if self.Disabled then
		self:Leave(ent)
		return
	end
	if self.Team == 0 and ent:Team() ~= TEAM_SURVIVOR then
		self:Leave(ent)
		return
	end
	if self.Team == 1 and ent:Team() ~= TEAM_SLASHER then
		self:Leave(ent)
		return
	end

	if self.Damage and self.Damage > 0 and ent:Team() == TEAM_SURVIVOR and
			(not ent.ZoneCooldown or CurTime() - ent.ZoneCooldown > 3) then

		if ent.ZoneCooldown and CurTime() - ent.ZoneCooldown < 4 then
			local realDamage = self.Damage
			if self.HealthLimit and ent:Health() - realDamage <= self.HealthLimit then
				realDamage = ent:Health() - self.HealthLimit
			end

			if realDamage > 0 then
				local effect = self.Effect or 1
				if damageSounds[effect] then
					damageSounds[effect](ent, realDamage)
				else
					damageSounds[1](ent, realDamage)
				end
				ent:TakeDamage(realDamage, self, self)
			end
		end
		ent.ZoneCooldown = CurTime()
	end
end

function ENT:StartTouch(ent)
	if self.Disabled or not ent:IsPlayer() or not ent:Alive() or IsValid(ent.LimitBrush) then
		return
	end
	if (self.Team == 2 or self.Team == 0) and ent:Team() == TEAM_SURVIVOR then
		self:Enter(ent)
		return
	end
	if (self.Team == 2 or self.Team == 1) and ent:Team() == TEAM_SLASHER then
		self:Enter(ent)
		return
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() and ent.LimitBrush == self then
		self:Leave(ent)
	end
end