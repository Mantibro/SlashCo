SlashCo = SlashCo or {}
SlashCo.LobbyConvos = {}

-- RaphaelIT7: We force voice lines to be .mp3 and don't support any other even if we could. If it's truly needed tell me but I doubt that.

local voiceFolder = "slashco/survivor/voice/"
local function LoadVoiceLines()
	SlashCo.LobbyConvos = {}
	local lookup = {}
	local voiceFiles = file.Find("sound/slashco/survivor/voice/maleconv_*", "GAME")
	for _, fileName in ipairs(voiceFiles) do
		local convoID, partID = string.match(fileName, "^maleconv_(%d+)_(%d+)%.mp3$")

		local convoTbl = SlashCo.LobbyConvos[lookup[convoID]]
		if not convoTbl then
			convoTbl = {
				ID = convoID, -- Used for file lookups later!
				Parts = 0,
			}
			lookup[convoID] = table.insert(SlashCo.LobbyConvos, convoTbl)
		end

		-- If at any point a convo is falsely named like maleconv_1_1 and then maleconv_1_3 skipping 2 then the third part is treated as invalid too!
		if (convoTbl.Parts + 1) == tonumber(partID) then
			convoTbl.Parts = convoTbl.Parts + 1
		end
	end

	-- Now we remove any invalid index that has no parts
	-- We keep SlashCo.LobbyConvos as a sequential table!
	local idx = 1
	while idx <= #SlashCo.LobbyConvos do
		if SlashCo.LobbyConvos[idx].Parts == 0 then
			table.remove(SlashCo.LobbyConvos, idx)
		else
			idx = idx + 1
		end
	end
end
LoadVoiceLines()

hook.Add("SlashCo:GameContentChanged", "SlashCo:VoiceLines", LoadVoiceLines)

-- Performance wise this is not great- but this is only supposed to be called once in the lobby sooo it'll be fine.
local function GetTotalConvoLength(convoTbl)
	local lengthData = {}
	for partID=1, convoTbl.Parts do
		lengthData[partID] = SoundDuration("slashco/survivor/voice/maleconv_" .. convoTbl.ID .. "_" .. partID .. ".mp3")
	end

	return lengthData
end

function SlashCo.LobbyBanter()
	local survivors = team.GetPlayers(TEAM_SURVIVOR)
	local totalSurvivors = #survivors
	if totalSurvivors < 2 then
		return 5
	end

	local predelay = math.random(2, 4)
	local convoTbl = SlashCo.LobbyConvos[math.random(1, #SlashCo.LobbyConvos)]
	local lengthData = GetTotalConvoLength(convoTbl)
	local function playVocal(convoTbl, partID, ply)
		if not IsValid(ply) or not convoTbl then return end

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/survivor/voice/maleconv_" .. convoTbl.ID .. "_" .. partID .. ".mp3",
			identifier = "SurvivorVoice",
			minDistance = 200,
			maxDistance = 400,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end

	local talkingSurvivors = {}
	for k=1, convoTbl.Parts do
		if #survivors > 0 then
			table.insert(talkingSurvivors, table.remove(survivors, math.random(1, #survivors))) -- It is guaranteed due to the above check that at minimum two survivors exist!
		else
			-- Funky!
			-- k-1 because else it uses the second and not first in some cases
			-- Using totalSurvivors since if we used #talkingSurvivors the calculation would break
			-- +1 since else we may use 0 which is not an index in Lua
			table.insert(talkingSurvivors, talkingSurvivors[((k - 1) % totalSurvivors) + 1])
		end
	end

	-- Now talkingSurvivors should contain an equal amount of entires for the parts count!

	timer.Simple(predelay, function()
		playVocal(convoTbl, 1, talkingSurvivors[1])
	end)

	local totalLength = predelay
	for partID=2, convoTbl.Parts do
		local partLength = lengthData[partID] or 0
		if partLength <= 0 then continue end

		totalLength = totalLength + partLength
		timer.Simple(predelay + totalLength, function()
			playVocal(convoTbl, partID, talkingSurvivors[partID])
		end)
	end

	return totalLength
end

net.Receive("SlashCo:SurvivorVoicePrompt", function(_, ply)
	if GameData.IsLobby and SlashCo.LobbyData.LOBBYSTATE == 2 then
		return
	end

	if ply.VoicePromptCooldown and CurTime() - ply.VoicePromptCooldown < 1 then
		return
	end
	ply.VoicePromptCooldown = CurTime()

	local prompt = net.ReadString()
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/voice/prompt_" .. prompt .. math.random(1, 5) .. ".mp3",
		identifier = "SurvivorVoicePrompt",
		minDistance = 200,
		maxDistance = 400,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})
end)

function SlashCo.EscapeVoicePrompt()
	local survivors = team.GetPlayers(TEAM_SURVIVOR)
	if #survivors == 0 then
		return
	end

	local function playVoice(ply)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/survivor/voice/prompt_escape" .. math.random(1, 5) .. ".mp3",
			identifier = "SurvivorVoicePrompt",
			minDistance = 200,
			maxDistance = 400,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end

	if #survivors == 1 then
		playVoice(survivors[1])
		return
	end

	local talkingSurvivors = { survivors[1] }
	for idx, survivor in ipairs(survivors) do
		for talkingIdx=1, #talkingSurvivors do
			if talkingSurvivors[talkingIdx] == survivor then
				break
			end

			if survivor:GetPos():Distance(talkingSurvivors[talkingIdx]:GetPos()) > 750 then
				table.insert(talkingSurvivors, survivor)
				break
			end
		end
	end

	for _, talkingPly in ipairs(talkingSurvivors) do
		playVoice(talkingPly)
	end
end