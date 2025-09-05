SlashCo = SlashCo or {}

function SlashCo.SinglePlayerSetup()
	g_SlashCoDebug = true
	SlashCo.CurRound.Difficulty = math.random(0, 3)
	SlashCo.CurRound.SurvivorData.GasCanMod = 0
	SlashCo.CurRound.OfferingData.CurrentOffering = 0

	hook.Add("PlayerInitialSpawn", "SinglePlayerSetup", function(ply)
		table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = ply:SteamID64() })
		table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = ply:SteamID64() })
	end)
end

function SlashCo.LoadCurRoundData()
	table.Empty(SlashCo.CurRound.ExpectedPlayers)
	if sql.TableExists("slashco_table_basedata") and sql.TableExists("slashco_table_survivordata") and sql.TableExists("slashco_table_slasherdata") then
		--Load relevant data from the database
		local baseData = sql.Query("SELECT * FROM slashco_table_basedata; ")[1]
		local diff = baseData.Difficulty
		local offering = baseData.Offering
		local slasher1id = baseData.SlasherIDPrimary
		local slasher2id = baseData.SlasherIDSecondary
		local survivorgasmod = baseData.SurviorGasMod
		local slasherDanger = baseData.SlasherDanger
		local slasherClass = baseData.SlasherClass
		local slasherID = baseData.SlasherID

		print("[SlashCo] RoundData Loaded with Difficulty of: " .. diff .. ", Offering of: " .. offering .. " and GasMod of: " .. survivorgasmod)

		--Transfer loaded data into the main table
		SlashCo.CurRound.Difficulty = tonumber(diff)
		SlashCo.CurRound.SurvivorData.GasCanMod = survivorgasmod
		SlashCo.CurRound.OfferingData.CurrentOffering = tonumber(offering)
		if SlashCo.CurRound.OfferingData.CurrentOffering > 0 then
			SlashCo.CurRound.OfferingData.OfferingName = SCInfo.Offering[SlashCo.CurRound.OfferingData.CurrentOffering].Name
		end
		SlashCo.CurRound.SlasherDanger = tonumber(slasherDanger)
		SlashCo.CurRound.SlasherClass = tonumber(slasherClass)
		SlashCo.CurRound.SlasherID = tonumber(slasherID)
		SlashCo.CurRound.FirstSelectedSlasherID = slasher1id

		--First we insert the Slasher. If the Slasher does not join in time the game cannot begin.

		--Insert the First and second Slasher into the table
		local slasherData = sql.Query("SELECT * FROM slashco_table_slasherdata;") or {}
		for e = 1, #slasherData do
			table.insert(SlashCo.CurRound.ExpectedPlayers, {steamid = slasherData[e].Slashers})
		end

		SlashCo.CurRound.ForceSlasherSelection = #slasherData == 0

		SlashCo.SetupExpectedPlayersFailsafe()

		--Nightmare offering >>>>>>>>>>>>>>>>>>>>>

		local survivorData = sql.Query("SELECT * FROM slashco_table_survivordata;") or {}
		if SlashCo.CurRound.OfferingData.CurrentOffering == SCInfo.Offering.Nightmare then
			--All survivors will become slashers.

			local query = survivorData
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

			for s = 1, #slasherData do
				local sr_id = slasherData[s].Slashers

				--table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = sr_id })
				--For the slasher's clientside view also
				table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = sr_id })
			end

			return
		end

		--Nightmare offering >>>>>>>>>>>>>>>>>>>>>>>>


		--Survivors don't necessarily have to join in time, as the game can continue with at least 1.
		--TODO: timer which starts the game premature if some survivors don't join in time.

		local query = survivorData
		for i = 1, #query do
			if query[i].Survivors ~= nil then
				--Survivors due to connect

				local steamid = query[i].Survivors
				table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = steamid })
				--For the slasher's clientside view also
				table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = steamid })
			end
		end

		for s = 1, #slasherData do
			local id = slasherData[s].Slashers
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

local function StartRound(instant)
	if SlashCo.CurRound.AntiLoopSpawn then return end

	SlashCo.AudioSystem.DisableBackgroundMusic()
	print("[SlashCo] All players connected. " .. (instant and "Starting now" or "Starting in 10 seconds") .. ". . .")
	SlashCo.CurRound.SlasherData.GameReadyToBegin = true
	SlashCo.RoundBeginTimer(instant)
end

function AskPlayersToBecomeSlasher()
	if SlashCo.CurRound.AntiLoopSpawn then return end

	SlashCo.AudioSystem.EnableBackgroundMusic()
	SlashCo.AudioSystem.SetBackgroundMusic("slashco/ambienttrack/mf_high.ogg", 1)

	local timeToAsk = 15 -- How many seconds they have to decide
	net.Start("SlashCo:AskToBecomeSlasher")
		net.WriteUInt(timeToAsk, 8)
	net.Broadcast()

	local becomeSlasher = {}
	net.Receive("SlashCo:AskToBecomeSlasher", function(_, ply)
		if net.ReadBool() then
			table.insert(becomeSlasher, ply)
		end
	end)

	timer.Create("SlashCo:AskToBecomeSlasherTimeLimit", timeToAsk, 1, function()
		if SlashCo.CurRound.AntiLoopSpawn then return end
		for idx, ply in ipairs(becomeSlasher) do
			if not IsValid(ply) then
				table.remove(becomeSlasher, idx)
				continue
			end
		end
	
		local slasherSelection
		local function RunSlasherSelection()
			local selectedPlyIndex = math.random(#becomeSlasher)
			local selectedPly = becomeSlasher[math.random(#becomeSlasher)]
			if not IsValid(selectedPly) then
				if SlashCo.CurRound.AntiLoopSpawn then return end
				SlashCo.Abort("No one wanted to become the slasher... Well GG")
				return
			end

			SlashCo.AwaitPlayerToSelectSlasher = function(ply, id) -- if id is nil, then they tried to select a banned slasher or they took too long!
				SlashCo.AwaitPlayerToSelectSlasher = nil
				if SlashCo.CurRound.AntiLoopSpawn then return end
				sql.Query("INSERT INTO slashco_table_slasherdata( Slashers ) VALUES( " .. ply:SteamID64() .. " );")
				SlashCo.SelectSlasher(id or SlashCo.CurRound.FirstSelectedSlasherID, ply:SteamID64())
				StartRound(true)
			end

			if string.len(SlashCo.CurRound.SlasherID or "") > 2 then
				SlashCo.AwaitPlayerToSelectSlasher(selectedPly, SlashCo.CurRound.SlasherID)
				return
			end

			net.Start("mantislashco_PickingSlasher")
				net.WriteTable({
					slashersteamid = selectedPly:SteamID64(),
					slashClass = SlashCo.CurRound.SlasherClass,
					slashDanger = SlashCo.CurRound.SlasherDanger,
					bannedSlashers = SlashCo.GetBannedSlashers(true),
				})
			net.Send(selectedPly)

			timer.Create("SlashCo:WaitingForPlayerToPickSlasher", 15, 1, function()
				if SlashCo.CurRound.AntiLoopSpawn then return end
				if not IsValid(selectedPly) then
					table.remove(becomeSlasher, selectedPlyIndex)
					slasherSelection() -- Run the selection again since our selected player disconnected when he was supposed to become the slasher.
					return
				end

				if SlashCo.AwaitPlayerToSelectSlasher then
					SlashCo.AwaitPlayerToSelectSlasher(selectedPly, nil)
				end
			end)
		end
		slasherSelection = RunSlasherSelection
		RunSlasherSelection()
	end)
end

function SlashCo.ForceNewSlasherSelection()
	if SlashCo.CurRound.AntiLoopSpawn then return end
	timer.Remove("SlashCo:ExpectedPlayersFailsafe")

	if player.GetCount() < 2 then
		SlashCo.Abort("Not enouth players to start a round")
		return
	end

	local expected_count = 0
	local plys = player.GetAll()
	for _, data in ipairs(SlashCo.CurRound.ExpectedPlayers) do
		if data.disconnected then
			expected_count = expected_count + 1
			continue
		end

		for _, ply in ipairs(plys) do
			if data.steamid == ply:SteamID64() then
				expected_count = expected_count + 1
				print("[SlashCo] Expected player " .. expected_count .. " in!" .. "(" .. ply:Name() .. ")")
				break
			end
		end
	end

	local foundSlasher = false
	local slashers = SQLTableToLuaTable(sql.Query("SELECT * FROM slashco_table_slasherdata; ") or {}, "Slashers") or {}
	for _, ply in ipairs(plys) do
		if slashers[ply:SteamID64()] then
			foundSlasher = true
			break
		end
	end

	if not foundSlasher then
		print("[SlashCo] Missing a slasher to start with! Time to ask the others.")
		AskPlayersToBecomeSlasher()
	else
		print("[SlashCo] Force starting the round since it took too long for players to connect.")
		StartRound(true)
	end
end

function SlashCo.SetupExpectedPlayersFailsafe()
	SlashCo.AudioSystem.EnableBackgroundMusic()
	SlashCo.AudioSystem.SetBackgroundMusic("slashco/ambienttrack/mf_mid.ogg", 1)

	SlashCo.CurRound.DisconnectedPlayers = {}
	timer.Create("SlashCo:ExpectedPlayersFailsafe", 90, 1, SlashCo.ForceNewSlasherSelection)

	gameevent.Listen("player_disconnect")
	hook.Add("player_disconnect", "SlashCo:OnPlayerDisconnect", function(data)
		if SlashCo.CurRound.AntiLoopSpawn then return end

		local steamID64 = util.SteamIDTo64(data.networkid)
		for idx, data in ipairs(SlashCo.CurRound.ExpectedPlayers) do
			if data.steamid == steamID64 then
				print("[SlashCo] One of our expected players disconnected! Marking as disconnected...")
				data.disconnected = true
				SlashCo.AwaitExpectedPlayers()
				break
			end
		end
	end)
end

function SlashCo.AwaitExpectedPlayers()
	if GameData.IsLobby then return end
	if SlashCo.CurRound.AntiLoopSpawn then return end
	if not game.SinglePlayer() and #SlashCo.CurRound.ExpectedPlayers < 2 then
		return
	end -- don't start with no data

	print("[SlashCo] Now running player expectation...")

	local expected_count = 0
	local plys = player.GetAll()
	for _, data in ipairs(SlashCo.CurRound.ExpectedPlayers) do
		if data.disconnected then
			expected_count = expected_count + 1
			continue
		end

		for _, ply in ipairs(plys) do
			if data.steamid == ply:SteamID64() then
				expected_count = expected_count + 1
				print("[SlashCo] Expected player " .. expected_count .. " in!" .. "(" .. ply:Name() .. ")")
				break
			end
		end
	end

	if expected_count == #SlashCo.CurRound.ExpectedPlayers then
		if #plys < 2 then
			SlashCo.Abort("Not enouth players to start a round")
			return
		end

		if SlashCo.CurRound.ForceSlasherSelection then
			SlashCo.ForceNewSlasherSelection()
			return
		end

		--All players that need to be in are in, begin.
		StartRound(false)
	end
end

--				***Begin the round start timer***
function SlashCo.RoundBeginTimer(instant)
	local time = game.SinglePlayer() and 3 or 10
	SlashCo.CurRound.AntiLoopSpawn = true
	if instant then
		SlashCo.StartRound()
	else
		timer.Create("GameStart", time, 1, function()
			SlashCo.StartRound()
		end)
	end
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
		if ply.QuickEscape then
			ply:AddPoints("quickescape")
		end

		if ply.SlowEscape then
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

	for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		SlashCo.AudioSystem.StopSound(nil, 1, slasher) -- Stop all sounds playing by the slasher.
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
	timer.Create("SlashCo:OverTime", 1, 0, function()
		local curTime = CurTime()
		local timePassed = SlashCo.GetRoundTime()
		if math.IsNearlyEqual(timePassed, SlashCo.OverTime, 1) and (GameData.LastOverTime or 0) < curTime then
			GameData.LastOverTime = curTime + 5
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

		local timePassed = SlashCo.GetRoundTime()
		if timePassed > 300 and not SlashCo.FailSafeActivate then
			local slashers = team.GetPlayers(TEAM_SLASHER)
			if #slashers == 0 then
				print("[SlashCo] Lobby failsafe was triggered! (No Slashers)")
				GameData.TriggeredLobbyFailSafe = true
				SlashCo.EndRound()
				return
			end

			local survivors = team.GetPlayers(TEAM_SURVIVOR)
			if #survivors == 0 then
				print("[SlashCo] Lobby failsafe was triggered! (No Survivors)")
				GameData.TriggeredLobbyFailSafe = true
				SlashCo.EndRound()
				return
			end
		end
	end)
end