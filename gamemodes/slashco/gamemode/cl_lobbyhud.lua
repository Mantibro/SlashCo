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

net.Receive( "mantislashcoGiveMasterDatabase", function( len, ply )

local t = net.ReadTable()

	timer.Simple(4, function()

		if t[1].PlayerID != LocalPlayer():SteamID64() then return end

		data_load = t

	end)

end)

hook.Add("HUDPaint", "LobbyInfoText", function()

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
		draw.SimpleText( " \" , \" to switch teams.", "LobbyFont2", scrW * 0.975, (scrH * 0.5)+425, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP ) 
	end

if StateOfLobby != nil and StateOfLobby < 1 then --DISPLAY THE HUD BELOW ONLY IN THE LOBBY

	local Tablet = Material("slashco/ui/lobby_backdrop")
	local ReadyCheck = Material("slashco/ui/lobby_ready")
	local UnReadyCheck = Material("slashco/ui/lobby_unready")
	
	clientname = LocalPlayer():GetName()
	
	if LobbyInfoTable[1] != nil then

		if not IsValid(player.GetBySteamID64( LobbyInfoTable[1].steamid )) then return end
	
		Player1 = player.GetBySteamID64( LobbyInfoTable[1].steamid ):GetName()
		Player1Yes = 1
	
		if LobbyInfoTable[1].readyState < 1 then
			Player1Readiness = 0
		else
			Player1Readiness = 1
		end
	else
		Player1 = ""
		Player1Readiness = 0
		Player1Yes = 0
	end
	
	if LobbyInfoTable[2] != nil then

		if not IsValid(player.GetBySteamID64( LobbyInfoTable[2].steamid )) then return end
	
		Player2 = player.GetBySteamID64( LobbyInfoTable[2].steamid ):GetName()
		Player2Yes = 1
	
		if LobbyInfoTable[2].readyState < 1 then
			Player2Readiness = 0
		else
			Player2Readiness = 1
		end
	else
		Player2 = ""
		Player2Readiness = 0
		Player2Yes = 0
	end
	
	if LobbyInfoTable[3] != nil then

		if not IsValid(player.GetBySteamID64( LobbyInfoTable[3].steamid )) then return end
	
		Player3 = player.GetBySteamID64( LobbyInfoTable[3].steamid ):GetName()
		Player3Yes = 1
	
		if LobbyInfoTable[1].readyState < 1 then
			Player3Readiness = 0
		else
			Player3Readiness = 1
		end
	else
		Player3 = ""
		Player3Readiness = 0
		Player3Yes = 0
	end
	
	if LobbyInfoTable[4] != nil then

		if not IsValid(player.GetBySteamID64( LobbyInfoTable[4].steamid )) then return end
	
		Player4 = player.GetBySteamID64( LobbyInfoTable[4].steamid ):GetName()
		Player4Yes = 1

		if LobbyInfoTable[1].readyState < 1 then
			Player4Readiness = 0
		else
			Player4Readiness = 1
		end
	else
		Player4 = ""
		Player4Readiness = 0
		Player4Yes = 0
	end
	
	if LobbyInfoTable[5] != nil then

		if not IsValid(player.GetBySteamID64( LobbyInfoTable[5].steamid )) then return end
	
		Player5 = player.GetBySteamID64( LobbyInfoTable[5].steamid ):GetName()
		Player5Yes = 1
	
		if LobbyInfoTable[1].readyState < 1 then
			Player5Readiness = 0
		else
			Player5Readiness = 0
		end
	else
		Player5 = ""
		Player5Readiness = 0
		Player5Yes = 0
	end
	
	if LobbyInfoTable != nil then
	
		for i = 1,5 do
	
			if LobbyInfoTable[i] != nil then

				if LobbyInfoTable[i].steamid == 0 or LobbyInfoTable[i].steamid == nil then return end
	
				if player.GetBySteamID64( LobbyInfoTable[i].steamid ):GetName() == clientname then
			
					clientReadiness = LobbyInfoTable[i].readyState
	
					isClientinLobby = true break
	
				else
	
					isClientinLobby = false
	
				end
	
			end
	
		end

	end
	
	if isClientinLobby then

		surface.SetDrawColor(255,255,255,255)	

		surface.SetMaterial(Tablet)
		surface.DrawTexturedRect(-ScrW()/15, ScrH()/50, ScrW()/2.5, ScrW()/2.5)
	
		draw.SimpleText( "Press F1 to ready as Survivor.", "LobbyFont1", scrW * 0.975, (scrH * 0.5)+300, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	
		draw.SimpleText( "Press F2 to ready as Slasher.", "LobbyFont1", scrW * 0.975, (scrH * 0.5)+350, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	
		if TimeLeft != nil and TimeLeft > 0 then
			draw.SimpleText( "Starting in: "..tostring( TimeLeft ).." seconds. . .", "LobbyFont2", scrW * 0.5, (scrH * 0.25), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end

		draw.SimpleText( Player1, "LobbyFont1", scrW * 0.025, (scrH * 0.27), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( Player2, "LobbyFont1", scrW * 0.025, (scrH * 0.333), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( Player3, "LobbyFont1", scrW * 0.025, (scrH * 0.395), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( Player4, "LobbyFont1", scrW * 0.025, (scrH * 0.457), Color( 255, 255, 255, 2555 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( Player5, "LobbyFont1", scrW * 0.025, (scrH * 0.52), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )


		surface.SetDrawColor(255,255,255,255)	

		surface.SetMaterial(ReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/3.8, ScrW()/45, Player1Yes*Player1Readiness*ScrW()/45)

		surface.SetMaterial(UnReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/3.8, ScrW()/45, Player1Yes*(1-Player1Readiness)*ScrW()/45)

		surface.SetMaterial(ReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/3.068, ScrW()/45, Player2Yes*Player2Readiness*ScrW()/45)

		surface.SetMaterial(UnReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/3.068, ScrW()/45, Player2Yes*(1-Player2Readiness)*ScrW()/45)

		surface.SetMaterial(ReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/2.57, ScrW()/45, Player3Yes*Player3Readiness*ScrW()/45)

		surface.SetMaterial(UnReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/2.57, ScrW()/45, Player3Yes*(1-Player3Readiness)*ScrW()/45)

		surface.SetMaterial(ReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/2.21, ScrW()/45, Player4Yes*Player4Readiness*ScrW()/45)

		surface.SetMaterial(UnReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/2.21, ScrW()/45, Player4Yes*(1-Player4Readiness)*ScrW()/45)

		surface.SetMaterial(ReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/1.945, ScrW()/45, Player5Yes*Player5Readiness*ScrW()/45)

		surface.SetMaterial(UnReadyCheck)
		surface.DrawTexturedRect(ScrW()/4.55, ScrH()/1.945, ScrW()/45, Player5Yes*(1-Player5Readiness)*ScrW()/45)
	
	end
	
	if clientReadiness != nil then
		
		if clientReadiness < 1 then
	
			draw.SimpleText( "You are not Ready.", "LobbyFont1", scrW * 0.025, scrH * 0.225, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
		end
		if clientReadiness == 1 then
	
			draw.SimpleText( "You are Ready as SURVIVOR.", "LobbyFont1", scrW * 0.025, scrH * 0.225, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
		end
		if clientReadiness == 2 then
	
			draw.SimpleText( "You are Ready as SLASHER.", "LobbyFont1", scrW * 0.025, scrH * 0.225, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
		end
	
	end
	
	surface.SetFont( "LobbyFont1" )
	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( scrW * 0.25, scrH * 0.25 ) 

end

end)