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
		self:SetUseType(SIMPLE_USE)
	end

	local item = SlashCoItems[self.OverrideItem or self.PrintName]
	if not item then
		ErrorNoHaltWithStack("[SlashCo] Failed to spawn item \"" .. (self.OverrideItem or self.PrintName) .. "\"!")
	else
		self:SetModel(item.Model)
	end

	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	local postInitialize = self.PostInitialize
	if postInitialize then
		postInitialize(self)
	end
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

		SlashCo.ItemPickUp(activator, self:EntIndex(), self.PrintName)
	end

	return
else
	function ENT:Draw()
		self:DrawModel()
	end
end
