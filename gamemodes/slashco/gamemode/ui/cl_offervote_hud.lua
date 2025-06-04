net.Receive("mantislashco_OfferingVoteOut", function()
	local offeror = net.ReadEntity()
	GameData.OfferingName = net.ReadString()
	GameData.OfferorName = IsValid(offeror) and offeror:GetName() or nil

	if GameData.OfferorName == nil or GameData.OfferingName == "" then
		GameData.ShowVoteScreen = false
		return
	end

	if offeror == GameData.LocalPlayer then
		GameData.ShowVoteScreen = false
		return
	end

	GameData.ShowVoteScreen = true
end)

net.Receive("mantislashco_OfferingEndVote", function()
	local steamID64 = net.ReadUInt64()

	if steamID64 ~= GameData.LocalSteamID64 then
		return
	end

	GameData.ShowVoteScreen = false
end)

net.Receive("mantislashco_OfferingVoteFinished", function()
	GameData.OfferingRarity = net.ReadUInt(2)

	GameData.ShowOfferingResultScreen = true
end)

hook.Add("HUDPaint", "OfferingVoteHUD", function()
	if GameData.ShowOfferingResultScreen == true then
		if GameData.OfferingSoundAntiSpam == nil then
			local ID = "offering_" .. (GameData.OfferingRarity or 1)
			--[[SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/music/slashco_" .. ID .. ".mp3",
				identifier = ID,
				volume = 1,
				entity = 0,
			})]]
			surface.PlaySound("slashco/music/slashco_" .. ID .. ".mp3")
			GameData.OfferingSoundAntiSpam = true
		end

		SlashCo.AudioSystem.DisableBackgroundMusic()

		if GameData.OfferingTick == nil then
			GameData.OfferingTick = 1
		end
		if GameData.OfferingTick ~= 0 then
			GameData.OfferingTick = GameData.OfferingTick + 1
		end

		if GameData.OfferingTick > 3000 then
			GameData.OfferingTick = -255
		end

		if GameData.OfferingTick == 0 then
			GameData.ShowOfferingResultScreen = false
			GameData.OfferingSoundAntiSpam = nil
			GameData.OfferingTick = 1
			SlashCo.AudioSystem.EnableBackgroundMusic()
		end

		draw.SimpleText(SlashCo.Language("offervote_success", SlashCo.Language("Offering_name", GameData.OfferingName or "")),
				"LobbyFont2", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, math.abs(GameData.OfferingTick)), TEXT_ALIGN_CENTER,
				TEXT_ALIGN_TOP)
	end

	if GameData.LocalPlayer:Team() ~= TEAM_LOBBY then
		return
	end

	if GameData.ShowVoteScreen ~= true then
		return
	end

	draw.SimpleText(SlashCo.Language("offervote_1", GameData.OfferorName, SlashCo.Language("Offering_name", GameData.OfferingName or "")),
			"LobbyFont1", ScrW() * 0.5, ScrH() * 0.27, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	draw.SimpleText("[F4]", "TVCD", ScrW() * 0.5, ScrH() * 0.33, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end)