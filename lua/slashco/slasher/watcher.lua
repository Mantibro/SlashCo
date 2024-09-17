local SLASHER = {}

SLASHER.Name = "The Watcher"
SLASHER.ID = 10
SLASHER.Class = 3
SLASHER.DangerLevel = 2
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/watcher/watcher.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 5
SLASHER.ProwlSpeed = 200
SLASHER.ChaseSpeed = 340
SLASHER.Perception = 0.8
SLASHER.Eyesight = 7
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 2000
SLASHER.ChaseRadius = 0.96
SLASHER.ChaseDuration = 2.0
SLASHER.ChaseCooldown = 2
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/watcher_chase.wav"
SLASHER.KillSound = "slashco/slasher/watcher_kill.mp3"
SLASHER.Description = "Watcher_desc"
SLASHER.ProTip = "Watcher_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★★★★☆"
SLASHER.DiffRating = "★★☆☆☆"

SLASHER.OnSpawn = function(slasher)
	slasher:SetViewOffset(Vector(0, 0, 100))
	slasher:SetCurrentViewOffset(Vector(0, 0, 100))
	slasher:SetNWBool("CanChase", true)
	slasher:SetNWBool("CanKill", true)
end

SLASHER.OnTickBehaviour = function(slasher)
	--local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --Survey Length
	local v2 = slasher.SlasherValue2 --Survey Cooldown
	local v3 = slasher.SlasherValue3 --Watched
	local v4 = slasher.SlasherValue4 --Stalk time

	slasher.SlasherValue3 = slasher:GetNWBool("WatcherWatched") and 1 or 0

	if not slasher:GetNWBool("WatcherRage") then
		if v1 > 0 then
			slasher.SlasherValue1 = v1 - FrameTime()
		end
	else
		slasher.SlasherValue1 = 1
		slasher.SlasherValue3 = 0.65
		SlashCoSlashers[slasher:GetNWString("Slasher")].CanChase = false
	end

	if slasher:GetNWBool("InSlasherChaseMode") or slasher:GetNWBool("WatcherRage") then
		slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed - (v3 * 80))
		slasher:SetWalkSpeed(SLASHER.ChaseSpeed - (v3 * 80))
		slasher:SetRunSpeed(SLASHER.ChaseSpeed - (v3 * 80))
	else
		slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed - (v3 * 120))
		slasher:SetWalkSpeed(SLASHER.ProwlSpeed - (v3 * 120))
		slasher:SetRunSpeed(SLASHER.ProwlSpeed - (v3 * 120))
	end

	if v2 > 0 then
		slasher.SlasherValue2 = v2 - FrameTime()
	end

	local isSeen = false

	for _, surv in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if v1 > 0 then
			if not surv:GetNWBool("SurvivorWatcherSurveyed") then
				surv:SetNWBool("SurvivorWatcherSurveyed", true)
			end
		else
			if surv:GetNWBool("SurvivorWatcherSurveyed") then
				surv:SetNWBool("SurvivorWatcherSurveyed", false)
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
				surv:SetNWBool("SurvivorWatcherSurveyed", true)
				isSeen = true
			else
				if surv:GetNWBool("SurvivorWatcherSurveyed") then
					surv:SetNWBool("SurvivorWatcherSurveyed", false)
				end
			end
		end
	end

	slasher:SetNWBool("WatcherWatched", isSeen)

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

	if IsValid(target) and isSeen == false and not slasher:GetNWBool("InSlasherChaseMode") then
		slasher.SlasherValue4 = v4 + FrameTime()
		if not slasher:GetNWBool("WatcherStalking") then
			slasher:SetNWBool("WatcherStalking", true)
		end
	else
		if slasher:GetNWBool("WatcherStalking") then
			slasher:SetNWBool("WatcherStalking", false)
		end
	end

	if v2 < 0.1 and slasher:GetNWBool("WatcherCanSurvey") ~= true then
		slasher:SetNWBool("WatcherCanSurvey", true)
	end

	if v2 >= 0.1 and slasher:GetNWBool("WatcherCanSurvey") ~= false then
		slasher:SetNWBool("WatcherCanSurvey", false)
	end

	slasher:SetNWInt("WatcherStalkTime", v4)
	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher.SlasherValue2 > 0 then
		return
	end
	if slasher:GetNWBool("WatcherRage") then
		return
	end

	slasher.SlasherValue1 = 10 + (SO * 10)
	slasher.SlasherValue2 = 100 - (SO * 35)

	slasher:PlayGlobalSound("slashco/slasher/watcher_locate.mp3", 100)

	for _, p in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		p:SetNWBool("WatcherSurveyed", true)
		p:EmitSound("slashco/slasher/watcher_see.mp3")
	end

	timer.Simple(5 + (SO * 5), function()
		for _, p in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			p:SetNWBool("WatcherSurveyed", false)
		end
	end)
end

SLASHER.OnSpecialAbilityFire = function(slasher)
	--local SO = SlashCo.CurRound.OfferingData.SO

	if SlashCo.CurRound.GameProgress < (10 - (slasher.SlasherValue4 / 25)) then
		return
	end
	if slasher:GetNWBool("WatcherRage") then
		return
	end
	if team.NumPlayers(TEAM_SURVIVOR) < 2 then
		return
	end

	slasher:SetNWBool("WatcherRage", true)
	slasher:PlayGlobalSound("slashco/slasher/watcher_rage.wav", 100)
end

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if ply:IsOnGround() then
		if not chase then
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

SLASHER.Footstep = function(ply)
	if SERVER then
		ply:EmitSound("npc/footsteps/hardboot_generic" .. math.random(1, 6) .. ".wav", 50, 90, 0.75)
		return false
	end

	if CLIENT then
		return false
	end
end

local surveyTable = {
	default = Material("slashco/ui/icons/slasher/s_10_a1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

local function canSurveil()
	return LocalPlayer():GetNWInt("GameProgressDisplay") > (10 - (LocalPlayer():GetNWInt("WatcherStalkTime") / 25))
			and not LocalPlayer():GetNWBool("WatcherRage") and team.NumPlayers(TEAM_SURVIVOR) > 1
end

local surveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
local red = Color(255, 0, 0)
SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_10"))
	hud:SetTitle("Watcher")

	hud:AddControl("R", "survey", surveyTable)
	hud:ChaseAndKill()
	hud:AddControl("F", "full surveillance", surveyTable)
	hud:TieControl("R", "WatcherCanSurvey")
	hud:TieControlVisible("R", "WatcherRage", true, true, false)

	hud.prevSurveil = not canSurveil()
	function hud.AlsoThink()
		local surveil = canSurveil()
		if surveil ~= hud.prevSurveil then
			hud:SetControlVisible("F", surveil)
			hud.prevSurveil = surveil
		end
	end

	function hud.TitleCard.Label:PaintOver()
		draw.SimpleText("STALK TIME: " .. LocalPlayer():GetNWInt("WatcherStalkTime"), "TVCD", 4, 18, red)
	end

	hook.Add("HUDPaint", "SlashCoWatcher", function()
		if LocalPlayer():Team() ~= TEAM_SLASHER then
			hook.Remove("HUDPaint", "SlashCoWatcher")
			return
		end

		if LocalPlayer():GetNWBool("WatcherWatched") then
			draw.SimpleText("YOU ARE BEING WATCHED. . .", "ItemFontTip", ScrW() / 2, ScrH() / 4,
					Color(255, 0, 0, 255),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		if LocalPlayer():GetNWBool("WatcherStalking") then
			draw.SimpleText("OBSERVING A SURVIVOR. . .", "ItemFontTip", ScrW() / 2, ScrH() / 4,
					Color(255, 0, 0, 255),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:GetNWBool("SurvivorWatcherSurveyed") then
				return
			end

			if not survivor:CanBeSeen() then
				continue
			end

			local pos = (survivor:GetPos() + Vector(0, 0, 60)):ToScreen()
			if pos.visible then
				surface.SetMaterial(surveyNoticeIcon)
				surface.DrawTexturedRect(pos.x - ScrW() / 32, pos.y - ScrW() / 32, ScrW() / 16, ScrW() / 16)
			end
		end
	end)
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Watcher") == true then
			local Overlay = Material("slashco/ui/overlays/watcher_see")

			Overlay:SetFloat("$alpha", 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end

		if LocalPlayer():GetNWBool("WatcherSurveyed") == true then
			if LocalPlayer().al_watch == nil then
				LocalPlayer().al_watch = 0
			end
			if LocalPlayer().al_watch < 100 then
				LocalPlayer().al_watch = LocalPlayer().al_watch + (FrameTime() * 100)
			end

			local Overlay = Material("slashco/ui/overlays/watcher_see")

			Overlay:SetFloat("$alpha", 1 - (LocalPlayer().al_watch / 100))

			surface.SetDrawColor(255, 255, 255, 60)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().al_watch = nil
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Watcher")