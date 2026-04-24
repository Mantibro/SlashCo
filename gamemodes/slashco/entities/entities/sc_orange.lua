AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Orange"
ENT.ClassName = "sc_orange"

function ENT:Initialize()
	self:SetModel("models/slashco/items/annoyingorange.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
end

function ENT:SetOrangeVelocity(velocity)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(velocity)
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/items/orange/orange_curse.mp3",
		identifier = "OrangeScream",
		minDistance = 300,
		maxDistance = 700,
		entity = self,
		volume = 1,
		fadeIn = 0,
	})
	self:SetSkin(1)

	self.EnableExposion = true
	self.DONTPICKUP = true -- Block being picked up again
end

function ENT:Explode()
	self.Exploded = true

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/beerkeg_explode.ogg",
		identifier = "OrangeExplode",
		minDistance = 300,
		maxDistance = 700,
		entity = self,
		volume = 1,
		fadeIn = 0,
	})

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/beerkeg_explode_far.mp3",
		identifier = "OrangeExplodeFar",
		minDistance = 1500,
		maxDistance = 2000,
		startDistance = 600,
		startEndDistance = 700,
		entity = self,
		volume = 0.7,
		fadeIn = 0,
	})

	local pos = self:GetPos()
	for _, ply in ipairs(SlashCo.FindPlayersInRange(pos, 200, nil, self)) do
		local team = ply:Team()
		if team == TEAM_SURVIVOR then
			ply:TakeDamage(90, self, self)
		elseif team == TEAM_SLASHER then
			ply:SlasherStunDeafen(5)
			ply:SetNWBool("OrangeBlur", true)
		end

		timer.Simple(5, function()
			if not IsValid(ply) then return end

			ply:SetNWBool("OrangeBlur", false)
		end)

		ply:SetVelocity((self:GetForward() * 600) + Vector(0, 0, 400))

		if ply:Alive() then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/beerkeg_tinnitus.ogg",
				identifier = "OrangeTinnitus",
				looping = true,
				volume = 1,
				fadeIn = 0,
				fadeOut = 2,
				fadeOutStart = 3,
				sendToEntity = ply,
			})
		end
	end

	ParticleEffect("beerkeg_fog", pos, angle_zero)
	self:Remove()
end

function ENT:PhysicsCollide(data)
	if not self.EnableExposion then return end

	if IsValid(data.HitEntity) and data.HitEntity:IsPlayer() and data.HitEntity:Team() == TEAM_SLASHER then
		self:Explode()
	end

	timer.Simple(2, function()
		if not IsValid(self) then return end

		self:Explode()
	end)
end

if CLIENT then
	hook.Add("SlashCo:DrawHUD", "Orange", function()
		if GameData.LocalPlayer:GetNWBool("OrangeBlur") then
			DrawSobel(0.3)
			DrawToyTown(4, ScrH() / 2)
		end
	end)
end