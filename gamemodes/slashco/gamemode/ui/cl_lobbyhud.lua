local grey = Color(128, 128, 128)
local red = Color(255, 64, 64)
local green = Color(64, 255, 64)

net.Receive("mantislashco_LobbyTimerTime", function()
	GameData.TimeLeft = net.ReadUInt(6)
end)

net.Receive("mantislashco_GiveLobbyStatus", function()
	GameData.StateOfLobby = net.ReadUInt(3)
end)

local longest_name, plynum, clientReadiness, Lobby_Players
local isClientinLobby = false
local function UpdateLobbyState()
	Lobby_Players = {}
	for _, v in ipairs(GameData.LobbyInfoTable) do
		local ply = player.GetBySteamID64(v.steamid)

		if not IsValid(ply) then
			continue
		end

		if not table.HasValue(Lobby_Players, { ID = v.steamid }) then
			table.insert(Lobby_Players, { ID = v.steamid, Name = ply:GetName(), Ready = v.readyState })
		end

		if v.steamid == GameData.LocalSteamID64 then
			clientReadiness = v.readyState
			isClientinLobby = true
		end
	end

	longest_name = longest_name or 0
	if not plynum or plynum ~= #Lobby_Players then
		longest_name = 0
		plynum = #Lobby_Players
	end
end

net.Receive("mantislashco_GiveLobbyInfo", function()
	GameData.LobbyInfoTable = net.ReadTable()

	UpdateLobbyState()
end)

hook.Add("HUDDrawTargetID", "SlashCoLobbyNames", function()
	if not GameData.IsLobby then return false end

	return GameData.StateOfLobby and GameData.StateOfLobby < 1
end)

local ReadyCheck = Material("slashco/ui/lobby_ready")
local UnReadyCheck = Material("slashco/ui/lobby_unready")

hook.Add("HUDPaint", "LobbyInfoText", function()
	if not GameData.IsLobby then return end

	local localPly = GameData.LocalPlayer

	local scrW, scrH = ScrW(), ScrH()
	local point_count = localPly:GetNW2Int("Points", 0)
	local localTeam = localPly:Team()

	if localTeam != TEAM_SPECTATOR then
		draw.SimpleText("[" .. point_count .. " " .. SlashCo.Language("PointCount") .. "]",
				"TVCD", ScrW() * 0.025, ScrH() * 0.05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	--LobbyFont1
	if localTeam == TEAM_LOBBY then
		if GameData.StateOfLobby == nil or GameData.StateOfLobby < 1 then
			draw.SimpleText("[,] " .. SlashCo.Language("ToggleSpectate"), "TVCD", scrW * 0.975, (scrH * 0.95) - 50,
					color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		end

		draw.SimpleText("[R] " .. SlashCo.Language("SelectPlayermodel"), "TVCD", scrW * 0.975, (scrH * 0.95) - 80,
				color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	if GameData.StateOfLobby and GameData.StateOfLobby < 1 then
		if not clientReadiness or not Lobby_Players then
			UpdateLobbyState()
		end

		longest_name = longest_name or 0
		if not plynum or plynum ~= #Lobby_Players then
			longest_name = 0
			plynum = #Lobby_Players
		end

		CL_LobbyPlayers = plynum

		if isClientinLobby then
			surface.SetDrawColor(255, 255, 255, 255)

			draw.SimpleText("[F1] " .. SlashCo.Language("ReadyAs", string.upper(SlashCo.Language("Survivor"))), "TVCD",
					scrW * 0.975, (scrH * 0.95) - 130, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("[F2] " .. SlashCo.Language("ReadyAs", string.upper(SlashCo.Language("Slasher"))), "TVCD",
					scrW * 0.975, (scrH * 0.95) - 160, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

			if GameData.TimeLeft and GameData.TimeLeft > 0 and GameData.TimeLeft < 61 then
				draw.SimpleText(tostring(GameData.TimeLeft), "LobbyFont2", scrW * 0.5, scrH * 0.65, color_white,
						TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			local mul_y = 1
			draw.SimpleText("[" .. plynum .. "/" .. GameData.MaxPlayers .. "] ", "TVCD", scrW * 0.025, scrH * 0.22, color_white, TEXT_ALIGN_LEFT,
					TEXT_ALIGN_TOP)

			for i = 1, #Lobby_Players do
				local lobbyPly = Lobby_Players[i]
				local pos_y = 0.27
				local x_pos = scrW * 0.025
				local iconsize = ScrW() / 45

				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(scrW * 0.018, (scrH * (pos_y * mul_y)) - 18, longest_name + 65, 60)
				surface.SetDrawColor((lobbyPly.Ready == 2 and 50 or 0) + 50, (lobbyPly.Ready == 1 and 50 or 0) + 50, 50)
				surface.DrawOutlinedRect(scrW * 0.018, (scrH * (pos_y * mul_y)) - 18, longest_name + 65, 60, 3)

				if string.len(lobbyPly.Name) * 15 > longest_name then
					longest_name = string.len(Lobby_Players[i].Name) * 15
				end

				draw.SimpleText(lobbyPly.Name, "PlayersFont", scrW * 0.025, scrH * (pos_y * mul_y),
						color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

				local icon_pos_x = x_pos + longest_name
				local icon_pos_y = (scrH * (pos_y * mul_y)) - 8

				surface.SetDrawColor(255, 255, 255, 255)
				if Lobby_Players[i].Ready > 0 then
					surface.SetMaterial(ReadyCheck)
				else
					surface.SetMaterial(UnReadyCheck)
				end

				surface.DrawTexturedRect(icon_pos_x, icon_pos_y, iconsize, iconsize)

				mul_y = mul_y + 0.25
			end

			if clientReadiness then
				if clientReadiness < 1 then
					draw.SimpleText("	   [" .. SlashCo.Language("NotReady") .. "]", "TVCD", scrW * 0.045,
							scrH * 0.22, grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				elseif clientReadiness == 1 then
					draw.SimpleText("	   [" .. SlashCo.Language("ReadyAs",
							string.upper(SlashCo.Language("Survivor"))) .. "]", "TVCD", scrW * 0.045, scrH * 0.22,
							green, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				elseif clientReadiness == 2 then
					draw.SimpleText("	   [" .. SlashCo.Language("ReadyAs",
							string.upper(SlashCo.Language("Slasher"))) .. "]", "TVCD", scrW * 0.045, scrH * 0.22, red,
							TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
			end
		end
	end
end)