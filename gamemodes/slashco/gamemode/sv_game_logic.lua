SlashCo = SlashCo or {}

SlashCo.LoadCurRoundData = function()
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
			table.insert(SlashCo.CurRound.ExpectedPlayers,
					{ steamid = sql.Query("SELECT * FROM slashco_table_slasherdata; ")[e].Slashers })
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


		--Survivors don't necessarily have to join in time, as the game can continue with at least 1.
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
					if slasher1id == "Covenant" then
						SlashCo.PresentCovenant = id
					end
					SlashCo.SelectSlasher(slasher1id, id)
					table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { s_id = id, slasherkey = slasher1id })
				end
				if s == 2 then
					if SlashCo.PresentCovenant == nil then
						SlashCo.SelectSlasher(slasher2id, id)
						table.insert(SlashCo.CurRound.SlasherData.AllSlashers,
								{ s_id = id, slasherkey = slasher2id })
					else
						table.insert(SlashCoSlashers.Covenant.PlayersToBecomePartOfCovenant, { steamid = id })
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

SlashCo.AwaitExpectedPlayers = function()
	if game.GetMap() ~= "sc_lobby" then
		if #SlashCo.CurRound.ExpectedPlayers < 2 then
			return
		end --don't start with no data

		print("[SlashCo] Now running player expectation...")

		local ExpectTrue = false
		local expected_count = 0

		for i = 1, #SlashCo.CurRound.ExpectedPlayers do
			local ex_p = player.GetBySteamID64(SlashCo.CurRound.ExpectedPlayers[i].steamid)

			for p = 1, #player.GetAll() do
				local s_p = player.GetAll()[p]

				if ex_p == s_p then
					expected_count = expected_count + 1
					print("[SlashCo] Expected player " .. expected_count .. " in!" .. "(" .. ex_p:Name() .. ")")
					break
				end
			end
		end

		if expected_count == #SlashCo.CurRound.ExpectedPlayers then
			ExpectTrue = true
		end

		if SlashCo.CurRound.AntiLoopSpawn == false and ExpectTrue == true then
			--All players that need to be in are in, begin.

			SlashCo.CurRound.AntiLoopSpawn = true
			print("[SlashCo] All players connected. Starting in 15 seconds. . .")
			SlashCo.CurRound.SlasherData.GameReadyToBegin = true
			SlashCo.RoundBeginTimer()
		end
	end
end

--				***Begin the round start timer***
SlashCo.RoundBeginTimer = function()
	timer.Create("GameStart", 15, 1, function()
		RunConsoleCommand("slashco_run_curconfig")
	end)
end

local roundEnding
SlashCo.EndRound = function()
	if g_SlashCoDebug then
		return
	end

	if roundEnding then
		return
	end
	roundEnding = true

	local delay = 20

	local survivorsWon = true
	local SurvivorCount = team.NumPlayers(TEAM_SURVIVOR)
	if SurvivorCount == 0 then
		--All Survivors are Dead

		survivorsWon = false

		if not SlashCo.CurRound.EscapeHelicopterSummoned or SlashCo.CurRound.DistressBeaconUsed then
			--Assignment Failed

			SlashCo.RoundOverScreen(3)
		else
			--Assignment Success

			SlashCo.RoundOverScreen(2)
		end
	else
		--There are living Survivors

		if SlashCo.CurRound.DistressBeaconUsed then
			--Premature Win Distress Beacon

			if #SlashCo.CurRound.HelicopterRescuedPlayers > 0 then
				--The Last survivor got to the helicopter

				SlashCo.RoundOverScreen(4)
			else
				--Emergency rescue came and went, normal loss

				SlashCo.RoundOverScreen(3)
			end
		else
			--Normal Win

			if #SlashCo.CurRound.SlasherData.AllSurvivors >= SurvivorCount and SurvivorCount <= #SlashCo.CurRound.HelicopterRescuedPlayers then
				--Everyone lived

				SlashCo.RoundOverScreen(0)
			else
				--Not Everyone lived

				SlashCo.RoundOverScreen(1)
			end
		end
	end
	print("[SlashCo] Round over, returning to lobby in " .. tostring(delay) .. " seconds.")

	timer.Simple(delay, function()
		SlashCo.RemoveHelicopter()

		if #SlashCo.CurRound.HelicopterRescuedPlayers > 0 then
			--Add to stats of the remaining survivors' wins.
			for _, v in ipairs(SlashCo.CurRound.HelicopterRescuedPlayers) do
				local plyID = v:SteamID64()

				SlashCoDatabase.UpdateStats(plyID, "SurvivorRoundsWon", 1)
				SlashCo.PlayerData[plyID].PointsTotal = SlashCo.PlayerData[plyID].PointsTotal + 25
			end
		end

		for _, v in ipairs(SlashCo.CurRound.SlasherData.AllSurvivors) do
			local man = v.id

			if IsValid(player.GetBySteamID64(man)) then
				SlashCoDatabase.UpdateStats(man, "Points", SlashCo.PlayerData[man].PointsTotal)
			end
		end

		local survivors = team.GetPlayers(TEAM_SURVIVOR)
		for i = 1, #survivors do
			survivors[i]:SetTeam(TEAM_SPECTATOR)
			survivors[i]:Spawn()
		end
		local slashers = team.GetPlayers(TEAM_SLASHER)
		for i = 1, #slashers do
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

function SlashCo.RoundHeadstart()
	if #SlashCo.CurRound.SlasherData.AllSurvivors > (SlashCo.MAXPLAYERS - 2) then
		return
	end

	local gens = ents.FindByClass("sc_generator")
	if table.IsEmpty(gens) then
		return
	end

	--for maps with smaller gas-per-can amounts, this can sometimes select generators that are already full
	--not fixing this, it's intended now hehehehehehehhehe
	for _ = 1, (6 - #SlashCo.CurRound.SlasherData.AllSurvivors) do
		local random = math.random(1, #gens)
		gens[random]:ChangeCanProgress(1)
	end
end

SlashCo.SurvivorWinFinish = function()
	local delay = 16

	timer.Simple(delay, function()
		SlashCo.EndRound()
	end)
end