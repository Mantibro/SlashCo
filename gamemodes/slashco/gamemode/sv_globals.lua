SlashCo = SlashCo or {}

SlashCo.CurConfig = {}

function GetRandomMap(ply_count)
	local keys = table.GetKeys(SCInfo.Maps)
	if #keys == 0 then -- if we have no maps, we return early as else we enter a infinite loop that would crash the game.
		return "error"
	end

	local tries = #keys * 4
	for k=1, tries do -- This formerly was a repeat until loop, that loved to crash the game.
		local rand = math.random(1, #keys)
		local rand_name = keys[rand]
		if rand_name ~= "error" and SCInfo.Maps[rand_name].MIN_PLAYERS <= (ply_count + (SCInfo.MinimumMapPlayers - 1)) then
			return rand_name
		end
	end

	--[[local key, val = next( SCInfo.Maps )
	if val then
		return val
	end]]

	print("[SlashCo] Ran out of tries to select map to stop a game crash, this should usualy never happen.")
	return "error"
end

SlashCo.LobbyData = SlashCo.LobbyData or {
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
	SelectedDifficulty = SlashCo.DifficultyLevel.EASY,
	SurvivorGasMod = 0,
	SelectedSlasherInfo = {

		ID = 0,
		CLASS = 0,
		DANGER = 0,
		NAME = 0,
		TIP = "--//--"

	},
	SelectedMap = "sc_summercamp",
	PickedSlasher = "None",
	--DeathwardsLeft = 0 --not used

}

--Holds all the information about the ongoing round
function SlashCo.ResetCurRoundData()
	SlashCo.CurRound = {
		Difficulty = SlashCo.DifficultyLevel.EASY,
		ExpectedPlayers = {},
		--ExpectedPlayersLoaded = false, --not used
		--ConnectedPlayers = {}, --not used
		AntiLoopSpawn = false,
		OfferingData = {
			CurrentOffering = 0,
			OfferingName = "",
			GasCanMod = 0,
			Singularity = 0, -- ToDo: rename this and the two below, what do they do, what are they? no idea :(
			Duality = false,
			Satiation = 0,
			--DrainageTick = 0, --not used
			ItemMod = 0 -- Number of additional items to add/remove
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

	local OldOfferingKeys = {
		["SO"] = "Singularity",
		["DO"] = "Duality",
		["SatO"] = "Satiation",
	}
	local OfferingMeta = { -- Backwards compatiblity with any addons that use the old keys.
		__index = function(self, key)
			return rawget(self, OldOfferingKeys[key] or key)
		end,

		__newindex = function(self, key, value)
			rawset(self, OldOfferingKeys[key] or key, value)
		end,
	}

	debug.setmetatable(SlashCo.CurRound.OfferingData, OfferingMeta)

	local CurRoundMeta = { -- Backwards compatiblity with any addons that use the old keys.
		__index = function(self, key)
			if key == "Helicopter" then
				return IsValid(SlashCo.Helicopter) and SlashCo.Helicopter:EntIndex() or 0
			end

			return rawget(self, key)
		end,

		__newindex = function(self, key, value)
			if key == "Helicopter" then
				SlashCo.Helicopter = isnumber(value) and Entity(value) or nil
			end

			rawset(self, key, value)
		end,
	}
	debug.setmetatable(SlashCo.CurRound, CurRoundMeta)
end

if not SlashCo.CurRound then
	SlashCo.ResetCurRoundData()
end

SlashCo.PlayerData = SlashCo.PlayerData or {} --Holds all loaded playerdata

--Spawn a gas can
function SlashCo.CreateGasCan(pos, ang)
	local Ent = ents.Create("sc_gascan")

	if not IsValid(Ent) then
		MsgC(Color(255, 64, 64),
				"[SlashCo] Something went wrong when trying to create a gas can at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	return Ent
end

--Spawn an Item( or any entity, including slasher entities )
function SlashCo.CreateItem(class, pos, ang)
	local Ent = ents.Create(class)

	if not IsValid(Ent) then
		MsgC(Color(255, 64, 64),
				"[SlashCo] Something went wrong when trying to create a " .. class .. " at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()
	Ent:Activate()

	return Ent
end

--Spawn the helicopter
function SlashCo.CreateHelicopter(pos, ang)
	local Ent = ents.Create("sc_helicopter")

	if not IsValid(Ent) then
		MsgC(Color(255, 64, 64),
				"[SlashCo] Something went wrong when trying to create the helicopter at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	return Ent
end

--Spawn the item stash 
function SlashCo.CreateItemStash(pos, ang)
	local Ent = ents.Create("sc_itemstash")

	if not IsValid(Ent) then
		MsgC(Color(255, 64, 64),
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
function SlashCo.CreateOfferTable(pos, ang)
	local Ent = ents.Create("sc_offertable")

	if not IsValid(Ent) then
		MsgC(Color(255, 64, 64),
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
function SlashCo.CreateRadio(pos, ang)
	local Ent = ents.Create("radio")

	if not IsValid(Ent) then
		MsgC(Color(255, 64, 64),
				"[SlashCo] Something went wrong when trying to create the offertable at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	local id = Ent:EntIndex()

	return id
end

function SlashCo.RemoveAllCurRoundEnts()
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

function SlashCo.DisableSoundScapes()
	for _, ent in ipairs(ents.FindByClass("env_soundscape")) do
		ent:Fire("Disable")
	end
end

function SlashCo.EnableSoundScapes()
	for _, ent in ipairs(ents.FindByClass("env_soundscape")) do
		ent:Fire("Enable")
	end
end

function SlashCo.ChangeMap(mapname)
	if g_SlashCoDebug then return end -- Don't change map when debugging

	RunConsoleCommand("changelevel", mapname)
end

function SlashCo.GoToLobby()
	SlashCo.ChangeMap(GameData.Lobby)
end

function SlashCo.SummonEscapeHelicopter(distress)
	if SlashCo.CurRound.EscapeHelicopterSummoned then
		return true
	end

	timer.Simple(math.random(2, 5), function()
		if distress then
			SlashCo.HelicopterRadioVoice(SlashCo.HelicopterVoices.BEACON)

			SlashCo.UpdateObjective("generator", SlashCo.ObjStatus.FAILED)
		else
			SlashCo.HelicopterRadioVoice(SlashCo.HelicopterVoices.APPROACH)

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

		SlashCo.AudioSystem.SetBackgroundMusic("slashco/music/slashco_helicopter.wav", 3)
		SlashCo.AudioSystem.EnableBackgroundMusic()
	end)
end

function SlashCo.HelicopterGoAboveLand(ent)
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

function SlashCo.HelicopterLand(pos)
	SlashCo.CurRound.HelicopterTargetPosition = pos

	timer.Simple(math.random(4, 6), function()
		SlashCo.HelicopterRadioVoice(SlashCo.HelicopterVoices.LAND)

		SlashCo.UpdateObjective("heliwait", SlashCo.ObjStatus.COMPLETE)
		SlashCo.UpdateObjective("helicopter", SlashCo.ObjStatus.INCOMPLETE, nil, true)
		SlashCo.SendObjectives()
	end)

	--Will the Helicopter Abandon players?

	if SlashCo.CurRound.Difficulty ~= SlashCo.DifficultyLevel.HARD then
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

function SlashCo.HelicopterTakeOff()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1],
			SlashCo.CurRound.HelicopterTargetPosition[2], SlashCo.CurRound.HelicopterTargetPosition[3] + 1000)

	timer.Simple(9, function()
		SlashCo.HelicopterFinalLeave()
	end)
end

function SlashCo.HelicopterTakeOffIntro()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1],
			SlashCo.CurRound.HelicopterTargetPosition[2], SlashCo.CurRound.HelicopterTargetPosition[3] + 1000)

	timer.Simple(9, function()
		SlashCo.HelicopterLeaveForIntro()
	end)
end

function SlashCo.HelicopterFinalLeave()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],
			SlashCo.CurRound.HelicopterSpawnPosition[2], SlashCo.CurRound.HelicopterSpawnPosition[3])
end

function SlashCo.HelicopterLeaveForIntro()
	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],
			SlashCo.CurRound.HelicopterSpawnPosition[2], SlashCo.CurRound.HelicopterSpawnPosition[3])

	local heli = SlashCo.Helicopter
	if not IsValid(heli) then
		return
	end

	local delay = math.sqrt(heli:GetPos():Distance(Vector(SlashCo.CurRound.HelicopterSpawnPosition[1],
			SlashCo.CurRound.HelicopterSpawnPosition[2], SlashCo.CurRound.HelicopterSpawnPosition[3]))) / 5

	timer.Simple(delay, function()
		if not IsValid(heli) then
			return
		end

		SlashCo.QuietHeli()
		timer.Simple(0.05, function()
			SlashCo.QuietHeli()
			SlashCo.RemoveHelicopter()

			net.Start("mantislashco_MapAmbientPlay")
			net.Broadcast()
		end)
	end)
end

function SlashCo.UpdateHelicopterSeek(pos)
	SlashCo.CurRound.HelicopterTargetPosition = pos
end

function SlashCo.RemoveHelicopter()
	local ent = SlashCo.Helicopter
	if IsValid(ent) then
		ent:Remove()
	end
end

function SlashCo.QuietHeli()
	if IsValid(SlashCo.Helicopter) then
		SlashCo.Helicopter:QuietHeli()
	end
end

function SlashCo.RadialTester(ent, dist, secondary)
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

function SlashCo.ClearDatabase()
	if SERVER then
		print("[SlashCo] Clearing Database. . .")

		sql.Query("DROP TABLE slashco_table_basedata;")
		sql.Query("DROP TABLE slashco_table_survivordata;")
		sql.Query("DROP TABLE slashco_table_slasherdata;")
	end
end
