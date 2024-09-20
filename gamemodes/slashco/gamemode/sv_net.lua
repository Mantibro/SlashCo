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
util.AddNetworkString("mantislashcoSendLobbyItemGlobal")
util.AddNetworkString("mantislashcoSendGlobalInfoTable")
util.AddNetworkString("mantislashcoGlobalSound")
util.AddNetworkString("mantislashcoBriefing")
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
util.AddNetworkString("mantislashcoHelicopterVoice")
util.AddNetworkString("mantislashcoMapAmbientPlay")

local ENTITY = FindMetaTable("Entity")

-- play a sound on an entity
-- this function ensures the sound is played for everyone unlike EmitSound
function SlashCo.PlayGlobalSound(soundPath, soundLevel, ent, vol, permanent)
	if not IsValid(ent) or type(soundPath) ~= "string" then
		return
	end

	vol = vol or 1
	soundLevel = soundLevel or 0

	-- sound must be precached
	ent:EmitSound(soundPath, 1, 1, 0)

	net.Start("mantislashcoGlobalSound")
	net.WriteBool(false)
	net.WriteString(soundPath)
	net.WriteUInt(ent:EntIndex(), 13)
	net.WriteUInt(soundLevel, 14)
	net.WriteFloat(vol)
	net.WriteBool(permanent)
	net.Broadcast()
end

-- possibly easier-to-use version of above
function ENTITY:PlayGlobalSound(soundPath, soundLevel, vol, permanent)
	SlashCo.PlayGlobalSound(soundPath, soundLevel, self, vol, permanent)
end

ENTITY.OldStopSound = ENTITY.OldStopSound or ENTITY.StopSound
function ENTITY:StopSound(soundPath)
	self:OldStopSound(soundPath)

	net.Start("mantislashcoGlobalSound")
	net.WriteBool(true)
	net.WriteString(soundPath)
	net.WriteUInt(self:EntIndex(), 13)
	net.Broadcast()
end

-- DEPRECATED avoid using this
PlayGlobalSound = SlashCo.PlayGlobalSound

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

local pointState = {
	[0] = function(ply)
		if #SlashCo.CurRound.SlasherData.AllSurvivors > 1 then
			ply:SetPoints("all_survive")
		end

		ply:SetPoints("objective")
	end,
	[1] = function(ply)
		ply:SetPoints("objective")
	end,
	[2] = function(ply)
		ply:SetPoints("objective")
	end,
	[3] = function() end,
	[4] = function(ply)
		ply:SetPoints("escape")
	end,
	[5] = function() end,
}

local pointStateSlasher = {
	[0] = function(ply) end,
	[1] = function(ply) end,
	[2] = function(ply)
		ply:SetPoints("slasher_win")
	end,
	[3] = function(ply)
		ply:SetPoints("slasher_win")
	end,
	[4] = function(ply)
		ply:SetPoints("slasher_escape")
	end,
	[5] = function() end,
}

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
	for _, ply in player.Iterator() do
		for _, v in ipairs(SlashCo.CurRound.SlasherData.AllSurvivors) do
			if ply:SteamID64() == v.id then
				table.insert(goodSurvivorTable, ply)
				pointState[state](ply)
			end
		end
		for _, v in ipairs(SlashCo.CurRound.SlasherData.AllSlashers) do
			if ply:SteamID64() == v.s_id then
				pointStateSlasher[state](ply)
			end
		end
	end

	local rescued = {}
	for _, v in ipairs(SlashCo.CurRound.HelicopterRescuedPlayers) do
		if not IsValid(v) then continue end
		table.insert(rescued, v)
	end

	SlashCo.SendValue(nil, "RoundEnd", state, goodSurvivorTable, rescued)
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

SlashCo.HelicopterRadioVoice = function(_type)
	net.Start("mantislashcoHelicopterVoice")
	net.WriteUInt(_type, 4)
	net.Broadcast()
end

