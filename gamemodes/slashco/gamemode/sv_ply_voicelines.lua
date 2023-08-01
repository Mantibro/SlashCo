local SlashCo = SlashCo or {}

local ConvoCount = 30

SlashCo.LobbyConvos = {

	{
		Length1 = 4,
		Length2 = 4,
		Length3 = 4
	},

	{
		Length1 = 2,
		Length2 = 2,
		Length3 = 3
	},

	{
		Length1 = 5.5,
		Length2 = 4,
		Length3 = 2
	},

	{
		Length1 = 2.5,
		Length2 = 2,
		Length3 = 3
	},

	{
		Length1 = 4,
		Length2 = 2,
		Length3 = 10
	},

	{
		Length1 = 5,
		Length2 = 5,
		Length3 = 3
	},

	{
		Length1 = 4,
		Length2 = 1,
		Length3 = 4
	},

	{
		Length1 = 3,
		Length2 = 2,
		Length3 = 3
	},

	{
		Length1 = 11,
		Length2 = 1,
		Length3 = 1
	},

	{
		Length1 = 13,
		Length2 = 1,
		Length3 = 6
	},

	{
		Length1 = 2,
		Length2 = 2,
		Length3 = 4
	},

	{
		Length1 = 5,
		Length2 = 3,
		Length3 = 3
	},

	{
		Length1 = 0.85,
		Length2 = 2,
		Length3 = 4
	},

	{
		Length1 = 6,
		Length2 = 2,
		Length3 = 1
	},

	{
		Length1 = 5,
		Length2 = 2,
		Length3 = 2
	},

	{
		Length1 = 4,
		Length2 = 3,
		Length3 = 3
	},

	{
		Length1 = 5,
		Length2 = 2,
		Length3 = 3
	},

	{
		Length1 = 3,
		Length2 = 9.5,
		Length3 = 6
	},

	{
		Length1 = 2,
		Length2 = 3,
		Length3 = 2
	},

	{
		Length1 = 1.5,
		Length2 = 1.3,
		Length3 = 3
	},

	{
		Length1 = 1.8,
		Length2 = 4,
		Length3 = 3
	},

	{
		Length1 = 10,
		Length2 = 3,
		Length3 = 4
	},

	{
		Length1 = 2,
		Length2 = 3,
		Length3 = 3
	},

	{
		Length1 = 6,
		Length2 = 1.5,
		Length3 = 3
	},

	{
		Length1 = 11,
		Length2 = 1,
		Length3 = 1
	},

	{
		Length1 = 4,
		Length2 = 3,
		Length3 = 2
	},

	{
		Length1 = 6,
		Length2 = 5,
		Length3 = 3
	},

	{
		Length1 = 3,
		Length2 = 3,
		Length3 = 4
	},

	{
		Length1 = 5,
		Length2 = 9,
		Length3 = 5
	},

	{
		Length1 = 5,
		Length2 = 5,
		Length3 = 2
	},

	{
		Length1 = 5,
		Length2 = 7,
		Length3 = 3
	},

	{
		Length1 = 2,
		Length2 = 3,
		Length3 = 3
	},

	{
		Length1 = 3,
		Length2 = 3,
		Length3 = 6
	},

	{
		Length1 = 4,
		Length2 = 2,
		Length3 = 3
	},

	{
		Length1 = 13,
		Length2 = 1.5,
		Length3 = 1.5
	},

	{
		Length1 = 5,
		Length2 = 5,
		Length3 = 4
	}

}

SlashCo.LobbyBanter = function()
	local survivors = team.GetPlayers(TEAM_SURVIVOR)

	if #survivors < 2 then
		return 5
	end

	local predelay = math.random(2, 4)

	local convo = math.random(1, ConvoCount)

	local totalLength = SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2 + SlashCo.LobbyConvos[convo].Length3 + predelay

	local function playVocal(conv, id, plyid)
		survivors[plyid]:EmitSound("slashco/survivor/voice/maleconv_" .. conv .. "_" .. id .. ".mp3")
	end

	local firstid = math.random(1, #survivors)
	timer.Simple(predelay, function()
		playVocal(convo, 1, firstid)
	end)

	local secondid = math.random(1, #survivors)
	if secondid == firstid then
		secondid = 1
	end
	if secondid == firstid then
		secondid = 2
	end

	local thirdid = math.random(1, #survivors)
	if thirdid == secondid then
		thirdid = 1
	end
	if thirdid == secondid then
		thirdid = 2
	end

	timer.Simple(predelay + SlashCo.LobbyConvos[convo].Length1, function()
		playVocal(convo, 2, secondid)
	end)

	timer.Simple(predelay + SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2, function()
		playVocal(convo, 3, thirdid)
	end)

	return totalLength
end

net.Receive("mantislashcoSurvivorVoicePrompt", function(_, ply)
	if game.GetMap() == "sc_lobby" and SlashCo.LobbyData.LOBBYSTATE == 2 then
		return
	end

	if ply.VoicePromptCooldown and CurTime() - ply.VoicePromptCooldown < 1 then
		return
	end
	ply.VoicePromptCooldown = CurTime()

	local prompt = net.ReadString()
	ply:EmitSound("slashco/survivor/voice/prompt_" .. prompt .. math.random(1, 5) .. ".mp3")
end)

SlashCo.EscapeVoicePrompt = function()
	if team.NumPlayers(TEAM_SURVIVOR) < 1 then
		return
	end

	local function playVoice(ply)
		ply:EmitSound("slashco/survivor/voice/prompt_escape" .. math.random(1, 5) .. ".mp3")
	end

	local survs = team.GetPlayers(TEAM_SURVIVOR)

	local speaking_survs = {}

	if #survs < 2 then
		playVoice(survs[1])
		return
	end

	table.insert(speaking_survs, survs[1])

	for i = 1, #survs do
		local survivor = survs[i]

		for s = 1, #speaking_survs do
			if speaking_survs[s] == survivor then
				goto SKIP
			end

			if survivor:GetPos():Distance(speaking_survs[s]:GetPos()) > 750 then
				table.insert(speaking_survs, survs[i])
				goto SKIP
			end
		end

		:: SKIP ::
	end

	for s = 1, #speaking_survs do
		playVoice(speaking_survs[s])
	end
end