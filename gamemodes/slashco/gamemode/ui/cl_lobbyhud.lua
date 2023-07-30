if game.GetMap() ~= "sc_lobby" then
    return
end

--local TimeLeft, StateOfLobby, LobbyInfoTable, data_load
local longest_name, plynum, lobby_music

local grey = Color(128, 128, 128)
local red = Color(255, 64, 64)
local green = Color(64, 255, 64)

local TimeLeft, StateOfLobby, LobbyInfoTable, data_load

net.Receive("mantislashcoLobbyTimerTime", function(_, _)
    TimeLeft = net.ReadUInt(6)
end)

net.Receive("mantislashcoGiveLobbyStatus", function(_, _)
    StateOfLobby = net.ReadUInt(3)
end)

net.Receive("mantislashcoGiveLobbyInfo", function(_, _)
    LobbyInfoTable = net.ReadTable()
end)

net.Receive("mantislashcoGiveMasterDatabase", function(_, _)
    local t = net.ReadTable()
    data_load = t
end)

hook.Add("HUDPaint", "LobbyInfoText", function()
    if stop_lobbymusic ~= true and (lobbymusic_antispam == nil or lobbymusic_antispam ~= true) then
        lobby_music = CreateSound(LocalPlayer(), "slashco/music/slashco_lobby.wav")
        lobby_music:Play()
        lobby_music:ChangeVolume(0.5)
        lobbymusic_antispam = true
    end

    if IsValid(obby_music) and stop_lobbymusic then
        lobby_music:Stop()
    end

    local point_count = 0
    local srvwin_count = 0
    local slswin_count = 0

    if data_load ~= nil and data_load ~= false then

        point_count = data_load[1].Points
        srvwin_count = data_load[1].SurvivorRoundsWon
        slswin_count = data_load[1].SlasherRoundsWon

    end

    local scrW, scrH = ScrW(), ScrH()

    --LobbyFont1
    draw.SimpleText("[" .. point_count .. " "..SlashCoLanguage("PointCount").."]  [" .. srvwin_count .. " "..SlashCoLanguage("SurvivorWins").."]  [" .. slswin_count .. " "..SlashCoLanguage("SlasherWins").."]", "TVCD", ScrW() * 0.025, (ScrH() * 0.05), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    if StateOfLobby == nil or StateOfLobby < 1 then
        draw.SimpleText("[,] "..SlashCoLanguage("ToggleSpectate"), "TVCD", scrW * 0.975, (scrH * 0.95) - 50, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    if LocalPlayer():Team() == TEAM_LOBBY then
        draw.SimpleText("[R] "..SlashCoLanguage("SelectPlayermodel"), "TVCD", scrW * 0.975, (scrH * 0.95) - 80, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    if StateOfLobby ~= nil and StateOfLobby < 1 then
        local ReadyCheck = Material("slashco/ui/lobby_ready")
        local UnReadyCheck = Material("slashco/ui/lobby_unready")

        local Lobby_Players = {}

        local isClientinLobby = false

        local clientReadiness
        for _, v in ipairs(LobbyInfoTable) do
            local ply = player.GetBySteamID64(v.steamid)

            if not IsValid(ply) then
                return
            end

            if not table.HasValue(Lobby_Players, { ID = v.steamid }) then
                table.insert(Lobby_Players, { ID = v.steamid, Name = ply:GetName(), Ready = v.readyState })
            end

            if v.steamid == LocalPlayer():SteamID64() then
                clientReadiness = v.readyState
                isClientinLobby = true
            end
        end

        if isClientinLobby then
            surface.SetDrawColor(255, 255, 255, 255)

            draw.SimpleText("[F1] "..SlashCoLanguage("ReadyAs", string.upper( SlashCoLanguage("Survivor") )), "TVCD", scrW * 0.975, (scrH * 0.95) - 130, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("[F2] "..SlashCoLanguage("ReadyAs", string.upper( SlashCoLanguage("Slasher") )), "TVCD", scrW * 0.975, (scrH * 0.95) - 160, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

            if TimeLeft ~= nil and TimeLeft > 0 and TimeLeft < 61 then
                draw.SimpleText(tostring(TimeLeft), "LobbyFont2", scrW * 0.5, (scrH * 0.65), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            local mul_y = 1
            longest_name = longest_name or 0
            if not plynum or plynum ~= #Lobby_Players then
                longest_name = 0
                plynum = #Lobby_Players
            end

            draw.SimpleText("[" .. plynum .. "/7] ", "TVCD", scrW * 0.025, (scrH * 0.22), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            for i = 1, #Lobby_Players do
                local pos_y = 0.27
                local x_pos = scrW * 0.025
                local iconsize = ScrW() / 45

                surface.SetDrawColor(0, 0, 0)
                surface.DrawRect(scrW * 0.018, ((scrH) * (pos_y * mul_y)) - 18, (longest_name) + 65, 60)
                surface.SetDrawColor(50, 50, 50)
                surface.DrawOutlinedRect(scrW * 0.018, ((scrH) * (pos_y * mul_y)) - 18, longest_name + 65, 60, 3)

                if string.len(Lobby_Players[i].Name) * 15 > longest_name then
                    longest_name = string.len(Lobby_Players[i].Name) * 15
                end

                draw.SimpleText(Lobby_Players[i].Name, "PlayersFont", scrW * 0.025, (scrH * (pos_y * mul_y)), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

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
                    draw.SimpleText("       ["..SlashCoLanguage("NotReady").."]", "TVCD", scrW * 0.025, (scrH * 0.22), grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                elseif clientReadiness == 1 then
                    draw.SimpleText("       ["..SlashCoLanguage("ReadyAs", string.upper( SlashCoLanguage("Survivor"))).."]", "TVCD", scrW * 0.025, (scrH * 0.22), green, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                elseif clientReadiness == 2 then
                    draw.SimpleText("       ["..SlashCoLanguage("ReadyAs", string.upper( SlashCoLanguage("Slasher"))).."]", "TVCD", scrW * 0.025, (scrH * 0.22), red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
            end
        end
    end
end)