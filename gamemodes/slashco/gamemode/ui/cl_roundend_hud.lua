net.Receive( "mantislashcoRoundEnd", function( _, _ )
	local retable = net.ReadTable()

	local result = retable.result

	if outromusic_antispam == nil or outromusic_antispam ~= true then

		if result == 0 then
			surface.PlaySound( "slashco/music/slashco_win_full.mp3") 
		elseif result == 1 then
			surface.PlaySound( "slashco/music/slashco_win_2.mp3") 
		elseif result == 2 then
			surface.PlaySound( "slashco/music/slashco_lost_active.mp3") 
		elseif result == 3 then
			surface.PlaySound( "slashco/music/slashco_lost.mp3") 
		elseif result == 4 then
			surface.PlaySound( "slashco/music/slashco_win_db.mp3") 
		end

		outromusic_antispam = true 
	end

	outro_line1 = retable.line1
	outro_line2 = retable.line2
	outro_line3 = retable.line3
	outro_line4 = retable.line4
	outro_line5 = retable.line5

	show_roundend_screen = true

end)

net.Receive( "mantislashcoHelicopterMusic", function( _, _ )

	if LocalPlayer():Team() == TEAM_SLASHER then return end

	if stop_helimusic ~= true and (helimusic_antispam == nil or helimusic_antispam ~= true) then
		heli_music = CreateSound(LocalPlayer(), "slashco/music/slashco_helicopter.wav")
		heli_music:Play()
		helimusic_antispam = true 
		AmbientStop = true
	end

end)

hook.Add("HUDPaint", "RoundOutroHUD", function()

	--local ply = LocalPlayer()

	--Round Ending screen

	if helimusic_antispam == true and LocalPlayer():GetNWBool("SurvivorChased") then stop_helimusic = true end

	if stop_helimusic and helimusic_antispam == true then heli_music:Stop() end

	if show_roundend_screen ~= true then return end

	if re_tick == nil then re_tick = 0 end
	re_tick = re_tick + 1.5

	stop_helimusic = true

	local black = Material("models/slashco/slashers/trollge/body")

	surface.SetDrawColor(0,0,0,re_tick)
	surface.SetMaterial(black)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	draw.SimpleText( outro_line1, "OutroFont", ScrW() * 0.5, (ScrH() * 0.15), Color( 255, 255, 255, re_tick-255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	draw.SimpleText( outro_line2, "OutroFont", ScrW() * 0.5, (ScrH() * 0.28), Color( 255, 255, 255, re_tick-(255*2) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	draw.SimpleText( outro_line3, "OutroFont", ScrW() * 0.5, (ScrH() * 0.44), Color( 255, 255, 255, re_tick-(255*3) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	draw.SimpleText( outro_line4, "OutroFont", ScrW() * 0.5, (ScrH() * 0.6), Color( 255, 255, 255, re_tick-(255*4) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	draw.SimpleText( outro_line5, "OutroFont", ScrW() * 0.5, (ScrH() * 0.77), Color( 255, 255, 255, re_tick-(255*5) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )


end)