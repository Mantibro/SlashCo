AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName 		= "sc_labmeat"
ENT.PrintName		= "Lab Grown Meat"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "This is moving."
ENT.Instructions	= ""
ENT.IsSelectable 	= true
ENT.PingType = "ITEM"

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/slashco/items/labmeat.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
		self:SetMoveType( MOVETYPE_VPHYSICS)
	end

	local physCount = self:GetPhysicsObjectCount()
	for i = 0, (physCount - 1) do
		local PhysBone = self:GetPhysicsObjectNum(i)

		if PhysBone:IsValid() then
			PhysBone:Wake()
		end
	end

	self.SoundTick = 0
end

function ENT:Use( activator )

	if SERVER then
	
		if activator:Team() == TEAM_SURVIVOR then 
	
			SlashCo.ItemPickUp(activator, self:EntIndex(), "LabMeat")
	
			if ( self:IsPlayerHolding() ) then return end
			activator:PickupObject( self )
			activator:EmitSound("slashco/survivor/eat_mayo.mp3")
	
		end
	
	end
	
	end

function ENT:Think( )
	if SERVER then

		self.SoundTick = self.SoundTick + math.random(0,1)

		if self.SoundTick > 100 then

			self:EmitSound("npc/headcrab/idle"..math.random(1,3)..".wav") 
			self.SoundTick = 0

			--jerk it

			local physCount = self:GetPhysicsObjectCount()
			for i = 0, (physCount - 1) do
				local PhysBone = self:GetPhysicsObjectNum(i)

				if PhysBone:IsValid() then
					PhysBone:SetVelocity( VectorRand( -5, 5 ) )
					PhysBone:AddAngleVelocity( VectorRand( -5, 5 ) )
				end
			end

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