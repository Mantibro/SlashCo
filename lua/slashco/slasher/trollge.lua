local SLASHER = {}

SLASHER.Name = "Trollge"
SLASHER.Aliases = {
	"Comedy",
}
SLASHER.ID = 3
SLASHER.Class = SlashCo.SlasherClass.Umbra
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/trollge/trollge.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 1.5
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 295
SLASHER.Perception = 1.0
SLASHER.Eyesight = 2
SLASHER.KillDistance = 100
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 0.0
SLASHER.ChaseDuration = 0.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/trollge/trollge_chase.ogg"
SLASHER.KillSound = "slashco/slasher/trollge/trollge_kill.mp3"
SLASHER.Description = "Trollge_desc"
SLASHER.ProTip = "Trollge_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★★★"
SLASHER.AngerIncrease = 10
SLASHER.AngerPassiveGain = 0.05
SLASHER.AngerChaseGain = 0
-- Only when he's really angry his ambiance should play. This is why we only set it for HighAnger.
SLASHER.HighAngerBackgroundMusic = "slashco/slasher/trollge/trollge_stage6.ogg"

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	SLASHER.ProwlSpeed = 150 + (2.5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 295 + (5 * additionalSurvivors)
end

local function PlayBreathing(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/trollge/trollge_breathing.mp3",
		identifier = "TrollgeBreath",
		minDistance = 350,
		maxDistance = 700,
		looping = true,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
end

local function StopBreathing()
	SlashCo.AudioSystem.StopSound("TrollgeBreath", 0.5)
end

function SLASHER.OnSpawn(slasher)
	PlayBreathing(slasher)
	
	slasher.TrollgeStage = 0
	slasher.ClawCooldown = 0
	slasher.TrollgeBlood = 0
	slasher.TrollgeDashing = 0
end

local function stopDash(slasher)
	if not slasher:GetNWBool("TrollgeDashFinish") then
		slasher:StopSound("slashco/slasher/trollge/trollge_screech.mp3")
		timer.Simple(0.25, function()
			if not IsValid(slasher) then
				return
			end

			slasher:StopSound("slashco/slasher/trollge/trollge_screech.mp3")
		end)

		slasher:EmitSound("slashco/slasher/trollge/trollge_exhaust.mp3")

		slasher.TrollgeDashing = 0
		slasher:SetNWBool("TrollgeDashFinish", true)

		timer.Simple(8, function()
			if not IsValid(slasher) then
				return
			end

			slasher.TrollgeDashing = 0
			slasher:Freeze(false)
			slasher:SetNWBool("TrollgeDashFinish", false)
			slasher:SetNWBool("TrollgeDashing", false)
			slasher.ClawCooldown = 1.99
		end)
	end
end

function SLASHER.OnTickBehaviour(slasher)
	local stage = slasher.TrollgeStage --Stage
	local ClawCD = math.Clamp(slasher.ClawCooldown or 0, 0, 2) --Claw cooldown
	slasher.ClawCooldown = ClawCD
	local Blood = slasher.TrollgeBlood or 0 --blood
	local Dashing = slasher.TrollgeDashing or 0 --dashing

	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception

	if math.random(1, 1000) == 1 then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/trollge/troll_limb" .. math.random(1, 9) .. ".mp3",
			identifier = "TrollgeLimb",
			minDistance = 250,
			maxDistance = 500,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end

	if ClawCD > 0 then
		slasher.ClawCooldown = ClawCD - FrameTime()
	end

	if stage == 0 then
		slasher:SetNWBool("TrollgeStage1", false)
		slasher:SetNWBool("TrollgeStage2", false)
	end

	if stage == 1 then
		slasher:SetNWBool("TrollgeStage1", true)
		slasher:SetNWBool("TrollgeStage2", false)
	end

	if stage == 2 then
		slasher:SetNWBool("TrollgeStage1", false)
		slasher:SetNWBool("TrollgeStage2", true)
	end

	if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage1") and SlashCo.CurRound.GameProgress > 4 and stage < 1 then
		slasher:SetNWBool("TrollgeTransition", true)
		slasher:Freeze(true)
		StopBreathing()
		slasher:StopSound("slashco/slasher/trollge_breathing.wav")
		slasher:PlayGlobalSound("slashco/slasher/trollge/trollge_transition.mp3", 125)

		for _, ply in ipairs(player.GetAll()) do
			ply:SetNWBool("DisplayTrollgeTransition", true)
		end

		timer.Simple(7, function()
			--transit
			StopBreathing()
			slasher.TrollgeStage = 1
			slasher:SetNWBool("TrollgeTransition", false)
			slasher:Freeze(false)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/trollge/trollge_stage1.ogg",
				identifier = "TrollgeStage1",
				minDistance = 550,
				maxDistance = 1100,
				looping = true,
				entity = slasher,
				volume = 0.9,
				fadeIn = 0,
			})

			slasher:SetRunSpeed(280)
			slasher:SetWalkSpeed(150)
			slasher:SetNWBool("CanKill", true)

			for _, ply in ipairs(player.GetAll()) do
				ply:SetNWBool("DisplayTrollgeTransition", false)
			end
		end)
	end

	if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage2") and SlashCo.CurRound.GameProgress > (10 - (Blood / 2)) and stage == 1 then
		slasher:SetNWBool("TrollgeTransition", true)
		slasher:Freeze(true)
		SlashCo.AudioSystem.StopSound("TrollgeStage1", 0.5)
		slasher:PlayGlobalSound("slashco/slasher/trollge/trollge_transition.mp3", 125)

		for _, ply in ipairs(player.GetAll()) do
			ply:SetNWBool("DisplayTrollgeTransition", true)
		end

		timer.Simple(7, function()
			if not IsValid(slasher) then
				return
			end

			--transit
			SlashCo.AudioSystem.StopSound("TrollgeStage1", 0.5)
			slasher.TrollgeStage = 2
			slasher:SetNWBool("TrollgeTransition", false)
			slasher:Freeze(false)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/trollge/trollge_stage6.ogg",
				identifier = "TrollgeStage2",
				minDistance = 1100,
				maxDistance = 2200,
				looping = true,
				entity = slasher,
				volume = 0.7,
				fadeIn = 0,
			})

			slasher:SetRunSpeed(450)
			slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
			final_eyesight = 10

			for _, ply in ipairs(player.GetAll()) do
				ply:SetNWBool("DisplayTrollgeTransition", false)
			end
		end)
	end

	if stage == 1 then
		final_eyesight = 10 - (slasher:GetVelocity():Length() / 35)
		final_perception = 5 - (slasher:GetVelocity():Length() / 60)
	end

	if slasher:GetNWInt("TrollgeStage") ~= stage then
		slasher:SetNWInt("TrollgeStage", stage)
	end

	if slasher:GetNWBool("TrollgeDashing") then
		local target = nil

		if not slasher:GetNWBool("TrollgeDashFinish") then
			target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 30)),
					Vector(-15, -15, -60), Vector(15, 15, 60), 50, DMG_SLASH, 5, false)
			SlashCo.BustDoor(slasher, target, 25000)
			slasher:SetVelocity(slasher:GetForward() * 100)

			if Dashing == 0 then
				timer.Simple(6, function()
					stopDash(slasher)
				end)
			end

			slasher.TrollgeDashing = Dashing + 1

			if target:IsValid() and target:IsPlayer() then
				stopDash(slasher)

				if target:Team() ~= TEAM_SURVIVOR then
					return
				end

				local vPoint = target:GetPos() + Vector(0, 0, 50)
				local bloodfx = EffectData()
				bloodfx:SetOrigin(vPoint)
				util.Effect("BloodImpact", bloodfx)

				target:EmitSound("slashco/slasher/trollge/trollge_hit.mp3")

				if slasher.TrollgeStage == 0 then
					slasher.TrollgeBlood = slasher.TrollgeBlood + 1 + SlashCo.CurRound.OfferingData.Singularity
					slasher:SetNWInt("TrollgeBlood", slasher.TrollgeBlood)
					SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)
				end
			end

			if slasher.TrollgeDashing > 50 and slasher:GetVelocity():Length() < 450 then
				stopDash(slasher)
			end
		end
	end

	local find = ents.FindInSphere(slasher:GetPos(), 60)
	for f = 1, #find do
		local ent = find[f]

		if ent:GetClass() == "sc_balkanboost" then
			--WHAT HAVE YOU DONE...
			ent:Remove()
			slasher.TrollgeBlood = 8
			slasher:SetNWBool("TrollgeTransition", true)
			slasher:Freeze(true)
			StopBreathing()
	 		slasher:PlayGlobalSound("slashco/slasher/trollge/trollge_transition.mp3", 125)

			for _, ply in ipairs(player.GetAll()) do
				ply:SetNWBool("DisplayTrollgeTransition", true)
			end

			timer.Simple(7, function()
				if not IsValid(slasher) then
					return
				end

				--transit
				StopBreathing()
				slasher.TrollgeStage = 2
				slasher:SetNWBool("TrollgeTransition", false)
				slasher:Freeze(false)
				SlashCo.AddSlasherAnger(slasher, 100)
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/trollge/trollge_stage6.ogg",
					identifier = "TrollgeStage2",
					minDistance = 1100,
					maxDistance = 2200,
					looping = true,
					entity = slasher,
					volume = 1,
					fadeIn = 0,
				})

				slasher:SetRunSpeed(450)
				slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseSpeed)
				final_eyesight = 10
				slasher:SetNWBool("CanKill", true)

				for _, ply in ipairs(player.GetAll()) do
					ply:SetNWBool("DisplayTrollgeTransition", false)
				end
			end)
		end
	end

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

function SLASHER.Move(ply, mv)
	if not ply:GetNWBool("TrollgeStage2") then
		if ply.TrollgeMoveSet then
			ply:SetGravity(ply.TrollgeGravity)
			ply:SetHullDuck(ply.TrollgeDuckMin, ply.TrollgeDuckMax)
			ply:SetViewOffsetDucked(ply.TrollgeViewDuck)
			ply.TrollgeMoveSet = nil
		end

		return
	end

	local newVel = Vector() -- DO NOT replace with vector_origin
	local ang = mv:GetMoveAngles()
	local speed = ply:GetRunSpeed()
	local f, r = 0, 0

	-- movement keys

	if mv:KeyDown(IN_JUMP) then
		newVel:Add(vector_up * speed)
	end
	if mv:KeyDown(IN_DUCK) then
		newVel:Add(vector_up * -speed)
	end

	local aF = (ang:Forward() * Vector(1, 1, 0)):GetNormalized()
	if mv:KeyDown(IN_FORWARD) then
		newVel:Add(aF * speed)
		f = f + 1
	end
	if mv:KeyDown(IN_BACK) then
		newVel:Add(aF * -speed)
		f = f - 1
	end

	if mv:KeyDown(IN_MOVERIGHT) then
		newVel:Add(ang:Right() * speed)
		r = r + 1
	end
	if mv:KeyDown(IN_MOVELEFT) then
		newVel:Add(ang:Right() * -speed)
		r = r - 1
	end

	if math.abs(f) + math.abs(r) == 2 then
		newVel:Mul(0.707)
	end

	-- stay close to ground

	local tr = util.TraceLine({
		start = ply:GetPos(),
		endpos = ply:GetPos() - vector_up * 500,
		filter = ply
	})

	if tr.Fraction > 0.5 and newVel.z > 0 then
		newVel.z = 0
	end
	if tr.Fraction > 0.65 then
		newVel.z = newVel.z - speed * (tr.Fraction - 0.65) / 0.35
	end

	-- sprint/walk

	local friction = 0.02
	if mv:KeyDown(IN_SPEED) then
		newVel:Mul(1.5)
		friction = 0.007
	end
	if mv:KeyDown(IN_WALK) then
		newVel:Mul(0.5)
		friction = 0.08
	end

	-- apply

	local vel = mv:GetVelocity() * (1 - friction) + newVel * FrameTime() * friction * 66.666
	mv:SetVelocity(vel)
	ply:SetGroundEntity(NULL)

	if not ply.TrollgeMoveSet then
		ply.TrollgeDuckMin, ply.TrollgeDuckMax = ply:GetHullDuck()
		ply.TrollgeGravity = ply:GetGravity()
		ply.TrollgeViewDuck = ply:GetViewOffsetDucked()

		ply:SetGravity(0.00000000000000001)
		ply:SetHullDuck(ply:GetHull())
		ply:SetViewOffsetDucked(ply:GetViewOffset())
		ply.TrollgeMoveSet = true
	end
end

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher.TrollgeStage ~= 0 then
		SlashCo.Jumpscare(slasher, target)
		return
	end

	if slasher.ClawCooldown < 0.01 and not slasher:GetNWBool("TrollgeTransition") then
		slasher:SetNWBool("TrollgeSlashing", false)
		timer.Remove("TrollgeSlashDecay")

		timer.Simple(0.3, function()
			if not IsValid(slasher) then
				return
			end

			slasher:EmitSound("slashco/slasher/trollge/trollge_swing.mp3")

			if SERVER then
				local target1 = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 0)),
						Vector(-30, -30, -60), Vector(30, 30, 60), 10, DMG_SLASH, 5, false)

				if target1:IsPlayer() then
					if target1:Team() ~= TEAM_SURVIVOR then
						return
					end

					local vPoint = target1:GetPos() + Vector(0, 0, 50)
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					target1:EmitSound("slashco/slasher/trollge/trollge_hit.mp3")

					if slasher.TrollgeStage == 0 then
						slasher.TrollgeBlood = slasher.TrollgeBlood + 1 + SlashCo.CurRound.OfferingData.Singularity
						slasher:SetNWInt("TrollgeBlood", slasher.TrollgeBlood)
						SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)
					end
				end
			end
		end)

		timer.Simple(0.1, function()
			if not IsValid(slasher) then
				return
			end

			slasher:SetNWBool("TrollgeSlashing", true)

			timer.Create("TrollgeSlashDecay", 0.6, 1, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("TrollgeSlashing", false)
			end)

			slasher.ClawCooldown = slasher.ClawCooldown + 0.5
		end)
	end
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher.TrollgeStage ~= 2 and not slasher:GetNWBool("TrollgeDashing") and slasher.ClawCooldown == 0 then
		slasher:SetNWBool("TrollgeDashing", true)
		slasher:PlayGlobalSound("slashco/slasher/trollge/trollge_screech.mp3", 125)
		slasher:Freeze(true)
		slasher.ClawCooldown = 3
		slasher.TrollgeDashing = 0
		slasher:SetVelocity(slasher:GetForward() * 1000)
	end
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("TrollgeDashing") or ply:GetNWBool("TrollgeDashFinish")
end

function SLASHER.Animator(ply)
	local trollge_stage1 = ply:GetNWBool("TrollgeStage1")
	local trollge_stage2 = ply:GetNWBool("TrollgeStage2")
	local trollge_slashing = ply:GetNWBool("TrollgeSlashing")

	if not trollge_slashing then
		ply.anim_antispam = false
	end

	if not trollge_stage1 and not trollge_stage2 then
		if ply:IsOnGround() then
			if not trollge_slashing then
				ply.CalcIdeal = ACT_HL2MP_WALK
				ply.CalcSeqOverride = ply:LookupSequence("walk")
			else
				ply.CalcSeqOverride = ply:LookupSequence("walk")

				if ply.anim_antispam == nil or ply.anim_antispam == false then
					ply:AddVCDSequenceToGestureSlot(1, 2, 0, true)
					ply.anim_antispam = true
				end
			end
		end
	elseif trollge_stage2 then
		ply.CalcSeqOverride = ply:LookupSequence("fly")
	else
		ply.CalcSeqOverride = ply:LookupSequence("glide")
	end

	if ply:GetNWBool("TrollgeDashing") and not ply:GetNWBool("TrollgeDashFinish") then
		ply.CalcSeqOverride = ply:LookupSequence("dash")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.OnHitByPocketSand(slasher, ply)
	StopBreathing()
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/trollge/troll_blind_" .. math.random(1, 2) .. ".mp3",
		identifier = "TrollgeBlinded",
		minDistance = 2000,
		maxDistance = 5000,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
	SlashCo.AddSlasherAnger(slasher, 5) -- We did not like that
	timer.Simple(9, function()
		if not IsValid(slasher) then return end

		PlayBreathing(slasher)
	end)
end

function SLASHER.CanSeeFlashlights(ply)
	return false
end

local avatarTable = {
	default = Material("slashco/ui/icons/slasher/s_3"),
	stage1 = Material("slashco/ui/icons/slasher/s_3_s1"),
	stage2 = Material("slashco/ui/icons/slasher/s_3_s2")
}

local killTable = {
	default = Material("slashco/ui/icons/slasher/s_0"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled"),
	claw = Material("slashco/ui/icons/slasher/s_3_a1")
}

local dashTable = {
	default = Material("slashco/ui/icons/slasher/s_3"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled"),
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Trollge")

	hud:AddControl("R", "dash", dashTable)
	hud:AddControl("LMB", "claw", killTable)
	hud:TieControl("R", "TrollgeDashing", true, true, false)

	hud:AddMeter("blood", 8, "", nil, true)
	hud:TieMeterInt("blood", "TrollgeBlood")

	hud.prevStage = -1
	function hud.AlsoThink()
		local stage = GameData.LocalPlayer:GetNWInt("TrollgeStage")
		if stage ~= hud.prevStage then
			if stage == 0 then
				hud:SetControlVisible("R", true)
				hud:SetControlText("LMB", "claw")
				hud:SetMeterVisible("blood", true)
				hud:SetAvatar("default")
			else
				if stage == 1 then
					hud:SetControlVisible("R", true)
				else
					hud:SetControlVisible("R", false)
				end

				hud:SetMeterVisible("blood", false)
				hud:SetControlText("LMB", "kill survivor")
				hud:SetAvatar(stage == 1 and "stage1" or "stage2")
			end

			hud.prevStage = stage
		end
	end
end

function SLASHER.Visibility(slasher, ply)
	ply = ply or slasher -- This was done to allow this function to be called using ply:SlasherFunction("Visibility", ply)

	local eyeAng = ply:EyeAngles()
	local lAng = math.sqrt(eyeAng.p^2 + eyeAng.y^2 + eyeAng.r^2)
	ply.MonitorLook = ply.MonitorLook or lAng
	ply.LookSpeed = math.max(math.abs(ply.MonitorLook - lAng) * 5, 30) - 30
	ply.MonitorLook = SlashCo.Dampen(8, ply.MonitorLook, lAng)

	local lPos = (ply:GetPos() - ply:EyePos()):Length()
	ply.MonitorPos = ply.MonitorPos or lPos
	ply.PosSpeed = math.abs(ply.MonitorPos - lPos) * 5
	ply.MonitorPos = SlashCo.Dampen(10, ply.MonitorPos, lPos)

	return ply.LookSpeed + ply:GetVelocity():Length() + ply.PosSpeed
end

function SLASHER.ClientSideEffect()
	for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if not ply:CanBeSeen() then
			ply.MonitorLook = nil
			ply.MonitorPos = nil
			continue
		end
		if ply:GetPos():Distance(GameData.LocalPlayer:GetPos()) >= 1000 then
			ply.MonitorLook = nil
			ply.MonitorPos = nil
			ply:SetColor(color_transparent)
			ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
			continue
		end

		ply:SetMaterial("lights/white")
		ply:SetColor(Color(255, 255, 255, SLASHER.Visibility(nil, ply)))
		ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
	end
end

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 5)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/trollge/troll_step" .. idx .. ".mp3",
			identifier = "TrollgeFootstep" .. idx,
			minDistance = 150,
			maxDistance = 500,
			entity = ply,
			volume = 1,
			fadeIn = 0,
			unreliable = true,
		})
	end

	return true
end

if CLIENT then
	local eyeball = Material("slashco/ui/particle/eyeball.png")
	local drawIcon

	timer.Create("TrollgeDetect", 0.5, 0, function()
		if not IsValid(GameData.LocalPlayer) or not GameData.LocalPlayer.Team or GameData.LocalPlayer:Team() ~= TEAM_SURVIVOR then
			return
		end

		drawIcon = false
		for _, s in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if s:GetNWString("Slasher") ~= "Trollge" or not s:CanBeSeen() then
				continue
			end

			if s:GetPos():Distance(GameData.LocalPlayer:GetPos()) >= 1000 then
				continue
			end

			local tr = util.TraceLine({
				start = s:EyePos(),
				endpos = GameData.LocalPlayer:WorldSpaceCenter(),
				filter = s
			})

			if tr.Entity ~= GameData.LocalPlayer then
				continue
			end

			drawIcon = true
			break
		end
	end)

	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if drawIcon and GameData.LocalPlayer:CanBeSeen() then
			surface.SetMaterial(eyeball)
			surface.SetDrawColor(255, 255, 255, SLASHER.Visibility(GameData.LocalPlayer))
			surface.DrawTexturedRect(ScrW() / 2 - ScrW() / 32, ScrH() / 2 - ScrW() / 32, ScrW() / 16, ScrW() / 16)
		end

		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Trollge") == true then
			if GameData.LocalPlayer.troll_f == nil then
				GameData.LocalPlayer.troll_f = 0
			end
			GameData.LocalPlayer.troll_f = GameData.LocalPlayer.troll_f + (FrameTime() * 30)
			if GameData.LocalPlayer.troll_f > 86 then
				return
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_3")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.troll_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.troll_f = nil
		end

		if GameData.LocalPlayer:GetNWBool("DisplayTrollgeTransition") == true then
			local Overlay = Material("slashco/ui/overlays/trollge_overlays")
			Overlay:SetInt("$frame", 0)

			surface.SetDrawColor(255, 255, 255, 60)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Trollge")