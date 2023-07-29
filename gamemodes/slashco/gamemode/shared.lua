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

--set up language

SlashCoLang = {}

include("lang/en.lua")
AddCSLuaFile("lang/en.lua")

SlashCoLangFallback = SlashCoLang

--[[local lang_files, _ = file.Find("slashco/gamemode/lang/*", "LUA")

for _, v in ipairs(lang_files) do  
    AddCSLuaFile("lang/"..v)
    include("lang/"..v)
end]]

function SlashCoLanguage(key, ...)
    local vars = {}
    for _, v in ipairs({...}) do
        if type(v) == "string" then
            table.insert(vars, SlashCoLanguage(v))
        else
            table.insert(vars, v)
        end
    end

    if SlashCoLang[key] then
        return string.format(SlashCoLang[key], unpack(vars))
    elseif SlashCoLangFallback[key] then
        return string.format(SlashCoLangFallback[key], unpack(vars))
    else
        return string.format(key, unpack(vars))
    end
end

function GetOfferingName(key)

    if SlashCoLang.OfferingPreceedsName then

        return SlashCoLanguage("Offering") .. " " .. SlashCoLanguage(key)

    else

        return SlashCoLanguage(key) .. " " .. SlashCoLanguage("Offering")

    end

end

function GM:Initialize()
    -- Do stuff
end

function GM:CreateTeams()

    if (not GAMEMODE.TeamBased) then
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

--[[function GM:PlayerSelectTeamSpawn(team, ply)
	
end]]

local DoorSlamWhitelist = {
    ["models/props_c17/door03_left.mdl"] = true,
    ["models/props_doors/doormain_rural01_small.mdl"] = true,
    ["models/props_doors/doormainmetal01.mdl"] = true,
    ["models/props_c17/door01_left.mdl"] = true,
    ["models/props_c17/door_fg.mdl"] = true,
    ["models/props_doors/doormain01.mdl"] = true,
    ["models/props_doors/doorglassmain01.mdl"] = true,
    ["models/props_doors/door_rotate_112.mdl"] = true,
    ["models/props_doors/doormainmetalwindow01.mdl"] = true
}

function g_CheckDoorWL(ent)
    return DoorSlamWhitelist[ent:GetModel()]

    --[[
    local allow = false
    for i = 1, #DoorSlamWhitelist do
        if ent:GetModel() == DoorSlamWhitelist[i] then
            allow = true
            break
        end
    end
    return allow
    --]]
end

SCInfo = {}

SCInfo.RoundEnd = {

    {
        On = "The assignment was successful.",
        Off = "The assignment was unsuccessful.",
        DB = "The assignment was only partially successful."
    },

    {
        FullTeam = "All of the dispatched SlashCo Workers were rescued.",
        NonFullTeam = "Not all of the dispatched SlashCo Workers could be rescued.",
        AlivePlayers = " were reported present on the rescue helicopter.",
        DeadPlayers = " could not make it out alive.",
        LeftBehindPlayers = " had to be left behind.",
        Fail = "The dispatched SlashCo Workers could not be rescued.",
        OnlyOneAlive = " was the only one to survive.",
    },

    {
        Loss = " are now presumed either dead or missing in action.",
        LossOnlyOne = " is now presumed either dead or missing in action.",
        LossComplete = "The Dispatched SlashCo Workers are now presumed either dead or missing in action.",
        DBWin = " had to be rescued before the assignment could be completed."
    }

}

SCInfo.Offering = {

    {
        Name = "Exposure",
        Rarity = 1,
        Description = "Will make Gas Cans easier to find,\nBut\nYou will not find more than you need.",
        GasCanMod = 0
    },

    {
        Name = "Satiation",
        Rarity = 1,
        Description = "The Slasher will be a Demon,\nand its items will be scarce,\nBut\nThe items will have greater effect.",
        GasCanMod = 0
    },

    {
        Name = "Drainage",
        Rarity = 2,
        Description = "Gas cans will be plentiful,\nBut\nGenerators will leak fuel over time.",
        GasCanMod = 6
    },

    {
        Name = "Duality",
        Rarity = 3,
        Description = "Only one generator will need to be powered,\nBut\nYou will face two Slashers.",
        GasCanMod = 0
    },

    {
        Name = "Singularity",
        Rarity = 3,
        Description = "Gas Cans will be plentiful,\nBut\nThe Slasher will grow much more powerful.",
        GasCanMod = 6
    },

    {
        Name = "Nightmare",
        Rarity = 3,
        Description = "The Helicopter will come rescue you regardless of Generators.\nFueling Generators will come with a massively increased Point bonus.\nBut\nSurvivors and Slasher will switch sides.",
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

local map_configs, _ = file.Find("slashco/configs/maps/*", "LUA")

local game_playable = false

if SERVER then
    SCInfo.MinimumMapPlayers = 6
end

for _, v in ipairs(map_configs) do
    if v ~= "template.lua" and v ~= "rp_deadcity.lua" then
        local config_table = util.JSONToTable(file.Read("slashco/configs/maps/" .. v, "LUA"))
        local mapid = string.Replace(v, ".lua", "")

        SCInfo.Maps[mapid] = {}
        SCInfo.Maps[mapid].NAME = config_table.Manifest.Name
        SCInfo.Maps[mapid].DEFAULT = config_table.Manifest.Default
        SCInfo.Maps[mapid].SIZE = config_table.Manifest.Size
        SCInfo.Maps[mapid].MIN_PLAYERS = config_table.Manifest.MinimumPlayers

        if SERVER then
            SCInfo.MinimumMapPlayers = math.min(SCInfo.Maps[mapid].MIN_PLAYERS, SCInfo.MinimumMapPlayers)
        end

        SCInfo.Maps[mapid].LEVELS = {}

        for ky, lvl in ipairs(config_table.Manifest.Levels) do
            SCInfo.Maps[mapid].LEVELS[ky] = lvl
        end

        game_playable = true
    end
end

if SERVER and not game_playable then
    timer.Simple(30, function()
        for _, play in ipairs(player.GetAll()) do
            play:ChatPrint([[[SlashCo] WARNING! There are no maps mounted! The Gamemode is not playable!
                
Download the Maps at the Gamemode's workshop page under the "Required Items" section.]])
        end
    end)
end