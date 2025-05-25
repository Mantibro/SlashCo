GM.Name = "SlashCo"
GM.Author = "Octo, Manti, Text"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = true

include("audiosystem/sh_audiosystem.lua")
include("player_class/player_survivor.lua")
include("player_class/player_slasher_base.lua")
include("player_class/player_lobby.lua")

SlashCo = SlashCo or {}

SlashCo.GasPerGen = 4 --Default number of gas cans required to fill up a generator
SlashCo.Generators = 2 --Default number of generators
SlashCo.GensNeeded = 2 --Default number of generators needed
SlashCo.GeneratorModel = "models/slashco/other/generator/generator.mdl" --Model path for the generators
SlashCo.HelicopterModel = "models/slashco/other/helicopter/helicopter.mdl" --Model path for the helicopter
SlashCo.GhostPingDelay = 480
SlashCo.QuickEscapeTime = 600 -- Time in seconds to count as a quick escape
SlashCo.SlowEscapeTime = 1200 -- Time in seconds to count as a slow escape
SlashCo.WarningTime = SlashCo.SlowEscapeTime - 300 -- Time in seconds when the survivors should be warned that they got only 5 minutes left before its a slow run.

SlashCo.HelicopterVoices = {
	INTRO = 1,
	APPROACH = 2,
	LAND = 3,
	BEACON = 4,
}

function SlashCo.CopyColor(col)
	return Color(col:Unpack())
end

function SlashCo.IsQuickEscape()
	return SlashCo.QuickEscapeTime > (CurTime() - GetGlobal2Float("SCStartTime"))
end

function SlashCo.IsSlowEscape()
	return SlashCo.SlowEscapeTime < (CurTime() - GetGlobal2Float("SCStartTime"))
end

SlashCo.UnknownCol = Color(200, 0, 0) -- Text Color used for fields that are unknown
SlashCo.KnownCol = Color(255, 255, 255) -- Text Color used for fields which are known

function SlashCo.GetDangerColor(danger)
	return (SlashCo.DangerLevel[SlashCo.DangerLevel[danger] .. "Tbl"] or {}).Color or SlashCo.DangerLevel.UnknownCol
end

function SlashCo.GetDangerSound(danger)
	return (SlashCo.DangerLevel[SlashCo.DangerLevel[danger] .. "Tbl"] or {}).Sound or SlashCo.DangerLevel.UnknownSound
end

function SlashCo.GetNameColor(name)
	return name == "Unknown" and SlashCo.UnknownCol or SlashCo.KnownCol
end

function SlashCo.GetClassColor(class)
	return class == SlashCo.SlasherClass.Unknown and SlashCo.UnknownCol or SlashCo.KnownCol
end

--[[
	DangerLevel's
	Use the SlashCo.AddDangerLevel and NEVER manually add stuff to SlashCo.DangerLevel
	This was done to have easier compatibility in the future

	idx option is only used for "Unknown" as it has to be at 0 but table.insert starts at 1
]]

SlashCo.DangerLevel = {} -- ToDo: Check this out later as it might be easier if we use tables to store the data instead of having sepeate entries for everything
function SlashCo.AddDangerLevel(dangerLevelTbl, idx)
	idx = idx or table.insert(SlashCo.DangerLevel, dangerLevelTbl.Name)

	SlashCo.DangerLevel[idx] = dangerLevelTbl.Name
	SlashCo.DangerLevel[dangerLevelTbl.Name] = idx
	SlashCo.DangerLevel[dangerLevelTbl.Name .. "Tbl"] = dangerLevelTbl
end

SlashCo.AddDangerLevel({
	Name = "Unknown",
	Color = SlashCo.UnknownCol,
	Sound = "slashco/difficulty/unknown.mp3", -- This file was previously named "slashco/music/slashco_intro.mp3"
}, 0)

SlashCo.AddDangerLevel({
	Name = "Moderate",
	Color = Color(255, 255, 0),
	Sound = "slashco/difficulty/moderate.mp3",
})

SlashCo.AddDangerLevel({
	Name = "Considerable",
	Color = Color(255, 155, 155),
	Sound = "slashco/difficulty/considerable.mp3",
})

SlashCo.AddDangerLevel({
	Name = "Devastating",
	Color = Color(255, 0, 0),
	Sound = "slashco/difficulty/devastating.mp3",
})

--[[
	Slasher Classes
]]

SlashCo.SlasherClass = {}
function SlashCo.AddSlasherClass(slasherClassTbl, idx)
	idx = idx or table.insert(SlashCo.SlasherClass, slasherClassTbl.Name)

	SlashCo.SlasherClass[idx] = slasherClassTbl.Name
	SlashCo.SlasherClass[slasherClassTbl.Name] = idx
end

SlashCo.AddSlasherClass({
	Name = "Unknown",
}, 0)

SlashCo.AddSlasherClass({
	Name = "Cryptid",
})

SlashCo.AddSlasherClass({
	Name = "Demon",
})

SlashCo.AddSlasherClass({
	Name = "Umbra",
})

--[[
	DifficultyLevel's
]]

SlashCo.DifficultyLevel = {
	EASY = 0,
	[0] = "EASY",

	NOVICE = 1,
	[1] = "NOVICE",

	INTERMEDIATE = 2,
	[2] = "INTERMEDIATE",

	HARD = 3,
	[3] = "HARD",
}

--[[
	Round States
]]

SlashCo.RoundState = {
	[0] = WON_ALL_ALIVE,
	WON_ALL_ALIVE = 0,

	[1] = WON_SOME_DEAD,
	WON_SOME_DEAD = 1,

	[2] = WON_ALL_DEAD,
	WON_ALL_DEAD = 2,

	[3] = LOST,
	LOST = 3,

	[4] = WON_DISTRESS,
	WON_DISTRESS = 4,

	[5] = CURSED,
	CURSED = 5,

	[6] = INTRO,
	INTRO = 6,
}

SlashCo.States = {
	LOBBY = 1,
	IN_GAME = 2,
	ENDING = 3,
}
SlashCo.State = SlashCo.State or SlashCo.States.LOBBY
SlashCo.IsPlayable = SlashCo.IsPlayable or false -- false if were missing maps to play on.

GameData = GameData or {} -- A table containing data that is frequently used, also stores data across lua refreshs to not break when editing.
GameData.Map = game.GetMap()
GameData.Lobby = GameData.Lobby or "sc_lobby" -- Map name of the default lobby, might change after GM:InitPostEntity was called(if you use it before it was called you might experience issues so don't use it too early)
GameData.IsLobby = GameData.Map == GameData.Lobby -- true if the current map is a lobby, same as above don't use it too early.
GameData.MaxPlayers = game.MaxPlayers()
GameData.IsSinglePlayer = game.SinglePlayer()
GameData.IsLan = GetConVar("sv_lan"):GetBool()

if CLIENT then
	--GameData.LocalPlayer = nil
	--GameData.LocalSteamID = nil
	--GameData.LocalSteamID64 = nil
	GameData.StateOfLobby = GameData.StateOfLobby or 0
	GameData.LobbyInfoTable = GameData.LobbyInfoTable or {}
	GameData.TimeLeft = GameData.TimeLeft or nil
	GameData.LocalIsSlasher = GameData.LocalIsSlasher or false
	GameData.IsLobby = GetGlobal2Bool("SlashCo:IsLobby", GameData.IsLobby) -- For autorefresh
	GameData.Lobby = GetGlobal2String("SlashCo:Lobby", GameData.Lobby) -- For autorefresh
	GameData.IsLan = GetGlobal2Bool("SlashCo:IsLan", GameData.IsLan)

	function GM:InitPostEntity()
		GameData.IsLobby = GetGlobal2Bool("SlashCo:IsLobby", GameData.IsLobby)
		GameData.Lobby = GetGlobal2String("SlashCo:Lobby", GameData.Lobby)
		GameData.IsLan = GetGlobal2Bool("SlashCo:IsLan", GameData.IsLan)

		if GameData.IsLan then -- We require this for multirun clients.
			SlashCo.SetupLanOverrides()
		end

		GameData.LocalPlayer = LocalPlayer()
		GameData.LocalSteamID = GameData.LocalPlayer:SteamID()
		GameData.LocalSteamID64 = GameData.LocalPlayer:SteamID64()
	end
else
	function GM:InitPostEntity()
		if GameData.IsLobby then
			GameData.Lobby = GameData.Map
			cookie.Set("SlashCo:LastLobby", GameData.Lobby)

			SlashCo.CreateHelicopter(Vector(644.594, -423.175, 40.004), Angle(0, 45, 0))
			SlashCo.CreateItemStash(Vector(-483.500, -260.000, 88.000), Angle(90, 180, 180))
			SlashCo.CreateOfferTable(Vector(940.838, 890.909, -191.853), Angle(0, -90, 0))
		else
			--[[
				Restore the last lobby value, if you for example started on sc_lobby_v2 and play a round.
				after the round it wouldn't know where to return to, so we restore the last lobby we've been on and use that.
			]]
			GameData.Lobby = cookie.GetString("SlashCo:LastLobby", GameData.Lobby)
		end

		SetGlobal2Bool("SlashCo:IsLobby", GameData.IsLobby) -- Network our state.
		SetGlobal2String("SlashCo:Lobby", GameData.Lobby)
		SetGlobal2Bool("SlashCo:IsLan", GameData.IsLan)

		if GameData.IsLan then
			SlashCo.SetupLanOverrides()
		end
	end
end

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

function SlashCo.Dampen(speed, from, to)
	return Lerp(1 - math.exp(-speed * FrameTime()), from, to)
end

SCInfo = {}

SCInfo.Offering = {} // use ipairs to iterate, if you use pairs you will get errors as the enums -> Exposure and such will be included.
function SlashCo.AddOffering(offeringTbl)
	SCInfo.Offering[offeringTbl.Name] = table.insert(SCInfo.Offering, offeringTbl)
end

SlashCo.AddOffering({
	Name = "Exposure",
	Rarity = 1,
	GasCanMod = 0
})

SlashCo.AddOffering({
	Name = "Satiation",
	Rarity = 1,
	GasCanMod = 0
})

SlashCo.AddOffering({
	Name = "Drainage",
	Rarity = 2,
	GasCanMod = 6
})

SlashCo.AddOffering({
	Name = "Duality",
	Rarity = 3,
	GasCanMod = 0
})

SlashCo.AddOffering({
	Name = "Singularity",
	Rarity = 3,
	GasCanMod = 6
})

SlashCo.AddOffering({
	Name = "Nightmare",
	Rarity = 3,
	GasCanMod = 0
})

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

function SlashCo.LoadMapConfigs(initialCheck)
	local configs, _ = file.Find("slashco/configs/maps/*", "LUA")
	local wasPlayable = SlashCo.IsPlayable
	SlashCo.IsPlayable = false

	if SERVER then
		SCInfo.MinimumMapPlayers = 6
	end

	for _, v in ipairs(configs) do
		local config = util.JSONToTable(file.Read("slashco/configs/maps/" .. v, "LUA"))
		if not config then continue end

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

		SlashCo.IsPlayable = true
	end

	if SERVER then
		if not SlashCo.IsPlayable then
			timer.Simple(math.max(30 - CurTime(), 0), function() -- If the game has already been running for a while don't use a 30sec timer
				for _, play in ipairs(player.GetAll()) do
					play:ChatPrint("[SlashCo] WARNING! There are no maps mounted!\nThe gamemode is not playable!\nDownload the Maps at the Gamemode's workshop page under the \"Required Items\" section.\nNOTE: After downloading a map you don't have to restart the game")
				end
			end)
		elseif SlashCo.IsPlayable and not wasPlayable and not initialCheck then
			timer.Simple(math.max(30 - CurTime(), 0), function() -- If the game has already been running for a while don't use a 30sec timer
				for _, play in ipairs(player.GetAll()) do
					play:ChatPrint("[SlashCo] Loaded configs for freshly mounted maps\nThe gamemode is now playable")
				end
			end)
		end
	end
end

SlashCo.LoadMapConfigs(true)
hook.Add("GameContentChanged", "SlashCo:RefreshMapConfigs", SlashCo.LoadMapConfigs)

-- determine if a position is far enough away from generators and survivors
function SlashCo.IsPositionLegalForSlashers(pos, noSurvivorCheck, distFactor)
	local dist = (600 + GetGlobal2Int("SlashCoMapSize", 1) * 150) * (distFactor or 1)

	for _, v in ipairs(ents.FindInSphere(pos, dist)) do
		if v:GetClass() == "sc_generator" then
			return false
		end
	end

	if noSurvivorCheck then
		return true
	end

	for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if v:GetPos():Distance(pos) < dist then
			return false
		end
	end

	return true
end

SlashCo.Objectives = {
	generator = {
		hasCount = true
	},
	helicopter = {},
	heliwait = {},
	trash = {
		hasCount = true,
		optional = true
	},
	mop = {
		hasCount = true,
		optional = true
	},
	trap = {
		hasCount = true,
		optional = true
	},
	page = {
		hasCount = true,
		optional = true
	},
}

SlashCo.ObjStatus = {
	INCOMPLETE = 0,
	COMPLETE = 1,
	FAILED = 2
}