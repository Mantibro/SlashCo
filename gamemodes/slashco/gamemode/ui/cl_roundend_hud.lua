local function printPlayersNeatly(players)
	local count = #players
	if count == 0 then
		return SlashCoLanguage("nobody"), 0
	end
	if count == 1 then
		return players[1]:GetName(), 1
	end
	if count == 2 then
		return SlashCoLanguage("TwoElements", players[1]:GetName(), players[2]:GetName()), 2
	end

	local strings = {}
	for i = 1, count - 2 do
		table.insert(SlashCoLanguage("InList", players[i]:GetName()))
	end
	table.insert(SlashCoLanguage("TwoElements", players[count - 1]:GetName(), players[count]:GetName()))

	return table.concat(strings), count
end

local function printRescued(rescued)
	local neatString, count = printPlayersNeatly(rescued)
	if count <= 0 then
		return
	end
	return SlashCoLanguage(count == 1 and "RescuedOnlyOne" or "Rescued", neatString)
end

local function printLeftBehind(survivors, rescued)
	local plysLeftBehind = table.Copy(survivors)
	for k, ply in ipairs(plysLeftBehind) do
		if ply:Team() ~= TEAM_SURVIVOR then
			table.remove(plysLeftBehind, k)
			continue
		end
		for _, v in ipairs(rescued) do
			if ply == v then
				table.remove(plysLeftBehind, k)
				break
			end
		end
	end

	local neatString, count = printPlayersNeatly(plysLeftBehind)
	if count <= 0 then
		return
	end
	return SlashCoLanguage(count == 1 and "leftBehindOnlyOne" or "LeftBehind", neatString)
end

local function printKilled(survivors)
	local plysKilled = table.Copy(survivors)
	for k, ply in ipairs(plysKilled) do
		if ply:Team() == TEAM_SURVIVOR then
			table.remove(plysKilled, k)
		end
	end

	local neatString, count = printPlayersNeatly(plysKilled)
	if count <= 0 then
		return
	end
	return SlashCoLanguage(count == 1 and "KilledOnlyOne" or "Killed", neatString)
end

local function teamSummary(lines, survivors, rescued)
	local rescuedString = printRescued(rescued)
	if rescuedString then
		table.insert(lines, rescuedString)
	end

	local leftBehindString = printLeftBehind(survivors, rescued)
	if leftBehindString then
		table.insert(lines, leftBehindString)
	end

	local killedString = printKilled(survivors)
	if killedString then
		table.insert(lines, killedString)
	end
end

local dangerTable = {
	[0] = "Unknown",
	"Moderate",
	"Considerable",
	"Devastating"
}
local classTable = {
	[0] = "Unknown",
	"Cryptid",
	"Demon",
	"Umbra"
}
local difficultyTable = {
	[0] = "Easy",
	"Novice",
	"Intermediate",
	"Hard"
}
local stateTable = {
	[0] = "wonAllSurvivors",
	"wonSomeSurvivors",
	"wonNoSurvivors",
	"lost",
	"wonBeacon",
	"cursed",
	"intro"
}
local stringTable = {
	wonAllSurvivors = function()
		surface.PlaySound("slashco/music/slashco_win_full.mp3")
		return {
			SlashCoLanguage("AssignmentSuccess"),
			SlashCoLanguage("AllRescued"),
		}
	end,
	wonSomeSurvivors = function(survivors, rescued)
		surface.PlaySound("slashco/music/slashco_win_2.mp3")
		local lines = {
			SlashCoLanguage("AssignmentSuccess"),
			SlashCoLanguage("SomeRescued"),
		}
		teamSummary(lines, survivors, rescued)

		return lines
	end,
	wonNoSurvivors = function()
		surface.PlaySound("slashco/music/slashco_lost_active.mp3")
		return {
			SlashCoLanguage("AssignmentSuccess"),
			SlashCoLanguage("NoneRescued"),
		}
	end,
	lost = function()
		surface.PlaySound("slashco/music/slashco_lost.mp3")
		return {
			SlashCoLanguage("AssignmentFail"),
			SlashCoLanguage("NoneRescued"),
		}
	end,
	wonBeacon = function(survivors, rescued)
		surface.PlaySound("slashco/music/slashco_win_db.mp3")
		local lines = {
			SlashCoLanguage("AssignmentAborted"),
		}
		teamSummary(lines, survivors, rescued)

		return lines
	end,
	cursed = function()
		surface.PlaySound("slashco/music/slashco_lost.mp3")
		local lines = {}
		for i = 0, 19 do
			local line = string.Split(SlashCoLanguage("Cursed"), SlashCoLanguage("WordSeparator"))
			for i1 = 1, i do
				line[math.random(1, #line)] = SlashCoLanguage("Judgement")
			end
			table.insert(lines, table.concat(line, SlashCoLanguage("WordSeparator")))
		end

		return lines
	end,
	intro = function(info)
		surface.PlaySound("slashco/music/slashco_intro.mp3")
		local lines = {
			SlashCoLanguage("cur_assignment", info[1]),
			SlashCoLanguage("slasher_assess"),
			SlashCoLanguage("Name", info[2]),
			SlashCoLanguage("Class", classTable[info[3]]),
			SlashCoLanguage("DangerLevel", dangerTable[info[4]]),
			SlashCoLanguage("Difficulty", difficultyTable[info[5]]),
		}
		if info[6] ~= "Regular" then
			table.insert(lines, SlashCoLanguage("Offering_name", difficultyTable[info[6]]))
		end

		return lines
	end
}

local function fadeIn(panel)
	local anim = Derma_Anim("Fade", nil, function(_, _, delta)
		panel:SetAlpha(255 * delta)
	end)
	anim:Start(1)

	function panel.Think()
		if anim:Active() then
			anim:Run()
		end
	end
end

local function nextLine(panel, lines)
	local line = panel:Add("DLabel")
	line:Dock(TOP)
	line:SetFont("OutroFont")
	line:SetContentAlignment(8)
	line:SetTall(40)
	line:SetText(lines[#lines])

	timer.Simple(0, function()
		local w = line:GetTextSize()
		if w > ScrW() then
			line:SetWrap(true)
			line:SetTall(80)
		end
	end)

	fadeIn(line)

	local fill = panel:Add("Panel")
	fill:Dock(TOP)
	fill:SetTall(ScrH() / 20)

	table.remove(lines)
end

hook.Add("scValue_RoundEnd", "SlashCoRoundEnd", function(state, survivors, rescued)
	local stateString = stateTable[state]
	local lines = stringTable[stateString](survivors, rescued)
	if table.IsEmpty(lines) then
		return
	end

	local linesPlay = table.Reverse(lines)
	local panel = vgui.Create("Panel") --GetHUDPanel():Add("Panel")
	panel:Dock(FILL)
	fadeIn(panel)

	function panel.Paint()
		surface.SetDrawColor(0, 0, 0)
		panel:DrawFilledRect()
	end

	timer.Simple(0, function()
		if not IsValid(panel) then
			return
		end

		local fill = panel:Add("Panel")
		fill:Dock(TOP)
		fill:SetTall(ScrH() / 5)

		nextLine(panel, linesPlay)

		local fill1 = panel:Add("Panel")
		fill1:Dock(TOP)
		fill1:SetTall(ScrH() / 20)
	end)

	local shows
	timer.Create("SlashCoRoundEnd", 1, 0, function()
		if not next(linesPlay) or not IsValid(panel) then
			timer.Remove("SlashCoRoundEndThink")
			return
		end

		if not shows then
			shows = true
			return
		end

		nextLine(panel, linesPlay)
	end)
end)

local helimusic_antispam
net.Receive("mantislashcoHelicopterMusic", function(_, _)

	--[[ but what if le slashers le heard le music.........
	if LocalPlayer():Team() == TEAM_SLASHER then
		return
	end
	--]]

	if not helimusic_antispam then
		local heli_music = CreateSound(LocalPlayer(), "slashco/music/slashco_helicopter.wav")
		heli_music:Play()
		helimusic_antispam = true
		g_AmbientStop = true
	end
end)