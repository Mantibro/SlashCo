AddCSLuaFile()

--local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName 		= "sc_activebeacon"
ENT.PrintName		= "active beacon"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "Rescue."
ENT.Instructions	= ""
ENT.PingType = "DISTRESS BEACON"

local rotate = 0
local intensity = 0

local function ArmBeacon(ent)
	if ent:GetNWBool("BeaconBroken") then return end

	timer.Remove(ent:EntIndex() .. "_BeaconBlipSound")
	SlashCo.PlayGlobalSound("slashco/survivor/distress_siren.wav", 98, ent)
	ent:SetNWBool("ArmingBeacon", false)
	SlashCo.SummonEscapeHelicopter(true)
	SlashCo.CurRound.DistressBeaconUsed = true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if SERVER then
	function ENT:Initialize()
		self:SetModel(SlashCoItems.Beacon.Model)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
		self:SetAngles(Angle(180,0,0))
	end

	function ENT:Think()
		if self:GetNWBool("BeaconBroken") then return end

		if self.DoArming and not self.TimersStarted then
			local ms = SlashCo.MapSize --SCInfo.Maps[game.GetMap()].SIZE

			local fin_time = (team.NumPlayers(TEAM_SURVIVOR) * 15) + math.random(5,25) + (ms * 10)

			print("[SlashCo] Beacon set to arm in " .. fin_time .. " seconds.")

			timer.Create(self:EntIndex() .. "_BeaconArming",fin_time, 1, function() ArmBeacon(self) end)
			timer.Create(self:EntIndex() .. "_BeaconBlipSound",3 , 0, function() SlashCo.PlayGlobalSound("slashco/beacon_connect.mp3", 95, self) end)
			self.TimersStarted = true
		end


		if self:GetNWBool("ArmingBeacon") and team.NumPlayers(TEAM_SURVIVOR) < 2 then
			timer.Remove(self:EntIndex() .. "_BeaconArming")
			ArmBeacon(self)
		end

		if not self:GetNWBool("ArmingBeacon") then return end

		for k, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if v:GetPos():Distance(self:GetPos()) < 50 then
				self:EmitSound("slashco/beacon_break.mp3", 85)
				timer.Remove(self:EntIndex() .. "_BeaconArming")
				timer.Remove(self:EntIndex() .. "_BeaconBlipSound")
				self:SetModel("models/props_c17/light_cagelight02_off.mdl")

				self:SetNWBool("ArmingBeacon", false)
				self:PhysicsInit(SOLID_VPHYSICS)
				self:SetMoveType(MOVETYPE_VPHYSICS)

				local phys = self:GetPhysicsObject()

				if phys:IsValid() then phys:Wake() end

				phys:ApplyForceCenter(Vector(math.random(-25,25),math.random(-25,25),math.random(-25,25)))

				self:SetNWBool("BeaconBroken", true)
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

	end

	function ENT:Think()
		if self:GetNWBool("BeaconBroken") then return end

		if self:GetNWBool("ArmingBeacon") then
			intensity = intensity + (FrameTime() * 300)

			local dlight = DynamicLight(self:EntIndex() + 99996)
			if dlight then
				dlight.pos = self:GetPos()
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.brightness = 1
				dlight.Decay = 1000
				dlight.Size = math.sin(intensity) * 500
				dlight.DieTime = CurTime() + 0.1
			end

			if IsValid(self.Light) then
				self.Light:Remove()
				self.Light = nil
			end

			if IsValid(self.Light2) then
				self.Light2:Remove()
				self.Light2 = nil
			end
		end

		if self:GetNWBool("ArmingBeacon") then return end

		rotate = rotate + (FrameTime() * 300)

		if self.Light then
			local position = self:GetPos() + Vector(0,0,20)

			self.Light:SetPos(position)
			self.Light:SetAngles(Angle(0,rotate,0))
			self.Light:Update()
		else
			self.Light = ProjectedTexture()
			self.Light:SetTexture("effects/flashlight001")
			self.Light:SetFarZ(1500)
			self.Light:SetFOV(140)
			self.Light:SetColor(Color(255,0,0,255))
		end

		if self.Light2 then
			local position = self:GetPos() + Vector(0,0,20)

			self.Light2:SetPos(position)
			self.Light2:SetAngles(Angle(0,180 + rotate,0))
			self.Light2:Update()
		else
			self.Light2 = ProjectedTexture()
			self.Light2:SetTexture("effects/flashlight001")
			self.Light2:SetFarZ(1500)
			self.Light2:SetFOV(140)
			self.Light2:SetColor(Color(255,0,0,255))
		end
	end
end