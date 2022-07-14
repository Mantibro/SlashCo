SlashCo = {}

SlashCo.CurConfig = {}

--Difficulty ENUM
SlashCo.Difficulty = {
    EASY = 0,
    NOVICE = 1,
    INTERMEDIATE = 2,
    HARD = 3
}

SlashCo.Maps = {

    {
        ID = "sc_summercamp",
        NAME = "Black Lake Summer Camp"
    },

    {
        ID = "rp_deadcity",
        NAME = "Dead City"
    }

}

SlashCo.MAXPLAYERS = 5

SlashCo.Items = {
    MILK = {Model = "models/props_junk/garbage_milkcarton001a.mdl", Material = ""},
    COOKIE = {Model = "models/slashco/items/cookie.mdl", Material = ""},
    BABY = {Model = "models/props_c17/doll01.mdl", Material = ""},
    STEP_DECOY = {Model = "models/props_junk/Shoe001a.mdl", Material = ""},
    GAS_CAN = {Model = SlashCo.GasCanModel, Material = ""},
    DEATHWARD = {Model = "models/slashco/items/deathward.mdl", Material = ""},
    DISTRESS_BEACON = {Model = "models/props_c17/light_cagelight01_on.mdl", Material = ""},
    MAYO = {Model = "models/props_lab/jar01a.mdl", Material = ""},
    DEVILS_GAMBLE = {Model = "models/slashco/items/devildie.mdl", Material = ""},
    SODA = {Model = "models/props_junk/PopCan01a.mdl", Material = ""}
}

SlashCo.SlasherData = {     --Information about Slashers.

    --[[
        CLS - Slasher Class
        1 - Cryptid
        2 - Demon
        3 - Umbra

        DNG - Danger Level
        1 - Moderate
        2 - Considerable
        3 - Devastating
    ]] 

    {
        NAME = "Bababooey",
        ID = 1,
        CLS = 1,
        DNG = 1,
        Model = "models/slashco/slashers/baba/baba.mdl",
        KillDelay = 1.5,
        GasCanMod = 0,
        ProwlSpeed = 150,
        ChaseSpeed = 290,
        Perception = 1.0,
        Eyesight = 5,
        KillDistance = 135,
        ChaseRange = 700,
        ChaseDuration = 10.0,
        JumpscareDuration = 1.5,
        ChaseMusic = "slashco/slasher/baba_chase.wav",
        KillSound = "slashco/slasher/baba_kill.mp3"
    },

    {
        NAME = "Sid",
        ID = 2,
        CLS = 2,
        DNG = 2,
        Model = "models/slashco/slashers/sid/sid.mdl",
        KillDelay = 3,
        GasCanMod = 0,
        ProwlSpeed = 150,
        ChaseSpeed = 270,
        Perception = 1,
        Eyesight = 3,
        KillDistance = 120,
        ChaseRange = 1500,
        ChaseDuration = 6.0,
        JumpscareDuration = 1,
        ChaseMusic = "slashco/slasher/sid_chase.wav",
        KillSound = "slashco/slasher/sid_kill.mp3"
    },

    {
        NAME = "Trollge",
        ID = 3,
        CLS = 3,
        DNG = 3,
        Model = "models/slashco/slashers/trollge/trollge.mdl",
        KillDelay = 1.5,
        GasCanMod = 0,
        ProwlSpeed = 150,
        ChaseSpeed = 200,
        Perception = 3.0,
        Eyesight = 2,
        KillDistance = 100,
        ChaseRange = 0,
        ChaseDuration = 0.0,
        JumpscareDuration = 2,
        ChaseMusic = "",
        KillSound = "slashco/slasher/trollge_kill.wav"
    },

    {
        NAME = "Amogus",
        ID = 4,
        CLS = 1,
        DNG = 1,
        Model = "models/slashco/slashers/amogus/amogus.mdl",
        KillDelay = 2,
        GasCanMod = 0,
        ProwlSpeed = 150,
        ChaseSpeed = 275,
        Perception = 4.5,
        Eyesight = 6,
        KillDistance = 130,
        ChaseRange = 400,
        ChaseDuration = 15.0,
        JumpscareDuration = 2,
        ChaseMusic = "slashco/slasher/amogus_chase.wav",
        KillSound = "slashco/slasher/amogus_kill.mp3"
    },

    {
        NAME = "Thirsty",
        ID = 5,
        CLS = 2,
        DNG = 2,
        Model = "models/slashco/slashers/thirsty/thirsty.mdl",
        KillDelay = 2,
        GasCanMod = 0,
        ProwlSpeed = 150,
        ChaseSpeed = 250,
        Perception = 1.0,
        Eyesight = 2,
        KillDistance = 150,
        ChaseRange = 900,
        ChaseDuration = 8.0,
        JumpscareDuration = 2,
        ChaseMusic = "slashco/slasher/thirsty_chase.wav",
        KillSound = "slashco/slasher/thirsty_kill.mp3"
    },

}

SlashCo.LobbyData = {

    LOBBYSTATE = 0,
    Offering = 0,
    ButtonDoorPrimary = NULL,
    ButtonDoorPrimaryClose = NULL,
    ButtonDoorSecondary = NULL,
    ButtonDoorSecondaryClose = NULL,
    ButtonDoorItems = NULL,
    Players = {},
    Offerors = {},
    VotedOffering = 0,
    ReadyTimerStarted = false,
    PotentialSurvivors = {},
    PotentialSlashers = {},
    AssignedSurvivors = {},
    AssignedSlashers = {},
    SelectedDifficulty = 0,
    SurvivorGasMod = 0,
    SelectedSlasherInfo = {

        ID = 0,
        CLS = 0,
        DNG = 0,
        NAME = "Unknown",
        TIP = "--//--"

    },
    SelectedMapNum = 0,
    FinalSlasherID = 0,

}

--Holds all the information about the ongoing round
SlashCo.ResetCurRoundData = function()
    SlashCo.CurRound = {
        Difficulty = SlashCo.Difficulty.EASY,
        ExpectedPlayers = {},
        ExpectedPlayersLoaded = false,
        ConnectedPlayers = {},
        AntiLoopSpawn = false,
        OfferingData = {
            CurrentOffering = 0,
            GasCanMod = 0,
            SO = 0,
            DO = false,
            SatO = 0,
            DrainageTick = 0,
            ItemMod = 0
        },
        SlasherData = {
            AllSurvivors = {}, --This table holds all survivors loaded for this round, dead or alive, as well as their contribution value to the round. (TODO: game contribution)
            AllSlashers = {},
            GameProgress = -1,
            GameReadyToBegin = false
        },
        SurvivorData = {
            GasCanMod = 0, --This will decrement if someone chooses a gas can to take in as an item.
            Items = {}
        },
        Generators = {
            --This will store all active generators during the round and their power/fuel state.
        },
        SlasherEntities = { --Slasher's unique entities, such as bababooey's clones.

        },
        GasCans = {},
        ExposureSpawns = {}, --This is only used in TestConfig()
        Batteries = {},
        Items = {},
        Helicopter = 0,
        AlivePlayers = {},
        DeadPlayers = {},
        SkipSlasherSpawnTimer = false,
        SlashersToBeSpawned = {},
        Slashers = {},
        Spectators = {},
        SurvivorCount = 0,
        GeneratorCount = 2,
        GasCanCount = 8,
        ItemCount = 4,
        roundOverToggle = false,
        SlasherSpawned = false,
        SummonHelicopter = false,
        HelicopterSpawnPosition = Vector(0,0,0),
        HelicopterTargetPosition = Vector(0,0,0),
        AllowRoundEndSequence = false,
        EscapeHelicopterSummoned = false,
        EscapeHelicopterSpawned = false,
        DistressBeaconUsed = false,
        IsRadioTalkEnabled = false
    }
end
SlashCo.ResetCurRoundData()

SlashCo.GasCanModel = "models/props_junk/metalgascan.mdl" --Model path for the gas cans
SlashCo.GeneratorModel = "models/props_vehicles/generatortrailer01.mdl" --Model path for the generators
SlashCo.BatteryModel = "models/items/car_battery01.mdl" --Model path for the batteries
SlashCo.HelicopterModel = "models/slashco/other/helicopter/helicopter.mdl" --Model path for the helicopter
SlashCo.GasCansPerGenerator = 4 --Number of gas cans required to fill up a generator
SlashCo.PlayerData = {} --Holds all loaded playerdata

SlashCo.LoadCurRoundData = function()

if SERVER then

    table.Empty( SlashCo.CurRound.ExpectedPlayers )

    if sql.TableExists("slashco_table_basedata") and sql.TableExists("slashco_table_survivordata") and sql.TableExists("slashco_table_slasherdata") then

        --Load relevant data from the database
        local diff = sql.Query("SELECT Difficulty FROM slashco_table_basedata; ")[1].Difficulty
        local offering = sql.Query("SELECT Offering FROM slashco_table_basedata; ")[1].Offering
        local slasher1id = sql.Query("SELECT SlasherIDPrimary FROM slashco_table_basedata; ")[1].SlasherIDPrimary
        local slasher2id = sql.Query("SELECT SlasherIDSecondary FROM slashco_table_basedata; ")[1].SlasherIDSecondary
        local survivorgasmod = sql.Query("SELECT SurviorGasMod FROM slashco_table_basedata; ")[1].SurviorGasMod

        print("[SlashCo] RoundData Loaded with Difficulty of: "..diff..", Offering of: "..offering.." and GasMod of: "..survivorgasmod)

        --Transfer loaded data into the main table
        SlashCo.CurRound.Difficulty = diff
        SlashCo.CurRound.SurvivorData.GasCanMod = survivorgasmod
        SlashCo.CurRound.OfferingData.CurrentOffering = tonumber(offering)

        --First we insert the Slasher. If the Slasher does not join in time the game cannot begin.

        --Insert the First and second Slasher into the table
        for e = 1, #sql.Query("SELECT * FROM slashco_table_slasherdata; ") do
            table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = sql.Query("SELECT * FROM slashco_table_slasherdata; ")[e].Slashers})
        end

        --Survivors don't necessarily have to join in time, as the game can continue with at least 1. (TODO)
        --TODO: timer which starts the game premature if some survivors don't join in time.

        for i = 1, #sql.Query("SELECT * FROM slashco_table_survivordata; ") do

            if sql.Query("SELECT * FROM slashco_table_survivordata; ")[i].Survivors != nil then
                --Survivors due to connect
                table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = sql.Query("SELECT * FROM slashco_table_survivordata; ")[i].Survivors})
                    --For the slasher's clientside view also
                    table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = sql.Query("SELECT * FROM slashco_table_survivordata; ")[i].Survivors, GameContribution = 0})
                --Items
                table.insert(SlashCo.CurRound.SurvivorData.Items, {steamid = sql.Query("SELECT * FROM slashco_table_survivordata; ")[i].Survivors, itemid = tonumber(sql.Query("SELECT * FROM slashco_table_survivordata; ")[i].Item) })
            end

        end

        print("[SlashCo] First 2 Expected Players assigned: "..SlashCo.CurRound.ExpectedPlayers[1].steamid..SlashCo.CurRound.ExpectedPlayers[2].steamid)
        print("[SlashCo] Expected Player table size: "..#SlashCo.CurRound.ExpectedPlayers)

        SlashCo.CurRound.ExpectedPlayersLoaded = true

        for s = 1, #sql.Query("SELECT * FROM slashco_table_slasherdata; ") do

            local id = sql.Query("SELECT * FROM slashco_table_slasherdata; ")[s].Slashers

            SlashCo.InsertSlasherToTable(id)

            timer.Simple(1, function() 

                print("[SlashCo] Selecting Slasher for player with id: "..id)        
                --if s == 1 then SlashCo.SelectSlasher(tonumber(slasher1id), id) end
                if s == 1 then SlashCo.SelectSlasher(3, id) end
                if s == 2 then SlashCo.SelectSlasher(tonumber(slasher2id), id) end

            end)
    
        end


    else

        print("[SlashCo] Something went wrong while trying to load the round data from the Database! Restart imminent.")

        SlashCo.EndRound()

    end

end

end

SlashCo.AwaitExpectedPlayers =  function()

if SERVER then

if game.GetMap() != "sc_lobby" then

    print("[SlashCo] Now running player expectation...")

    local ExpectTrue = false
    local P1 = false
    local P2 = false
    local P3 = false
    local P4 = false
    local P5 = false

    if SlashCo.CurRound.ExpectedPlayersLoaded == true and ExpectTrue == false then

        print("[SlashCo] Now expecting players..!")

        if table.HasValue(player.GetAll(), player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[1].steamid)) then
            P1 = true
            print("[SlashCo] Expected player 1 in!".."("..player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[1].steamid):Name()..")")
        end

        if table.HasValue(player.GetAll(), player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[2].steamid)) then
            P2 = true
            print("[SlashCo] Expected player 2 in!".."("..player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[2].steamid):Name()..")")
        end

        if SlashCo.CurRound.ExpectedPlayers[3] != nil and table.HasValue(player.GetAll(), player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[3].steamid)) then
            P3 = true
            print("[SlashCo] Expected player 3 in!".."("..player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[3].steamid):Name()..")")
        end

        if SlashCo.CurRound.ExpectedPlayers[4] != nil and table.HasValue(player.GetAll(), player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[4].steamid)) then
            P4 = true
            print("[SlashCo] Expected player 4 in!".."("..player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[4].steamid):Name()..")")
        end

        if SlashCo.CurRound.ExpectedPlayers[5] != nil and table.HasValue(player.GetAll(), player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[5].steamid)) then
            P5 = true
            print("[SlashCo] Expected player 5 in!".."("..player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[5].steamid):Name()..")")
        end

        if #SlashCo.CurRound.ExpectedPlayers == 2 and P1 == true and P2 == true then ExpectTrue = true print("[SlashCo] Expectation successful with 2 players!") end
        if #SlashCo.CurRound.ExpectedPlayers == 3 and P1 == true and P2 == true and P3 == true then ExpectTrue = true end
        if #SlashCo.CurRound.ExpectedPlayers == 4 and P1 == true and P2 == true and P3 == true and P4 == true then ExpectTrue = true end
        if #SlashCo.CurRound.ExpectedPlayers == 5 and P1 == true and P2 == true and P3 == true and P4 == true and P5 == true then ExpectTrue = true end

    end

    if SlashCo.CurRound.AntiLoopSpawn == false and ExpectTrue == true then

        --All players that need to be in are in, begin.

        SlashCo.CurRound.AntiLoopSpawn = true

        print("[SlashCo] All players connected. Starting in 15 seconds. . .")

        SlashCo.CurRound.SlasherData.GameReadyToBegin = true

        SlashCo.RoundBeginTimer()

        table.Empty( SlashCo.CurRound.ExpectedPlayers )

    end

end

end

end

--				***Begin the round start timer***
SlashCo.RoundBeginTimer = function()
	timer.Create( "GameStart", 15, 1, function() if SERVER then RunConsoleCommand("slashco_curconfig_run") end end)
end

concommand.Add( "slashco_curconfig_run", function( ply, cmd, args )

    SlashCo.RemoveAllCurRoundEnts()
	
    SlashCo.LoadCurRoundTeams()

    SlashCo.SpawnCurConfig()

end )


SlashCo.LoadCurRoundTeams = function()

if SERVER then

    if sql.TableExists("slashco_table_basedata") and sql.TableExists("slashco_table_survivordata") and sql.TableExists("slashco_table_slasherdata") then

        print("[SlashCo] Teams database loaded...")

        local survivors = sql.Query("SELECT * FROM slashco_table_survivordata; ")
        local slashers = sql.Query("SELECT * FROM slashco_table_slasherdata; ")

        for play = 1, #player.GetAll() do --Assign the teams for the current round

            local playercur = player.GetAll()[play]
            local id = playercur:SteamID64()

            print("name: "..playercur:Name())
            
            for i = 1, #survivors do
                if id == survivors[i].Survivors then 
                    
                    playercur:SetTeam(TEAM_SURVIVOR)
                    playercur:Spawn()
                    print(playercur:Name().." now Survivor")

                    if SlashCo.GetHeldItem(playercur) == 2 then SlashCo.PlayerData[id].Lives = 2 end --Apply Deathward
                    
                    break

                else

                    if slashers[1] != nil and id == slashers[1].Slashers then goto CONTINUE end
                    if slashers[2] != nil and id == slashers[2].Slashers then goto CONTINUE end

                    for k = 1, #survivors do
                        if id == survivors[k].Survivors then goto CONTINUE end
                    end

                    playercur:SetTeam(TEAM_SPECTATOR)
                    playercur:Spawn()
                    print(playercur:Name().." now Spectator")
                end
                ::CONTINUE::
            end

            for i = 1, #slashers do     
                if id == slashers[i].Slashers then 
                    print(playercur:Name().." now Slasher (Memorized)")
                    playercur:SetTeam(TEAM_SPECTATOR)
                    playercur:Spawn()

                    table.insert(SlashCo.CurRound.SlashersToBeSpawned,{ID = id})

                end
            end

        end

        SlashCo.CurRound.SurvivorCount = #survivors

        local id1 = slashers[1].Slashers
        local id2 = 0
        if slashers[2] != nil then id2 = slashers[2].Slashers end

        timer.Simple(0.05, function()

            print("[SlashCo] Now proceeding with Spawns...")

            SlashCo.PrepareSlasherForSpawning()

            SlashCo.SpawnPlayers()

            SlashCo.BroadcastItemData()
    
        end)


    else

        print("[SlashCo] Something went wrong while trying to load the round data from the Teams Database! Restart imminent.")

        SlashCo.EndRound()

    end

end

end

SlashCo.SpawnPlayers = function()

    for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

        ply = team.GetPlayers(TEAM_SURVIVOR)[i]

        local pos = Vector(SlashCo.CurConfig.Spawnpoints.Survivor[i].pos[1],SlashCo.CurConfig.Spawnpoints.Survivor[i].pos[2],SlashCo.CurConfig.Spawnpoints.Survivor[i].pos[3])
        local ang = Angle( 0, SlashCo.CurConfig.Spawnpoints.Survivor[i].ang ,0 )


        ply:SetPos( pos )
        ply:SetAngles( ang )

    end

end

SlashCo.RespawnPlayer = function(ply, hp)

    i = math.random(1, #SlashCo.CurConfig.Spawnpoints.Survivor)

    if hp == nil then hp = 100 end

    local pos = Vector(SlashCo.CurConfig.Spawnpoints.Survivor[i].pos[1],SlashCo.CurConfig.Spawnpoints.Survivor[i].pos[2],SlashCo.CurConfig.Spawnpoints.Survivor[i].pos[3])
    local ang = Angle( 0, SlashCo.CurConfig.Spawnpoints.Survivor[i].ang ,0 )

    ply:SetTeam(TEAM_SURVIVOR)
    ply:Spawn()
    ply:SetPos( pos )
    ply:SetAngles( ang )
    ply:SetHealth(hp)

end

--Returns whether a config for the given map exists or not
SlashCo.CheckMap = function(map)
    return file.Exists("slashco/configs/maps/"..map..".lua", "LUA")    
end

--Loads a config file and return its contents as a table from JSON
SlashCo.LoadMap = function(map)
    if not SlashCo.CheckMap(map) then return nil end

    return util.JSONToTable(file.Read("slashco/configs/maps/"..map..".lua", "LUA")) or nil
end

--Algorithm found on reddit from u/skeeto, adapted to GLua functions
function permute(lim)
    -- Operate on nearest power of 2 up
    local n = math.ceil(math.log(lim) / math.log(2))
    local m = bit.lshift(1, n)
    local i = 0

    -- Hash function parameters
    local shift = n // 2
    local mask = bit.lshift(1, n) - 1
    local a = math.random(bit.lshift(1, n))
    local b = bit.bor(math.random(bit.lshift(1, n)), 1)
    local c = bit.bor(math.random(bit.lshift(1, n)), 1)
    local d = bit.bor(math.random(bit.lshift(1, n)), 1)

    return function()
        while i < m do
            -- xorshift hash function
            local x = i
            x = bit.band((x + a), mask)
            x = bit.bxor(x, bit.rshift(x, shift))
            x = bit.band((x * b), mask)
            x = bit.bxor(x, bit.rshift(x, shift))
            x = bit.band((x * c), mask)
            x = bit.bxor(x, bit.rshift(x, shift))
            x = bit.band(x * d, mask)
            x = bit.bxor(x, bit.rshift(x, shift))
            i = i + 1
            if x > 0 and x <= lim then
                return x
            end
        end
    end
end

--Gets a list of randomly generated unique spawnpoints
SlashCo.GetSpawnpoints = function(amount, limit)
    local outRand = {}

    if amount == limit then
        for I=1, limit do
            table.insert(outRand, I)
        end

        return outRand
    end

    for I in permute(limit) do
        table.insert(outRand, I)
        if #outRand == amount then break end
    end

    return outRand
end

--Check the given map to make sure the config is usable
SlashCo.ValidateMap = function(map)
    local valid = true

    if not SlashCo.CheckMap(map) then
        ErrorNoHalt("[SlashCo] This map has no configuration and will be impossible to complete!\n")
        valid = false
    end

    local json = SlashCo.LoadMap(map)

    if json == nil then
        ErrorNoHalt("[SlashCo] This map's JSON has an error in it and could not be read, this map will not be playable!\n")
        return false
    end

    if SlashCo.CurRound.OfferingData.CurrentOffering > 0 then 
        SlashCo.CurRound.OfferingData.GasCanMod = SCInfo.Offering[SlashCo.CurRound.OfferingData.CurrentOffering].GasCanMod
    end

    local slashergasmod = 0 --FIX LATER

    --Amount of Spawned Gas Cans: 7 + (4 - Difficulty Value) + Map Modifier + Offering Modifier + Slasher-Specific Modifier + (4 - Player Count)
    local gasCount = json.GasCans.Count + (3-SlashCo.CurRound.Difficulty) + SlashCo.CurRound.OfferingData.GasCanMod + slashergasmod + (4 - SlashCo.CurRound.SurvivorCount) - SlashCo.CurRound.SurvivorData.GasCanMod

    if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then --The Exposure Offering caps gas cans at 8.
        gasCount = 8 + slashergasmod
    end

    SlashCo.CurRound.GasCanCount = gasCount

    --Transfer json to a global
    SlashCo.CurConfig = json

    /* ============================ GENERATORS ============================ */
    local genCount = json.Generators.Count
    --local gasCount = math.max(json.GasCans.Count, #(json.GasCans.Spawnpoints))
    local batCount = math.max(json.Generators.Count, #(json.Batteries.Spawnpoints))
    local itemCount = #(json.Items.Spawnpoints)
    local HeliCount = #(json.Helicopter.Spawnpoints)

    SlashCo.CurRound.HelicopterSpawnPosition = Vector(json.Helicopter.StartLocation.pos[1],json.Helicopter.StartLocation.pos[2],json.Helicopter.StartLocation.pos[3])

    --Add gas can spawns to the number of item spawns if allowed by the config
    local usesGasSpawns = ""
    if json.Items.IncludeGasCanSpawns then
        itemCount = itemCount + gasCount
        usesGasSpawns = "(can use Gas Can spawns)"
    end

    --Check to make sure this config is playable
    if gasCount > #(json.GasCans.Spawnpoints) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] This map has too few gas can spawnpoints for the number of gas cans required! ("..tostring(gasCount).." Gas Cans > "..tostring(#(json.GasCans.Spawnpoints)).." Gas Can Spawnpoints), this map will not be playable!\n")
        valid = false
    end

    if gasCount < genCount*SlashCo.GasCansPerGenerator then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] This map has too few gas cans for the number of given generators ("..tostring(gasCount).." Gas Cans < "..tostring(genCount).." Generators*4), this map will not be playable!\n")
        valid = false
    end

    if batCount < genCount then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] This map has too few battery spawnpoints for the number of given generators ("..tostring(batCount).." Gas Cans < "..tostring(genCount).." Generators), this map will not be playable!\n")
    end

    --Make sure every battery spawnpoint has at least one entry.
    for I=1, #(json.Batteries.Spawnpoints) do
        if #(json.Batteries.Spawnpoints[I]) == 0 then
            MsgC( Color( 255, 50, 50 ), "[SlashCo] There are no battery spawnpoints available for Generator spawnpoint "..tostring(I).."! This could cause issues if a generator spawns here, as it will have no battery, making the map non-completable! Exiting for safety, fix your JSON.\n")
            valid = false
        end
    end
    /* ============================ GENERATORS ============================ */
    
    /* ============================ OFFERINGS ============================ */ 
    if not json.Offerings then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] This configuration has no data for offerings, and several will not work.\n")
    end

    local offeringText = ""
    if json.Offerings.Exposure.Spawnpoints then
        if #(json.Offerings.Exposure.Spawnpoints) == 0 then
            MsgC( Color( 255, 50, 50 ), "[SlashCo] This configuration has no spawnpoints for the Exposure offering. It will not work.\n")
        elseif #(json.Offerings.Exposure.Spawnpoints) < SlashCo.CurRound.GasCanCount then
            MsgC( Color( 255, 50, 50 ), "[SlashCo] This configuration doesn't have enough spawnpoints for the Exposure offering. It will not work.\n")
        end
    else
        MsgC( Color( 255, 50, 50 ), "[SlashCo] This configuration has no data for the Exposure offering. It will not work.\n")
    end
    offeringText = offeringText..tostring(#(json.Offerings.Exposure.Spawnpoints)).." Exposure Offering Spawnpoints"

    /* ============================ OFFERINGS ============================ */

    --Map is valid, print out to console.
    print( "[SlashCo] Map config for '"..map.."' loaded successfully.\n\t"..tostring(#(SlashCo.CurConfig.Generators.Spawnpoints)).." Generator Spawnpoints\n\t"..tostring(#(SlashCo.CurConfig.GasCans.Spawnpoints)).." Gas Can Spawnpoints\n\t"..tostring(itemCount).." Item Spawnpoints "..usesGasSpawns.."\n\t"..tostring(#(json.Spawnpoints.Slasher)).." Slasher Spawnpoints\n\t"..tostring(#(json.Spawnpoints.Survivor)).." Survivor Spawnpoints\n\t"..tostring(#(json.Helicopter.Spawnpoints)).." Helicopter Spawnpoints\n\t"..offeringText )

    return valid
end

--Spawn a generator
SlashCo.CreateGenerator = function(pos, ang)
    local Ent = ents.Create( "sc_generator" )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a generator at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    local id = Ent:EntIndex()

    SlashCo.CurRound.Generators[id] = {
        Running = false,
        Remaining = SlashCo.GasCansPerGenerator,
        Interaction = false,
        Pouring = false,
        Progress = 0.0,
        PouredCanID = 0,
        CorrentPourer = 0,
        HasBattery = false
    }

    return id
end

--Spawn a gas can
SlashCo.CreateGasCan = function(pos, ang)
    local Ent = ents.Create( "prop_physics" )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a gas can at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:SetModel( SlashCo.GasCanModel )
    Ent:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
    Ent:PhysicsInit( SOLID_VPHYSICS )
    Ent:Spawn()

    local id = Ent:EntIndex()
    table.insert(SlashCo.CurRound.GasCans, id)

    return id
end

--Spawn a gas can (testing only for exposure spawnpoints)
SlashCo.CreateGasCanE = function(pos, ang)
    local Ent = ents.Create( "prop_physics" )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a gas can at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:SetModel( SlashCo.GasCanModel )
    Ent:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
    Ent:PhysicsInit( SOLID_VPHYSICS )
    Ent:Spawn()
    Ent:SetColor( Color(255, 0, 0, 255) )

    local id = Ent:EntIndex()
    table.insert(SlashCo.CurRound.ExposureSpawns, id)

    return id
end

--Spawn an Item( or any entity, including slasher entities )
SlashCo.CreateItem = function(class, pos, ang)
    local Ent = ents.Create( class )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a "..class.." at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()
    Ent:Activate()

    local id = Ent:EntIndex()

    if class == "sc_babaclone" then 
        if  SERVER  then
            SlashCo.CurRound.SlasherEntities[id] = {
                activateWalk = false,
                activateSpook = false,
                PostActivation = false
            }
        end
    end

    return id
end

--Spawn a battery
SlashCo.CreateBattery = function(pos, ang)
    local Ent = ents.Create( "prop_physics" )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a battery at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:SetModel(SlashCo.BatteryModel)
    Ent:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
    Ent:PhysicsInit( SOLID_VPHYSICS )
    Ent:Spawn()

    local id = Ent:EntIndex()
    table.insert(SlashCo.CurRound.Batteries, id)

    return id
end

SlashCo.CreateGenerators = function(spawnpoints)
    for I=1, #spawnpoints do
        local pos = SlashCo.CurConfig.Generators.Spawnpoints[spawnpoints[I]].pos
        local ang = SlashCo.CurConfig.Generators.Spawnpoints[spawnpoints[I]].ang

        local entID = SlashCo.CreateGenerator( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

SlashCo.CreateGasCans = function(spawnpoints)
    for I=1, #spawnpoints do
        local pos = SlashCo.CurConfig.GasCans.Spawnpoints[spawnpoints[I]].pos
        local ang = SlashCo.CurConfig.GasCans.Spawnpoints[spawnpoints[I]].ang

        if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then --Exposure Offering Spawnpoints
            pos = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[spawnpoints[I]].pos
            ang = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[spawnpoints[I]].ang
        end

        local entID = SlashCo.CreateGasCan( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

--Testing only function for exposure spawnpoints
SlashCo.CreateGasCansE = function(spawnpoints)
    for I=1, #spawnpoints do
        local pos = SlashCo.CurConfig.GasCans.Spawnpoints[spawnpoints[I]].pos
        local ang = SlashCo.CurConfig.GasCans.Spawnpoints[spawnpoints[I]].ang

        local entID = SlashCo.CreateGasCanE( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

SlashCo.CreateItems = function(spawnpoints, item)
    for I=1, #spawnpoints do
        local pos = SlashCo.CurConfig.Items.Spawnpoints[spawnpoints[I]].pos
        local ang = SlashCo.CurConfig.Items.Spawnpoints[spawnpoints[I]].ang

        local entID = SlashCo.CreateItem(item, Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ))
    end
end

SlashCo.CreateBatteries = function(spawnpoints)
    for I=1, #spawnpoints do
        local rand = math.random(1, #(SlashCo.CurConfig.Batteries.Spawnpoints[spawnpoints[I]]))
        local pos = SlashCo.CurConfig.Batteries.Spawnpoints[spawnpoints[I]][rand].pos
        local ang = SlashCo.CurConfig.Batteries.Spawnpoints[spawnpoints[I]][rand].ang

        local entID = SlashCo.CreateBattery( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

--For testing configs only, spawns batteries in ever possible spot.
SlashCo.CreateBatteriesE = function(spawnpoints)
    for I=1, #spawnpoints do
        for J=1, #(SlashCo.CurConfig.Batteries.Spawnpoints[spawnpoints[I]])do
            local pos = SlashCo.CurConfig.Batteries.Spawnpoints[spawnpoints[I]][J].pos
            local ang = SlashCo.CurConfig.Batteries.Spawnpoints[spawnpoints[I]][J].ang

            local entID = SlashCo.CreateBattery( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
        end
    end
end

--Inserts a given battery into a generator
SlashCo.InsertBattery = function(generator, battery)
    local gid = generator:EntIndex()
    local bid = battery:EntIndex()
    --If either of the two inputs aren't registered to the current round table, exit silently.
    if SlashCo.CurRound.Generators[gid] == nil or not table.HasValue(SlashCo.CurRound.Batteries, bid) then return end

    SlashCo.CurRound.Generators[gid].HasBattery = true
    battery:SetMoveType( MOVETYPE_NONE )
    battery:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
    battery:SetPos( generator:LocalToWorld( Vector(-7,25,50) ) )
    battery:SetAngles( generator:LocalToWorldAngles( Angle(0,90,0) ) )
    battery:SetParent( generator )
    battery:EmitSound("ambient/machines/zap1.wav", 125, 100, 0.5)
    battery:EmitSound("slashco/battery_insert.wav", 125, 100, 1)
end

--Inserts a given gas can into a generator
SlashCo.AddGas = function(generator)

    local gid = generator:EntIndex()

    SlashCo.CurRound.Generators[gid].Remaining = SlashCo.CurRound.Generators[gid].Remaining - 1

end

--Remove a gas can from the table as it is now being poured in the generator.
SlashCo.RemoveGas = function(generator, gas)
    local gid = generator:EntIndex()
    local gasid = gas:EntIndex()
    --If either of the two inputs aren't registered to the current round table, exit silently.
    if SlashCo.CurRound.Generators[gid] == nil or not table.HasValue(SlashCo.CurRound.GasCans, gasid) then return end
  
    gas:Remove()
    table.RemoveByValue( SlashCo.CurRound.GasCans, gasid )
end

--Spawn the helicopter 
SlashCo.CreateHelicopter = function(pos, ang)
    local Ent = ents.Create( "sc_helicopter" )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create the helicopter at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    local id = Ent:EntIndex()

    SlashCo.CurRound.Helicopter = id

    return id
end

--Spawn the item stash 
SlashCo.CreateItemStash = function(pos, ang)
    local Ent = ents.Create( "sc_itemstash" )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create the itemstash at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    local id = Ent:EntIndex()

    return id
end

--Spawn the offering table
SlashCo.CreateOfferTable = function(pos, ang)
    local Ent = ents.Create( "sc_offertable" )

    if !IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create the offertable at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    local id = Ent:EntIndex()

    return id
end

SlashCo.RemoveAllCurRoundEnts = function()
    local ents = table.GetKeys(SlashCo.CurRound.Generators)
    for I=1, #ents do
        if IsValid(Entity(ents[I])) then
            Entity(ents[I]):Remove()
        end
    end

    for I=1, #(SlashCo.CurRound.GasCans) do
        if IsValid(Entity(SlashCo.CurRound.GasCans[I])) then
            Entity(SlashCo.CurRound.GasCans[I]):Remove()
        end
    end

    for I=1, #(SlashCo.CurRound.Items) do
        if IsValid(Entity(SlashCo.CurRound.Items[I])) then
            Entity(SlashCo.CurRound.Items[I]):Remove()
        end
    end

    for I=1, #(SlashCo.CurRound.Batteries) do
        if IsValid(Entity(SlashCo.CurRound.Batteries[I])) then
            Entity(SlashCo.CurRound.Batteries[I]):Remove()
        end
    end

    for I=1, #(SlashCo.CurRound.ExposureSpawns) do
        if IsValid(Entity(SlashCo.CurRound.ExposureSpawns[I])) then
            Entity(SlashCo.CurRound.ExposureSpawns[I]):Remove()
        end
    end
end

SlashCo.EndRound = function()
    local delay = 15

    local survivorsWon = true
    if SlashCo.CurRound.SurvivorCount == 0 then
        print("[SlashCo] The slasher won the round.")
        survivorsWon = false
        if SlashCo.CurRound.SlasherData.GameProgress < 10 then 
            SlashCo.RoundOverScreen(3)
        else
            SlashCo.RoundOverScreen(2)
        end
    else
        print("[SlashCo] The survivors won the round. "..tostring(SlashCo.CurRound.SurvivorCount).." survivors made it out.")

        if #SlashCo.CurRound.SlasherData.AllSurvivors == #team.GetPlayers(TEAM_SURVIVOR) then 
            SlashCo.RoundOverScreen(0) 
        else
            SlashCo.RoundOverScreen(1) 
        end

    end
    print("[SlashCo] Round over, returning to lobby in "..tostring(delay).." seconds.")

    timer.Simple(1, function()

        SlashCo.RemoveHelicopter()

        local survivors = team.GetPlayers(TEAM_SURVIVOR)
        for i=1, #survivors do
            survivors[i]:SetTeam(TEAM_SPECTATOR)
            survivors[i]:Spawn()
        end

        local slashers = team.GetPlayers(TEAM_SLASHER)
        for i=1, #slashers do
            slashers[i]:SetTeam(TEAM_SPECTATOR)
            slashers[i]:Spawn()
        end

        if #survivors > 0 then
            --TODO: Add to stats of the remaining survivors' wins.
        else
            --TODO: Add to stats of the slasher's wins
        end

        SlashCo.RemoveAllCurRoundEnts()
        SlashCo.ResetCurRoundData()
        SlashCo.GoToLobby()
    end)
end

SlashCo.SurvivorWinFinish = function()
    local delay = 6

    for i, play in ipairs( player.GetAll() ) do
        play:ChatPrint("[SlashCo] All Living survivors are in the Helicopter.") 
    end

    timer.Simple(delay, function()

        SlashCo.EndRound()

    end)
end

SlashCo.SpawnCurConfig = function()
    SlashCo.RemoveAllCurRoundEnts()
    --SlashCo.ResetCurRoundData()

    local curmap = game.GetMap()
    if curmap != "sc_lobby" then --Replace with actual map name for the lobby map
        if not SlashCo.ValidateMap(curmap) then
            ErrorNoHalt("[SlashCo] '"..curmap.."' is not a playable map, aborting.\n")
            return
        end

        --Spawn all generators
        local genSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GeneratorCount, #(SlashCo.CurConfig.Generators.Spawnpoints))
        --local gasSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GasCanCount, #(SlashCo.CurConfig.GasCans.Spawnpoints))
        local gasSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GasCanCount, #(SlashCo.CurConfig.GasCans.Spawnpoints))

        if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then
            gasSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GasCanCount, #(SlashCo.CurConfig.Offerings.Exposure.Spawnpoints))
        end

        if SlashCo.CurRound.OfferingData.CurrentOffering == 2 then
            SlashCo.CurRound.OfferingData.ItemMod = -2
        end

        if SlashCo.CurRound.OfferingData.CurrentOffering == 2 then SlashCo.CurRound.OfferingData.SatO = 1 end

        if SlashCo.CurRound.OfferingData.CurrentOffering == 4 then SlashCo.CurRound.OfferingData.DO = true end 

        if SlashCo.CurRound.OfferingData.CurrentOffering == 5 then SlashCo.CurRound.OfferingData.SO = 1 end

        SlashCo.CurRound.ItemCount = SlashCo.CurRound.ItemCount + SlashCo.CurRound.OfferingData.ItemMod

        local possibleItemSpawnpoints = SlashCo.CurConfig.Items.Spawnpoints
        if SlashCo.CurConfig.Items.IncludeGasCanSpawns then
            for i=1, #(SlashCo.CurConfig.GasCans.Spawnpoints) do
                local isValid = true
                for j=1, #gasSpawns do
                    if i == gasSpawns[j] then
                        isValid = false
                    end
                end

                if isValid then
                    possibleItemSpawnpoints[#possibleItemSpawnpoints+1] = SlashCo.CurConfig.GasCans.Spawnpoints[i]
                end
            end
        end
        local itemSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.ItemCount, #possibleItemSpawnpoints)

        local item_class = ""

        SlashCo.CreateGenerators(genSpawns)
        SlashCo.CreateBatteries(genSpawns)
        SlashCo.CreateGasCans(gasSpawns)

        --Decide if what and if items should be spawned according to the selected slasher
        for s = 1, #SlashCo.CurRound.SlashersToBeSpawned do

            local plyid = SlashCo.CurRound.SlashersToBeSpawned[s].ID

            local slashid = SlashCo.CurRound.SlasherData[plyid].SlasherID

            if slashid == 2 then item_class = "sc_cookie" end

            if item_class != "" then SlashCo.CreateItems(itemSpawns, item_class) print("[SlashCo] Spawning Items.") end

        end

        SlashCo.CurRound.roundOverToggle = true

        SlashCo.BroadcastItemData()
        
		timer.Simple(0.5, function()

			SlashCo.BroadcastItemData() --Fallback

        end)

        GAMEMODE.State = GAMEMODE.States.IN_GAME
        SlashCo.CurRound.SlasherData.GameProgress = 0

    else

    end
end

--Used to test configs for conflicts.
--Run lua_run SlashCo.TestConfig

concommand.Add( "debug_config", function( ply, cmd, args )
	SlashCo.TestConfig()
end )

SlashCo.TestConfig = function()
    SlashCo.RemoveAllCurRoundEnts()
    --SlashCo.ResetCurRoundData()

    local curmap = game.GetMap()
    if not SlashCo.ValidateMap(curmap) then
        ErrorNoHalt("[SlashCo] '"..curmap.."' is not a playable map, aborting.\n")
        return
    end

    --Spawn all generators
    local genSpawns = SlashCo.GetSpawnpoints(#(SlashCo.CurConfig.Generators.Spawnpoints), #(SlashCo.CurConfig.Generators.Spawnpoints))
    local gasSpawns = SlashCo.GetSpawnpoints(#(SlashCo.CurConfig.GasCans.Spawnpoints), #(SlashCo.CurConfig.GasCans.Spawnpoints))

    local possibleItemSpawnpoints = SlashCo.CurConfig.Items.Spawnpoints
    if SlashCo.CurConfig.Items.IncludeGasCanSpawns then
        for i=1, #(SlashCo.CurConfig.GasCans.Spawnpoints) do
            possibleItemSpawnpoints[#possibleItemSpawnpoints+1] = SlashCo.CurConfig.GasCans.Spawnpoints[i]
        end
    end

    --Check Exposure offering spawnpoints too.
    if SlashCo.CurConfig.Offerings.Exposure.Spawnpoints then
        local exposureSpawns = SlashCo.GetSpawnpoints(#(SlashCo.CurConfig.Offerings.Exposure.Spawnpoints), #(SlashCo.CurConfig.Offerings.Exposure.Spawnpoints))
        SlashCo.CreateGasCansE(exposureSpawns)
    end

    SlashCo.CreateGenerators(genSpawns)
    SlashCo.CreateBatteriesE(genSpawns)
    SlashCo.CreateGasCans(gasSpawns)
    --SlashCo.CreateItems(SlashCo.GetSpawnpoints(#possibleItemSpawnpoints, #possibleItemSpawnpoints), SlashCo.Items.MILK) --TODO!

    net.Start("octoSlashCoTestConfigHalos")
    --net.WriteTable(send) --I'm so sorry for using this, I'm just too lazy.
    net.Broadcast()
end

SlashCo.ChangeMap = function(mapname)
    if SERVER then
        RunConsoleCommand("changelevel", mapname)
    end
end

SlashCo.GoToLobby = function()
    SlashCo.ChangeMap("sc_lobby")
end

SlashCo.SummonEscapeHelicopter = function()

    SlashCo.CurRound.EscapeHelicopterSummoned = true

	--[[

			Once both Generators have been activated, a timer will start which will determine when the rescue helicopter will arrive.
			Difficulty 0 - 30-60 seconds
			Difficulty 1,2 - 30-100 seconds
			Difficulty 3 - 30-140 seconds


	]]

    local delay = 30 + math.random( 0, 30 + ( SlashCo.CurRound.Difficulty * 15 ) )

	print("[SlashCo] Generators On. The Helicopter will arrive in "..delay.." seconds.")

    timer.Simple(delay, function()

		SlashCo.CreateEscapeHelicopter()

    end)

end

SlashCo.CreateEscapeHelicopter = function()

    if SlashCo.CurRound.EscapeHelicopterSpawned == true then return end

    local entID = SlashCo.CreateHelicopter( SlashCo.CurRound.HelicopterSpawnPosition, Angle( 0,0,0 ) ) --TODO: set up a unique spawn position for each map.

    SlashCo.CurRound.EscapeHelicopterSpawned = true

    SlashCo.CurRound.Helicopter = entID

    timer.Simple(0.1, function()

        SlashCo.HelicopterGoAboveLand(entID)

    end)

end

SlashCo.HelicopterGoAboveLand = function(id)

    local rand = math.random( 1, #SlashCo.CurConfig.Helicopter.Spawnpoints) --The Landing position is randomized

    local pos = SlashCo.CurConfig.Helicopter.Spawnpoints[rand].pos
    local ang = SlashCo.CurConfig.Helicopter.Spawnpoints[rand].ang 

	SlashCo.CurRound.HelicopterTargetPosition = Vector(pos[1],pos[2],pos[3]+1500)

    local delay = math.sqrt( ents.GetByIndex(id):GetPos():Distance(Vector(pos[1],pos[2],pos[3]+1500)) ) / 5

    print(delay)

    timer.Simple(delay, function()

        SlashCo.HelicopterLand(pos)

    end)

end

SlashCo.HelicopterLand = function(pos)

	SlashCo.CurRound.HelicopterTargetPosition = Vector(pos[1],pos[2],pos[3])

end

SlashCo.HelicopterTakeOff = function()

	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1],SlashCo.CurRound.HelicopterTargetPosition[2],SlashCo.CurRound.HelicopterTargetPosition[3]+1500)

    timer.Simple(5, function()

        SlashCo.HelicopterFinalLeave()

    end)

end

SlashCo.HelicopterFinalLeave = function()

	SlashCo.CurRound.HelicopterTargetPosition = Vector(7675, -3046, 1700)

end

SlashCo.UpdateHelicopterSeek = function(pos)

	SlashCo.CurRound.HelicopterTargetPosition = pos

end

SlashCo.RemoveHelicopter = function()

local ent = ents.GetByIndex(SlashCo.CurRound.Helicopter)

ent:Remove()

end

SlashCo.OfferingVoteFail = function()

    SlashCo.LobbyData.Offering = 0
    SlashCo.LobbyData.VotedOffering = 0
    table.Empty(SlashCo.LobbyData.Offerors)

    for i, play in ipairs( player.GetAll() ) do
        play:ChatPrint("Offering vote was unsuccessful.") 
        SlashCo.EndOfferingVote(play)
    end

end

SlashCo.OfferingVoteSuccess = function(id)

    local fail = false

    if id == 4 then --Duality

        if #team.GetPlayers(TEAM_SPECTATOR) < 1 then

            for i, play in ipairs( player.GetAll() ) do
                play:ChatPrint("Offering vote successful, however a Spectator could not be found to assign as the second Slasher. Duality was not offered.") 
                SlashCo.EndOfferingVote(play)
                fail = true
            end

        end

    end

    if id == 2 then --Satiation

        --SlashCo.LobbyData.SelectedSlasherInfo.CLS = 2

    end

    SlashCo.LobbyData.VotedOffering = 0

    if fail == true then return end

    SlashCo.LobbyData.Offering = id

    timer.Destroy( "OfferingVoteTimer")

    for i, play in ipairs( player.GetAll() ) do
        play:ChatPrint("Offering vote successful. "..SCInfo.Offering[id].Name.." has been offered.") 
        SlashCo.EndOfferingVote(play)
    end

    SlashCo.OfferingVoteFinished(SCInfo.Offering[id].Rarity)

end

SlashCo.ClearDatabase = function()

    if SERVER then

        print("[SlashCo] Clearing Database. . .")

        sql.Query("DROP TABLE slashco_table_basedata;" )
        sql.Query("DROP TABLE slashco_table_survivordata;" )
        sql.Query("DROP TABLE slashco_table_slasherdata;" )
    
    end

end

function BoolToNumber(bool) return bool and 1 or 0 end
