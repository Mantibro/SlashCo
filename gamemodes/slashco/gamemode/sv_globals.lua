SlashCo = SlashCo or {}

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
	until SCInfo.Maps[rand_name].MIN_PLAYERS <= (ply_count + (SCInfo.MinimumMapPlayers - 1)) and rand_name ~= "error"

	return rand_name
end

SlashCo.MAXPLAYERS = 7

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
		--GeneratorCount = 2,
		GasCanCount = 8,
		ItemCount = 6,
		roundOverToggle = false, --weird
		HelicopterSpawnPosition = Vector(0, 0, 0),
		HelicopterInitialSpawnPosition = Vector(0, 0, 0),
		HelicopterTargetPosition = Vector(0, 0, 0),
		HelicopterRescuedPlayers = {}, --need opt
		EscapeHelicopterSummoned = false,
		DistressBeaconUsed = false,
	}
end
SlashCo.ResetCurRoundData()

SlashCo.PlayerData = SlashCo.PlayerData or {} --Holds all loaded playerdata

--Spawn a gas can
SlashCo.CreateGasCan = function(pos, ang)
	local Ent = ents.Create("sc_gascan")

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create a gas can at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	--The JUG
	if math.random() > 0.35 then
		Ent:SetNWBool("JugCursed", true)
	end

	return Ent
end

--Spawn an Item( or any entity, including slasher entities )
SlashCo.CreateItem = function(class, pos, ang)
	local Ent = ents.Create(class)

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create a " .. class .. " at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()
	Ent:Activate()

	local id = Ent:EntIndex()

	if class == "sc_babaclone" then
		SlashCo.CurRound.SlasherEntities[id] = {
			activateWalk = false,
			activateSpook = false,
			PostActivation = false
		}
	end

	return id
end

--Spawn the helicopter
SlashCo.CreateHelicopter = function(pos, ang)
	local Ent = ents.Create("sc_helicopter")

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create the helicopter at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	SlashCo.CurRound.Helicopter = Ent:EntIndex()
	return Ent
end

--Spawn the item stash 
SlashCo.CreateItemStash = function(pos, ang)
	local Ent = ents.Create("sc_itemstash")

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create the itemstash at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	local id = Ent:EntIndex()

	return id
end

--Spawn the offering table
SlashCo.CreateOfferTable = function(pos, ang)
	local Ent = ents.Create("sc_offertable")

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create the offertable at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	local id = Ent:EntIndex()

	return id
end

--Spawn the radio
SlashCo.CreateRadio = function(pos, ang)
	local Ent = ents.Create("radio")

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create the offertable at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	local id = Ent:EntIndex()

	return id
end

SlashCo.RemoveAllCurRoundEnts = function()
	local gens = ents.FindByClass("sc_generator")
	for _, v in ipairs(gens) do
		local can = v.FuelingCan --make sure any attached cans and bats go too
		if IsValid(can) then
			can:Remove()
		end
		v:Remove()
	end

	local cans = ents.FindByClass("sc_gascan")
	for _, v in ipairs(cans) do
		v:Remove()
	end

	for k, _ in pairs(SlashCo.CurRound.Items) do
		local ent = Entity(k)
		if IsValid(ent) then
			ent:Remove()
		end
	end

	local bats = ents.FindByClass("sc_battery")
	for _, v in ipairs(bats) do
		v:Remove()
	end

	for I = 1, #SlashCo.CurRound.ExposureSpawns do
		if IsValid(Entity(SlashCo.CurRound.ExposureSpawns[I])) then
			Entity(SlashCo.CurRound.ExposureSpawns[I]):Remove()
		end
	end
end

SlashCo.ChangeMap = function(mapname)
	RunConsoleCommand("changelevel", mapname)
end

SlashCo.GoToLobby = function()
	SlashCo.ChangeMap("sc_lobby")
end

SlashCo.SummonEscapeHelicopter = function(distress)
	if SlashCo.CurRound.EscapeHelicopterSummoned then
		return true
	end

	timer.Simple(math.random(2, 5), function()
		if distress then
			SlashCo.HelicopterRadioVoice(4)

			SlashCo.UpdateObjective("generator", SlashCo.ObjStatus.FAILED)
		else
			SlashCo.HelicopterRadioVoice(2)

			SlashCo.UpdateObjective("generator", SlashCo.ObjStatus.COMPLETE)
		end

		SlashCo.UpdateObjective("heliwait", SlashCo.ObjStatus.INCOMPLETE)
		SlashCo.SendObjectives()
	end)

	SlashCo.CurRound.EscapeHelicopterSummoned = true

	--[[
		Once both Generators have been activated, a timer will start which will determine when the rescue helicopter will arrive.
		Difficulty 0 - 30-60 seconds
		Difficulty 1,2 - 30-100 seconds
		Difficulty 3 - 30-140 seconds
	]]

	local delay = 30 + math.random(0, 30 + (SlashCo.CurRound.Difficulty * 20))

	print("[SlashCo] Generators On. The Helicopter will arrive in " .. delay .. " seconds.")

	timer.Simple(delay, function()
		local ent = SlashCo.CreateHelicopter(SlashCo.CurRound.HelicopterSpawnPosition, Angle(0, 0, 0))

		SlashCo.EscapeVoicePrompt()
		timer.Simple(0.1, function()
			SlashCo.HelicopterGoAboveLand(ent)
		end)

		net.Start("mantislashcoHelicopterMusic")
		net.Broadcast()
	end)
end

SlashCo.HelicopterGoAboveLand = function(ent)
	local target = SlashCo.SelectSpawnsNoForce(ents.FindByClass("info_sc_helicopter"))
	if not IsValid(target) then
		SlashCo.Abort("Missing helicopter landing entities")
		return
	end
	local pos = target:GetPos() - Vector(0, 0, 70)

	SlashCo.CurRound.HelicopterTargetPosition = pos + Vector(0, 0, 1000)
	local delay = math.sqrt(ent:GetPos():Distance(pos + Vector(0, 0, 1000))) / 5

	timer.Simple(delay, function()
		SlashCo.HelicopterLand(pos)
	end)
end

SlashCo.HelicopterLand = function(pos)
	SlashCo.CurRound.HelicopterTargetPosition = pos

	timer.Simple(math.random(4, 6), function()
		SlashCo.HelicopterRadioVoice(3)

		SlashCo.UpdateObjective("heliwait", SlashCo.ObjStatus.COMPLETE)
		SlashCo.UpdateObjective("helicopter", SlashCo.ObjStatus.INCOMPLETE, nil, true)
		SlashCo.SendObjectives()
	end)

	--Will the Helicopter Abandon players?

	if SlashCo.CurRound.Difficulty ~= 3 then
		return
	end

	local abandon = math.random(50, 120)
	print("[SlashCo] Helicopter set to abandon players in " .. tostring(abandon) .. " seconds.")

	timer.Simple(abandon, function()
		SlashCo.UpdateObjective("helicopter", SlashCo.ObjStatus.FAILED)
		SlashCo.SendObjectives()

		SlashCo.HelicopterTakeOff()
		SlashCo.SurvivorWinFinish()
	end)
end

SlashCo.HelicopterTakeOff = function()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1],
			SlashCo.CurRound.HelicopterTargetPosition[2], SlashCo.CurRound.HelicopterTargetPosition[3] + 1000)

	timer.Simple(9, function()
		SlashCo.HelicopterFinalLeave()
	end)
end

SlashCo.HelicopterTakeOffIntro = function()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1],
			SlashCo.CurRound.HelicopterTargetPosition[2], SlashCo.CurRound.HelicopterTargetPosition[3] + 1000)

	timer.Simple(9, function()
		SlashCo.HelicopterLeaveForIntro()
	end)
end

SlashCo.HelicopterFinalLeave = function()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],
			SlashCo.CurRound.HelicopterSpawnPosition[2], SlashCo.CurRound.HelicopterSpawnPosition[3])
end

SlashCo.HelicopterLeaveForIntro = function()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],
			SlashCo.CurRound.HelicopterSpawnPosition[2], SlashCo.CurRound.HelicopterSpawnPosition[3])

	local delay = math.sqrt(ents.GetByIndex(SlashCo.CurRound.Helicopter):GetPos():Distance(Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],
			SlashCo.CurRound.HelicopterSpawnPosition[2], SlashCo.CurRound.HelicopterSpawnPosition[3]))) / 5

	timer.Simple(delay, function()
		local heli = ents.GetByIndex(SlashCo.CurRound.Helicopter)

		if not IsValid(heli) then
			return
		end

		heli:StopSound("slashco/helicopter_engine_distant.wav")
		heli:StopSound("slashco/helicopter_rotors_distant.wav")
		heli:StopSound("slashco/helicopter_engine_close.wav")
		heli:StopSound("slashco/helicopter_rotors_close.wav")

		timer.Simple(0.05, function()
			if IsValid(heli) then
				heli:StopSound("slashco/helicopter_engine_distant.wav")
				heli:StopSound("slashco/helicopter_rotors_distant.wav")
				heli:StopSound("slashco/helicopter_engine_close.wav")
				heli:StopSound("slashco/helicopter_rotors_close.wav")
			end
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
	if IsValid(ent) then
		ent:Remove()
	end
end

SlashCo.RadialTester = function(ent, dist, secondary)
	local last_best_angle = 0
	local last_greatest_distance = 0

	for i = 1, 359 do

		local ang = ent:GetAngles()[2] + i

		local tr = util.TraceLine({
			start = ent:GetPos() + Vector(0, 0, 60),
			endpos = (ent:GetAngles() + Angle(0, ang, 0)):Forward() * dist,
			filter = { ent, secondary }
		})

		if not tr.Hit then
			return ang
		end

		if (tr.HitPos - tr.StartPos):Length() > last_greatest_distance then
			last_greatest_distance = (tr.HitPos - tr.StartPos):Length()
			last_best_angle = ang
		end
	end

	return last_best_angle
end

SlashCo.ClearDatabase = function()
	if SERVER then
		print("[SlashCo] Clearing Database. . .")

		sql.Query("DROP TABLE slashco_table_basedata;")
		sql.Query("DROP TABLE slashco_table_survivordata;")
		sql.Query("DROP TABLE slashco_table_slasherdata;")
	end
end
