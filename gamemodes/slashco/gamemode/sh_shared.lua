GM.Name = "SlashCo"
GM.Author = "Octo, Manti, Text"
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

CreateConVar("slashco_player_cycle", "0", FCVAR_REPLICATED) --local cycle_players =

SlashCo = SlashCo or {}

SlashCo.GasPerGen = 4 --Default number of gas cans required to fill up a generator
SlashCo.Generators = 2 --Default number of generators
SlashCo.GensNeeded = 2 --Default number of generators needed
SlashCo.GeneratorModel = "models/slashco/other/generator/generator.mdl" --Model path for the generators
SlashCo.HelicopterModel = "models/slashco/other/helicopter/helicopter.mdl" --Model path for the helicopter
SlashCo.GhostPingDelay = 480

local lang_files, _ = file.Find("slashco/lang/*.lua", "LUA")
for _, v in ipairs(lang_files) do
	AddCSLuaFile("slashco/lang/" .. v)
end

local lang_patches, _ = file.Find("slashco/patch/lang/*.lua", "LUA")
for _, v in ipairs(lang_patches) do
	AddCSLuaFile("slashco/patch/lang/" .. v)
end

function GM:Initialize()
	-- Do stuff
end

function GM:CreateTeams()
	if not GAMEMODE.TeamBased then
		return
	end

	TEAM_SURVIVOR = 1
	team.SetUp(TEAM_SURVIVOR, "Survivor", Color(255, 255, 255))

	TEAM_SLASHER = 2
	team.SetUp(TEAM_SLASHER, "Slasher", Color(255, 0, 0))

	TEAM_LOBBY = 3
	team.SetUp(TEAM_LOBBY, "Lobby", Color(230, 255, 230))

	team.SetUp(TEAM_SPECTATOR, "Spectator", Color(135, 206, 235))
end

local DoorSlamWhitelist = {
	["models/props_c17/door03_left.mdl"] = true,
	["models/props_doors/doormain_rural01_small.mdl"] = true,
	["models/props_doors/doormainmetal01.mdl"] = true,
	["models/props_c17/door01_left.mdl"] = true,
	["models/props_c17/door_fg.mdl"] = true,
	["models/props_doors/doormain01.mdl"] = true,
	["models/props_doors/doorglassmain01.mdl"] = true,
	["models/props_doors/door_rotate_112.mdl"] = true,
	["models/props_doors/doormainmetalwindow01.mdl"] = true,
	["models/props_c17/door01_addg_medium.mdl"] = true
}

function SlashCo.CheckDoorWL(ent)
	return DoorSlamWhitelist[ent:GetModel()]
end

SCInfo = {}

SCInfo.Offering = {
	{
		Name = "Exposure",
		Rarity = 1,
		GasCanMod = 0
	},
	{
		Name = "Satiation",
		Rarity = 1,
		GasCanMod = 0
	},
	{
		Name = "Drainage",
		Rarity = 2,
		GasCanMod = 6
	},
	{
		Name = "Duality",
		Rarity = 3,
		GasCanMod = 0
	},
	{
		Name = "Singularity",
		Rarity = 3,
		GasCanMod = 6
	},
	{
		Name = "Nightmare",
		Rarity = 3,
		GasCanMod = 0
	}
}

SCInfo.Maps = {
	["error"] = {
		NAME = "Missing map!",
		DEFAULT = true,
		SIZE = 1,
		MIN_PLAYERS = 1,
		LEVELS = {
			500
		}
	},
}

local configs, _ = file.Find("slashco/configs/maps/*", "LUA")

local game_playable = false

if SERVER then
	SCInfo.MinimumMapPlayers = 6
end

for _, v in ipairs(configs) do
	local config = util.JSONToTable(file.Read("slashco/configs/maps/" .. v, "LUA"))
	if not config then
		continue
	end

	local mapid = string.Replace(v, ".lua", "")
	SCInfo.Maps[mapid] = SCInfo.Maps[mapid] or {}

	if type(config.Manifest) == "table" then
		if config.Manifest.DoNotUseThisConfig then
			SCInfo.Maps[mapid] = nil
			continue
		end

		SCInfo.Maps[mapid].NAME = config.Manifest.Name or "Unspecified Map Name"
		SCInfo.Maps[mapid].DEFAULT = config.Manifest.Default --wtf does this do...
		SCInfo.Maps[mapid].MIN_PLAYERS = config.Manifest.MinimumPlayers or 1
	else
		SCInfo.Maps[mapid].NAME = "Unspecified Map Name"
		SCInfo.Maps[mapid].MIN_PLAYERS = 1
	end

	if SERVER then
		SCInfo.MinimumMapPlayers = math.min(SCInfo.Maps[mapid].MIN_PLAYERS, SCInfo.MinimumMapPlayers)
	end

	game_playable = true
end

if SERVER and not game_playable then
	timer.Simple(30, function()
		for _, play in ipairs(player.GetAll()) do
			play:ChatPrint([[[SlashCo] WARNING! There are no maps mounted! The gamemode is not playable!
                
Download the Maps at the Gamemode's workshop page under the "Required Items" section.]])
		end
	end)
end

-- determine if a position is far enough away from generators and survivors
function SlashCo.IsPositionLegalForSlashers(pos, dist)
	dist = dist or (600 + GetGlobal2Int("SlashCoMapSize") * 150)

	for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if v:GetPos():Distance(pos) < dist then
			return false
		end
	end

	for _, v in ipairs(ents.FindInSphere(pos, dist)) do
		if v:GetClass() == "sc_generator" then
			return false
		end
	end

	return true
end