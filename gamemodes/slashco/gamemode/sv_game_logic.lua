SlashCo = SlashCo or {}

function SlashCo.SinglePlayerSetup()
	g_SlashCoDebug = true
	SlashCo.CurRound.Difficulty = math.random(0, 3)
	SlashCo.CurRound.SurvivorData.GasCanMod = 0
	SlashCo.CurRound.OfferingData.CurrentOffering = 0

	hook.Add("PlayerInitialSpawn", "SinglePlayerSetup", function(ply)
		table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = ply:SteamID64() })
		table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { steamid = ply:SteamID64() })
	end)
end

function SlashCo.LoadCurRoundData()
	table.Empty(SlashCo.CurRound.ExpectedPlayers)
	if cookie.GetString("slashco_table_basedata") ~= nil and sql.TableExists("slashco_table_survivordata") and sql.TableExists("slashco_table_slasherdata") then
		--Load relevant data from the database
		local baseData = util.JSONToTable(cookie.GetString("slashco_table_basedata") or "") or {}
		local diff = baseData.Difficulty
		local offering = baseData.Offering
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

		--First we insert the Slasher. If the Slasher does not join in time the game cannot begin.

		--Insert the First and second Slasher into the table
		local slasherData = sql.Query("SELECT * FROM slashco_table_slasherdata;") or {}
		for _, slasherData in ipairs(slasherData) do
			table.insert(SlashCo.CurRound.ExpectedPlayers, {
				steamid = slasherData.SteamID,
				disconnected = SlashCo.CurRound.DisconnectedPlayers[slasherData.SteamID] ~= nil
			})
		end

		SlashCo.CurRound.ForceSlasherSelection = #slasherData == 0

		SlashCo.SetupExpectedPlayersFailsafe()

		--Nightmare offering >>>>>>>>>>>>>>>>>>>>>

		local survivorData = sql.Query("SELECT * FROM slashco_table_survivordata;") or {}
		if SlashCo.CurRound.OfferingData.CurrentOffering == SCInfo.Offering.Nightmare then
			--All survivors will become slashers.
			for _, survivorData in ipairs(survivorData) do
				local slasher_pick = SlashCo.GetRandomSlasher(SlashCo.CurRound.SlasherDanger, SlashCo.CurRound.SlasherClass)
				SlashCo.SelectSlasher(slasher_pick, survivorData.SteamID)
				table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { steamid = survivorData.SteamID, slasherID = slasher_pick })
				table.insert(SlashCo.CurRound.ExpectedPlayers, {
					steamid = survivorData.SteamID,
					disconnected = SlashCo.CurRound.DisconnectedPlayers[survivorData.SteamID] ~= nil
				})
			end

			--Slasher becomes the sole survivor
			for _, slasherData in ipairs(slasherData) do
				--For the slasher's clientside view also
				table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { steamid = slasherData.SteamID })
			end

			return
		end

		--Nightmare offering >>>>>>>>>>>>>>>>>>>>>>>>

		for _, survivorData in ipairs(survivorData) do
			table.insert(SlashCo.CurRound.ExpectedPlayers, { steamid = survivorData.SteamID })
			--For the slasher's clientside view also
			table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { steamid = survivorData.SteamID })
		end

		for _, slasherData in ipairs(slasherData) do
			if not SlashCo.PresentCovenant then
				if slasherData.SlasherID == "Covenant" then
					SlashCo.PresentCovenant = slasherData.SteamID
				end

				SlashCo.SelectSlasher(slasherData.SlasherID, slasherData.SteamID)
				table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { steamid = slasherData.SteamID, slasherID = slasherData.SlasherID })
				continue
			end

			if SlashCo.PresentCovenant == nil then
				SlashCo.SelectSlasher(slasherData.SlasherID, slasherData.SteamID)
				table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { steamid = slasherData.SteamID, slasherID = slasherData.SlasherID })
			else
				table.insert(SlashCoSlashers.Covenant.PlayersToBecomePartOfCovenant, { steamid = slasherData.SteamID })
			end
		end

		table.Empty(SlashCo.CurRound.DisconnectedPlayers) -- Not needed anymore
	else
		if game.SinglePlayer() then
			SlashCo.SinglePlayerSetup()
			return
		end

		print("[SlashCo] Something went wrong while trying to load the round data from the Database! Restart imminent. (init)")
		local baseTable = (cookie.GetString("slashco_table_basedata") ~= nil) and "present" or "nil"
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
	SlashCo.FlashWindows() -- RaphaelIT7: Tell all players they should tab in.
end

 function RefundSurvivorItems(ply)
 	local steamID64 = IsValid(ply) and ply:SteamID64() or ply -- if it's a string - it must be a SteamID64!
	local survivorData = sql.Query("SELECT * FROM slashco_table_survivordata WHERE SteamID = " .. sql.SQLStr(steamID64) .. ";")
	if not survivorData or not survivorData[1] then return end

	survivorData = survivorData[1]
	local totalRefund = 0
	if survivorData.Item and survivorData.Item ~= "none" then
		local itemData = SlashCoItems[survivorData.Item]
		if itemData and itemData.Price and itemData.Price > 0 then
			totalRefund = totalRefund + itemData.Price
		end
	end

	if survivorData.Item2 and survivorData.Item2 ~= "none" then
		local itemData = SlashCoItems[survivorData.Item2]
		if itemData and itemData.Price and itemData.Price > 0 then
			totalRefund = totalRefund + itemData.Price
		end
	end

	if totalRefund == 0 then return end

	print("[SlashCo] Player \"" .. (IsValid(ply) and ply:Name() or steamID64) .. "\" was refunded " .. tostring(totalRefund) .. " points for his items since became a slasher")

	if IsValid(ply) then
		ply:ChatText({"item_refund", tostring(totalRefund)})
	end

	SlashCoDatabase.UpdateStats(steamID64, "Points", totalRefund)
	sql.Query("DELETE FROM slashco_table_survivordata WHERE SteamID = " .. sql.SQLStr(steamID64) .. ";")
end

local _DoSlasherSelection
local function DoGlobalSlasherSelection()
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
		_DoSlasherSelection(becomeSlasher, false)
	end)
end

local function DoSlasherSelection(slashers, usingPotentialSlashers)
	if SlashCo.CurRound.AntiLoopSpawn then return end
	for idx, ply in ipairs(slashers) do
		if not IsValid(ply) then
			table.remove(slashers, idx)
			continue
		end
	end
	
	local slasherSelection
	local function RunSlasherSelection()
		local selectedPlyIndex = math.random(#slashers)
		local selectedPly = slashers[math.random(#slashers)]
		if not IsValid(selectedPly) then
			if SlashCo.CurRound.AntiLoopSpawn then return end
			if usingPotentialSlashers then
				DoGlobalSlasherSelection()
			else
				SlashCo.Abort("No one wanted to become the slasher... Well GG")
			end
			return
		end

		SlashCo.AwaitPlayerToSelectSlasher = function(ply, slasherID) -- if id is nil, then they took too long!
			SlashCo.AwaitPlayerToSelectSlasher = nil
			if SlashCo.CurRound.AntiLoopSpawn then return end

			local slasherID = slasherID or SlashCo.GetRandomSlasher(SlashCo.CurRound.SlasherDanger, SlashCo.CurRound.SlasherClass)
			sql.Query("INSERT INTO slashco_table_slasherdata( SteamID, SlasherID ) VALUES( " .. sql.SQLStr(ply:SteamID64()) .. ", " .. sql.SQLStr(slasherID) .. " );")
			table.insert(SlashCo.CurRound.SlasherData.AllSlashers, { steamid = ply:SteamID64(), slasherID = slasherID })
			RefundSurvivorItems(ply)
			SlashCo.SelectSlasher(slasherID, ply:SteamID64())
			StartRound(true)
		end

		if string.len(SlashCo.CurRound.SlasherID or "") > 2 then
			SlashCo.AwaitPlayerToSelectSlasher(selectedPly, SlashCo.CurRound.SlasherID)
			return
		end

		local selectionData = {
			slashClass = SlashCo.CurRound.SlasherClass,
			slashDanger = SlashCo.CurRound.SlasherDanger,
			bannedSlashers = SlashCo.GetBannedSlashers(true),
		}

		net.Start("SlashCo:PickingSlasher")
			net.WriteTable(selectionData)
		net.Send(selectedPly)
		SlashCo.AllowedPlayerSlasherSelection[selectedPly] = selectionData
		selectedPly:ChatText("slasher_replacement")

		timer.Create("SlashCo:WaitingForPlayerToPickSlasher", 15, 1, function()
			if SlashCo.CurRound.AntiLoopSpawn then return end
			if not IsValid(selectedPly) then
				table.remove(slashers, selectedPlyIndex)
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
end
_DoSlasherSelection = DoSlasherSelection

function AskPlayersToBecomeSlasher()
	if SlashCo.CurRound.AntiLoopSpawn then return end

	SlashCo.AudioSystem.EnableBackgroundMusic()
	SlashCo.AudioSystem.SetBackgroundMusic("slashco/ambienttrack/mf_high.ogg", 1)

	if sql.TableExists("slashco_table_potentialslashers") then
		local potentialSlashers = sql.Query("SELECT * FROM slashco_table_potentialslashers;") or {}
		local slashers = {}
		for _, potentialSlasher in ipairs(potentialSlashers) do
			local ply = player.GetBySteamID64(potentialSlasher.SteamID)
			if not IsValid(ply) then continue end

			table.insert(slashers, ply)
		end

		if #slashers > 0 then
			DoSlasherSelection(slashers, true)
			return
		end
	end

	DoGlobalSlasherSelection()
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
				print("[SlashCo] Expected " .. expected_count .. " players in!" .. "(" .. ply:Name() .. ")")
				break
			end
		end
	end

	local foundSlasher = false
	local slashers = SlashCo.SQLTableToLuaTable(sql.Query("SELECT * FROM slashco_table_slasherdata;") or {}, "SteamID") or {}
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
		
		-- Until we fetched SQL we'll store disconnects here and apply the later
		if #SlashCo.CurRound.ExpectedPlayers == 0 then
			SlashCo.CurRound.DisconnectedPlayers[steamID64] = true
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
	for _, data in ipairs(SlashCo.CurRound.ExpectedPlayers) do
		if data.disconnected then
			expected_count = expected_count + 1
			continue
		end

		local ply = player.GetBySteamID64(data.steamid)
		if IsValid(ply) then
			expected_count = expected_count + 1
			print("[SlashCo] Expected player " .. expected_count .. " in!" .. "(" .. ply:Name() .. ")")
			continue
		end
	end

	if expected_count == #SlashCo.CurRound.ExpectedPlayers then
		if player.GetCount() < 2 then
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
			ply:AddRoundPoints("quickescape")
		end

		if ply.SlowEscape then
			ply:AddRoundPoints("slowescape")
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

			v:SetRoundPoints("survive")
			winners[v:SteamID64()] = true
		end

		if heliCount == 1 and #SlashCo.CurRound.SlasherData.AllSurvivors > 1 then
			SlashCo.CurRound.HelicopterRescuedPlayers[1]:SetRoundPoints("last_survive")
		end

		for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not winners[v:SteamID64()] then
				v:SetRoundPoints("left_behind")
			end
		end
	end

	SlashCo.State = SlashCo.States.ENDING
	hook.Run("SlashCo:EndRound", winners)

	print("[SlashCo] Round over, returning to lobby in " .. tostring(lobbyDelay) .. " seconds.")

	timer.Simple(lobbyDelay, function()
		SlashCo.RemoveHelicopter()
		SlashCo.CommitRoundPoints()

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

local function CheckOverTime()
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
end

local function CheckLobbyFailSafe()
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
end

-- RaphaelIT7: Ambient sound stuff
local ambientSounds = {}
for k=1, 8 do
	table.insert(ambientSounds, "clutter" .. k .. ".mp3")
end

for k=1, 10 do
	table.insert(ambientSounds, "creak" .. k .. ".mp3")
end

for k=1, 7 do
	table.insert(ambientSounds, "scrape" .. k .. ".mp3")
end

local function randomAmbientVector(minDistance, maxDistance)
	local x = math.random(minDistance, maxDistance)
	local y = math.random(minDistance, maxDistance)
	local z = math.random(minDistance, maxDistance) / 2

	return Vector(
		(math.random(0, 1) == 1 and x or -x),
		(math.random(0, 1) == 1 and y or -y),
		(math.random(0, 1) == 1 and z or -z)
	)
end

local function RandomAmbientSound()
	if GameData.IsLobby or SlashCo.State ~= SlashCo.States.IN_GAME then return end -- Not in game, so lets do nothing.

	for _, ply in player.Iterator() do
		local plyTeam = ply:Team()

		local chance = 2
		if plyTeam == TEAM_SURVIVOR then
			chance = (GameData.RoundStartSurvivorCount > GameData.BaseMaxSurvivors) and 3 or 1 -- More players = higher chance | less players = lower chance
		elseif plyTeam == TEAM_SLASHER then
			chance = (GameData.RoundStartSurvivorCount > GameData.BaseMaxSurvivors) and 1 or 5 -- More players = lower chance | less players = higher chance
		end

		if math.random(1, 100) > chance then continue end
		if ply:Team() == TEAM_SLASHER then
			if not ply:SlasherFunction("ShouldPlayAmbientSound") then continue end
		end
			
		local pos = randomAmbientVector(150, 400)
		pos:Add(ply:GetPos())

		local soundName = ambientSounds[math.random(1, #ambientSounds)]
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/mapambient/" .. soundName,
			identifier = "AmbientSound-" .. soundName .. "-" .. ply:EntIndex(),
			volume = 1,
			entity = game.GetWorld(),
			fadeIn = 0,
			position = pos,
			minDistance = 250,
			maxDistance = 500,
			disableUniqueToEntity = true,
			deleteWhenDone = true, -- Else we'll have easily 100+ dead channels
		})
	end
end

timer.Create("SlashCo:PerSecondTick", 1, 0, function()
	if GameData.IsLobby then return end

	CheckOverTime()
	CheckLobbyFailSafe()
	RandomAmbientSound()
end)