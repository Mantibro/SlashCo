local grey = Color(128, 128, 128)
local red = Color(255, 64, 64)
local green = Color(64, 255, 64)

net.Receive("SlashCo:LobbyTimerTime", function()
	GameData.TimeLeft = net.ReadUInt(6)
end)

net.Receive("SlashCo:GiveLobbyStatus", function()
	GameData.StateOfLobby = net.ReadUInt(3)
end)

local longest_name, plynum, clientReadiness, Lobby_Players
local isClientinLobby = false
local function UpdateLobbyState()
	Lobby_Players = {}
	for ply, readyState in pairs(GameData.LobbyInfoTable) do
		if not IsValid(ply) then
			continue
		end

		if not Lobby_Players[ply] then
			table.insert(Lobby_Players, { ID = ply:SteamID64(), Name = ply:GetName(), Ready = readyState })
			Lobby_Players[ply] = true
		end

		if ply == GameData.LocalPlayer then
			clientReadiness = readyState
			isClientinLobby = true
		end
	end

	for _, lobbyPly in ipairs(Lobby_Players) do
		local length = string.len(lobbyPly.Name)
		if length > 20 then
			length = 20
			lobbyPly.Name = lobbyPly.Name:sub(0, 20)
			lobbyPly.Name = lobbyPly.Name .. "..."
		end
		
		if (length * 15) > (longest_name or 0) then
			longest_name = length * 14
		end
	end

	longest_name = longest_name or 0
	plynum = #Lobby_Players
end

net.Receive("SlashCo:GiveLobbyInfo", function(len)
	GameData.LobbyInfoTable = {} -- We only use GameData.LobbyInfoTable in this file.

	local entities = len / (MAX_EDICT_BITS + 2) -- +2 because of the uint we write
	for k=1, entities do
		GameData.LobbyInfoTable[net.ReadEntity()] = net.ReadUInt(2)
	end

	UpdateLobbyState()
end)

hook.Add("HUDDrawTargetID", "SlashCoLobbyNames", function()
	if not GameData.IsLobby then return false end

	return GameData.StateOfLobby and GameData.StateOfLobby < 1
end)

local ReadyCheck = Material("slashco/ui/lobby_ready")
local UnReadyCheck = Material("slashco/ui/lobby_unready")

hook.Add("SlashCo:DrawHUD", "LobbyInfoText", function()
	if not GameData.IsLobby then return end

	local localPly = GameData.LocalPlayer

	local scrW, scrH = ScrW(), ScrH()
	local localTeam = localPly:Team()
	if localTeam == TEAM_SPECTATOR then return end

	local _, pointsSize = draw.SimpleText("[" .. localPly:GetPoints() .. " " .. SlashCo.Language("PointCount") .. "]",
		"TVCD", ScrW() * 0.025, ScrH() * 0.05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	local lvl, ep, nextLevelEP = SlashCo.ExperienceToLevel(localPly:GetExperience())
	draw.SimpleText("[" .. lvl .. " LVL - " .. ep .. "/" .. nextLevelEP .. "EP]",
		"TVCD", ScrW() * 0.025, (ScrH() * 0.05) + pointsSize + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	--LobbyFont1
	if localTeam == TEAM_LOBBY then
		if GameData.StateOfLobby == nil or GameData.StateOfLobby < 1 then
			draw.SimpleText("[Q] " .. SlashCo.Language("ToggleSpectate"), "TVCD", scrW * 0.975, (scrH * 0.95) - 50,
					color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		end

		draw.SimpleText("[R] " .. SlashCo.Language("SelectPlayermodel"), "TVCD", scrW * 0.975, (scrH * 0.95) - 80,
				color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	if GameData.StateOfLobby and GameData.StateOfLobby < 1 then
		if not clientReadiness or not Lobby_Players then
			UpdateLobbyState()
		end

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

			local currentYPos = scrH * 0.22
			local width, height = draw.SimpleText("[" .. plynum .. "/" .. GameData.MaxPlayers .. "] ", "TVCD", scrW * 0.025, currentYPos, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			if clientReadiness then
				if clientReadiness == SlashCo.ReadyState.NotReady then
					draw.SimpleText("[" .. SlashCo.Language("NotReady") .. "]", "TVCD", scrW * 0.025 + width, currentYPos,
						grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				elseif clientReadiness == SlashCo.ReadyState.Survivor then
					draw.SimpleText("[" .. SlashCo.Language("ReadyAs",
						string.upper(SlashCo.Language("Survivor"))) .. "]", "TVCD", scrW * 0.025 + width, currentYPos,
						green, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				elseif clientReadiness == SlashCo.ReadyState.Slasher then
					draw.SimpleText("[" .. SlashCo.Language("ReadyAs",
						string.upper(SlashCo.Language("Slasher"))) .. "]", "TVCD", scrW * 0.025 + width, currentYPos,
						red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
			end

			currentYPos = currentYPos + height

			local lobbyPlayerCount = #Lobby_Players
			local boxSize = 55
			local screenHeight = ScrH()
			if (GameData.CachedLobbyPlayerListCount or -1) == lobbyPlayerCount then
				boxSize = GameData.CachedLobbyPlayerListSize
			else
				while screenHeight < (currentYPos + ((boxSize + 5) * lobbyPlayerCount)) and boxSize != 15 do
					boxSize = boxSize > 15 and (boxSize - 1) or boxSize
				end
				GameData.CachedLobbyPlayerListCount = lobbyPlayerCount
				GameData.CachedLobbyPlayerListSize = boxSize
			end

			local iconsize = boxSize - 10 -- Icons always have a padding
			for i = 1, lobbyPlayerCount do
				local lobbyPly = Lobby_Players[i]
				local x_pos = scrW * 0.025

				currentYPos = currentYPos + 5
				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(scrW * 0.018, currentYPos, longest_name + iconsize, boxSize)

				surface.SetDrawColor((lobbyPly.Ready == 2 and 50 or 0) + 50, (lobbyPly.Ready == 1 and 50 or 0) + 50, 50)
				surface.DrawOutlinedRect(scrW * 0.018, currentYPos, longest_name + iconsize, boxSize, 3)

				surface.SetFont("PlayersFont")
				surface.SetTextColor(255, 255, 255, 255)

				local _, nameHeight = surface.GetTextSize(lobbyPly.Name)
				surface.SetTextPos(scrW * 0.025, currentYPos + (boxSize / 2) - (nameHeight / 2))
				surface.DrawText(lobbyPly.Name)

				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial((Lobby_Players[i].Ready > 0) and ReadyCheck or UnReadyCheck)
				surface.DrawTexturedRect((scrW * 0.018) + longest_name - 5, currentYPos + 5, iconsize, iconsize)

				currentYPos = currentYPos + boxSize
			end
		end
	end
end)