local SLASHER = {}

SLASHER.Name = "Borgmire"
SLASHER.ID = 8
SLASHER.Class = 1
SLASHER.DangerLevel = 3
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/borgmire/borgmire.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 0
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 325
SLASHER.Perception = 1.0
SLASHER.Eyesight = 2
SLASHER.KillDistance = 0
SLASHER.ChaseRange = 1500
SLASHER.ChaseRadius = 0.88
SLASHER.ChaseDuration = 12.0
SLASHER.ChaseCooldown = 8
SLASHER.JumpscareDuration = 0
SLASHER.ChaseMusic = "slashco/slasher/borgmire_chase.wav"
SLASHER.KillSound = ""
SLASHER.Description = "Borgmire_desc"
SLASHER.ProTip = "Borgmire_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★☆☆☆☆"

SLASHER.OnSpawn = function(slasher)
	slasher:SetViewOffset(Vector(0, 0, 85))
	slasher:SetCurrentViewOffset(Vector(0, 0, 85))
	PlayGlobalSound("slashco/slasher/borgmire_heartbeat.wav", 50, slasher)
	slasher:SetNWBool("CanChase", true)
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --Time Spent chasing
	local v2 = slasher.SlasherValue2 --Punch Cooldown
	local v3 = slasher.SlasherValue3 --Punch Slowdown

	if v2 > 0 then
		slasher.SlasherValue2 = v2 - FrameTime()
	end

	if v3 > 1 then
		slasher.SlasherValue3 = v3 - (FrameTime() / (2 - SO))
	end
	if v3 < 1 then
		slasher.SlasherValue3 = 1
	end

	if not slasher:GetNWBool("InSlasherChaseMode") then
		slasher.SlasherValue1 = 0

		slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		slasher:SetWalkSpeed(SLASHER.ProwlSpeed)

		slasher.ChaseSound = nil

		if slasher.IdleSound == nil then
			PlayGlobalSound("slashco/slasher/borgmire_breath_base.wav", 60, slasher, 1)

			slasher:StopSound("slashco/slasher/borgmire_breath_chase.wav")
			timer.Simple(0.1, function()
				slasher:StopSound("slashco/slasher/borgmire_breath_chase.wav")
			end)

			slasher.IdleSound = true
		end
	else
		slasher.IdleSound = nil

		slasher.SlasherValue1 = v1 + FrameTime()

		slasher:SetRunSpeed((SLASHER.ChaseSpeed - math.sqrt(v1 * (14 - (SO * 7)))) / v3)
		slasher:SetWalkSpeed((SLASHER.ChaseSpeed - math.sqrt(v1 * (14 - (SO * 7)))) / v3)

		if slasher.ChaseSound == nil then
			PlayGlobalSound("slashco/slasher/borgmire_breath_chase.wav", 70, slasher, 1)

			PlayGlobalSound("slashco/slasher/borgmire_anger.mp3", 75, slasher, 1)

			PlayGlobalSound("slashco/slasher/borgmire_anger_far.mp3", 110, slasher, 1)

			slasher:StopSound("slashco/slasher/borgmire_breath_base.wav")
			timer.Simple(0.1, function()
				slasher:StopSound("slashco/slasher/borgmire_breath_base.wav")
			end)

			slasher.ChaseSound = true
		end
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher.SlasherValue2 < 0.01 then
		slasher:SetNWBool("BorgmirePunch", false)
		timer.Remove("BorgmirePunchDecay")
		slasher.SlasherValue2 = 2

		timer.Simple(0.3, function()
			if not IsValid(slasher) then
				return
			end

			slasher:EmitSound("slashco/slasher/borgmire_swing" .. math.random(1, 2) .. ".mp3")
			slasher.SlasherValue3 = 2

			local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(50, 0, 50)),
					Vector(-35, -45, -60), Vector(35, 45, 60), 35 + (SO * 20), DMG_SLASH, 5, false)

			if not target:IsValid() then
				return
			end

			SlashCo.BustDoor(slasher, target, 60000)

			if (target:IsPlayer() and target:Team() == TEAM_SURVIVOR) or target:GetClass() == "prop_ragdoll" then
				local o = Vector(0, 0, 0)

				if (target:IsPlayer() and target:Team() == TEAM_SURVIVOR) then
					o = Vector(0, 0, 50)
				end

				local vPoint = target:GetPos() + o
				local bloodfx = EffectData()
				bloodfx:SetOrigin(vPoint)
				util.Effect("BloodImpact", bloodfx)

				target:EmitSound("slashco/slasher/borgmire_hit" .. math.random(1, 2) .. ".mp3")
			end
		end)

		timer.Simple(0.05, function()
			if not IsValid(slasher) then
				return
			end

			slasher:SetNWBool("BorgmirePunch", true)

			timer.Create("BorgmirePunchDecay", 1.5, 1, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("BorgmirePunch", false)
			end)
		end)
	end
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnSpecialAbilityFire = function(slasher, target)
	local SO = SlashCo.CurRound.OfferingData.SO

	if not IsValid(target) or not target:IsPlayer() or slasher:GetNWBool("BorgmireThrow") then
		return
	end

	if target:Team() ~= TEAM_SURVIVOR then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) >= 200 or target:GetNWBool("SurvivorBeingJumpscared") then
		return
	end

	slasher:SetNWBool("BorgmireThrow", true)

	--local pick_ang = SlashCo.RadialTester(slasher, 200, target)
	--slasher:SetEyeAngles( Angle(0,pick_ang,0) )

	slasher.ChaseActivationCooldown = 99
	slasher:EmitSound("slashco/slasher/throw.mp3")

	target:Freeze(true)
	slasher:Freeze(true)

	target:SetPos(slasher:GetPos() + Vector(0, 0, 100))

	for i = 1, 13 do
		timer.Simple(0.1 + (i / 10), function()
			if not IsValid(target) then
				return
			end

			target:SetPos(slasher:GetPos() + Vector(0, 0, 100))
		end)
	end

	timer.Simple(1.5, function()
		if not IsValid(target) then
			return
		end

		target:SetPos(slasher:GetPos() + Vector(47, 0, 53))

		local strength_forward = 1600 + (SO * 450)
		local strength_up = 800 + (SO * 150)

		target:SetVelocity((slasher:GetForward() * strength_forward) + Vector(0, 0, strength_up))

		target:Freeze(false)
		if target:Health() > 1 then
			target:SetHealth(target:Health() * 0.75)
		end
	end)

	timer.Simple(2, function()
		if not IsValid(target) then
			return
		end

		slasher:Freeze(false)
		slasher:SetNWBool("BorgmireThrow", false)
		slasher.ChaseActivationCooldown = 2
	end)
end

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local borg_punch = ply:GetNWBool("BorgmirePunch")
	local borg_throw = ply:GetNWBool("BorgmireThrow")

	if not borg_punch and not borg_throw then
		ply.anim_antispam = false
	end

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("walk_all")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("run_all")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("jump")
	end

	if borg_punch and (ply.anim_antispam == nil or ply.anim_antispam == false) then
		local r = math.random(1, 2)
		local PunchAnim = ""
		if r == 1 then
			PunchAnim = "Attack_FIST"
		else
			PunchAnim = "Attack_MELEE"
		end

		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence(PunchAnim), 0, true)
		ply.anim_antispam = true
	end

	if borg_throw and (ply.anim_antispam == nil or ply.anim_antispam == false) then
		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("attack_throw"), 0, true)
		ply.anim_antispam = true
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		if ply.BorgStepTick == nil or ply.BorgStepTick > 1 then
			ply.BorgStepTick = 0
		end

		if ply.BorgStepTick == 0 then
			ply:EmitSound("slashco/slasher/borgmire_step" .. math.random(1, 4) .. ".mp3")
		end

		ply.BorgStepTick = ply.BorgStepTick + 1

		return true
	end

	return true
end

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_8"))
	hud:SetTitle("Borgmire")

	hud:AddControl("LMB", "punch", Material("slashco/ui/icons/slasher/s_punch"))
	hud:ChaseAndKill(nil, true)
	hud:AddControl("F", "throw", Material("slashco/ui/icons/slasher/s_punch"))
end

SlashCo.RegisterSlasher(SLASHER, "Borgmire")