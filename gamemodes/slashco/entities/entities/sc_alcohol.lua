AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Alcohol"
ENT.ClassName = "sc_alcohol"

function ENT:Initialize()
	if SERVER then
		self:SetModel(SlashCoItems[self.PrintName].Model or "models/props_junk/PopCan01a.mdl")
		self:SetMaterial("models/shiny")
		self:SetColor(Color(121, 68, 59))
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