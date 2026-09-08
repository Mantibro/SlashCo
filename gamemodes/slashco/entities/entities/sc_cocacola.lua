AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "CocaCola"
ENT.ClassName = "sc_cocacola"

function ENT:Initialize()
	self:SetModel("models/slashco/items/cocacola.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/items/coca/cocacolastanding.mp3",
		identifier = "CocaColaIdle",
		minDistance = 200,
		maxDistance = 600,
		looping = true,
		entity = self,
		volume = 1,
		fadeIn = 0,
	})
end

function ENT:SetColaVelocity(velocity)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(velocity)
	end

	self.EnableExposion = true
	self.DONTPICKUP = true -- Block being picked up again
end

function ENT:Explode()
	self.Exploded = true

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/beerkeg_explode.ogg",
		identifier = "CocaColaExplode",
		minDistance = 300,
		maxDistance = 1200,
		entity = self,
		volume = 1,
		fadeIn = 0,
	})

	local pos = self:GetPos()
	for _, ply in ipairs(SlashCo.FindPlayersInRange(pos, 200, nil, self)) do
		local team = ply:Team()

		if team == TEAM_SURVIVOR then
			ply:TakeDamage(30, self, self)
			if ply:Alive() then
				ply:AddEffect("Slowness", 9)
			end
		elseif team == TEAM_SLASHER then
			if ply:GetNWBool("PainisRage") then return end

			ply:Freeze(true)
		end

		timer.Simple(6, function()
			if not IsValid(ply) then return end

			ply:Freeze(false)
		end)
	end

	local find = ents.FindInSphere(self:GetPos(), 500)
	for f = 1, #find do
		local ent = find[f]

		if ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" then
			ent:SetVelocity(self:GetPos() * 500)
		end
	end

	local effect = EffectData()
	effect:SetOrigin(pos)
	effect:SetScale(50)
	util.Effect("Explosion", effect)

	SlashCo.AudioSystem.StopSound("CocaColaPuddle", 0, ply)

	self:Remove()
end

function ENT:WarningSound()
	timer.Simple(0.1, function()
		if not IsValid(self) then return end

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/items/coca/cocacolawarning.mp3",
			identifier = "CocaColaWarning",
			minDistance = 500,
			maxDistance = 2000,
			entity = self,
			volume = 1,
			fadeIn = 0,
		})
	end)

	timer.Simple(1.5, function()
		if not IsValid(self) then return end

		self:Explode()
	end)
end

function ENT:PhysicsCollide(data)
	if not self.EnableExposion then return end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/items/coca/cocacolapuddle.mp3",
		identifier = "CocaColaPuddle",
		minDistance = 300,
		maxDistance = 700,
		looping = true,
		entity = self,
		volume = 0.5,
		fadeIn = 0,
	})
end