local SlashCo = SlashCo

util.AddNetworkString("octoSlashCoTestConfigHalos")
util.AddNetworkString("mantislashcoGiveLobbyInfo")
util.AddNetworkString("mantislashcoGiveLobbyStatus")
util.AddNetworkString("mantislashcoRequestInfo")
util.AddNetworkString("mantislashcoLobbyTimerTime")
util.AddNetworkString("mantislashcoLobbyHelicopterReady")
util.AddNetworkString("mantislashcoGasPourProgress")
util.AddNetworkString("mantislashcoGiveSlasherData")
util.AddNetworkString("mantislashcoSlasherChaseMode")
util.AddNetworkString("mantislashcoSlasherKillPlayer")
util.AddNetworkString("mantiSlashCoPickingSlasher")
util.AddNetworkString("mantiSlashCoSelectSlasher")
util.AddNetworkString("mantislashcoStartItemPicking")
util.AddNetworkString("mantislashcoPickItem")
util.AddNetworkString("mantislashcoGiveItemData")
util.AddNetworkString("mantislashcoSendLobbyItemGlobal")
util.AddNetworkString("mantislashcoSendGlobalInfoTable")
util.AddNetworkString("mantislashcoGlobalSound")
util.AddNetworkString("mantislashcoGameIntro")
util.AddNetworkString("mantislashcoRoundEnd")
util.AddNetworkString("mantislashcoBriefing")
util.AddNetworkString("mantislashcoStartOfferingPicking")
util.AddNetworkString("mantislashcoBeginOfferingVote")
util.AddNetworkString("mantislashcoOfferingVoteOut")
util.AddNetworkString("mantislashcoVoteForOffering")
util.AddNetworkString("mantislashcoOfferingEndVote")
util.AddNetworkString("mantislashcoOfferingVoteFinished")
util.AddNetworkString("mantislashcoGiveMasterDatabase")
util.AddNetworkString("mantislashcoSendRoundData")
util.AddNetworkString("mantislashcoHelicopterMusic")
util.AddNetworkString("mantislashcoLobbySlasherInformation")
util.AddNetworkString("slashcoSelectables")

function PlayGlobalSound(sound, level, ent, vol)

	if vol == nil then vol = 1 end

	if SERVER then
		ent:EmitSound(sound, 1, 1, 0)
		--"Sounds must be precached serverside manually before they can be played. util.PrecacheSound does not work for this purpose, Entity:EmitSound does the trick"

		net.Start("mantislashcoGlobalSound")
		net.WriteTable({SoundPath = sound, SndLevel = level, Entity = ent, Volume = vol})
		net.Broadcast()
	end

end

SlashCo.BroadcastSlasherData = function()

    net.Start("mantislashcoGiveSlasherData")
	net.WriteTable(SlashCo.CurRound.SlasherData)
	net.Broadcast()

end

SlashCo.BroadcastLobbySlasherInformation = function()

    net.Start("mantislashcoLobbySlasherInformation")
	net.WriteTable({ player = SlashCo.LobbyData.AssignedSlasher, slasher = SlashCo.SlasherData[SlashCo.LobbyData.FinalSlasherID].Name })
	net.Broadcast()

end

SlashCo.BroadcastCurrentRoundData = function()

    net.Start("mantislashcoSendRoundData")
	net.WriteTable({survivors = SlashCo.CurRound.SlasherData.AllSurvivors, slashers = SlashCo.CurRound.SlasherData.AllSlashers, offering = SlashCo.CurRound.OfferingData.OfferingName})
	net.Broadcast()

end

SlashCo.EndOfferingVote = function(play)

    net.Start("mantislashcoOfferingEndVote")
	net.WriteTable({ply = play:SteamID64()})
	net.Broadcast()

end

SlashCo.OfferingVoteFinished = function(result)

    net.Start("mantislashcoOfferingVoteFinished")
	net.WriteTable({r = result})
	net.Broadcast()

end


net.Receive("mantislashcoBeginOfferingVote", function()

	t = net.ReadTable()

	table.insert(SlashCo.LobbyData.Offerors, {steamid = t.ply})
	SlashCo.BroadcastOfferingVote(t.ply, t.id)
	SlashCo.LobbyData.VotedOffering = t.id

	timer.Create( "OfferingVoteTimer", 20, 1, function() SlashCo.OfferingVoteFail() end)

	for _, play in ipairs( player.GetAll() ) do
        play:ChatPrint(player.GetBySteamID64(t.ply):GetName().." would like to offer "..SCInfo.Offering[t.id].Name)
    end

end)

SlashCo.OfferingVote = function(ply, agreement)

	if agreement ~= true then return end

	table.insert(SlashCo.LobbyData.Offerors, {steamid = ply:SteamID64()})

	--if getReadyState(ply) == 2 then lobbyPlayerReadying(ply, 1) end

end

SlashCo.BroadcastOfferingVote = function(offeror, o_id)

    net.Start("mantislashcoOfferingVoteOut")
	net.WriteTable({ply = offeror, name = SCInfo.Offering[o_id].Name})
	net.Broadcast()

end

SlashCo.LobbyPlayerBriefing = function()

    net.Start("mantislashcoBriefing")
	net.WriteTable(SlashCo.LobbyData.SelectedSlasherInfo)
	net.Broadcast()

end

SlashCo.StartGameIntro = function()

	local offering = "Regular"

	if SlashCo.LobbyData.Offering > 0 then offering = SCInfo.Offering[SlashCo.LobbyData.Offering].Name end

    net.Start("mantislashcoGameIntro")
	net.WriteTable({
		map = SlashCo.Maps[SlashCo.LobbyData.SelectedMapNum].NAME,
		diff = SlashCo.LobbyData.SelectedDifficulty,
		offer = offering,
		s_name = SlashCo.LobbyData.SelectedSlasherInfo.NAME,
		s_class = SlashCo.LobbyData.SelectedSlasherInfo.CLS,
		s_danger = SlashCo.LobbyData.SelectedSlasherInfo.DNG
	})
	net.Broadcast()

end

SlashCo.PlayerItemStashRequest = function(id)

    if SlashCo.GetHeldItem(player.GetBySteamID64(id)) ~= 0 then
        player.GetBySteamID64(id):ChatPrint("You have already chosen an item.")
        return
    end

    net.Start("mantislashcoStartItemPicking")
	net.WriteTable({ply = id, wardsleft = SlashCo.LobbyData.DeathwardsLeft})
	net.Broadcast()

end

SlashCo.PlayerOfferingTableRequest = function(id)

    if SlashCo.LobbyData.Offering > 0 or #SlashCo.LobbyData.Offerors > 0 then
        player.GetBySteamID64(id):ChatPrint("An Offering has already been made.")
        return
    end

    net.Start("mantislashcoStartOfferingPicking")
	net.WriteTable({ply = id})
	net.Broadcast()

end

SlashCo.RoundOverScreen = function(state)

	local heli = table.Random(ents.FindByClass("sc_helicopter"))

	if not IsValid(heli) then goto skipsound end

	heli:StopSound("slashco/helicopter_engine_distant.wav")
	heli:StopSound("slashco/helicopter_rotors_distant.wav")
	heli:StopSound("slashco/helicopter_engine_close.wav")
	heli:StopSound("slashco/helicopter_rotors_close.wav")

	::skipsound::

    net.Start("mantislashcoRoundEnd")

	--[[

	state value:

	0 - (If won with all players alive)
	1 - (If won with players dead or ones that havent made it to the helicopter in time)
	2 - (If won with no players making it to the helicopter)
	3 - (If lost)
	4 - (If won using Distress Beacon)

	]]

	local l1 = ""
	local l2 = ""
	local l3 = ""
	local l4 = ""
	local l5 = ""

	local all_survivors = SlashCo.CurRound.SlasherData.AllSurvivors

	local rescued_players = SlashCo.CurRound.HelicopterRescuedPlayers
	local alive_survivors = ""

	if #rescued_players == 1 then

		alive_survivors = player.GetBySteamID64(rescued_players[1].steamid):GetName()

	elseif #rescued_players == 2 then

		alive_survivors = player.GetBySteamID64(rescued_players[1].steamid):GetName().." and "..player.GetBySteamID64(rescued_players[2].steamid):GetName()

	elseif #rescued_players == 3 then

		alive_survivors = player.GetBySteamID64(rescued_players[1].steamid):GetName()..", "..player.GetBySteamID64(rescued_players[2].steamid):GetName().." and "..player.GetBySteamID64(rescued_players[3].steamid):GetName()

	elseif #rescued_players == 4 then

		alive_survivors = player.GetBySteamID64(rescued_players[1].steamid):GetName()..", "..player.GetBySteamID64(rescued_players[2].steamid):GetName()..", "..player.GetBySteamID64(rescued_players[3].steamid):GetName().." and "..player.GetBySteamID64(rescued_players[4].steamid):GetName()

	end

	local deadsurv_table = {}
	local dead_survivors = ""

	for i = 1, #team.GetPlayers(TEAM_SPECTATOR) do

		local spec = team.GetPlayers(TEAM_SPECTATOR)[i]:SteamID64()

		for s = 1, #SlashCo.CurRound.SlasherData.AllSurvivors do

			if spec == SlashCo.CurRound.SlasherData.AllSurvivors[s].id then
				table.insert(deadsurv_table, {id = spec})
			end

		end

	end

	if #deadsurv_table == 1 then

		dead_survivors = player.GetBySteamID64(deadsurv_table[1].id):GetName()

	elseif #deadsurv_table == 2 then

		dead_survivors = player.GetBySteamID64(deadsurv_table[1].id):GetName().." and "..player.GetBySteamID64(deadsurv_table[2].id):GetName()

	elseif #deadsurv_table == 3 then

		dead_survivors = player.GetBySteamID64(deadsurv_table[1].id):GetName()..", "..player.GetBySteamID64(deadsurv_table[2].id):GetName().." and "..player.GetBySteamID64(deadsurv_table[3].id):GetName()

	elseif #deadsurv_table == 4 then

		dead_survivors = player.GetBySteamID64(deadsurv_table[1].id):GetName()..", "..player.GetBySteamID64(deadsurv_table[2].id):GetName()..", "..player.GetBySteamID64(deadsurv_table[3].id):GetName().." and "..player.GetBySteamID64(deadsurv_table[4].id):GetName()

	end

	local absurv_table = {}
	local abandoned_survivors = ""

	for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

		local a_ply = team.GetPlayers(TEAM_SURVIVOR)[i]:SteamID64()

		for r = 1, #rescued_players do

			local r_ply = rescued_players[r].steamid

			if r_ply == a_ply then goto RESCUED end

		end

		table.insert(absurv_table, a_ply)

		::RESCUED::

	end

	if #absurv_table == 1 then

		abandoned_survivors = player.GetBySteamID64(absurv_table[1].id):GetName()

	elseif #absurv_table == 2 then

		abandoned_survivors = player.GetBySteamID64(absurv_table[1].id):GetName().." and "..player.GetBySteamID64(absurv_table[2].id):GetName()

	elseif #absurv_table == 3 then

		abandoned_survivors = player.GetBySteamID64(absurv_table[1].id):GetName()..", "..player.GetBySteamID64(absurv_table[2].id):GetName().." and "..player.GetBySteamID64(absurv_table[3].id):GetName()

	elseif #absurv_table == 4 then

		abandoned_survivors = player.GetBySteamID64(absurv_table[1].id):GetName()..", "..player.GetBySteamID64(absurv_table[2].id):GetName()..", "..player.GetBySteamID64(absurv_table[3].id):GetName().." and "..player.GetBySteamID64(absurv_table[4].id):GetName()

	end

	if state == 0 then

		l1 = SCInfo.RoundEnd[1].On
		l2 = SCInfo.RoundEnd[2].FullTeam
		l3 = ""
		l4 = ""
		l5 = ""

	elseif state == 1 then

		l1 = SCInfo.RoundEnd[1].On
		l2 = SCInfo.RoundEnd[2].NonFullTeam

		if #team.GetPlayers(TEAM_SURVIVOR) > 1 then
			l3 = alive_survivors..SCInfo.RoundEnd[2].AlivePlayers
		else
			l3 = alive_survivors..SCInfo.RoundEnd[2].OnlyOneAlive
		end

		l4 = dead_survivors..SCInfo.RoundEnd[2].DeadPlayers

		if #absurv_table > 0 then
			l5 = abandoned_survivors..SCInfo.RoundEnd[2].LeftBehindPlayers
		else
			l5 = ""
		end

	elseif state == 2 then

		l1 = SCInfo.RoundEnd[1].On
		l2 = SCInfo.RoundEnd[2].Fail
		l3 = ""
		l4 = ""
		l5 = ""

	elseif state == 3 then

		l1 = SCInfo.RoundEnd[1].Off
		l2 = SCInfo.RoundEnd[3].LossComplete
		l3 = ""
		l4 = ""
		l5 = ""

	elseif state == 4 then
		if #all_survivors > 1 then
			l1 = SCInfo.RoundEnd[1].DB

			if #dead_survivors > 1 then
				l2 = dead_survivors..SCInfo.RoundEnd[3].Loss
			else
				l2 = dead_survivors..SCInfo.RoundEnd[3].LossOnlyOne
			end

			l3 = alive_survivors..SCInfo.RoundEnd[3].DBWin
			l4 = ""
			l5 = ""
		else
			l1 = SCInfo.RoundEnd[1].DB
			l2 = alive_survivors..SCInfo.RoundEnd[3].DBWin
			l3 = ""
			l4 = ""
			l5 = ""
		end

	end

	net.WriteTable({
		result = state,
		line1 = l1,
		line2 = l2,
		line3 = l3,
		line4 = l4,
		line5 = l5
	})

	net.Broadcast()

end

SlashCo.BroadcastItemData = function()

	if SERVER then

    net.Start("mantislashcoGiveItemData")
	net.WriteTable(SlashCo.CurRound.SurvivorData.Items)
	net.Broadcast()

	SlashCo.BroadcastGlobalData()

	end

end

SlashCo.BroadcastGlobalData = function()

	if SERVER then

	net.Start("mantislashcoSendGlobalInfoTable")
	net.WriteTable(SCInfo)
	net.Broadcast()

	end

end

SlashCo.BroadcastMasterDatabaseForClient = function(ply_id)

	if SERVER then

		if sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID ='"..ply_id.."'; ") == nil or sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID ='"..ply_id.."'; ") == false then return end

		net.Start("mantislashcoGiveMasterDatabase")
		net.WriteTable(sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID ='"..ply_id.."'; "))
		net.Broadcast()

	end

end

--[[
SlashCo.BroadcastSelectables = function()
	if SERVER then
		net.Start("slashcoSelectables")
		net.WriteTable(SlashCo.CurRound.Selectables)
		net.Broadcast()
	end
end
]]
