AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "BurgerActive"
ENT.ClassName = "sc_activecrazyburger"

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/slashco/items/amborgeza.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.PhysObj = self:GetPhysicsObject()
		self.IncrementalSize = 0
		self.LastIncrement = 0

		if(self.PhysObj:IsValid()) then
			self.PhysObj:Wake()
		end

		self:EmitSound("weapons/smokegrenade/sg_explode.wav", 511, 100 )
	end

	function ENT:SetBurgerVelocity(velocity)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(velocity)
		end
	end

	function ENT:Think()
		if (self.LastIncrement + 1 <= CurTime()) then 
			self.LastIncrement = CurTime()
			self.IncrementalSize = math.Approach( self.IncrementalSize, 300, 128  )
		end

		local burgerPos = self:GetPos()

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if survivor:GetPos():Distance(burgerPos) > 300 then continue end

			if math.random(1, 20) == 1 then
				local idx = math.random(1, 5)
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/survivor_cough" .. idx .. ".mp3",
					identifier = "CoughingBaby" .. idx,
					minDistance = 400,
					maxDistance = 600,
					entity = survivor,
					volume = 1,
					fadeIn = 0,
				})
			end
		end

		for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if slasher:GetPos():Distance(burgerPos) > 300 then continue end

			slasher:SlasherStunDeafen(1 + (slasher:GetPerception() * 1))
		end

		timer.Simple(30.0, function()
			if not IsValid(self) then return end

			self:Remove()
		end)
	end

	function ENT:Use(activator)
		if activator:Team() == TEAM_SURVIVOR then
			if (self:IsPlayerHolding()) then return end

			activator:PickupObject(self)
		end
	end
end

if CLIENT then 
	function ENT:Initialize()
		local pos = self:GetPos()
		self.Emitter = ParticleEmitter( pos , false )
	end

	function ENT:Think()
		timer.Simple(29.9, function()
			if not IsValid(self) then return end
			if not self.Emitter:IsValid() then return end

			self.Emitter:Finish()
		end)
	end

	function ENT:Draw()
		self:DrawModel()
		local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:GetPos() )

		if (particle) then
			particle:SetVelocity( self:GetForward() * -65 )
			particle:SetDieTime(math.Rand( 5, 7 ))
			particle:SetStartAlpha( math.Rand( 55, 65 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 13, 15 ) )
			particle:SetEndSize( math.Rand( 240, 280 ) )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-1, 1) )
			particle:SetColor( 30, 100, 0 ) 
			particle:SetAirResistance( 100 ) 
			particle:SetGravity( VectorRand():GetNormalized()*math.random(45, 111)+Vector(0,math.random(55,155),math.random(45, 55)) ) 	
			particle:SetCollide( false )
		end
	end
end