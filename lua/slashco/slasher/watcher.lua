local SLASHER = {}

SLASHER.Name = "The Watcher"
SLASHER.Aliases = {
	"The Agent",
	"Big Brother",
}
SLASHER.Class = SlashCo.SlasherClass.Umbra
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/watcher/watcher.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 5
SLASHER.ProwlSpeed = 185
SLASHER.ChaseSpeed = 340
SLASHER.Perception = 0.8
SLASHER.Eyesight = 7
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 2000
SLASHER.ChaseRadius = 0.96
SLASHER.ChaseDuration = 2.0
SLASHER.ChaseCooldown = 2
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/watcher/watcher_chase.ogg"
SLASHER.KillSound = "slashco/slasher/watcher/watcher_kill.mp3"
SLASHER.Description = "Watcher_desc"
SLASHER.ProTip = "Watcher_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★★★★☆"
SLASHER.DiffRating = "★★☆☆☆"
SLASHER.AngerIncrease = 10 -- Anger increase of objectives being completed
SLASHER.AngerPassiveGain = 0.05
SLASHER.AngerChaseGain = 0
SLASHER.AngerWatchingGain = 0.15 -- Anger thats gained per second when hes watching someone.
SLASHER.LowAngerBackgroundMusic = "slashco/slasher/watcher/watchertheme_med.ogg"
SLASHER.MediumAngerBackgroundMusic = "slashco/slasher/watcher/watchertheme_med.ogg"
SLASHER.HighAngerBackgroundMusic = "slashco/slasher/watcher/watchertheme_high.ogg"
-- Balancement Vars
SLASHER.SurveyLength = 10 -- How long a survey goes
SLASHER.SurveyCooldown = 100 -- How long the survey cooldown is.
SLASHER.SurveyDisplayLength = 5 -- How long the survey texture is displayed on survivors screen.

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors, SO)
	SLASHER.SurveyLength = 10 + (SO * 10) + (1 * additionalSurvivors)
	SLASHER.SurveyCooldown = 100 + (SO * 35) + (2.5 * additionalSurvivors)
	SLASHER.SurveyDisplayLength = 5 + (SO * 5)

	if additionalSurvivors > 0 then
		SLASHER.ProwlSpeed = 185 + (3 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	slasher:SetViewOffset(Vector(0, 0, 100))
	slasher:SetCurrentViewOffset(Vector(0, 0, 100))
	slasher:SetCanChase(true)
	slasher:SetCanKill(true)

	slasher.SurveyLength = 0
	slasher.SurveyCooldown = 0
	slasher.WatcherWatched = 0
	slasher.StalkTime = 0
end

function SLASHER.OnAngerTick(slasher)
	if slasher:GetNW2Bool("WatcherStalking") then
		SlashCo.AddSlasherAnger(slasher, SLASHER.AngerWatchingGain)
	end
end

function SLASHER.OnTickBehaviour(slasher)
	local SurveyLG = slasher.SurveyLength or 0 --Survey Length
	local SurveyCD = slasher.SurveyCooldown or 0 --Survey Cooldown
	local Watched = slasher.WatcherWatched or 0 --Watched
	local Stalking = slasher.StalkTime or 0 --Stalk time

	slasher.WatcherWatched = slasher:GetNW2Bool("WatcherWatched") and 1 or 0

	if not slasher:GetNW2Bool("WatcherRage") then
		if SurveyLG > 0 then
			slasher.SurveyLength = SurveyLG - FrameTime()
		end
	else
		slasher.SurveyLength = 1
		slasher.WatcherWatched = 0.65
		slasher:SetCanChase(false)
	end

	if slasher:GetInSlasherChaseMode() then
		slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed - (Watched * 80))
		slasher:SetWalkSpeed(SLASHER.ChaseSpeed - (Watched * 80))
		slasher:SetRunSpeed(SLASHER.ChaseSpeed - (Watched * 80))
	else
		slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed - (Watched * 120))
		slasher:SetWalkSpeed(SLASHER.ProwlSpeed - (Watched * 120))
		slasher:SetRunSpeed(SLASHER.ProwlSpeed - (Watched * 120))
	end

	if slasher:GetNW2Bool("WatcherRage") then
		slasher:SetSlowWalkSpeed(300)
		slasher:SetWalkSpeed(300)
		slasher:SetRunSpeed(300)
	end

	if SurveyCD > 0 then
		slasher.SurveyCooldown = SurveyCD - FrameTime()
	end

	local isSeen = false

	for _, surv in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if SurveyLG > 0 then
			if not surv:GetSurvivorWatcherSurveyed() then
				surv:SetSurvivorWatcherSurveyed(true)
			end
		else
			if surv:GetSurvivorWatcherSurveyed() then
				surv:SetSurvivorWatcherSurveyed(false)
			end

			local trace = surv:GetEyeTrace()
			local find = ents.FindInCone(surv:GetPos(), trace.Normal, 3000, 0.5)
			local target

			if trace.Entity == slasher then
				target = slasher
				goto FOUND
			end

			do
				for i = 1, #find do
					if find[i] == slasher then
						target = find[i]
						break
					end
				end

				if IsValid(target) then
					local tr = util.TraceLine({
						start = surv:EyePos(),
						endpos = target:GetPos() + Vector(0, 0, 50),
						filter = surv
					})

					if tr.Entity ~= target then
						target = nil
					end
				end
			end
			:: FOUND ::

			if IsValid(target) and target == slasher then
				surv:SetSurvivorWatcherSurveyed(true)
				isSeen = true
			else
				if surv:GetSurvivorWatcherSurveyed() then
					surv:SetSurvivorWatcherSurveyed(false)
				end
			end
		end
	end

	slasher:SetNW2Bool("WatcherWatched", isSeen)

	--Stalk Survivors

	local trace = slasher:GetEyeTrace()
	local find = ents.FindInCone(slasher:GetPos(), trace.Normal, 1500, 0.85)
	local target

	if trace.Entity:IsPlayer() and trace.Entity:Team() == TEAM_SURVIVOR then
		target = trace.Entity
		goto FOUND
	end

	do
		for i = 1, #find do
			if find[i]:IsPlayer() and find[i]:Team() == TEAM_SURVIVOR then
				target = find[i]
				break
			end
		end

		if IsValid(target) then
			local tr = util.TraceLine({
				start = slasher:EyePos(),
				endpos = target:GetPos() + Vector(0, 0, 50),
				filter = slasher
			})

			if tr.Entity ~= target then
				target = nil
			end
		end
	end
	:: FOUND ::

	if IsValid(target) and isSeen == false and not slasher:GetInSlasherChaseMode() then
		slasher.StalkTime = Stalking + FrameTime()
		if not slasher:GetNW2Bool("WatcherStalking") then
			slasher:SetNW2Bool("WatcherStalking", true)
		end
	else
		if slasher:GetNW2Bool("WatcherStalking") then
			slasher:SetNW2Bool("WatcherStalking", false)
		end
	end

	slasher:SetNW2Bool("WatcherCanSurvey", SurveyCD < 0.1)
	slasher:SetNW2Int("WatcherStalkTime", Stalking)
	slasher:SetEyeSight(SLASHER.Eyesight)
	slasher:SetPerception(SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if (slasher.SurveyCooldown or 0) > 0 then return end
	if slasher:GetNW2Bool("WatcherRage") then return end

	slasher.SurveyLength = SLASHER.SurveyLength
	slasher.SurveyCooldown = SLASHER.SurveyCooldown

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/watcher/watcher_locate.mp3",
		identifier = "WatcherLocate",
		minDistance = 1000,
		maxDistance = 2000,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	for _, p in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		p:SetNW2Bool("WatcherSurveyed", true)

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/watcher/watcher_see.mp3",
			identifier = "WatcherSee",
			entity = p,
			volume = 1,
			fadeIn = 0,
			fadeOutStart = SLASHER.SurveyDisplayLength,
			fadeOut = 0.5,
		})
	end

	timer.Simple(SLASHER.SurveyDisplayLength, function()
		for _, p in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			p:SetNW2Bool("WatcherSurveyed", false)
		end
	end)
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if SlashCo.CurRound.GameProgress < (10 - (slasher.StalkTime / 25)) then return end
	if slasher:GetNW2Bool("WatcherRage") then return end
	if team.NumPlayers(TEAM_SURVIVOR) < 2 then return end

	slasher:SetNW2Bool("WatcherRage", true)
	SlashCo.AudioSystem.DisableBackgroundMusic()

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/watcher/watcher_rage.ogg",
		identifier = "WatcherRage",
		minDistance = 1000 * SlashCo.MapSize,
		maxDistance = 2000 * SlashCo.MapSize,
		looping = true,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
end

function SLASHER.Animator(ply)
	local rage = ply:GetNW2Bool("WatcherRage")
	local chase = ply:GetInSlasherChaseMode()

	if ply:IsOnGround() then
		if not chase or rage then
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	local idx = math.random(1, 4)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/watcher/watcher_boot" .. idx .. ".mp3",
		identifier = "WatcherFootstep" .. idx,
		group = "SlasherFootstep",
		minDistance = 250,
		maxDistance = 550,
		entity = ply,
		volume = 1,
		fadeIn = 0,
		excludeSendTo = ply,
	})

	return false
end

local surveyTable = {
	default = Material("slashco/ui/icons/slasher/watcher_a1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

local function canSurveil()
	return SlashCo.GetGameProgress() > (10 - (GameData.LocalPlayer:GetNW2Int("WatcherStalkTime") / 25))
			and not GameData.LocalPlayer:GetNW2Bool("WatcherRage") and team.NumPlayers(TEAM_SURVIVOR) > 1
end

local surveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
local red = Color(255, 0, 0)
function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/watcher"))
	hud:SetTitle("Watcher")

	hud:AddControl("R", "survey", surveyTable)
	hud:ChaseAndKill()
	hud:AddControl("F", "full surveillance", surveyTable)
	hud:TieControl("R", "WatcherCanSurvey")
	hud:TieControlVisible("R", "WatcherRage", true, true)

	hud.prevSurveil = not canSurveil()
	function hud.AlsoThink()
		local surveil = canSurveil()
		if surveil ~= hud.prevSurveil then
			hud:SetControlVisible("F", surveil)
			hud.prevSurveil = surveil
		end
	end

	function hud.TitleCard.Label:PaintOver()
		draw.SimpleText("STALK TIME: " .. math.Round(GameData.LocalPlayer:GetNW2Int("WatcherStalkTime"), 1), "TVCD", 4, 18, red)
	end
end

function SLASHER.DrawHUD(localPly)
	if localPly:GetNW2Bool("WatcherWatched") then
		draw.SimpleText("YOU ARE BEING WATCHED. . .", "ItemFontTip", ScrW() / 2, ScrH() / 4,
				Color(255, 0, 0, 255),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	if localPly:GetNW2Bool("WatcherStalking") then
		draw.SimpleText("OBSERVING A SURVIVOR. . .", "ItemFontTip", ScrW() / 2, ScrH() / 4,
				Color(255, 0, 0, 255),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	surface.SetDrawColor(255, 255, 255, 255)
	for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if not survivor:GetSurvivorWatcherSurveyed() then
			continue
		end

		if not survivor:CanBeSeen() then
			continue
		end

		local pos = survivor:EyePos():ToScreen()
		if pos.visible then
			surface.SetMaterial(surveyNoticeIcon)
			surface.DrawTexturedRect(pos.x - ScrW() / 32, pos.y - ScrW() / 32, ScrW() / 16, ScrW() / 16)
		end
	end
end

if CLIENT then
	hook.Add("SlashCo:DrawHUD", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetSurvivorJumpscare() == SLASHER.ID then
			local Overlay = Material("slashco/ui/overlays/watcher_see")

			Overlay:SetFloat("$alpha", 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end

		if GameData.LocalPlayer:GetNW2Bool("WatcherSurveyed") then
			if GameData.LocalPlayer.al_watch == nil then
				GameData.LocalPlayer.al_watch = 0
			end
			if GameData.LocalPlayer.al_watch < 100 then
				GameData.LocalPlayer.al_watch = GameData.LocalPlayer.al_watch + (FrameTime() * 100)
			end

			local Overlay = Material("slashco/ui/overlays/watcher_see")

			Overlay:SetFloat("$alpha", 1 - (GameData.LocalPlayer.al_watch / 100))

			surface.SetDrawColor(255, 255, 255, 60)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.al_watch = nil
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Watcher")