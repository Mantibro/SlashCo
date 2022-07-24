AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName 		= "sc_activebeacon"
ENT.PrintName		= "baby"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "Rescue."
ENT.Instructions	= ""

local rotate = 0

function ENT:Initialize()
	if SERVER then
		self:SetModel( SlashCo.Items.DISTRESS_BEACON.Model)
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
		self:SetAngles(Angle(180,0,0))

		PlayGlobalSound("slashco/survivor/distress_siren.wav", 98, self)
	end

end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

if CLIENT then
    function ENT:Draw()
		self:DrawModel()

	end

	function ENT:Think()

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

	end
end