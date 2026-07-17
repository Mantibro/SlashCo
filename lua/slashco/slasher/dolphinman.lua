local SLASHER = {}

SLASHER.Name = "Dolphinman"
SLASHER.Aliases = {
	"Dolfin",
}
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/dolphinman/dolphinman.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 0.5
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 315
SLASHER.Perception = 1.0
SLASHER.Eyesight = 2
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 0.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/dolfin/dolfin_kill.mp3"
SLASHER.Description = "Dolphinman_desc"
SLASHER.ProTip = "Dolphinman_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★☆"
SLASHER.CannotBeSpectated = true
SLASHER.AlertDistance = 400 -- Make dolphinman able to detect survivors in a range and start chase by itself if wanted.
-- Balancement Vars
SLASHER.HuntPowerKill = 15 -- Used to give huntpower per kill based on survivor amount
SLASHER.HuntPowerDiv = 1 -- Used to divide FrameTime, raising it will make his hunt last longer.
SLASHER.HuntPowerGainDiv = 2 -- Used to divide FrameTime, raising it will make him gain hunt power SLOWER

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	-- math.max so it cannot go below 0.5.
	SLASHER.HuntPowerKill = math.max(15 + SO + (2 * additionalSurvivors), 5)
	SLASHER.HuntPowerDiv = math.max(1 + SO + (0.1 * additionalSurvivors), 0.5)
	SLASHER.HuntPowerGainDiv = math.max(2 - (0.5 * SO) - (0.02 * additionalSurvivors), 0.5)
	SLASHER.ChaseDuration = 10.0 + (1 * additionalSurvivors)

	if additionalSurvivors > 0 then
		SLASHER.AlertDistance = 400 + (5 * additionalSurvivors)
		SLASHER.Perception = 1.0 + (0.1 * additionalSurvivors)
		SLASHER.ProwlSpeed = 150 + (3 * additionalSurvivors)
		SLASHER.ChaseSpeed = 315 + (0.5 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	slasher.Jump = slasher:GetJumpPower()
	slasher:SetNWBool("DolphinCanActivate", false)

	slasher.HuntPower = 0
	slasher.dolfin_final_antispam = nil
end

local function PlayCallSound(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/dolfin/dolfin_call.mp3",
		identifier = "DolfinCall",
		minDistance = 700 * SlashCo.MapSize,
		maxDistance = 1240 * SlashCo.MapSize,
		looping = true,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/dolfin/dolfin_call_far.mp3",
		identifier = "DolfinCallFar",
		minDistance = 1250 * SlashCo.MapSize,
		maxDistance = 2250 * SlashCo.MapSize,
		looping = true,
		entity = slasher,
		volume = 0.8,
		fadeIn = 0,
	})
end

local function PlayCallSoundFinal(slasher)
	if slasher.dolfin_final_antispam == nil then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/dolfin/dolfin_call.mp3",
			identifier = "DolfinCall",
			minDistance = 700 * SlashCo.MapSize,
			maxDistance = 1240 * SlashCo.MapSize,
			looping = true,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/dolfin/dolfin_call_far.mp3",
			identifier = "DolfinCallFar",
			minDistance = 1250 * SlashCo.MapSize,
			maxDistance = 2250 * SlashCo.MapSize,
			looping = true,
			entity = slasher,
			volume = 0.8,
			fadeIn = 0,
		})

		slasher.dolfin_final_antispam = 0
	end

	if slasher.dolfin_final_antispam then
		slasher.dolfin_final_antispam = slasher.dolfin_final_antispam + FrameTime()
	end
end

local function DolphinHunt(slasher)
	slasher:SetNWBool("DolphinFound", true)
	PlayCallSound(slasher)

	timer.Simple(10, function()
		slasher:SetNWBool("DolphinFound", false)
		slasher:SetNWBool("DolphinInHiding", false)
		slasher:SetNWBool("DolphinHunting", true)
	end)
end

function SLASHER.OnTickBehaviour(slasher)
	local HuntPower = slasher.HuntPower or 0 --Hunt power
	local hunt_boost = 0

	if not slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") then
		if math.random(1, 1500) == 1 then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/dolfin/dolfin_click" .. math.random(1, 2) .. ".ogg",
				identifier = "DolfinClick",
				minDistance = 350,
				maxDistance = 800,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})
		end
	end

	if SlashCo.CurRound.EscapeHelicopterSummoned then
		slasher:SetNWBool("DolphinFound", false)
		slasher:SetNWBool("DolphinInHiding", false)
		slasher:SetNWBool("DolphinHunting", true)
		slasher:SetNWBool("DolphinFinal", true)
		slasher:SetNWBool("CanKill", true)

		PlayCallSoundFinal(slasher)
	end

	if slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") then
		slasher:SetJumpPower(0)
		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetSlowWalkSpeed(1)

		--get hunt yes.....
		if HuntPower < 100 then
			slasher.HuntPower = HuntPower + (FrameTime() / SLASHER.HuntPowerGainDiv)
		end

		--Survivore finderore

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:CanBeSeen() then
				continue
			end

			if survivor:GetPos():Distance(slasher:GetPos()) > 400 then
				continue
			end

			local tr = util.TraceLine({
				start = slasher:EyePos(),
				endpos = survivor:WorldSpaceCenter(),
				filter = slasher
			})

			if tr.Entity ~= survivor then
				continue
			end

			DolphinHunt(slasher)
		end

		for _, alert_surv in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			local alert_area = SLASHER.AlertDistance + ((2 * HuntPower) + 100)

			if alert_surv:GetPos():Distance(slasher:GetPos()) > alert_area then
				alert_surv:SetNWBool("SurvivorAlert", false)
				--slasher:SetNWBool("DolphinCanActivate", false)
				continue
			end

			alert_surv:SetNWBool("SurvivorAlert", true)
			slasher:SetNWBool("DolphinCanActivate", true)
		end

		if slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", false)
		end
	elseif not slasher:GetNWBool("DolphinInHiding") then
		if not slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", true)
		end

		if slasher:GetNWBool("DolphinCanActivate") then
			slasher:SetNWBool("DolphinCanActivate", false)
		end

		for _, surv in player.Iterator() do
			if surv:Team() == TEAM_SURVIVOR then
				if surv:GetNWBool("SurvivorAlert") then
					surv:SetNWBool("SurvivorAlert", false)
				end
			end
		end

		slasher:SetJumpPower(slasher.Jump)

		--urgh i can move yes lmao

		if not slasher:GetNWBool("DolphinHunting") then
			--auggh im slow :((

			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		else
			--you're fucking dead

			slasher:SetRunSpeed(SLASHER.ChaseSpeed)
			slasher:SetWalkSpeed(SLASHER.ChaseSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed)

			hunt_boost = 1

			--oh fuck i'm losing my hunt!!
			if not SlashCo.CurRound.EscapeHelicopterSummoned then
				slasher.HuntPower = HuntPower - (FrameTime() / SLASHER.HuntPowerDiv)
			end

			--damn shit
			if HuntPower <= 0 then
				slasher:SetNWBool("DolphinHunting", false)
				SlashCo.AudioSystem.StopSound("DolfinCall", 0.5, slasher)
				SlashCo.AudioSystem.StopSound("DolfinCallFar", 0.5, slasher)
			end
		end
	end

	if slasher:GetNWInt("DolphinHunt") ~= math.floor(HuntPower) then
		slasher:SetNWInt("DolphinHunt", math.floor(HuntPower))
	end

	slasher:SetEyeSight(SLASHER.Eyesight + (hunt_boost * 5))
	slasher:SetPerception(SLASHER.Perception * 1.4 ^ (slasher.DolphinKills or 0) + (hunt_boost * 3))
end

function SLASHER.OnHitByPocketSand(slasher, ply)
	-- i'm crying
	slasher:SetNWBool("DolphinFound", false)
	slasher:SetNWBool("DolphinInHiding", false)
	slasher:SetNWBool("DolphinHunting", false)

	slasher:Freeze(true)
	slasher:SetNWBool("DolphinStunned", true)

	SlashCo.AudioSystem.StopSound("DolfinCall", 0.5, slasher)
	SlashCo.AudioSystem.StopSound("DolfinCallFar", 0.5, slasher)

	timer.Simple(9, function()
		if not IsValid(slasher) then return end

		slasher:Freeze(false)
		slasher:SetNWBool("DolphinStunned", false)

		if not slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", true)
		end
	end)
end
SLASHER.OnHitByBeerKeg = SLASHER.OnHitByPocketSand -- RIP your ears xD
SLASHER.OnHitByTeslaCoil = SLASHER.OnHitByPocketSand

function SLASHER.OnBeerKegExplode(slasher, beerkeg)
	if slasher:GetPos():Distance(beerkeg:GetPos()) < 2000 then
		-- GGs - A beerkeg exploded somewhere nearby.
		slasher.HuntPower = 100
		DolphinHunt(slasher)
	end
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("DolphinInHiding")
end

function SLASHER.CanBeSeen(ply)
	if SERVER then return end

	if ply:IsVisible() and not ply:GetNWBool("DolphinInHiding") then
		return true
	end
end

function SLASHER.OnPrimaryFire(slasher, target)
	if SlashCo.Jumpscare(slasher, target) then
		slasher.HuntPower = math.min(100, slasher.HuntPower + SLASHER.HuntPowerKill)
		slasher.DolphinKills = (slasher.DolphinKills or 0) + 1
	end
end

function SLASHER.OnSecondaryFire(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher:GetNWBool("DolphinFinal") then return end

	if not slasher:GetNWBool("DolphinHunting") and not slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") then
		if not SlashCo.IsPositionLegalForSlashers(slasher:GetPos()) then return end

		slasher:SetNWBool("DolphinInHiding", true)
		if SlashCo.CurRound.EscapeHelicopterSummoned then
			slasher.HuntPower = math.min(100, slasher.HuntPower + 20)
		end

		return
	end

	if slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") and slasher.HuntPower >= 5 then
		slasher:SetNWBool("DolphinInHiding", false)

		slasher.HuntPower = slasher.HuntPower - math.floor(slasher.HuntPower / 1.2)
	end
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if slasher:GetNWBool("DolphinFinal") then return end
	if slasher:GetNWBool("DolphinFound") then return end
	if slasher:GetNWBool("DolphinHunting") then return end
	if not slasher:GetNWBool("DolphinCanActivate") then return end

	DolphinHunt(slasher)
end

function SLASHER.Animator(ply)
	local hunt = ply:GetNWBool("DolphinHunting")
	local hide = ply:GetNWBool("DolphinInHiding")
	local found = ply:GetNWBool("DolphinFound")
	local stun = ply:GetNWBool("DolphinStunned")

	if ply:IsOnGround() then
		if not hunt then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("hunt")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	if hide then
		ply.CalcSeqOverride = ply:LookupSequence("hide")
	end

	if found then
		ply.CalcSeqOverride = ply:LookupSequence("found")
	end

	if stun then
		ply.CalcSeqOverride = ply:LookupSequence("stun")
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	else
		ply.anim_antispam = false
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 5)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/dolfin/dolphin_step" .. idx .. ".mp3",
			identifier = "DolphinFootstep" .. idx,
			group = "SlasherFootstep",
			minDistance = 250,
			maxDistance = 400,
			entity = ply,
			volume = 0.8,
			fadeIn = 0,
		})
	end

	return true
end

local mat = Material("lights/white")
local function targetPaint(ply)
	if not IsValid(ply) then return end

	cam.Start3D()
	render.MaterialOverride(mat)
	render.SetColorModulation(1, 0, 0)

	ply:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride("")
	cam.End3D()
end

local hideIcons = {
	["default"] = Material("slashco/ui/icons/slasher/dolphinman"),
	["unhide"] = Material("slashco/ui/icons/slasher/watcher_a1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/dolphinman"))
	hud:SetTitle("Dolphinman")

	hud:AddControl("R", "hide", hideIcons)
	hud:ChaseAndKill(true)
	hud:AddControl("F", "hunt", Material("slashco/ui/icons/slasher/dolphinman"))
	hud:TieControlVisible("LMB", "DolphinInHiding", true, true)
	hud:TieControlVisible("F", "DolphinCanActivate")
	hud:TieControlVisible("R", "DolphinHunting", true, true)
	hud:TieControlText("R", "DolphinInHiding", "unhide", "hide", true)

	hud:AddMeter("hunt")
	hud:TieMeterInt("hunt", "DolphinHunt")

	hud.prevHide = -1
	function hud.AlsoThink()
		local hide
		if GameData.LocalPlayer:GetNWBool("DolphinInHiding") then
			hide = not GameData.LocalPlayer:GetNWBool("DolphinFound") and GameData.LocalPlayer:GetNWInt("DolphinHunt") >= 5
		else
			hide = SlashCo.IsPositionLegalForSlashers(GameData.LocalPlayer:GetPos())
		end

		if hud.prevHide ~= hide then
			hud:SetControlEnabled("R", hide)
			hud.prevHide = hide
		end

		if GameData.LocalPlayer:GetNWBool("DolphinFinal") then
			hud:SetControlVisible("R", false)
			hud:SetControlVisible("F", false)
		end
	end

	hook.Add("SlashCo:DrawHUD", "SlashCo:SlasherHUD", function()
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			hook.Remove("SlashCo:DrawHUD", "SlashCo:SlasherHUD")
			return
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:GetNWBool("SurvivorAlert") then
				continue
			end

			targetPaint(survivor)
		end
	end)
end

if CLIENT then
	hook.Add("SlashCo:DrawHUD", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Dolphinman") == true then
			if GameData.LocalPlayer.dolf_f == nil then
				GameData.LocalPlayer.dolf_f = 0
			end
			GameData.LocalPlayer.dolf_f = GameData.LocalPlayer.dolf_f + (FrameTime() * 20)
			if GameData.LocalPlayer.dolf_f > 29 then
				GameData.LocalPlayer.dolf_f = 28
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_dolphinman")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.dolf_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.dolf_f = nil
		end
	end)
	hook.Add("Tick", "DolphinmanLight", function()
		for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if v == GameData.LocalPlayer then return end

			if v:GetNWBool("DolphinHunting") then
				local tlight = DynamicLight(MAX_EDICT + v:EntIndex())
				if tlight then
					tlight.pos = v:LocalToWorld(Vector(0, 0, 20))
					tlight.r = 249
					tlight.g = 215
					tlight.b = 10
					tlight.brightness = 5
					tlight.Decay = 1000
					tlight.Size = 500
					tlight.DieTime = CurTime() + 1
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Dolphinman")