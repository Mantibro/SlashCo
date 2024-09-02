AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName = "sc_baseitem"
ENT.PrintName = "Soda"
ENT.Author = "textstack"
ENT.Contact = ""
ENT.Purpose = "the essential item"
ENT.Instructions = ""
ENT.IsSelectable = true
ENT.PingType = "ITEM"

function ENT:Initialize()
	if SERVER then
		self:SetModel(SlashCoItems[self.PrintName].Model)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
		self:SetMoveType(MOVETYPE_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

		SlashCo.ItemPickUp(activator, self:EntIndex(), self.PrintName)

		--[[
		if self:IsPlayerHolding() then
			return
		end

		activator:PickupObject(self)
		--]]
	end

	return
end

function ENT:Draw()
	self:DrawModel()
end