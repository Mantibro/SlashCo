local SlashCo = SlashCo

util.AddNetworkString("SlashCo:TestConfigHalos")
util.AddNetworkString("SlashCo:GiveLobbyInfo")
util.AddNetworkString("SlashCo:GiveLobbyStatus")
util.AddNetworkString("SlashCo:RequestInfo")
util.AddNetworkString("SlashCo:LobbyTimerTime")
util.AddNetworkString("SlashCo:LobbyHelicopterReady")
util.AddNetworkString("SlashCo:GasPourProgress")
util.AddNetworkString("SlashCo:GiveSlasherData")
util.AddNetworkString("SlashCo:SlasherChaseMode")
util.AddNetworkString("SlashCo:SlasherKillPlayer")
util.AddNetworkString("SlashCo:PickingSlasher")
util.AddNetworkString("SlashCo:SelectSlasher")
util.AddNetworkString("SlashCo:SendLobbyItemGlobal")
util.AddNetworkString("SlashCo:SendGlobalInfoTable")
util.AddNetworkString("SlashCo:GlobalSound")
util.AddNetworkString("SlashCo:Briefing")
util.AddNetworkString("SlashCo:OfferingVoteOut")
util.AddNetworkString("SlashCo:VoteForOffering")
util.AddNetworkString("SlashCo:OfferingEndVote")
util.AddNetworkString("SlashCo:OfferingVoteFinished")
util.AddNetworkString("SlashCo:SendRoundData")
util.AddNetworkString("SlashCo:SurvivorVoicePrompt")
util.AddNetworkString("SlashCo:SurvivorPings")
util.AddNetworkString("SlashCo:MapAmbientPlay")
util.AddNetworkString("SlashCo:AskToBecomeSlasher")
util.AddNetworkString("SlashCo:Announcement")

local ENTITY = FindMetaTable("Entity")

-- play a sound on an entity
-- this function ensures the sound is played for everyone unlike EmitSound
function SlashCo.PlayGlobalSound(soundPath, soundLevel, ent, vol, permanent)
	if not IsValid(ent) or type(soundPath) ~= "string" then return end

	vol = vol or 1
	soundLevel = soundLevel or 0

	-- sound must be precached
	ent:EmitSound(soundPath, 1, 1, 0)

	net.Start("SlashCo:GlobalSound")
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
	net.Start("SlashCo:GlobalSound")
		net.WriteBool(true)
		net.WriteString("")
		net.WriteUInt(self:EntIndex(), MAX_EDICT_BITS)
	net.Broadcast()
end

ENTITY.OldStopSound = ENTITY.OldStopSound or ENTITY.StopSound
function ENTITY:StopSound(soundPath)
	self:OldStopSound(soundPath)

	net.Start("SlashCo:GlobalSound")
		net.WriteBool(true)
		net.WriteString(soundPath)
		net.WriteUInt(self:EntIndex(), MAX_EDICT_BITS)
	net.Broadcast()
end

-- DEPRECATED avoid using this
PlayGlobalSound = SlashCo.PlayGlobalSound

function SlashCo.LobbyRoundData()
	net.Start("SlashCo:SendRoundData")
		net.WriteTable({
			survivors = SlashCo.LobbyData.AssignedSurvivors,
			slashers = SlashCo.LobbyData.AssignedSlashers,
			offering = (SCInfo.Offering[SlashCo.LobbyData.Offering] or {}).Name
		})
	net.Broadcast()
end

function SlashCo.BroadcastCurrentRoundData(readygame)
	net.Start("SlashCo:SendRoundData")
		net.WriteTable({
			survivors = SlashCo.CurRound.SlasherData.AllSurvivors,
			slashers = SlashCo.CurRound.SlasherData.AllSlashers,
			offering = SlashCo.CurRound.OfferingData.OfferingName
		})
	net.Broadcast()

	net.Start("SlashCo:GiveSlasherData")
		net.WriteTable({
			GameProgress = SlashCo.CurRound.GameProgress,
			AllSurvivors = SlashCo.CurRound.SlasherData.AllSurvivors,
			AllSlashers = SlashCo.CurRound.SlasherData.AllSlashers,
			GameReadyToBegin = readygame
		})
	net.Broadcast()
end

function SlashCo.EndOfferingVote(ply)
	net.Start("SlashCo:OfferingEndVote")
		net.WriteUInt64(ply:SteamID64())
	net.Broadcast()
end

function SlashCo.OfferingVoteFinished(rarity) -- rarity can range from 1 to 3.
	net.Start("SlashCo:OfferingVoteFinished")
		net.WriteUInt(rarity, 2)
	net.Broadcast()
end

hook.Add("scValue_sendOffer", "slashCo_StartOfferingVote", function(ply, offerID)
	table.insert(SlashCo.LobbyData.Offerors, ply:SteamID64())
	SlashCo.BroadcastOfferingVote(ply, offerID)
	SlashCo.LobbyData.VotedOffering = offerID

	timer.Create("OfferingVoteTimer", 20, 1, function()
		SlashCo.OfferingVoteFail()
	end)
end)

function SlashCo.OfferingVote(ply, agreement)
	if not agreement then return end

	table.insert(SlashCo.LobbyData.Offerors, { steamid = ply:SteamID64() })
end

function SlashCo.BroadcastOfferingVote(offeror, offerID)
	net.Start("SlashCo:OfferingVoteOut")
		net.WriteEntity(offeror)
		net.WriteString(SCInfo.Offering[offerID].Name)
	net.Broadcast()
end

function SlashCo.LobbyPlayerBriefing()
	net.Start("SlashCo:Briefing")
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
		SCInfo.Maps[SlashCo.LobbyData.SelectedMap] and SCInfo.Maps[SlashCo.LobbyData.SelectedMap].NAME or SlashCo.LobbyData.SelectedMap,
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
			ply:SetRoundPoints("all_survive")
		end

		ply:SetRoundPoints("objective")
	end,
	[SlashCo.RoundState.WON_SOME_DEAD] = function(ply)
		ply:SetRoundPoints("objective")
	end,
	[SlashCo.RoundState.WON_ALL_DEAD] = function(ply)
		ply:SetRoundPoints("objective")
	end,
	[SlashCo.RoundState.LOST] = function() end,
	[SlashCo.RoundState.WON_DISTRESS] = function(ply)
		ply:SetRoundPoints("escape")
	end,
	[SlashCo.RoundState.CURSED] = function() end,
}

local pointStateSlasher = {
	[SlashCo.RoundState.WON_ALL_ALIVE] = function(ply) end,
	[SlashCo.RoundState.WON_SOME_DEAD] = function(ply) end,
	[SlashCo.RoundState.WON_ALL_DEAD] = function(ply)
		ply:SetRoundPoints("slasher_win")
	end,
	[SlashCo.RoundState.LOST] = function(ply)
		ply:SetRoundPoints("slasher_win")
	end,
	[SlashCo.RoundState.WON_DISTRESS] = function(ply)
		ply:SetRoundPoints("slasher_escape")
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
		local steamID = ply:SteamID64()
		for _, survivorData in ipairs(SlashCo.CurRound.SlasherData.AllSurvivors) do
			if steamID == survivorData.steamid then
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

function SlashCo.BroadcastGlobalData(ply)
	net.Start("SlashCo:SendGlobalInfoTable")
		net.WriteTable(SCInfo)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

-- All types are defined in sh_shared.lua -> SlashCo.HelicopterVoices
function SlashCo.HelicopterRadioVoice(type)
	local id = math.random(1, type == SlashCo.HelicopterVoices.INTRO and 8 or 5), 4
	if type == SlashCo.HelicopterVoices.INTRO then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/helipilot/helipilot_intro" .. id .. ".mp3",
			identifier = "HelipilotIntro",
			volume = 1,
			fadeIn = 0,
		})
		return
	end

	if type == SlashCo.HelicopterVoices.APPROACH then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/helipilot/helipilot_approach" .. id .. ".mp3",
			identifier = "HelipilotApproach",
			volume = 1,
			fadeIn = 0,
		})
		return
	end

	if type == SlashCo.HelicopterVoices.LAND then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/helipilot/helipilot_land" .. id .. ".mp3",
			identifier = "HelipilotLand",
			volume = 1,
			fadeIn = 0,
		})
		return
	end

	if type == SlashCo.HelicopterVoices.BEACON then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/helipilot/helipilot_beacon" .. id .. ".mp3",
			identifier = "HelipilotBeacon",
			volume = 1,
			fadeIn = 0,
		})
		return
	end
end

function SlashCo.BroadcastAnnouncement(text, time, ply)
	net.Start("SlashCo:Announcement")
		net.WriteUInt(time or (5 + (string.len(text) / 20)), 8)
		net.WriteString(text)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end