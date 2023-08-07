AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "StepDecoy"
ENT.ClassName = "sc_stepdecoy"

function ENT:Initialize()
	if SERVER then
		self:SetModel(SlashCoItems.StepDecoy.Model)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetNWBool("StepDecoyActive", false)

		self.steppa = ents.Create("prop_physics")
		self.steppa:SetMoveType(MOVETYPE_NONE)
		self.steppa:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self.steppa:SetModel("models/Humans/Group01/male_07.mdl")
		self.steppa:SetPos(self:LocalToWorld(Vector(0, 0, -5)))
		self.steppa:SetAngles(self:GetAngles())
		self.steppa:SetParent(self)
		self.steppa:DrawShadow(false)
		self.steppa:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.steppa:SetColor(Color(0, 0, 0, 0))
		self.steppa:SetModelScale(0.0001, 0.0001)

		timer.Simple(0.1, function()
			if not IsValid(self) or not IsValid(self.steppa) then
				return
			end

			self.steppa:ResetSequence("run_all_panicked")
			self.steppa:SetPoseParameter("move_x", 1)
			self.steppa:SetPlaybackRate(1)
		end)
	end

	if self:GetPhysicsObject():IsValid() then
		self:GetPhysicsObject():Wake()
	end
end

if CLIENT then
	return
end

function ENT:Think()
	if self.cyc == nil then
		self.cyc = 0
	end
	if self.cyc > 1 then
		self.cyc = 0
	end
	self.cyc = self.cyc + 0.02

	self.steppa:SetCycle(self.cyc)

	if self:GetNWBool("StepDecoyActive") then
		if not self:GetPhysicsObject():IsAsleep() then
			self:GetPhysicsObject():Sleep()
			self:SetAngles(Angle(0, self:GetAngles()[2], 0))
		end

		local ground = util.TraceLine({
			start = self:LocalToWorld(Vector(0, 0, 20)),
			endpos = self:LocalToWorld(Vector(0, 0, -20)),
			filter = self
		})

		self:SetPos(self:GetPos() + self:GetForward() * 3)
		self:SetPos(Vector(self:GetPos()[1], self:GetPos()[2], ground.HitPos[3] + 5))

		local etr = util.TraceLine({
			start = self:LocalToWorld(Vector(0, 0, 20)),
			endpos = self:LocalToWorld(Vector(0, 0, 20)) + self:GetForward() * 6,
			filter = self
		})

		if etr.Hit then
			if self:GetPhysicsObject():IsValid() then
				self:GetPhysicsObject():Wake()
			end
			self:GetPhysicsObject():ApplyForceCenter((self:GetForward() * -15) + (Vector(0, 0, 20)))
			self:SetNWBool("StepDecoyActive", false)
		end
	end

	self:NextThink(CurTime())
	return true
end