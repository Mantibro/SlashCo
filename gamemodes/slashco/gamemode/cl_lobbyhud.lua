include( "ui/fonts.lua" )

net.Receive( "mantislashcoLobbyTimerTime", function( len, ply )
	TimeLeft = net.ReadUInt(6)
end)

net.Receive( "mantislashcoGiveLobbyStatus", function( len, ply )
	StateOfLobby = net.ReadUInt(3)	
end)

net.Receive( "mantislashcoGiveLobbyInfo", function( len, ply )
	LobbyInfoTable = net.ReadTable()
end)

hook.Add("HUDPaint", "LobbyInfoText", function()

	net.Receive( "mantislashcoGiveMasterDatabase", function( len, ply )
		local t = net.ReadTable()
		if t[1].PlayerID != LocalPlayer():SteamID64() then return end
		data_load = t
	end)

	if game.GetMap() != "sc_lobby" then return end

	if stop_lobbymusic != true and (lobbymusic_antispam == nil or lobbymusic_antispam != true) then  
		lobby_music = CreateSound(LocalPlayer(), "slashco/music/slashco_lobby.wav")
		lobby_music:Play()
		lobbymusic_antispam = true 
	end

	if stop_lobbymusic then lobby_music:Stop() end

	local point_count = 0
	local srvwin_count = 0
	local slswin_count = 0

	if data_load != nil and data_load != false then

		point_count = data_load[1].Points
		srvwin_count = data_load[1].SurvivorRoundsWon
		slswin_count = data_load[1].SlasherRoundsWon

	end

	local scrW, scrH = ScrW(), ScrH()

	draw.SimpleText( "You have "..point_count.." Points.", "LobbyFont1", ScrW() * 0.025, (ScrH() * 0.05), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "You have won "..srvwin_count.." Rounds as SURVIVOR.", "LobbyFont1", ScrW() * 0.025, (ScrH() * 0.08), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "You have won "..slswin_count.." Rounds as SLASHER.", "LobbyFont1", ScrW() * 0.025, (ScrH() * 0.11), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	if StateOfLobby == nil or StateOfLobby < 1 then 
		draw.SimpleText( " \" , \" to switch between player / spectator", "LobbyFont1", scrW * 0.975, (scrH * 0.93), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP ) 
	end

	if LocalPlayer():Team() == TEAM_LOBBY then

		draw.SimpleText( "R to choose Playermodel", "LobbyFont1", scrW * 0.975, (scrH * 0.9), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP ) 

	end

if StateOfLobby != nil and StateOfLobby < 1 then --DISPLAY THE HUD BELOW ONLY IN THE LOBBY

	local Tablet = Material("slashco/ui/lobby_backdrop")
	local ReadyCheck = Material("slashco/ui/lobby_ready")
	local UnReadyCheck = Material("slashco/ui/lobby_unready")
	
	clientname = LocalPlayer():GetName()

	local Lobby_Players = {}

	local isClientinLobby = false

	for i = 1, #LobbyInfoTable do

		if not IsValid(player.GetBySteamID64( LobbyInfoTable[i].steamid )) then return end

		if not table.HasValue(Lobby_Players, {ID = LobbyInfoTable[i].steamid}) then 
			table.insert(Lobby_Players, { ID = LobbyInfoTable[i].steamid, Name = player.GetBySteamID64( LobbyInfoTable[i].steamid ):GetName(), Ready = LobbyInfoTable[i].readyState })
		end

		if Lobby_Players[i].Name == clientname then			
			clientReadiness = LobbyInfoTable[i].readyState
			isClientinLobby = true
		end

	end
	
	if isClientinLobby then

		surface.SetDrawColor(255,255,255,255)	

		surface.SetMaterial(Tablet)
		surface.DrawTexturedRect(-ScrW()/15, ScrH()/50, ScrW()/2.5, ScrW()/2.5)
	
		draw.SimpleText( "Press F1 to ready as Survivor.", "LobbyFont1", scrW * 0.975, (scrH * 0.5)+300, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	
		draw.SimpleText( "Press F2 to ready as Slasher.", "LobbyFont1", scrW * 0.975, (scrH * 0.5)+350, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	
		if TimeLeft != nil and TimeLeft > 0 and TimeLeft < 61 then
			draw.SimpleText( "Starting in: "..tostring( TimeLeft ).." seconds. . .", "LobbyFont2", scrW * 0.5, (scrH * 0.65), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end

		for i = 1, #Lobby_Players do

			local pos_y = 0.27
			if i == 2 then pos_y = 0.333 end
			if i == 3 then pos_y = 0.395 end
			if i == 4 then pos_y = 0.457 end
			if i == 5 then pos_y = 0.52 end

			draw.SimpleText( Lobby_Players[i].Name, "PlayersFont", scrW * 0.025, (scrH * pos_y), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

		end

		surface.SetDrawColor(255,255,255,255)	

		for i = 1, #Lobby_Players do

			local iconsize = ScrW()/45
			local x_pos = ScrW()/4.55
			local y_pos = ScrH()/3.8

			if i == 2 then y_pos = ScrH()/3.068 end
			if i == 3 then y_pos = ScrH()/2.57 end
			if i == 4 then y_pos = ScrH()/2.21 end
			if i == 5 then y_pos = ScrH()/1.945 end

			if Lobby_Players[i].Ready > 0 then
				surface.SetMaterial(ReadyCheck)
				surface.DrawTexturedRect(x_pos, y_pos, iconsize, iconsize)
			else
				surface.SetMaterial(UnReadyCheck)
				surface.DrawTexturedRect(x_pos, y_pos, iconsize, iconsize)
			end

		end
	
	end
	
	if clientReadiness != nil then
		
		if clientReadiness < 1 then
	
			draw.SimpleText( "You are not Ready.", "LobbyFont1", scrW * 0.025, scrH * 0.8, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
		end
		if clientReadiness == 1 then
	
			draw.SimpleText( "You are Ready as SURVIVOR.", "LobbyFont1", scrW * 0.025, scrH * 0.8, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
		end
		if clientReadiness == 2 then
	
			draw.SimpleText( "You are Ready as SLASHER.", "LobbyFont1", scrW * 0.025, scrH * 0.8, Color( 255, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
		end
	
	end

end

end)