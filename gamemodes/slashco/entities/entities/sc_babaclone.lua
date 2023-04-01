AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName 		= "sc_babaclone"
ENT.PrintName		= "babaclone"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "A Bababooey clone."
ENT.Instructions	= ""
ENT.PingType = "SLASHER"

ENT.AutomaticFrameAdvance = true 

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/slashco/slashers/baba/baba.mdl")
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( SIMPLE_USE )
		self:DrawShadow(false)
		self:SetColor(Color(0,0,0,0))
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		--self:SetNoDraw(true)

		self:SetNWBool("CloneTripped", false)

		timer.Simple(0.1, function()

			self:ResetSequence( "prowl" )
			self:SetPoseParameter( "move_x", 1 )
			self:SetPlaybackRate( 2 )
	
		end)
	end
end

function ENT:Think()
	if  SERVER  then

		local tr = util.TraceLine( {
		start = self:LocalToWorld(Vector(0,0,40)),
		endpos = self:LocalToWorld(Vector(0,0,40)) + self:GetForward() * 1150
		} )

		local ground = util.TraceLine( {
			start = self:LocalToWorld(Vector(0,0,40)),
			endpos = self:LocalToWorld(Vector(0,0,40)) + self:GetUp() * -10000
		} )

		if tr.Entity:IsPlayer() and tr.Entity:Team() == TEAM_SURVIVOR and SlashCo.CurRound.SlasherEntities[self:EntIndex()].activateWalk == false and SlashCo.CurRound.SlasherEntities[self:EntIndex()].activateSpook == false then 
			SlashCo.CurRound.SlasherEntities[self:EntIndex()].activateWalk = true 
			self:EmitSound("slashco/slasher/baba_reveal.mp3") 
		end

		if SlashCo.CurRound.SlasherEntities[self:EntIndex()].activateWalk == true then 

			if SlashCo.CurRound.SlasherEntities[self:EntIndex()].PostActivation == false then 
				for s = 1, #team.GetPlayers(TEAM_SLASHER) do local sl = team.GetPlayers(TEAM_SLASHER)[s] sl:ChatPrint("A Bababooey Clone has been tripped!") end
			end

			SlashCo.CurRound.SlasherEntities[self:EntIndex()].PostActivation = true

			self:SetNWBool("CloneTripped", true)

			self:DrawShadow(true)
			self:SetColor(Color(255,255,255,255))
			self:SetRenderMode(RENDERMODE_TRANSCOLOR)
			self:SetNoDraw(false) 

			self:SetPos( self:GetPos() + self:GetForward() * 2 )
			self:SetPos( Vector(self:GetPos()[1],self:GetPos()[2],ground.HitPos[3]))

			local etr = util.TraceLine( {
				start = self:LocalToWorld(Vector(0,0,40)),
				endpos = self:LocalToWorld(Vector(0,0,40)) + self:GetForward() * 30
			} )

			if etr.Hit then table.RemoveByValue( SlashCo.CurRound.SlasherEntities, self:EntIndex() ) self:Remove()  end

		elseif SlashCo.CurRound.SlasherEntities[self:EntIndex()].activateSpook == true then 

			if SlashCo.CurRound.SlasherEntities[self:EntIndex()].PostActivation == false then 
				for s = 1, #team.GetPlayers(TEAM_SLASHER) do local sl = team.GetPlayers(TEAM_SLASHER)[s] sl:ChatPrint("A Bababooey Clone has been tripped!") end
			end

			if SlashCo.CurRound.SlasherEntities[self:EntIndex()].PostActivation == true then return end

			self:SetNWBool("CloneTripped", true)

			self:EmitSound("slashco/slasher/baba_reveal.mp3")

			self:EmitSound("slashco/slasher/baba_scare.mp3")
			self:DrawShadow(true)
			self:SetColor(Color(255,255,255,255))
			self:SetRenderMode(RENDERMODE_TRANSCOLOR)
			self:SetNoDraw(false) 
			self:ResetSequence( "spook" )
			self:SetPlaybackRate( 2 )

			SlashCo.CurRound.SlasherEntities[self:EntIndex()].PostActivation = true

			timer.Simple(1.75, function()

				table.RemoveByValue( SlashCo.CurRound.SlasherEntities, self:EntIndex() )

                self:Remove()
        
            end)

		end

		for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do
			local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

			if ply:GetPos():Distance( self:GetPos() ) < 150 then 
				SlashCo.CurRound.SlasherEntities[self:EntIndex()].activateSpook = true 
				self:SetAngles( Angle(0, (ply:GetPos() - self:GetPos() ):Angle()[2], 0) )
			end
		end

		self:NextThink( CurTime() )
		return true 
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