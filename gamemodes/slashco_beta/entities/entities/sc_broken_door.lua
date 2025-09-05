AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"
ENT.BASE = "base_anim"
ENT.PrintName = "Broken Door"

function ENT:Initialize()
	self.HasCollisions = true
end

function ENT:Think()
	if not self.HasCollisions then return end

	-- After we stopped moving, we disable collisions with players.
	if self:GetVelocity():Length() < 0.1 then
		self.HasCollisions = false
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	end
end