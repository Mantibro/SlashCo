AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName = "sc_dogg"
ENT.PrintName = "Plush Dog"
ENT.Author = "Manti"
ENT.Contact = ""
ENT.Purpose = "I'm so sorry"
ENT.Instructions = ""
ENT.IsSelectable = true
ENT.PingType = "PLUSH DOG"

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/slashco/items/dogg.mdl")
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

	self.SoundTick = 0
end

if SERVER then
	function ENT:Use(activator)
		if activator:Team() == TEAM_SURVIVOR then
			if (self:IsPlayerHolding()) then
				return
			end
			activator:PickupObject(self)
		end
	end

	function ENT:Think()
		self.SoundTick = self.SoundTick + math.random(0, 1)

		if self.SoundTick > 100 then

			self:EmitSound("slashco/dogg" .. math.random(1, 4) .. ".mp3")
			self.SoundTick = 0
		end

		self:NextThink(CurTime())
		return true
	end
end