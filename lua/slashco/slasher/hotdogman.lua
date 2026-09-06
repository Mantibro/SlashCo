local SLASHER = {}

SLASHER.Name = "Hotdogman"
SLASHER.Aliases = {
	"Glizzyman",
	"YOU ARE WHAT YOU EAT",
}

SLASHER.Class = SlashCo.SlasherClass.Demon
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/hotdogman/glizzyman_v1.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 0
SLASHER.ProwlSpeed = 170
SLASHER.ChaseSpeed = 295
SLASHER.Perception = 0.8
SLASHER.Eyesight = 6
SLASHER.KillDistance = 0
SLASHER.ChaseRange = 1200
SLASHER.ChaseRadius = 0.90
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 0
SLASHER.ChaseMusic = "slashco/slasher/hotdogman/hdm_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Hotdogman_desc"
SLASHER.ProTip = "Hotdogman_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★★☆"
SLASHER.DiffRating = "★☆☆☆☆"
SLASHER.ItemToSpawn = "Hotdog"

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	if additionalSurvivors > 0 then
		SLASHER.ProwlSpeed = 170 + (3 * additionalSurvivors)
		SLASHER.ChaseSpeed = 295 + (0.5 * additionalSurvivors)
	end
end

local function PlayNausea(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/hotdogman/hdm_nausea.mp3",
		identifier = "HotdogmanNausea",
		minDistance = 105,
		maxDistance = 335,
		looping = true,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
end

local function StopNausea(slasher)
	SlashCo.AudioSystem.StopSound("HotdogmanNausea", 1, slasher)
end

local function PlayFall(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/hotdogman/hdm_fall.mp3",
		identifier = "HotdogmanFall",
		minDistance = 400,
		maxDistance = 800,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
end

function SLASHER.OnSpawn(slasher)
	slasher:SetNWBool("HotdoginHand", false)
	slasher:SetNWBool("CanChase", true)

	slasher.EatedHotdogs = 0
	slasher.PunchCooldown = 0
	slasher.LeapCooldown = 0
	slasher.VomitCooldown = 0
end

local slasher_viewoffset = Vector(0, 0, 80)
function SLASHER.OnTickBehaviour(slasher)
	local Hotdogs = math.Clamp(slasher.EatedHotdogs, 0, 3) --Hotdogs Eaten
	slasher.EatedHotdogs = Hotdogs
	local PunchCD = slasher.PunchCooldown or 0 -- Main attack cooldown
	local LeapCD = slasher.LeapCooldown or 0 -- Main attack cooldown
	local VomitCD = slasher.VomitCooldown or 0 -- Special ability cooldown

	if PunchCD > 0 then
		slasher.PunchCooldown = PunchCD - FrameTime()
	end

	if LeapCD > 0 then
		slasher.LeapCooldown = LeapCD - FrameTime()
	end

	if VomitCD > 0 then
		slasher.VomitCooldown = VomitCD - FrameTime()
	end

	if slasher:GetNWBool("HotdogLeaping") then
		if slasher:IsOnGround() then
			slasher:SetNWBool("HotdogLeap", false)
			slasher:SetNWBool("HotdogLeaping", false)
			slasher:SetNWBool("LeapFall", true)

			local vPoint = slasher:GetPos()
			local dust = EffectData()
			dust:SetOrigin(vPoint)
			dust:SetScale(100)
			dust:SetEntity(slasher)
			util.Effect("ThumperDust", dust)

			PlayFall(slasher)

			local find = ents.FindInSphere(slasher:GetPos(), 400)
			for i = 1, #find do
				local ent = find[i]

				if ent:IsPlayer() and ent ~= slasher and ent:Team() == TEAM_SURVIVOR then
					timer.Simple(0.1, function()
						if not IsValid(slasher) then return end
						if not IsValid(ent) then return end

						ent:TakeDamage(20, slasher, slasher)
					end)
				end
			end

			timer.Simple(3.0, function()
				if not IsValid(slasher) then return end

				slasher:SetNWBool("LeapFall", false)
				slasher:Freeze(false)
			end)
		end
	end

	if slasher:GetNWBool("HotdoginHand") then
		slasher:SetBodygroup(1, 1)
	else
		slasher:SetBodygroup(1, 0)
	end

	if slasher.EatedHotdogs >= 1 then
		PlayNausea(slasher)
	else
		StopNausea(slasher)
	end

	local find2 = ents.FindInSphere(slasher:GetPos(), 120)
	for f = 1, #find2 do
		local ent = find2[f]

		if ent:GetClass() == "sc_hotdog" then
			if slasher:GetNWBool("HotdoginHand") then return end

			ent:Remove()
			slasher:SetNWBool("HotdoginHand", true)
		end
	end

	if slasher:GetNWInt("VomitAmount") ~= Hotdogs then
		slasher:SetNWInt("VomitAmount", Hotdogs)
	end

	slasher:SetViewOffset(slasher_viewoffset)
	slasher:SetCurrentViewOffset(slasher_viewoffset)
	slasher:SetEyeSight(SLASHER.Eyesight)
	slasher:SetPerception(SLASHER.Perception)
end

local function EatHotdog(slasher)
	SlashCo.StopChase(slasher)
	slasher:SetNWBool("HotdogEating", true)
	slasher:Freeze(true)

	local rand = math.random()
	timer.Simple(1, function()
		if not IsValid(slasher) then return end

		local idx = math.random(2, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "npc/barnacle/barnacle_crunch" .. idx .. ".wav",
			identifier = "HotdogmanEating1" .. idx,
			minDistance = 200,
			maxDistance = 600,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end)

	timer.Simple(4, function()
		if not IsValid(slasher) then return end

		local idx = math.random(1, 2)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "npc/barnacle/barnacle_gulp" .. idx .. ".wav",
			identifier = "HotdogmanEating2" .. idx,
			minDistance = 200,
			maxDistance = 600,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end)

	timer.Simple(5, function()
		if not IsValid(slasher) then return end

		local idx = math.random(1, 2)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "npc/barnacle/barnacle_digesting" .. idx .. ".wav",
			identifier = "HotdogmanEating3" .. idx,
			minDistance = 200,
			maxDistance = 600,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end)

	timer.Simple(6, function()
		if not IsValid(slasher) then return end

		slasher:Freeze(false)
		slasher:SetNWBool("HotdoginHand", false)
		slasher:SetNWBool("HotdogEating", false)
		slasher.EatedHotdogs = slasher.EatedHotdogs + 1
	end)
end

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher:GetNWBool("HotdoginHand") then return end
	if slasher.PunchCooldown > 0.01 then return end

	slasher:SetNWBool("HotdogPunch", false)
	timer.Remove("HotdogPunchDelay")
	slasher.PunchCooldown = 1.5

	timer.Simple(0.3, function()
		if not IsValid(slasher) then return end

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/trollge/trollge_swing.mp3",
			identifier = "HDMSwing",
			minDistance = 600,
			maxDistance = 800,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})

		slasher:LagCompensation(true)
		local tr = util.TraceHull({
			start = slasher:EyePos(),
			endpos = slasher:LocalToWorld(Vector(50, 0, 50)),
			maxs = Vector(35, 45, 60),
			mins = Vector(-35, -45, -60),
			filter = slasher,
			ignoreworld = true,
		})
		slasher:LagCompensation(false)

		local target = tr.Entity
		if target:IsValid() and (not target:IsPlayer() or target:Team() == TEAM_SURVIVOR) then
			local dmg = DamageInfo()
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(slasher)
			dmg:SetInflictor(slasher)
			dmg:SetDamage(40)
			dmg:SetDamageForce(Vector(1, 1, 1))
			dmg:SetDamagePosition(tr.HitPos)
			target:TakeDamageInfo(dmg)
		end

		if not target:IsValid() then return end

		if (target:IsPlayer() and target:Team() == TEAM_SURVIVOR) or target:GetClass() == "prop_ragdoll" then
			local o = Vector(0, 0, 0)

			if (target:IsPlayer() and target:Team() == TEAM_SURVIVOR) then
				o = Vector(0, 0, 50)
			end

			local vPoint = target:GetPos() + o
			local bloodfx = EffectData()
			bloodfx:SetOrigin(vPoint)
			util.Effect("BloodImpact", bloodfx)

			local idx = math.random(1, 2)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/borgmire/borgmire_hit" .. idx .. ".mp3",
				identifier = "SurvivorHitHotdog" .. idx,
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

		slasher:SetNWBool("HotdogPunch", true)

		timer.Create("HotdogPunchDelay", 1.5, 1, function()
			if not IsValid(slasher) then return end

			slasher:SetNWBool("HotdogPunch", false)
		end)
	end)
end

function SLASHER.OnSecondaryFire(slasher)
	if slasher:GetNWBool("HotdoginHand") then return end
	if slasher:GetNWBool("HotdogLeap") then return end

	if slasher:GetNWBool("InSlasherChaseMode") then
		if slasher.LeapCooldown > 0.01 then return end

		slasher:SetNWBool("HotdogLeap", false)
		slasher:SetNWBool("HotdogLeaping", false)
		timer.Remove("HotdogLeapDelay")
		slasher.LeapCooldown = 7

		timer.Simple(0.1, function()
			if not IsValid(slasher) then return end

			slasher:SetNWBool("HotdogLeap", true)
			slasher:SetVelocity((slasher:EyeAngles():Forward() * 300) + Vector(0, 0, 300))
		end)

		timer.Simple(0.7, function()
			if not IsValid(slasher) then return end
			if slasher:IsOnGround() then
				slasher:SetNWBool("HotdogLeap", false)
				return
			end

			slasher:Freeze(true)
			slasher:SetNWBool("HotdogLeaping", true)
		end)

		return
	end

	SlashCo.StartChaseMode(slasher)
	slasher.LeapCooldown = 5
end

function SLASHER.OnMainAbilityFire(slasher)
	if not slasher:GetNWBool("HotdoginHand") then return end
	if slasher:GetNWBool("HotdogEating") then return end

	EatHotdog(slasher)
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if slasher:GetNWBool("HotdoginHand") then return end
	if slasher:GetNWBool("HotdogLeap") then return end
	if slasher.VomitCooldown > 0.01 then return end
	if slasher.EatedHotdogs < 1 then return end

	SlashCo.StopChase(slasher)
	slasher:SetNWBool("HotdogVomiting", true)
	slasher:Freeze(true)
	slasher.VomitCooldown = 15
	slasher.EatedHotdogs = slasher.EatedHotdogs - 1

	timer.Simple(1.7, function()
		if not IsValid(slasher) then return end

		local matrix = slasher:GetBoneMatrix(slasher:LookupBone("Mouth"))
		local pos = matrix:GetTranslation()
		local ang = matrix:GetAngles()

		local vPoint = pos
		local vomit = EffectData()
		vomit:SetOrigin(vPoint)
		vomit:SetScale(100)
		vomit:SetEntity(slasher)
		util.Effect("antlion_gib_02", vomit)
		SlashCo.CreateItem("sc_vomit", slasher:GetPos(), Angle(0, 0, 0))

		local vomitEffect = ents.Create("grenade_spit")
		local trail = util.SpriteTrail(vomitEffect, 0, colortrail, false, 10, 60, 1, .0072, "trails/plasma.vmt")
		vomitEffect:SetModel("models/spitball_large.mdl")
		vomitEffect:SetPos(pos)
		vomitEffect:SetAngles(ang)
		vomitEffect:Spawn()
	end)

	timer.Simple(4.5, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("HotdogVomiting", false)
		slasher:Freeze(false)
	end)
end

function SLASHER.OnHitByPocketSand(slasher, ply)
	SlashCo.StopChase(slasher)

	slasher:SetNWBool("HotdogStun", true)
	slasher:Freeze(true)
	timer.Simple(9, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("HotdogStun", false)
		slasher:Freeze(false)
	end)
end
SLASHER.OnHitByBeerKeg = SLASHER.OnHitByPocketSand
SLASHER.OnHitByTeslaCoil = SLASHER.OnHitByPocketSand

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("HotdogVomiting") or ply:GetNWBool("HotdogEating") or ply:GetNWBool("HotdogStun") or ply:GetNWBool("LeapFall")
end

function SLASHER.Animator(ply)
	local punch = ply:GetNWBool("HotdogPunch")
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local holdingFood = ply:GetNWBool("HotdoginHand")
	local eatingFood = ply:GetNWBool("HotdogEating")
	local vomitingFood = ply:GetNWBool("HotdogVomiting")
	local leapStart = ply:GetNWBool("HotdogLeap")
	local leapFall = ply:GetNWBool("LeapFall")
	local stunLoop = ply:GetNWBool("HotdogStun")

	if not punch and not eatingFood and not vomitingFood and not leapStart and not leapFall then
		ply.anim_antispam = false
	end

	if ply:IsOnGround() then
		if not chase then
			if not holdingFood then
				ply.CalcIdeal = ACT_HL2MP_WALK
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			else
				ply.CalcIdeal = ACT_HL2MP_WALK
				ply.CalcSeqOverride = ply:LookupSequence("prowl_W_hotdog")
			end
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("run")
		end
	else
		if not holdingFood then
			if not leapStart then
				ply.CalcSeqOverride = ply:LookupSequence("float1")
			else
				ply.CalcSeqOverride = ply:LookupSequence("float2")
			end
		else
			ply.CalcSeqOverride = ply:LookupSequence("float1_W_hotdog")
		end
	end

	ply:SetPoseParameter("move_x", ply:GetVelocity():Length() / 100)

	if ply:GetVelocity():Length() < 30 then
		if not holdingFood then
			ply.CalcIdeal = ACT_IDLE
			ply.CalcSeqOverride = ply:LookupSequence("idle")
		else
			ply.CalcIdeal = ACT_IDLE
			ply.CalcSeqOverride = ply:LookupSequence("idle_W_hotdog")
		end
	end

	if punch and (ply.anim_antispam == nil or ply.anim_antispam == false) then
		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("swing"), 0, true)
		ply.anim_antispam = true
	end

	if eatingFood then
		ply.CalcSeqOverride = ply:LookupSequence("eat")

		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if vomitingFood then
		ply.CalcSeqOverride = ply:LookupSequence("special_attack")

		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if leapFall then
		ply.CalcSeqOverride = ply:LookupSequence("land")

		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if stunLoop then
		ply.CalcSeqOverride = ply:LookupSequence("stun_loop")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 4)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/hotdogman/hdm_step" .. idx .. ".mp3",
			identifier = "HDMFootstep" .. idx,
			group = "SlasherFootstep",
			minDistance = 300,
			maxDistance = 600,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end

	return true
end

local chaseTable = {
	default = Material("slashco/ui/icons/slasher/chase"),
	["leap"] = Material("slashco/ui/icons/slasher/hotdogman_leap"),
	["d/leap"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetTitle("Hotdogman")
	hud:SetAvatar(Material("slashco/ui/icons/slasher/hotdogman"))

	hud:AddControl("LMB", "punch", Material("slashco/ui/icons/slasher/punch"))
	hud:ChaseAndKill(nil, true)
	hud:TieControlText("RMB", "InSlasherChaseMode", "leap", "start chasing", true)

	hud:AddControl("R", "find hotdog", Material("slashco/ui/icons/slasher/hotdogman_hotdog"))
	hud:TieControlText("R", "HotdoginHand", "eat hotdog", "find hotdog", true)

	hud:AddControl("F", "vomit", Material("slashco/ui/icons/slasher/hotdogman_vomit"))

	hud:AddMeter("nausea", 3, "", nil, true)
	hud:TieMeterInt("nausea", "VomitAmount", true)

	hook.Add("SlashCo:DrawHUD", "SlashCo:SlasherHUD", function()
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			hook.Remove("SlashCo:DrawHUD", "SlashCo:SlasherHUD")
			return
		end

		if GameData.LocalPlayer:GetNWBool("HotdoginHand") then
			draw.SimpleText("EAT THE HOTDOG! ! !", "ItemFontTip", ScrW() / 2, ScrH() / 4,
					Color(255, 0, 0, 255),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end)

	function hud.AlsoThink()
		local hotdog = GameData.LocalPlayer:GetNWBool("HotdoginHand")
		local vomit = GameData.LocalPlayer:GetNWInt("VomitAmount")

		if vomit ~= 0 then
			hud:ShakeControl("F")
		end

		if not hotdog then
			hud:SetControlEnabled("LMB", true)
			hud:SetControlEnabled("RMB", true)
			hud:SetControlEnabled("F", true)
		else
			hud:SetControlEnabled("LMB", false)
			hud:SetControlEnabled("RMB", false)
			hud:SetControlEnabled("F", false)
		end
	end
end

function SLASHER.PreDrawHalos()
	SlashCo.DrawHalo(ents.FindByClass("sc_hotdog"), nil, 2, false)
	
	local plyWithItem = {}
	for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if v:HasItem("Hotdog") then
			table.insert(plyWithItem, v)
		end
	end

	SlashCo.DrawHalo(plyWithItem, nil, 2, false)
end

SlashCo.RegisterSlasher(SLASHER, "Hotdogman")