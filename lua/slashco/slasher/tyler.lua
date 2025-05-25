local SLASHER = {}

SLASHER.Name = "Tyler"
SLASHER.Aliases = {
	"Tyler The Creator",
	"Tyler The Destroyer",
}
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
SLASHER.MinEffectRadius = 500 -- Mimimum distance for HUD effects
SLASHER.MaxEffectRadius = 1500 -- Maximum distance for HUD effects
SLASHER.ChaseDuration = 0.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/igor/tyler_kill.mp3"
SLASHER.Description = "Tyler_desc"
SLASHER.ProTip = "Tyler_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★★★★☆"
SLASHER.CannotBeSpectated = true
SLASHER.AngerIncrease = 5 -- Anger increase of objectives being completed & every time he gives out a fuel can.
SLASHER.AngerPassiveGain = 0
SLASHER.AngerChaseGain = 0
SLASHER.MinChase = 15 -- Number of seconds that are the minimum for a chase
SLASHER.MinTylerTime = 5 -- Number of seconds he has to be at minimum as tyler the creator.
SLASHER.AllowEndlessChase = false -- If true, tyler will enter a endless chase once a round has reached the slow escape mark.
SLASHER.CustomBackgroundMusic = true -- Tyler has his own background music.

function SLASHER.OnSpawn(slasher)
	slasher.SlasherValue1 = 0
	slasher:SetVisible(false)
end

function SLASHER.Precache()
	-- ToDo: Implement sound precaching for the new audiosystem.
	--[[for k=1, 6 do
		SlashCo.PrecacheSound("slashco/slasher/igor/tyler_song_" .. k .. ".mp3")
	end
	
	SlashCo.PrecacheSound("slashco/slasher/igor/tyler_destroyer_theme.mp3")
	SlashCo.PrecacheSound("slashco/slasher/igor/tyler_destroyer_whisper.mp3")
	SlashCo.PrecacheSound("slashco/slasher/igor/tyler_alarm.mp3")]]
	--SlashCo.PrecacheGeneric("slashco/ui/overlays/tyler_destroyer_face.vtf")
end

function SLASHER.HideTime(slasher)
	slasher.TylerTime = math.max((25 + SlashCo.MapSize * 25) - ((SlashCo.GetSlasherAnger(slasher) / 2) / SlashCo.MapSize) - team.NumPlayers(TEAM_SURVIVOR), SLASHER.MinTylerTime)
end

local function EndlessChase()
	return (SLASHER.AllowEndlessChase and SlashCo.IsSlowEscape()) -- When the time for a slow escape is reached, we enter a endless chase
end

function SLASHER.OnTickBehaviour(slasher)
	local v1 = slasher.SlasherValue1 --State
	local v2 = slasher.SlasherValue2 --Time Spent as Creator or destroyer
	local v5 = slasher.SlasherValue5 --Destoyer Blink
	local anger = SlashCo.GetSlasherAnger(slasher)
	local endlessChase = EndlessChase()

	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception

	if (v1 == 0 or v1 == 1) and endlessChase then
		slasher.SlasherValue1 = 2
		SlashCo.AudioSystem.StopSound("TylerSong", 0)
		slasher.TylerSongPickedID = nil
		SlashCo.AddSlasherAnger(slasher, 100) -- Max it out
		anger = SlashCo.GetSlasherAnger(slasher)
	end

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

		slasher.tyler_destroyer_entrance_antispam = nil
	elseif v1 == 1 then
		--Creator

		if SlashCo.BeaconArming then
			slasher.SlasherValue1 = 0
			slasher.SlasherValue2 = 0
			slasher.SlasherValue5 = 0
			slasher:SetVisible(false)
			if slasher.TylerSongPickedID then
				SlashCo.AudioSystem.StopSound("TylerSong", 0)
				slasher.TylerSongPickedID = nil
			end
		end

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
			local rnd = math.random(1, 9)
			slasher.TylerSongPickedID = "slashco/slasher/igor/tyler_song_" .. rnd .. (rnd <= 6 and ".mp3" or ".ogg")
			SlashCo.AudioSystem.PlaySound({
				soundPath = slasher.TylerSongPickedID,
				identifier = "TylerSong",
				soundLevel = 45,
				looping = true,
				entity = slasher,
				volume = math.max(0.8 - (slasher.SlasherValue3 * 0.12), 0.1),
				fadeIn = 1,
			})
			SLASHER.HideTime(slasher)
		end

		if not slasher.TylerTime then
			SLASHER.HideTime(slasher)
		end

		--Time ran out
		if (SlashCo.CurRound.EscapeHelicopterSummoned and v2 > slasher.TylerTime / 2.5) or v2 > slasher.TylerTime then
			slasher.TylerSongPickedID = nil
			slasher.SlasherValue1 = 2
			SlashCo.AudioSystem.StopSound("TylerSong", 0)
		end

		for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
			--Survivor found tyler

			local surv = team.GetPlayers(TEAM_SURVIVOR)[i]

			if not slasher:GetNWBool("TylerCreating") and surv:GetPos():Distance(slasher:GetPos()) < 400 and surv:GetEyeTrace().Entity == slasher then
				slasher:SetNWBool("TylerCreating", true)
				slasher.SlasherValue2 = 0
				SlashCo.AudioSystem.StopSound("TylerSong", 0)
				slasher.TylerSongPickedID = nil
			end
		end

		if slasher:GetNWBool("TylerCreating") and slasher.SlasherValue5 ~= 1.8 then
			slasher.SlasherValue5 = 1.8
			slasher.SlasherValue2 = 0

			slasher:EmitSound("slashco/slasher/igor/tyler_create.mp3")

			timer.Simple(3, function()
				if not IsValid(slasher) then
					return
				end

				SlashCo.CreateGasCan(slasher:GetPos() + (slasher:GetForward() * 60) + Vector(0, 0, 18), Angle(0, 0, 0))
				SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)
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
				slasher:SetVisible(false)
			end)
		end

		slasher.tyler_destroyer_entrance_antispam = nil
	elseif v1 == 2 then
		--Pre-Destroyer

		slasher.TylerSongPickedID = nil
		slasher:Freeze(true)

		if slasher.tyler_destroyer_entrance_antispam == nil then
			SlashCo.AudioSystem.DisableBackgroundMusic()
			SlashCo.AudioSystem.StopSound("TylerSong", 1)
			SlashCo.AudioSystem.PlaySound({
				soundPath = endlessChase and "slashco/slasher/igor/igor_whatsgood_intro.ogg" or "slashco/slasher/igor/tyler_alarm.ogg",
				identifier = "TylerAlarm",
				soundLevel = 10000,
				looping = true,
				entity = slasher,
				volume = 1,
				fadeIn = 1,
			})
			slasher.tyler_destroyer_entrance_antispam = 0
		end

		local decay = anger / 8 -- At longest 12.5 sec
		if slasher.tyler_destroyer_entrance_antispam < (endlessChase and 15.5 or (18 - decay)) then
			slasher.tyler_destroyer_entrance_antispam = slasher.tyler_destroyer_entrance_antispam + FrameTime()
		else
			SlashCo.AudioSystem.StopSound("TylerAlarm", 0.5)

			if anger < 50 then -- switch up songs if his anger is below 50.
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/igor/igor_nmw.ogg",
					identifier = "TylerTheme",
					soundLevel = 10000,
					looping = true,
					entity = slasher,
					volume = 1,
					fadeIn = 1,
				})
			else
				if endlessChase then
					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/slasher/igor/igor_whatsgood.ogg",
						identifier = "TylerTheme",
						soundLevel = 10000,
						looping = true,
						entity = slasher,
						volume = 1,
						fadeIn = 1,
					})
				else
					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/slasher/igor/tyler_destroyer_theme.mp3",
						identifier = "TylerTheme",
						soundLevel = 10000,
						looping = true,
						entity = slasher,
						volume = 1,
						fadeIn = 1,
					})

					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/slasher/igor/tyler_destroyer_whisper.mp3",
						identifier = "TylerWhisper",
						soundLevel = 60,
						looping = true,
						entity = slasher,
						volume = 1,
						fadeIn = 1,
					})
				end
			end

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

		if v2 > math.max((((3 + SlashCo.MapSize) / 4) * anger), SLASHER.MinChase) and not endlessChase then
			slasher.SlasherValue1 = 0

			SlashCo.AudioSystem.StopSound("TylerTheme", 1)
			SlashCo.AudioSystem.StopSound("TylerWhisper", 1)
			SlashCo.AudioSystem.EnableBackgroundMusic() -- We only play the background music now after the first time he chased.
			SlashCo.AudioSystem.SetBackgroundMusic("slashco/slasher/igor/igors_theme.ogg", 1)

			slasher:SetVisible(false)
			slasher:SetNWBool("TylerFlash", false)

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
			slasher:SetVisible(false)
			slasher:SetNWBool("TylerFlash", false)
		else
			slasher:SetVisible(true)
			slasher:SetNWBool("TylerFlash", true)
		end
	end

	if slasher:GetNWInt("TylerState") ~= v1 then
		slasher:SetNWInt("TylerState", v1)
	end

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
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

	local function DestroyItem(slasher, target)
		SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)
		if not IsValid(target) then
			return
		end

		local corpse
		if target:IsPlayer() then
			corpse = target.DeadBody
		else
			corpse = target
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
	end

	timer.Simple(SlashCoSlashers[slasher:GetNWString("Slasher")].JumpscareDuration, function()
		for i = 1, #player.GetAll() do
			local ply = player.GetAll()[i]
			ply:SetNWBool("DisplayTylerTheDestroyerEffects", false)
		end

		if IsValid(slasher) then
			slasher:Freeze(false)
			if EndlessChase() then goto skip end

			slasher.SlasherValue1 = 0
			slasher:SetVisible(false)

			SlashCo.AudioSystem.StopSound("TylerTheme", 0.5)
			SlashCo.AudioSystem.StopSound("TylerWhisper", 0.5)
			SlashCo.AudioSystem.EnableBackgroundMusic()
			SlashCo.AudioSystem.SetBackgroundMusic("slashco/slasher/igor/igors_theme.ogg", 1)

			slasher:SetNWBool("TylerFlash", false)
			::skip::
		end

		if IsValid(target) then
			target:SetNWBool("SurvivorBeingJumpscared", false)
			target:SetNWBool("SurvivorJumpscare_Tyler", false)

			if target:IsPlayer() then
				target:Freeze(false)
				if target:ItemValue("IsFuel", false, true) then
					SlashCo.DropItem(target, function(_, _, droppedItem)
						droppedItem.DONTPICKUP = true
						DestroyItem(slasher, droppedItem)
					end)
					return
				else
					target:TakeDamage(99999, slasher, slasher)
				end
			end

			timer.Simple(FrameTime(), function()
				DestroyItem(slasher, target)
			end)
		end
	end)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher.SlasherValue1 ~= 0 then
		return
	end

	if slasher:WaterLevel() > 1 then
		return
	end

	slasher.SlasherValue1 = 1
	slasher:SetVisible(true)
end

function SLASHER.Animator(ply)
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

function SLASHER.Thirdperson(ply)
	return ply:GetNWInt("TylerState") == 1
end

function SLASHER.Footstep()
	return true
end

function SLASHER.CanBeSeen(ply)
	if SERVER then
		return
	end

	if ply:GetNWBool("SlashCoVisible", true) and ply:GetNWInt("TylerState") ~= 1 then
		return true
	end
end

local avatarTable = {
	creator = Material("slashco/ui/icons/slasher/s_7"),
	destroyer = Material("slashco/ui/icons/slasher/s_7_s1")
}

local manifestTable = {
	default = Material("slashco/ui/icons/slasher/s_7_s1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Tyler_creator")

	hud:AddControl("R", "manifest", manifestTable)

	hud:AddControl("LMB", "destroy", manifestTable)
	hud:TieControlVisible("LMB", "CanKill")

	hud.prevState = -1
	hud.destroyEnabled = true
	hud.prevWater = -1
	function hud.AlsoThink()
		local state = GameData.LocalPlayer:GetNWInt("TylerState")
		if state == 0 then
			local isInWater = GameData.LocalPlayer:WaterLevel() > 1
			if hud.prevWater ~= isInWater then
				if isInWater then
					hud:SetControlEnabled("R", false)
				else
					hud:SetControlEnabled("R", true)
				end
			end
		end

		if state ~= hud.prevState then
			if state == 0 then
				hud:SetControlVisible("R", true)
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
					if not IsValid(hud) then return end
					hud:SetCrosshairEnabled(false)
				end)
			end

			hud.prevState = state
		end

		local target = GameData.LocalPlayer:GetEyeTrace().Entity
		local class = IsValid(target) and target:GetClass()
		if IsValid(target) and target:IsPlayer() or (target.PingType == "ITEM" and class ~= "sc_beacon")
				and class ~= "sc_battery" and not target:GetNWBool("SurvivorBeingJumpscared") and
				GameData.LocalPlayer:GetPos():Distance(target:GetPos()) < SLASHER.KillDistance then

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
	local eyeball = Material("slashco/ui/particle/eyeball.png")
	local drawIcon
	local iconT = 0
	local iconTL = 0

	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Tyler") == true then
			if GameData.LocalPlayer.tyl_f == nil then
				GameData.LocalPlayer.tyl_f = 0
			end
			GameData.LocalPlayer.tyl_f = GameData.LocalPlayer.tyl_f + (FrameTime() * 20)
			if GameData.LocalPlayer.tyl_f > 39 then
				GameData.LocalPlayer.tyl_f = 25
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_7")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.tyl_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.tyl_f = nil
		end

		if GameData.LocalPlayer:Team() == TEAM_SLASHER then
			return
		end

		if drawIcon and GameData.LocalPlayer:Team() == TEAM_SURVIVOR then
			iconTL = SlashCo.Dampen(7, iconTL, iconT)

			surface.SetMaterial(eyeball)
			surface.SetDrawColor(255, 255 - iconTL / 2, 255 - iconTL / 2, iconTL)
			surface.DrawTexturedRect(ScrW() / 32, ScrW() / 32, ScrW() / 16, ScrW() / 16)
		end

		if GameData.LocalPlayer:GetNWBool("DisplayTylerTheDestroyerEffects") then
			local effectScale = 0
			local localPos = GameData.LocalPlayer:GetPos()
			for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
				if slasher:GetNWString("Slasher") == SLASHER.Name then
					local pos = slasher:GetPos()
					local dist = pos:Distance(localPos)
					if dist > SLASHER.MaxEffectRadius then continue end

					local scale = 1 - (dist - SLASHER.MinEffectRadius) / (SLASHER.MaxEffectRadius - SLASHER.MinEffectRadius)
					if scale > effectScale then
						effectScale = scale
					end

					if not slasher:IsDormant() then -- Play the shake every time he's visible.
						util.ScreenShake(slasher:GetPos(), 15 * scale, 40, 1, SLASHER.MaxEffectRadius, true)
					end
				end
			end

			local Overlay = Material("slashco/ui/overlays/tyler_static")
			local DestroyerFace = Material("slashco/ui/overlays/tyler_destroyer_face")

			Overlay:SetFloat("$alpha", math.Rand(0.1, 0.12) * effectScale)
			DestroyerFace:SetFloat("$alpha", math.Rand(0, 0.07) * effectScale)

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