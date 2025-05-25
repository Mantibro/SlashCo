SlashCo = SlashCo or {}

function SlashCo.SinglePlayerSetup()
	g_SlashCoDebug = true
	SlashCo.CurRound.Difficulty = math.random(0, 3)
	SlashCo.CurRound.SurvivorData.GasCanMod = 0
	SlashCo.CurRound.OfferingData.CurrentOffering = 0

	hook.Add("PlayerInitialSpawn", "SinglePlayerSetup", function(ply)
		table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = ply:SteamID64() })
		table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = ply:SteamID64(), GameContribution = 0 })
	end)
end

function SlashCo.LoadCurRoundData()
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

		if SlashCo.CurRound.OfferingData.CurrentOffering == SCInfo.Offering.Nightmare then
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
		if game.SinglePlayer() then
			SlashCo.SinglePlayerSetup()
			return
		end

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

function SlashCo.AwaitExpectedPlayers()
	if not GameData.IsLobby then
		if not game.SinglePlayer() and #SlashCo.CurRound.ExpectedPlayers < 2 then
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
function SlashCo.RoundBeginTimer()
	local time = game.SinglePlayer() and 3 or 15
	timer.Create("GameStart", time, 1, function()
		RunConsoleCommand("slashco_run_curconfig")
	end)
end

local roundEnding
local lobbyDelay = 20 -- Time in seconds before players are returned to the lobby.
function SlashCo.EndRound()
	if g_SlashCoDebug then
		return
	end

	if roundEnding then
		return
	end
	roundEnding = true

	local survivors = team.GetPlayers(TEAM_SURVIVOR)
	for _, ply in ipairs(survivors) do
		if ply:GetNW2Bool("QuickEscape") then
			ply:AddPoints("quickescape")
		end

		if ply:GetNW2Bool("SlowEscape") then
			ply:AddPoints("slowescape")
		end
	end

	local SurvivorCount = #survivors
	local heliCount = #SlashCo.CurRound.HelicopterRescuedPlayers
	if SurvivorCount == 0 then
		--All survivors are dead

		if not SlashCo.CurRound.EscapeHelicopterSummoned or SlashCo.CurRound.DistressBeaconUsed then
			--Assignment failed

			SlashCo.RoundOverScreen(SlashCo.RoundState.LOST)
		else
			--Assignment success

			SlashCo.RoundOverScreen(SlashCo.RoundState.WON_ALL_DEAD)
		end
	else
		--There are living survivors

		if SlashCo.CurRound.DistressBeaconUsed then
			--Premature Win distress beacon

			if heliCount > 0 then
				--The last survivor got to the helicopter

				SlashCo.RoundOverScreen(SlashCo.RoundState.WON_DISTRESS)
			else
				--Emergency rescue came and went, normal loss

				SlashCo.RoundOverScreen(SlashCo.RoundState.LOST)
			end
		else
			--Normal win

			if heliCount >= #SlashCo.CurRound.SlasherData.AllSurvivors then
				--Everyone lived

				SlashCo.RoundOverScreen(SlashCo.RoundState.WON_ALL_ALIVE)
			else
				--Not everyone lived

				SlashCo.RoundOverScreen(SlashCo.RoundState.WON_SOME_DEAD)
			end
		end
	end

	local winners = {}
	if heliCount > 0 then
		--Add to stats of the remaining survivors' wins
		for _, v in ipairs(SlashCo.CurRound.HelicopterRescuedPlayers) do
			if not IsValid(v) then continue end

			SlashCoDatabase.UpdateStats(v:SteamID64(), "SurvivorRoundsWon", 1)

			v:SetPoints("survive")
			winners[v:SteamID64()] = true
		end

		if heliCount == 1 and #SlashCo.CurRound.SlasherData.AllSurvivors > 1 then
			SlashCo.CurRound.HelicopterRescuedPlayers[1]:SetPoints("last_survive")
		end

		for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not winners[v:SteamID64()] then
				v:SetPoints("left_behind")
			end
		end
	end

	SlashCo.State = SlashCo.States.ENDING
	hook.Run("SlashCo:EndRound", winners)

	print("[SlashCo] Round over, returning to lobby in " .. tostring(lobbyDelay) .. " seconds.")

	timer.Simple(lobbyDelay, function()
		SlashCo.RemoveHelicopter()
		SlashCo.CommitPoints()

		local survivors = team.GetPlayers(TEAM_SURVIVOR)
		local slashers = team.GetPlayers(TEAM_SLASHER)

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
	end)
end

local winDelay = 16
function SlashCo.SurvivorWinFinish()
	timer.Simple(winDelay, function()
		SlashCo.EndRound()
	end)
end


if not GameData.IsLobby then
	timer.Create("SlashCo:WarningTime", 1, 0, function()
		local curTime = CurTime()
		local timePassed = curTime - GetGlobal2Float("SCStartTime")
		if math.IsNearlyEqual(timePassed, SlashCo.WarningTime, 1) and (GameData.LastWarningTime or 0) < curTime then
			GameData.LastWarningTime = curTime + 5
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/time_alert.mp3",
				volume = 1,
				entity = game.GetWorld(),
				fadeIn = 0,
			})
		end
	end)

	timer.Create("SlashCo:LobbyFailSafe", 1, 0, function()
		if SlashCo.State ~= SlashCo.States.IN_GAME or g_SlashCoDebug or GameData.TriggeredLobbyFailSafe then
			return
		end

		local timePassed = CurTime() - GetGlobal2Float("SCStartTime")
		if timePassed > 300 and not SlashCo.FailSafeActivate then
			local slashers = team.GetPlayers(TEAM_SLASHER)
			if #slashers == 0 then
				print("[SlashCo] Lobby failsafe was triggered!")
				GameData.TriggeredLobbyFailSafe = true
				SlashCo.EndRound()
				return
			end

			local survivors = team.GetPlayers(TEAM_SURVIVOR)
			if #survivors == 0 then
				print("[SlashCo] Lobby failsafe was triggered!")
				GameData.TriggeredLobbyFailSafe = true
				SlashCo.EndRound()
				return
			end
		end
	end)
end