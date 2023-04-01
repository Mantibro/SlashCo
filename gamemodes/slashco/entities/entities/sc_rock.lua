AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName 		= "sc_rock"
ENT.PrintName		= "rock"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "This is plutonium."
ENT.Instructions	= ""
ENT.IsSelectable 	= true
ENT.PingType = "ITEM"

function ENT:Orient()
	local selfPos = self:GetPos()
	local canDist, canPos = math.huge
	for _, v in ipairs(ents.FindByClass("sc_gascan")) do
		local currentPos = v:GetPos()
		local distSqr = selfPos:DistToSqr(currentPos)
		if distSqr < canDist then
			canDist = distSqr
			canPos = currentPos
		end
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:AddVelocity((selfPos - canPos):GetNormalized())
	end

	timer.Simple(math.random(5)+5, function()
		if not IsValid(self) or not self.Orient then
			return
		end
		self:Orient()
	end)
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( SlashCoItems.Rock.Model )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
		self:SetMoveType( MOVETYPE_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then phys:Wake() end

	timer.Simple(math.random(5)+5, function()
		if not IsValid(self) or not self.Orient then
			return
		end
		self:Orient()
	end)
end

function ENT:Use( activator )

if SERVER then

	if activator:Team() == TEAM_SURVIVOR then 

		SlashCo.ItemPickUp(activator, self:EntIndex(), "Rock")

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