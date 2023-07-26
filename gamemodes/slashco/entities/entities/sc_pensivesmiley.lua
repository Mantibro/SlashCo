AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.ClassName = "sc_pensivesmiley"
ENT.Spawnable = true
ENT.PingType = "SLASHER"

function ENT:Initialize()
	self:SetModel("models/slashco/slashers/freesmiley/pensivesmiley.mdl")

	self.CollideSwitch = 3

	self.AttackedPlayer = ""

	self.AttackEngage = false

	self.LoseTargetDist = 1000    -- How far the enemy has to be before we lose them
	self.SearchRadius = 700    -- How far to search for enemies
end

----------------------------------------------------
-- ENT:Get/SetEnemy()
-- Simple functions used in keeping our enemy saved
----------------------------------------------------
function ENT:SetEnemy(ent)
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end

----------------------------------------------------
-- ENT:HaveEnemy()
-- Returns true if we have an enemy
----------------------------------------------------
function ENT:HaveEnemy()
	-- If our current enemy is valid
	if self:GetEnemy() and IsValid(self:GetEnemy()) then
		-- If the enemy is too far
		if self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist then
			-- FindEnemy() will return true if an enemy is found, making this function return true
			return self:FindEnemy()
			-- If the enemy is dead( we have to check if its a player before we use Alive() )
		elseif self:GetEnemy():IsPlayer() and not self:GetEnemy():Alive() then
			return self:FindEnemy()        -- Return false if the search finds nothing
		end
		-- The enemy is neither too far nor too dead so we can return true
		return true
	else
		-- The enemy isn't valid so lets look for a new one
		return self:FindEnemy()
	end
end

----------------------------------------------------
-- ENT:FindEnemy()
-- Returns true and sets our enemy if we find one
----------------------------------------------------
function ENT:FindEnemy()
	if self.AttackedPlayer ~= "" then
		return false
	end

	-- Search around us for entities
	-- This can be done any way you want eg. ents.FindInCone() to replicate eyesight
	local _ents = ents.FindInSphere(self:GetPos(), self.SearchRadius)
	-- Here we loop through every entity the above search finds and see if it's the one we want
	for _, v in ipairs(_ents) do
		if v:IsPlayer() and v:Team() == TEAM_SURVIVOR then
			-- We found one so lets set it as our enemy and return true

			local tr = util.TraceLine({
				start = self:GetPos() + Vector(0, 0, 40),
				endpos = v:GetPos() + Vector(0, 0, 40),
				filter = self
			})

			if tr.Entity == v then
				self:SetEnemy(v)
				return true
			else
				self:SetEnemy(nil)
				return false
			end
		end
	end
	-- We found nothing so we will set our enemy as nil (nothing) and return false
	self:SetEnemy(nil)
	return false
end

function ENT:RunBehaviour()
	while true do
		-- Lets use the above mentioned functions to see if we have/can find a enemy
		self:StartActivity(ACT_IDLE)
		if self.AttackedPlayer == "" then
			if self:HaveEnemy() then
				-- Now that we have a enemy, the code in this block will run
				self:SetSequence(self:LookupSequence("attack"))
				self.loco:FaceTowards(self:GetEnemy():GetPos())    -- Face our enemy
				--self:StartActivity( ACT_WALK )			-- Set the animation
				self.loco:SetDesiredSpeed(300)        -- Set the speed that we will be moving at. Don't worry, the animation will speed up/slow down to match
				self.loco:SetAcceleration(900)            -- We are going to run at the enemy quickly, so we want to accelerate really fast
				self:ChaseEnemy()                        -- The new function like MoveToPos that will be looked at soon.
				self.loco:SetAcceleration(400)            -- Set this back to its default since we are done chasing the enemy
				--self:StartActivity( ACT_IDLE )			--We are done so go back to idle
				-- Now once the above function is finished doing what it needs to do, the code will loop back to the start
				-- unless you put stuff after the if statement. Then that will be run before it loops
			else
				-- Since we can't find an enemy, lets wander
				-- Its the same code used in Garry's test bot
				self:SetSequence(self:LookupSequence("idle"))
				--self:StartActivity( ACT_WALK )			-- Walk anmimation
				self.loco:SetDesiredSpeed(100)        -- Walk speed

				local pos = SlashCo.LocalizedTraceHullLocatorAdvanced(self, 100, 200, self.GotStuck and -20 or 150)
				self.GotStuck = nil
				if pos then
					self:MoveToPos(pos, {
						draw = g_SlashCoDebug,
						maxage = 10,
						tolerance = 50,
						lookahead = 600
					}) -- Walk to a random place
				else
					coroutine.wait(1)
				end -- Walk to a random place
				--self:StartActivity( ACT_IDLE )
			end
		else
			self:SetSequence(self:LookupSequence("attack"))
			self.loco:FaceTowards(player.GetBySteamID64(self.AttackedPlayer):GetPos())    -- Face our enemy
			coroutine.wait(math.Rand(12))
		end
		-- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
		-- Using this next function we are going to wait 2 seconds until we go ahead and repeat it 
		--coroutine.wait(math.Rand( 0, 1 ))
	end
end

function ENT:ChaseEnemy(options)
	local options1 = options or {}
	local path = Path("Follow")
	path:SetMinLookAheadDistance(options1.lookahead or 300)
	path:SetGoalTolerance(options1.tolerance or 20)
	path:Compute(self, self:GetEnemy():GetPos())        -- Compute the path towards the enemy's position

	if not path:IsValid() then
		return "failed"
	end

	while path:IsValid() and self:HaveEnemy() do
		if path:GetAge() > 0.1 then
			-- Since we are following the player we have to constantly remake the path
			path:Compute(self, self:GetEnemy():GetPos())-- Compute the path towards the enemy's position again
		end
		path:Update(self)                                -- This function moves the bot along the path

		if options1.draw then
			path:Draw()
		end
		-- If we're stuck then call the HandleStuck function and abandon
		if self.loco:IsStuck() then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end

	if self.AttackedPlayer ~= "" then
		coroutine.yield()
	end

	return "ok"
end

function ENT:HandleStuck()
	self.GotStuck = true
	local lim = 1
	while true do
		if not self.loco:IsStuck() then
			self.loco:ClearStuck()
			return
		end

		local pos = VectorRand(-lim, lim)
		pos.z = pos.z / 5
		local mins, maxs = self:WorldSpaceAABB()

		local hullTrace = util.TraceHull({
			start = pos + self:GetPos(),
			endpos = pos + self:GetPos(),
			mins = mins,
			maxs = maxs
		})

		if g_SlashCoDebug then
			debugoverlay.Box(pos, mins, maxs, 1, Color(255, 0, 0))
			debugoverlay.Cross(pos + self:GetPos(), 40, 1, color_white, true)
		end

		if not hullTrace.Hit then
			self:SetPos(pos + self:GetPos())
			break
		end

		--be less specific if it's not working out
		if lim == 40 and not hullTrace.HitNonWorld then
			self:SetPos(pos + self:GetPos())
			break
		end

		coroutine.wait(0.05)
		lim = math.Clamp(lim + 0.5, 1, 100)
	end

	self:EmitSound("physics/water/water_impact_hard" .. math.random(2) .. ".wav", 75, 90, 0.1)
	self.loco:ClearStuck()
end

function ENT:Think()
	if SERVER then
		if self.CollideSwitch > 0 then
			self:SetNotSolid(true)
			self.CollideSwitch = self.CollideSwitch - FrameTime()
		else
			self:SetNotSolid(false)
		end

		local tr = util.TraceLine({
			start = self:GetPos() + Vector(0, 0, 50),
			endpos = self:GetPos() + self:GetForward() * 10000,
			filter = self
		})

		if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_door_rotating" and self:GetPos():Distance(tr.Entity:GetPos()) < 100 and
				not tr.Entity.IsOpen and (not self.UseCooldown or CurTime() - self.UseCooldown > 2) then

			tr.Entity:Use(self)
			self.UseCooldown = CurTime()
		end

		if self.AttackedPlayer == "" then
			local _ents = ents.FindInSphere(self:GetPos(), self.SearchRadius)

			for _, v in ipairs(_ents) do
				if (v:IsPlayer() and v:Team() == TEAM_SURVIVOR) then
					if not self:HaveEnemy() then
						self:FindEnemy()
					end

					if v:GetPos():Distance(self:GetPos()) < 150 then
						self.AttackedPlayer = v:SteamID64()
						self.Enemy = nil
					end
				end
			end
		else
			if not IsValid(player.GetBySteamID64(self.AttackedPlayer)) then
				self.AttackedPlayer = ""
				self.Enemy = nil
			end

			local attacked = player.GetBySteamID64(self.AttackedPlayer)
			attacked:SetSlowWalkSpeed(50)
			attacked:SetWalkSpeed(50)
			attacked:AddSpeedEffect("smiley", 50, 15)

			attacked:SetNWBool("MarkedBySmiley", true)

			if self.AttackEngage == false then
				self:EmitSound("slashco/slasher/pensive_attack" .. math.random(1, 2) .. ".mp3")

				timer.Simple(10, function()
					if not IsValid(attacked) then
						return
					end

					attacked:SetSlowWalkSpeed(200)
					attacked:SetWalkSpeed(200)
					attacked:RemoveSpeedEffect("smiley")

					attacked:SetNWBool("MarkedBySmiley", false)

					self:Remove()
				end)

				self.AttackEngage = true
			end
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	return
end

function ENT:Use(activator)
	if activator:Team() ~= TEAM_SLASHER then
		return
	end

	self:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav")
	self:Remove()
end