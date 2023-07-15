local SlashCo = SlashCo

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

            --Nightmare offering >>>>>>>>>>>>>>>>>>>>>

            if SlashCo.CurRound.OfferingData.CurrentOffering == 6 then

                --All survivors will become slashers.

                local query = sql.Query("SELECT * FROM slashco_table_survivordata; ")
                for i = 1, #query do

                    local id = query[i].Survivors
    
                    timer.Simple(1, function()

                        local slasher_pick = GetRandomSlasher()

                        SlashCo.SelectSlasher(slasher_pick, id)
                        table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { s_id = id, slasherkey = slasher_pick })

                        table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = id })
    
                    end)

                end

                --Slasher becomes the sole survivor

                for s = 1, #sql.Query("SELECT * FROM slashco_table_slasherdata; ") do

                    local sr_id = sql.Query("SELECT * FROM slashco_table_slasherdata; ")[s].Slashers

                    --table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = sr_id })
                    --For the slasher's clientside view also
                    table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = sr_id, GameContribution = 0 })
    
                end

                return

            end

            --Nightmare offering >>>>>>>>>>>>>>>>>>>>>>>>


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

            for s = 1, #sql.Query("SELECT * FROM slashco_table_slasherdata; ") do

                local id = sql.Query("SELECT * FROM slashco_table_slasherdata; ")[s].Slashers
                if id == "90071996842377216" then
                    break
                end

                timer.Simple(1, function()
                    if s == 1 then
                        if slasher1id == "Covenant" then SlashCo.PresentCovenant = id end
                        SlashCo.SelectSlasher(slasher1id, id)
                        table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { s_id = id, slasherkey = slasher1id })
                    end
                    if s == 2 then
                        if SlashCo.PresentCovenant == nil then
                            SlashCo.SelectSlasher(slasher2id, id)
                            table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { s_id = id, slasherkey = slasher2id })
                        else
                            table.insert(SlashCoSlasher.Covenant.PlayersToBecomePartOfCovenant, { steamid = id })
                        end

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

        local becameCovenant = 0

        if sql.TableExists("slashco_table_basedata") and sql.TableExists("slashco_table_survivordata") and sql.TableExists("slashco_table_slasherdata") then

            timer.Simple(0.05, function()

                print("[SlashCo] Now proceeding with Spawns...")

                SlashCo.PrepareSlasherForSpawning()

                SlashCo.SpawnPlayers()

            end)

            print("[SlashCo] Teams database loaded...")

            local survivors = sql.Query("SELECT * FROM slashco_table_survivordata; ")
            local slashers = sql.Query("SELECT * FROM slashco_table_slasherdata; ")

            for play = 1, #player.GetAll() do
                --Assign the teams for the current round

                local playercur = player.GetAll()[play]
                local id = playercur:SteamID64()

                print("name: " .. playercur:Name())

                --Nightmare offering >>>>>>>>>>>>>>>>>>>>>

                if SlashCo.CurRound.OfferingData.CurrentOffering == 6 then

                    for i = 1, #slashers do --Slasher becomes the sole survivor
                        if id == slashers[i].Slashers then
                            print(playercur:Name() .. " now Survivor for Nightmare.")
                            playercur:SetTeam(TEAM_SURVIVOR)
                            playercur:Spawn()
                        end
                    end

                    for i = 1, #survivors do
                        if id == survivors[i].Survivors then
    
                            playercur:SetTeam(TEAM_SPECTATOR)
                            playercur:Spawn()
                            print(playercur:Name() .. " now Slasher for Nightmare")

                            table.insert(SlashCo.CurRound.SlashersToBeSpawned, playercur)
    
                            break
    
                        else
    
                            if slashers[1] ~= nil and id == slashers[1].Slashers then
                                goto CONT_NGHT
                            end
    
                            for k = 1, #survivors do
                                if id == survivors[k].Survivors then
                                    goto CONT_NGHT
                                end
                            end
    
                            playercur:SetTeam(TEAM_SPECTATOR)
                            playercur:Spawn()
                            print(playercur:Name() .. " now Spectator (Nightmare)")
                        end
                        :: CONT_NGHT ::
                    end


                    if play >= #player.GetAll() then 
                        goto NIGHTMARE_SKIPALL 
                    else
                        goto NIGHTMARE_SKIPPART 
                    end
                end

                --Nightmare offering >>>>>>>>>>>>>>>>>>>>>

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

                        if SlashCo.PresentCovenant == nil and becameCovenant < 3 then
                            table.insert(SlashCoSlasher.Covenant.PlayersToBecomePartOfCovenant, { steamid = id })
                            becameCovenant = becameCovenant + 1
                        end
                    end
                    :: CONTINUE ::
                end

                for i = 1, #slashers do
                    if id == slashers[i].Slashers then

                        for _, v in ipairs(SlashCoSlasher.Covenant.PlayersToBecomePartOfCovenant) do
                            if v.steamid == id then
                                print(playercur:Name() .. " will become part of the Covenant.")
                                playercur:SetTeam(TEAM_SPECTATOR)
                                playercur:Spawn()

                                goto covenant_member
                            end
                        end


                        print(playercur:Name() .. " now Slasher (Memorized)")
                        playercur:SetTeam(TEAM_SPECTATOR)
                        playercur:Spawn()

                        table.insert(SlashCo.CurRound.SlashersToBeSpawned, playercur)

                        --table.insert(SlashCo.CurRound.SlasherData.AllSlashers, {s_id = playercur:SteamID64()})
                        ::covenant_member::

                    end
                end

                ::NIGHTMARE_SKIPPART::

            end

            --local id1 = slashers[1].Slashers
            local id2 = 0
            if slashers[2] ~= nil then
                id2 = slashers[2].Slashers
            end

            ::NIGHTMARE_SKIPALL::

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

    gasCount = SCInfo.Maps[game.GetMap()].SIZE + json.GasCans.Count + (3-SlashCo.CurRound.Difficulty) + SlashCo.CurRound.OfferingData.GasCanMod + (4 - #SlashCo.CurRound.SlasherData.AllSurvivors) - SlashCo.CurRound.SurvivorData.GasCanMod

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

            if #SlashCo.CurRound.SlasherData.AllSurvivors == SurvivorCount and SurvivorCount == #SlashCo.CurRound.HelicopterRescuedPlayers then --Everyone lived

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

        for i = 1, #SlashCo.CurRound.SlasherData.AllSurvivors do
            local man = SlashCo.CurRound.SlasherData.AllSurvivors[i].id

            if IsValid(player.GetBySteamID64( man )) then
                SlashCoDatabase.UpdateStats(man, "Points", SlashCo.PlayerData[man].PointsTotal)
            end

        end

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

        if #survivors < 1 then

            --Add to stats of the slasher's wins
            for i = 1, #slashers do
                SlashCoDatabase.UpdateStats(slashers[i]:SteamID64(), "SlasherRoundsWon", 1)
            end

        end

        SlashCo.RemoveAllCurRoundEnts()
        SlashCo.ResetCurRoundData()

        timer.Simple(0.5, function()
            SlashCo.GoToLobby()
        end)
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

        local diff = SlashCo.CurRound.Difficulty

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

        local item_count = ((SlashCo.MAXPLAYERS + 1) - math.floor((diff+1) / 2) ) - #SlashCo.CurRound.SlasherData.AllSurvivors

        local itemSpawns
        if item_count >= 1 then
            itemSpawns = SlashCo.GetSpawnpoints(SlashCo.CurRound.ItemCount, #possibleItemSpawnpoints)
            local random_itemSpawns = SlashCo.GetSpawnpoints(item_count, #possibleItemSpawnpoints)

            if #random_itemSpawns >= 1 then
                for _ = 1, #random_itemSpawns do --Free items spawned during the round
                    local cls = SlashCo.SpawnableItems[math.random(1, #SlashCo.SpawnableItems)]
                    SlashCo.CreateItems({math.random(1,#SlashCo.CurConfig.Items.Spawnpoints)}, cls)
                end
            end
        end

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
            elseif slashid == "Princess" then
                itemClass = "sc_baby"
            end

            if itemClass then SlashCo.CreateItems(itemSpawns, itemClass) print("[SlashCo] Spawning Items.") end

            if slashid == "Male07" then

                local diff1 = SlashCo.CurRound.Difficulty

                for _ = 1, (  math.random(0, 6) + (10 * SCInfo.Maps[game.GetMap()].SIZE) + (  diff1  *  4  )     ) do

                    SlashCo.CreateItem("sc_maleclone", SlashCo.TraceHullLocator(), angle_zero)

                end

            end

            slashergasmod = slashergasmod + SlashCo.CurRound.Slashers[p:SteamID64()].GasCanMod

        end

        local spawnableItems = {}
        for k, v in pairs(SlashCoItems) do
            if v.ReplacesWorldProps then
                spawnableItems[v.Model] = k
            end
        end

        --Repalce world props.
        for _, v in ipairs(ents.FindByClass("prop_physics")) do
            local item = spawnableItems[v:GetModel()]
            if item then
                local it_pos = v:GetPos()
                local it_ang = v:GetAngles()
                local droppedItem = SlashCo.CreateItem(SlashCoItems[item].EntClass, it_pos, it_ang)
                SlashCo.CurRound.Items[droppedItem] = true
                Entity(droppedItem):SetCollisionGroup(COLLISION_GROUP_NONE)
                v:Remove()
            end
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

        GAMEMODE.State = GAMEMODE.States.IN_GAME
        SlashCo.CurRound.GameProgress = 0

        SlashCo.UpdateHelicopterSeek( SlashCo.CurRound.HelicopterIntroPosition )

        SlashCo.CreateHelicopter( SlashCo.CurRound.HelicopterIntroPosition, SlashCo.CurRound.HelicopterIntroAngle )

        SlashCo.BroadcastCurrentRoundData(true)

        timer.Simple(8, function()

            SlashCo.HelicopterTakeOffIntro()

            --if not isDebug then SlashCo.ClearDatabase() end --Everything was loaded, clear the database.

        end)

        timer.Simple( math.random(2,4), function() 
            SlashCo.HelicopterRadioVoice(1) 
            SlashCo.CurRound.roundOverToggle = true
        end)

        if SlashCo.CurRound.OfferingData.CurrentOffering == 6 then

            timer.Simple( 240, function() 
            
                local failed = SlashCo.SummonEscapeHelicopter()

                if not failed then
                    SlashCo.CurRound.DistressBeaconUsed = false
                end
            
            end)
            
        else
            SlashCo.RoundHeadstart()
        end
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

    local itemSpawns = SlashCo.GetSpawnpoints(#(possibleItemSpawnpoints), #(possibleItemSpawnpoints))

    --Check Exposure offering spawnpoints too.
    if SlashCo.CurConfig.Offerings.Exposure.Spawnpoints then
        local exposureSpawns = SlashCo.GetSpawnpoints(#(SlashCo.CurConfig.Offerings.Exposure.Spawnpoints), #(SlashCo.CurConfig.Offerings.Exposure.Spawnpoints))
        SlashCo.CreateGasCansE(exposureSpawns)
    end

    SlashCo.CreateGenerators(genSpawns, true)
    print("[SlashCo] TESTCONFIG: Creating Generators.")

    timer.Simple(1, function()
        SlashCo.CreateBatteriesE(genSpawns)
        print("[SlashCo] TESTCONFIG: Creating Batteries.")
    end)

    timer.Simple(2, function()
        SlashCo.CreateGasCans(gasSpawns, true)
        print("[SlashCo] TESTCONFIG: Creating Gas Cans.")
    end)

    timer.Simple(3, function()
        SlashCo.CreateItems(itemSpawns, "sc_milkjug", true)
        print("[SlashCo] TESTCONFIG: Creating Items.")
    end)
    
    net.Start("octoSlashCoTestConfigHalos")
    --net.WriteTable(send) --I'm so sorry for using this, I'm just too lazy.
    net.Broadcast()
end