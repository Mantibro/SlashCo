local SlashCo = SlashCo

concommand.Add( "lobby_debug_proceed", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then
	
	SlashCo.LobbyData.LOBBYSTATE = 1 

	SlashCo.LobbyData.ButtonDoorPrimary = table.Random(ents.FindByName("door_lobby_primary"))
    SlashCo.LobbyData.ButtonDoorPrimary:Fire("Open")

	for i = 1, #SlashCo.LobbyData.Players do --If someone is not ready, force them as ready survivor.

		local ply = player.GetBySteamID64( SlashCo.LobbyData.Players[i].steamid )

		if getReadyState(ply) < 1 then
			lobbyPlayerReadying(ply, 1)
		end
	end
	if SERVER then
		net.Start("mantislashcoGiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE,3)
		net.Broadcast()
	end

	--ply:ChatPrint("(Debug) Lobby advanced, Finalizing teams...")

	table.Empty( SlashCo.LobbyData.PotentialSlashers )
	table.Empty( SlashCo.LobbyData.PotentialSurvivors )
	table.Empty( SlashCo.LobbyData.AssignedSurvivors )
	table.Empty( SlashCo.LobbyData.AssignedSlashers )

	SlashCo.LobbyData.SelectedSlasherInfo.NAME = "Unknown"
	SlashCo.LobbyData.SelectedSlasherInfo.ID = 0
	SlashCo.LobbyData.SelectedSlasherInfo.CLS = 0
	SlashCo.LobbyData.SelectedSlasherInfo.DNG = 0
	SlashCo.LobbyData.SelectedSlasherInfo.TIP = "--//--"

	lobbyRoundSetup()

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "lobby_debug_transition", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then
	
	SlashCo.LobbyData.LOBBYSTATE = 2

	SlashCo.LobbyData.ButtonDoorPrimary = table.Random(ents.FindByName("door_lobby_primary"))
    SlashCo.LobbyData.ButtonDoorPrimary:Fire("Close")

	lobbyTransitionTimer()
	if SERVER then
		net.Start("mantislashcoGiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE,3)
		net.Broadcast()
	end

	--ply:ChatPrint("(Debug) Lobby transitioning...")

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "lobby_debug_brief", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then
	
	SlashCo.LobbyData.LOBBYSTATE = 3

	SlashCo.LobbyData.ButtonDoorPrimary = table.Random(ents.FindByName("door_lobby_secondary"))
    SlashCo.LobbyData.ButtonDoorPrimary:Fire("Open")

	if SERVER then
		net.Start("mantislashcoGiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE,3)
		net.Broadcast()
	end

	--ply:ChatPrint("(Debug) Lobby now entering Brief Mode...")


	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "timer_start", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then
	
	--ply:ChatPrint("(Debug) Timer started.")

	lobbyReadyTimer(30)

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "lobby_reset", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then
	
	SlashCo.LobbyData.LOBBYSTATE = 0

	table.Empty(SlashCo.LobbyData.ChosenItems)

	SlashCo.LobbyData.ButtonDoorPrimaryClose = table.Random(ents.FindByName("door_lobby_primary"))
    SlashCo.LobbyData.ButtonDoorPrimaryClose:Fire("Close")

	SlashCo.LobbyData.ButtonDoorSecondaryClose = table.Random(ents.FindByName("door_lobby_secondary"))
    SlashCo.LobbyData.ButtonDoorSecondaryClose:Fire("Close")

	timer.Destroy("AllReadyLobby")

	if SERVER then
		net.Start("mantislashcoGiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE,3)
		net.Broadcast()
	end

	ply:ChatPrint("(Debug) Lobby reset.")

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "lobby_openitems", function( ply, cmd, args )
	
	if ply:IsAdmin() or SERVER then

	SlashCo.LobbyData.ButtonDoorPrimaryClose = table.Random(ents.FindByName("door_itembox"))
    SlashCo.LobbyData.ButtonDoorPrimaryClose:Fire("Open")

	ply:ChatPrint("(Debug) Items opened.")

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "lobby_leave", function( ply, cmd, args )
	
	if ply:IsAdmin() or SERVER then

		SlashCo.ClearDatabase()

		timer.Simple(1, function() 
			lobbySaveCurData() 
		end)

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

--Only run this and the removePlayerFromLobby function using the GM:PlayerChangedTeam hook: https://wiki.facepunch.com/gmod/GM:PlayerChangedTeam
function addPlayerToLobby(ply)

	if !table.HasValue(SlashCo.LobbyData.Players, ply:SteamID64()) then table.insert(SlashCo.LobbyData.Players, {steamid = ply:SteamID64(), readyState = 0}) end

	broadcastLobbyInfo()
	
  end

function removePlayerFromLobby(ply)
	local id = ply:SteamID64()
	for _, v in ipairs(SlashCo.LobbyData.Players) do
	  if v.steamid == id then
		--If the steamid in this entry matches the one we're looking for, remove it.
		table.remove(SlashCo.LobbyData.Players, _)
	  end
	end
	broadcastLobbyInfo()
  end

  function lobbyPlayerReadying(ply, state)
	local id = ply:SteamID64()
	for _, v in ipairs(SlashCo.LobbyData.Players) do
	  if v.steamid == id then
		
		SlashCo.LobbyData.Players[_].readyState = state

	  end
	end
  end

function getReadyState(ply)
	local id = ply:SteamID64()

	--Return the player's ReadyState
	for _, v in ipairs(SlashCo.LobbyData.Players) do
		if v.steamid == id then
			return SlashCo.LobbyData.Players[_].readyState
		end
	end

end

function isPlyOfferor(ply)
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
	for _, v in ipairs(SlashCo.LobbyData.Players) do
	  if v.readyState == 0 then
		return false
	  end
	end
	--If we make it here then everyone has a readystate that isn't 0 and so everyone must be ready
	return true
end

function broadcastLobbyInfo()

	net.Start("mantislashcoGiveLobbyInfo")
	net.WriteTable(SlashCo.LobbyData.Players)
	net.Broadcast()

	if timer.TimeLeft( "AllReadyLobby" ) != nil then

		net.Start("mantislashcoLobbyTimerTime")
		net.WriteUInt(  math.floor(	timer.TimeLeft( "AllReadyLobby" ) )	,6)
		net.Broadcast()

	end

end

function GM:PlayerChangedTeam(ply, oldTeam, newTeam)

	if newTeam == TEAM_LOBBY and oldTeam != TEAM_LOBBY then
		addPlayerToLobby(ply)
	end

	if newTeam == TEAM_SPECTATOR and oldTeam != TEAM_SPECTATOR then
		removePlayerFromLobby(ply)
	end

end

function lobbyChooseItem(plyid, id)

	SlashCo.BroadcastGlobalData()

	--Change the survivor's chosen item.

	for _, v in ipairs(SlashCo.CurRound.SurvivorData.Items) do
		if v.steamid == plyid then
		  --If the steamid in this entry matches the one we're looking for, remove it.
		  table.remove(SlashCo.CurRound.SurvivorData.Items, _)
		end
	end

	if table.HasValue(SlashCo.CurRound.SurvivorData.Items, id) == false then
		table.insert(SlashCo.CurRound.SurvivorData.Items, {steamid = plyid, itemid = id})
	else
		for _, v in ipairs(SlashCo.CurRound.SurvivorData.Items) do
			if v.steamid == plyid then
				v.itemid = id
			end
		end
	end

	if id == 1 then SlashCo.LobbyData.SurvivorGasMod = SlashCo.LobbyData.SurvivorGasMod + 1 end --Picking a Fuel Can will reduce how many will spawn during the round.

	if id == 2 then SlashCo.PlayerData[plyid].Lives = SlashCo.PlayerData[plyid].Lives + 1 end

	timer.Simple(0.1, function()

		SlashCo.BroadcastItemData()

	end)

end

--				***Begin the post-ready timer***
function lobbyReadyTimer(count)
	timer.Create( "AllReadyLobby", count, 1, function() if SERVER then RunConsoleCommand("lobby_debug_proceed") end end)
end
--				***Begin the transition timer***
function lobbyTransitionTimer()
	timer.Create( "LobbyTransition", 5, 1, function() if SERVER then 
		RunConsoleCommand("lobby_debug_brief") 
		SlashCo.LobbyPlayerBriefing()

		timer.Simple(8, function() RunConsoleCommand("lobby_openitems") end)
		end 
	end)
end
--				***Begin the leaving timer***
function lobbyLeaveTimer()
	timer.Create( "LobbyLeave", 20, 1, function() if SERVER then RunConsoleCommand("lobby_leave") end end)
end

--				***Assign the values for the incoming Round***
function lobbyRoundSetup()

	if SERVER then

	SlashCo.BroadcastGlobalData()

	SlashCo.CurRound.ConnectedPlayers = SlashCo.LobbyData.Players


	SlashCo.LobbyData.SelectedDifficulty = math.random( 0, 3 ) --Randomizing the Difficulty


	--Difficulty-based Slasher Selection:

	if SlashCo.LobbyData.SelectedDifficulty == 0 then

		local rand = math.random( 1, #SlashCo.SlasherData)

		SlashCo.LobbyData.SelectedSlasherInfo.ID = rand
		SlashCo.LobbyData.SelectedSlasherInfo.CLS = SlashCo.SlasherData[rand].CLS
		SlashCo.LobbyData.SelectedSlasherInfo.DNG = SlashCo.SlasherData[rand].DNG
		SlashCo.LobbyData.SelectedSlasherInfo.NAME = SlashCo.SlasherData[rand].NAME
		SlashCo.LobbyData.SelectedSlasherInfo.TIP = SCInfo.Slasher[rand].ProTip

	elseif SlashCo.LobbyData.SelectedDifficulty == 1 then

		local rand = math.random( 1, #SlashCo.SlasherData)

		SlashCo.LobbyData.SelectedSlasherInfo.CLS = SlashCo.SlasherData[rand].CLS

	elseif SlashCo.LobbyData.SelectedDifficulty == 2 then

		local rand = math.random( 1, #SlashCo.SlasherData)

		SlashCo.LobbyData.SelectedSlasherInfo.DNG = SlashCo.SlasherData[rand].DNG

	end

	for i = 1, #SlashCo.LobbyData.Players do --Setup for assigning that players' in-game teams

		if SlashCo.LobbyData.Players[i].readyState == 1	then

			table.insert(SlashCo.LobbyData.PotentialSurvivors, {steamid = SlashCo.LobbyData.Players[i].steamid})
			print("(Debug) "..player.GetBySteamID64(SlashCo.LobbyData.Players[i].steamid):GetName() .." now is a potential Survivor.")

		elseif SlashCo.LobbyData.Players[i].readyState == 2 then

			table.insert(SlashCo.LobbyData.PotentialSlashers, {steamid = SlashCo.LobbyData.Players[i].steamid})
			print("(Debug) "..player.GetBySteamID64(SlashCo.LobbyData.Players[i].steamid):GetName() .." now is a potential Slasher.")
		
		end

	end

	if SlashCo.LobbyData.PotentialSurvivors[1] != nil or SlashCo.LobbyData.PotentialSlashers[1] != nil then --Assigning that players' teams

		if SlashCo.LobbyData.PotentialSlashers[1] == nil then --If no none readied as Slasher, the slasher will be randomly picked from the survivor-ready players.

			local randid = math.random( 1, #SlashCo.LobbyData.PotentialSurvivors )

			for i = 1, #SlashCo.LobbyData.PotentialSurvivors do 

				if i == randid then

					table.insert(SlashCo.LobbyData.AssignedSlashers, {steamid = SlashCo.LobbyData.PotentialSurvivors[i].steamid})
					print("(Debug) "..player.GetBySteamID64(SlashCo.LobbyData.PotentialSurvivors[i].steamid):GetName() .." has been assigned Slasher.")

				else

					table.insert(SlashCo.LobbyData.AssignedSurvivors, {steamid = SlashCo.LobbyData.PotentialSurvivors[i].steamid})
					print("(Debug) "..player.GetBySteamID64(SlashCo.LobbyData.PotentialSurvivors[i].steamid):GetName() .." has been assigned Survivor.")

				end
		
			end

		elseif SlashCo.LobbyData.PotentialSurvivors[1] == nil then --If no none readied as Survivor, the slasher will be randomly picked from the slasher-ready players.

			local randid = math.random( 1, #SlashCo.LobbyData.PotentialSlashers )

			for i = 1, #SlashCo.LobbyData.PotentialSlashers do 

				if i == randid then

					table.insert(SlashCo.LobbyData.AssignedSlashers, {steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid})

				else

					table.insert(SlashCo.LobbyData.AssignedSurvivors, {steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid})

				end
		
			end

		else --If the ready states are mixed, pick the slasher from slasher-ready players.

			local randid = math.random( 1, #SlashCo.LobbyData.PotentialSlashers)

			for i = 1, #SlashCo.LobbyData.PotentialSlashers do 

				if i == randid then

					table.insert(SlashCo.LobbyData.AssignedSlashers, {steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid})

				else

					table.insert(SlashCo.LobbyData.AssignedSurvivors, {steamid = SlashCo.LobbyData.PotentialSlashers[i].steamid})

				end
		
			end

			for i = 1, #SlashCo.LobbyData.PotentialSurvivors do 

				table.insert(SlashCo.LobbyData.AssignedSurvivors, {steamid = SlashCo.LobbyData.PotentialSurvivors[i].steamid})
		
			end

		end

	end

	if SlashCo.LobbyData.Offering == 4 then --Duality Slasher

		local dual_random = 0

		::reroll::

		dual_random = math.random(1, #team.GetPlayers(TEAM_SPECTATOR))

		if team.GetPlayers(TEAM_SPECTATOR)[dual_random]:SteamID64() == SlashCo.LobbyData.AssignedSlashers[1].steamid then goto reroll end

		table.insert(SlashCo.LobbyData.AssignedSlashers, {	steamid = team.GetPlayers(TEAM_SPECTATOR)[dual_random]:SteamID64()	})

		--SlashCo.LobbyData.AssignedSlashers[2].steamid = team.GetPlayers(TEAM_SPECTATOR)[dual_random]:SteamID64()

		local p = player.GetBySteamID64(SlashCo.LobbyData.AssignedSlashers[2].steamid)
		p:ChatPrint("You will become the second Slasher.")

	end

	--Finalize teams
	if SlashCo.LobbyData.AssignedSurvivors[1] != nil and SlashCo.LobbyData.AssignedSlashers[1] != nil then

		--print(player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[1].steamid):GetName() .. player.GetBySteamID64(SlashCo.LobbyData.AssignedSlashers[1].steamid):GetName())

		for i = 1, #SlashCo.LobbyData.AssignedSurvivors do --The Survivors become survivors

			local ply = player.GetBySteamID64( SlashCo.LobbyData.AssignedSurvivors[i].steamid )

			ply:SetTeam(TEAM_SURVIVOR)
			ply:Spawn()

			--Fill the Items table
			table.insert(SlashCo.CurRound.SurvivorData.Items, {steamid = ply:SteamID64(), itemid = 0})

			print("Survivor "..i.." selection successful, the Survivor is: "..ply:GetName())
	
		end

		for i = 1, #SlashCo.LobbyData.AssignedSlashers do --The Slasher becomes a spectator in the lobby.

			local ply = player.GetBySteamID64( SlashCo.LobbyData.AssignedSlashers[i].steamid )

			ply:SetTeam(TEAM_SPECTATOR)
			ply:Spawn()

			for i, play in ipairs( player.GetAll() ) do
				--play:ChatPrint("(Debug) Slasher selection successful, the Slasher is: "..ply:GetName()) 
			end
	
		end

	end

	--Assign the map randomly
	SlashCo.LobbyData.SelectedMapNum = math.random(1, #SlashCo.Maps)
	--SlashCo.LobbyData.SelectedMapNum = 2

	for i, ply in ipairs( player.GetAll() ) do
		ply:ChatPrint("(Debug) Lobby Setup complete. Difficulty: "..SlashCo.LobbyData.SelectedDifficulty)
	end

	net.Start("mantislashcoSendLobbyItemGlobal") 
	net.WriteTable(SlashCo.SlasherData)
	net.Broadcast()

	BeginSlasherSelection()

	end

end

function BeginSlasherSelection()

	print("Slasher Selecting!")

	net.Start("mantiSlashCoPickingSlasher")
	net.WriteTable({slashersteamid = SlashCo.LobbyData.AssignedSlashers[1].steamid, slashID = SlashCo.LobbyData.SelectedSlasherInfo.ID, slashClass =  SlashCo.LobbyData.SelectedSlasherInfo.CLS, slashDanger =   SlashCo.LobbyData.SelectedSlasherInfo.DNG})
	net.Broadcast()

end

net.Receive("mantiSlashCoSelectSlasher", function()
    
	id = net.ReadUInt(3)

	ChooseTheSlasher(id)

end)

function ChooseTheSlasher(id)

	SlashCo.LobbyData.FinalSlasherID = id

end

net.Receive("mantislashcoPickItem", function()

    t = net.ReadTable()
    
	lobbyChooseItem(t.ply, t.id)

end)

hook.Add("Tick", "LobbyTickEvent", function()

	if game.GetMap() != "sc_lobby" then return end

	if lobby_tick == nil then lobby_tick = 0 end
	lobby_tick = lobby_tick + 1
	if lobby_tick > 33 then lobby_tick = 0 end

	if lobby_tick == 33 and timer.TimeLeft( "AllReadyLobby" ) != nil then 
		broadcastLobbyInfo()
	end

	local num = #SlashCo.LobbyData.Players
	local num_o = #SlashCo.LobbyData.Offerors

	if num_o > 0 and SlashCo.LobbyData.Offering < 1 then

		if num_o > ( num / 2) then 
			SlashCo.OfferingVoteSuccess(SlashCo.LobbyData.VotedOffering)
		end

	end

	if SlashCo.LobbyData.LOBBYSTATE < 1 then

		if SlashCo.LobbyData.ReadyTimerStarted == false then

			local seek = seek

			if num < 2 then return end

			if seek == nil then seek = 0 end

			for p = 1, num do

				local rdy = getReadyState(player.GetBySteamID64(SlashCo.LobbyData.Players[p].steamid))
				if rdy > 0 then seek = seek + 1 end

			end

			if seek >= (num / 2) then 
				SlashCo.LobbyData.ReadyTimerStarted = true
				lobbyReadyTimer(30)
			end

			seek = 0

		end

		if num < 2 and SlashCo.LobbyData.ReadyTimerStarted then 
			timer.Destroy( "AllReadyLobby" )
			SlashCo.LobbyData.ReadyTimerStarted = false
		end

	end

	if SlashCo.LobbyData.LOBBYSTATE == 1 then

		if #SlashCo.LobbyData.AssignedSurvivors == Check and Check > 0 and SERVER then 
			RunConsoleCommand("lobby_debug_transition") 
		end

		local minx = -1520
		local maxx = -1360
		local miny = -270
		local maxy = -140

		for i = 1, #SlashCo.LobbyData.AssignedSurvivors do

			local x = player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[i].steamid):GetPos()[1]
			local y = player.GetBySteamID64(SlashCo.LobbyData.AssignedSurvivors[i].steamid):GetPos()[2]

				if i == 1 then 
					if (x > minx and x < maxx) and (y > miny and y < maxy) then P1Check = 1 else P1Check = 0 end
				end
				if i == 2 then 
					if (x > minx and x < maxx) and (y > miny and y < maxy) then P2Check = 1 else P2Check = 0 end
				end
				if i == 3 then 
					if (x > minx and x < maxx) and (y > miny and y < maxy) then P3Check = 1 else P3Check = 0 end
				end
				if i == 4 then 
					if (x > minx and x < maxx) and (y > miny and y < maxy) then P4Check = 1 else P4Check = 0 end
				end

		end

	else
		P1Check = 0
		P2Check = 0
		P3Check = 0
		P4Check = 0
	end

	if P1Check == nil then P1Check = 0 end
	if P2Check == nil then P2Check = 0 end
	if P3Check == nil then P3Check = 0 end
	if P4Check == nil then P4Check = 0 end

	Check = P1Check + P2Check + P3Check + P4Check

end)

hook.Add( "PlayerDisconnected", "Playerleave", function(ply) --If a player disconnects after the Lobby stage is underway, reset the lobby.
    if game.GetMap() == "sc_lobby" then

		if SlashCo.LobbyData.LOBBYSTATE > 0 then

			if ply:Team() == TEAM_SURVIVOR then

				ply:ChatPrint("[SlashCo] A Survivor has left during the Lobby Setup! Lobby will now reset.")
				if SERVER then RunConsoleCommand("lobby_reset") end

				for i, play in ipairs( player:GetAll() ) do
					play:SetTeam(TEAM_SPECTATOR)
					play:Spawn()
				end

			end

			if ply:SteamID64() == SlashCo.LobbyData.AssignedSlashers[1].steamid or ply:SteamID64() == SlashCo.LobbyData.AssignedSlashers[2].steamid then

				ChatPrint("[SlashCo] The Slasher has left during the Lobby Setup! Lobby will now reset.")
				if SERVER then RunConsoleCommand("lobby_reset") end

				for i, play in ipairs( player.GetAll() ) do
					play:SetTeam(TEAM_SPECTATOR)
					play:Spawn()
				end

			end

		end

		if ply:Team() == TEAM_LOBBY then removePlayerFromLobby(ply) end

	end

end )

function lobbySaveCurData()

	local diff = SlashCo.LobbyData.SelectedDifficulty
	local offer = SlashCo.LobbyData.Offering
	local survivorgasmod = SlashCo.LobbyData.SurvivorGasMod
	local survivors = {}
	local slashers = {}

	if SERVER then

	--Clear the database before saving
	--RunConsoleCommand("debug_datatest_delete")

	if SlashCo.LobbyData.FinalSlasherID == 0 then --If the slasher wasn't selected, randomize it based on possible options

		::retry::

		local rand = math.random(1, #SlashCo.SlasherData) --random id for this roll

		if SlashCo.LobbyData.SelectedSlasherInfo.CLS == 0 then --Check if the random id of slasher has the appropriate class for the difficulty

			--The difficulty allows for any class.

		else

			if SlashCo.LobbyData.SelectedSlasherInfo.CLS != SlashCo.SlasherData[rand].CLS then goto retry end --the random slasher's class does not match.

		end

		if SlashCo.LobbyData.SelectedSlasherInfo.DNG == 0 then --Check if the random id of slasher has the appropriate danger level for the difficulty

			--The difficulty allows for any danger level.

		else

			if SlashCo.LobbyData.SelectedSlasherInfo.DNG != SlashCo.SlasherData[rand].DNG then goto retry end --the random slasher's danger level does not match.

		end

		ChooseTheSlasher(rand) 
		
	end 

	local slasher1id = SlashCo.LobbyData.FinalSlasherID
	local slasher2id = math.random(1, #SlashCo.SlasherData)

	print("Now beginning database...")

	if !sql.TableExists( "slashco_table_basedata" ) then --Create the database table

		sql.Query("CREATE TABLE slashco_table_basedata(Difficulty NUMBER , Offering NUMBER , SlasherIDPrimary NUMBER , SlasherIDSecondary NUMBER , SurviorGasMod NUMBER);" )
		sql.Query("CREATE TABLE slashco_table_survivordata(Survivors TEXT, Item NUMBER);" )
		sql.Query("CREATE TABLE slashco_table_slasherdata(Slashers TEXT);" )
	
	end


	if team.GetPlayers(TEAM_SURVIVOR) != nil and #team.GetPlayers(TEAM_SURVIVOR) > 0 then
		for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do --Save the Current Survivors to the database

			table.insert(survivors, {steamid = team.GetPlayers(TEAM_SURVIVOR)[i]:SteamID64()})

		end

	else

		--ChatPrint("[SlashCo] ERROR! Survivor team empty! Could not database!")

	end

	if team.GetPlayers(TEAM_SPECTATOR) != nil and SlashCo.LobbyData.AssignedSlashers != nil then
		for i = 1, #team.GetPlayers(TEAM_SPECTATOR) do --Save the Current Spectators to the database

			if team.GetPlayers(TEAM_SPECTATOR)[i]:SteamID64() != SlashCo.LobbyData.AssignedSlashers[1].steamid then

				if SlashCo.LobbyData.AssignedSlashers[2] != nil and team.GetPlayers(TEAM_SPECTATOR)[i]:SteamID64() != SlashCo.LobbyData.AssignedSlashers[2].steamid then

					--They're just a regular Spectator

				end

			else

				--If the Spectator is the Slasher, save them as the Slasher
				table.insert(slashers, {steamid = team.GetPlayers(TEAM_SPECTATOR)[i]:SteamID64()})

			end

		end

	else

		--ChatPrint("[SlashCo] ERROR! Could not database the Slasher!")

	end

	if SlashCo.LobbyData.AssignedSlashers[2] != nil then

		table.insert(slashers, {steamid = SlashCo.LobbyData.AssignedSlashers[2].steamid})

	end

	--Major data dump SOON: Duality
	sql.Query("INSERT INTO slashco_table_basedata( Difficulty, Offering, SlasherIDPrimary, SlasherIDSecondary, SurviorGasMod ) VALUES( "..diff..", "..offer..", "..slasher1id..", "..slasher2id..", "..survivorgasmod.." );")

	for i = 1, #SlashCo.CurRound.SurvivorData.Items do --Save the Current Survivors to the database

		sql.Query("INSERT INTO slashco_table_survivordata( Survivors, Item ) VALUES( "..SlashCo.CurRound.SurvivorData.Items[i].steamid..", "..SlashCo.CurRound.SurvivorData.Items[i].itemid.." );")

	end

	if #slashers > 0 then

		for i = 1, #slashers do --Save the Current Slashers to the database

			sql.Query("INSERT INTO slashco_table_slasherdata( Slashers ) VALUES( "..slashers[i].steamid.." );")

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

	SlashCo.ChangeMap(SlashCo.Maps[SlashCo.LobbyData.SelectedMapNum].ID)

	end

end

concommand.Add( "debug_datatest_read", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then

	print("basedata: ")
	PrintTable( sql.Query("SELECT * FROM slashco_table_basedata; ") )
	print("survivordata: ")
	PrintTable( sql.Query("SELECT * FROM slashco_table_survivordata; ") )
	print("slasherdata: ")
	PrintTable( sql.Query("SELECT * FROM slashco_table_slasherdata; ") )

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "debug_datatest_error", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then

	print(sql.LastError())

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

concommand.Add( "debug_datatest_delete", function( ply, cmd, args )

	if ply:IsAdmin() or SERVER then

		SlashCo.ClearDatabase()

	else

	ply:ChatPrint("Only admins can use debug commands!")

	end

end )

function lobbyFinish() 

	if SlashCo.LobbyData.LOBBYSTATE == 4 then return end

	SlashCo.LobbyData.LOBBYSTATE = 4

	print("Helicopter now ready to depart!")

	timer.Simple(1.5, function()

		SlashCo.CurRound.HelicopterTargetPosition = Vector(SlashCo.CurRound.HelicopterTargetPosition[1]+1500,SlashCo.CurRound.HelicopterTargetPosition[2],SlashCo.CurRound.HelicopterTargetPosition[3]+400)

	end)

	timer.Simple(4, function()

		SlashCo.StartGameIntro()

		lobbyLeaveTimer()

	end)

end