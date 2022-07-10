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

util.AddNetworkString("mantislashcoBriefing")

util.AddNetworkString("mantislashcoStartOfferingPicking") 

util.AddNetworkString("mantislashcoBeginOfferingVote")

util.AddNetworkString("mantislashcoOfferingVoteOut")

util.AddNetworkString("mantislashcoVoteForOffering")

util.AddNetworkString("mantislashcoOfferingEndVote")

util.AddNetworkString("mantislashcoOfferingVoteFinished")

function PlayGlobalSound(sound, level, ent)

	ent:EmitSound(sound, 1, 1, 0)
	--"Sounds must be precached serverside manually before they can be played. util.PrecacheSound does not work for this purpose, Entity:EmitSound does the trick"

	if SERVER then
		net.Start("mantislashcoGlobalSound")
		net.WriteTable({SoundPath = sound, SndLevel = level, Entity = ent})
		net.Broadcast()
	end

end

SlashCo.BroadcastSlasherData = function()

    net.Start("mantislashcoGiveSlasherData")
	net.WriteTable(SlashCo.CurRound.SlasherData)
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

	for i, play in ipairs( player.GetAll() ) do
        play:ChatPrint(player.GetBySteamID64(t.ply):GetName().." would like to offer "..SCInfo.Offering[t.id].Name) 
    end

end)

SlashCo.OfferingVote = function(ply, agreement)

	if agreement != true then return end

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

    if IsPlayerHoldingItem(id) then 
        player.GetBySteamID64(id):ChatPrint("You have already chosen an item.")
        return 
    end

    net.Start("mantislashcoStartItemPicking")
	net.WriteTable({ply = id})
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

	local alive_survivors = ""

	if #team.GetPlayers(TEAM_SURVIVOR) == 1 then 

		alive_survivors = team.GetPlayers(TEAM_SURVIVOR)[1]:GetName()

	elseif #team.GetPlayers(TEAM_SURVIVOR) == 2 then 

		alive_survivors = team.GetPlayers(TEAM_SURVIVOR)[1]:GetName().." and "..team.GetPlayers(TEAM_SURVIVOR)[2]:GetName()

	elseif #team.GetPlayers(TEAM_SURVIVOR) == 3 then 

		alive_survivors = team.GetPlayers(TEAM_SURVIVOR)[1]:GetName()..", "..team.GetPlayers(TEAM_SURVIVOR)[2]:GetName().." and "..team.GetPlayers(TEAM_SURVIVOR)[3]:GetName()

	elseif #team.GetPlayers(TEAM_SURVIVOR) == 4 then 

		alive_survivors = team.GetPlayers(TEAM_SURVIVOR)[1]:GetName()..", "..team.GetPlayers(TEAM_SURVIVOR)[2]:GetName()..", "..team.GetPlayers(TEAM_SURVIVOR)[3]:GetName().." and "..team.GetPlayers(TEAM_SURVIVOR)[4]:GetName()

	end

	local deadsurv_table = SlashCo.CurRound.SlasherData.AllSurvivors
	local dead_survivors = ""

	for i = 1, #SlashCo.CurRound.SlasherData.AllSurvivors do

		local dataply = SlashCo.CurRound.SlasherData.AllSurvivors[i].id

		for s = 1, #team.GetPlayers(TEAM_SURVIVOR) do

			if dataply == team.GetPlayers(TEAM_SURVIVOR)[s]:SteamID64() then table.RemoveByValue( deadsurv_table, dataply ) end

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

	if state == 0 then

		l1 = SCInfo.RoundEnd[1].On
		l2 = SCInfo.RoundEnd[2].FullTeam
		l3 = ""
		l4 = ""
		l5 = ""

	elseif state == 1 then

		l1 = SCInfo.RoundEnd[1].On
		l2 = SCInfo.RoundEnd[2].NonFullTeam
		l3 = alive_survivors..SCInfo.RoundEnd[2].AlivePlayers
		l4 = dead_survivors..SCInfo.RoundEnd[2].DeadPlayers
		l5 = ""

	elseif state == 2 then

		l1 = SCInfo.RoundEnd[1].On
		l2 = SCInfo.RoundEnd[2].Fail
		l3 = "" --TODO
		l4 = ""
		l5 = ""

	elseif state == 3 then

		l1 = SCInfo.RoundEnd[1].Off
		l2 = SCInfo.RoundEnd[3].LossComplete
		l3 = ""
		l4 = ""
		l5 = ""

	elseif state == 4 then
		
		l1 = SCInfo.RoundEnd[1].DB
		l2 = SCInfo.RoundEnd[3].LossComplete
		l3 = ""
		l4 = ""
		l5 = ""

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