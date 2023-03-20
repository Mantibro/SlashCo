include( "ui/fonts.lua" )

net.Receive("mantislashcoLobbySlasherInformation", function()

	LobbySlasherInfo = net.ReadTable()

end)

hook.Add("HUDPaint", "Spectator_Vision", function()

	local ply = LocalPlayer()

	if ply:Team() ~= TEAM_SPECTATOR then return end

	if LobbySlasherInfo ~= nil then

		if LobbySlasherInfo.player ~= LocalPlayer():SteamID64() then return end

		if slashershow_tick == nil then slashershow_tick = 0 end
		slashershow_tick = slashershow_tick + 0.25

		draw.SimpleText("You will play as: "..LobbySlasherInfo.slasher , "LobbyFont2", ScrW() * 0.5, (ScrH() * 0.6), Color( 255, 0, 0, slashershow_tick ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	end

	if game.GetMap() == "sc_lobby" then return end

	local show_slasher_anticipation = false

	if SlasherTeam ~= nil then
		for i = 1, #SlasherTeam do
			if SlasherTeam[i].s_id == LocalPlayer():SteamID64() then
				show_slasher_anticipation = SlashCoSlasher[SlasherTeam[i].slasherkey].Name
			end
		end
	end

	if show_slasher_anticipation ~= false then
		draw.SimpleText("You will spawn as "..show_slasher_anticipation.." soon. . ." , "LobbyFont2", ScrW() * 0.5, (ScrH() * 0.4), Color( 255, 50, 50, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		return
	end

	draw.SimpleText("[YOU ARE SPECTATING]" , "TVCD", ScrW() * 0.5, (ScrH() * 0.05), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	draw.SimpleText( "[LMB] FOLLOW PLAYER", "TVCD", ScrW() * 0.975, (ScrH() * 0.95)-110, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( "[SPACE] SWITCH VIEW", "TVCD", ScrW() * 0.975, (ScrH() * 0.95)-80, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( "[R] TOGGLE LIGHT", "TVCD", ScrW() * 0.975, (ScrH() * 0.95)-50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

end)

hook.Add("KeyPress", "ToggleLight", function(ply, key)
	if not IsFirstTimePredicted() then return end

	if ply ~= LocalPlayer() or LocalPlayer():Team() ~= TEAM_SPECTATOR or SERVER then return end

	if SlasherSteamID ~= nil and SlasherSteamID == LocalPlayer():SteamID64() then
		return
	end

	if key == 8192 then
		vision = not vision
		local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
		Sndd:Play()
		Sndd:ChangeVolume(0.5, 0)
		Sndd:ChangePitch(100, 0)
	end

end)

hook.Add( "Think", "Spectator_Vision_Light", function()

	if vision == nil then vision = false end

	if LocalPlayer():Team() ~= TEAM_SPECTATOR then return end
	if not vision then return end

	if SlasherSteamID ~= nil and SlasherSteamID == LocalPlayer():SteamID64() then
		return
	end

	--Eyesight - an arbitrary range from 1 - 10 which decides how illuminated the Slasher 'vision is client-side. (1 - barely any illumination, 10 - basically fullbright ) 

	local dlight = DynamicLight( LocalPlayer():EntIndex() + 984 )
	if ( dlight ) then
		dlight.pos = LocalPlayer():GetShootPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 1
		dlight.Decay = 1000
		dlight.Size = 2500
		dlight.DieTime = CurTime() + 0.1
	end
end )
--[[hook.Add("RenderScreenspaceEffects", "SpectatorVision", function()

	if LocalPlayer():Team() ~= TEAM_SPECTATOR then return end
	if not vision then return end

	local tab = {
		["$pp_colour_addr"] = 0.01,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0.1,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}

	DrawColorModify( tab ) --Draws Color Modify effect
end )]]
