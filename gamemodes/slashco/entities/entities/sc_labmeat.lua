AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "LabMeat"
ENT.ClassName = "sc_labmeat"

function ENT:Initialize()
	if SERVER then
		self.ragdoll = ents.Create("prop_ragdoll")
		self.ragdoll:SetModel("models/slashco/items/labmeat.mdl")
		self.ragdoll.PingType = self.PingType
		self.ragdoll:SetPos(self:GetPos())
		self.ragdoll:SetNoDraw(false)
		self.ragdoll:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self.ragdoll:Spawn()

		self:SetModel("models/slashco/items/labmeat.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_BBOX)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_DISSOLVING) --Collide with nothing
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetNoDraw(true)
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end

	self.SoundTick = 0
end

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

		if SlashCo.ItemPickUp(activator, self:EntIndex(), "LabMeat") then
			self.ragdoll:Remove()
			activator:EmitSound("slashco/survivor/eat_mayo.mp3")
		end

		if self:IsPlayerHolding() then
			return
		end
	end

	function ENT:Think()
		self:SetPos(self.ragdoll:GetPos())
		self.SoundTick = self.SoundTick + math.random(0, 1)

		if self.SoundTick > 60 then
			self:EmitSound("npc/headcrab/idle" .. math.random(1, 3) .. ".wav")
			self.SoundTick = 0

			--jerk it

			local physCount = self.ragdoll:GetPhysicsObjectCount()
			for i = 0, (physCount - 1) do
				local PhysBone = self.ragdoll:GetPhysicsObjectNum(i)

				if PhysBone:IsValid() then
					PhysBone:SetVelocity(VectorRand(-5, 5))
					PhysBone:AddAngleVelocity(VectorRand(-1, 1) * 150)
				end
			end
		end

		self:NextThink(CurTime())
		return true
	end

	return
end