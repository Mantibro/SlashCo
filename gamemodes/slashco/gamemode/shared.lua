GM.Name = "SlashCo"
GM.Author = "Octo, Manti"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = true
GM.States = {
	LOBBY = 1,
	IN_GAME = 2
}
GM.State = GM.State or GM.States.LOBBY

include("player_class/player_survivor.lua")
include("player_class/player_slasher_base.lua")
include("player_class/player_lobby.lua")

AddCSLuaFile( "ui/fonts.lua" )

AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_headbob.lua" )
AddCSLuaFile( "cl_lobbyhud.lua" )
AddCSLuaFile( "cl_survivorhud.lua" )
AddCSLuaFile( "slasher/cl_slasher_ui.lua" )
AddCSLuaFile( "slasher/cl_slasher_picker.lua" )
AddCSLuaFile( "cl_item_picker.lua" )
AddCSLuaFile( "cl_offering_picker.lua" )
AddCSLuaFile( "cl_intro_hud.lua" )
AddCSLuaFile( "cl_roundend_hud.lua" )
AddCSLuaFile( "cl_jumpscare.lua" )
AddCSLuaFile( "cl_offervote_hud.lua" )
AddCSLuaFile( "cl_spectator_hud.lua" )
AddCSLuaFile( "cl_playermodel_picker.lua" )
AddCSLuaFile( "cl_gameinfo.lua" )

CreateConVar( "slashco_player_cycle", "0", FCVAR_REPLICATED ) --local cycle_players =

function GM:Initialize()
	-- Do stuff
end

function GM:CreateTeams()

	if ( not GAMEMODE.TeamBased ) then return end

	TEAM_SURVIVOR = 1
	team.SetUp( TEAM_SURVIVOR, "Survivor", Color( 255, 255, 255 ) )

	TEAM_SLASHER = 2
	team.SetUp( TEAM_SLASHER, "Slasher", Color( 255, 0, 0 ) )

	TEAM_LOBBY = 3
	team.SetUp( TEAM_LOBBY, "Lobby", Color( 230, 255, 230 ) )

	team.SetUp( TEAM_SPECTATOR, "Spectator", Color( 135, 206, 235 ) )

end

--[[function GM:PlayerSelectTeamSpawn(team, ply)
	
end]]

DoorSlamWhitelist = {
	"models/props_c17/door03_left.mdl",
	"models/props_doors/doormain_rural01_small.mdl",
	"models/props_doors/doormainmetal01.mdl",
	"models/props_c17/door01_left.mdl"
}

function CheckDoorWL(ent)
	allow = false
	for i = 1, #DoorSlamWhitelist do
		if ent:GetModel() == DoorSlamWhitelist[i] then
			allow = true
			break
		end
	end
	return allow
end