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
	local survivors = {}
	local slashers = {}

	--Clear the database before saving
	--RunConsoleCommand("debug_datatest_delete")

	if SlashCo.LobbyData.PickedSlasher == "None" then
		--If the slasher wasn't selected, randomize it based on possible options

		:: retry ::

		local rand_name = GetRandomSlasher()
		if SlashCo.LobbyData.SelectedSlasherInfo.CLASS == SlashCo.SlasherClass.Unknown then
			--Check if the random id of slasher has the appropriate class for the difficulty
			--The difficulty allows for any class.
		else
			if SlashCo.LobbyData.SelectedSlasherInfo.CLASS ~= SlashCoSlashers[rand_name].Class then
				goto retry
			end --the random slasher's class does not match.
		end

		if SlashCo.LobbyData.SelectedSlasherInfo.DANGER == SlashCo.DangerLevel.Unknown then
			--Check if the random id of slasher has the appropriate danger level for the difficulty

			--The difficulty allows for any danger level.
		else
			if SlashCo.LobbyData.SelectedSlasherInfo.DANGER ~= SlashCoSlashers[rand_name].DangerLevel then
				goto retry
			end --the random slasher's danger level does not match.
		end

		SlashCo.ChooseTheSlasherLobby(rand_name)
	end

	local slasher1id = SlashCo.LobbyData.PickedSlasher
	local slasher2id = GetRandomSlasher()

	print("Now beginning database...")
	if not sql.TableExists("slashco_table_basedata") then
		--Create the database table

		sql.Query("CREATE TABLE slashco_table_basedata(Difficulty NUMBER, SlasherDanger NUMBER, SlasherClass NUMBER, SlasherID TEXT, Offering NUMBER, SlasherIDPrimary TEXT, SlasherIDSecondary TEXT, SurviorGasMod NUMBER);")
		sql.Query("CREATE TABLE slashco_table_survivordata(Survivors TEXT, Item TEXT);")
		sql.Query("CREATE TABLE slashco_table_slasherdata(Slashers TEXT);")
	end

	local allSurvivors = team.GetPlayers(TEAM_SURVIVOR)
	if allSurvivors ~= nil and #allSurvivors > 0 then
		for i = 1, #allSurvivors do
			--Save the Current Survivors to the database

			table.insert(survivors, { steamid = allSurvivors[i]:SteamID64() })
		end
	end

	local allSpectators = team.GetPlayers(TEAM_SPECTATOR)
	if allSpectators ~= nil and SlashCo.LobbyData.AssignedSlashers ~= nil then
		for i = 1, #allSpectators do
			--Save the Current Spectators to the database

			--[[				if team.GetPlayers(TEAM_SPECTATOR)[i]:SteamID64() ~= SlashCo.LobbyData.AssignedSlashers[1].steamid then
								if SlashCo.LobbyData.AssignedSlashers[2] ~= nil and team.GetPlayers(TEAM_SPECTATOR)[i]:SteamID64() ~= SlashCo.LobbyData.AssignedSlashers[2].steamid then
									--They're just a regular Spectator
								end]]

			if allSpectators[i]:SteamID64() == SlashCo.LobbyData.AssignedSlashers[1].steamid then
				--If the Spectator is the Slasher, save them as the Slasher
				table.insert(slashers, { steamid = allSpectators[i]:SteamID64() })
			end
		end
	end

	if SlashCo.LobbyData.AssignedSlashers[2] ~= nil then
		table.insert(slashers, { steamid = SlashCo.LobbyData.AssignedSlashers[2].steamid })
	end

	--Major data dump
	sql.Query("INSERT INTO slashco_table_basedata( Difficulty, SlasherDanger, SlasherClass, SlasherID, Offering, SlasherIDPrimary, SlasherIDSecondary, SurviorGasMod ) VALUES( " .. diff .. ", " .. (SlashCo.LobbyData.SelectedSlasherInfo.DANGER or SlashCo.DangerLevel.Unknown) .. ", " .. (SlashCo.LobbyData.SelectedSlasherInfo.CLASS or SlashCo.DangerLevel.Unknown) .. ", '" .. (SlashCo.LobbyData.SelectedSlasherInfo.ID or 0) .. "', " .. offer .. ", '" .. slasher1id .. "', '" .. slasher2id .. "', " .. survivorgasmod .. " );")

	for _, p in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		--Save the Current Survivors to the database
		local item = p:GetItem("item2")
		if item == "none" then
			item = p:GetItem("item")
		end
		sql.Query("INSERT INTO slashco_table_survivordata( Survivors, Item ) VALUES( " .. p:SteamID64() .. ", " .. sql.SQLStr(item) .. " );")
	end

	if #slashers > 0 then
		for i = 1, #slashers do
			--Save the Current Slashers to the database
			sql.Query("INSERT INTO slashco_table_slasherdata( Slashers ) VALUES( " .. slashers[i].steamid .. " );")
		end
	else
		print("[SlashCo] Error! No assigned Slasher(s) to database! Restarting the lobby...")

		--RunConsoleCommand("debug_datatest_delete")

		--for i, ply in ipairs( player.GetAll() ) do
		--	ply:SetTeam(TEAM_SPECTATOR)
		--	ply:Spawn()
		--end
	end

	print(sql.LastError())
	print("DATA SAVED.")

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
		if readyState == 0 then
			return false
		end
	end

	--If we make it here then everyone has a readystate that isn't 0 and so everyone must be ready
	return true
end

function broadcastLobbyInfo()
	net.Start("mantislashco_GiveLobbyInfo")
		for ply, readyState in pairs(SlashCo.LobbyData.Players) do
			net.WriteEntity(ply)
			net.WriteUInt(readyState, 2)
		end
	net.Broadcast()

	if timer.TimeLeft("AllReadyLobby") ~= nil then
		net.Start("mantislashco_LobbyTimerTime")
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

	SlashCo.ChangeSurvivorItem(player.GetBySteamID64(plyid), id)

	if SlashCoItems[id].OnBuy then
		SlashCoItems[id].OnBuy()
	end
end

--				***Begin the post-ready timer***
local function lobbyReadyTimer(count)
	timer.Create("AllReadyLobby", count, 1, function()
		RunConsoleCommand("lobby_debug_proceed")
	end)
end
--				***Begin the transition timer***
local function lobbyTransitionTimer()
	timer.Create("LobbyTransition", math.max(SlashCo.LobbyBanter(), 10), 1, function()
		RunConsoleCommand("lobby_debug_brief")
		SlashCo.LobbyPlayerBriefing()

		timer.Simple(8, function()
			RunConsoleCommand("lobby_openitems")
		end)
	end)
end
--				***Begin the leaving timer***
local function lobbyLeaveTimer()
	timer.Create("LobbyLeave", 20, 1, function()
		RunConsoleCommand("lobby_leave")
	end)
end

local function BeginSlasherSelection()
	print("Slasher Selecting!")
	
	-- We did this previously clientside, but there's no reason to go server -> client -> server when the client gets no choice.
	if SlashCo.LobbyData.SelectedSlasherInfo.ID ~= 0 then
		SlashCo.ChooseTheSlasherLobby(SlashCo.LobbyData.SelectedSlasherInfo.ID)
		return
	end

	net.Start("mantislashco_PickingSlasher")
		net.WriteTable({
			slashersteamid = SlashCo.LobbyData.AssignedSlashers[1].steamid,
			slashClass = SlashCo.LobbyData.SelectedSlasherInfo.CLASS,
			slashDanger = SlashCo.LobbyData.SelectedSlasherInfo.DANGER,
			bannedSlashers = SlashCo.GetBannedSlashers(true),
		})
	net.Broadcast()
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
		local rand_name = GetRandomSlasher()

		SlashCo.LobbyData.SelectedSlasherInfo.ID = rand
		SlashCo.LobbyData.SelectedSlasherInfo.CLASS = SlashCoSlashers[rand_name].Class
		SlashCo.LobbyData.SelectedSlasherInfo.DANGER = SlashCoSlashers[rand_name].DangerLevel
		SlashCo.LobbyData.SelectedSlasherInfo.NAME = rand_name
		SlashCo.LobbyData.SelectedSlasherInfo.TIP = SlashCoSlashers[rand_name].ProTip

		SlashCo.LobbyData.PickedSlasher = rand_name
	elseif SlashCo.LobbyData.SelectedDifficulty == SlashCo.DifficultyLevel.NOVICE then
		SlashCo.LobbyData.SelectedSlasherInfo.CLASS = math.random(1, #SlashCo.SlasherClass)
	elseif SlashCo.LobbyData.SelectedDifficulty == SlashCo.DifficultyLevel.INTERMEDIATE then
		SlashCo.LobbyData.SelectedSlasherInfo.DANGER = math.random(1, #SlashCo.DangerLevel)
	end

	--SlashCo.LobbyData.DeathwardsLeft = 2 - SlashCo.LobbyData.SelectedDifficulty

	for ply, readyState in pairs(SlashCo.LobbyData.Players) do
		--Setup for assigning that players' in-game teams

		if readyState == 1 then
			table.insert(SlashCo.LobbyData.PotentialSurvivors, { steamid = ply:SteamID64() })
			print("(Debug) " .. ply:GetName() .. " now is a potential Survivor.")
		elseif readyState == 2 then
			table.insert(SlashCo.LobbyData.PotentialSlashers, { steamid = ply:SteamID64() })
			print("(Debug) " .. ply:GetName() .. " now is a potential Slasher.")
		end
	end

	if SlashCo.LobbyData.PotentialSurvivors[1] ~= nil or SlashCo.LobbyData.PotentialSlashers[1] ~= nil then
		--Assigning that players' teams

		if SlashCo.LobbyData.PotentialSlashers[1] == nil then
			--If no none readied as Slasher, the slasher will be randomly picked from the survivor-ready players.

			local randid = math.random(1, #SlashCo.LobbyData.PotentialSurvivors)

			for i = 1, #SlashCo.LobbyData.PotentialSurvivors do
				if i == randid then
					table.insert(SlashCo.LobbyData.AssignedSlashers, { steamid = SlashCo.LobbyData.PotentialSurvivors[i].steamid })
					print("(Debug) " .. player.GetBySteamID64(SlashCo.LobbyData.PotentialSurvivors[i].steamid):GetName() .. " has been assigned Slasher.")
				else
					table.insert(SlashCo.LobbyData.AssignedSurvivors, { steamid = SlashCo.LobbyData.PotentialSurvivors[i].steamid })
					print("(Debug) " .. player.GetBySteamID64(SlashCo.LobbyData.PotentialSurvivors[i].steamid):GetName() .. " has been assigned Survivor.")
				end
			end
		elseif SlashCo.LobbyData.PotentialSurvivors[1] == nil then
			--If no none readied as Survivor, the slasher will be randomly picked from the slasher-ready players.

			local randid = math.random(1, #SlashCo.LobbyData.PotentialSlashers)

			for i = 1, #SlashCo.LobbyData.PotentialSlashers do
				if i == randid then
					table.insert(SlashCo.LobbyData.AssignedSlashers, { steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid })
				else
					table.insert(SlashCo.LobbyData.AssignedSurvivors, { steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid })
				end
			end
		else
			--If the ready states are mixed, pick the slasher from slasher-ready players.

			local randid = math.random(1, #SlashCo.LobbyData.PotentialSlashers)
			for i = 1, #SlashCo.LobbyData.PotentialSlashers do
				if i == randid then
					table.insert(SlashCo.LobbyData.AssignedSlashers, { steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid })
				else
					table.insert(SlashCo.LobbyData.AssignedSurvivors, { steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid })
				end
			end

			for i = 1, #SlashCo.LobbyData.PotentialSurvivors do
				table.insert(SlashCo.LobbyData.AssignedSurvivors, { steamid = SlashCo.LobbyData.PotentialSurvivors[i].steamid })
			end
		end
	end

	--[[if #team.GetPlayers(TEAM_SPECTATOR) < 1 and SlashCo.LobbyData.Offering == SCInfo.Offering.Duality then
		SlashCo.LobbyData.Offering = 0

		for _, play in ipairs(player.GetAll()) do
			play:ChatPrint("[SlashCo] No Spectators, Duality Offering was cleared.")
		end
	end]]

	if SlashCo.LobbyData.Offering == SCInfo.Offering.Duality then
		--Duality Slasher

		local dual_random = 0

		:: reroll ::

		dual_random = math.random(1, #SlashCo.LobbyData.PotentialSlashers)
		local lobbyPlys = team.GetPlayers(TEAM_LOBBY)

		if lobbyPlys[dual_random]:SteamID64() == SlashCo.LobbyData.AssignedSlashers[1].steamid then
			goto reroll
		end

		table.insert(SlashCo.LobbyData.AssignedSlashers, { steamid = lobbyPlys[dual_random]:SteamID64() })

		local p = player.GetBySteamID64(SlashCo.LobbyData.AssignedSlashers[2].steamid)
		p:ChatText("second_slasher")
	end

	--Finalize teams
	if SlashCo.LobbyData.AssignedSurvivors[1] ~= nil and SlashCo.LobbyData.AssignedSlashers[1] ~= nil then
		--print(player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[1].steamid):GetName() .. player.GetBySteamID64(SlashCo.LobbyData.AssignedSlashers[1].steamid):GetName())

		for i = 1, #SlashCo.LobbyData.AssignedSurvivors do
			--The Survivors become survivors

			local ply = player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[i].steamid)
			ply:SetTeam(TEAM_SURVIVOR)
			ply:Spawn()
			ply:SetAvoidPlayers(false) -- Disable being pushed out of players while being in the lobby.

			print("Survivor " .. i .. " selection successful, the Survivor is: " .. ply:GetName())
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

	if SlashCo.LobbyData.SelectedDifficulty > 0 then
		BeginSlasherSelection()
	end
end

net.Receive("mantislashco_SelectSlasher", function(_, ply)
	local rec_id = net.ReadString()
	if SlashCo.IsSlasherBanned(rec_id) then
		print("[SlashCo] \"" .. ply:Name() .. "\" tried to pick a banned slasher! (" .. rec_id .. ")")
		if SlashCo.AwaitPlayerToSelectSlasher then
			SlashCo.AwaitPlayerToSelectSlasher(ply, nil)
		end
		return
	end

	print("[SlashCo] Received. (" .. rec_id .. ")")
	SlashCo.ChooseTheSlasherLobby(rec_id)

	if SlashCo.AwaitPlayerToSelectSlasher then
		SlashCo.AwaitPlayerToSelectSlasher(ply, rec_id)
	end
end)

function SlashCo.ChooseTheSlasherLobby(id)
	if not GameData.IsLobby then return end

	SlashCo.LobbyData.PickedSlasher = id
	print("[SlashCo] Slasher Picked. (" .. id .. ")")

	SlashCo.BroadcastLobbySlasherInformation()
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

			local rdy = readyState
			if rdy > 0 then
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
			RunConsoleCommand("lobby_debug_proceed")
		end

		if (num < 2 or seek <= (num / 2)) and SlashCo.LobbyData.ReadyTimerStarted then
			timer.Remove("AllReadyLobby")
			SlashCo.LobbyData.ReadyTimerStarted = false

			net.Start("mantislashco_LobbyTimerTime")
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

		if (all_players_in or (CurTime() > (SlashCo.LobbyData.ElevatorEnterTime or CurTime()))) and SERVER then
			RunConsoleCommand("lobby_debug_transition")
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

	--[[if id == 4 and #team.GetPlayers(TEAM_SPECTATOR) < 1 then
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

concommand.Add("lobby_debug_proceed", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		return
	end

	SlashCo.LobbyData.LOBBYSTATE = 1
	SlashCo.LobbyData.ElevatorEnterTime = CurTime() + 30 -- It will proceed on its own

	local doors = ents.FindByName("Slashco_Elev_Shutter")
	doors[1]:Fire("Open")
	doors[2]:Fire("Open")

	for ply, readyState in pairs(SlashCo.LobbyData.Players) do
		--If someone is not ready, force them as ready survivor.

		if getReadyState(ply) < 1 then
			lobbyPlayerReadying(ply, 1)
		end
	end

	net.Start("mantislashco_GiveLobbyStatus")
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
end)

concommand.Add("lobby_debug_transition", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		return
	end

	SlashCo.LobbyData.LOBBYSTATE = 2

	local doors = ents.FindByName("Slashco_Elev_Shutter")
	doors[1]:Fire("Close")
	doors[2]:Fire("Close")

	timer.Simple(3, function()
		local elevator = table.Random(ents.FindByName("Slashco_Elev"))
		elevator:Fire("Open")

		lobbyTransitionTimer()
	end)

	net.Start("mantislashco_GiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE, 3)
	net.Broadcast()
end)

concommand.Add("lobby_debug_brief", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		return
	end

	SlashCo.LobbyData.LOBBYSTATE = 3

	local doors = ents.FindByName("Slashco_Elev_Exit")
	doors[1]:Fire("Open")
	doors[2]:Fire("Open")

	net.Start("mantislashco_GiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE, 3)
	net.Broadcast()
end)

concommand.Add("timer_start", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		return
	end

	lobbyReadyTimer(30)
end)

concommand.Add("lobby_openitems", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		return
	end

	local door = table.Random(ents.FindByName("door_itembox"))
	if IsValid(door) then
		door:Fire("Open")
	end
end)

concommand.Add("lobby_leave", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		return
	end

	SlashCo.ClearDatabase()

	timer.Simple(1, function()
		lobbySaveCurData()
	end)
end)

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