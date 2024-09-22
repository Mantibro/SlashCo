local SLASHER = {}

SLASHER.Name = "Amogus"
SLASHER.ID = 4
SLASHER.Class = 1
SLASHER.DangerLevel = 1
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/amogus/amogus.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 8
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 296
SLASHER.Perception = 4.5
SLASHER.Eyesight = 6
SLASHER.KillDistance = 130
SLASHER.ChaseRange = 600
SLASHER.ChaseRadius = 0.90
SLASHER.ChaseDuration = 15.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/amogus_chase.wav"
SLASHER.KillSound = "slashco/slasher/amogus_kill.mp3"
SLASHER.Description = "Amogus_desc"
SLASHER.ProTip = "Amogus_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★☆☆"

SLASHER.PickUpAttempt = function(ply)
	return ply:GetNWBool("AmogusSurvivorDisguise")
end

SLASHER.OnTickBehaviour = function(slasher)
	if IsValid(ents.GetByIndex(slasher.SlasherValue3)) then
		ents.GetByIndex(slasher.SlasherValue3):SetAngles(Angle(0, slasher:EyeAngles()[2], 0))
	end

	if slasher.SlasherValue2 > 0 then
		slasher.SlasherValue2 = slasher.SlasherValue2 - FrameTime()
		slasher:SetNWBool("CanKill", false)
		slasher:SetNWBool("CanChase", false)
	else
		if not slasher:GetNWBool("AmogusDisguised") and not slasher:GetNWBool("AmogusDisguising") then
			slasher:SetNWBool("CanKill", true)
			slasher:SetNWBool("CanChase", true)
			slasher.SlasherValue3 = 0
		else
			slasher:SetNWBool("CanKill", false)
			slasher:SetNWBool("CanChase", false)
		end
	end

	if slasher:GetNWBool("AmogusSurvivorDisguise") then
		for k, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if v:GetPos():Distance(slasher:GetPos()) < 500 then
				slasher.SlasherValue4 = slasher.SlasherValue1 + FrameTime()
				break
			end
		end

		if slasher.SlasherValue1 > 30 then
			slasher.SlasherValue4 = 0
			slasher:EmitSound("slashco/slasher/amogus_speech" .. math.random(1, 7) .. ".mp3")
		end
	else
		slasher.SlasherValue4 = 0
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if not slasher:GetNWBool("AmogusSurvivorDisguise") then
		SlashCo.Jumpscare(slasher, target)
	end

	if not IsValid(target) or not target:IsPlayer() then
		return
	end

	if target:Team() ~= TEAM_SURVIVOR then
		return
	end

	if slasher.KillDelayTick > 0 then
		return
	end

	if slasher:GetVelocity():Length() > 1 then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) >= SlashCoSlashers.Tyler.KillDistance or target:GetNWBool("SurvivorBeingJumpscared") then
		return
	end

	target:SetNWBool("SurvivorBeingJumpscared", true)
	target:Freeze(true)

	slasher:EmitSound("slashco/slasher/amogus_stealthkill.mp3", 60)
	slasher:Freeze(true)
	slasher.KillDelayTick = SLASHER.KillDelay

	timer.Simple(1.25, function()
		if IsValid(target) then
			target:SetNWBool("SurvivorBeingJumpscared", false)
			target:Freeze(false)
			if IsValid(slasher) then
				target:TakeDamage(99999, slasher, slasher)
			else
				target:Kill()
			end
		end

		if IsValid(slasher) then
			slasher:Freeze(false)
		end
	end)
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if not slasher:GetNWBool("AmogusDisguising") and slasher.SlasherValue2 < 0.01 and not slasher:GetNWBool("AmogusSurvivorDisguise") and not slasher:GetNWBool("AmogusDisguised") then
		slasher:SetNWBool("AmogusDisguising", true)
		slasher:Freeze(true)

		slasher:EmitSound("slashco/slasher/amogus_transform" .. math.random(1, 2) .. ".mp3")
		slasher.SlasherValue2 = 4

		timer.Simple(2, function()
			slasher:Freeze(false)
			slasher:SetNWBool("AmogusDisguising", false)

			slasher:SetNWBool("AmogusSurvivorDisguise", true)
			slasher:SetNWBool("AmogusDisguised", true)

			slasher:SlasherHudFunc("SetAvatar", "survivor")
			slasher:SlasherHudFunc("SetTitle", "Amogus_survivor_disguised_title")

			slasher:EmitSound("slashco/slasher/amogus_sus.mp3")

			local s = team.GetPlayers(TEAM_SURVIVOR)
			local modelname = "models/slashco/survivor/male_01.mdl"
			if #s > 0 then
				modelname = s[math.random(1, #s)]:GetModel()
			end
			util.PrecacheModel(modelname)
			slasher:SetModel(modelname)

			slasher:SetRunSpeed(300)
			slasher:SetWalkSpeed(200)
		end)
	elseif not slasher:GetNWBool("AmogusDisguising") and slasher.SlasherValue2 < 0.01 and slasher:GetNWBool("AmogusDisguised") then
		slasher:Freeze(true)
		slasher:SetNWBool("AmogusSurvivorDisguise", false)
		slasher:SetNWBool("AmogusFuelDisguise", false)
		slasher:SetNWBool("AmogusDisguised", false)
		slasher:EmitSound("slashco/slasher/amogus_reveal.mp3")
		slasher:SetNWBool("DynamicFlashlight", false)

		slasher:SlasherHudFunc("SetAvatar", "default")
		slasher:SlasherHudFunc("SetTitle", "Amogus")

		util.PrecacheModel("models/slashco/slashers/amogus/amogus.mdl")
		slasher:SetModel("models/slashco/slashers/amogus/amogus.mdl")

		slasher:SetVisible(true)

		slasher:SetRunSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)
		slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)

		slasher.KillDelayTick = 2 - (SO * 1.95)

		if IsValid(ents.GetByIndex(slasher.SlasherValue3)) then
			ents.GetByIndex(slasher.SlasherValue3):Remove()
		end

		timer.Simple(2 - (SO * 1.95), function()
			slasher:Freeze(false)
			slasher.SlasherValue2 = 2.5 - (SO * 2.4)
		end)
	end
end

SLASHER.OnSpecialAbilityFire = function(slasher)
	if not slasher:GetNWBool("AmogusDisguising") and slasher.SlasherValue2 < 0.01 and not slasher:GetNWBool("AmogusFuelDisguise") and not slasher:GetNWBool("AmogusDisguised") then
		slasher:SetNWBool("AmogusDisguising", true)
		slasher:Freeze(true)
		slasher:EmitSound("slashco/slasher/amogus_transform" .. math.random(1, 2) .. ".mp3")

		slasher.SlasherValue2 = 4

		timer.Simple(2, function()
			slasher:Freeze(false)
			slasher:SetNWBool("AmogusDisguising", false)
			slasher:SetNWBool("AmogusFuelDisguise", true)
			slasher:SetNWBool("AmogusDisguised", true)

			slasher:SlasherHudFunc("SetAvatar", "fuel")
			slasher:SlasherHudFunc("SetTitle", "Amogus_gas_disguised_title")

			slasher:EmitSound("slashco/slasher/amogus_sus.mp3")

			slasher:SetVisible(false)

			local g = ents.Create("prop_physics")

			g:SetPos(slasher:GetPos() + Vector(0, 0, 15))
			g:SetAngles(slasher:GetAngles() + Angle(0, 90, 0))
			g:SetModel(SlashCoItems.GasCan.Model)
			g:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			g:Spawn()

			g:FollowBone(slasher, slasher:LookupBone("Hips"))

			local id = g:EntIndex()
			slasher.SlasherValue3 = id

			slasher:SetRunSpeed(200)
			slasher:SetWalkSpeed(200)
		end)
	end
end

SLASHER.Animator = function(ply)
	if ply:GetNWBool("AmogusSurvivorDisguise") then
		return
	end

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		if ply:GetNWBool("AmogusFuelDisguise") then
			return true
		end
		if ply:GetNWBool("AmogusSurvivorDisguise") then
			return false
		end

		ply:EmitSound("slashco/slasher/amogus_step" .. math.random(1, 3) .. ".wav")
		return true
	end

	if CLIENT then
		if ply:GetNWBool("AmogusSurvivorDisguise") then
			return false
		end
		return true
	end
end

hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
	if LocalPlayer():GetNWBool("SurvivorJumpscare_Amogus") == true then
		if LocalPlayer().amog_f == nil then
			LocalPlayer().amog_f = 0
		end
		LocalPlayer().amog_f = LocalPlayer().amog_f + (FrameTime() * 20)
		if LocalPlayer().amog_f > 59 then
			LocalPlayer().amog_f = 50
		end

		local Overlay = Material("slashco/ui/overlays/jumpscare_4")
		Overlay:SetInt("$frame", math.floor(LocalPlayer().amog_f))

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	else
		LocalPlayer().amog_f = nil
	end
end)

local avatarTable = {
	default = Material("slashco/ui/icons/slasher/s_4"),
	survivor = Material("slashco/ui/icons/slasher/s_4_a1"),
	fuel = Material("slashco/ui/icons/slasher/s_4_a2")
}

local disguiseTable = {
	["disguise as survivor"] = Material("slashco/ui/icons/slasher/s_4_a1"),
	["reveal yourself"] = Material("slashco/ui/icons/slasher/s_4")
}

local killTable = {
	["kill survivor"] = Material("slashco/ui/icons/slasher/s_0"),
	["d/kill survivor"] = Material("slashco/ui/icons/slasher/kill_disabled"),
	["sneak kill"] = Material("slashco/ui/icons/slasher/s_4_a1"),
	["d/sneak kill"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetTitle("Amogus")
	hud:SetAvatarTable(avatarTable)

	hud:AddControl("R", "disguise as survivor", disguiseTable)
	hud:ChaseAndKill()
	hud:AddControl("F", "disguise as fuel", Material("slashco/ui/icons/slasher/s_4_a2"))
	hud:SetControlIconTable("LMB", killTable)
	hud:TieControlVisible("F", "AmogusDisguised", true)
	hud:TieControlVisible("RMB", "AmogusDisguised", true)
	hud:TieControlVisible("LMB", "AmogusFuelDisguise", true)
	hud:TieControlText("R", "AmogusDisguised", "reveal yourself", "disguise as survivor", true)

	local control = hud:GetControl("LMB")
	control.prevSurvivor = -1
	function control.AlsoThink()
		local survivor = LocalPlayer():GetNWBool("AmogusSurvivorDisguise")
		if survivor ~= control.prevSurvivor then
			if survivor then
				control:SetText("sneak kill")
			else
				control:SetText("kill survivor")
			end

			control.prevSurvivor = survivor
		end

		if survivor and LocalPlayer():GetVelocity():Length() < 1 then
			if not control.prevKill then
				control:SetEnabled(true)
				control:Shake()
				control.prevKill = true
			end
		else
			if control.prevKill then
				control:SetEnabled(false)
				control.prevKill = false
			end
		end
	end
end

SlashCo.RegisterSlasher(SLASHER, "Amogus")