local SLASHER = {}

SLASHER.Name = "Hoovydundy"
SLASHER.Aliases = {
	"Heavy Weapons Guy",
	"The Hated",
	"The Friendly",
	"HOOVYDUNDE",
}
SLASHER.ID = 27
SLASHER.Class = SlashCo.SlasherClass.Umbra
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = false
SLASHER.Model = "models/slashco/slashers/hoovy/hoovy.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 250
SLASHER.Perception = 1.0
SLASHER.Eyesight = 4
SLASHER.KillDistance = 160
SLASHER.ChaseRange = 1500
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10
SLASHER.ChaseCooldown = 5
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/hoovydundy/chase.mp3"
SLASHER.KillSound = "slashco/slasher/hoovydundy/kill.mp3"
SLASHER.Description = "Hoovydundy_desc"
SLASHER.ProTip = "Hoovydundy_tip"
SLASHER.SpeedRating = "★☆☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★☆☆"
SLASHER.DisableHelicopterMusic = true

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	if additionalSurvivors > 0 then
		SLASHER.ProwlSpeed = 125 + (2 * additionalSurvivors)
		SLASHER.ChaseSpeed = 250 + (2 * additionalSurvivors)
	end
end

local function HoovyIdle(slasher)
	if not slasher:GetNWBool("InSlasherChaseMode") then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/hoovydundy/idle_" .. idx .. ".mp3",
			identifier = "HoovydundyIdle" .. idx,
			minDistance = 300,
			maxDistance = 1250,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end

	timer.Simple(math.random(10, 20), function()
		HoovyIdle(slasher)
	end)
end

local function PlayPanicMusic(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/hoovydundy/survivorgrabbed.mp3",
		identifier = "HoovydundyGrabMusic",
		minDistance = 700 * SlashCo.MapSize,
		maxDistance = 1240 * SlashCo.MapSize,
		looping = true,
		entity = slasher,
		volume = 0.8,
		fadeIn = 0,
	})
end

local function StopPanicMusic(slasher)
	SlashCo.AudioSystem.StopSound("HoovydundyGrabMusic", 0.5, slasher)
end

function SLASHER.OnSpawn(slasher)
	HoovyIdle(slasher)
	slasher:SetNWBool("CanKill", true)

	slasher.GeneratorBlockCooldown = 0
	slasher.GeneratorBlockUses = 0
	slasher.GeneratorBlockDuration = 30
	slasher.RopeCooldown = 0
	slasher.RopeDuration = 5
end

function SLASHER.OnTickBehaviour(slasher)
	local GenCD = slasher.GeneratorBlockCooldown or 0 -- Generator Block Cooldown
	local GenUses = slasher.GeneratorBlockUses or 0 -- Generator Block Cooldown Increase
	local GenBlocked = slasher.GeneratorBlockDuration or 0 -- Generator Block Duration
	local RopeCD = slasher.RopeCooldown or 0 -- Rope Grab Cooldown
	local RopeTime = slasher.RopeDuration or 0 -- Rope Grab Duration
	local prowl_final = SLASHER.ProwlSpeed
	local chase_final = SLASHER.ChaseSpeed

	if GenCD > 0 then
		slasher.GeneratorBlockCooldown = GenCD - FrameTime()
	end
	if RopeCD > 0 then
		slasher.RopeCooldown = RopeCD - FrameTime()
	end

	if SlashCo.CurRound.GameProgress > 3 then
		slasher:SetNWBool("HoovyCanBlock", true)
		prowl_final = 200
		chase_final = 280
	end

	if SlashCo.CurRound.GameProgress > 4 then
		GenBlocked = 40
		RopeTime = 6.5
	elseif SlashCo.CurRound.GameProgress > 5 then
		GenBlocked = 50
		RopeTime = 8
	elseif SlashCo.CurRound.GameProgress > 6 then
		GenBlocked = 60
		RopeTime = 9.5
	end

	if IsValid(slasher.SurvivorRoped) then
		slasher.SurvivorRoped.RopeStruggle = 0

		slasher:SetRunSpeed(100)
		slasher:SetWalkSpeed(100)
		slasher:SetSlowWalkSpeed(100)

		if not slasher.SurvivorRoped:IsFrozen() then
			slasher.SurvivorRoped:Freeze(true)
		end

		if slasher.SurvivorRoped.RopeStruggle ~= nil and slasher.SurvivorRoped.RopeStruggle > 25 then
			slasher.SurvivorRoped.RopeStruggle = 0
			slasher.SurvivorRoped:Freeze(false)
			slasher.SurvivorRoped:SetNWBool("SurvivorGrabbed", false)
			slasher.SurvivorRoped = nil
			StopPanicMusic(slasher)

			slasher:Freeze(true)
			slasher:SetNWBool("HoovyGrabLoop", false)
			slasher:SetNWBool("HoovyStunned", true)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/hoovydundy/rope_escape.mp3",
				identifier = "HoovydundyRopeEscape",
				minDistance = 200,
				maxDistance = 900,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})

			timer.Simple(3, function()
				if not IsValid(slasher) then return end

				slasher:Freeze(false)
				slasher:SetNWBool("HoovyStunned", false)
				slasher:SetNWBool("CanChase", true)
			end)
		end

		timer.Simple(RopeTime, function()
			if not IsValid(slasher.SurvivorRoped) then return end

			slasher:SetNWBool("CanChase", true)
			slasher:SetNWBool("HoovyGrabLoop", false)
			slasher.SurvivorRoped:SetNWBool("SurvivorGrabbed", false)
			slasher.SurvivorRoped:Freeze(false)
			slasher.SurvivorRoped.RopeStruggle = 0
			slasher.SurvivorRoped = nil
			StopPanicMusic(slasher)
		end)
	else
		if not slasher:GetNWBool("InSlasherChaseMode") then
			slasher:SetRunSpeed(prowl_final)
			slasher:SetWalkSpeed(prowl_final)
			slasher:SetSlowWalkSpeed(prowl_final)
		else
			slasher:SetRunSpeed(chase_final)
			slasher:SetWalkSpeed(chase_final)
			slasher:SetSlowWalkSpeed(chase_final)
		end

		slasher:SetNWBool("CanChase", true)
		slasher.SurvivorRoped = nil
	end

	if slasher:GetNWInt("RopeCooldown") ~= math.floor(RopeCD) then
		slasher:SetNWInt("RopeCooldown", math.floor(RopeCD))
	end

	if slasher:GetNWInt("GenBlockCooldown") ~= math.floor(GenCD) then
		slasher:SetNWInt("GenBlockCooldown", math.floor(GenCD))
	end

	slasher:SetEyeSight(SLASHER.Eyesight)
	slasher:SetPerception(SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher:GetNWBool("HoovyStunned") then return end
	if slasher:GetNWBool("HoovyGrabStart") then return end
	if slasher.KillDelayTick > 0 then return end

	SlashCo.Jumpscare(slasher, target)
end

function SLASHER.OnSecondaryFire(slasher)
	if slasher:GetNWBool("HoovyStunned") then return end
	if slasher:GetNWBool("HoovyGrabStart") then return end
	if slasher:GetNWBool("HoovyGrabLoop") then return end

	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher, target)
	if not slasher:GetNWBool("HoovyCanBlock") then return end
	if not IsValid(target) or target:GetClass() ~= "sc_generator" then return end
	if slasher:GetPos():Distance(target:GetPos()) >= 500 or target:GetNWBool("GeneratorMalfunction") then return end
	if slasher.GeneratorBlockCooldown > 0.01 then return end

	target:SetNWBool("GeneratorMalfunction", true)
	target:DoSpark()
	slasher.GeneratorBlockUses = slasher.GeneratorBlockUses + 15
	slasher.GeneratorBlockCooldown = 90 + (1 * slasher.GeneratorBlockUses)

	timer.Simple(slasher.GeneratorBlockDuration, function()
		if not IsValid(target) then return end

		target:SetNWBool("GeneratorMalfunction", false)
	end)
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if IsValid(slasher.SurvivorRoped) then return end
	if slasher:GetNWBool("HoovyStunned") then return end
	if slasher:GetNWBool("HoovyGrabLoop") then return end
	if slasher:GetNWBool("HoovyGrabStart") then return end
	if slasher.RopeCooldown > 0.01 then return end

	local dist = slasher:SlasherValue("ChaseRange", 1500)
	local inv = -0.2
	local eyeTrace = slasher:GetEyeTrace()
	local find = ents.FindInCone(slasher:GetPos(), eyeTrace.Normal, dist * 2, slasher:SlasherValue("ChaseRadius", 0.91) + inv)
	for p = 1, #find do
		if find[p]:IsPlayer() and find[p]:Team() == TEAM_SURVIVOR then
			find_p = find[p]
		end

		if eyeTrace.Entity:IsPlayer() and eyeTrace.Entity:Team() == TEAM_SURVIVOR and slasher:GetPos():Distance(eyeTrace.Entity:GetPos()) < dist * 2 then
			find_p = eyeTrace.Entity

			slasher:SetRunSpeed(1)
			slasher:SetWalkSpeed(1)
			slasher:SetSlowWalkSpeed(1)
			slasher:SetNWBool("HoovyGrabStart", true)

			local idx = math.random(1, 2)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/hoovydundy/rope_".. idx ..".mp3",
				identifier = "HoovydundyRope" .. idx,
				minDistance = 200,
				maxDistance = 900,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})

			timer.Simple(1.0, function()
				if not IsValid(slasher) then return end

				slasher:SetNWBool("HoovyGrabLoop", true)
				slasher:SetNWBool("HoovyGrabStart", false)
				slasher:SetNWBool("CanChase", false)

				slasher.SurvivorRoped = find_p
				find_p:SetNWBool("SurvivorGrabbed", true)

				SlashCo.StopChase(slasher)
				PlayPanicMusic(slasher)
			end)

			slasher.RopeCooldown = 40
		end
	end
end

function SLASHER.OnKillPlayer(slasher, target)
	if target == slasher.SurvivorRoped then
		slasher.SurvivorRoped = nil
		target:SetNWBool("SurvivorGrabbed", false)
		slasher:SetNWBool("CanChase", true)
		slasher:SetNWBool("HoovyGrabLoop", false)
		StopPanicMusic(slasher)
	end
end

function SLASHER.OnHitByPocketSand(slasher, ply)
	slasher:SetNWBool("HoovyStunned", true)
	slasher:Freeze(true)

	local idx = math.random(1, 3)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/hoovydundy/stun_".. idx ..".mp3",
		identifier = "HoovydundyStun" .. idx,
		minDistance = 200,
		maxDistance = 800,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	slasher:SetNWBool("HoovyGrabLoop", false)
	StopPanicMusic(slasher)

	timer.Simple(9, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("HoovyStunned", false)
		slasher:SetNWBool("CanChase", true)
		slasher:Freeze(false)
	end)
end
SLASHER.OnHitByBeerKeg = SLASHER.OnHitByPocketSand
SLASHER.OnHitByTeslaCoil = SLASHER.OnHitByPocketSand

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("HoovyStunned")
end

function SLASHER.Animator(ply)
	local GrabAnim = ""
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local hoovy_grab = ply:GetNWBool("HoovyGrabStart")
	local hoovy_grabloop = ply:GetNWBool("HoovyGrabLoop")
	local hoovy_stun = ply:GetNWBool("HoovyStunned")

	if not hoovy_grab and not hoovy_grabloop and not hoovy_stun then
		ply.anim_antispam = false
	end

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("hoovy_walk")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("hoovy_run")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("jumpfloat_ITEM1")
	end

	if ply:GetVelocity():Length() < 30 then
		ply.CalcIdeal = ACT_IDLE
		ply.CalcSeqOverride = ply:LookupSequence("hoovy_idle")
	end

	if hoovy_grab then
		local r = math.random(1, 2)
		if r == 1 then
			GrabAnim = "hoovy_grab1"
		else
			GrabAnim = "hoovy_grab2"
		end

		ply.CalcSeqOverride = ply:LookupSequence(GrabAnim)
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if hoovy_grabloop and (ply.anim_antispam == nil or ply.anim_antispam == false) then
		local GrabLoopAnim = ""
		if GrabAnim == "hoovy_grab1" then
			GrabLoopAnim = "hoovy_grab1_idle"
		elseif GrabAnim == "hoovy_grab2" then
			GrabLoopAnim = "hoovy_grab2_idle"
		end

		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence(GrabLoopAnim), 0, false)
		ply.anim_antispam = true
	end

	if hoovy_stun then
		ply.CalcSeqOverride = ply:LookupSequence("PRIMARY_stun_middle")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER then
		if ply:GetNWBool("InSlasherChaseMode") then
			local idx = math.random(1, 4)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/hoovydundy/step_".. idx ..".mp3",
				identifier = "HoovydundyFootstep" .. idx,
				group = "SlasherFootstep",
				minDistance = 500,
				maxDistance = 1075,
				entity = ply,
				volume = 1,
				fadeIn = 0,
			})
			return true
		end

		if ply.HoovyStepTick == nil or ply.HoovyStepTick > 1 then
			ply.HoovyStepTick = 0
		end

		if ply.HoovyStepTick == 0 then
			local idx = math.random(1, 4)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/hoovydundy/step_".. idx ..".mp3",
				identifier = "HoovydundyFootstep" .. idx,
				group = "SlasherFootstep",
				minDistance = 400,
				maxDistance = 875,
				entity = ply,
				volume = 1,
				fadeIn = 0,
			})
		end

		ply.HoovyStepTick = ply.HoovyStepTick + 1
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_27"))
	hud:SetTitle("Hoovydundy")

	hud:ChaseAndKill()
	hud:AddControl("R", "genblock", Material("slashco/ui/icons/slasher/hoovy_gen"))
	hud:TieControl("R", "HoovyCanBlock")
	hud:TieControlVisible("R", "HoovyCanBlock")

	hud:AddControl("F", "entangle", Material("slashco/ui/icons/slasher/hoovy_rope"))

	hud:SetCrosshairEnabled(true)
	hud:SetCrosshairTighten(4)
	hud:SetCrosshairProngs(5)
	hud:SetCrosshairAlpha(255)

	function hud.AlsoThink()
		local HoovyRopeCooldown = GameData.LocalPlayer:GetNWInt("RopeCooldown")
		local HoovyGenCooldown = GameData.LocalPlayer:GetNWInt("GenBlockCooldown")

		if HoovyRopeCooldown > 0 then
			hud:SetControlEnabled("F", false)
		else
			hud:SetControlEnabled("F", true)
		end

		if HoovyGenCooldown > 0 then
			hud:SetControlEnabled("R", false)
		else
			hud:SetControlEnabled("R", true)
		end
	end
end

if CLIENT then
	hook.Add("SlashCo:DrawHUD", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Hoovydundy") == true then
			if GameData.LocalPlayer.hoovy_f == nil then
				GameData.LocalPlayer.hoovy_f = 0
			end
			if GameData.LocalPlayer.hoovy_f < 8 then
				GameData.LocalPlayer.hoovy_f = GameData.LocalPlayer.hoovy_f + (FrameTime() * 6)
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_27")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.hoovy_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.hoovy_f = nil
		end
	end)

	hook.Add("Tick", "HoovyLight", function()
		for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if v == GameData.LocalPlayer then return end

			if not v:GetNWBool("InSlasherChaseMode") then
				local tlight = DynamicLight(MAX_EDICT + v:EntIndex())
				if tlight then
					tlight.pos = v:LocalToWorld(Vector(0, 0, 20))
					tlight.r = 255
					tlight.g = 0
					tlight.b = 0
					tlight.brightness = 2
					tlight.Decay = 500
					tlight.Size = 1000
					tlight.DieTime = CurTime() + 1
				end
			else
				local tlight = DynamicLight(MAX_EDICT + v:EntIndex())
				if tlight then
					tlight.pos = v:LocalToWorld(Vector(0, 0, 20))
					tlight.r = 255
					tlight.g = 0
					tlight.b = 0
					tlight.brightness = 3
					tlight.Decay = 2300
					tlight.Size = 2000
					tlight.DieTime = CurTime() + 1
				end
			end
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if survivor:GetNWBool("SurvivorGrabbed") then
				local tlight = DynamicLight(MAX_EDICT + survivor:EntIndex())
				if tlight then
					tlight.pos = survivor:LocalToWorld(Vector(0, 0, 20))
					tlight.r = 0
					tlight.g = 0
					tlight.b = 255
					tlight.brightness = 2
					tlight.Decay = 200
					tlight.Size = 400
					tlight.DieTime = CurTime() + 1
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Hoovydundy")