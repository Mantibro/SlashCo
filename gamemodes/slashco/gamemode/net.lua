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
--util.AddNetworkString("mantislashcoPickItem")
util.AddNetworkString("mantislashcoSendLobbyItemGlobal")
util.AddNetworkString("mantislashcoSendGlobalInfoTable")
util.AddNetworkString("mantislashcoGlobalSound")
--util.AddNetworkString("mantislashcoGameIntro")
--util.AddNetworkString("mantislashcoRoundEnd")
util.AddNetworkString("mantislashcoBriefing")
--util.AddNetworkString("mantislashcoBeginOfferingVote")
util.AddNetworkString("mantislashcoOfferingVoteOut")
util.AddNetworkString("mantislashcoVoteForOffering")
util.AddNetworkString("mantislashcoOfferingEndVote")
util.AddNetworkString("mantislashcoOfferingVoteFinished")
util.AddNetworkString("mantislashcoGiveMasterDatabase")
util.AddNetworkString("mantislashcoSendRoundData")
util.AddNetworkString("mantislashcoHelicopterMusic")
util.AddNetworkString("mantislashcoLobbySlasherInformation")
util.AddNetworkString("mantislashcoSurvivorVoicePrompt")
util.AddNetworkString("mantislashcoSurvivorPings")
--util.AddNetworkString("mantislashcoSurvivorPreparePing")
util.AddNetworkString("mantislashcoHelicopterVoice")
util.AddNetworkString("mantislashcoMapAmbientPlay")
--util.AddNetworkString("mantislashcoSendMapForce")

function PlayGlobalSound(sound, level, ent, vol)
	if vol == nil then
		vol = 1
	end

	if SERVER then
		ent:EmitSound(sound, 1, 1, 0)
		--"Sounds must be precached serverside manually before they can be played.
		--util.PrecacheSound does not work for this purpose, Entity:EmitSound does the trick"

		net.Start("mantislashcoGlobalSound")
		net.WriteTable({ SoundPath = sound, SndLevel = level, Entity = ent, Volume = vol })
		net.Broadcast()
	end
end

SlashCo.BroadcastLobbySlasherInformation = function()
	net.Start("mantislashcoLobbySlasherInformation")
	net.WriteTable({ player = SlashCo.LobbyData.AssignedSlasher, slasher = SlashCo.LobbyData.PickedSlasher })
	net.Broadcast()
end

SlashCo.BroadcastCurrentRoundData = function(readygame)
	net.Start("mantislashcoSendRoundData")
	net.WriteTable({ survivors = SlashCo.CurRound.SlasherData.AllSurvivors, slashers = SlashCo.CurRound.SlasherData.AllSlashers, offering = SlashCo.CurRound.OfferingData.OfferingName })
	net.Broadcast()

	net.Start("mantislashcoGiveSlasherData")
	local send_t = {}

	send_t.GameProgress = SlashCo.CurRound.GameProgress
	send_t.AllSurvivors = SlashCo.CurRound.SlasherData.AllSurvivors
	send_t.AllSlashers = SlashCo.CurRound.SlasherData.AllSlashers
	send_t.GameReadyToBegin = readygame

	net.WriteTable(send_t)
	net.Broadcast()
end

SlashCo.EndOfferingVote = function(play)
	net.Start("mantislashcoOfferingEndVote")
	net.WriteTable({ ply = play:SteamID64() })
	net.Broadcast()
end

SlashCo.OfferingVoteFinished = function(result)
	net.Start("mantislashcoOfferingVoteFinished")
	net.WriteTable({ r = result })
	net.Broadcast()
end

hook.Add("scValue_sendOffer", "slashCo_StartOfferingVote", function(ply, offer)
	table.insert(SlashCo.LobbyData.Offerors, ply:SteamID64())
	SlashCo.BroadcastOfferingVote(ply:SteamID64(), offer)
	SlashCo.LobbyData.VotedOffering = offer

	timer.Create("OfferingVoteTimer", 20, 1, function()
		SlashCo.OfferingVoteFail()
	end)
end)

SlashCo.OfferingVote = function(ply, agreement)
	if agreement ~= true then
		return
	end

	table.insert(SlashCo.LobbyData.Offerors, { steamid = ply:SteamID64() })
end

SlashCo.BroadcastOfferingVote = function(offeror, o_id)
	net.Start("mantislashcoOfferingVoteOut")
	net.WriteTable({ ply = offeror, name = SCInfo.Offering[o_id].Name })
	net.Broadcast()
end

SlashCo.LobbyPlayerBriefing = function()
	net.Start("mantislashcoBriefing")
	net.WriteTable(SlashCo.LobbyData.SelectedSlasherInfo)
	net.Broadcast()
end

local function quietHeli()
	for _, heli in ipairs(ents.FindByClass("sc_helicopter")) do
		heli:StopSound("slashco/helicopter_engine_distant.wav")
		heli:StopSound("slashco/helicopter_rotors_distant.wav")
		heli:StopSound("slashco/helicopter_engine_close.wav")
		heli:StopSound("slashco/helicopter_rotors_close.wav")
	end
end

SlashCo.StartGameIntro = function()
	quietHeli()

	local offering = "Regular"
	if SlashCo.LobbyData.Offering > 0 then
		offering = SCInfo.Offering[SlashCo.LobbyData.Offering].Name
	end

	SlashCo.SendValue(nil, "RoundEnd", 6, {
		SCInfo.Maps[SlashCo.LobbyData.SelectedMap].NAME,
		SlashCo.LobbyData.SelectedSlasherInfo.NAME,
		SlashCo.LobbyData.SelectedSlasherInfo.CLS,
		SlashCo.LobbyData.SelectedSlasherInfo.DNG,
		SlashCo.LobbyData.SelectedDifficulty,
		offering
	})
end

--[[ state value:
	0 - (If won with all players alive)
	1 - (If won with players dead or ones that havent made it to the helicopter in time)
	2 - (If won with no players making it to the helicopter)
	3 - (If lost)
	4 - (If won using Distress Beacon)
	5 - (fun test end)
]]
SlashCo.RoundOverScreen = function(state)
	quietHeli()

	--yucky yucky
	local goodSurvivorTable = {}
	for _, ply in ipairs(player.GetAll()) do
		for _, v in ipairs(SlashCo.CurRound.SlasherData.AllSurvivors) do
			if ply:SteamID64() == v.id then
				table.insert(goodSurvivorTable, ply)
			end
		end
	end

	SlashCo.SendValue(nil, "RoundEnd", state, goodSurvivorTable, SlashCo.CurRound.HelicopterRescuedPlayers)
end

SlashCo.BroadcastGlobalData = function()
	if CLIENT then
		return
	end

	net.Start("mantislashcoSendGlobalInfoTable")
	net.WriteTable(SCInfo)
	net.Broadcast()
end

SlashCo.BroadcastMasterDatabaseForClient = function(ply)
	if CLIENT then
		return
	end

	if not IsValid(ply) then
		return
	end

	if sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID ='" .. ply:SteamID64() .. "'; ") == nil
			or sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID ='" .. ply:SteamID64() .. "'; ") == false then
		return
	end

	net.Start("mantislashcoGiveMasterDatabase")
	net.WriteTable(sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID ='" .. ply:SteamID64() .. "'; "))
	net.Send(ply)
end

SlashCo.HelicopterRadioVoice = function(type)
	net.Start("mantislashcoHelicopterVoice")
	net.WriteUInt(type, 4)
	net.Broadcast()
end

