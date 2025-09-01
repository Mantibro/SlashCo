local SLASHER = {}

SLASHER.Name = "Borgmire"
SLASHER.Aliases = {
	"Borg",
	"Tim",
}
SLASHER.ID = 8
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
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
SLASHER.ChaseCooldown = 5
SLASHER.JumpscareDuration = 0
SLASHER.ChaseMusic = "slashco/slasher/borgmire/borgmire_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Borgmire_desc"
SLASHER.ProTip = "Borgmire_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★☆☆☆☆"
-- Balancement Vars
SLASHER.PunchDamage = 35
SLASHER.ThrowStrengthForward = 1600 -- forward Velocity used when throwing a player
SLASHER.ThrowStrengthUp = 800 -- up Velocity used when throwing a player
SLASHER.ChaseDecreaseMult = 14 -- Multiplier used when decreasing the chase duration
SLASHER.PunchSlowdownDiv = 2 -- Used to divide FrameTime making the PunchSlowdown last longer, the lower, the shorter the Slowdown becomes. 

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.PunchDamage = 35 + (SO * 20) + (1.5 * additionalSurvivors)
	SLASHER.ThrowStrengthForward = 1600 + (SO * 450)  + (30 * additionalSurvivors)
	SLASHER.ThrowStrengthUp = 800 + (SO * 150) + (10 * additionalSurvivors)
	SLASHER.PunchSlowdownDiv = math.max((2 / SO) - (0.05 * additionalSurvivors), 0.5)

	SLASHER.ProwlSpeed = 150 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 325 + (7.5 * additionalSurvivors)
	SLASHER.ChaseDuration = 12.0 + (1 * additionalSurvivors)
end

function SLASHER.OnSpawn(slasher)
	slasher:SetViewOffset(Vector(0, 0, 85))
	slasher:SetCurrentViewOffset(Vector(0, 0, 85))
	slasher:PlayGlobalSound("slashco/slasher/borgmire/borgmire_heartbeat.mp3", 50, nil, true)
	slasher:SetNWBool("CanChase", true)

	slasher.TimeChasing = 0
	slasher.PunchCooldown = 0
	slasher.PunchSlowdown = 0
	slasher.ThrowCooldown = 0
end

function SLASHER.OnTickBehaviour(slasher)
	local ChaseTime = slasher.TimeChasing or 0 --Time Spent chasing
	local PunchCD = slasher.PunchCooldown or 0 --Punch Cooldown
	local PunchSD = slasher.PunchSlowdown or 0 --Punch Slowdown
	local ThrowCD = slasher.ThrowCooldown or 0 -- Throw Cooldown

	if PunchCD > 0 then
		slasher.PunchCooldown = PunchCD - FrameTime()
	end
	
	if ThrowCD > 0 then
		slasher.ThrowCooldown = ThrowCD - FrameTime()
	end

	if PunchSD > 1 then
		slasher.PunchSlowdown = PunchSD - (FrameTime() / SLASHER.PunchSlowdownDiv)
	end
	if PunchSD < 1 then
		slasher.PunchSlowdown = 1
	end

	if not slasher:GetNWBool("InSlasherChaseMode") then
		slasher.TimeChasing = 0

		slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		slasher:SetWalkSpeed(SLASHER.ProwlSpeed)

		slasher.ChaseSound = nil

		if slasher.IdleSound == nil then
			slasher:PlayGlobalSound("slashco/slasher/borgmire/borgmire_breath_base.mp3", 60, nil, true)

			slasher:StopSound("slashco/slasher/borgmire/borgmire_breath_chase.mp3")
			timer.Simple(0.1, function()
				slasher:StopSound("slashco/slasher/borgmire/borgmire_breath_chase.mp3")
			end)

			slasher.IdleSound = true
		end
	else
		slasher.IdleSound = nil

		slasher.TimeChasing = ChaseTime + FrameTime()

		slasher:SetRunSpeed((SLASHER.ChaseSpeed - math.sqrt(ChaseTime * (14 - (SO * 7)))) / PunchSD)
		slasher:SetWalkSpeed((SLASHER.ChaseSpeed - math.sqrt(ChaseTime * (14 - (SO * 7)))) / PunchSD)

		if slasher.ChaseSound == nil then
			slasher:PlayGlobalSound("slashco/slasher/borgmire/borgmire_breath_chase.mp3", 70, nil, true)
			slasher:PlayGlobalSound("slashco/slasher/borgmire/borgmire_anger.mp3", 75)
			slasher:PlayGlobalSound("slashco/slasher/borgmire/borgmire_anger_far.mp3", 110)

			slasher:StopSound("slashco/slasher/borgmire/borgmire_breath_base.mp3")
			timer.Simple(0.1, function()
				slasher:StopSound("slashco/slasher/borgmire/borgmire_breath_base.mp3")
			end)

			slasher.ChaseSound = true
		end
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher)
	if slasher:GetNWBool("BorgmireThrow") then
		return
	end

	if slasher.PunchCooldown < 0.01 then
		slasher:SetNWBool("BorgmirePunch", false)
		slasher.BorgPunching = true
		timer.Remove("BorgmirePunchDecay")
		slasher.PunchCooldown = 2

		timer.Simple(0.3, function()
			if not IsValid(slasher) then
				return
			end

			slasher:EmitSound("slashco/slasher/borgmire/borgmire_swing" .. math.random(1, 2) .. ".mp3")
			slasher.PunchSlowdown = 2

			local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(50, 0, 50)),
					Vector(-35, -45, -60), Vector(35, 45, 60), SLASHER.PunchDamage, DMG_SLASH, 5, false)

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

				target:EmitSound("slashco/slasher/borgmire/borgmire_hit" .. math.random(1, 2) .. ".mp3")
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
				slasher.BorgPunching = false
			end)
		end)
	end
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnSpecialAbilityFire(slasher, target)
	if slasher.BorgPunching then
		return
	end

	if not IsValid(target) or not target:IsPlayer() or slasher:GetNWBool("BorgmireThrow") then
		return
	end

	if target:Team() ~= TEAM_SURVIVOR then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) >= 140 or target:GetNWBool("SurvivorBeingJumpscared") then
		return
	end

	if slasher.ThrowCooldown < 0.01 then
		slasher:SetNWBool("BorgmireThrow", true)
		slasher.ChaseActivationCooldown = 99
		slasher:EmitSound("slashco/slasher/borgmire/borgmire_throw.mp3")
		
		target:Freeze(true)
		target:SetPos(slasher:GetPos() + Vector(0, 0, 100))

		for i = 1, 13 do
			timer.Simple(0.1 + (i / 10), function()
				if not IsValid(target) or not IsValid(slasher) then
					return
				end

				target:SetPos(slasher:GetPos() + Vector(0, 0, 100))
			end)
		end

		timer.Simple(1.5, function()
			if not IsValid(target) or not IsValid(slasher) then
				return
			end

			target:SetPos(slasher:GetPos() + Vector(47, 0, 53))
			target:SetVelocity((slasher:GetForward() * SLASHER.ThrowStrengthForward) + Vector(0, 0, SLASHER.ThrowStrengthUp))

			target:Freeze(false)
			if target:Health() > 1 then
				target:SetHealth(target:Health() * 0.75)
			end
			
			slasher.ThrowCooldown = 3
		end)

		timer.Simple(2, function()
			if not IsValid(target) or not IsValid(slasher) then
				return
			end

			slasher:SetNWBool("BorgmireThrow", false)
			slasher.ChaseActivationCooldown = 2
		end)
	end
end

function SLASHER.Animator(ply)
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

function SLASHER.Footstep(ply)
	if SERVER then
		if ply.BorgStepTick == nil or ply.BorgStepTick > 1 then
			ply.BorgStepTick = 0
		end

		if ply.BorgStepTick == 0 then
			local idx = math.random(1, 4)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/borgmire/borgmire_step" .. idx .. ".mp3",
				identifier = "BorgmireFootstep" .. idx,
				minDistance = 400,
				maxDistance = 700,
				entity = ply,
				volume = 1,
				fadeIn = 0,
				unreliable = true,
			})
		end

		ply.BorgStepTick = ply.BorgStepTick + 1
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_8"))
	hud:SetTitle("Borgmire")

	hud:AddControl("LMB", "punch", Material("slashco/ui/icons/slasher/s_punch"))
	hud:ChaseAndKill(nil, true)
	hud:AddControl("F", "throw", Material("slashco/ui/icons/slasher/s_punch"))
end

SlashCo.RegisterSlasher(SLASHER, "Borgmire")