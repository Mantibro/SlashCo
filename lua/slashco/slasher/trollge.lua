local SLASHER = {}

SLASHER.Name = "Trollge"
SLASHER.ID = 3
SLASHER.Class = 3
SLASHER.DangerLevel = 3
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/trollge/trollge.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 1.5
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 295
SLASHER.Perception = 1.0
SLASHER.Eyesight = 2
SLASHER.KillDistance = 100
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 0.0
SLASHER.ChaseDuration = 0.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/trollge_kill.wav"
SLASHER.Description = "Trollge_desc"
SLASHER.ProTip = "Trollge_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★★★"

SLASHER.OnSpawn = function(slasher)
	PlayGlobalSound("slashco/slasher/trollge_breathing.wav", 50, slasher)
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	local v1 = slasher.SlasherValue1 --Stage
	local v2 = math.Clamp(slasher.SlasherValue2, 0, 2) --Claw cooldown
	slasher.SlasherValue2 = v2
	local v3 = slasher.SlasherValue3 --blood
	local v4 = slasher.SlasherValue4 --dashing

	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception

	if v2 > 0 then
		slasher.SlasherValue2 = v2 - FrameTime()
	end

	if v1 == 0 then
		slasher:SetNWBool("TrollgeStage1", false)
		slasher:SetNWBool("TrollgeStage2", false)
	end
	if v1 == 1 then
		slasher:SetNWBool("TrollgeStage1", true)
		slasher:SetNWBool("TrollgeStage2", false)
	end
	if v1 == 2 then
		slasher:SetNWBool("TrollgeStage1", false)
		slasher:SetNWBool("TrollgeStage2", true)
	end

	if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage1") and SlashCo.CurRound.GameProgress > 4 and v1 < 1 then
		slasher:SetNWBool("TrollgeTransition", true)
		slasher:Freeze(true)
		slasher:StopSound("slashco/slasher/trollge_breathing.wav")
		PlayGlobalSound("slashco/slasher/trollge_transition.mp3", 125, slasher)

		for p = 1, #player.GetAll() do
			local ply = player.GetAll()[p]
			ply:SetNWBool("DisplayTrollgeTransition", true)
		end

		timer.Simple(7, function()
			--transit
			slasher:StopSound("slashco/slasher/trollge_breathing.wav")
			slasher.SlasherValue1 = 1
			slasher:SetNWBool("TrollgeTransition", false)
			slasher:Freeze(false)
			PlayGlobalSound("slashco/slasher/trollge_stage1.wav", 60, slasher)

			slasher:SetRunSpeed(280)
			slasher:SetWalkSpeed(150)
			slasher:SetNWBool("CanKill", true)

			for i = 1, #player.GetAll() do
				local ply = player.GetAll()[i]
				ply:SetNWBool("DisplayTrollgeTransition", false)
			end
		end)
	end

	if v3 > 8 then
		slasher.SlasherValue3 = 8
	end

	if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage2") and SlashCo.CurRound.GameProgress > (10 - (v3 / 2)) and v1 == 1 then
		slasher:SetNWBool("TrollgeTransition", true)
		slasher:Freeze(true)
		slasher:StopSound("slashco/slasher/trollge_stage1.wav")
		PlayGlobalSound("slashco/slasher/trollge_transition.mp3", 125, slasher)

		for i = 1, #player.GetAll() do
			local ply = player.GetAll()[i]
			ply:SetNWBool("DisplayTrollgeTransition", true)
		end

		timer.Simple(7, function()
			if not IsValid(slasher) then
				return
			end

			--transit
			slasher:StopSound("slashco/slasher/trollge_stage1.wav")
			slasher.SlasherValue1 = 2
			slasher:SetNWBool("TrollgeTransition", false)
			slasher:Freeze(false)
			PlayGlobalSound("slashco/slasher/trollge_stage6.wav", 60, slasher)

			slasher:SetRunSpeed(450)
			slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
			final_eyesight = 10

			for i = 1, #player.GetAll() do
				local ply = player.GetAll()[i]
				ply:SetNWBool("DisplayTrollgeTransition", false)
			end
		end)
	end

	if v1 == 1 then
		final_eyesight = 10 - (slasher:GetVelocity():Length() / 35)
		final_perception = 5 - (slasher:GetVelocity():Length() / 60)
	end

	if slasher:GetNWInt("TrollgeStage") ~= v1 then
		slasher:SetNWInt("TrollgeStage", v1)
	end

	local function stopDash()
		if not slasher:GetNWBool("TrollgeDashFinish") then
			slasher:StopSound("slashco/slasher/trollge_screech.mp3")
			timer.Simple(0.25, function()
				if not IsValid(slasher) then
					return
				end

				slasher:StopSound("slashco/slasher/trollge_screech.mp3")
			end)

			slasher:EmitSound("slashco/slasher/trollge_exhaust.mp3")

			slasher.SlasherValue4 = 0
			slasher:SetNWBool("TrollgeDashFinish", true)

			timer.Simple(8, function()
				if not IsValid(slasher) then
					return
				end

				slasher.SlasherValue4 = 0
				slasher:Freeze(false)
				slasher:SetNWBool("TrollgeDashFinish", false)
				slasher:SetNWBool("TrollgeDashing", false)
				slasher.SlasherValue2 = 1.99
			end)
		end
	end

	if v1 == 0 and slasher:GetNWBool("TrollgeDashing") then
		local target = nil

		if not slasher:GetNWBool("TrollgeDashFinish") then
			target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 30)),
					Vector(-15, -15, -60), Vector(15, 15, 60), 50, DMG_SLASH, 5, false)
			SlashCo.BustDoor(slasher, target, 25000)
			slasher:SetVelocity(slasher:GetForward() * 100)

			if v4 == 0 then
				timer.Simple(6, stopDash)
			end

			slasher.SlasherValue4 = v4 + 1

			if slasher.SlasherValue4 > 50 then
				if slasher:GetVelocity():Length() < 450 then
					stopDash()
				end

				if target:IsValid() and target:IsPlayer() then
					stopDash()

					if target:Team() ~= TEAM_SURVIVOR then
						return
					end

					local vPoint = target:GetPos() + Vector(0, 0, 50)
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					target:EmitSound("slashco/slasher/trollge_hit.wav")

					slasher.SlasherValue3 = slasher.SlasherValue3 + 1 + SlashCo.CurRound.OfferingData.SO
					slasher:SetNWInt("TrollgeBlood", slasher.SlasherValue3)
				end
			end
		end
	end

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if slasher.SlasherValue1 ~= 0 then
		SlashCo.Jumpscare(slasher, target)
		return
	end

	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher.SlasherValue2 < 0.01 and not slasher:GetNWBool("TrollgeTransition") then
		slasher:SetNWBool("TrollgeSlashing", false)
		timer.Remove("TrollgeSlashDecay")

		timer.Simple(0.3, function()
			if not IsValid(slasher) then
				return
			end

			slasher:EmitSound("slashco/slasher/trollge_swing.wav")

			if SERVER then
				local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 0)),
						Vector(-30, -30, -60), Vector(30, 30, 60), 10, DMG_SLASH, 5, false)

				if target:IsPlayer() then
					if target:Team() ~= TEAM_SURVIVOR then
						return
					end

					local vPoint = target:GetPos() + Vector(0, 0, 50)
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					target:EmitSound("slashco/slasher/trollge_hit.wav")

					slasher.SlasherValue3 = slasher.SlasherValue3 + 1 + SO
					slasher:SetNWInt("TrollgeBlood", slasher.SlasherValue3)
				end
			end
		end)

		timer.Simple(0.1, function()
			if not IsValid(slasher) then
				return
			end

			slasher:SetNWBool("TrollgeSlashing", true)

			timer.Create("TrollgeSlashDecay", 0.6, 1, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("TrollgeSlashing", false)
			end)

			slasher.SlasherValue2 = slasher.SlasherValue2 + 0.5
		end)
	end
end

SLASHER.OnMainAbilityFire = function(slasher)
	if slasher.SlasherValue1 == 0 and not slasher:GetNWBool("TrollgeDashing") and slasher.SlasherValue2 == 0 then
		slasher:SetNWBool("TrollgeDashing", true)
		PlayGlobalSound("slashco/slasher/trollge_screech.mp3", 125, slasher)
		slasher:Freeze(true)
		slasher.SlasherValue2 = 3
		slasher.SlasherValue4 = 0
		slasher:SetVelocity(slasher:GetForward() * 1000)
	end
end

SLASHER.Animator = function(ply)
	local trollge_stage1 = ply:GetNWBool("TrollgeStage1")
	local trollge_stage2 = ply:GetNWBool("TrollgeStage2")
	local trollge_slashing = ply:GetNWBool("TrollgeSlashing")

	if not trollge_slashing then
		ply.anim_antispam = false
	end

	if not trollge_stage1 and not trollge_stage2 then
		if ply:IsOnGround() then
			if not trollge_slashing then
				ply.CalcIdeal = ACT_HL2MP_WALK
				ply.CalcSeqOverride = ply:LookupSequence("walk")
			else
				ply.CalcSeqOverride = ply:LookupSequence("walk")

				if ply.anim_antispam == nil or ply.anim_antispam == false then
					ply:AddVCDSequenceToGestureSlot(1, 2, 0, true)
					ply.anim_antispam = true
				end
			end
			--else
			--ply.CalcSeqOverride = ply:LookupSequence("float")
		end
	elseif trollge_stage2 then
		ply.CalcSeqOverride = ply:LookupSequence("fly")
	else
		ply.CalcSeqOverride = ply:LookupSequence("glide")
	end

	if ply:GetNWBool("TrollgeDashing") and not ply:GetNWBool("TrollgeDashFinish") then
		ply.CalcSeqOverride = ply:LookupSequence("dash")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.CanSeeFlashlights = function(ply)
	return ply:GetNWBool("TrollgeStage2")
end

SLASHER.Footstep = function()
	return true
end

local avatarTable = {
	default = Material("slashco/ui/icons/slasher/s_3"),
	stage1 = Material("slashco/ui/icons/slasher/s_3_s1"),
	stage2 = Material("slashco/ui/icons/slasher/s_3_s2")
}

local killTable = {
	default = Material("slashco/ui/icons/slasher/s_0"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled"),
	claw = Material("slashco/ui/icons/slasher/s_3_a1")
}

local dashTable = {
	default = Material("slashco/ui/icons/slasher/s_3"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled"),
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Trollge")

	hud:AddControl("R", "dash", dashTable)
	hud:AddControl("LMB", "claw", killTable)
	hud:TieControl("R", "TrollgeDashing", true, true, false)

	hud:AddMeter("blood", 8, "", nil, true)
	hud:TieMeterInt("blood", "TrollgeBlood")

	hud.prevStage = -1
	function hud.AlsoThink()
		local stage = LocalPlayer():GetNWInt("TrollgeStage")
		if stage ~= hud.prevStage then
			if stage == 0 then
				hud:SetControlVisible("R", true)
				hud:SetControlText("LMB", "claw")
				hud:SetMeterVisible("blood", true)
				hud:SetAvatar("default")
			else
				hud:SetControlVisible("R", false)
				hud:SetMeterVisible("blood", false)
				hud:SetControlText("LMB", "kill survivor")
				hud:SetAvatar(stage == 1 and "stage1" or "stage2")
			end

			hud.prevStage = stage
		end
	end
end

SLASHER.ClientSideEffect = function()
	for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if not ply:CanBeSeen() then
			continue
		end

		if not LocalPlayer():GetNWBool("TrollgeStage2") then
			local l_ang = math.abs(ply:EyeAngles()[1]) + math.abs(ply:EyeAngles()[2]) + math.abs(ply:EyeAngles()[3])

			if ply.MonitorLook == nil then
				ply.MonitorLook = 0
			end

			ply.LookSpeed = math.max(math.abs(ply.MonitorLook - l_ang) * 10, 50) - 50
			ply.MonitorLook = l_ang

			ply:SetMaterial("lights/white")
			ply:SetColor(Color(255, 255, 255, (ply.LookSpeed + ply:GetVelocity():Length()) * 3))
			ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
		else
			ply:SetMaterial("lights/white")
			ply:SetColor(color_white)
			ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Trollge") == true then
			if LocalPlayer().troll_f == nil then
				LocalPlayer().troll_f = 0
			end
			LocalPlayer().troll_f = LocalPlayer().troll_f + (FrameTime() * 30)
			if LocalPlayer().troll_f > 86 then
				return
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_3")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().troll_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().troll_f = nil
		end

		if LocalPlayer():GetNWBool("DisplayTrollgeTransition") == true then
			local Overlay = Material("slashco/ui/overlays/trollge_overlays")
			Overlay:SetInt("$frame", 0)

			surface.SetDrawColor(255, 255, 255, 60)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Trollge")