local SlashCo = SlashCo

util.AddNetworkString("octoSlashCoTestConfigHalos")
util.AddNetworkString("mantislashco_GiveLobbyInfo")
util.AddNetworkString("mantislashco_GiveLobbyStatus")
util.AddNetworkString("mantislashco_RequestInfo")
util.AddNetworkString("mantislashco_LobbyTimerTime")
util.AddNetworkString("mantislashco_LobbyHelicopterReady")
util.AddNetworkString("mantislashco_GasPourProgress")
util.AddNetworkString("mantislashco_GiveSlasherData")
util.AddNetworkString("mantislashco_SlasherChaseMode")
util.AddNetworkString("mantislashco_SlasherKillPlayer")
util.AddNetworkString("mantislashco_PickingSlasher")
util.AddNetworkString("mantislashco_SelectSlasher")
util.AddNetworkString("mantislashco_SendLobbyItemGlobal")
util.AddNetworkString("mantislashco_SendGlobalInfoTable")
util.AddNetworkString("mantislashco_GlobalSound")
util.AddNetworkString("mantislashco_Briefing")
util.AddNetworkString("mantislashco_OfferingVoteOut")
util.AddNetworkString("mantislashco_VoteForOffering")
util.AddNetworkString("mantislashco_OfferingEndVote")
util.AddNetworkString("mantislashco_OfferingVoteFinished")
util.AddNetworkString("mantislashco_SendRoundData")
util.AddNetworkString("mantislashco_LobbySlasherInformation")
util.AddNetworkString("mantislashco_SurvivorVoicePrompt")
util.AddNetworkString("mantislashco_SurvivorPings")
util.AddNetworkString("mantislashco_HelicopterVoice")
util.AddNetworkString("mantislashco_MapAmbientPlay")

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

	net.Start("mantislashco_GlobalSound")
		net.WriteBool(false)
		net.WriteString(soundPath)
		net.WriteUInt(ent:EntIndex(), MAX_EDICT_BITS)
		net.WriteUInt(soundLevel, 14)
		net.WriteFloat(vol)
		net.WriteBool(permanent)
	net.Broadcast()

	--SlashCo.AudioSystem.PlaySound(soundPath, soundLevel, ent, vol, permanent)
end

-- possibly easier-to-use version of above
function ENTITY:PlayGlobalSound(soundPath, soundLevel, vol, permanent)
	SlashCo.PlayGlobalSound(soundPath, soundLevel, self, vol, permanent)
end

function ENTITY:StopAllGlobalSounds()
	net.Start("mantislashco_GlobalSound")
		net.WriteBool(true)
		net.WriteString("")
		net.WriteUInt(self:EntIndex(), MAX_EDICT_BITS)
	net.Broadcast()
end

ENTITY.OldStopSound = ENTITY.OldStopSound or ENTITY.StopSound
function ENTITY:StopSound(soundPath)
	self:OldStopSound(soundPath)

	net.Start("mantislashco_GlobalSound")
		net.WriteBool(true)
		net.WriteString(soundPath)
		net.WriteUInt(self:EntIndex(), MAX_EDICT_BITS)
	net.Broadcast()
end

-- DEPRECATED avoid using this
PlayGlobalSound = SlashCo.PlayGlobalSound

function SlashCo.BroadcastLobbySlasherInformation()
	net.Start("mantislashco_LobbySlasherInformation")
		net.WriteTable({ player = SlashCo.LobbyData.AssignedSlasher, slasher = SlashCo.LobbyData.PickedSlasher })
	net.Broadcast()
end

function SlashCo.LobbyRoundData()
	local offering = ""
	if SlashCo.LobbyData.Offering > 0 then
		offering = SCInfo.Offering[SlashCo.LobbyData.Offering].Name
	end

	net.Start("mantislashco_SendRoundData")
		net.WriteTable({ survivors = SlashCo.LobbyData.AssignedSurvivors, slashers = SlashCo.LobbyData.AssignedSlashers, offering = offering })
	net.Broadcast()
end

function SlashCo.BroadcastCurrentRoundData(readygame)
	net.Start("mantislashco_SendRoundData")
		net.WriteTable({ survivors = SlashCo.CurRound.SlasherData.AllSurvivors, slashers = SlashCo.CurRound.SlasherData.AllSlashers, offering = SlashCo.CurRound.OfferingData.OfferingName })
	net.Broadcast()

	net.Start("mantislashco_GiveSlasherData")
		local send_t = {}

		send_t.GameProgress = SlashCo.CurRound.GameProgress
		send_t.AllSurvivors = SlashCo.CurRound.SlasherData.AllSurvivors
		send_t.AllSlashers = SlashCo.CurRound.SlasherData.AllSlashers
		send_t.GameReadyToBegin = readygame

		net.WriteTable(send_t)
	net.Broadcast()
end

function SlashCo.EndOfferingVote(play)
	net.Start("mantislashco_OfferingEndVote")
		net.WriteTable({ ply = play:SteamID64() })
	net.Broadcast()
end

function SlashCo.OfferingVoteFinished(result)
	net.Start("mantislashco_OfferingVoteFinished")
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

function SlashCo.OfferingVote(ply, agreement)
	if agreement ~= true then
		return
	end

	table.insert(SlashCo.LobbyData.Offerors, { steamid = ply:SteamID64() })
end

function SlashCo.BroadcastOfferingVote(offeror, o_id)
	net.Start("mantislashco_OfferingVoteOut")
		net.WriteTable({ ply = offeror, name = SCInfo.Offering[o_id].Name })
	net.Broadcast()
end

function SlashCo.LobbyPlayerBriefing()
	net.Start("mantislashco_Briefing")
		net.WriteTable(SlashCo.LobbyData.SelectedSlasherInfo)
	net.Broadcast()
end

function SlashCo.StartGameIntro()
	SlashCo.QuietHeli()
	SlashCo.AudioSystem.DisableBackgroundMusic()

	local offering = "Regular"
	if SlashCo.LobbyData.Offering > 0 then
		offering = SCInfo.Offering[SlashCo.LobbyData.Offering].Name
	end

	SlashCo.SendValue(nil, "RoundEnd", 6, {
		SCInfo.Maps[SlashCo.LobbyData.SelectedMap].NAME,
		SlashCo.LobbyData.SelectedSlasherInfo.NAME,
		SlashCo.LobbyData.SelectedSlasherInfo.CLASS,
		SlashCo.LobbyData.SelectedSlasherInfo.DANGER,
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

local pointState = {
	[SlashCo.RoundState.WON_ALL_ALIVE] = function(ply)
		if #SlashCo.CurRound.SlasherData.AllSurvivors > 1 then
			ply:SetPoints("all_survive")
		end

		ply:SetPoints("objective")
	end,
	[SlashCo.RoundState.WON_SOME_DEAD] = function(ply)
		ply:SetPoints("objective")
	end,
	[SlashCo.RoundState.WON_ALL_DEAD] = function(ply)
		ply:SetPoints("objective")
	end,
	[SlashCo.RoundState.LOST] = function() end,
	[SlashCo.RoundState.WON_DISTRESS] = function(ply)
		ply:SetPoints("escape")
	end,
	[SlashCo.RoundState.CURSED] = function() end,
}

local pointStateSlasher = {
	[SlashCo.RoundState.WON_ALL_ALIVE] = function(ply) end,
	[SlashCo.RoundState.WON_SOME_DEAD] = function(ply) end,
	[SlashCo.RoundState.WON_ALL_DEAD] = function(ply)
		ply:SetPoints("slasher_win")
	end,
	[SlashCo.RoundState.LOST] = function(ply)
		ply:SetPoints("slasher_win")
	end,
	[SlashCo.RoundState.WON_DISTRESS] = function(ply)
		ply:SetPoints("slasher_escape")
	end,
	[SlashCo.RoundState.CURSED] = function() end,
}

function SlashCo.RoundOverScreen(state)
	SlashCo.QuietHeli()
	SlashCo.AudioSystem.DisableBackgroundMusic()
	SlashCo.AudioSystem.StopSound(nil, 1) -- Stops all sounds that use the AudioSystem.

	--yucky yucky
	local goodSurvivorTable = {}
	for _, ply in player.Iterator() do
		for _, v in ipairs(SlashCo.CurRound.SlasherData.AllSurvivors) do
			if ply:SteamID64() == v.id then
				table.insert(goodSurvivorTable, ply)
				pointState[state](ply)
			end
		end

		if SlashCo.CurRound.Slashers[ply:SteamID64()] then
			pointStateSlasher[state](ply)
		end
	end

	local rescued = {}
	for _, v in ipairs(SlashCo.CurRound.HelicopterRescuedPlayers) do
		if not IsValid(v) then continue end
		table.insert(rescued, v)
	end

	SlashCo.SendValue(nil, "RoundEnd", state, goodSurvivorTable, rescued)
end

function SlashCo.BroadcastGlobalData()
	net.Start("mantislashco_SendGlobalInfoTable")
		net.WriteTable(SCInfo)
	net.Broadcast()
end

function SlashCo.BroadcastMasterDatabaseForClient(ply)
	if not IsValid(ply) then
		return
	end

	local data = sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID ='" .. ply:SteamID64() .. "'; ")
	if data == nil or data == false or data[1] == nil then
		return
	end

	ply:SetNW2Int("SurvivorRoundsWon", data[1].SurvivorRoundsWon)
	ply:SetNW2Int("SlasherRoundsWon", data[1].SlasherRoundsWon)
	ply:SetNW2Int("Points", data[1].Points)
end

-- All types are defined in sh_shared.lua -> SlashCo.HelicopterVoices
function SlashCo.HelicopterRadioVoice(type)
	net.Start("mantislashco_HelicopterVoice")
		net.WriteUInt(type, 4)
		net.WriteUInt(math.random(1, type == SlashCo.HelicopterVoices.INTRO and 8 or 5), 4) -- Sound index
	net.Broadcast()
end