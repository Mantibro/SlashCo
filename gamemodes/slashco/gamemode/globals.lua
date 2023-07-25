SlashCo = {}

SlashCo.CurConfig = {}

--Difficulty ENUM
SlashCo.Difficulty = {
    EASY = 0,
    NOVICE = 1,
    INTERMEDIATE = 2,
    HARD = 3
}

function GetRandomMap(ply_count)
    local keys = table.GetKeys(SCInfo.Maps)
    local rand, rand_name
    repeat
	      rand = math.random(1, #keys)
	      rand_name = keys[rand] --random id for this roll
    until SCInfo.Maps[rand_name].MIN_PLAYERS <= ( ply_count + ( SCInfo.MinimumMapPlayers - 1 ) )

    return rand_name
end

SlashCo.MAXPLAYERS = 7

SlashCo.Debug = false

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
    SelectedMap = "sc_summercamp",
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
        GeneratorCount = 2,
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
SlashCo.CreateGasCan = function(pos, ang, test)
    local Ent = ents.Create( "sc_gascan" )

    if not IsValid(Ent) then
        MsgC( Color( 255, 50, 50 ), "[SlashCo] Something went wrong when trying to create an exposure gas can at ("..tostring(pos).."), entity was NULL.\n")
        return nil
    end

    Ent:SetPos( pos )
    Ent:SetAngles( ang )
    Ent:Spawn()

    --The JUG
    if math.random() > 0.35 then
        Ent:SetNWBool("JugCursed", true)
    end

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

SlashCo.CreateGenerators = function(spawnpoints, testconfig)
    for k, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.Generators.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.Generators.Spawnpoints[v].ang

        local entID = SlashCo.CreateGenerator( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) ) --local entID =

        if testconfig then
            Entity(entID):SetNWInt("SpawnPoint_ID", k)
        end
    end
end

SlashCo.CreateGasCans = function(spawnpoints, testconfig)
    for k, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.GasCans.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.GasCans.Spawnpoints[v].ang

        if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then --Exposure Offering Spawnpoints
            pos = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[v].pos
            ang = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[v].ang
        end

        local ent = SlashCo.CreateGasCan( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ))

        if testconfig then
            ent:SetNWInt("SpawnPoint_ID", k)
        end
    end
end

--Testing only function for exposure spawnpoints
SlashCo.CreateGasCansE = function(spawnpoints)
    for _, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.Offerings.Exposure.Spawnpoints[v].ang

        SlashCo.CreateGasCanE( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )
    end
end

SlashCo.CreateItems = function(spawnpoints, item, testconfig)
    for k, v in ipairs(spawnpoints) do
        local pos = SlashCo.CurConfig.Items.Spawnpoints[v].pos
        local ang = SlashCo.CurConfig.Items.Spawnpoints[v].ang

        local id = SlashCo.CreateItem(item, Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ))
        SlashCo.CurRound.Items[id] = true

        if testconfig then
            Entity(id):SetNWInt("SpawnPoint_ID", k)
        end
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
    for k, v in ipairs(spawnpoints) do
        for J=1, #(SlashCo.CurConfig.Batteries.Spawnpoints[v])do
            local pos = SlashCo.CurConfig.Batteries.Spawnpoints[v][J].pos
            local ang = SlashCo.CurConfig.Batteries.Spawnpoints[v][J].ang

            local bat = SlashCo.CreateBattery( Vector(pos[1], pos[2], pos[3]), Angle( ang[1], ang[2], ang[3] ) )

            --bat:SetNWInt("SpawnPoint_ID_BatteryGenerator", k)
            bat:SetNWInt("SpawnPoint_ID", J)
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

SlashCo.ChangeMap = function(mapname)
    if SERVER then
        RunConsoleCommand("changelevel", mapname)
    end
end

SlashCo.GoToLobby = function()
    SlashCo.ChangeMap("sc_lobby")
end

SlashCo.SummonEscapeHelicopter = function(distress)

    if SlashCo.CurRound.EscapeHelicopterSummoned then return true end

    timer.Simple( math.random(2,5), function() 
        if distress then
            SlashCo.HelicopterRadioVoice(4) 
        else
            SlashCo.HelicopterRadioVoice(2) 
        end
    end)

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

            net.Start("mantislashcoMapAmbientPlay")
            net.Broadcast()

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
    local size = SCInfo.Maps[game.GetMap()].SIZE

    local range = 3500*size

    local pos = Vector(0,0,h)

    ::RELOCATE::

    local h = SCInfo.Maps[game.GetMap()].LEVELS[math.random(1, #SCInfo.Maps[game.GetMap()].LEVELS)]

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
    local size = SCInfo.Maps[game.GetMap()].SIZE

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
    local size = SCInfo.Maps[game.GetMap()].SIZE

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
