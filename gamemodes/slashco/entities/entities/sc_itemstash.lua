AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName 		= "sc_itemstash"
ENT.PrintName		= "itemstash"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "Supplying SlashCo workers with an item."
ENT.Instructions	= ""

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/hunter/blocks/cube2x3x025.mdl")
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( SIMPLE_USE )
		self:SetColor(Color(0,0,0,0)) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR ) 
	end
end

function ENT:Use( activator )

if SERVER then

	if activator:Team() == TEAM_SURVIVOR then 

		SlashCo.PlayerItemStashRequest(activator:SteamID64())

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