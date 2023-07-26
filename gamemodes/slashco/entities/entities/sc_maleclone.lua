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
		self:MoveToPos(SlashCo.TraceHullLocator()) -- Walk to a random place
		self:StartActivity(ACT_IDLE)

		coroutine.wait(math.Rand(0, 35))

		coroutine.yield()
		-- The function is done here, but will start back at the top of the loop and make the bot walk somewhere else

		if self:GetPos()[3] < -2000 then
			self:Remove()
			SlashCo.CreateItem("sc_maleclone", SlashCo.TraceHullLocator(), Angle(0, 0, 0))
		end
	end
end

--make sure the hull is player-size
local mins, maxs = Vector(-16, -16, 0), Vector(16, 16, 71)
function ENT:HandleStuck()
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

		if not IsValid(tr.Entity) then
			return
		end

		if tr.Entity:GetClass() == "prop_door_rotating" then
			if self:GetPos():Distance(tr.Entity:GetPos()) > 150 then
				return
			end
			tr.Entity:Fire("Open")
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