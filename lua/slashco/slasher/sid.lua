local SLASHER = {}

SLASHER.Name = "Sid"
SLASHER.ID = 2
SLASHER.Class = 2
SLASHER.DangerLevel = 2
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/sid/sid.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 7
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 275
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 120
SLASHER.ChaseRange = 1500
SLASHER.ChaseRadius = 0.96
SLASHER.ChaseDuration = 6.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 1
SLASHER.ChaseMusic = "slashco/slasher/sid_chase.wav"
SLASHER.KillSound = "slashco/slasher/sid_kill.mp3"
SLASHER.Description = "Sid_desc"
SLASHER.ProTip = "Sid_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★☆"
SLASHER.ItemToSpawn = "Cookie"

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = math.Clamp(slasher.SlasherValue1, 0, 5) --Cookies Eaten
	slasher.SlasherValue1 = v1
	local v2 = slasher.SlasherValue2 --Pacification
	local v3 = slasher.SlasherValue3 --Gun use cooldown
	local v4 = slasher.SlasherValue4 --bullet spread
	local v5 = slasher.SlasherValue5 --chase speed increase

	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception

	if v2 > 0 then
		slasher.SlasherValue2 = v2 - (FrameTime() + (SO * 0.04))
		slasher:SetNWBool("CanKill", false)
		slasher:SetNWBool("CanChase", false)
	elseif slasher:GetNWBool("SidGun", false) then
		slasher:SetNWBool("CanKill", false)
		slasher:SetNWBool("CanChase", false)
		slasher:SetNWBool("DemonPacified", false)
	else
		slasher:SetNWBool("CanKill", true)
		slasher:SetNWBool("CanChase", true)
		slasher:SetNWBool("DemonPacified", false)
	end

	if v3 > 0 then
		slasher.SlasherValue3 = v3 - (FrameTime() + (SO * 0.04))
	end
	if v4 > 0 then
		slasher.SlasherValue4 = v4 - (0.02 + (SO * 0.08))
	end

	if v5 < 160 and slasher:GetNWBool("InSlasherChaseMode") then
		slasher.SlasherValue5 = v5 + (FrameTime() + (SO * 0.02)) + (v1 * FrameTime() * 0.5)
		slasher:SetRunSpeed(SLASHER.ChaseSpeed + (v5 / 3.5))
		slasher:SetWalkSpeed(SLASHER.ChaseSpeed + (v5 / 3.5))
	else
		slasher.SlasherValue5 = 0
	end

	if not slasher:GetNWBool("DemonPacified") then
		if not slasher:GetNWBool("SidGun") then
			final_eyesight = SLASHER.Eyesight
			final_perception = SLASHER.Perception
		else
			if not slasher:GetNWBool("SidGunRage") then
				final_eyesight = SLASHER.Eyesight + (2 + (SO * 2))
				final_perception = SLASHER.Perception + (1.5 + (SO * 1))
			else
				final_eyesight = SLASHER.Eyesight + (5 + (SO * 2))
				final_perception = SLASHER.Perception + (1 + (SO * 3))
			end
		end
	else
		final_eyesight = 0
		final_perception = 0
	end

	if SlashCo.CurRound.GameProgress > 9 and not slasher:GetNWBool("SidGunRage") then
		slasher:SetNWBool("SidGunRage", true)

		if slasher:GetNWBool("SidGunEquipped") then
			if not slasher:GetNWBool("SidGunAimed") and not slasher:GetNWBool("SidGunAiming") then
				slasher:SetRunSpeed(SLASHER.ChaseSpeed)
			end
		end
	end

	if slasher:GetNWBool("SidGunRage") and not slasher:GetNWBool("SidGunLetterC") and slasher:GetNWBool("SidGunEquipped") then
		slasher:SetNWBool("SidGunLetterC", true)
		SlashCo.PlayGlobalSound("slashco/slasher/sid_THE_LETTER_C.wav", 95, slasher, 0.5)
	end

	if slasher:GetNWInt("SidGunUses") ~= v1 then
		slasher:SetNWInt("SidGunUses", v1)
	end

	if not slasher.CanUseGun and SlashCo.CurRound.GameProgress > 5 then
		slasher:SetNWBool("SidCanUseGun", true)
		slasher.CanUseGun = true
	end

	-- [[
	--let sid use his gun early if he gets enough saturation
	if not slasher.CanUseGun and v1 >= 5 then
		slasher:SetNWBool("SidCanUseGun", true)
		slasher.CanUseGun = true
	end
	--]]

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if not slasher:GetNWBool("SidGun") then
		SlashCo.Jumpscare(slasher, target)
		return
	end

	local spread = slasher.SlasherValue4
	local dist = SLASHER.KillDistance

	if slasher:GetNWBool("SidGunAimed") and spread < 2.4 then
		slasher:SetNWBool("SidGunShoot", false)
		timer.Remove("SidGunDecay")

		timer.Simple(0.05, function()
			if not IsValid(slasher) then
				return
			end

			slasher:SetNWBool("SidGunShoot", true)

			SlashCo.PlayGlobalSound("slashco/slasher/sid_shot_farthest.mp3", 150, slasher)
			SlashCo.PlayGlobalSound("slashco/slasher/sid_shot.mp3", 85, slasher)
			SlashCo.PlayGlobalSound("slashco/slasher/sid_shot_legacy.mp3", 78, slasher)

			slasher:FireBullets(
					{
						Damage = 100,
						TracerName = "AirboatGunHeavyTracer",
						Dir = slasher:GetAimVector(),
						Src = slasher:GetPos() + Vector(0, 0, 60),
						IgnoreEntity = slasher,
						Spread = Vector(math.Rand(-1 - (spread * 25), 1 + (spread * 25)) * 0.001,
								math.Rand(-1 - (spread * 25), 1 + (spread * 25)) * 0.001, 0)

					}, false)

			local vec, ang = slasher:GetBonePosition(slasher:LookupBone("HandL"))
			local vPoint = vec
			local muzzle = EffectData()
			muzzle:SetOrigin(vPoint + slasher:GetForward() * 8 + Vector(0, 0, 2))
			muzzle:SetStart(Vector(255, 0, 0))
			muzzle:SetAttachment(0)
			util.Effect("sid_muzzle", muzzle)

			local shell = EffectData()
			shell:SetOrigin(vPoint)
			shell:SetAngles(ang)
			util.Effect("ShellEject", shell)

			slasher.SlasherValue4 = 3

			timer.Create("SidGunDecay", 1.5, 1, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("SidGunShoot", false)
			end)
		end)
	else
		--Executing a Survivor

		if IsValid(target) and target:IsPlayer() then
			if target:Team() ~= TEAM_SURVIVOR then
				return
			end

			if slasher:GetPos():Distance(target:GetPos()) >= dist * 1.4 or target:GetNWBool("SurvivorBeingJumpscared") then
				return
			end

			local pick_ang = SlashCo.RadialTester(slasher, 600, target)

			slasher:SetEyeAngles(Angle(0, pick_ang, 0))
			target:SetEyeAngles(Angle(0, pick_ang, 0))
			slasher:Freeze(true)

			timer.Simple(0.1, function()
				if not IsValid(slasher) or not IsValid(target) then
					return
				end

				target:SetPos(slasher:GetPos())

				target:Freeze(true)

				target:SetNWBool("SurvivorBeingJumpscared", true)
				slasher:SetNWBool("CanChase", false)

				SlashCo.PlayGlobalSound("slashco/slasher/sid_angry_" .. math.random(1, 4) .. ".mp3", 85, slasher, 1)

				slasher:SetNWBool("SidExecuting", true)

				target:SetNWBool("SurvivorDecapitate", true)
				target:SetNWBool("SurvivorSidExecution", true)

				target:SetPos(slasher:GetPos())
				target:SetEyeAngles(Angle(0, pick_ang, 0))

				slasher.KillDelayTick = SlashCoSlashers[slasher:GetNWString("Slasher")].KillDelay

				timer.Simple(1, function()
					if not IsValid(target) then
						return
					end

					target:EmitSound("ambient/voices/citizen_beaten4.wav")
				end)

				timer.Simple(3, function()
					if not IsValid(target) then
						return
					end

					target:EmitSound("ambient/voices/citizen_beaten3.wav")
				end)

				timer.Simple(3.95, function()
					if not IsValid(target) then
						return
					end

					target:SetEyeAngles(Angle(0, 180 + pick_ang, 0))
				end)

				timer.Simple(4.1, function()
					if not IsValid(slasher) or not IsValid(target) then
						return
					end

					target:SetNWBool("SurvivorBeingJumpscared", false)

					SlashCo.PlayGlobalSound("slashco/slasher/sid_shot_farthest.mp3", 150, slasher)

					slasher:EmitSound("slashco/slasher/sid_shot.mp3", 95)
					slasher:EmitSound("slashco/slasher/sid_shot_2.mp3", 85)

					local vec, ang = slasher:GetBonePosition(slasher:LookupBone("HandL"))
					local vPoint = vec
					local muzzle = EffectData()
					muzzle:SetOrigin(vPoint + slasher:GetForward() * 8 + Vector(0, 0, 2))
					muzzle:SetStart(Vector(255, 0, 0))
					muzzle:SetAttachment(0)
					util.Effect("sid_muzzle", muzzle)

					local shell = EffectData()
					shell:SetOrigin(vPoint)
					shell:SetAngles(ang)
					util.Effect("ShellEject", shell)

					target:SetNWBool("SurvivorSidExecution", false)
					target:SetPos(slasher:GetPos() + (slasher:GetForward() * 40))

					target:Freeze(false)
					target:SetVelocity(slasher:GetForward() * 300)
					target:SetNotSolid(false)
					timer.Simple(0.05, function()
						if not IsValid(target) then
							return
						end

						target:Kill()
					end)
				end)

				timer.Simple(8, function()
					if not IsValid(slasher) or not IsValid(target) then
						return
					end

					slasher:Freeze(false)
					slasher:SetNWBool("SidExecuting", false)
					target:SetNWBool("SurvivorDecapitate", false)
				end)
			end)
		end
	end
end

SLASHER.OnSecondaryFire = function(slasher)
	if not slasher:GetNWBool("SidGunEquipped") then
		SlashCo.StartChaseMode(slasher)
		return
	end

	local gunrage = slasher:GetNWBool("SidGunRage")

	if not slasher:GetNWBool("SidGunAimed") and not slasher:GetNWBool("SidGunAiming") and slasher.SlasherValue3 < 0.01 then
		slasher:SetNWBool("SidGunAiming", true)
		slasher.SlasherValue3 = 2
		slasher:SetSlowWalkSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetRunSpeed(1)
		slasher:EmitSound("slashco/slasher/sid_draw.wav", 75, 110)

		timer.Simple(1, function()
			if not IsValid(slasher) then
				return
			end

			slasher:SetNWBool("SidGunAiming", false)
			slasher:SetNWBool("SidGunAimed", true)
			slasher:EmitSound("slashco/slasher/sid_clipout.wav")
			slasher.SlasherValue4 = 2
		end)
	elseif slasher:GetNWBool("SidGunAimed") and slasher.SlasherValue3 < 0.01 then
		slasher.SlasherValue3 = 2
		slasher:SetNWBool("SidGunAiming", false)
		slasher:SetNWBool("SidGunAimed", false)
		slasher:SetSlowWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)
		slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)

		if not gunrage then
			slasher:SetRunSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)
		else
			slasher:SetRunSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
		end
	end
end

SLASHER.OnMainAbilityFire = function(slasher, target)
	local SO = SlashCo.CurRound.OfferingData.SO
	local SatO = SlashCo.CurRound.OfferingData.SatO

	if not IsValid(target) or target:GetClass() ~= "sc_cookie" then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) >= 150 or slasher:GetNWBool("SidEating") or slasher:GetNWBool("SidGun") then
		return
	end

	slasher:SetNWBool("SidEating", true)
	slasher.SlasherValue2 = 99
	slasher:EmitSound("slashco/slasher/sid_cookie" .. math.random(1, 2) .. ".mp3")

	target:SetNWBool("BeingEaten", true)

	timer.Simple(1.3, function()
		slasher:EmitSound("slashco/slasher/sid_eating.mp3")
	end)

	slasher:Freeze(true)

	timer.Simple(10, function()
		if not IsValid(slasher) then
			return
		end

		slasher:Freeze(false)
		slasher:SetNWBool("SidEating", false)
		slasher:SetNWBool("DemonPacified", true)
		slasher.SlasherValue1 = slasher.SlasherValue1 + 1 + SatO
		slasher.SlasherValue2 = math.random(15, 25)

		if IsValid(target) then
			target:Remove()
		end
	end)
end

SLASHER.OnSpecialAbilityFire = function(slasher)
	if not slasher.CanUseGun then
		return
	end

	local SO = SlashCo.CurRound.OfferingData.SO

	if not slasher:GetNWBool("SidGun") and slasher.SlasherValue3 < 0.01 and slasher.SlasherValue1 > 0 then
		--Equip the gun
		slasher:SetNWBool("SidGun", true)
		slasher:SetNWBool("SidGunEquipping", true)
		slasher:Freeze(true)
		slasher.SlasherValue3 = 4 - (SO * 2)
		slasher.SlasherValue2 = 4 - (SO * 2)

		slasher.SlasherValue1 = slasher.SlasherValue1 - 1 --Deplete the uses

		timer.Simple(0.5, function()
			--Show the gun model

			slasher:SetBodygroup(1, 1)
			slasher:EmitSound("slashco/slasher/sid_draw.wav")
		end)
		timer.Simple(2.25, function()
			--sound
			slasher:EmitSound("slashco/slasher/sid_slideback.wav", 75, 75)
			slasher:SlasherHudFunc("SetCrosshairProngs", 4)
		end)

		timer.Simple(4.5, function()
			--Apply the state

			slasher:SetNWBool("SidGunEquipping", false)
			slasher:SetNWBool("SidGunEquipped", true)
			slasher:Freeze(false)

			slasher.SlasherValue3 = 2

			if slasher:GetNWBool("SidGunRage") then
				slasher:SetRunSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
			end
		end)
	elseif slasher:GetNWBool("SidGun") and slasher.SlasherValue3 < 0.01 and not slasher:GetNWBool("SidGunAiming") and not slasher:GetNWBool("SidGunAimed") then
		slasher:SetNWBool("SidGunEquipped", false)
		slasher:SetNWBool("SidGun", false)
		slasher:SetBodygroup(1, 0)
		slasher:SetNWBool("SidGunLetterC", false)
		slasher:StopSound("slashco/slasher/sid_THE_LETTER_C.wav")
		slasher.SlasherValue2 = math.random(5, 15)
	end
end

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local pac = ply:GetNWBool("DemonPacified")

	local eating = ply:GetNWBool("SidEating")
	local equipping_gun = ply:GetNWBool("SidGunEquipping")
	local sid_executing = ply:GetNWBool("SidExecuting")

	local gun_state = ply:GetNWBool("SidGunEquipped")
	local aiming_gun = ply:GetNWBool("SidGunAiming")
	local aimed_gun = ply:GetNWBool("SidGunAimed")
	local gun_shooting = ply:GetNWBool("SidGunShoot")
	local gun_rage = ply:GetNWBool("SidGunRage")

	if gun_state then
		gun_prefix = "g_"
	else
		gun_prefix = ""
	end

	if not eating and not equipping_gun and not aiming_gun and not gun_shooting and not sid_executing then
		ply.anim_antispam = false
	end

	if not equipping_gun then
		if not aiming_gun and not aimed_gun then
			if not eating then
				if ply:IsOnGround() then
					if ply:GetVelocity():Length() < 200 then
						ply.CalcIdeal = ACT_HL2MP_WALK
						ply.CalcSeqOverride = ply:LookupSequence(gun_prefix .. "prowl")
					else
						ply.CalcIdeal = ACT_HL2MP_RUN
						ply.CalcSeqOverride = ply:LookupSequence(gun_prefix .. "chase")
					end
				else
					ply.CalcSeqOverride = ply:LookupSequence(gun_prefix .. "float")
				end
			else
				ply.CalcSeqOverride = ply:LookupSequence("eat")
				if ply.anim_antispam == nil or ply.anim_antispam == false then
					ply:SetCycle(0)
					ply.anim_antispam = true
				end
			end
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("arm")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if aiming_gun then
		ply.CalcSeqOverride = ply:LookupSequence("readygun")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if aimed_gun then
		if not gun_shooting then
			ply.CalcSeqOverride = ply:LookupSequence("readyidle")
		else
			ply.CalcSeqOverride = ply:LookupSequence("shoot")
			if ply.anim_antispam == nil or ply.anim_antispam == false then
				ply:SetCycle(0)
				ply.anim_antispam = true
			end
		end
	end

	if sid_executing then
		ply.CalcSeqOverride = ply:LookupSequence("execution")
		ply:SetPlaybackRate(1)
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		ply:EmitSound("slashco/slasher/sid_step" .. math.random(1, 2) .. ".mp3")
		return true
	end

	if CLIENT then
		return true
	end
end

local gunTable = {
	["equip gun"] = Material("slashco/ui/icons/slasher/s_2_a1"),
	["unequip gun"] = Material("slashco/ui/icons/slasher/s_2_a1_unavailable"),
	["d/"] = Material("slashco/ui/icons/slasher/s_2_a1_disabled")
}

local attackTable = {
	default = Material("slashco/ui/icons/slasher/s_0"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled"),
	shoot = Material("slashco/ui/icons/slasher/s_2_a2")
}

local aimTable = {
	default = Material("slashco/ui/icons/slasher/s_chase"),
	["d/"] = Material("slashco/ui/icons/slasher/chase_disabled"),
	aim = Material("slashco/ui/icons/slasher/s_2_a3"),
	["d/aim"] = Material("slashco/ui/icons/slasher/kill_disabled"),
	["lower gun"] = Material("slashco/ui/icons/slasher/s_2_a3")
}

local cookieTable = {
	default = Material("slashco/ui/icons/slasher/s_2"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_2"))
	hud:SetTitle("Sid")

	hud:AddControl("R", "eat cookie", cookieTable)
	hud:TieControlVisible("R", "SidGun", true, false, false)
	hud:ChaseAndKill()
	hud:SetControlIconTable("LMB", attackTable)
	hud:SetControlIconTable("RMB", aimTable)
	hud:AddControl("F", "equip gun", gunTable)
	hud:TieControlVisible("F", "SidGunAimed", true, false, false)
	hud:TieControlText("F", "SidGun", "unequip gun", "equip gun", false, false)
	hud:SetCrosshairEnabled(true)
	hud:SetCrosshairAlpha(255)
	hud:TieCrosshair("SidGunAimed")
	hud:TieCrosshairEntity("sc_cookie", 150, "R", { "SidGun", "SidEating", IsOr = true })

	timer.Simple(0, function()
		if LocalPlayer():GetNWBool("SidCanUseGun") then
			return
		end
		hud:SetControlVisible("F", false)
	end)

	hud:AddMeter("satiation", 5, "", nil, true)
	hud:TieMeterInt("satiation", "SidGunUses", true)

	hud.prevGun = not LocalPlayer():GetNWBool("SidGun")
	hud.prevGunEquipped = not LocalPlayer():GetNWBool("SidGunEquipped")
	hud.prevGunUses = -1
	function hud.AlsoThink()
		local gun = LocalPlayer():GetNWBool("SidGun")
		local gunUses = LocalPlayer():GetNWInt("SidGunUses")
		if gun ~= hud.prevGun then
			if gun then
				hud:UntieControl("LMB")
				hud:UntieControl("RMB")
				hud:TieControlText("RMB", "SidGunAimed", "lower gun", "aim", true, false)
				hud:ShakeControl("F")
				hud:SetControlEnabled("F", false)
				--hud:SetControlText("LMB", "shoot")
				timer.Simple(0, function()
					hud:SetControlEnabled("LMB", true)
					hud:SetControlEnabled("RMB", false)
					hud:TieControlText("LMB", "SidGunAimed", "shoot", "kill survivor", true, false)
					--hud:TieControlVisible("LMB", "SidGunAimed", false, false, false)
				end)
			else
				if gunUses <= 0 then
					hud:SetControlEnabled("F", false)
				else
					hud:SetControlEnabled("F", true)
				end
				hud:SetCrosshairProngs(3)
				hud:UntieControl("LMB")
				hud:UntieControl("RMB")
				hud:SetControlVisible("LMB", true)
				hud:SetControlText("LMB", "kill survivor")
				hud:ShakeControl("F")
				hud:TieControl("LMB", "CanKill")
				hud:TieControl("RMB", "CanChase")
				hud:TieControlText("RMB", "InSlasherChaseMode", "stop chasing", "start chasing", true, false)
			end

			hud.prevGun = gun
		end

		local gunEquip = LocalPlayer():GetNWBool("SidGunEquipped")
		if gunEquip ~= hud.prevGunEquipped then
			if gunEquip then
				timer.Simple(0, function()
					hud:SetControlEnabled("RMB", true)
					hud:SetControlEnabled("F", true)
				end)
			end

			hud.prevGunEquipped = gunEquip
		end

		if gunUses ~= hud.prevGunUses then
			if gunUses <= 0 then
				hud:SetControlEnabled("F", false)
			elseif hud.prevGunUses < gunUses then
				hud:SetControlEnabled("F", true)
			end

			hud.prevGunUses = gunUses
		end

		if not hud.gunMode and LocalPlayer():GetNWBool("SidCanUseGun") then
			hud:SetControlVisible("F", true)
			hud:SetMeterName("satiation", "gun uses")
			hud:FlashMeter("gun uses")
			hud:SetTitle("Sid_gun_title")
			hud:ShakeControl("F")
			hud:FlashMeter("gun uses")
			surface.PlaySound("slashco/slashco_progress.mp3")
			hud.gunMode = true
		end
	end
end

SLASHER.PreDrawHalos = function()
	SlashCo.DrawHalo(ents.FindByClass("sc_cookie"), nil, 2, false)

	local plyWithItem = {}
	for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if v:HasItem("Cookie") then
			table.insert(plyWithItem, v)
		end
	end

	SlashCo.DrawHalo(plyWithItem, nil, 2, false)
end

SLASHER.SidRage = function(ply)
	local pos = ply:GetPos()

	for i = 1, #team.GetPlayers(TEAM_SLASHER) do
		local slasherid = team.GetPlayers(TEAM_SLASHER)[i]:SteamID64()
		local slasher = team.GetPlayers(TEAM_SLASHER)[i]

		if SlashCoSlashers[slasher:GetNWString("Slasher")].ID ~= 2 then
			return
		end

		if slasher:GetPos():Distance(pos) > 1800 then
			return
		end

		slasher.SlasherValue1 = slasher.SlasherValue1 + 2

		SlashCo.PlayGlobalSound("slashco/slasher/sid_angry_" .. math.random(1, 4) .. ".mp3", 95, slasher, 1)

		for _, v in player.Iterator() do
			v:SetNWBool("SidFuck", true)
		end

		timer.Simple(3, function()
			for _, v in player.Iterator() do
				v:SetNWBool("SidFuck", false)
			end

			SlashCo.PlayGlobalSound("slashco/slasher/sid_sad_1.mp3", 85, slasher, 1)
		end)
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Sid") == true then
			if LocalPlayer().sid_f == nil then
				LocalPlayer().sid_f = 0
			end
			if LocalPlayer().sid_f < 39 then
				LocalPlayer().sid_f = LocalPlayer().sid_f + (FrameTime() * 30)
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_2")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().sid_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().sid_f = nil
		end

		if LocalPlayer():GetNWBool("SidFuck") == true then
			local Overlay = Material("slashco/ui/overlays/sid_fuck")

			surface.SetDrawColor(255, 255, 255, 60)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

			if c == nil then
				surface.PlaySound("slashco/slasher/sid_rage_drone.mp3")
				c = true
			end
		end
	end)

	hook.Add("CalcView", "SidExecution", function(ply, pos, angles, fov)
		if ply:Team() ~= TEAM_SURVIVOR then
			return
		end

		if ply:GetNWBool("SurvivorSidExecution") then
			pos = ply:LocalToWorld(Vector(120, 120, 60))
			angles = ply:LocalToWorldAngles(Angle(0, -135, 0))

			return GAMEMODE:CalcView(ply, pos, angles, fov)
		else
			return
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Sid")

