local SLASHER = {}

SLASHER.Name = "Bren"
SLASHER.Aliases = {
	"The Council",
}
SLASHER.ID = 24
SLASHER.Class = SlashCo.SlasherClass.Umbra
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/breen/breen.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 1.5
SLASHER.ProwlSpeed = 200
SLASHER.ChaseSpeed = 290
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 1200
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 7
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = "slashco/slasher/bren/bren_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Bren_desc"
SLASHER.ProTip = "Bren_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★★★★★"
SLASHER.AngerIncrease = 20
SLASHER.AngerPassiveGain = 0.005
SLASHER.AngerChaseGain = 0.003
SLASHER.MediumAngerBackgroundMusic = "slashco/slasher/bren/bren_ambience.ogg"
SLASHER.HighAngerBackgroundMusic = "slashco/slasher/bren/bren_ambience.ogg"
-- Balancement Vars
SLASHER.FogIncreaseLength = 12

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	SLASHER.ProwlSpeed = 200 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 290 + (1.5 * additionalSurvivors)
	SLASHER.KillDistance = 135 + (5 * additionalSurvivors)
	
	if additionalSurvivors > 0 then
		SLASHER.ChaseDuration = 10.0 + (2 * additionalSurvivors)
		SLASHER.FogIncreaseLength = 12 + (1.5 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	slasher:SetJumpPower(0)
	slasher:DrawShadow(false)
	slasher:SetNWBool("CanChase", true)

	slasher.MainCooldown = 0
	slasher.NoclipCooldown = 0
	slasher.SnapCooldown = 0
end

function SLASHER.OnTickBehaviour(slasher)
	local MainCD = slasher.MainCooldown or 0 -- kill cooldown
	local NoclipCD = slasher.NoclipCooldown or 0 -- noclip cooldown
	local SnapCD = slasher.SnapCooldown or 0 -- snap cooldown
	
	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception
	
	if MainCD > 0 then
		slasher.MainCooldown = MainCD - FrameTime()
	end
	
	if NoclipCD > 0 then
		slasher.NoclipCooldown = NoclipCD - FrameTime()
	end
	
	if SnapCD > 0 then
		slasher.SnapCooldown = SnapCD - FrameTime()
	end
	
	if SlashCo.CurRound.GameProgress > 4 then
		slasher:SetImpervious(true)
		SlashCo.AddSlasherAnger(slasher, SLASHER.AngerPassiveGain)
		final_perception = 3.0
	end

	if not slasher:GetNWBool("InSlasherChaseMode") then
		slasher:SetBodygroup(0, 0)
	else
		SlashCo.AddSlasherAnger(slasher, SLASHER.AngerChaseGain)
		slasher:SetBodygroup(0, 1)
	end
	
	local anger = SlashCo.GetSlasherAnger(slasher)
	slasher:SetNWBool("CanNoclip", anger > 50)

	if not slasher:GetNWBool("BrenNoclip") then
		slasher:SetJumpPower(0)
		slasher:SetMoveType(MOVETYPE_WALK)

		final_eyesight = SLASHER.Eyesight
	else
		slasher:SetMoveType(MOVETYPE_NOCLIP)

		final_eyesight = 1
	end

	if slasher:GetNWInt("BrenAnger") ~= math.floor(anger) then
		slasher:SetNWInt("BrenAnger", math.floor(anger))
	end
	
	if slasher:GetNWInt("SnapCooldown") ~= math.floor(SnapCD) then
		slasher:SetNWInt("SnapCooldown", math.floor(SnapCD))
	end
	
	if slasher:GetNWInt("NoclipCooldown") ~= math.floor(NoclipCD) then
		slasher:SetNWInt("NoclipCooldown", math.floor(NoclipCD))
	end

	slasher:SetEyeSight(final_eyesight)
	slasher:SetPerception(final_perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher:GetNWBool("BrenNoclip") then return end
	if slasher.MainCooldown > 0.01 then return end

	if not IsValid(target) or not target:IsPlayer() then return end
	if target:Team() ~= TEAM_SURVIVOR then return end
	
	local dist = SLASHER.KillDistance
	if slasher:GetPos():Distance(target:GetPos()) >= dist * 1.4 or target:GetNWBool("SurvivorBeingJumpscared") then
		return
	end

	timer.Simple(0.1, function()
		if not IsValid(slasher) or not IsValid(target) then return end

		slasher:Freeze(true)
		target:Freeze(true)
		target:EmitSound("ambient/voices/citizen_beaten4.wav")

		slasher.MainCooldown = 5
		slasher:SetNWBool("CanChase", false)
		slasher:SetNWBool("BrenKill", true)

		timer.Simple(1.5, function()
			if not IsValid(slasher) then return end

			slasher:Freeze(false)
			slasher:SetNWBool("BrenKill", false)
			slasher:SetNWBool("CanChase", true)
			SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)

			if not IsValid(target) then return end

			target:Freeze(false)
			target:TakeDamage(99999, slasher, slasher)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/bren/bren_kill.mp3",
				identifier = "BrenKillSound",
				minDistance = 800,
				maxDistance = 900,
				entity = slasher,
				volume = 2,
				fadeIn = 0,
			})

			timer.Simple(FrameTime(), function()
				if not IsValid(target) then return end

				local ragdoll = target.DeadBody
				if not IsValid(ragdoll) then return end

				timer.Simple(0.5, function()
					if not IsValid(slasher) then return end

					local Dissolver = ents.Create("env_entity_dissolver")
					if not IsValid(Dissolver) then return end

					Dissolver.Target = "dissolve" .. ragdoll:EntIndex()
					Dissolver:SetKeyValue("dissolvetype", 0)
					Dissolver:SetKeyValue("magnitude", 1)
					Dissolver:SetPos(ragdoll:GetPos())
					Dissolver:SetPhysicsAttacker(slasher)
					Dissolver:Spawn()

					ragdoll:SetName(Dissolver.Target)
					Dissolver:Fire("Dissolve", Dissolver.Target, 0)
					Dissolver:Fire("Kill", "", 0.5)

					SafeRemoveEntityDelayed(Dissolver, 1)
				end)
			end)
		end)
	end)
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher:GetNWBool("BrenKill") then return end
	if not slasher:GetNWBool("CanNoclip") then return end

	if not slasher:GetNWBool("BrenNoclip") then
		if !slasher:OnGround() and slasher:WaterLevel() == 0 and !slasher:IsStuck() then return end
		if slasher.NoclipCooldown > 0.01 then return end
		
		slasher:SlasherHudFunc("SetControlEnabled", "LMB", false)
		slasher:SlasherHudFunc("SetControlEnabled", "RMB", false)

		slasher:SetNWBool("BrenNoclip", true)
		slasher:SetNWBool("CanChase", false)
	else
		local trace = util.TraceHull({
			start = slasher:GetPos(),
			endpos = slasher:GetPos(),
			mins = slasher:OBBMins(),
			maxs = slasher:OBBMaxs(),
			filter = slasher,
			mask = MASK_PLAYERSOLID,
		})
		if trace.Hit then return end
		
		slasher:SlasherHudFunc("SetControlEnabled", "LMB", true)
		slasher:SlasherHudFunc("SetControlEnabled", "RMB", true)

		slasher:SetNWBool("BrenNoclip", false)
		slasher:SetNWBool("CanChase", true)
		slasher.NoclipCooldown = 5
		slasher.MainCooldown = 5
		SlashCo.AddSlasherAnger(slasher, -25)
	end
end

function SLASHER.OnSpecialAbilityFire(slasher, target)
	if slasher:GetNWBool("BrenKill") then return end
	if slasher.SnapCooldown > 0.01 then return end

	slasher.SnapCooldown = 60
	slasher:SetNWBool("BrenSnapAnim", true)
	slasher:Freeze(true)

	timer.Simple(1.0, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("BrenSnapAnim", false)
		slasher:Freeze(false)
		slasher:EmitSound("slashco/slasher/bren/bren_snap.mp3")

		SlashCo.SetSurvivorFogMult(0.3)

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/bren/bren_near.mp3",
				identifier = "BrenFog",
				entity = survivor,
				volume = 1,
				fadeIn = 0,
				fadeOutStart = SLASHER.FogIncreaseLength,
				fadeOut = 0.5,
			})
		end

		timer.Simple(SLASHER.FogIncreaseLength, function()
			SlashCo.SetSurvivorFogMult(1)
		end)
	end)
end

function SLASHER.Animator(ply)
	local bren_kill = ply:GetNWBool("BrenKill")
	local bren_snap = ply:GetNWBool("BrenSnapAnim")
	
	if not bren_kill and not bren_snap then
		ply.anim_antispam = false
	end

	if ply:IsOnGround() then
		ply.CalcIdeal = ACT_HL2MP_WALK
		ply.CalcSeqOverride = ply:LookupSequence("walk_all")
	else
		ply.CalcSeqOverride = ply:LookupSequence("slashco_breen_idle")
	end
	
	ply:SetPoseParameter("move_x", ply:GetVelocity():Length() / 100)

	if ply:GetVelocity():Length() < 30 then
		ply.CalcIdeal = ACT_IDLE
		ply.CalcSeqOverride = ply:LookupSequence("slashco_breen_idle")
	end
	
	if bren_kill and (ply.anim_antispam == nil or ply.anim_antispam == false) then
		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("slashco_breen_kill"), 0, true)
		ply.anim_antispam = true
	end
	
	if bren_snap and (ply.anim_antispam == nil or ply.anim_antispam == false) then
		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("slashco_breen_snap"), 0, true)
		ply.anim_antispam = true
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("BrenSnapAnim") or ply:GetNWBool("BrenKill")
end

function SLASHER.Footstep(ply)
	if SERVER then
		if not ply:GetNWBool("BrenNoclip") then
			local idx = math.random(1, 6)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/criminal/criminal_step" .. idx .. ".mp3",
				identifier = "BrenFootstep" .. idx,
				group = "SlasherFootstep",
				minDistance = 200,
				maxDistance = 400,
				entity = ply,
				volume = 1,
				fadeIn = 0,
				unreliable = true,
			})
		end
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_24"))
	hud:SetTitle("Bren")

	hud:ChaseAndKill()
	hud:AddControl("R", "noclip", Material("slashco/ui/icons/slasher/s_bren_noclip"))
	hud:AddControl("F", "snap", Material("slashco/ui/icons/slasher/s_bren_snap"))
	
	hud:AddMeter("anger", 100, "", nil, true)
	hud:TieMeterInt("anger", "BrenAnger")
	
	function hud.AlsoThink()
		local canNoclip = GameData.LocalPlayer:GetNWBool("CanNoclip")
		local BrenNoclip = GameData.LocalPlayer:GetNWBool("BrenNoclip")
		local BrenNoclipCooldown = GameData.LocalPlayer:GetNWInt("NoclipCooldown")
		local BrenSnapCooldown = GameData.LocalPlayer:GetNWInt("SnapCooldown")
		
		if not canNoclip then
			hud:SetControlEnabled("R", false)
			hud:SetControlVisible("R", false)
		else
			hud:SetControlEnabled("R", true)
			hud:SetControlVisible("R", true)
		end
		
		if BrenNoclipCooldown > 0 then
			hud:SetControlEnabled("R", false)
		else
			hud:SetControlEnabled("R", true)
		end
		
		if BrenSnapCooldown > 0 then
			hud:SetControlEnabled("F", false)
		else
			hud:SetControlEnabled("F", true)
		end
	end
end

SlashCo.RegisterSlasher(SLASHER, "Bren")