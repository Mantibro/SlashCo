AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "StepDecoy"
ENT.ClassName = "sc_stepdecoy"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "StepDecoyActive")
end

function ENT:Initialize()
	if SERVER then
		self:SetModel(SlashCoItems.StepDecoy.Model)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetStepDecoyActive(false)

		self.steppa = ents.Create("prop_physics")
		self.steppa:SetMoveType(MOVETYPE_NONE)
		self.steppa:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self.steppa:SetModel("models/Humans/Group01/male_07.mdl")
		self.steppa:SetPos(self:LocalToWorld(Vector(0, 0, -5)))
		self.steppa:SetAngles(self:GetAngles())
		self.steppa:SetParent(self)
		self.steppa:DrawShadow(false)
		self.steppa:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.steppa:SetColor(color_transparent)
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

local offsetVec1 = Vector(0, 0, 20)
local offsetVec2 = Vector(0, 0, -20)
function ENT:Think()
	if self.cyc == nil then
		self.cyc = 0
	end

	if self.cyc > 1 then
		self.cyc = 0
	end
	self.cyc = self.cyc + 0.02

	self.steppa:SetCycle(self.cyc)

	if self:GetStepDecoyActive() then
		local physObj = self:GetPhysicsObject()
		if not physObj:IsAsleep() then
			physObj:Sleep()
			self:SetAngles(Angle(0, self:GetAngles()[2], 0))
		end

		local etrStartPos = self:LocalToWorld(offsetVec1)
		local ground = util.TraceLine({
			start = etrStartPos,
			endpos = self:LocalToWorld(offsetVec2),
			filter = self,
			collisiongroup = COLLISION_GROUP_WORLD,
			mask = MASK_SOLID_BRUSHONLY,
		})

		local forward = self:GetForward()
		--self:SetPos(self:GetPos() + forward * 3)
		local pos = self:GetPos()
		self:SetPos(Vector(pos[1], pos[2], ground.HitPos[3] + 5))

		local etrEndPos = etrStartPos + forward
		etrEndPos:Mul(6)
		
		local etr = util.TraceLine({
			start = etrStartPos,
			endpos = etrEndPos,
			filter = self,
			collisiongroup = COLLISION_GROUP_WORLD,
			mask = MASK_SOLID_BRUSHONLY,
		})

		if etr.Hit then
			if physObj:IsValid() then
				physObj:Wake()
				
				forward:Mul(-15)
				forward:Add(offsetVec1)
				physObj:ApplyForceCenter(forward)
			end

			self:SetStepDecoyActive(false)
		end
	end

	self:NextThink(CurTime())
	return true
end