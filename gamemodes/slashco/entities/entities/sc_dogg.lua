AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName 		= "sc_dogg"
ENT.PrintName		= "Plush Dog"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "I'm so sorry"
ENT.Instructions	= ""
ENT.IsSelectable 	= true

function ENT:Initialize()
	if SERVER then
		self:SetModel( SlashCoItems.Cookie.Model )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
		self:SetMoveType( MOVETYPE_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then phys:Wake() end

	self.SoundTick = 0
end

function ENT:Think( )
	if SERVER then

		self.SoundTick = self.SoundTick + math.random(0,1)

		if self.SoundTick > 100 then

			slasher:EmitSound("slashco/dogg"..math.random(1,4)..".mp3") 
			self.SoundTick = 0
		end

		self:NextThink( CurTime() )
		return true 
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