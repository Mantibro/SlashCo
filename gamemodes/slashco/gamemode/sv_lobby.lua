local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

hook.Add("InitPostEntity", "SlashCo:LobbyBackgroundMusic", function()
	if not GameData.IsLobby then return end

	SlashCo.AudioSystem.EnableBackgroundMusic()
	SlashCo.AudioSystem.SetBackgroundMusic("slashco/music/slashco_lobby.wav")
end)

local function lobbySaveCurData()
	local diff = SlashCo.LobbyData.SelectedDifficulty
	local offer = SlashCo.LobbyData.Offering
	local survivorgasmod = SlashCo.LobbyData.SurvivorGasMod

	--Clear the database before saving
	--RunConsoleCommand("debug_datatest_delete")

	print("[SlashCo] Now beginning database...")
	if not sql.TableExists("slashco_table_basedata") then
		--Create the database table

		sql.Query("CREATE TABLE slashco_table_basedata(Difficulty NUMBER, SlasherDanger NUMBER, SlasherClass NUMBER, SlasherID TEXT, Offering NUMBER, SurviorGasMod NUMBER);")
		sql.Query("CREATE TABLE slashco_table_survivordata(SteamID TEXT, Item TEXT, Item2 TEXT);")
		sql.Query("CREATE TABLE slashco_table_slasherdata(SteamID TEXT, SlasherID TEXT);")
	end

	if not sql.TableExists("slashco_table_potentialslashers") then
		sql.Query("CREATE TABLE slashco_table_potentialslashers(SteamID TEXT);") -- RaphaelIT7: used in case the slasher quits and can be faster
	end

	--Major data dump
	sql.Query("INSERT INTO slashco_table_basedata( Difficulty, SlasherDanger, SlasherClass, SlasherID, Offering, SurviorGasMod ) VALUES( " .. diff .. ", " .. (SlashCo.LobbyData.SelectedSlasherInfo.DANGER or SlashCo.DangerLevel.Unknown) .. ", " .. sql.SQLStr(SlashCo.LobbyData.SelectedSlasherInfo.CLASS or SlashCo.DangerLevel.Unknown) .. ", " .. sql.SQLStr(SlashCo.LobbyData.SelectedSlasherInfo.ID or 0) .. ", " .. offer .. ", " .. survivorgasmod .. " );")

	for _, p in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do -- RaphaelIT7: Why not using SlashCo.LobbyData.AssignedSurvivors? Because people could have been set survivor, idk what servers might do.
		--Save the Current Survivors Items to the database
		sql.Query("INSERT INTO slashco_table_survivordata( SteamID, Item, Item2 ) VALUES( " .. sql.SQLStr(p:SteamID64()) .. ", " .. sql.SQLStr(p:GetItem("item")) .. ", " .. sql.SQLStr(p:GetItem("item2")) .. " );")
	end

	for _, slasher in ipairs(SlashCo.LobbyData.AssignedSlashers) do
		--Save the Current Slashers to the database
		local slasherID = slasher.slasherID -- if the slasher data contains slasher.slasherid then its a forced id by SlashCo.AssignSlasher
		if not slasherID or slasherID == "" then
			slasherID = SlashCo.GetRandomSlasher(SlashCo.LobbyData.SelectedSlasherInfo.DANGER, SlashCo.LobbyData.SelectedSlasherInfo.CLASS)
		end

		sql.Query("INSERT INTO slashco_table_slasherdata( SteamID, SlasherID ) VALUES( " .. sql.SQLStr(slasher.steamid) .. ", " .. sql.SQLStr(slasherID) ..  " );")
	end

	for _, potentialSlasher in ipairs(SlashCo.LobbyData.NonPickedPotentialSlashers) do
		-- RaphaelIT7: Save all players who wanted to be a slasher but didn't make it
		sql.Query("INSERT INTO slashco_table_potentialslashers( SteamID ) VALUES( " .. sql.SQLStr(potentialSlasher.steamid) .. " );")
	end

	local lastSQLError = sql.LastError() or ""
	if lastSQLError ~= "" then
		ErrorNoHaltWithStack("Encountered some SQL error while writing lobby data! Report this: \"" .. lastSQLError .. "\"")
	end

	print("[SlashCo] DATA SAVED.")

	SlashCo.ChangeMap(SlashCo.LobbyData.SelectedMap)
end

--Only run this and the removePlayerFromLobby function using the GM:PlayerChangedTeam hook: https://wiki.facepunch.com/gmod/GM:PlayerChangedTeam
local function addPlayerToLobby(ply)
	SlashCo.LobbyData.Players[ply] = 0 -- Ready state
	broadcastLobbyInfo()
end

local function removePlayerFromLobby(ply)
	SlashCo.LobbyData.Players[ply] = nil
	broadcastLobbyInfo()
end

function lobbyPlayerReadying(ply, state)
	SlashCo.LobbyData.Players[ply] = state
end

function getReadyState(ply)
	return SlashCo.LobbyData.Players[ply]
end

function isPlyOfferer(ply)
	local id = ply:SteamID64()

	for _, v in ipairs(SlashCo.LobbyData.Offerors) do
		if v.steamid == id then
			return true
		end
	end

	return false
end

function lobbyReady()
	--Is everyone ready?
	for _, readyState in pairs(SlashCo.LobbyData.Players) do
		if readyState == SlashCo.ReadyState.NotReady then
			return false
		end
	end

	--If we make it here then everyone has a readystate that isn't 0 and so everyone must be ready
	return true
end

function broadcastLobbyInfo()
	net.Start("SlashCo:GiveLobbyInfo")
		for ply, readyState in pairs(SlashCo.LobbyData.Players) do
			net.WriteEntity(ply)
			net.WriteUInt(readyState, 2)
		end
	net.Broadcast()

	if timer.TimeLeft("AllReadyLobby") ~= nil then
		net.Start("SlashCo:LobbyTimerTime")
			net.WriteUInt(math.floor(timer.TimeLeft("AllReadyLobby")), 6)
		net.Broadcast()
	end
end

function GM:PlayerChangedTeam(ply, oldTeam, newTeam)
	if newTeam == TEAM_LOBBY and oldTeam ~= TEAM_LOBBY then
		addPlayerToLobby(ply)
	end

	if newTeam == TEAM_SPECTATOR and oldTeam ~= TEAM_SPECTATOR then
		removePlayerFromLobby(ply)
	end
end

local function lobbyChooseItem(plyid, id)
	SlashCo.BroadcastGlobalData()

	--Change the survivor's chosen item.

	SlashCo.ChangeSurvivorItem(player.GetBySteamID64(plyid), "item", id)

	if SlashCoItems[id].OnBuy then
		SlashCoItems[id].OnBuy()
	end
end

--				***Begin the post-ready timer***
local function lobbyReadyTimer(count)
	timer.Create("AllReadyLobby", count, 1, function()
		SlashCo.LobbyRoundSetup()
	end)
end
--				***Begin the transition timer***
local function lobbyTransitionTimer()
	timer.Create("LobbyTransition", math.max(SlashCo.LobbyBanter(), 10), 1, function()
		SlashCo.LobbyBriefingTransition()

		timer.Simple(8, function()
			SlashCo.LobbyOpenItems()
		end)
	end)
end
--				***Begin the leaving timer***
local function lobbyLeaveTimer()
	timer.Create("LobbyLeave", 20, 1, function()
		SlashCo.LobbyLeave()
	end)
end

-- A table containing all players that are allowed to pick a slasher, if they send the SlashCo:SelectSlasher net message without being in here, they will be rejected.
SlashCo.AllowedPlayerSlasherSelection = SlashCo.AllowedPlayerSlasherSelection or {}
local function BeginSlasherSelection(specificSlasher)
	for _, slasherData in ipairs(SlashCo.LobbyData.AssignedSlashers) do
		if specificSlasher and specificSlasher ~= slasherData.steamid then continue end

		local slasher = player.GetBySteamID64(slasherData.steamid)
		if not IsValid(slasher) or slasher:GetPickedSlasher() ~= "" then continue end

		-- We did this previously clientside, but there's no reason to go server -> client -> server when the client gets no choice.
		if SlashCo.LobbyData.SelectedSlasherInfo.ID ~= 0 then
			SlashCo.PlayerPickedLobbySlasher(slasher, SlashCo.LobbyData.SelectedSlasherInfo.ID)
			continue
		end

		local selectionData = {
			slasherClass = SlashCo.LobbyData.SelectedSlasherInfo.CLASS,
			slasherDanger = SlashCo.LobbyData.SelectedSlasherInfo.DANGER,
			bannedSlashers = SlashCo.GetBannedSlashers(true),
		}

		net.Start("SlashCo:PickingSlasher")
			net.WriteTable(selectionData)
		net.Send(slasher)
		SlashCo.AllowedPlayerSlasherSelection[slasher] = selectionData
	end
end

--				***Assign the values for the incoming Round***
local function lobbyRoundSetup()
	SlashCo.BroadcastGlobalData()

	for _, play in ipairs(player.GetAll()) do
		--local pid = play:SteamID64()
		SlashCo.BroadcastMasterDatabaseForClient(play)
	end

	SlashCo.LobbyData.SelectedDifficulty = math.random(0, #SlashCo.DifficultyLevel) --Randomizing the Difficulty

	local diff = math.min(GetConVar("slashco_force_difficulty"):GetInt(), #SlashCo.DifficultyLevel)
	if diff > -1 then
		SlashCo.LobbyData.SelectedDifficulty = diff
	end

	--Difficulty-based Slasher Selection:

	if SlashCo.LobbyData.SelectedDifficulty == SlashCo.DifficultyLevel.EASY then
		local randomSlasherID = SlashCo.GetRandomSlasher()

		SlashCo.LobbyData.SelectedSlasherInfo.ID = randomSlasherID
		SlashCo.LobbyData.SelectedSlasherInfo.CLASS = SlashCoSlashers[randomSlasherID].Class
		SlashCo.LobbyData.SelectedSlasherInfo.DANGER = SlashCoSlashers[randomSlasherID].DangerLevel
		SlashCo.LobbyData.SelectedSlasherInfo.NAME = SlashCoSlashers[randomSlasherID].Name
		SlashCo.LobbyData.SelectedSlasherInfo.TIP = SlashCoSlashers[randomSlasherID].ProTip
	elseif SlashCo.LobbyData.SelectedDifficulty == SlashCo.DifficultyLevel.NOVICE then
		SlashCo.LobbyData.SelectedSlasherInfo.CLASS = math.random(1, #SlashCo.SlasherClass)
	elseif SlashCo.LobbyData.SelectedDifficulty == SlashCo.DifficultyLevel.INTERMEDIATE then
		SlashCo.LobbyData.SelectedSlasherInfo.DANGER = math.random(1, #SlashCo.DangerLevel)
	end

	--SlashCo.LobbyData.DeathwardsLeft = 2 - SlashCo.LobbyData.SelectedDifficulty

	for ply, readyState in pairs(SlashCo.LobbyData.Players) do
		--Setup for assigning that players' in-game teams

		if readyState == SlashCo.ReadyState.Survivor then
			table.insert(SlashCo.LobbyData.PotentialSurvivors, { steamid = ply:SteamID64() })
			print("(Debug) " .. ply:GetName() .. " now is a potential Survivor.")
		elseif readyState == SlashCo.ReadyState.Slasher then
			table.insert(SlashCo.LobbyData.PotentialSlashers, { steamid = ply:SteamID64() })
			print("(Debug) " .. ply:GetName() .. " now is a potential Slasher.")
		end
	end

	if SlashCo.LobbyData.PotentialSurvivors[1] or SlashCo.LobbyData.PotentialSlashers[1] then
		--Assigning that players' teams

		if not SlashCo.LobbyData.PotentialSlashers[1] then
			--If no none readied as Slasher, the slasher will be randomly picked from the survivor-ready players.

			local randomSlasher = table.remove(SlashCo.LobbyData.PotentialSurvivors, math.random(1, #SlashCo.LobbyData.PotentialSurvivors))
			table.insert(SlashCo.LobbyData.AssignedSlashers, randomSlasher)
			print("(Debug) " .. player.GetBySteamID64(randomSlasher.steamid):GetName() .. " has been assigned Slasher.")
		elseif not SlashCo.LobbyData.PotentialSurvivors[1] then
			--If no none readied as Survivor, the slasher will be randomly picked from the slasher-ready players.

			local randomSlasher = table.remove(SlashCo.LobbyData.PotentialSlashers, math.random(1, #SlashCo.LobbyData.PotentialSlashers))
			table.insert(SlashCo.LobbyData.AssignedSlashers, randomSlasher)
		else
			--If the ready states are mixed, pick the slasher from slasher-ready players.
			-- RaphaelIT7: This case shouldn't be possible?

			local randomSlasher = table.remove(SlashCo.LobbyData.PotentialSlashers, math.random(1, #SlashCo.LobbyData.PotentialSlashers))
			table.insert(SlashCo.LobbyData.AssignedSlashers, randomSlasher)
		end

		-- RaphaelIT7: If you later use table.remove on AssignedSurvivors or PotentialSurvivors the change affects both since both variables are the same table
		SlashCo.LobbyData.AssignedSurvivors = SlashCo.LobbyData.PotentialSurvivors -- Move table since its now finalized (Slashers were removed)
	end

	--[[if team.NumPlayers(TEAM_SPECTATOR) < 1 and SlashCo.LobbyData.Offering == SCInfo.Offering.Duality then
		SlashCo.LobbyData.Offering = 0

		for _, play in ipairs(player.GetAll()) do
			play:ChatPrint("[SlashCo] No Spectators, Duality Offering was cleared.")
		end
	end]]

	if SlashCo.LobbyData.Offering == SCInfo.Offering.Duality then
		--Duality Slasher

		local randomPly
		if #SlashCo.LobbyData.PotentialSlashers > 0 then
			randomPly = table.remove(SlashCo.LobbyData.PotentialSlashers, math.random(1, #SlashCo.LobbyData.PotentialSlashers))
		elseif #SlashCo.LobbyData.PotentialSurvivors > 1 then -- There must be more than 1 survivor left!
			randomPly = table.remove(SlashCo.LobbyData.PotentialSurvivors, math.random(1, #SlashCo.LobbyData.PotentialSurvivors))
		end

		if randomPly then
			table.insert(SlashCo.LobbyData.AssignedSlashers, randomPly)

			local p = player.GetBySteamID64(randomPly.steamid)
			p:ChatText("second_slasher")
		else
			print("[SlashCo] Found no player that could fill the second slasher slot")
		end
	end

	-- Move leftover slashers over
	for key, slasher in ipairs(SlashCo.LobbyData.PotentialSlashers) do
		table.insert(SlashCo.LobbyData.AssignedSurvivors, slasher)
	end
	SlashCo.LobbyData.NonPickedPotentialSlashers = SlashCo.LobbyData.PotentialSlashers -- RaphaelIT7: Moved over since the selection is over and these were all players who wanted to become a slasher but did not make it.
	SlashCo.LobbyData.PotentialSlashers = {}
	SlashCo.LobbyData.FinishedPicking = true

	--Finalize teams
	if SlashCo.LobbyData.AssignedSurvivors[1] and SlashCo.LobbyData.AssignedSlashers[1] then
		--print(player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[1].steamid):GetName() .. player.GetBySteamID64(SlashCo.LobbyData.AssignedSlashers[1].steamid):GetName())

		for i = 1, #SlashCo.LobbyData.AssignedSurvivors do
			--The Survivors become survivors

			local ply = player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[i].steamid)
			ply:SetTeam(TEAM_SURVIVOR)
			ply:Spawn()
			ply:SetAvoidPlayers(false) -- Disable being pushed out of players while being in the lobby.

			print("[SlashCo] Survivor " .. i .. " selection successful, the Survivor is: " .. ply:GetName())
		end

		for i = 1, #SlashCo.LobbyData.AssignedSlashers do
			--The Slasher becomes a spectator in the lobby.

			local ply = player.GetBySteamID64(SlashCo.LobbyData.AssignedSlashers[i].steamid)

			ply:SetTeam(TEAM_SPECTATOR)
			ply:Spawn()
		end
	end

	SlashCo.LobbyRoundData()

	--Assign the map randomly
	SlashCo.LobbyData.SelectedMap = GetRandomMap(#SlashCo.LobbyData.AssignedSurvivors)
	SlashCo.PrecacheNextMap()

	BeginSlasherSelection()
end

-- RaphaelIT7: Function only exists for servers or other addons to use
function SlashCo.AssignSlasher(steamid, forceSlasherID)
	if not GameData.IsLobby then
		error("This function is only functional in the lobby!")
		return
	end

	if not isstring(steamid) then
		error("Expected a steamid/string!")
		return
	end

	-- For conveniance we support an input of a normal steamid and steamid64
	if string.StartsWith(steamid, "STEAM") then
		steamid = util.SteamIDTo64(steamid)
	end

	if SlashCo.LobbyData.FinishedPicking then
		for key, slasher in ipairs(SlashCo.LobbyData.NonPickedPotentialSlashers) do
			if slasher.steamid == steamid then
				table.remove(SlashCo.LobbyData.NonPickedPotentialSlashers, key)
				break
			end
		end
	end

	local isSlasher = false
	for _, slasher in ipairs(SlashCo.LobbyData.AssignedSlashers) do
		if slasher.steamid == steamid then
			isSlasher = true
			break
		end
	end

	if not isSlasher then
		table.insert(SlashCo.LobbyData.AssignedSlashers, { steamid = steamid, slasherid = forceSlasherID })
	end

	if SlashCo.LobbyData.FinishedPicking then
		BeginSlasherSelection(steamid) -- Allow him to pick since picking already started
	end
end

net.Receive("SlashCo:SelectSlasher", function(_, ply)
	local selectedSlasher = net.ReadString()
	local selectionData = SlashCo.AllowedPlayerSlasherSelection[ply]
	if not selectionData then
		print("[SlashCo] Player \"" .. ply:Name() .. "\" tried to pick a slasher when they were never asked to!")
		return
	else
		local slasher = SlashCoSlashers[selectedSlasher]
		if not slasher then
			print("[SlashCo] Player \"" .. ply:Name() .. "\" tried to pick a non-existent slasher! (\"" .. selectedSlasher .. "\")")
			net.Start("SlashCo:PickingSlasher") -- Force the client to select a new slasher again since he fucked up!
				net.WriteTable(selectionData)
			net.Send(ply)
			return
		end

		if selectionData.slasherClass and selectionData.slasherClass ~= SlashCo.SlasherClass.Unknown and selectionData.slasherClass ~= slasher.Class then
			print("[SlashCo] Player \"" .. ply:Name() .. "\" tried to pick a slasher that was not of the allowed class! (\"" .. selectedSlasher .. "\")")
			net.Start("SlashCo:PickingSlasher") -- Force the client to select a new slasher again since he fucked up!
				net.WriteTable(selectionData)
			net.Send(ply)
			return
		end

		if selectionData.slasherDanger and selectionData.slasherDanger ~= SlashCo.DangerLevel.Unknown and selectionData.slasherDanger ~= slasher.DangerLevel then
			print("[SlashCo] Player \"" .. ply:Name() .. "\" tried to pick a slasher that was not of the allowed danger level! (\"" .. selectedSlasher .. "\")")
			net.Start("SlashCo:PickingSlasher") -- Force the client to select a new slasher again since he fucked up!
				net.WriteTable(selectionData)
			net.Send(ply)
			return
		end

		if selectionData.bannedSlashers and selectionData.bannedSlashers[selectedSlasher]  then
			print("[SlashCo] Player \"" .. ply:Name() .. "\" tried to pick a slasher that was banned! (\"" .. selectedSlasher .. "\")")
			net.Start("SlashCo:PickingSlasher") -- Force the client to select a new slasher again since he fucked up!
				net.WriteTable(selectionData)
			net.Send(ply)
			return
		end

		if SlashCo.IsSlasherBanned(selectedSlasher)  then
			print("[SlashCo] Player \"" .. ply:Name() .. "\" tried to pick a slasher that was banned while they were selecting! (\"" .. selectedSlasher .. "\")")
			net.Start("SlashCo:PickingSlasher") -- Force the client to select a new slasher again since it wasn't their fault for this event
				net.WriteTable(selectionData)
			net.Send(ply)
			return
		end

		SlashCo.AllowedPlayerSlasherSelection[ply] = nil -- Only allow them to pick once!
	end

	print("[SlashCo] Player \"" .. ply:Name() .. "\" picked slasher \"" .. selectedSlasher .. "\"")

	if SlashCo.AwaitPlayerToSelectSlasher then
		SlashCo.AwaitPlayerToSelectSlasher(ply, selectedSlasher)
	end

	if GameData.IsLobby then
		SlashCo.PlayerPickedLobbySlasher(ply, selectedSlasher)
	end
end)

function SlashCo.PlayerPickedLobbySlasher(ply, slasherID)
	if not GameData.IsLobby then return end
	
	ply:SetPickedSlasher(slasherID)

	local steamid = ply:SteamID64()
	for _, slasher in ipairs(SlashCo.LobbyData.AssignedSlashers) do
		if slasher.steamid ~= steamid then continue end

		-- RaphaelIT7: We store the slasherID in this table since if the player crashes/disconnects and wants to rejoin the SetPickedSlasher field was nuked.
		slasher.slasherID = slasherID
		break
	end
end

local function pickItem(ply, item)
	local balance = tonumber(SlashCoDatabase.GetStat(ply:SteamID64(), "Points"))

	if ply:Team() ~= TEAM_SURVIVOR then
		return
	end

	if ply:GetItem("item") ~= "none" or ply:GetItem("item2") ~= "none" then
		ply:ChatText("item_already_chosen")
		return
	end

	if SlashCoItems[item].Price > balance then
		ply:ChatText("item_afford")
		return
	end

	if SlashCoItems[item].MaxAllowed then
		local numAllowed = SlashCoItems[item].MaxAllowed()
		local itemCount = 0
		local slot = SlashCoItems[item].IsSecondary and "item2" or "item"
		for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if v:GetItem(slot) == item then
				itemCount = itemCount + 1
			end
		end
		if itemCount >= numAllowed then
			ply:ChatText("item_toomany")
			return
		end
	end

	ply:Give("sc_survivorhands")
	SlashCoDatabase.UpdateStats(ply:SteamID64(), "Points", -SlashCoItems[item].Price)
	lobbyChooseItem(ply:SteamID64(), item)

	timer.Simple(0.5, function()
		SlashCo.BroadcastMasterDatabaseForClient(ply)
	end)

	if not SlashCo.LobbyData.VendorCooldown then
		SlashCo.LobbyData.VendorCooldown = CurTime()
		LobbyVendorVoice(item)
	elseif (CurTime() - SlashCo.LobbyData.VendorCooldown) > 5 then
		SlashCo.LobbyData.VendorCooldown = CurTime()
		LobbyVendorVoice(item)
	end
end

function LobbyVendorVoice(item)
	local vendor = ents.FindByClass("sc_itemstash")[1]

	if item == "DeathWard" then
		vendor:EmitSound("slashco/itemvendor/itemvendor_deathward" .. math.random(1,5) .. ".mp3")
	elseif item == "Brick" then
		vendor:EmitSound("slashco/itemvendor/itemvendor_brick" .. math.random(1,5) .. ".mp3")
	else
		vendor:EmitSound("slashco/itemvendor/itemvendor_generic" .. math.random(1,12) .. ".mp3")
	end
end

local MapForceCost = 100
local function pickMap(ply, map)
	local balance = tonumber(SlashCoDatabase.GetStat(ply:SteamID64(), "Points"))

	if SlashCo.LobbyData.SelectedMap == map then
		ply:ChatText("map_already_selected")
		return
	end

	if balance < MapForceCost then
		ply:ChatText("map_notenough")
		return
	end

	for _, play in ipairs(player.GetAll()) do
		play:ChatText({"map_guaranteed_to", ply:Nick(), MapForceCost, SCInfo.Maps[map].NAME})
	end

	SlashCoDatabase.UpdateStats(ply:SteamID64(), "Points", -MapForceCost)
	SlashCo.LobbyData.SelectedMap = map
	MapForceCost = MapForceCost + 50
	SlashCo.SendValue(nil, "mapGuar", SlashCo.LobbyData.SelectedMap, MapForceCost)
	SlashCo.PrecacheNextMap()
end

hook.Add("scValue_pickItem", "slashCo_PickItem", function(ply, item)
	if ply.CantBuy then return end
	pickItem(ply, item)
end)

hook.Add("scValue_pickMap", "slashCo_PickMap", function(ply, map)
	if ply.CantBuy then return end
	pickMap(ply, map)
end)

local lobby_tick
hook.Add("Tick", "LobbyTickEvent", function()
	if not GameData.IsLobby then
		return
	end

	lobby_tick = lobby_tick or 0
	lobby_tick = lobby_tick + 1
	if lobby_tick > 33 then
		lobby_tick = 0
	end

	if lobby_tick == 33 and timer.TimeLeft("AllReadyLobby") ~= nil then
		broadcastLobbyInfo()
	end

	local num = table.Count(SlashCo.LobbyData.Players)
	local num_o = #SlashCo.LobbyData.Offerors

	if num_o > 0 and SlashCo.LobbyData.Offering < 1 and num_o > (num / 2) then
		SlashCo.OfferingVoteSuccess(SlashCo.LobbyData.VotedOffering)
	end

	if SlashCo.LobbyData.LOBBYSTATE < 1 then
		local seek = seek

		if num < 2 then
			return
		end

		if seek == nil then
			seek = 0
		end

		for ply, readyState in pairs(SlashCo.LobbyData.Players) do
			if not IsValid(ply) then
				removePlayerFromLobby(ply)
				continue
			end

			if readyState > SlashCo.ReadyState.NotReady then
				seek = seek + 1
			end
		end

		if seek > (num / 2) and SlashCo.LobbyData.ReadyTimerStarted == false then
			SlashCo.LobbyData.ReadyTimerStarted = true
			lobbyReadyTimer(30)
		end

		if seek <= (num / 2) and SlashCo.LobbyData.ReadyTimerStarted == true then
			timer.Remove("AllReadyLobby")
			SlashCo.LobbyData.ReadyTimerStarted = false
		end

		if seek >= num then
			timer.Remove("AllReadyLobby")
			SlashCo.LobbyRoundSetup()
		end

		if (num < 2 or seek <= (num / 2)) and SlashCo.LobbyData.ReadyTimerStarted then
			timer.Remove("AllReadyLobby")
			SlashCo.LobbyData.ReadyTimerStarted = false

			net.Start("SlashCo:LobbyTimerTime")
				net.WriteUInt(62, 6)
			net.Broadcast()
		end

		seek = 0
	end

	if SlashCo.LobbyData.LOBBYSTATE == 1 then
		local minx = -60
		local maxx = 60
		local miny = 640
		local maxy = 785

		local all_players_in = true

		if table.IsEmpty(SlashCo.LobbyData.AssignedSurvivors) then
			return
		end

		for i = 1, #SlashCo.LobbyData.AssignedSurvivors do
			local ply = player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[i].steamid)
			if not ply then continue end
			local pos = ply:GetPos()
			local x = pos[1]
			local y = pos[2]

			if (x > minx and x < maxx) and (y > miny and y < maxy) then
				continue
			end

			all_players_in = false
			break
		end

		if all_players_in or (CurTime() > (SlashCo.LobbyData.ElevatorEnterTime or CurTime())) then
			SlashCo.LobbyEvelatorTransition()
		end
	end
end)

hook.Add("PlayerDisconnected", "Playerleave", function(ply)
	-- If the slasher disconnects after they were already picked, a new one will be picked before the next round starts, we don't need to reset the lobby.
	if GameData.IsLobby and ply:Team() == TEAM_LOBBY then
		removePlayerFromLobby(ply)
	end
end)

function lobbyFinish()
	if SlashCo.LobbyData.LOBBYSTATE == 4 then
		return
	end

	SlashCo.LobbyData.LOBBYSTATE = 4
	SetGlobal2Bool("IsLobbyStarting", true)

	SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1], SlashCo.CurRound.HelicopterTargetPosition[2], SlashCo.CurRound.HelicopterTargetPosition[3] + 500)

	timer.Simple(8, function()
		SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1] + 5000, SlashCo.CurRound.HelicopterTargetPosition[2] + 4000, SlashCo.CurRound.HelicopterTargetPosition[3] + 1000)
	end)

	timer.Simple(15, function()
		SlashCo.StartGameIntro()

		lobbyLeaveTimer()

		SlashCo.AudioSystem.DisableBackgroundMusic()
		SlashCo.QuietHeli()
	end)
end

function SlashCo.OfferingVoteFail()
	SlashCo.LobbyData.Offering = 0
	SlashCo.LobbyData.VotedOffering = 0
	table.Empty(SlashCo.LobbyData.Offerors)

	for _, ply in player.Iterator() do
		ply:ChatText("offervote_not_success")
		SlashCo.EndOfferingVote(ply)
	end
end

function SlashCo.OfferingVoteSuccess(id)
	local fail = false

	--[[if id == 4 and team.NumPlayers(TEAM_SPECTATOR) < 1 then
		for _, ply in player.Iterator() do
			ply:ChatText("offervote_duality_fail")
			SlashCo.EndOfferingVote(ply)
			fail = true
		end
	end]]

	if id == 2 then
		--Satiation

		SlashCo.LobbyData.SelectedSlasherInfo.CLASS = SlashCo.SlasherClass.Deamon
	end

	SlashCo.LobbyData.VotedOffering = 0

	SlashCo.LobbyData.Offering = id

	timer.Remove("OfferingVoteTimer")

	for _, play in ipairs(player.GetAll()) do
		SlashCo.EndOfferingVote(play)
	end

	if not fail then
		SlashCo.OfferingVoteFinished(SCInfo.Offering[id].Rarity)
	end
end

--//lobby concommands//--

function SlashCo.LobbyRoundSetup()
	SlashCo.LobbyData.LOBBYSTATE = 1
	SlashCo.LobbyData.ElevatorEnterTime = CurTime() + 30 -- It will proceed on its own

	local doors = ents.FindByName("Slashco_Elev_Shutter")
	doors[1]:Fire("Open")
	doors[2]:Fire("Open")

	for ply, readyState in pairs(SlashCo.LobbyData.Players) do
		--If someone is not ready, force them as ready survivor.

		if getReadyState(ply) == SlashCo.ReadyState.NotReady then
			lobbyPlayerReadying(ply, SlashCo.ReadyState.Survivor)
		end
	end

	net.Start("SlashCo:GiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE, 3)
	net.Broadcast()

	table.Empty(SlashCo.LobbyData.PotentialSlashers)
	table.Empty(SlashCo.LobbyData.PotentialSurvivors)
	table.Empty(SlashCo.LobbyData.AssignedSurvivors)
	table.Empty(SlashCo.LobbyData.AssignedSlashers)

	SlashCo.LobbyData.SelectedSlasherInfo.NAME = "Unknown"
	SlashCo.LobbyData.SelectedSlasherInfo.ID = 0
	SlashCo.LobbyData.SelectedSlasherInfo.CLASS = SlashCo.SlasherClass.Unknown
	SlashCo.LobbyData.SelectedSlasherInfo.DANGER = SlashCo.DangerLevel.Unknown
	SlashCo.LobbyData.SelectedSlasherInfo.TIP = "--//--"

	lobbyRoundSetup()
end

function SlashCo.LobbyEvelatorTransition()
	SlashCo.LobbyData.LOBBYSTATE = 2

	local doors = ents.FindByName("Slashco_Elev_Shutter")
	doors[1]:Fire("Close")
	doors[2]:Fire("Close")

	timer.Simple(3, function()
		local elevator = table.Random(ents.FindByName("Slashco_Elev"))
		elevator:Fire("Open")

		lobbyTransitionTimer()
	end)

	net.Start("SlashCo:GiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE, 3)
	net.Broadcast()
end

function SlashCo.LobbyBriefingTransition()
	SlashCo.LobbyData.LOBBYSTATE = 3

	SlashCo.LobbyPlayerBriefing()

	local doors = ents.FindByName("Slashco_Elev_Exit")
	doors[1]:Fire("Open")
	doors[2]:Fire("Open")

	net.Start("SlashCo:GiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE, 3)
	net.Broadcast()
end

function SlashCo.LobbyOpenItems()
	local door = table.Random(ents.FindByName("door_itembox"))
	if IsValid(door) then
		door:Fire("Open")
	end
end

function SlashCo.LobbyLeave()
	SlashCo.ClearDatabase()

	timer.Simple(1, function()
		lobbySaveCurData()
	end)
end

util.AddNetworkString("slashCo_SpectatorSceneToPVS")
if GameData.IsLobby then
	net.Receive("slashCo_SpectatorSceneToPVS", function(len, ply)
		if ply:Team() ~= TEAM_SPECTATOR then
			return
		end

		ply.spectatorScenePos = net.ReadVector()
	end)

	hook.Add("SetupPlayerVisibility", "SpectatorsPVS", function(ply)
		if ply:Team() ~= TEAM_SPECTATOR or not ply.spectatorScenePos then
			return
		end

		AddOriginToPVS(ply.spectatorScenePos)
	end)
end