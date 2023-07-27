SlashCoSlasher.Amogus = {}

SlashCoSlasher.Amogus.Name = "Amogus"
SlashCoSlasher.Amogus.ID = 4
SlashCoSlasher.Amogus.Class = 1
SlashCoSlasher.Amogus.DangerLevel = 1
SlashCoSlasher.Amogus.IsSelectable = true
SlashCoSlasher.Amogus.Model = "models/slashco/slashers/amogus/amogus.mdl"
SlashCoSlasher.Amogus.GasCanMod = 0
SlashCoSlasher.Amogus.KillDelay = 8
SlashCoSlasher.Amogus.ProwlSpeed = 150
SlashCoSlasher.Amogus.ChaseSpeed = 296
SlashCoSlasher.Amogus.Perception = 4.5
SlashCoSlasher.Amogus.Eyesight = 6
SlashCoSlasher.Amogus.KillDistance = 130
SlashCoSlasher.Amogus.ChaseRange = 600
SlashCoSlasher.Amogus.ChaseRadius = 0.90
SlashCoSlasher.Amogus.ChaseDuration = 15.0
SlashCoSlasher.Amogus.ChaseCooldown = 3
SlashCoSlasher.Amogus.JumpscareDuration = 2
SlashCoSlasher.Amogus.ChaseMusic = "slashco/slasher/amogus_chase.wav"
SlashCoSlasher.Amogus.KillSound = "slashco/slasher/amogus_kill.mp3"
SlashCoSlasher.Amogus.Description = "The Imposter Slasher who is the master of deception and hiding in plain sight.\n\n-Amogus can assume the form of a Survivor.\n-He can assume the form of a Fuel Can.\n-Amogus is really loud while running."
SlashCoSlasher.Amogus.ProTip = "-This Slasher can disguise itself as a human."
SlashCoSlasher.Amogus.SpeedRating = "★★☆☆☆"
SlashCoSlasher.Amogus.EyeRating = "★★★☆☆"
SlashCoSlasher.Amogus.DiffRating = "★★★☆☆"

SlashCoSlasher.Amogus.OnSpawn = function(slasher)

end

SlashCoSlasher.Amogus.PickUpAttempt = function(ply)
	return false
end

SlashCoSlasher.Amogus.OnTickBehaviour = function(slasher)
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

	slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Amogus.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Amogus.Perception)
end

SlashCoSlasher.Amogus.OnPrimaryFire = function(slasher)
	if not slasher:GetNWBool("AmogusSurvivorDisguise") then
		SlashCo.Jumpscare(slasher)
	end

	if slasher:GetEyeTrace().Entity:IsPlayer() then
		local target = slasher:GetEyeTrace().Entity

		if target:Team() ~= TEAM_SURVIVOR then
			return
		end

		if slasher.KillDelayTick > 0 then
			return
		end

		if slasher:GetVelocity():Length() > 1 then
			return
		end

		if slasher:GetPos():Distance(target:GetPos()) < SlashCoSlasher.Amogus.KillDistance and not target:GetNWBool("SurvivorBeingJumpscared") then
			target:SetNWBool("SurvivorBeingJumpscared", true)

			slasher:EmitSound("slashco/slasher/amogus_stealthkill.mp3", 60)

			target:Freeze(true)
			slasher:Freeze(true)

			slasher.KillDelayTick = SlashCoSlasher.Amogus.KillDelay

			timer.Simple(1.25, function()
				target:SetNWBool("SurvivorBeingJumpscared", false)
				slasher:Freeze(false)
				target:Freeze(false)
				target:Kill()
			end)
		end
	end
end

SlashCoSlasher.Amogus.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Amogus.OnMainAbilityFire = function(slasher)
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
			slasher:SlasherHudFunc("SetTitle", "regular survivor")

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
		slasher:SlasherHudFunc("SetTitle", "amogus")

		util.PrecacheModel("models/slashco/slashers/amogus/amogus.mdl")
		slasher:SetModel("models/slashco/slashers/amogus/amogus.mdl")

		slasher:SetColor(Color(255, 255, 255, 255))
		slasher:DrawShadow(true)
		slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		slasher:SetNoDraw(false)

		slasher:SetRunSpeed(SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed)
		slasher:SetWalkSpeed(SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed)

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

SlashCoSlasher.Amogus.OnSpecialAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

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
			slasher:SlasherHudFunc("SetTitle", "regular fuel can")

			slasher:EmitSound("slashco/slasher/amogus_sus.mp3")

			slasher:SetColor(Color(0, 0, 0, 0))
			slasher:DrawShadow(false)
			slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
			slasher:SetNoDraw(true)

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

SlashCoSlasher.Amogus.Animator = function(ply)
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

SlashCoSlasher.Amogus.Footstep = function(ply)
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

if CLIENT then
	hook.Add("HUDPaint", SlashCoSlasher.Amogus.Name .. "_Jumpscare", function()
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

	SlashCoSlasher.Amogus.InitHud = function(_, hud)
		hud:SetTitle("amogus")
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
		control.prevSurvivor = LocalPlayer():GetNWBool("AmogusSurvivorDisguise")
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

	SlashCoSlasher.Amogus.ClientSideEffect = function()

	end
end