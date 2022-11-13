 
AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" )  
 
include('shared.lua')


util.AddNetworkString( "radio" )
 
function ENT:Initialize()
 
	self:SetModel( "models/props/cs_office/radio.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_NONE )  
	self:SetSolid( SOLID_VPHYSICS )      
	


end
 
local NextPrintTime = 0

function ENT:Use( activator, caller )


    if (CurTime() >= NextPrintTime) then
       
		net.Start( "radio" )
		net.WriteEntity( self )
	net.Send( activator )

	NextPrintTime = CurTime() + 1
	

    end
end
 
//Gonna have to redo the code for this, but its whatever
concommand.Add( "cl_playerpaint", function( ply, cmd, args )
	for k, v in ipairs( ents.FindByName( "secret" ) ) do
		if IsValid( v ) then
			v:Fire("Break")
		end
	end
end )
