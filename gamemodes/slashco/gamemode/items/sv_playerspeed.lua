local PLAYER = FindMetaTable("Player")

PLAYER.SpeedEffects = {}

function PLAYER:AddSpeedEffect(key, speed, priority)
	self.SpeedEffects[key] = { speed, priority }
	self:UpdateSpeed()
end

function PLAYER:RemoveSpeedEffect(key)
	self.SpeedEffects[key] = nil
	self:UpdateSpeed()
end

function PLAYER:UpdateSpeed()
	local highestPriority = -9999
	local highestPrioritySpeed
	for _, v in pairs(self.SpeedEffects) do
		if v[2] > highestPriority then
			highestPriority = v[2]
			highestPrioritySpeed = v[1]
		end
	end

	if highestPriority == -9999 then
		self:SetRunSpeed(300)
		self:SetWalkSpeed(200)
		self:SetSlowWalkSpeed(100)
	else
		self:SetRunSpeed(highestPrioritySpeed)
		self:SetWalkSpeed(math.min(highestPrioritySpeed, 200))
		self:SetSlowWalkSpeed(math.min(highestPrioritySpeed, 100))
	end
end

hook.Add("PlayerDeath", "slashCoResetSpeedEffects", function(victim)
	victim.SpeedEffects = {}
end)

hook.Add("PlayerSilentDeath", "slashCoResetSpeedEffectsSilent", function(victim)
	victim.SpeedEffects = {}
end)