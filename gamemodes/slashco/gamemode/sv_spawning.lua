SlashCo = SlashCo or {}

---Returns the map's settings entity
function SlashCo.SettingsEntity()
	local ent = ents.FindByClass("info_sc_settings")[1]
	if ent then
		function SlashCo.SettingsEntity()
			return ent
		end
	end
	return ent
end

---abort the game if there is a technical issue
function SlashCo.Abort(reason)
	for _, v in ipairs(player.GetAll()) do
		v:ChatPrint("Aborting round: " .. reason)
	end

	if not SlashCo.Aborts then
		SlashCo.RoundOverScreen(5)
		timer.Create("SlashCoAbort", 5, 1, function()
			SlashCo.GoToLobby()
		end)
	end

	SlashCo.Aborts = (SlashCo.Aborts or 0) + 1
end

---Default set of conditions for weighted tables
function SlashCo.DefaultConditions(ent)
	return IsValid(ent) and not ent.Disabled and not IsValid(ent.SpawnedEntity)
end

---Assemble a table for use in the spawning functions. The elements variable should be a sequential table, and the
---conditions variable is an optional function to determine whether each entry in the table should pass.
---Returns the weighted table
function SlashCo.AssembleWeightedTable(elements, conditions)
	conditions = conditions or SlashCo.DefaultConditions
	local weightedTable = {}
	for _, v in ipairs(elements) do
		if conditions(v) then
			weightedTable[v] = v.Weight or 10
		end
	end
	return weightedTable
end

---Returns a random number within the range of a weighted table
function SlashCo.GetWeightedRandom(table)
	local total = 0
	for _, v in pairs(table) do
		total = total + v
	end
	return math.random(0, total)
end

---Selects a number of spawns from a sequential table of them
---Returns a single element if amount == 1 or is undefined
---Returns a table of elements and the number of missed entries if amount > 1
---Returns nothing is amount <= 0
function SlashCo.SelectSpawnsNoForce(elements, amount, conditions, forceTable)
	amount = amount or 1
	if amount <= 0 then
		if forceTable then
			return {}, 0
		end
		return
	end

	local weightedTable = SlashCo.AssembleWeightedTable(elements, conditions)
	local selected = {}
	local missed = amount
	for i = 1, amount do
		if table.IsEmpty(weightedTable) then
			break
		end

		local random = SlashCo.GetWeightedRandom(weightedTable)
		for k, v in pairs(weightedTable) do
			random = random - v
			if random <= 0 then
				table.insert(selected, k)
				weightedTable[k] = nil
				missed = missed - 1
				break
			end
		end
	end

	if amount == 1 and not forceTable then
		return selected[1]
	else
		return selected, missed
	end
end

---Default set of conditions for weighted tables
function SlashCo.DefaultConditionsForced(ent)
	return SlashCo.DefaultConditions(ent) and ent.Forced
end
function SlashCo.DefaultConditionsNonForced(ent)
	return SlashCo.DefaultConditions(ent) and not ent.Forced
end

---Selects a number of spawns from a sequential table of them, with priority for forced spawns
function SlashCo.SelectSpawns(elements, amount, conditionsForced, conditionsNonForced, forceTable)
	conditionsForced = conditionsForced or SlashCo.DefaultConditionsForced
	conditionsNonForced = conditionsNonForced or SlashCo.DefaultConditionsNonForced
	local entries, missed = SlashCo.SelectSpawnsNoForce(elements, amount, conditionsForced, forceTable)
	if missed then
		local entriesToAdd
		entriesToAdd, missed = SlashCo.SelectSpawnsNoForce(elements, missed, conditionsNonForced, true)
		table.Add(entries, entriesToAdd)
	elseif (not amount or amount == 1) and not IsValid(entries) then
		entries, missed = SlashCo.SelectSpawnsNoForce(elements, amount, conditionsNonForced, forceTable)
	end

	return entries, missed
end

---Activate a list of spawn points
function SlashCo.Spawn(elements, spawnFunc)
	for _, v in ipairs(elements) do
		if v.SpawnEnt then
			if spawnFunc then
				spawnFunc(v)
			end
			v:SpawnEnt()
		end
	end
end

local function genCondForced(ent)
	return SlashCo.DefaultConditionsForced(ent) and ent.BatterySpawns
end
local function genCondNonForced(ent)
	return SlashCo.DefaultConditionsNonForced(ent) and ent.BatterySpawns
end

---Spawn generators for the round
function SlashCo.SpawnGenerators()
	local gensToSpawn = SlashCo.SelectSpawns(ents.FindByClass("info_sc_generator"),
			GetGlobal2Int("SlashCoGeneratorsToSpawn", SlashCo.Generators), genCondForced, genCondNonForced, true)

	if table.IsEmpty(gensToSpawn) then
		SlashCo.Abort("Missing generator spawn entities")
		return
	end

	for _, v in pairs(gensToSpawn) do
		local spawn = SlashCo.SelectSpawns(table.GetKeys(v.BatterySpawns))
		spawn:SpawnEnt()
	end

	SlashCo.Spawn(gensToSpawn)
end

---Auto-fills some gas cans at the start of the round if there are too few players
local function roundHeadstart()
	if #SlashCo.CurRound.SlasherData.AllSurvivors > (SlashCo.MAXPLAYERS - 2) then
		return
	end

	local gens = ents.FindByClass("sc_generator")
	if table.IsEmpty(gens) then
		return
	end

	local cans = 5 - #SlashCo.CurRound.SlasherData.AllSurvivors
	if cans < 0 then
		return
	end

	local fuelled = 0
	for _ = 1, cans do
		local random = math.random(1, #gens)
		if not gens[random]:ChangeCanProgress(1) then
			fuelled = fuelled + 1
		end
	end

	SlashCo.HeadStartCans = fuelled
end

---Spawn gas cans for the round
function SlashCo.SpawnGasCans()
	local gasCanCount = GetGlobal2Int("SlashCoGasCansToSpawn", -1)
	local cansPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
	local gens = GetGlobal2Int("SlashCoGeneratorsToSpawn", SlashCo.Generators)

	-- base count is for compatibility with older configs
	local baseCount = SlashCo.BaseCans or (cansPerGen * gens)
	if baseCount < 0 then
		baseCount = cansPerGen * gens
	end

	-- auto-determine unmodified can count
	if gasCanCount < 0 then
		gasCanCount = baseCount + SlashCo.MapSize
	end

	for _, p in ipairs(SlashCo.CurRound.SlashersToBeSpawned) do
		gasCanCount = gasCanCount + p:SlasherValue("GasCanMod", 0)
	end

	local diffMod = 3 - SlashCo.CurRound.Difficulty
	local offeringMod = SlashCo.CurRound.OfferingData.GasCanMod
	local headStartMod = -(SlashCo.HeadStartCans or 0)
	local survivorMod = -SlashCo.CurRound.SurvivorData.GasCanMod
	gasCanCount = math.max(gasCanCount + offeringMod + headStartMod + survivorMod + diffMod, SlashCo.MapSize)

	local gasCanSpawns
	if SlashCo.CurRound.OfferingData.CurrentOffering == 1 then
		gasCanCount = math.min(gasCanCount, baseCount)
		gasCanSpawns = ents.FindByClass("info_sc_gascanexposed")
	else
		gasCanSpawns = ents.FindByClass("info_sc_gascan")
		for _, v in ipairs(ents.FindByClass("info_sc_item")) do
			if v.IsGasCanSpawn then
				table.insert(gasCanSpawns, v)
			end
		end
	end

	local gasCansToSpawn = SlashCo.SelectSpawns(gasCanSpawns, gasCanCount, nil, nil, true)

	if table.IsEmpty(gasCansToSpawn) then
		SlashCo.Abort("Missing gas can spawn entities")
		return
	end

	SlashCo.Spawn(gasCansToSpawn, function(ent)
		ent.Item = "GasCan"
	end)
end

local function itemCondForced(ent)
	return SlashCo.DefaultConditionsForced(ent) and (not ent.Item or not SlashCoItems[ent.Item])
end
local function itemCondNonForced(ent)
	return SlashCo.DefaultConditionsNonForced(ent) and (not ent.Item or not SlashCoItems[ent.Item])
end

---Spawn items for the round
function SlashCo.SpawnItems()
	--Replace world props.
	local replaceableItems = {}
	for k, v in pairs(SlashCoItems) do
		if v.ReplacesWorldProps then
			replaceableItems[v.Model] = k
		end
	end
	for _, v in ipairs(ents.FindByClass("prop_physics")) do
		local item = replaceableItems[v:GetModel()]
		if item then
			local it_pos = v:GetPos()
			local it_ang = v:GetAngles()
			local droppedItem = SlashCo.CreateItem(SlashCoItems[item].EntClass, it_pos, it_ang)
			SlashCo.CurRound.Items[droppedItem] = true
			Entity(droppedItem):SetCollisionGroup(COLLISION_GROUP_NONE)
			v:Remove()
		end
	end

	if table.IsEmpty(ents.FindByClass("info_sc_item")) then
		SlashCo.Abort("Missing item spawn entities")
		return
	end

	--item count for demons
	SlashCo.CurRound.ItemCount = SlashCo.CurRound.ItemCount + SlashCo.CurRound.OfferingData.ItemMod + SlashCo.CurRound.Difficulty
	for _, p in ipairs(SlashCo.CurRound.SlashersToBeSpawned) do
		local item = p:SlasherValue("ItemToSpawn")

		if item then
			local items = SlashCo.SelectSpawns(ents.FindByClass("info_sc_item"), SlashCo.CurRound.ItemCount,
					itemCondForced, itemCondNonForced, true)

			SlashCo.Spawn(items, function(ent)
				ent.Item = item
			end)
		end

		p:SlasherFunction("OnItemSpawn", SlashCo.CurRound.ItemCount)
	end

	local beacon = SlashCo.SelectSpawns(ents.FindByClass("info_sc_item"), 1, itemCondForced, itemCondNonForced)
	beacon.Item = "Beacon"
	beacon:SpawnEnt()

	--item count for everything else
	local randomItemCount = SlashCo.MAXPLAYERS + 1 - math.floor((SlashCo.CurRound.Difficulty + 1) / 2) - #SlashCo.CurRound.SlasherData.AllSurvivors
	local items = SlashCo.SelectSpawns(ents.FindByClass("info_sc_item"), randomItemCount,
			nil, nil, true)

	SlashCo.Spawn(items)
end

---Set up the helicopter globals
function SlashCo.SetHelicopterPositions()
	local intro = ents.FindByClass("info_sc_helicopter_intro")[1]
	local spawn = ents.FindByClass("info_sc_helicopter_start")[1]

	SlashCo.CurRound.HelicopterIntroPosition = vector_origin
	SlashCo.CurRound.HelicopterIntroAngle = angle_zero
	SlashCo.CurRound.HelicopterSpawnPosition = vector_origin

	if not IsValid(intro) then
		SlashCo.Abort("Missing helicopter intro entity")
		return
	end
	if not IsValid(spawn) then
		SlashCo.Abort("Missing helicopter start entity")
		return
	end

	--vectors are dropped a little to make the hammer model more accurate
	SlashCo.CurRound.HelicopterIntroPosition = intro:GetPos() - Vector(0, 0, 70)
	SlashCo.CurRound.HelicopterIntroAngle = intro:GetAngles()
	SlashCo.CurRound.HelicopterSpawnPosition = spawn:GetPos() - Vector(0, 0, 70)
end

local slasherSpawned

function SlashCo.SpawnSlasher()
	if slasherSpawned then
		return
	end

	for _, p in ipairs(SlashCo.CurRound.SlashersToBeSpawned) do
		p:SetTeam(TEAM_SLASHER)
		p:Spawn()

		SlashCo.OnSlasherSpawned(p)
	end

	slasherSpawned = true
end

---Set up players for the round
function SlashCo.SetupPlayers()
	if not sql.TableExists("slashco_table_basedata") or not sql.TableExists("slashco_table_survivordata")
			or not sql.TableExists("slashco_table_slasherdata") then

		SlashCo.Abort("Missing SQL table data")
		return
	end

	timer.Simple(0.25, function()
		print("[SlashCo] Now proceeding with Spawns...")
		SlashCo.PrepareSlasherForSpawning()
	end)

	print("[SlashCo] Teams database loaded...")

	local survivors = sql.Query("SELECT * FROM slashco_table_survivordata; ")
	local slashers = sql.Query("SELECT * FROM slashco_table_slasherdata; ")
	local becameCovenant = 0
	local spawn_queue = 0

	for play = 1, #player.GetAll() do
		--Assign the teams for the current round

		local playercur = player.GetAll()[play]
		local id = playercur:SteamID64()

		print("name: " .. playercur:Name())

		--Nightmare offering >>>>>>>>>>>>>>>>>>>>>

		if SlashCo.CurRound.OfferingData.CurrentOffering == 6 then
			for i = 1, #slashers do
				--Slasher becomes the sole survivor
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
					continue
				end
				if slashers[2] ~= nil and id == slashers[2].Slashers then
					continue
				end

				for k = 1, #survivors do
					if id == survivors[k].Survivors then
						continue
					end
				end

				playercur:SetTeam(TEAM_SPECTATOR)
				playercur:Spawn()
				print(playercur:Name() .. " now Spectator")
				spawn_queue = spawn_queue + 1

				if SlashCo.PresentCovenant == nil and becameCovenant < 3 then
					table.insert(SlashCoSlashers.Covenant.PlayersToBecomePartOfCovenant, { steamid = id })
					becameCovenant = becameCovenant + 1
				end
			end
		end

		for i = 1, #slashers do
			if id == slashers[i].Slashers then
				for _, v in ipairs(SlashCoSlashers.Covenant.PlayersToBecomePartOfCovenant) do
					if v.steamid == id then
						print(playercur:Name() .. " will become part of the Covenant.")
						playercur:SetTeam(TEAM_SPECTATOR)
						playercur:Spawn()
						spawn_queue = spawn_queue + 1
						goto covenant_member
					end
				end
				print(playercur:Name() .. " now Slasher (Memorized)")
				playercur:SetTeam(TEAM_SPECTATOR)
				playercur:Spawn()
				spawn_queue = spawn_queue + 1

				table.insert(SlashCo.CurRound.SlashersToBeSpawned, playercur)

				--table.insert(SlashCo.CurRound.SlasherData.AllSlashers, {s_id = playercur:SteamID64()})
				:: covenant_member ::
			end
		end
		:: NIGHTMARE_SKIPPART ::
	end
	:: NIGHTMARE_SKIPALL ::
end

local function makeEnt(class, config)
	if not istable(config.pos) then
		return
	end

	local ent = ents.Create(class)
	ent:SetPos(Vector(unpack(config.pos)))

	if isnumber(config.ang) then
		ent:SetAngles(Angle(0, config.ang, 0))
	elseif istable(config.ang) then
		ent:SetAngles(Angle(config.ang[1], config.ang[2], config.ang[3]))
	else
		ent:SetAngles(angle_zero)
	end

	if isnumber(config.Weight) then
		ent.Weight = config.Weight
	end

	if config.Forced then
		ent.Forced = true
	end

	ent:Spawn()

	return ent
end

local function convertLegacyConfig(name, skip)
	local config = util.JSONToTable(file.Read("slashco/configs/maps/" .. name, "LUA"))

	if not istable(config) then
		print(string.format("Aborting the legacy config for %s due to being invalid", name))
		return
	end

	if config.DoNotUseThisConfig then
		return
	end

	if skip and not config.AlwaysAddLegacySettings then
		return
	end

	if istable(config.Spawnpoints) then
		if istable(config.Spawnpoints.Slasher) then
			for _, v in ipairs(config.Spawnpoints.Slasher) do
				makeEnt("info_sc_player_slasher", v)
			end
		end
		if istable(config.Spawnpoints.Survivor) then
			for _, v in ipairs(config.Spawnpoints.Survivor) do
				makeEnt("info_sc_player_employee", v)
			end
		end
	end

	local gens = {}
	if istable(config.Generators) then
		if isnumber(config.Generators.Count) then
			SetGlobal2Int("SlashCoGeneratorsToSpawn", config.Generators.Count)
		end

		if isnumber(config.Generators.Needed) then
			SetGlobal2Int("SlashCoGeneratorsNeeded", config.Generators.Needed)
		end

		if istable(config.Generators.Spawnpoints) then
			for k, v in ipairs(config.Generators.Spawnpoints) do
				local ent = makeEnt("info_sc_generator", v)

				if IsValid(ent) then
					gens[k] = ent
				end
			end
		end
	end
	if istable(config.Helicopter) then
		if istable(config.Helicopter.IntroLocation) then
			config.Helicopter.IntroLocation.pos[3] = config.Helicopter.IntroLocation.pos[3] + 70
			makeEnt("info_sc_helicopter_intro", config.Helicopter.IntroLocation)
		end

		if istable(config.Helicopter.StartLocation) then
			makeEnt("info_sc_helicopter_start", config.Helicopter.StartLocation)
		end

		if istable(config.Helicopter.Spawnpoints) then
			for _, v in ipairs(config.Helicopter.Spawnpoints) do
				v.pos[3] = v.pos[3] + 70
				makeEnt("info_sc_helicopter", v)
			end
		end
	end
	if istable(config.GasCans) then
		if config.GasCans.CountIsDirect and isnumber(config.GasCans.Count) then
			SetGlobal2Int("SlashCoGasCansToSpawn", config.GasCans.Count)
		else
			SlashCo.BaseCans = config.GasCans.Count
		end

		if isnumber(config.GasCans.NeededPerGenerator) then
			SetGlobal2Int("SlashCoGasCansPerGenerator", config.GasCans.NeededPerGenerator)
		end

		if istable(config.GasCans.Spawnpoints) then
			for _, v in ipairs(config.GasCans.Spawnpoints) do
				makeEnt("info_sc_gascan", v)
			end
		end
	end
	if istable(config.Items) and istable(config.Items.Spawnpoints) then
		for _, v in ipairs(config.Items.Spawnpoints) do
			local ent = makeEnt("info_sc_item", v)

			if config.Items.IncludeGasCanSpawns and IsValid(ent) then
				ent.IsGasCanSpawn = true
			end
		end
	end
	if istable(config.Batteries) and istable(config.Batteries.Spawnpoints) then
		for k, v in ipairs(config.Batteries.Spawnpoints) do
			if not istable(v) then
				continue
			end

			for _, v1 in ipairs(v) do
				local ent = makeEnt("info_sc_battery", v1)
				ent.Generators = { gens[k] }

				if IsValid(ent) and gens[k] then
					gens[k].BatterySpawns = gens[k].BatterySpawns or {}
					gens[k].BatterySpawns[ent] = true
				end
			end
		end
	end
	if istable(config.Offerings) and istable(config.Offerings.Exposure) and istable(config.Offerings.Exposure.Spawnpoints) then
		for _, v in ipairs(config.Offerings.Exposure.Spawnpoints) do
			makeEnt("info_sc_gascanexposed", v)
		end
	end
end

---Add spawning entities from the legacy config if it exists
function SlashCo.LegacySetup()
	local configs, configDirs = file.Find(string.format("slashco/configs/maps/%s.lua", game.GetMap()), "LUA")
	local skip = IsValid(SlashCo.SettingsEntity())
	for _, v in ipairs(configs) do
		convertLegacyConfig(v, skip)
	end

	for _, v in ipairs(configDirs) do
		for _, v1 in ipairs(v) do
			convertLegacyConfig(v1, skip)
		end
	end
end

hook.Add("InitPostEntity", "LegacySetupSpawns", SlashCo.LegacySetup)

---main body of round starting function
local function startRound(noSetup)
	SlashCo.RoundStarted = true
	GAMEMODE.State = GAMEMODE.States.IN_GAME
	SlashCo.CurRound.GameProgress = 0

	SetGlobalFloat("SCStartTime", CurTime())
	timer.Simple(SlashCo.GhostPingDelay, function()
		SetGlobalBool("SpectatorsCanPing", true)
		for _, v in ipairs(team.GetPlayers(TEAM_SPECTATOR)) do
			v:ChatText("spectators_can_ping")
		end
	end)

	if SlashCo.CurRound.OfferingData.CurrentOffering == 2 then
		SlashCo.CurRound.OfferingData.ItemMod = -2
	end
	if SlashCo.CurRound.OfferingData.CurrentOffering == 2 then
		SlashCo.CurRound.OfferingData.SatO = 1
		SetGlobalInt("SatO", 1)
	end
	if SlashCo.CurRound.OfferingData.CurrentOffering == 4 then
		SlashCo.CurRound.OfferingData.DO = true
	end
	if SlashCo.CurRound.OfferingData.CurrentOffering == 5 then
		SlashCo.CurRound.OfferingData.SO = 1
	end

	if not noSetup then
		SlashCo.SetupPlayers()
	end

	SlashCo.SpawnGenerators()

	if SlashCo.CurRound.OfferingData.CurrentOffering ~= 6 then
		roundHeadstart()
	end

	SlashCo.SpawnGasCans()
	SlashCo.SpawnItems()

	SlashCo.SetHelicopterPositions()
	SlashCo.UpdateHelicopterSeek(SlashCo.CurRound.HelicopterIntroPosition)
	SlashCo.CreateHelicopter(SlashCo.CurRound.HelicopterIntroPosition, SlashCo.CurRound.HelicopterIntroAngle)
	SlashCo.BroadcastCurrentRoundData(true)

	timer.Simple(8, function()
		SlashCo.HelicopterTakeOffIntro()

		if not g_SlashCoDebug then
			SlashCo.ClearDatabase()
		end --Everything was loaded, clear the database.
	end)

	timer.Simple(math.random(2, 4), function()
		SlashCo.HelicopterRadioVoice(1)
		SlashCo.CurRound.roundOverToggle = true
	end)

	if SlashCo.CurRound.OfferingData.CurrentOffering == 6 then
		timer.Simple(240, function()
			if not SlashCo.SummonEscapeHelicopter() then
				SlashCo.CurRound.DistressBeaconUsed = false
			end
		end)
	end

	local settingsEnt = SlashCo.SettingsEntity()
	if settingsEnt then
		settingsEnt:TriggerOutput("OnRoundStarted", settingsEnt, settingsEnt, #SlashCo.CurRound.ExpectedPlayers)
	end
	table.Empty(SlashCo.CurRound.ExpectedPlayers)

	SlashCo.UpdateObjective("generator", SlashCo.ObjStatus.INCOMPLETE, GetGlobal2Int("SlashCoGeneratorsNeeded", SlashCo.GensNeeded))
	SlashCo.SendObjectives()
end

---start a round
function SlashCo.StartRound(noSetup)
	if game.GetMap() == "sc_lobby" then
		return
	end

	--reseed for better le random
	math.randomseed(RealTime())

	SlashCo.RemoveAllCurRoundEnts()

	local settingsEnt = SlashCo.SettingsEntity()
	if settingsEnt then
		settingsEnt:TriggerOutput("OnPreRoundStarted", settingsEnt, settingsEnt, #SlashCo.CurRound.ExpectedPlayers)
	end

	timer.Simple(0.5, function()
		startRound(noSetup)
	end)
end

hook.Add("PlayerSelectSpawn", "RandomSpawn", function(ply, transition)
	if transition then
		return
	end

	local elements
	if ply:Team() == TEAM_SURVIVOR then
		elements = ents.FindByClass("info_sc_player_employee")
		table.Add(elements, ents.FindByClass("info_sc_player_survivor"))
	elseif ply:Team() == TEAM_SLASHER then
		elements = ents.FindByClass("info_sc_player_slasher")
	end

	if elements and not table.IsEmpty(elements) then
		local ent = SlashCo.SelectSpawns(elements)
		if not IsValid(ent) then
			return
		end
		ent.SpawnedEntity = ply
		ent:SpawnEnt()
		return ent
	end
end)