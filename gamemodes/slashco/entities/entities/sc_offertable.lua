AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName 		= "sc_offertable"
ENT.PrintName		= "offertable"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "A table for offerings."
ENT.Instructions	= ""
ENT.PingType = "OFFERING TABLE"

local offer = offer

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/slashco/other/lobby/offertable.mdl")
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( SIMPLE_USE )

		offer = ents.Create( "prop_physics" )

		offer:SetMoveType( MOVETYPE_NONE )
    	offer:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		offer:SetModel( "models/slashco/other/offerings/o_1.mdl" )
    	offer:SetPos( self:LocalToWorld( Vector(50,0,48)) )
    	offer:SetAngles( self:LocalToWorldAngles( Angle(0,0,0) ) )
    	offer:SetParent( self )
	end
end

function ENT:Think()

	if SERVER then

		if SlashCo.LobbyData.Offering > 0 then 
			offer:SetModel( "models/slashco/other/offerings/o_"..SlashCo.LobbyData.Offering..".mdl" )
			offer:SetColor(Color(255,255,255,255)) 
		else
			offer:SetModel( "" )
			offer:SetColor(Color(0,0,0,0)) 
			offer:SetRenderMode( RENDERMODE_TRANSCOLOR ) 
		end
	end

end

function ENT:Use( activator )

if SERVER then

	if activator:Team() == TEAM_LOBBY then 

		if #SlashCo.LobbyData.Offerors > 0 or SlashCo.LobbyData.Offering ~= 0 then activator:ChatPrint("An Offering has already been made.") return end

		--if #team.GetPlayers(TEAM_LOBBY) < 2 then activator:ChatPrint("Not enough players to make an Offering.") return end

		if SlashCo.LobbyData.ReadyTimerStarted then activator:ChatPrint("It is too late to make an Offering.") return end

		if getReadyState(activator) < 1 then

			SlashCo.BroadcastGlobalData()

			SlashCo.PlayerOfferingTableRequest(activator:SteamID64())

		else
			activator:ChatPrint("Cannot make an Offering when you are ready.")
		end

	end

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