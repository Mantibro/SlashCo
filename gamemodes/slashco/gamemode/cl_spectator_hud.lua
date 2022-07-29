include( "ui/fonts.lua" )

hook.Add("HUDPaint", "RoundOutroHUD", function()

	local ply = LocalPlayer()

	if ply:Team() != TEAM_SPECTATOR then return end

	if game.GetMap() == "sc_lobby" then return end

	draw.SimpleText("You are Spectating" , "LobbyFont2", ScrW() * 0.5, (ScrH() * 0.06), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	draw.SimpleText("LMB to follow player. | Space to switch view. | R to toggle illumination." , "LobbyFont1", ScrW() * 0.5, (ScrH() * 0.12), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

end)

hook.Add("KeyPress", "ToggleLight", function(ply, key) 

	if vision == nil then vision = false end
	if game.GetMap() == "sc_lobby" then return end

	if input.IsKeyDown( 28 ) then 
		vision = not vision
	end

end)

hook.Add( "Think", "Spectator_Vision_Light", function()

	if vision == nil then vision = false end

	if LocalPlayer():Team() != TEAM_SPECTATOR then return end
	if not vision then return end

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
		dlight.DieTime = CurTime() +0.1
	end
end )
hook.Add("RenderScreenspaceEffects", "SpectatorVision", function()

	if LocalPlayer():Team() != TEAM_SPECTATOR then return end
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
end )