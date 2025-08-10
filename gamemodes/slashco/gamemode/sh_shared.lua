GM.Name = "SlashCo"
GM.Author = "Octo, Manti, Text"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = true

include("audiosystem/sh_audiosystem.lua")
include("player_class/player_survivor.lua")
include("player_class/player_slasher_base.lua")
include("player_class/player_lobby.lua")

game.AddParticles("particles/slashco.pcf")
PrecacheParticleSystem("pocketsand")

SlashCo = SlashCo or {}

SlashCo.GasPerGen = 4 --Default number of gas cans required to fill up a generator
SlashCo.Generators = 2 --Default number of generators
SlashCo.GensNeeded = 2 --Default number of generators needed
SlashCo.GeneratorModel = "models/slashco/other/generator/generator.mdl" --Model path for the generators
SlashCo.HelicopterModel = "models/slashco/other/helicopter/helicopter.mdl" --Model path for the helicopter
SlashCo.GhostPingDelay = 480
SlashCo.QuickEscapeTime = 600 -- Time in seconds to count as a quick escape
SlashCo.SlowEscapeTime = 1200 -- Time in seconds to count as a slow escape
SlashCo.OverTime = SlashCo.SlowEscapeTime - 300 -- Time in seconds when the survivors should be warned that they got only 5 minutes left before its a slow run. NOTE: At this point, some hints will be given to survivors like fuel cans will make sounds
SlashCo.AllowLateJoin = true -- If enabled, players that joined after the lobby was created BUT before the round was started will get spawned as survivors.
SlashCo.MaximumLateJoinTime = 180 -- Time in seconds in which players will still be spawned as survivors if they just took ages to load, though they won't be spawned a survivors if they weren't expected to join!

SlashCo.HelicopterVoices = {
	INTRO = 1,
	APPROACH = 2,
	LAND = 3,
	BEACON = 4,
}

function SlashCo.CopyColor(col)
	return Color(col:Unpack())
end

function SlashCo.GetRoundStartTime()
	return GetGlobal2Float("SCStartTime", CurTime()) -- We fallback to CurTime() since if we haven't started yet, the time should be 0 when calculated.
end

function SlashCo.GetRoundTime()
	return CurTime() - SlashCo.GetRoundStartTime()
end

function SlashCo.IsQuickEscape()
	return SlashCo.QuickEscapeTime > SlashCo.GetRoundTime()
end

function SlashCo.IsSlowEscape()
	return SlashCo.SlowEscapeTime < SlashCo.GetRoundTime()
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

function SlashCo.SetGlobalFogMult(mult)
	SetGlobal2Float("FogMult", mult)
end

function SlashCo.GetGlobalFogMult()
	return GetGlobal2Float("FogMult", 1)
end

-- Accepts a vector or color as input.
function SlashCo.SetGlobalFogColor(color)
	local r, g, b = 0, 0, 0
	if isvector(color) then -- If given a vector we assume it use a range from 0-1 for colors so we multiply it by 255
		r, g, b = color:Unpack()
		r, g, b = r * 255, g * 255, b * 255
	else
		r = color.r
		g = color.g
		b = color.b
	end

	SetGlobal2Float("FogColorR", r)
	SetGlobal2Float("FogColorG", g)
	SetGlobal2Float("FogColorB", b)
end

-- type = if not given, it will return a color object, if set to 1, it will return a vector with a colors as a range from 0-1, if set to 2, it will return 3 arguments r g b.
-- object = if not nil then it will use the given color or vector object and set the values directly into it instead of creating a new one
function SlashCo.GetGlobalFogColor(type, object)
	local r = GetGlobal2Float("FogColorR", 0)
	local g = GetGlobal2Float("FogColorG", 0)
	local b = GetGlobal2Float("FogColorB", 0)

	if not object then
		if not type then
			return Color(r, g, b)
		elseif type == 1 then
			return Vector(r / 255, g / 255, b / 255)
		elseif type == 2 then
			return r, g, b
		end
	else
		if not asVector then
			object.r = r
			object.g = g
			object.b = b
		else
			object:SetUnpacked(r / 255, g / 255, b / 255)
		end
	end
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
GameData.BaseMaxSurvivors = 6 -- Used later on to calculate balancement
GameData.BaseMaxPlayers = GameData.BaseMaxSurvivors + 1 -- 6 survivors, 1 slasher
GameData.MaxPlayers = GameData.BaseMaxPlayers -- This value is set in InitPostEntity & will be networked to all clients
GameData.TotalSlots = game.MaxPlayers()
GameData.IsSinglePlayer = game.SinglePlayer()
GameData.IsLan = GetConVar("sv_lan"):GetBool()
GameData.World = GameData.World or game.GetWorld()
MAX_EDICT = math.pow(2, MAX_EDICT_BITS)

if CLIENT then
	--GameData.LocalPlayer = nil
	--GameData.LocalSteamID = nil
	--GameData.LocalSteamID64 = nil
	--GameData.LocalEntIndex = -1
	GameData.StateOfLobby = GameData.StateOfLobby or 0
	GameData.LobbyInfoTable = GameData.LobbyInfoTable or {}
	GameData.TimeLeft = GameData.TimeLeft or nil
	GameData.LocalIsSlasher = GameData.LocalIsSlasher or false
	GameData.IsLobby = GetGlobal2Bool("SlashCo:IsLobby", GameData.IsLobby) -- For autorefresh
	GameData.Lobby = GetGlobal2String("SlashCo:Lobby", GameData.Lobby) -- For autorefresh
	GameData.IsLan = GetGlobal2Bool("SlashCo:IsLan", GameData.IsLan)
	GameData.IsNewPlayer = cookie.GetNumber("slashco_totalplaycount", 0) < 3 -- We keep track how many rounds they played. If they played more than 3 rounds, their not considered a new player anymore. this variable is used to enable hints for them.
	GameData.MaxPlayers = GetGlobal2Int("SlashCo:MaxPlayers", GameData.MaxPlayers) -- For autorefresh

	function GM:InitPostEntity()
		GameData.World = game.GetWorld()
		GameData.World:SetNW2VarProxy("SlashCo:MaxPlayers", function(_, _, _, newVal)
			GameData.MaxPlayers = newVal
		end)

		GameData.IsLobby = GetGlobal2Bool("SlashCo:IsLobby", GameData.IsLobby)
		GameData.Lobby = GetGlobal2String("SlashCo:Lobby", GameData.Lobby)
		GameData.IsLan = GetGlobal2Bool("SlashCo:IsLan", GameData.IsLan)
		GameData.MaxPlayers = GetGlobal2Int("SlashCo:MaxPlayers", GameData.MaxPlayers)

		if GameData.IsLan then -- We require this for multirun clients.
			SlashCo.SetupLanOverrides()
		end

		GameData.LocalPlayer = LocalPlayer()
		GameData.LocalEntIndex = GameData.LocalPlayer:EntIndex()
		GameData.LocalSteamID = GameData.LocalPlayer:SteamID()
		GameData.LocalSteamID64 = GameData.LocalPlayer:SteamID64()
	end
else
	local maxplayers = CreateConVar("slashco_maxplayers", tostring(GameData.BaseMaxPlayers), FCVAR_ARCHIVE, "The number of maximum players, by default 7. 6 survivors - 1 slasher", 1, 255)
	cvars.AddChangeCallback("slashco_maxplayers", function(convar, _, newValue)
		GameData.MaxPlayers = math.min(tonumber(newValue) or GameData.MaxPlayers, GameData.TotalSlots) -- We clamp it so that we cannot have more max players than slots to avoid confusion.
		SetGlobal2Int("SlashCo:MaxPlayers", GameData.MaxPlayers)
	end, "slashco_maxplayers_refresh")

	function GM:InitPostEntity()
		GameData.World = game.GetWorld()

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
		GameData.MaxPlayers = math.min(maxplayers and maxplayers:GetInt() or GameData.MaxPlayers, GameData.TotalSlots)
		SetGlobal2Int("SlashCo:MaxPlayers", GameData.MaxPlayers)

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
	-- Rarity can only range from 1 to 3. Their used only for the sound that is played when their enabled.
	offeringTbl.Rarity = math.Clamp(offeringTbl.Rarity, 1, 3)

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

	-- removing this may not be the best solution, need to check if theres a better way
	-- to prevent unplayable rounds for slashers that use this function
	
	--[[for _, v in ipairs(ents.FindInSphere(pos, dist)) do
		if v:GetClass() == "sc_generator" then
			return false
		end
	end]]

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