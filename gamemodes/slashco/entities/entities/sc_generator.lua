AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName 		= "sc_generator"
ENT.PrintName		= "generator"
ENT.Author			= "Octo"
ENT.Contact			= ""
ENT.Purpose			= "Combustion engine powered generator unit."
ENT.Instructions	= ""

--local InInteraction = false
local SenderTable = {
	prog = 0,
	id = 0
}
local AntiSpam = false

function ENT:Initialize()
	if SERVER then
		self:SetModel( SlashCo.GeneratorModel )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE )

		self.PlaySound = false
	end
end

function ENT:Touch(otherEnt)
	if SERVER then
		if not SlashCo.CurRound.Generators[self:EntIndex()].Interaction and otherEnt:GetModel() == SlashCo.GasCanModel and otherEnt:IsPlayerHolding() and SlashCo.CurRound.Generators[self:EntIndex()].Remaining > 0 then
			--print("Gas Touch")

		SlashCo.RemoveGas( self, otherEnt )
		SlashCo.CancelSlasherSpawnDelay()

		local pgas = ents.Create( "prop_physics" )

		pgas:SetMoveType( MOVETYPE_NONE )
    	pgas:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		pgas:SetModel( SlashCo.GasCanModel )
    	pgas:SetPos( self:LocalToWorld( Vector(-18,30,55+(SlashCo.CurRound.Generators[self:EntIndex()].Progress*2)) ) )
    	pgas:SetAngles( self:LocalToWorldAngles( Angle(0,0,45+SlashCo.CurRound.Generators[self:EntIndex()].Progress) ) )
    	pgas:SetParent( self )

		SlashCo.CurRound.Generators[self:EntIndex()].PouredCanID = pgas:EntIndex()

		SlashCo.CurRound.Generators[self:EntIndex()].Interaction = true

		end

		if not SlashCo.CurRound.Generators[self:EntIndex()].HasBattery and otherEnt:GetModel() == SlashCo.BatteryModel and otherEnt:IsPlayerHolding() and otherEnt:GetPos():Distance(self:LocalToWorld( Vector(-7,25,50) )) < 18 then
			--print("Battery Touch")
			SlashCo.InsertBattery( self, otherEnt )

			SlashCo.CancelSlasherSpawnDelay()
		end

		if SlashCo.CurRound.Generators[self:EntIndex()].Remaining == 0 and SlashCo.CurRound.Generators[self:EntIndex()].HasBattery and not SlashCo.CurRound.Generators[self:EntIndex()].Running then
			SlashCo.CurRound.Generators[self:EntIndex()].Running = true
			local delay = 6
			self:EmitSound("slashco/generator_start.wav", 85, 100, 1)

    		timer.Simple(delay, function()

				--self:EmitSound("slashco/generator_loop.wav", 85, 100, 1)
				PlayGlobalSound("slashco/generator_loop.wav", 85, self)

    		end)

		end

	end
end

function ENT:Use( activator, caller, usetype )

if SERVER then

	if activator:Team() == TEAM_SURVIVOR then 

		if usetype == USE_ON then 
			SlashCo.CurRound.Generators[self:EntIndex()].Pouring = true 
			SlashCo.CurRound.Generators[self:EntIndex()].CurrentPourer = activator:SteamID64()
			AntiSpam = false

			if SlashCo.CurRound.Generators[self:EntIndex()].Remaining > 3 then
				SlashCo.CurRound.Generators[self:EntIndex()].ConsistentPourer = activator:SteamID64()
			else
				if SlashCo.CurRound.Generators[self:EntIndex()].CurrentPourer != SlashCo.CurRound.Generators[self:EntIndex()].ConsistentPourer then

					SlashCo.CurRound.Generators[self:EntIndex()].ConsistentPourer = 0

				end
			end
		end
		if usetype == USE_OFF then 
			SlashCo.CurRound.Generators[self:EntIndex()].Pouring = false 
			SlashCo.CurRound.Generators[self:EntIndex()].CurrentPourer = 0
			AntiSpam = false
			self:StopSound("slashco/generator_fill.wav")
		end

	end

end

end

function ENT:Think()

	if SERVER then

	local activator = player.GetBySteamID64(SlashCo.CurRound.Generators[self:EntIndex()].CurrentPourer)

	if not IsValid(activator) then self:StopSound("slashco/generator_fill.wav") return end

	if SlashCo.CurRound.Generators[self:EntIndex()].Interaction and SlashCo.CurRound.Generators[self:EntIndex()].Pouring then

		if activator:GetPos():Distance( self:GetPos() ) > 100 then 
			SlashCo.CurRound.Generators[self:EntIndex()].Pouring = false 
			SlashCo.CurRound.Generators[self:EntIndex()].CurrentPourer = 0
			self:StopSound("slashco/generator_fill.wav")
			AntiSpam = false
		end

		SlashCo.CurRound.Generators[self:EntIndex()].Progress = SlashCo.CurRound.Generators[self:EntIndex()].Progress + 0.01

		net.Start("mantislashcoGasPourProgress")

		SenderTable.prog = SlashCo.CurRound.Generators[self:EntIndex()].Progress
		SenderTable.id = activator:SteamID64()

		net.WriteTable( SenderTable )
		net.Broadcast()

		if AntiSpam == false then
			self:EmitSound("slashco/generator_fill.wav")
			AntiSpam = true
		end
	end

	if SlashCo.CurRound.Generators[self:EntIndex()].Progress > 0 then

		local PouredGas = ents.GetByIndex(SlashCo.CurRound.Generators[self:EntIndex()].PouredCanID)

		if PouredGas != nil then
			if PouredGas != NULL then
				PouredGas:SetAngles( self:LocalToWorldAngles( Angle(0,0,45+(SlashCo.CurRound.Generators[self:EntIndex()].Progress*6)) ) )
				PouredGas:SetPos( self:LocalToWorld( Vector(-18,30,55+(SlashCo.CurRound.Generators[self:EntIndex()].Progress*2)) ) )
			end
		end

		if SlashCo.CurRound.Generators[self:EntIndex()].Progress > 13 then 

			SlashCo.AddGas( self )

			SlashCoDatabase.UpdateStats(SlashCo.CurRound.Generators[self:EntIndex()].CurrentPourer, "Points", 5)

			AntiSpam = false
			self:StopSound("slashco/generator_fill.wav")

			SlashCo.CurRound.Generators[self:EntIndex()].PouredCanID = 0
		
			PouredGas:Remove()
		
			SlashCo.CurRound.Generators[self:EntIndex()].Progress = 0
		
			if SlashCo.CurRound.Generators[self:EntIndex()].Remaining == 0 and SlashCo.CurRound.Generators[self:EntIndex()].HasBattery and not SlashCo.CurRound.Generators[self:EntIndex()].Running then
				SlashCo.CurRound.Generators[self:EntIndex()].Running = true
				self:StopSound("slashco/generator_fill.wav")
				AntiSpam = false

				local delay = 6
				self:EmitSound("slashco/generator_start.wav", 85, 100, 1)

				if SlashCo.CurRound.Generators[self:EntIndex()].ConsistentPourer == SlashCo.CurRound.Generators[self:EntIndex()].CurrentPourer then

					SlashCoDatabase.UpdateStats(SlashCo.CurRound.Generators[self:EntIndex()].ConsistentPourer, "Points", 25)

				end

				timer.Simple(delay, function()

					self.PlaySound = true

				end)

			elseif SlashCo.CurRound.Generators[self:EntIndex()].HasBattery and SlashCo.CurRound.Generators[self:EntIndex()].Remaining > 0 then

				self:EmitSound("slashco/generator_failstart.wav", 85, 100, 1)
				
			end

			SlashCo.CurRound.Generators[self:EntIndex()].Pouring = false
		
			SlashCo.CurRound.Generators[self:EntIndex()].Interaction = false
		
		end

	end

	if self.PlaySound then

		if self.RunningSound == nil then 
            self.RunningSound = CreateSound( slasher, "slashco/slasher/generator_loop.wav")
        else
            self.RunningSound:SetSoundLevel( 85 )
            self.RunningSound:Play() 
        end

	end

	self:NextThink( CurTime() ) -- Set the next think to run as soon as possible, i.e. the next frame.

	return true -- Apply NextThink call

end

end

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

if CLIENT then
    function ENT:Draw()
		self:DrawModel()
	end
end