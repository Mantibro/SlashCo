AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName 		= "sc_benadryl"
ENT.PrintName		= "benadryl"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "Benadryl."
ENT.Instructions	= ""
ENT.IsSelectable 		= true
ENT.PingType = "ITEM"

function ENT:Initialize()
	if SERVER then
		self:SetModel( SlashCoItems.Benadryl.Model)
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
		self:SetMoveType( MOVETYPE_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then phys:Wake() end
end

function ENT:Use( activator )

if SERVER then

	if activator:Team() == TEAM_SURVIVOR then 

		SlashCo.ItemPickUp(activator, self:EntIndex(), "Benadryl")

		if ( self:IsPlayerHolding() ) then return end
		activator:PickupObject( self )

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