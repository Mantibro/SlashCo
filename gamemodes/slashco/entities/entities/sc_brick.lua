AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Brick"
ENT.ClassName = "sc_brick"

function ENT:Initialize()
	self:SetModel("models/props_junk/cinderblock01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	self.HitObjects = {}
end

function ENT:SetBrickVelocity(velocity)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:SetVelocity(velocity)
		phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
	end

	self.InitialVelocity = velocity -- We save our velocity so that if we hit two doors at once, we can 
	self.Active = true
end

function ENT:Break()
	if math.random(1, 5) == 1 then
		self:EmitSound("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav")
		self:Remove()
	end
end

function ENT:PhysicsCollide(data)
	if self.DidCollide or not self.Active then return end

	local pos = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(pos)
	effectdata:SetOrigin(pos)
	effectdata:SetScale(1.5)

	util.Effect("GlassImpact", effectdata)
	local velocity = self.InitialVelocity or self:GetPhysicsObject():GetVelocity()
	if IsValid(data.HitEntity) then
		if data.HitEntity:IsPlayer() and data.HitEntity:Team() == TEAM_SLASHER then
			data.HitEntity.SlashCoBrickFriction = data.HitEntity.SlashCoBrickFriction or data.HitEntity:GetFriction()
			data.HitEntity:SetFriction(0)
			data.HitEntity:SetVelocity(velocity * 4)
			timer.Create("BrickHit" .. data.HitEntity:EntIndex(), 0.4, 1, function()
				if not IsValid(data.HitEntity) then return end

				data.HitEntity:SetFriction(data.HitEntity.SlashCoBrickFriction)
				data.HitEntity.SlashCoBrickFriction = nil
			end)

			self:Break()
		elseif data.HitEntity:GetClass() == "prop_door_rotating" then
			SlashCo.BustDoor(self, data.HitEntity, velocity * 50, function()
				self:Break()
			end)
		else
			if not data.HitEntity:IsWorld() then
				data.HitObject:ApplyForceCenter(velocity * 50)
			end
		end
	else
		data.HitObject:ApplyForceCenter(velocity * 50)
	end

	self:EmitSound("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav")
	self.DidCollide = true
end