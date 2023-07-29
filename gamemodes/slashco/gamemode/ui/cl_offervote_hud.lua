net.Receive( "mantislashcoOfferingVoteOut", function( _, _ )
	local t = net.ReadTable()

	offeror_name = player.GetBySteamID64(t.ply):GetName()

	offering_name = t.name

	if offeror_name == nil or offering_name == nil then show_vote_screen = false return end

	if t.ply == LocalPlayer():SteamID64() then show_vote_screen = false return end

	show_vote_screen = true

end)

net.Receive( "mantislashcoOfferingEndVote", function( _, _ )
	local t = net.ReadTable()

	if t.ply ~= LocalPlayer():SteamID64() then return end

	show_vote_screen = false

end)

net.Receive( "mantislashcoOfferingVoteFinished", function( _, _ )
	local t = net.ReadTable()

	offering_vote_result = t.r

	show_offering_result_screen = true

end)

hook.Add("HUDPaint", "OfferingVoteHUD", function()

	local ply = LocalPlayer()

	if show_offering_result_screen == true then

		if offerjingle_antispam == nil then

			surface.PlaySound("slashco/music/slashco_offering_"..offering_vote_result..".mp3")
			offerjingle_antispam = true

		end

		stop_lobbymusic = true

		if o_tick == nil then o_tick = 1 end 
		if o_tick ~= 0 then o_tick = o_tick + 1 end

		if o_tick > 3000 then o_tick = -255 end

		if o_tick == 0  then 
			show_offering_result_screen = false 
			stop_lobbymusic = false
			lobbymusic_antispam = false
		end

		draw.SimpleText( GetOfferingName(offering_name)..SlashCoLanguage("offervote_success"), "LobbyFont2", ScrW() * 0.5, (ScrH() * 0.5), Color( 255, 255, 255, math.abs(o_tick) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )


	end

	if ply:Team() ~= TEAM_LOBBY then return end

	if show_vote_screen ~= true then return end

	draw.SimpleText( offeror_name..SlashCoLanguage("offervote_1")..GetOfferingName(offering_name)..SlashCoLanguage("offervote_2"), "LobbyFont1", ScrW() * 0.5, (ScrH() * 0.27), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	draw.SimpleText( "[F4]", "TVCD", ScrW() * 0.5, (ScrH() * 0.33), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )


end)