AddCSLuaFile()

--local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName 		= "sc_activebeacon"
ENT.PrintName		= "baby"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "Rescue."
ENT.Instructions	= ""

local rotate = 0
local intensity = 0

function ENT:Initialize()
	if SERVER then
		self:SetModel(SlashCoItems.Beacon.Model)
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
		self:SetAngles(Angle(180,0,0))

		if not self:GetNWBool("ArmingBeacon") then
			PlayGlobalSound("slashco/survivor/distress_siren.wav", 98, self)
		else
			timer.Create(self:EntIndex().."_BeaconArming",( ( #team.GetPlayers(TEAM_SURVIVOR)*15) + math.random(30,80) ), 1, function() ArmBeacon(self) end)
			timer.Create(self:EntIndex().."_BeaconBlipSound",2.5 , 0, function() PlayGlobalSound("slashco/beacon_connect", 95, self) end)
		end
	end

end

local function ArmBeacon(ent)
	timer.Remove(self:EntIndex().."_BeaconBlipSound")
	PlayGlobalSound("slashco/survivor/distress_siren.wav", 98, self)
	ent:SetNWBool("ArmingBeacon", false)
	SlashCo.SummonEscapeHelicopter()
	SlashCo.CurRound.DistressBeaconUsed = true
	timer.Simple( math.random(3,6), function() SlashCo.HelicopterRadioVoice(4) end)
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

if SERVER then

	function ENT:Think()

		if self:GetNWBool("ArmingBeacon") then 
		
			if #team.GetPlayers(TEAM_SURVIVOR) < 2 then
				timer.Remove(self:EntIndex().."_BeaconArming")
				ArmBeacon(self)
			end

		end

		if not self:GetNWBool("ArmingBeacon") then return end
		if self.Broken then return end

		for k, v in team.GetPlayers(TEAM_SLASHER) do

			if v:GetPos():Distance( self:GetPos() ) < 50  do

				self:EmitSound("slashco/beacon_break.mp3", 85)
				timer.Remove(self:EntIndex().."_BeaconArming")
				timer.Remove(self:EntIndex().."_BeaconBlipSound")
				self:SetModel("models/props_c17/light_cagelight02_off.mdl")

				local phys = self:GetPhysicsObject()

				if phys:IsValid() then phys:Wake() end

				self.Broken = true

			end

		end

	end

end

if CLIENT then
    function ENT:Draw()
		self:DrawModel()

	end

	function ENT:Think()

		if not self:GetNWBool("ArmingBeacon")then

			rotate = rotate + (FrameTime()*300)

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
				self.Light2:SetAngles(Angle(0,180+rotate,0))
				self.Light2:Update()
			else
				self.Light2 = ProjectedTexture()
				self.Light2:SetTexture("effects/flashlight001")
				self.Light2:SetFarZ(1500)
				self.Light2:SetFOV(140)
				self.Light2:SetColor(Color(255,0,0,255))
			end

		else

			intensity = intensity + (FrameTime()*300)

			local dlight = DynamicLight( self:EntIndex() + 99996)
			if ( dlight ) then
				dlight.pos = self:GetPos()
				dlight.r = 255
				dlight.g = 40
				dlight.b = 40
				dlight.brightness = 1
				dlight.Decay = 1000
				dlight.Size = math.sin( intensity ) * 500
				dlight.DieTime = CurTime() + 0.1
			end

		end

	end
end