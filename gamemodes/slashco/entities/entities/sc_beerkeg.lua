AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "BeerKeg"
ENT.ClassName = "sc_beerkeg"

function ENT:Initialize()
	self:SetModel("models/slashco/beerkeg.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableDrag(false)
		phys:SetMaterial("gmod_bouncy")
	end

	self.ExplodeMeter = 0
end

function ENT:SetBeerKegVelocity(velocity)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(velocity)
		self.DisableGravity = CurTime() + 1
	end
	self.EnableExposion = true
	self.DONTPICKUP = true -- Block being picked up again
end

local gravity = GetConVar("sv_gravity")
function ENT:Think()
	if CLIENT then return end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		local disableGavity = self.DisableGravity
		if disableGavity and CurTime() > disableGavity then
			return
		else
			phys:EnableGravity(false)
			self.DisableGravity = nil
		end

		-- If it had an impact we reduce gravity for a bit allowing more bouncing around :3
		local hadImpact = (self.NextImpact or 0) > CurTime()

		-- Applying a low gravity
		local gravity = (gravity:GetInt() * FrameTime()) * (hadImpact and 0.2 or 1)
		local vel = phys:GetVelocity()
		vel[3] = math.Clamp(vel[3], -200, 100)
		vel[3] = vel[3] - gravity

		phys:SetVelocity(vel)
	end
end

function ENT:Explode()
	self.Exploded = true

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/beerkeg_explode.ogg",
		identifier = "BeerKegExplode",
		minDistance = 300,
		maxDistance = 700,
		entity = self,
		volume = 1,
		fadeIn = 0,
	})

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/beerkeg_explode_far.mp3",
		identifier = "BeerKegExplodeFar",
		minDistance = 1500,
		maxDistance = 2000,
		startDistance = 600,
		startEndDistance = 700,
		entity = self,
		volume = 0.7,
		fadeIn = 0,
	})

	hook.Run("SlashCo:OnBeerKegExplode", self)

	local pos = self:GetPos()
	for _, ply in ipairs(SlashCo.FindPlayersInRange(pos, 200, nil, self)) do
		local team = ply:Team()
		if team == TEAM_SURVIVOR then
			ply:TakeDamage(50, self, self)
		elseif team == TEAM_SLASHER then
			ply:SlasherStunDeafen(25 + (ply:GetPerception() * 2.5)) -- 25 seconds + 2.5 seconds for every perception level
			ply:SlasherFunction("OnHitByBeerKeg")
		end

		if ply:Alive() then -- They survived the damage? Their ears won't >:3
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/beerkeg_tinnitus.ogg",
				identifier = "BeerKegTinnitus",
				looping = true,
				volume = 0.8, -- having some mercy with them
				fadeIn = 0,
				fadeOut = 2,
				fadeOutStart = 3,
				sendToEntity = ply,
			})
		end
	end

	local effect = EffectData()
	effect:SetOrigin(pos)
	effect:SetScale(200)

	util.Effect("Explosion", effect)

	ParticleEffect("beerkeg_fog", pos, angle_zero) -- A small fog though it shouldn't block any vision, it's just to visualize it's range.

	self:Remove()
end

function ENT:PhysicsCollide(data)
	if not self.EnableExposion then return end

	local tick = engine.TickCount()
	if (self.LastCollideTick or 0) == tick or self.Exploded or CurTime() < (self.NextImpact or 0) then return end -- Sometimes it can collide multiple times in the same frame. We don't want toes to count.

	self.LastCollideTick = tick	
	self.ExplodeMeter = self.ExplodeMeter + math.random(0.1, 0.25)
	self.NextImpact = CurTime() + 0.5

	if IsValid(data.HitEntity) and data.HitEntity:IsPlayer() and data.HitEntity:Team() == TEAM_SLASHER then
		self:Explode()
	end

	if self.ExplodeMeter >= 1 then
		self:Explode()
	else
		local rng = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/beerkeg_drop" .. rng .. ".mp3",
			identifier = "BeerKegImpact" .. rng,
			minDistance = 400,
			maxDistance = 600,
			entity = self,
			volume = 1,
			fadeIn = 0,
		})
	end
end