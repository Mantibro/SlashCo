local SLASHER = {}

SLASHER.Name = "Americanpo"
SLASHER.Aliases = {
	"Po",
	"Big Po",
	"The Patriot",
}
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/americanpo/americanpo.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 0
SLASHER.ProwlSpeed = 150
SLASHER.ProwlSpeedAggro = 200
SLASHER.ChaseSpeed = 280
SLASHER.FinalSpeed = 305
SLASHER.Perception = 4.0
SLASHER.Eyesight = 7
SLASHER.KillDistance = 0
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.90
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 10
SLASHER.JumpscareDuration = 0
SLASHER.ChaseMusic = "slashco/slasher/americanpo/po_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Americanpo_desc"
SLASHER.ProTip = "Americanpo_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★☆☆☆"

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	SLASHER.ChaseDuration = SLASHER.ChaseDuration + (1 * additionalSurvivors)

	if additionalSurvivors > 0 then
		SLASHER.ProwlSpeed = SLASHER.ProwlSpeed + (3 * additionalSurvivors)
		SLASHER.ProwlSpeedAggro = SLASHER.ProwlSpeedAggro + (2 * additionalSurvivors)
		SLASHER.ChaseSpeed = SLASHER.ChaseSpeed + (0.5 * additionalSurvivors)
		SLASHER.FinalSpeed = SLASHER.FinalSpeed + (0.5 * additionalSurvivors)
	end
end

local function AmericanpoIdle(slasher)
	if not slasher:GetNWBool("InSlasherChaseMode") or not slasher:GetNWBool("AmericanpoFinal") then
		local hunter = slasher:GetNWInt("AmericanpoState") == 0
		local idx = math.random(1, 9)

		if not slasher:GetNWBool("AmericanpoAiming") then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/americanpo/vo/po_idle" .. idx .. ".mp3",
				identifier = "AmericanpoIdle" .. idx,
				minDistance = 200,
				maxDistance = 1200,
				entity = slasher,
				volume = hunter and 0.5 or 1,
				fadeIn = 0,
			})
		end
	else
		local idxx = math.random(1, 9)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/americanpo/vo/po_chase" .. idxx .. ".mp3",
			identifier = "AmericanpoChase" .. idxx,
			minDistance = 200,
			maxDistance = 1200,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end

	timer.Simple(math.random(60, 120), function()
		AmericanpoIdle(slasher)
	end)
end

local AMERICANPO_HUNTER = 0
local AMERICANPO_AGGRO = 1

local function PoEndlessChase(slasher)
	if slasher.americanpo_final_antispam == nil then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/americanpo/po_endgame.ogg",
			identifier = "AmericanPoFinal",
			minDistance = 15000,
			maxDistance = 20000,
			looping = true,
			isMusic = true,
			entity = slasher,
			volume = 0.6,
			fadeIn = 0,
		})

		SlashCo.StopChase(slasher)
		slasher.AmericanpoState = AMERICANPO_AGGRO

		-- just in case we have some actions going on at the same time, let's prevent animations from breaking.
		slasher:SetNWBool("AmericanpoShootingHip", false)
		slasher:SetNWBool("AmericanpoShooting", false)
		slasher:SetNWBool("AmericanpoAiming", false)
		slasher:SetNWBool("AmericanpoAim", false)
		slasher:SetNWBool("AmericanpoAttack", false)
		slasher:SetNWBool("AmericanpoThrowingBottle", false)
		slasher:SetNWBool("AmericanpoStun", false)
		slasher:SetNWBool("InSlasherChaseMode", false)
		slasher:SetNWBool("CanChase", false)
		slasher:Freeze(false)

		slasher.americanpo_final_antispam = 0
	end
end

function SLASHER.OnSpawn(slasher)
	slasher.AmericanpoState = AMERICANPO_HUNTER
	AmericanpoIdle(slasher)
	slasher:SetNWBool("CanChase", true)
	slasher:SetNWBool("AmericanpoFinal", false)
	slasher:SetNWBool("AmericanpoAiming", false)
	slasher:SetNWBool("AmericanpoAttack", false)
	slasher.americanpo_final_antispam = nil

	slasher.AmericanpoStateCooldown = 0
	slasher.BulletSpread = 2
	slasher.ShotgunCooldown = 0
	slasher.AttackCooldown = 0
	slasher.BottleCooldown = 0
end

function SLASHER.OnTickBehaviour(slasher)
	local State = slasher.AmericanpoState or AMERICANPO_HUNTER --State
	local StateCD = slasher.AmericanpoStateCooldown or 0 -- Cooldown to switch state
	local BulletSP = slasher.BulletSpread or 0 --Bullet spread
	local ShotgunCD = slasher.ShotgunCooldown or 0 -- Cooldown for aim shotgun
	local AttackCD = slasher.AttackCooldown or 0 -- Cooldown for melee attack
	local BottleCD = slasher.BottleCooldown or 0 -- Cooldown for bottle throw

	local eyesight_final = SLASHER.Eyesight
	local perception_final = SLASHER.Perception

	if StateCD > 0 then
		slasher.AmericanpoStateCooldown = StateCD - FrameTime()
	end

	if ShotgunCD > 0 then
		slasher.ShotgunCooldown = ShotgunCD - FrameTime()
	end

	if AttackCD > 0 then
		slasher.AttackCooldown = AttackCD - FrameTime()
	end

	if BottleCD > 0 then
		slasher.BottleCooldown = BottleCD - FrameTime()
	end

	if State == AMERICANPO_HUNTER then
		-- Hunter Mode
		eyesight_final = 7
		perception_final = 4.0
	else
		-- Aggro Mode
		eyesight_final = 3
		perception_final = 0.5
	end

	if slasher:GetNWBool("InSlasherChaseMode") then
		slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed)
		slasher:SetWalkSpeed(SLASHER.ChaseSpeed)
		slasher:SetRunSpeed(SLASHER.ChaseSpeed)
	else
		if slasher:GetNWBool("AmericanpoFinal") then
			slasher:SetSlowWalkSpeed(SLASHER.FinalSpeed)
			slasher:SetWalkSpeed(SLASHER.FinalSpeed)
			slasher:SetRunSpeed(SLASHER.FinalSpeed)
		else
			if not slasher:GetNWBool("AmericanpoAiming") or slasher:GetNWBool("AmericanpoAttack") then
				if State == AMERICANPO_HUNTER then
					slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
					slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
					slasher:SetRunSpeed(SLASHER.ProwlSpeed)
				else
					slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeedAggro)
					slasher:SetWalkSpeed(SLASHER.ProwlSpeedAggro)
					slasher:SetRunSpeed(SLASHER.ProwlSpeedAggro)
				end
			else
				slasher:SetSlowWalkSpeed(1)
				slasher:SetWalkSpeed(1)
				slasher:SetRunSpeed(1)
			end
		end
	end

	if SlashCo.CurRound.EscapeHelicopterSummoned then
		slasher:SetNWBool("AmericanpoFinal", true)
		PoEndlessChase(slasher)
	end

	if slasher:GetNWInt("AmericanpoState") ~= State then
		slasher:SetNWInt("AmericanpoState", State)
	end

	slasher:SetEyeSight(eyesight_final)
	slasher:SetPerception(perception_final)
end

local function BulletHit(attacker, tr, dmginfo)
	if IsValid(tr.Entity) and (tr.Entity:IsPlayer() and tr.Entity:Team() == TEAM_SURVIVOR) then
		if tr.Entity:GetNWBool("SurvivorFueled") then
			tr.Entity:Ignite(5)
		end
	end
end

local function PlayBullets(slasher)
	if not slasher:GetNWBool("AmericanpoStun") then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/americanpo/po_shotgunfire.mp3",
			identifier = "AmericanpoShot",
			minDistance = 700 * SlashCo.MapSize,
			maxDistance = 1240 * SlashCo.MapSize,
			entity = slasher,
			volume = 0.8,
			fadeIn = 0,
		})
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/po_shotgunfirenear.mp3",
		identifier = "AmericanpoShotNear",
		minDistance = 200 * SlashCo.MapSize,
		maxDistance = 400 * SlashCo.MapSize,
		entity = slasher,
		volume = 0.1,
		fadeIn = 0,
	})

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/po_shotgunfirefar.mp3",
		identifier = "AmericanpoShotFar",
		minDistance = 1250 * SlashCo.MapSize,
		maxDistance = 2250 * SlashCo.MapSize,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	local bullets = 8
	local spread = slasher.BulletSpread

	for i = 1, bullets do
		timer.Simple(i * 0.001, function()
			if not IsValid(slasher) then return end

			slasher:FireBullets({
				Callback = BulletHit,
				Damage = 15,
				TracerName = "AirboatGunHeavyTracer",
				Dir = slasher:GetAimVector(),
				Src = slasher:GetPos() + Vector(0, 0, 60),
				IgnoreEntity = slasher,
				Spread = Vector(
					math.Rand(-1 - (spread * 35), 1 + (spread * 35)) * 0.001,
					math.Rand(-1 - (spread * 35), 1 + (spread * 35)) * 0.001,
					0
				)
			}, false)
		end)
	end

	local vec, ang = slasher:GetBonePosition(slasher:LookupBone("ValveBiped.weapon_bone"))
	local vPoint = vec
	local muzzle = EffectData()
	muzzle:SetOrigin(vPoint + slasher:GetForward() * 8 + Vector(0, 0, 2))
	muzzle:SetStart(Vector(255, 0, 0))
	muzzle:SetAttachment(0)
	muzzle:SetEntity(slasher)
	util.Effect("sid_muzzle", muzzle)

	local shell = EffectData()
	shell:SetOrigin(vPoint)
	shell:SetAngles(ang)
	util.Effect("ShellEject", shell)

	slasher.BulletSpread = 2
end

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher:GetNWBool("AmericanpoStun") then return end
	if slasher:GetNWBool("AmericanpoThrowingBottle") then return end

	-- SHOTGUN SHOTS
	if slasher.ShotgunCooldown < 0.01 then
		if slasher:GetNWBool("AmericanpoAiming") then
			slasher:SetNWBool("AmericanpoShooting", true)
			PlayBullets(slasher)
			slasher.ShotgunCooldown = 1

			timer.Simple(0.9, function()
				if not IsValid(slasher) then return end

				slasher:SetNWBool("AmericanpoShooting", false)
			end)

			return
		elseif slasher:GetNWBool("InSlasherChaseMode") or slasher:GetNWBool("AmericanpoFinal") then
			slasher:SetNWBool("AmericanpoShootingHip", true)
			PlayBullets(slasher)
			slasher.ShotgunCooldown = 2

			slasher:Freeze(true)
			timer.Simple(1.0, function()
				if not IsValid(slasher) then return end

				slasher:SetNWBool("AmericanpoShootingHip", false)
				slasher:Freeze(false)
			end)

			return
		end
	end

	-- BASE ATTACK
	if slasher.AttackCooldown > 0.01 then return end
	if slasher:GetNWBool("AmericanpoAim") then return end
	if slasher:GetNWBool("AmericanpoAiming") then return end
	if slasher:GetNWBool("AmericanpoFinal") then return end
	if slasher:GetNWBool("InSlasherChaseMode") then return end

	timer.Remove("AmericanpoAttackDecay")
	slasher.AttackCooldown = 3

	local idx = math.random(1, 2)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/vo/po_melee" .. idx .. ".mp3",
		identifier = "AmericanpoMelee" .. idx,
		minDistance = 200,
		maxDistance = 600,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(0.5, function()
		if not IsValid(slasher) then return end

		slasher:SetVelocity(slasher:GetForward() * 400)
	end)

	timer.Simple(1.0, function()
		if not IsValid(slasher) then return end

		slasher:LagCompensation(true)
		local tr = util.TraceHull({
			start = slasher:EyePos(),
			endpos = slasher:LocalToWorld(Vector(45, 0, 30)),
			maxs = Vector(40, 40, 60),
			mins = Vector(-40, -40, -60),
			filter = slasher,
			ignoreworld = true,
		})
		slasher:LagCompensation(false)

		local target = tr.Entity
		local damage = 20

		if target:IsValid() and (not target:IsPlayer() or target:Team() == TEAM_SURVIVOR) then
			local dmg = DamageInfo()
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(slasher)
			dmg:SetInflictor(slasher)
			dmg:SetDamage(damage)
			dmg:SetDamageForce(Vector(1, 1, 1))
			dmg:SetDamagePosition(tr.HitPos)
			target:TakeDamageInfo(dmg)

			if target:IsPlayer() and target:Team() == TEAM_SURVIVOR then
				target:AddSpeedEffect("poattack", 200, 2)
				timer.Simple(8, function()
					if not IsValid(target) then return end
					target:RemoveSpeedEffect("poattack")
				end)
			end

			local vPoint = target:GetPos()
			local bloodfx = EffectData()
			bloodfx:SetOrigin(vPoint)
			util.Effect("BloodImpact", bloodfx)

			local idx = math.random(1, 2)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/borgmire/borgmire_hit" .. idx .. ".mp3",
				identifier = "SurvivorHitPo" .. idx,
				minDistance = 600,
				maxDistance = 800,
				entity = target,
				volume = 1,
				fadeIn = 0,
			})
		end
	end)

	timer.Simple(0.05, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("AmericanpoAttack", true)

		timer.Create("AmericanpoAttackDecay", 1.0, 1, function()
			if not IsValid(slasher) then return end

			slasher:SetNWBool("AmericanpoAttack", false)
		end)
	end)
end

local function AimShotgun(slasher)
	if not slasher:GetNWBool("AmericanpoAim") and not slasher:GetNWBool("AmericanpoAiming") and slasher.ShotgunCooldown < 0.01 then
		if slasher.AmericanpoState == AMERICANPO_HUNTER then
			local idx = math.random(1, 4)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/americanpo/vo/po_aimstealth" .. idx .. ".mp3",
				identifier = "AmericanpoAimStealth" .. idx,
				minDistance = 400,
				maxDistance = 700,
				entity = slasher,
				volume = 0.7,
				fadeIn = 0,
			})
		else
			local idxx = math.random(1, 4)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/americanpo/vo/po_aim" .. idxx .. ".mp3",
				identifier = "AmericanpoAim" .. idxx,
				minDistance = 400,
				maxDistance = 700,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})
		end

		slasher:SetNWBool("AmericanpoAim", true)
		slasher.ShotgunCooldown = 1.5

		timer.Simple(0.7, function()
			if not IsValid(slasher) then return end

			slasher:SetNWBool("AmericanpoAim", false)
			slasher:SetNWBool("AmericanpoAiming", true)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/sid/sid_clipout.mp3",
				identifier = "AmericanpoClipout",
				minDistance = 400,
				maxDistance = 700,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})

			slasher.BulletSpread = 2
		end)
	elseif slasher:GetNWBool("AmericanpoAiming") and slasher.ShotgunCooldown < 0.01 then
		slasher:SetNWBool("AmericanpoAiming", false)
		slasher.ShotgunCooldown = 1.5
	end
end

function SLASHER.OnSecondaryFire(slasher)
	if slasher:GetNWBool("AmericanpoThrowingBottle") then return end
	if slasher:GetNWBool("AmericanpoAim") then return end
	if slasher:GetNWBool("AmericanpoAttack") then return end
	if slasher:GetNWBool("AmericanpoStun") then return end
	if slasher:GetNWBool("AmericanpoFinal") then return end

	if slasher.AmericanpoState == AMERICANPO_HUNTER then
		AimShotgun(slasher)
	else
		SlashCo.StartChaseMode(slasher)
		slasher.ShotgunCooldown = 1.5
	end
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher.AmericanpoState == AMERICANPO_HUNTER then return end
	if slasher.BottleCooldown > 0.01 then return end
	if slasher:GetNWBool("AmericanpoStun") then return end
	if slasher:GetNWBool("AmericanpoAim") then return end
	if slasher:GetNWBool("AmericanpoAttack") then return end

	slasher:SetNWBool("AmericanpoThrowingBottle", true)
	slasher.BottleCooldown = 15

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/po_throwbottle.mp3",
		identifier = "AmericanpoThrowBottle",
		minDistance = 400,
		maxDistance = 800,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	local idx = math.random(1, 4)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/vo/po_bottlethrow" .. idx .. ".mp3",
		identifier = "AmericanpoThrowBottleVO" .. idx,
		minDistance = 400,
		maxDistance = 800,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(1.2, function()
		if not IsValid(slasher) then return end

		local vec = slasher:GetPos()
		local ang = slasher:LocalToWorldAngles(Angle(0, 0, 0))
		local pos = vec
		local bottle = ents.Create("sc_americanbottle")

		bottle:SetPos(pos + slasher:GetForward() * 7 + Vector(0, 0, 60))
		bottle:SetAngles(ang)
		bottle:Spawn()
		bottle:Activate()
		bottle:SetBottleVelocity(slasher:GetAimVector() * 1000)
	end)

	timer.Simple(1.7, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("AmericanpoThrowingBottle", false)
	end)
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if slasher.AmericanpoStateCooldown > 0.01 then return end
	if slasher:GetNWBool("InSlasherChaseMode") then return end
	if slasher:GetNWBool("AmericanpoAim") then return end
	if slasher:GetNWBool("AmericanpoAiming") then return end
	if slasher:GetNWBool("AmericanpoThrowingBottle") then return end
	if slasher:GetNWBool("AmericanpoStun") then return end
	if slasher:GetNWBool("AmericanpoAttack") then return end
	if slasher:GetNWBool("AmericanpoFinal") then return end

	slasher.AmericanpoStateCooldown = 10

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/po_statechange.mp3",
		identifier = "AmericanpoChangeState",
		minDistance = 200,
		maxDistance = 400,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	if slasher.AmericanpoState == AMERICANPO_HUNTER then
		slasher.AmericanpoState = AMERICANPO_AGGRO
	else
		slasher.AmericanpoState = AMERICANPO_HUNTER
	end
end

function SLASHER.OnKillPlayer(slasher, target)
	local idx = math.random(1, 5)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/vo/po_kill" .. idx .. ".mp3",
		identifier = "AmericanpoKill" .. idx,
		minDistance = 200,
		maxDistance = 600,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
end

function SLASHER.OnHitByPocketSand(slasher, ply)
	SlashCo.StopChase(slasher)

	local idx = math.random(1, 4)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/americanpo/vo/po_stun" .. idx .. ".mp3",
		identifier = "AmericanpoStun" .. idx,
		minDistance = 200,
		maxDistance = 600,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	slasher:SetNWBool("AmericanpoThrowingBottle", false)
	slasher:SetNWBool("AmericanpoAim", false)
	slasher:SetNWBool("AmericanpoAiming", false)
	slasher:SetNWBool("AmericanpoShooting", false)
	slasher:SetNWBool("AmericanpoAttack", false)

	slasher:SetNWBool("AmericanpoStun", true)
	slasher:Freeze(true)

	timer.Simple(4.5, function()
		if not IsValid(slasher) then return end

		PlayBullets(slasher)
	end)

	timer.Simple(14, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("AmericanpoStun", false)
		slasher:Freeze(false)
	end)
end
SLASHER.OnHitByBeerKeg = SLASHER.OnHitByPocketSand
SLASHER.OnHitByTeslaCoil = SLASHER.OnHitByPocketSand

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("AmericanpoStun")
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode") or ply:GetNWBool("AmericanpoFinal")
	local aim_start = ply:GetNWBool("AmericanpoAim")
	local aim_loop = ply:GetNWBool("AmericanpoAiming")
	local shooting = ply:GetNWBool("AmericanpoShooting")
	local hipfire = ply:GetNWBool("AmericanpoShootingHip")
	local attack = ply:GetNWBool("AmericanpoAttack")
	local throw_bottle = ply:GetNWBool("AmericanpoThrowingBottle")
	local stunned = ply:GetNWBool("AmericanpoStun")
	local hunter = ply:GetNWInt("AmericanpoState") == 0

	if not aim_start and not aim_loop and not shooting and not hipfire and not throw_bottle and not attack and not stunned then
		ply.anim_antispam = false
	end

	ply:SetPoseParameter("move_x", ply:GetVelocity():Length() / 100)

	if not aim_start and not aim_loop then
		if hunter then
			if ply:IsOnGround() then
				if ply:GetVelocity():Length() < 30 then
					ply.CalcIdeal = ACT_IDLE
					ply.CalcSeqOverride = ply:LookupSequence("cg_stealthidle")
				else
					ply.CalcIdeal = ACT_HL2MP_WALK
					ply.CalcSeqOverride = ply:LookupSequence("cg_stealthwalk")
				end
			else
				ply.CalcSeqOverride = ply:LookupSequence("float")
			end
		else
			if ply:IsOnGround() then
				if ply:GetVelocity():Length() < 30 then
					ply.CalcIdeal = ACT_IDLE
					ply.CalcSeqOverride = ply:LookupSequence("idle")
				else
					if not chase then
						ply.CalcIdeal = ACT_HL2MP_WALK
						ply.CalcSeqOverride = ply:LookupSequence("walk")
					else
						ply.CalcIdeal = ACT_HL2MP_RUN
						ply.CalcSeqOverride = ply:LookupSequence("chase")
					end
				end
			else
				ply.CalcSeqOverride = ply:LookupSequence("float")
			end
		end
	end

	if hipfire then
		ply.CalcSeqOverride = ply:LookupSequence("hipfire")
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if aim_start then
		ply.CalcSeqOverride = ply:LookupSequence("readygun")
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if aim_loop then
		if not shooting then
			ply.CalcSeqOverride = ply:LookupSequence("readyidle")
		else
			ply.CalcSeqOverride = ply:LookupSequence("shoot")
			if not ply.anim_antispam then
				ply:SetCycle(0)
				ply.anim_antispam = true
			end
		end
	end

	if attack and (not ply.anim_antispam) then
		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("cg_meleeattack"), 0, true)
		ply.anim_antispam = true
	end

	if throw_bottle and (not ply.anim_antispam) then
		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("bottlethrow_quick"), 0, true)
		ply.anim_antispam = true
	end

	if stunned then
		ply.CalcSeqOverride = ply:LookupSequence("stun_1")
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 2)
		local hunter = ply:GetNWInt("AmericanpoState") == 0

		if not hunter then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/screamer/screamer_step" .. idx .. ".mp3",
				identifier = "AmericanpoFootstep" .. idx,
				group = "SlasherFootstep",
				minDistance = 200,
				maxDistance = 400,
				entity = ply,
				volume = 1,
				fadeIn = 0,
			})
		else
			if ply.PoStepTick == nil or ply.PoStepTick > 1 then
				ply.PoStepTick = 0
			end

			if ply.PoStepTick == 0 then
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/screamer/screamer_step" .. idx .. ".mp3",
					identifier = "AmericanpoFootstep" .. idx,
					group = "SlasherFootstep",
					minDistance = 200,
					maxDistance = 400,
					entity = ply,
					volume = 0.3,
					fadeIn = 0,
				})
			end

			ply.PoStepTick = ply.PoStepTick + 1
		end
	end

	return true
end

local mat = Material("lights/white")
local function targetPaint(ply)
	if not IsValid(ply) or not ply:CanBeSeen() then return end

	cam.Start3D()
	render.MaterialOverride(mat)
	render.SetColorModulation(1, 0, 0)

	ply:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride("")
	cam.End3D()
end

local chaseTable = {
	["start chasing"] = Material("slashco/ui/icons/slasher/chase"),
	["stop chasing"] = Material("slashco/ui/icons/slasher/chase"),
	["aim"] = Material("slashco/ui/icons/slasher/americanpo_shotgun")
}
local shootTable = {
	["punch"] = Material("slashco/ui/icons/slasher/punch"),
	["shoot"] = Material("slashco/ui/icons/slasher/americanpo_shotgun")
}
local stateTable = {
	hunter = Material("slashco/ui/icons/slasher/americanpo_hunter"),
	aggressive = Material("slashco/ui/icons/slasher/americanpo_aggro")
}

function SLASHER.InitHud(_, hud)
	hud:SetTitle("Americanpo")
	hud:SetAvatar(Material("slashco/ui/icons/slasher/americanpo"))

	hud:AddControl("LMB", "punch", shootTable)
	hud:AddControl("RMB", "aim", chaseTable)
	hud:AddControl("R", "throw bottle", Material("slashco/ui/icons/slasher/americanpo_bottle"))
	hud:AddControl("F", "switch mode", stateTable)

	hud:SetCrosshairEnabled(true)
	hud:SetCrosshairAlpha(255)
	hud:TieCrosshair("AmericanpoAiming")

	function hud.TitleCard.Label:PaintOver()
		local curState = GameData.LocalPlayer:GetNWInt("AmericanpoState")
		if curState == 0 then
			draw.SimpleText("MODE: HUNTER", "TVCD", 4, 18, red)
		else
			draw.SimpleText("MODE: AGGRESSIVE", "TVCD", 4, 18, red)
		end
	end

	function hud.AlsoThink()
		local curState = GameData.LocalPlayer:GetNWInt("AmericanpoState")
		local final = GameData.LocalPlayer:GetNWBool("AmericanpoFinal")
		local stateIcon = "hunter"

		if curState == 0 then
			hud:SetControlVisible("R", false)
			hud:SetControlText("RMB", "aim")
			hud:TieControlText("LMB", "AmericanpoAiming", "shoot", "punch", true)
			stateIcon = "hunter"
		else
			hud:SetControlVisible("R", true)
			hud:TieControlText("RMB", "InSlasherChaseMode", "stop chasing", "start chasing", true)
			stateIcon = "aggressive"

			if not final then
				hud:TieControlText("LMB", "InSlasherChaseMode", "shoot", "punch", true)
			else
				hud:SetControlText("LMB", "shoot")
				hud:SetControlVisible("F", false)
				hud:SetControlVisible("RMB", false)
			end
		end

		hud:SetControlIcon("F", stateIcon)
	end
end

function SLASHER.DrawHUD(localPly)
	for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if not survivor:GetNWBool("SurvivorFueled") then
			continue
		end

		if not survivor:CanBeSeen() then
			continue
		end

		targetPaint(survivor)
	end
end)

if CLIENT then
	hook.Add("Tick", "PoLight", function()
		for _, po in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if po == GameData.LocalPlayer then return end

			if SlashCoSlashers[po:GetNWString("Slasher")] == SLASHER then
				if po:GetNWBool("AmericanpoFinal") then
					local tlight = DynamicLight(MAX_EDICT + po:EntIndex())
					if tlight then
						tlight.pos = po:LocalToWorld(Vector(0, 0, 20))
						tlight.r = 255
						tlight.g = 0
						tlight.b = 0
						tlight.brightness = 6
						tlight.Decay = 1000
						tlight.Size = 250
						tlight.DieTime = CurTime() + 1
					end
				end
			end
		end
	end)
end

local function SidIsHere()
    for _, s in ipairs(team.GetPlayers(TEAM_SLASHER)) do
        if s:GetNWString("Slasher") == "Sid" then return true end
    end
    return false
end
local function ScreamerIsHere()
    for _, s in ipairs(team.GetPlayers(TEAM_SLASHER)) do
        if s:GetNWString("Slasher") == "Screamer" then return true end
    end
    return false
end

hook.Add("SlashCo:OnPing", "AmericanPoSpecialInteraction", function(pingInfo)
	if pingInfo.Team ~= TEAM_SLASHER then return end
	if not pingInfo.Player then return end
	if CLIENT then return end

	local ply = pingInfo.Player

	if isnumber(ply) then
		ply = Entity(ply)
	end

	if not IsValid(ply) then return end

	if ply:GetNWString("Slasher") ~= "Americanpo" then return end

	if pingInfo.Type == "SLASHER" then
		if SidIsHere() then
			local idx = math.random(1, 5)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/americanpo/vo/po&sid" .. idx .. ".mp3",
				identifier = "PoSidTalk" .. idx,
				minDistance = 700,
				maxDistance = 1200,
				entity = ply,
				volume = 1.0,
				fadeIn = 0,
			})
		elseif ScreamerIsHere() then
			local idx = math.random(1, 8)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/americanpo/vo/po&screamer" .. idx .. ".mp3",
				identifier = "PoTinkyTalk" .. idx,
				minDistance = 700,
				maxDistance = 1200,
				entity = ply,
				volume = 1.0,
				fadeIn = 0,
			})
		end
	end

	return true
end)

SlashCo.RegisterSlasher(SLASHER, "Americanpo")