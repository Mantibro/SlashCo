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
        NAME = "Summer Camp",
        AUTHOR = "Steinman",
        DEFAULT = true,
        SIZE = 2,
        MIN_PLAYERS = 1,
        LEVELS = {
            500
        }
    },

    {
        ID = "sc_highschool",
        NAME = "High School",
        AUTHOR = "Steinman",
        DEFAULT = true,
        SIZE = 2,
        MIN_PLAYERS = 2,
        LEVELS = {
            -160,
            100,
            600
        }
    },

    {
        ID = "sc_hospital",
        NAME = "Hospital",
        AUTHOR = "sparkz",
        DEFAULT = true,
        SIZE = 2,
        MIN_PLAYERS = 2,
        LEVELS = {
            -1750,
            -2100,
            50
        }
    },

    {
        ID = "rp_deadcity",
        NAME = "Dead City",
        AUTHOR = "NuclearGhost",
        DEFAULT = false,
        SIZE = 3,
        MIN_PLAYERS = 2,
        LEVELS = {
            150,
            350
        }
    },

    {
        ID = "rp_redforest",
        NAME = "Red Forest",
        AUTHOR = "NuclearGhost",
        DEFAULT = false,
        SIZE = 4,
        MIN_PLAYERS = 3,
        LEVELS = {
            250,
            350,
            -630,
            -650
        }
    }

}

SlashCo.ReturnMapIndex = function()

    local cur_map = game.GetMap()

    for i = 1, #SlashCo.Maps do

        if SlashCo.Maps[i].ID == cur_map then
            return i
        end

    end

end

SlashCo.MAXPLAYERS = 7

--[[SlashCo.SlasherData = {     --Information about Slashers

    {
        NAME = "Leuonard",
        ID = 14,
        CLS = 2,
        DNG = 3,
        Model = "models/slashco/slashers/leuonard/leuonard.mdl",
        KillDelay = 2,
        GasCanMod = 0,
        ProwlSpeed = 150,
        ChaseSpeed = 290,
        Perception = 1,
        Eyesight = 5,
        KillDistance = 150,
        ChaseRange = 900,
        ChaseRadius = 0.86,
        ChaseDuration = 5.0,
        ChaseCooldown = 4,
        JumpscareDuration = 2,
        ChaseMusic = "slashco/slasher/leuonard_chase.mp3",
        KillSound = "slashco/slasher/freesmiley_kill.mp3"
    }

}]]

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
        NAME = 0,
        TIP = "--//--"

    },
    SelectedMapNum = 0,
    PickedSlasher = "None",
    --DeathwardsLeft = 0 --not used

}

--Holds all the information about the ongoing round
SlashCo.ResetCurRoundData = function()
    SlashCo.CurRound = {
        Difficulty = SlashCo.Difficulty.EASY,
        ExpectedPlayers = {},
        --ExpectedPlayersLoaded = false, --not used
        --ConnectedPlayers = {}, --not used
        AntiLoopSpawn = false,
        OfferingData = {
            CurrentOffering = 0,
            OfferingName = "",
            GasCanMod = 0,
            SO = 0,
            DO = false,
            SatO = 0,
            --DrainageTick = 0, --not used
            ItemMod = 0
        },
        SlasherData = {
            AllSurvivors = {}, --This table holds all survivors loaded for this round, dead or alive, as well as their contribution value to the round. (TODO: game contribution)
            AllSlashers = {},
            GameReadyToBegin = false
        },
        GameProgress = -1,
        SurvivorData = {
            GasCanMod = 0 --This will decrement if someone chooses a gas can to take in as an item.
            --Items = {} --not used
        },
        SlasherEntities = { --Slasher's unique entities, such as bababooey's clones.

        },
        ExposureSpawns = {}, --This is only used in TestConfig()
        Items = {},
        Helicopter = 0,
        SlashersToBeSpawned = {},
        Slashers = {},
        GeneratorCount = 2, --may not need to be here (Def 2)
        GasCanCount = 8,
        ItemCount = 6,
        roundOverToggle = false, --weird
        HelicopterSpawnPosition = Vector(0,0,0),
        HelicopterInitialSpawnPosition = Vector(0,0,0),
        HelicopterTargetPosition = Vector(0,0,0),
        HelicopterRescuedPlayers = {}, --need opt
        EscapeHelicopterSummoned = false,
        DistressBeaconUsed = false,
    }
end
SlashCo.ResetCurRoundData()

--SlashCo.GasCanModel = "models/props_junk/metalgascan.mdl" --Model path for the gas cans
SlashCo.GeneratorModel = "models/props_vehicles/generatortrailer01.mdl" --Model path for the generators
--SlashCo.BatteryModel = "models/items/car_battery01.mdl" --Model path for the batteries
SlashCo.HelicopterModel = "models/slashco/other/helicopter/helicopter.mdl" --Model path for the helicopter
SlashCo.GasCansPerGenerator = 4 --Number of gas cans required to fill up a generator
SlashCo.PlayerData = {} --Holds all loaded playerdata

SlashCo.LoadCurRoundData = function()

    if SERVER then

        table.Empty(SlashCo.CurRound.ExpectedPlayers)

        if sql.TableExists("slashco_table_basedata") and sql.TableExists("slashco_table_survivordata") and sql.TableExists("slashco_table_slasherdata") then

            --Load relevant data from the database
            local diff = sql.Query("SELECT Difficulty FROM slashco_table_basedata; ")[1].Difficulty
            local offering = sql.Query("SELECT Offering FROM slashco_table_basedata; ")[1].Offering
            local slasher1id = sql.Query("SELECT SlasherIDPrimary FROM slashco_table_basedata; ")[1].SlasherIDPrimary
            local slasher2id = sql.Query("SELECT SlasherIDSecondary FROM slashco_table_basedata; ")[1].SlasherIDSecondary
            local survivorgasmod = sql.Query("SELECT SurviorGasMod FROM slashco_table_basedata; ")[1].SurviorGasMod

            print("[SlashCo] RoundData Loaded with Difficulty of: " .. diff .. ", Offering of: " .. offering .. " and GasMod of: " .. survivorgasmod)

            --Transfer loaded data into the main table
            SlashCo.CurRound.Difficulty = tonumber(diff)
            SlashCo.CurRound.SurvivorData.GasCanMod = survivorgasmod
            SlashCo.CurRound.OfferingData.CurrentOffering = tonumber(offering)
            if SlashCo.CurRound.OfferingData.CurrentOffering > 0 then
                SlashCo.CurRound.OfferingData.OfferingName = SCInfo.Offering[SlashCo.CurRound.OfferingData.CurrentOffering].Name
            end

            --First we insert the Slasher. If the Slasher does not join in time the game cannot begin.

            --Insert the First and second Slasher into the table
            for e = 1, #sql.Query("SELECT * FROM slashco_table_slasherdata; ") do
                table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = sql.Query("SELECT * FROM slashco_table_slasherdata; ")[e].Slashers })
            end

            --Survivors don't necessarily have to join in time, as the game can continue with at least 1. (TODO)
            --TODO: timer which starts the game premature if some survivors don't join in time.

            local query = sql.Query("SELECT * FROM slashco_table_survivordata; ")
            for i = 1, #query do

                if query[i].Survivors ~= nil then
                    --Survivors due to connect

                    local steamid = query[i].Survivors
                    table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = steamid })
                    --For the slasher's clientside view also
                    table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = steamid, GameContribution = 0 })
                end

            end

            print("[SlashCo] First 2 Expected Players assigned: " .. SlashCo.CurRound.ExpectedPlayers[1].steamid .. SlashCo.CurRound.ExpectedPlayers[2].steamid)
            print("[SlashCo] Expected Player table size: " .. #SlashCo.CurRound.ExpectedPlayers)

            for s = 1, #sql.Query("SELECT * FROM slashco_table_slasherdata; ") do

                local id = sql.Query("SELECT * FROM slashco_table_slasherdata; ")[s].Slashers
                if id == "90071996842377216" then
                    break
                end

                timer.Simple(1, function()

                    print("[SlashCo] Selecting Slasher for player with id: " .. id)
                    if s == 1 then
                        SlashCo.SelectSlasher(slasher1id, id)
                        table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { s_id = id, slasherkey = slasher1id })
                    end
                    if s == 2 then
                        SlashCo.SelectSlasher(slasher2id, id)
                        table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { s_id = id, slasherkey = slasher2id })
                    end

                end)

            end


        else
            print("[SlashCo] Something went wrong while trying to load the round data from the Database! Restart imminent. (init)")
            local baseTable = sql.TableExists("slashco_table_basedata") and "present" or "nil"
            local survivorTable = sql.TableExists("slashco_table_survivordata") and "present" or "nil"
            local slasherTable = sql.TableExists("slashco_table_slasherdata") and "present" or "nil"
            print("base table: " .. baseTable)
            print("survivor table: " .. survivorTable)
            print("slasher table: " .. slasherTable)

            SlashCo.EndRound()

        end

    end

end

SlashCo.AwaitExpectedPlayers =  function()

if SERVER then

if game.GetMap() ~= "sc_lobby" then

    if #SlashCo.CurRound.ExpectedPlayers < 2 then return end --don't start with no data

    print("[SlashCo] Now running player expectation...")

    local ExpectTrue = false
    local expected_count = 0

    for i = 1, #SlashCo.CurRound.ExpectedPlayers do
        local ex_p = player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[i].steamid)

        for p = 1, #player.GetAll() do
            local s_p = player.GetAll()[p]

            if ex_p == s_p then
                expected_count = expected_count + 1
                print("[SlashCo] Expected player "..expected_count.." in!".."("..ex_p:Name()..")")
                break
            end

        end

    end

    if expected_count == #SlashCo.CurRound.ExpectedPlayers then ExpectTrue = true end

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
	timer.Create( "GameStart", 15, 1, function() if SERVER then RunConsoleCommand("slashco_run_curconfig") end end)
end

SlashCo.LoadCurRoundTeams = function()

    if SERVER then

        if sql.TableExists("slashco_table_basedata") and sql.TableExists("slashco_table_survivordata") and sql.TableExists("slashco_table_slasherdata") then

            print("[SlashCo] Teams database loaded...")

            local survivors = sql.Query("SELECT * FROM slashco_table_survivordata; ")
            local slashers = sql.Query("SELECT * FROM slashco_table_slasherdata; ")

            for play = 1, #player.GetAll() do
                --Assign the teams for the current round

                local playercur = player.GetAll()[play]
                local id = playercur:SteamID64()

                print("name: " .. playercur:Name())

                local query = sql.Query("SELECT * FROM slashco_table_survivordata; ") --This table shouldn't be organized like this.
                for i = 1, #survivors do
                    if id == survivors[i].Survivors then

                        playercur:SetTeam(TEAM_SURVIVOR)
                        playercur:Spawn()
                        for _, v in ipairs(query) do
                            if (v.Survivors == playercur:SteamID64()) then
                                SlashCo.ChangeSurvivorItem(playercur, v.Item)
                                break
                            end
                        end
                        print(playercur:Name() .. " now Survivor")

                        break

                    else

                        if slashers[1] ~= nil and id == slashers[1].Slashers then
                            goto CONTINUE
                        end
                        if slashers[2] ~= nil and id == slashers[2].Slashers then
                            goto CONTINUE
                        end

                        for k = 1, #survivors do
                            if id == survivors[k].Survivors then
                                goto CONTINUE
                            end
                        end

                        playercur:SetTeam(TEAM_SPECTATOR)
                        playercur:Spawn()
                        print(playercur:Name() .. " now Spectator")
                    end
                    :: CONTINUE ::
                end

                for i = 1, #slashers do
                    if id == slashers[i].Slashers then
                        print(playercur:Name() .. " now Slasher (Memorized)")
                        playercur:SetTeam(TEAM_SPECTATOR)
                        playercur:Spawn()

                        table.insert(SlashCo.CurRound.SlashersToBeSpawned, playercur)

                        --table.insert(SlashCo.CurRound.SlasherData.AllSlashers, {s_id = playercur:SteamID64()})

                    end
                end

            end

            --local id1 = slashers[1].Slashers
            local id2 = 0
            if slashers[2] ~= nil then
                id2 = slashers[2].Slashers
            end

            timer.Simple(0.05, function()

                print("[SlashCo] Now proceeding with Spawns...")

                SlashCo.PrepareSlasherForSpawning()

                SlashCo.SpawnPlayers()

            end)


        else

            print("[SlashCo] Something went wrong while trying to load the round data from the Teams Database! Restart imminent. (loadrounds)")

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

    --Amount of Spawned Gas Cans: 7 + (4 - Difficulty Value) + Map Modifier + Offering Modifier + Slasher-Specific Modifier + (4 - Player Count)
    local gasCount = 9

    --Transfer json to a global
    SlashCo.CurConfig = json

    -- ============================ GENERATORS ============================
    local genCount = json.Generators.Count
    --local gasCount = math.max(json.GasCans.Count, #(json.GasCans.Spawnpoints))
    local batCount = math.max(json.Generators.Count, #(json.Batteries.Spawnpoints))
    local itemCount = #(json.Items.Spawnpoints)
    --local HeliCount = #(json.Helicopter.Spawnpoints)

    SlashCo.CurRound.HelicopterSpawnPosition = Vector(json.Helicopter.StartLocation.pos[1],json.Helicopter.StartLocation.pos[2],json.Helicopter.StartLocation.pos[3])

    SlashCo.CurRound.HelicopterIntroPosition = Vector(json.Helicopter.IntroLocation.pos[1],json.Helicopter.IntroLocation.pos[2],json.Helicopter.IntroLocation.pos[3])

    SlashCo.CurRound.HelicopterIntroAngle = Angle(json.Helicopter.IntroLocation.ang[1],json.Helicopter.IntroLocation.ang[2],json.Helicopter.IntroLocation.ang[3])

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

    gasCount = SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE + json.GasCans.Count + (3-SlashCo.CurRound.Difficulty) + SlashCo.CurRound.OfferingData.GasCanMod + (4 - #SlashCo.CurRound.SlasherData.AllSurvivors) - SlashCo.CurRound.SurvivorData.GasCanMod

    if gasCount < 8 then gasCount = 8 end

    if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then --The Exposure Offering caps gas cans at 8.
        SlashCo.CurRound.GasCanCount = 8 - SlashCo.CurRound.SurvivorData.GasCanMod
    else
        SlashCo.CurRound.GasCanCount = gasCount
    end

    -- ============================ GENERATORS ============================

    -- ============================ OFFERINGS ============================
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

    -- ============================ OFFERINGS ============================

    --Map is valid, print out to console.
    print( "[SlashCo] Map config for '"..map.."' loaded successfully.\n\t"..tostring(#(SlashCo.CurConfig.Generators.Spawnpoints)).." Generator Spawnpoints\n\t"..tostring(#(SlashCo.CurConfig.GasCans.Spawnpoints)).." Gas Can Spawnpoints\n\t"..tostring(itemCount).." Item Spawnpoints "..usesGasSpawns.."\n\t"..tostring(#(json.Spawnpoints.Slasher)).." Slasher Spawnpoints\n\t"..tostring(#(json.Spawnpoints.Survivor)).." Survivor Spawnpoints\n\t"..tostring(#(json.Helicopter.Spawnpoints)).." Helicopter Spawnpoints\n\t"..offeringText )

    return valid
end

--Spawn a generator
SlashCo.CreateGenerator = function(pos, ang)
    local Ent = ents.Create( "sc_generator" )

    if not IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a generator at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    return Ent:EntIndex()
end

--Spawn a gas can
SlashCo.CreateGasCan = function(pos, ang)
    local Ent = ents.Create( "sc_gascan" )

    if not IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create an exposure gas can at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    return Ent
end

--Spawn a gas can (testing only for exposure spawnpoints)
SlashCo.CreateGasCanE = function(pos, ang)
    local Ent = ents.Create( "sc_gascan" )

    if not IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a gas can at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()
    Ent:SetColor( Color(255, 0, 0, 255) )

    local id = Ent:EntIndex()
    table.insert(SlashCo.CurRound.ExposureSpawns, id)

    return id
end

--Spawn an Item( or any entity, including slasher entities )
SlashCo.CreateItem = function(class, pos, ang)
    local Ent = ents.Create( class )

    if not IsValid(Ent) then
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
    local Ent = ents.Create( "sc_battery" )

    if not IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create a battery at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    return Ent
end

SlashCo.CreateGenerators = function(spawnpoints)
    for _, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.Generators.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.Generators.Spawnpoints[v].ang

        SlashCo.CreateGenerator( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) ) --local entID =
    end
end

SlashCo.CreateGasCans = function(spawnpoints)
    for _, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.GasCans.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.GasCans.Spawnpoints[v].ang

        if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then --Exposure Offering Spawnpoints
            pos = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[v].pos
            ang = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[v].ang
        end

        SlashCo.CreateGasCan( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

--Testing only function for exposure spawnpoints
SlashCo.CreateGasCansE = function(spawnpoints)
    for _, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.GasCans.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.GasCans.Spawnpoints[v].ang

        SlashCo.CreateGasCanE( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

SlashCo.CreateItems = function(spawnpoints, item)
    for _, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.Items.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.Items.Spawnpoints[v].ang

        local id = SlashCo.CreateItem(item, Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ))
        SlashCo.CurRound.Items[id] = true
    end
end

SlashCo.CreateBatteries = function(spawnpoints)
    for _, v in ipairs(spawnpoints) do
        local rand = math.random(1, #(SlashCo.CurConfig.Batteries.Spawnpoints[v]))
        local pos = SlashCo.CurConfig.Batteries.Spawnpoints[v][rand].pos
        local ang = SlashCo.CurConfig.Batteries.Spawnpoints[v][rand].ang

        SlashCo.CreateBattery( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

--For testing configs only, spawns batteries in ever possible spot.
SlashCo.CreateBatteriesE = function(spawnpoints)
    for _, v in ipairs(spawnpoints) do
        for J=1, #(SlashCo.CurConfig.Batteries.Spawnpoints[v])do
            local pos = SlashCo.CurConfig.Batteries.Spawnpoints[v][J].pos
            local ang = SlashCo.CurConfig.Batteries.Spawnpoints[v][J].ang

            SlashCo.CreateBattery( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
        end
    end
end

--Spawn the helicopter 
SlashCo.CreateHelicopter = function(pos, ang)
    local Ent = ents.Create( "sc_helicopter" )

    if not IsValid(Ent) then
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

    if not IsValid(Ent) then
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

    if not IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create the offertable at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    local id = Ent:EntIndex()

    return id
end

--Spawn the radio
SlashCo.CreateRadio = function(pos, ang)
    local Ent = ents.Create( "radio" )

    if not IsValid(Ent) then
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

    local gens = ents.FindByClass( "sc_generator")
    for _, v in ipairs(gens) do
        local can = v.FuelingCan --make sure any attached cans and bats go too
        local bat = v.HasBattery
        if IsValid(can) then can:Remove() end
        if IsValid(bat) then bat:Remove() end
        v:Remove()
    end

    local cans = ents.FindByClass( "sc_gascan")
    for _, v in ipairs(cans) do
        v:Remove()
    end

    for k, _ in pairs(SlashCo.CurRound.Items) do
        local ent = Entity(k)
        if IsValid(ent) then ent:Remove() end
    end

    local bats = ents.FindByClass( "sc_battery")
    for _, v in ipairs(bats) do
        v:Remove()
    end

    for I=1, #(SlashCo.CurRound.ExposureSpawns) do
        if IsValid(Entity(SlashCo.CurRound.ExposureSpawns[I])) then
            Entity(SlashCo.CurRound.ExposureSpawns[I]):Remove()
        end
    end
end

SlashCo.EndRound = function()
    local delay = 20

    local survivorsWon = true
    local SurvivorCount = #team.GetPlayers(TEAM_SURVIVOR)
    if SurvivorCount == 0 then --All Survivors are Dead

        survivorsWon = false

        if not SlashCo.CurRound.EscapeHelicopterSummoned or SlashCo.CurRound.DistressBeaconUsed then --Assignment Failed

            SlashCo.RoundOverScreen(3)

        else --Assignment Success

            SlashCo.RoundOverScreen(2)

        end

    else --There are living Survivors

        if SlashCo.CurRound.DistressBeaconUsed then --Premature Win Distress Beacon

            if #SlashCo.CurRound.HelicopterRescuedPlayers > 0 then --The Last survivor got to the helicopter

                SlashCo.RoundOverScreen(4)

            else --Emergency rescue came and went, normal loss

                SlashCo.RoundOverScreen(3)

            end


        else --Normal Win

            if #SlashCo.CurRound.SlasherData.AllSurvivors >= SurvivorCount and SurvivorCount == #SlashCo.CurRound.HelicopterRescuedPlayers then --Everyone lived

                SlashCo.RoundOverScreen(0)

            else --Not Everyone lived

                SlashCo.RoundOverScreen(1)

            end

        end

    end
    print("[SlashCo] Round over, returning to lobby in "..tostring(delay).." seconds.")

    timer.Simple(delay, function()

        SlashCo.RemoveHelicopter()

        if #SlashCo.CurRound.HelicopterRescuedPlayers > 0 then
            --Add to stats of the remaining survivors' wins.
            for i = 1, #SlashCo.CurRound.HelicopterRescuedPlayers do

                SlashCoDatabase.UpdateStats(SlashCo.CurRound.HelicopterRescuedPlayers[i].steamid, "SurvivorRoundsWon", 1)

                SlashCo.PlayerData[SlashCo.CurRound.HelicopterRescuedPlayers[i].steamid].PointsTotal = SlashCo.PlayerData[SlashCo.CurRound.HelicopterRescuedPlayers[i].steamid].PointsTotal + 25

            end
        end

        local survivors = team.GetPlayers(TEAM_SURVIVOR)
        for i=1, #survivors do

            survivors[i]:SetTeam(TEAM_SPECTATOR)
            survivors[i]:Spawn()

        end

        for i = 1, #SlashCo.CurRound.SlasherData.AllSurvivors do
            local man = SlashCo.CurRound.SlasherData.AllSurvivors[i].id

            if IsValid(player.GetBySteamID64( man )) then
                SlashCoDatabase.UpdateStats(man, "Points", SlashCo.PlayerData[man].PointsTotal)
            end

        end

        local slashers = team.GetPlayers(TEAM_SLASHER)
        for i=1, #slashers do
            slashers[i]:SetTeam(TEAM_SPECTATOR)
            slashers[i]:Spawn()
        end

        if #survivors < 1 then

            --Add to stats of the slasher's wins
            for i = 1, #slashers do
                SlashCoDatabase.UpdateStats(slashers[i]:SteamID64(), "SlasherRoundsWon", 1)
            end

        end

        SlashCo.RemoveAllCurRoundEnts()
        SlashCo.ResetCurRoundData()
        SlashCo.GoToLobby()
        --print("tried to go to lobby (round end)")
    end)
end

SlashCo.RoundHeadstart = function()

    if #SlashCo.CurRound.SlasherData.AllSurvivors > (SlashCo.MAXPLAYERS - 2) then return end

    for _ = 1, (6 - #SlashCo.CurRound.SlasherData.AllSurvivors) do

        local gens = ents.FindByClass("sc_generator")
        local random = math.random(#gens)
        gens[random].CansRemaining = math.Clamp((gens[random].CansRemaining or SlashCo.GasCansPerGenerator)-1,0,SlashCo.GasCansPerGenerator)

    end

end

SlashCo.SurvivorWinFinish = function()
    local delay = 16

    for _, play in ipairs( player.GetAll() ) do
        play:ChatPrint("[SlashCo] The Helicopter will now leave.")
    end

    timer.Simple(delay, function()

        SlashCo.EndRound()

    end)
end

SlashCo.SpawnCurConfig = function(isDebug)
    SlashCo.RemoveAllCurRoundEnts()
    --SlashCo.ResetCurRoundData()

    local curmap = game.GetMap()
    if curmap ~= "sc_lobby" then
        if not SlashCo.ValidateMap(curmap) then
            ErrorNoHalt("[SlashCo] '"..curmap.."' is not a playable map, aborting.\n")
            return
        end

        local slashergasmod = 0

        if SlashCo.CurRound.OfferingData.CurrentOffering == 2 then
            SlashCo.CurRound.OfferingData.ItemMod = -2
        end

        if SlashCo.CurRound.OfferingData.CurrentOffering == 2 then SlashCo.CurRound.OfferingData.SatO = 1 end

        if SlashCo.CurRound.OfferingData.CurrentOffering == 4 then SlashCo.CurRound.OfferingData.DO = true end

        if SlashCo.CurRound.OfferingData.CurrentOffering == 5 then SlashCo.CurRound.OfferingData.SO = 1 end

        SlashCo.CurRound.ItemCount = SlashCo.CurRound.ItemCount + SlashCo.CurRound.OfferingData.ItemMod + SlashCo.CurRound.Difficulty

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
        local random_itemSpawns = SlashCo.GetSpawnpoints(6 - #SlashCo.CurRound.SlasherData.AllSurvivors, #possibleItemSpawnpoints)

        if #random_itemSpawns < 1 then goto FULL end

        for _ = 1, #random_itemSpawns do --Free items spawned during the round
            local cls = SlashCo.SpawnableItems[math.random(1, #SlashCo.SpawnableItems)]
            SlashCo.CreateItems({math.random(1,#SlashCo.CurConfig.Items.Spawnpoints)}, cls)
        end

        ::FULL::

        --local item_class = ""

        --Decide if what and if items should be spawned according to the selected slasher
        for _, p in ipairs(SlashCo.CurRound.SlashersToBeSpawned) do

            local slashid = SlashCo.CurRound.Slashers[p:SteamID64()].SlasherID

            print("SLASHER ID: "..slashid)

            local itemClass
            if slashid == "Sid" then
                itemClass = "sc_cookie"
            elseif slashid == "Thirsty" then
                itemClass = "sc_milkjug"
            end

            if itemClass then SlashCo.CreateItems(itemSpawns, itemClass) print("[SlashCo] Spawning Items.") end

            if slashid == "Male07" then

                local diff = SlashCo.CurRound.Difficulty

                for _ = 1, (  math.random(0, 6) + (10 * SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE) + (  diff  *  4  )     ) do

                    SlashCo.CreateItem("sc_maleclone", SlashCo.TraceHullLocator(), Angle(0,0,0))

                end

            end

            slashergasmod = slashergasmod + SlashCo.CurRound.Slashers[p:SteamID64()].GasCanMod

        end

        SlashCo.CurRound.GasCanCount = SlashCo.CurRound.GasCanCount + slashergasmod

        if SlashCo.CurRound.GasCanCount < 2 then SlashCo.CurRound.GasCanCount = 2 end

        --Spawn all generators
        local genSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GeneratorCount, #(SlashCo.CurConfig.Generators.Spawnpoints))
        --local gasSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GasCanCount, #(SlashCo.CurConfig.GasCans.Spawnpoints))
        local gasSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GasCanCount, #(SlashCo.CurConfig.GasCans.Spawnpoints))

        if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then
            gasSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.GasCanCount, #(SlashCo.CurConfig.Offerings.Exposure.Spawnpoints))
        end

        SlashCo.CreateGenerators(genSpawns)
        SlashCo.CreateBatteries(genSpawns)
        SlashCo.CreateGasCans(gasSpawns)

        --SlashCo.GetSpawnpoints(1, #possibleItemSpawnpoints) --local beacon_spawn =
        local r = math.random(1, #possibleItemSpawnpoints)
        local pickedpoint = possibleItemSpawnpoints[r]

        local id = SlashCo.CreateItem("sc_beacon", Vector(pickedpoint.pos[1],pickedpoint.pos[2],pickedpoint.pos[3]), Angle(pickedpoint.ang[1],pickedpoint.ang[2],pickedpoint.ang[3])) --Spawn one distress beacon
        SlashCo.CurRound.Items[id] = true

        SlashCo.CurRound.roundOverToggle = true
        GAMEMODE.State = GAMEMODE.States.IN_GAME
        SlashCo.CurRound.GameProgress = 0

        SlashCo.UpdateHelicopterSeek( SlashCo.CurRound.HelicopterIntroPosition )

        SlashCo.CreateHelicopter( SlashCo.CurRound.HelicopterIntroPosition, SlashCo.CurRound.HelicopterIntroAngle )

        SlashCo.BroadcastCurrentRoundData(true)

        timer.Simple(8, function()

            SlashCo.HelicopterTakeOffIntro()

            --if not isDebug then SlashCo.ClearDatabase() end --Everything was loaded, clear the database.

        end)

        timer.Simple( math.random(2,4), function() SlashCo.HelicopterRadioVoice(1) end)

        SlashCo.RoundHeadstart()
    end
end

--Used to test configs for conflicts.
--Run lua_run SlashCo.TestConfig

concommand.Add( "debug_config", function( _, _, _ )
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

    if SlashCo.CurRound.EscapeHelicopterSummoned then return true end

    timer.Simple( math.random(2,5), function() SlashCo.HelicopterRadioVoice(2) end)

    SlashCo.CurRound.EscapeHelicopterSummoned = true

	--[[

			Once both Generators have been activated, a timer will start which will determine when the rescue helicopter will arrive.
			Difficulty 0 - 30-60 seconds
			Difficulty 1,2 - 30-100 seconds
			Difficulty 3 - 30-140 seconds


	]]

    local delay = 30 + math.random( 0, 30 + ( SlashCo.CurRound.Difficulty * 20 ) )

	print("[SlashCo] Generators On. The Helicopter will arrive in "..delay.." seconds.")

    timer.Simple(delay, function()

        local entID = SlashCo.CreateHelicopter( SlashCo.CurRound.HelicopterSpawnPosition, Angle( 0,0,0 ) )

        SlashCo.EscapeVoicePrompt()

        timer.Simple(0.1, function()

            SlashCo.HelicopterGoAboveLand(entID)

        end)

        net.Start("mantislashcoHelicopterMusic")
        net.Broadcast()

    end)

end

SlashCo.HelicopterGoAboveLand = function(id)

    local rand = math.random( 1, #SlashCo.CurConfig.Helicopter.Spawnpoints) --The Landing position is randomized

    local pos = SlashCo.CurConfig.Helicopter.Spawnpoints[rand].pos
    --local ang = SlashCo.CurConfig.Helicopter.Spawnpoints[rand].ang

	SlashCo.CurRound.HelicopterTargetPosition = Vector(pos[1],pos[2],pos[3]+1000)

    local delay = math.sqrt( ents.GetByIndex(id):GetPos():Distance(Vector(pos[1],pos[2],pos[3]+1000)) ) / 5

    timer.Simple(delay, function()

        SlashCo.HelicopterLand(pos)

    end)

end

SlashCo.HelicopterLand = function(pos)

	SlashCo.CurRound.HelicopterTargetPosition = Vector(pos[1],pos[2],pos[3])

    timer.Simple( math.random(4,6), function() SlashCo.HelicopterRadioVoice(3) end)

    --Will the Helicopter Abandon players?

    if SlashCo.CurRound.Difficulty ~= 3 then return end

    local abandon = math.random(50, 120)
    print("[SlashCo] Helicopter set to abandon players in "..tostring(abandon).." seconds.")

    timer.Simple(abandon, function()

        SlashCo.HelicopterTakeOff()
        SlashCo.SurvivorWinFinish()

    end)

end

SlashCo.HelicopterTakeOff = function()

	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1],SlashCo.CurRound.HelicopterTargetPosition[2],SlashCo.CurRound.HelicopterTargetPosition[3]+1000)

    timer.Simple(9, function()

        SlashCo.HelicopterFinalLeave()

    end)

end

SlashCo.HelicopterTakeOffIntro = function()

	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1],SlashCo.CurRound.HelicopterTargetPosition[2],SlashCo.CurRound.HelicopterTargetPosition[3]+1000)

    timer.Simple(9, function()

        SlashCo.HelicopterLeaveForIntro()

    end)

end

SlashCo.HelicopterFinalLeave = function()

	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],SlashCo.CurRound.HelicopterSpawnPosition[2],SlashCo.CurRound.HelicopterSpawnPosition[3])

end

SlashCo.HelicopterLeaveForIntro = function()

	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],SlashCo.CurRound.HelicopterSpawnPosition[2],SlashCo.CurRound.HelicopterSpawnPosition[3])

    local delay = math.sqrt( ents.GetByIndex(SlashCo.CurRound.Helicopter):GetPos():Distance(Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],SlashCo.CurRound.HelicopterSpawnPosition[2],SlashCo.CurRound.HelicopterSpawnPosition[3])) ) / 5

    timer.Simple(delay, function()

        local heli = ents.GetByIndex(SlashCo.CurRound.Helicopter)

        heli:StopSound("slashco/helicopter_engine_distant.wav")
		heli:StopSound("slashco/helicopter_rotors_distant.wav")
		heli:StopSound("slashco/helicopter_engine_close.wav")
		heli:StopSound("slashco/helicopter_rotors_close.wav")

        timer.Simple(0.05, function()

		    heli:StopSound("slashco/helicopter_engine_distant.wav")
		    heli:StopSound("slashco/helicopter_rotors_distant.wav")
		    heli:StopSound("slashco/helicopter_engine_close.wav")
		    heli:StopSound("slashco/helicopter_rotors_close.wav")

            SlashCo.RemoveHelicopter()

        end)

    end)

end

SlashCo.UpdateHelicopterSeek = function(pos)

	SlashCo.CurRound.HelicopterTargetPosition = pos

end

SlashCo.RemoveHelicopter = function()

    local ent = ents.GetByIndex(SlashCo.CurRound.Helicopter)

    if IsValid(ent) then ent:Remove() end

end

SlashCo.TraceHullLocator = function()

    --Repeatedly positioning a TraceHull to a random position to find a spot with enough space for a player or npc.

    local height_offset = 10
    local size = SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE

    local range = 3500*size

    local pos = Vector(0,0,h)

    ::RELOCATE::

    local h = SlashCo.Maps[SlashCo.ReturnMapIndex()].LEVELS[math.random(1, #SlashCo.Maps[SlashCo.ReturnMapIndex()].LEVELS)]

    pos = Vector(math.random(-range,range),math.random(-range,range),h)

    local tr_l = util.TraceLine( {
		start = pos,
		endpos = pos - Vector(0,0,1000),
	} )

    if not tr_l.Hit then goto RELOCATE end

    local tr = util.TraceHull( {
		start = pos,
		endpos = pos + Vector(0,0,tr_l.HitPos[3] - height_offset),
		maxs = Vector(18,18,72),
		mins = Vector(-18,-18,0),
	} )

    if tr.Hit then goto RELOCATE end

    pos = tr_l.HitPos

    return pos

end

SlashCo.RadialTester = function(ent, dist, secondary)

    local last_best_angle = 0
    local last_greatest_distance = 0

    for i = 1, 359 do

        local ang = ent:GetAngles()[2] + i

        local tr = util.TraceLine( {
            start = ent:GetPos() + Vector(0,0,60),
            endpos = (  ent:GetAngles() + Angle(0,ang,0)    ):Forward() * dist,
            filter = {ent, secondary}
        } )

        if not tr.Hit then return ang end

        if ( tr.HitPos - tr.StartPos ):Length() > last_greatest_distance then

            last_greatest_distance = ( tr.HitPos - tr.StartPos ):Length()

            last_best_angle = ang

        end

    end

    return last_best_angle

end

SlashCo.LocalizedTraceHullLocator = function(ent, input_range)

    --Repeatedly positioning a TraceHull to a random localized position to find a spot with enough space for a player or npc.

    local height_offset = 10
    local size = SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE

    local range = input_range

    local pos = Vector(0,0,h)

    local err = 0

    ::RELOCATE::

    if err > 250 then print("TRACE LOCATOR FAILURE.") return end

    pos = ent:LocalToWorld(Vector(math.random(-range,range),math.random(-range,range),height_offset * 50))

    local tr_l = util.TraceLine( {
		start = pos,
		endpos = pos - Vector(0,0,1000),
	} )

    if not tr_l.Hit then err = err+1 goto RELOCATE end

    local tr = util.TraceHull( {
		start = pos,
		endpos = pos + Vector(0,0,tr_l.HitPos[3] - height_offset),
		maxs = Vector(12,12,72),
		mins = Vector(-12,-12,0),
	} )

    if tr.Hit then err = err+1 goto RELOCATE end

    pos = tr_l.HitPos

    return pos

end

SlashCo.LocalizedTraceHullLocatorAdvanced = function(ent, min_range, input_range, offset)

    --Repeatedly positioning a TraceHull to a random localized position to find a spot with enough space for a player or npc.

    local height_offset = 10
    local size = SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE

    local range = input_range

    local pos = Vector(0,0,h)

    local err = 0

    local offset_local = ent:GetForward() * offset

    ::RELOCATE::

    if err > 250 then print("TRACE LOCATOR FAILURE.") return end

    local x_s = math.random(-range,range)
    local y_s = math.random(-range,range)

    if math.abs(x_s) < min_range then y_s = min_range + math.random(0,range-min_range) end 
    if math.abs(y_s) < min_range then y_s = min_range + math.random(0,range-min_range) end 

    pos = ent:LocalToWorld(offset_local + Vector((x_s) ,y_s , height_offset * 50))

    local tr_l = util.TraceLine( {
		start = pos,
		endpos = pos - Vector(0,0,1000),
	} )

    if not tr_l.Hit then err = err+1 goto RELOCATE end

    local tr = util.TraceHull( {
		start = pos,
		endpos = pos + Vector(0,0,tr_l.HitPos[3] - height_offset),
		maxs = Vector(18,18,72),
		mins = Vector(-18,-18,0),
	} )

    if tr.Hit then err = err+1 goto RELOCATE end

    pos = tr_l.HitPos

    return pos

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
