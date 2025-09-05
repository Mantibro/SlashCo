AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Rock"
ENT.ClassName = "sc_rock"

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

	if phys:IsValid() and canPos then
		phys:AddVelocity((selfPos - canPos):GetNormalized())
	end

	timer.Simple(math.random(5) + 5, function()
		if not IsValid(self) or not self.Orient then
			return
		end
		self:Orient()
	end)
end

function ENT:Initialize()
	if SERVER then
		self:SetModel(SlashCoItems.Rock.Model)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
		self:SetMoveType(MOVETYPE_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then phys:Wake() end

	timer.Simple(math.random(5) + 5, function()
		if not IsValid(self) or not self.Orient then
			return
		end
		self:Orient()
	end)
end