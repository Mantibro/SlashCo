AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.ClassName = "sc_maleclone"
ENT.PingType = "SLASHER"

function ENT:Initialize()
	if CLIENT then
		self:SetIK()
	end

	self:SetModel("models/Humans/Group01/male_07.mdl")
	self.CollideSwitch = 3
end

function ENT:RunBehaviour()
	while true do
		-- Here is the loop, it will run forever
		self:StartActivity(ACT_WALK)            -- Walk animation
		self.loco:SetDesiredSpeed(100)        -- Walk speed

		local pos = SlashCo.TraceHullLocator()
		if g_SlashCoDebug then
			debugoverlay.Cross(pos, 40, 30, Color(0, 255, 255), true)
		end
		self:MoveToPos(pos, {
			draw = g_SlashCoDebug,
			repath = 6,
			lookahead = 600
		}) -- Walk to a random place
		self:StartActivity(ACT_IDLE)

		if not self.GotStuck then
			coroutine.wait(math.Rand(0, 35))
		end
		self.GotStuck = nil

		coroutine.yield()
		-- The function is done here, but will start back at the top of the loop and make the bot walk somewhere else

		if self:GetPos()[3] < -16000 then
			self:Remove()
			SlashCo.CreateItem("sc_maleclone", SlashCo.TraceHullLocator(), Angle(0, 0, 0))
		end
	end
end

--make sure the hull is player-size
local mins, maxs = Vector(-16, -16, 0), Vector(16, 16, 71)
function ENT:HandleStuck()
	self.GotStuck = true
	local lim = 1
	while true do
		if not self.loco:IsStuck() then
			self.loco:ClearStuck()
			return
		end

		local pos = VectorRand(-lim, lim) + self:GetPos()
		pos.z = pos.z / 5

		local hullTrace = util.TraceHull({
			start = pos,
			endpos = pos,
			mins = mins,
			maxs = maxs
		})

		if g_SlashCoDebug then
			debugoverlay.Box(pos, mins, maxs, 1, Color(255, 0, 0))
			debugoverlay.Cross(pos, 40, 1, color_white, true)
		end

		if not hullTrace.Hit then
			self:SetPos(pos)
			break
		end

		--be less specific if it's not working out
		if lim == 40 and not hullTrace.HitNonWorld then
			self:SetPos(pos)
			break
		end

		if lim == 100 then
			pos = SlashCo.TraceHullLocator()
			if pos then
				self:SetPos(pos)
				break
			end
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
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end