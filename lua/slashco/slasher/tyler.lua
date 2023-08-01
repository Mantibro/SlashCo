local SLASHER = {}

SLASHER.Name = "Tyler"
SLASHER.ID = 7
SLASHER.Class = 2
SLASHER.DangerLevel = 3
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/tyler/tyler.mdl"
SLASHER.GasCanMod = -6
SLASHER.KillDelay = 6
SLASHER.ProwlSpeed = 300
SLASHER.ChaseSpeed = 580
SLASHER.Perception = 0.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 200
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 1
SLASHER.ChaseDuration = 0.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/tyler_kill.mp3"
SLASHER.Description = "Tyler_desc"
SLASHER.ProTip = "Tyler_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★★★★☆"

SLASHER.OnSpawn = function(slasher)
	slasher.SlasherValue1 = 0
	slasher:SetColor(Color(0, 0, 0, 0))
	slasher:DrawShadow(false)
	slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
	slasher:SetNoDraw(true)
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	--local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --State
	local v2 = slasher.SlasherValue2 --Time Spent as Creator or destroyer
	--local v3 = slasher.SlasherValue3 --Times Found
	local v4 = slasher.SlasherValue4 --Destruction power
	local v5 = slasher.SlasherValue5 --Destoyer Blink

	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception

	local ms = SCInfo.Maps[game.GetMap()].SIZE

	if v1 == 0 then
		--Specter

		slasher.TylerSongPickedID = nil
		slasher:SetNWBool("TylerFlash", false)
		slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
		slasher:SetNWBool("TylerTheCreator", false)
		slasher:SetBodygroup(0, 0)
		slasher.SlasherValue2 = 0
		slasher:SetNWBool("CanKill", false)
		slasher:SetImpervious(true)
		final_perception = 6.0
	elseif v1 == 1 then
		--Creator

		slasher:SetImpervious(false)
		slasher:SetNWBool("TylerFlash", false)
		slasher:SetSlowWalkSpeed(1)
		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:Freeze(true)
		slasher:SetNWBool("TylerTheCreator", true)
		slasher:SetBodygroup(0, 0)
		slasher.SlasherValue2 = v2 + FrameTime()
		slasher:SetNWBool("CanKill", false)
		final_perception = 0.0

		if not slasher:GetNWBool("TylerCreating") and slasher.TylerSongPickedID == nil then
			slasher.TylerSongPickedID = math.random(1, 6)

			PlayGlobalSound("slashco/slasher/tyler_song_" .. slasher.TylerSongPickedID .. ".mp3", 98, slasher,
					0.8 - (slasher.SlasherValue3 * 0.12))
		end

		if v2 > 20 + ((ms * 35) - (v4 * 4)) then
			--Time ran out

			local stop_song = slasher.TylerSongPickedID

			slasher.SlasherValue1 = 2
			slasher:StopSound("slashco/slasher/tyler_song_" .. stop_song .. ".mp3")
			timer.Simple(0.1, function()
				slasher:StopSound("slashco/slasher/tyler_song_" .. stop_song .. ".mp3")
			end)
			slasher.TylerSongPickedID = nil
		end

		for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
			--Survivor found tyler

			local surv = team.GetPlayers(TEAM_SURVIVOR)[i]

			local stop_song = slasher.TylerSongPickedID

			if not slasher:GetNWBool("TylerCreating") and surv:GetPos():Distance(slasher:GetPos()) < 400 and surv:GetEyeTrace().Entity == slasher then
				slasher:SetNWBool("TylerCreating", true)
				slasher.SlasherValue2 = 0
				slasher:StopSound("slashco/slasher/tyler_song_" .. stop_song .. ".mp3")
				timer.Simple(0.1, function()
					slasher:StopSound("slashco/slasher/tyler_song_" .. stop_song .. ".mp3")
				end)
				slasher.TylerSongPickedID = nil
			end
		end

		if slasher:GetNWBool("TylerCreating") and slasher.SlasherValue5 ~= 1.8 then
			slasher.SlasherValue5 = 1.8
			slasher.SlasherValue2 = 0

			slasher:EmitSound("slashco/slasher/tyler_create.mp3")

			timer.Simple(3, function()
				if not IsValid(slasher) then
					return
				end

				SlashCo.CreateGasCan(slasher:GetPos() + (slasher:GetForward() * 60) + Vector(0, 0, 18), Angle(0, 0, 0))
			end)

			timer.Simple(4, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("TylerCreating", false)
				slasher.SlasherValue1 = 0
				slasher.SlasherValue2 = 0
				slasher.SlasherValue3 = slasher.SlasherValue3 + 1
				slasher.SlasherValue5 = 0
				slasher:Freeze(false)
				slasher:SetColor(Color(0, 0, 0, 0))
				slasher:DrawShadow(false)
				slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
				slasher:SetNoDraw(true)
			end)
		end

		slasher.tyler_destroyer_entrance_antispam = nil
	elseif v1 == 2 then
		--Pre-Destroyer

		slasher.TylerSongPickedID = nil
		slasher:Freeze(true)

		if slasher.tyler_destroyer_entrance_antispam == nil then
			PlayGlobalSound("slashco/slasher/tyler_alarm.wav", 110, slasher, 1)
			if CLIENT then
				slasher.TylerSong:Stop()
				slasher.TylerSong = nil
			end

			slasher.tyler_destroyer_entrance_antispam = 0
		end

		local decay = v4 / 2

		if v4 > 14 then
			decay = 7
		end

		if slasher.tyler_destroyer_entrance_antispam < (12 - decay) then
			slasher.tyler_destroyer_entrance_antispam = slasher.tyler_destroyer_entrance_antispam + FrameTime()
		else
			slasher:StopSound("slashco/slasher/tyler_alarm.wav")
			timer.Simple(0.1, function()
				slasher:StopSound("slashco/slasher/tyler_alarm.wav")
			end) --idk man only works if i stop it twice shut up

			PlayGlobalSound("slashco/slasher/tyler_destroyer_theme.wav", 98, slasher, 1)
			PlayGlobalSound("slashco/slasher/tyler_destroyer_whisper.wav", 101, slasher, 0.75)

			slasher:Freeze(false)
			slasher.SlasherValue1 = 3

			for i = 1, #player.GetAll() do
				local ply = player.GetAll()[i]
				ply:SetNWBool("DisplayTylerTheDestroyerEffects", true)
			end
		end

		slasher:SetSlowWalkSpeed(1)
		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetNWBool("TylerTheCreator", false)
		slasher:SetBodygroup(0, 1)
		slasher.SlasherValue2 = 0
		slasher:SetNWBool("CanKill", false)
		final_perception = 0.0
	elseif v1 == 3 then
		--Destroyer

		slasher:SetSlowWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
		slasher:SetRunSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
		slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
		slasher:SetNWBool("TylerTheCreator", false)
		slasher:SetBodygroup(0, 1)
		slasher.SlasherValue2 = v2 + FrameTime()
		slasher:SetNWBool("CanKill", true)
		final_perception = 2.0

		if v2 > ((ms * 15) + 60 + (v4 * 10)) then
			slasher.SlasherValue1 = 0

			slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
			slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav")
			timer.Simple(0.1, function()
				slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
				slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav")
			end)

			slasher:SetColor(Color(0, 0, 0, 0))
			slasher:DrawShadow(false)
			slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
			slasher:SetNoDraw(true)
			slasher:SetNWBool("TylerFlash", false)

			slasher.SlasherValue4 = slasher.SlasherValue4 - 1

			for i = 1, #player.GetAll() do
				local ply = player.GetAll()[i]
				ply:SetNWBool("DisplayTylerTheDestroyerEffects", false)
			end
		end
	end

	if v1 > 1 then
		slasher.SlasherValue5 = v5 + FrameTime()

		if v5 > 0.85 then
			slasher.SlasherValue5 = 0
		end

		if v5 <= 0.5 then
			slasher:SetColor(Color(0, 0, 0, 0))
			slasher:DrawShadow(false)
			slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
			slasher:SetNoDraw(true)
			slasher:SetNWBool("TylerFlash", false)
		else
			slasher:SetColor(Color(255, 255, 255, 255))
			slasher:DrawShadow(true)
			slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
			slasher:SetNoDraw(false)
			slasher:SetNWBool("TylerFlash", true)
		end
	end

	if slasher:GetNWInt("TylerState") ~= v1 then
		slasher:SetNWInt("TylerState", v1)
	end

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if slasher.SlasherValue1 ~= 3 then
		return
	end

	if slasher:GetNWBool("CanKill") == false then
		return
	end

	if slasher.KillDelayTick > 0 then
		return
	end

	if not IsValid(target) then
		return
	end

	local class = target:GetClass()
	if (not target:IsPlayer() and target.PingType ~= "ITEM") or class == "sc_beacon" or class == "sc_battery" then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) >= SLASHER.KillDistance or target:GetNWBool("SurvivorBeingJumpscared") then
		return
	end

	target:SetNWBool("SurvivorBeingJumpscared", true)
	target:SetNWBool("SurvivorJumpscare_Tyler", true)

	slasher:EmitSound(SlashCoSlashers[slasher:GetNWString("Slasher")].KillSound)

	if target:IsPlayer() then
		target:Freeze(true)
	end
	slasher:Freeze(true)

	slasher.KillDelayTick = SLASHER.KillDelay
	slasher.SlasherValue2 = 0

	timer.Simple(SlashCoSlashers[slasher:GetNWString("Slasher")].JumpscareDuration, function()
		for i = 1, #player.GetAll() do
			local ply = player.GetAll()[i]
			ply:SetNWBool("DisplayTylerTheDestroyerEffects", false)
		end

		if IsValid(slasher) then
			slasher:Freeze(false)
			slasher.SlasherValue4 = slasher.SlasherValue4 + 1
			slasher.SlasherValue1 = 0

			slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
			slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav")
			timer.Simple(0.1, function()
				if not IsValid(slasher) then
					return
				end

				slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
				slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav")
			end)

			slasher:SetColor(Color(0, 0, 0, 0))
			slasher:DrawShadow(false)
			slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
			slasher:SetNoDraw(true)
			slasher:SetNWBool("TylerFlash", false)
		end

		if IsValid(target) then
			target:SetNWBool("SurvivorBeingJumpscared", false)
			target:SetNWBool("SurvivorJumpscare_Tyler", false)

			if target:IsPlayer() then
				target:Freeze(false)
				target:Kill()
			end

			timer.Simple(FrameTime(), function()
				if not IsValid(target) then
					print("how")
					return
				end

				local corpse
				if target:IsPlayer() then
					corpse = target.DeadBody
				else
					corpse = target
					if IsValid(slasher) then
						slasher.SlasherValue4 = slasher.SlasherValue4 + 0.5
					end
				end

				if not IsValid(corpse) then
					return
				end

				local dissolver = ents.Create("env_entity_dissolver")
				timer.Simple(2, function()
					if IsValid(dissolver) then
						dissolver:Remove() -- backup edict save on error
					end
				end)

				dissolver.Target = "dissolve" .. corpse:EntIndex()
				dissolver:SetKeyValue("dissolvetype", 0)
				dissolver:SetKeyValue("magnitude", 1)
				dissolver:SetPos(corpse:GetPos())
				dissolver:SetPhysicsAttacker(slasher)
				dissolver:Spawn()

				corpse:SetName(dissolver.Target)
				dissolver:Fire("Dissolve", dissolver.Target, 0)
				dissolver:Fire("Kill", "", 1)
			end)
		end
	end)
end

SLASHER.OnMainAbilityFire = function(slasher)
	if slasher.SlasherValue1 ~= 0 then
		return
	end

	slasher.SlasherValue1 = 1
	slasher:SetColor(Color(255, 255, 255, 255))
	slasher:DrawShadow(true)
	slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
	slasher:SetNoDraw(false)
end

SLASHER.Animator = function(ply)
	local tyler_creator = ply:GetNWBool("TylerTheCreator")
	local tyler_creating = ply:GetNWBool("TylerCreating")

	if tyler_creator then
		if not tyler_creating then
			ply.CalcSeqOverride = ply:LookupSequence("creator idle")

			ply.anim_antispam = false
		else
			ply.CalcSeqOverride = ply:LookupSequence("create")
			if ply.anim_antispam == nil or ply.anim_antispam == false then
				ply:SetCycle(0)
				ply.anim_antispam = true
			end
		end
	else
		if ply:GetVelocity():LengthSqr() > 5 then
			ply.CalcSeqOverride = ply:LookupSequence("destroyer walk")
		else
			ply.CalcSeqOverride = ply:LookupSequence("destroyer activated")
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function()
	return true
end

local avatarTable = {
	creator = Material("slashco/ui/icons/slasher/s_7"),
	destroyer = Material("slashco/ui/icons/slasher/s_7_s1")
}

local manifestTable = {
	default = Material("slashco/ui/icons/slasher/s_7_s1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Tyler_creator")

	hud:AddControl("R", "manifest", manifestTable)

	hud:AddControl("LMB", "destroy", manifestTable)
	hud:TieControlVisible("LMB", "CanKill")

	hud.prevState = -1
	hud.destroyEnabled = true
	function hud.AlsoThink()
		local state = LocalPlayer():GetNWInt("TylerState")
		if state ~= hud.prevState then
			if state == 0 then
				hud:SetControlVisible("R", true)
				hud:SetControlEnabled("R", true)
				hud:SetControlText("R", "manifest")
			elseif state == 1 then
				hud:SetControlVisible("R", true)
				hud:SetControlEnabled("R", false)
				hud:SetControlText("R", "(hiding)")
				hud:ShakeControl("R")
			else
				hud:SetControlVisible("R", false)
			end

			if state <= 1 then
				hud:SetTitle("Tyler_creator")
				hud:SetAvatar("creator")
			else
				hud:SetTitle("Tyler_destroyer")
				hud:SetAvatar("destroyer")
			end

			if state == 3 then
				hud:SetCrosshairEnabled(true)
			else
				hud:SetCrosshairAlpha(0)
				timer.Simple(1, function()
					hud:SetCrosshairEnabled(false)
				end)
			end

			hud.prevState = state
		end

		local target = LocalPlayer():GetEyeTrace().Entity
		local class = target:GetClass()
		if IsValid(target) and target:IsPlayer() or (target.PingType == "ITEM" and class ~= "sc_beacon")
				and class ~= "sc_battery" and not target:GetNWBool("SurvivorBeingJumpscared") and
				LocalPlayer():GetPos():Distance(target:GetPos()) < SLASHER.KillDistance then

			if not hud.destroyEnabled then
				hud:SetControlEnabled("LMB", true)
				hud:ShakeControl("LMB")
				hud:SetCrosshairSpin(50)
				hud:SetCrosshairTighten(4)
				hud:SetCrosshairProngs(5)
				hud:SetCrosshairAlpha(255)
				hud.destroyEnabled = true
			end
		else
			if hud.destroyEnabled then
				hud:SetControlEnabled("LMB", false)
				hud:ShakeControl("LMB")
				hud:SetCrosshairSpin(0)
				hud:SetCrosshairTighten(0)
				hud:SetCrosshairProngs(3)
				hud:SetCrosshairAlpha(0)
				hud.destroyEnabled = nil
			end
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Tyler") == true then
			if LocalPlayer().tyl_f == nil then
				LocalPlayer().tyl_f = 0
			end
			LocalPlayer().tyl_f = LocalPlayer().tyl_f + (FrameTime() * 20)
			if LocalPlayer().tyl_f > 39 then
				LocalPlayer().tyl_f = 25
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_7")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().tyl_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().tyl_f = nil
		end

		if LocalPlayer():GetNWBool("DisplayTylerTheDestroyerEffects") == true then
			local Overlay = Material("slashco/ui/overlays/tyler_static")
			local DestroyerFace = Material("slashco/ui/overlays/tyler_destroyer_face")

			Overlay:SetFloat("$alpha", math.Rand(0.2, 0.23))

			DestroyerFace:SetFloat("$alpha", math.Rand(0, 0.1))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(DestroyerFace)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Tyler")