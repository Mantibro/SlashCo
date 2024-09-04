local SLASHER = {}

SLASHER.Name = "Abomignat"
SLASHER.ID = 11
SLASHER.Class = 1
SLASHER.DangerLevel = 1
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/abomignat/abomignat.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 5
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 293
SLASHER.Perception = 0.5
SLASHER.Eyesight = 6
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 1400
SLASHER.ChaseRadius = 0.82
SLASHER.ChaseDuration = 5.0
SLASHER.ChaseCooldown = 5
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/abomignat_chase.wav"
SLASHER.KillSound = ""
SLASHER.Description = "Abomignat_desc"
SLASHER.ProTip = "Abomignat_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★★☆"
SLASHER.DiffRating = "★☆☆☆☆"

SLASHER.OnSpawn = function(slasher)
	PlayGlobalSound("slashco/slasher/abomignat_breathing.wav", 65, slasher)
	slasher.AbomignatKills = 0
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	--local SO = SlashCo.CurRound.OfferingData.SO

	v1 = slasher.SlasherValue1 --Main Slash Cooldown
	v2 = slasher.SlasherValue2 --Forward charge
	v3 = slasher.SlasherValue3 --Lunge Finish Antispam
	v4 = slasher.SlasherValue4 --Lunge Duration

	local eyesight_final = SLASHER.Eyesight
	local perception_final = SLASHER.Perception

	if v1 > 0 then
		slasher.SlasherValue1 = v1 - FrameTime()
	end

	if slasher:IsOnGround() then
		slasher:SetVelocity(slasher:GetForward() * v2 * 8)
	end

	if slasher:GetNWBool("AbomignatLunging") then
		local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 30)),
				Vector(-15, -15, -60), Vector(15, 15, 60), 50, DMG_SLASH, 5, false)

		SlashCo.BustDoor(slasher, target, 25000)

		slasher.SlasherValue4 = v4 + 1

		if (slasher:GetVelocity():Length() < 450 or target:IsValid()) and v4 > 30 and slasher.SlasherValue3 == 0 then
			slasher:SetNWBool("AbomignatLungeFinish", true)
			timer.Simple(0.6, function()
				slasher:EmitSound("slashco/slasher/abomignat_scream" .. math.random(1, 3) .. ".mp3")
			end)

			slasher:SetNWBool("AbomignatLunging", false)
			slasher:SetCycle(0)

			slasher.SlasherValue2 = 0
			slasher.SlasherValue3 = 1

			timer.Simple(4, function()
				if v3 == 1 then
					slasher.SlasherValue3 = 2
					slasher.SlasherValue4 = 0
					slasher:SetNWBool("AbomignatLungeFinish", false)
					slasher:Freeze(false)
				end
			end)
		end
	end

	if slasher:GetNWBool("AbomignatCrawling") then
		slasher:SetNWBool("CanChase", false)

		slasher:SetSlowWalkSpeed(350)
		slasher:SetWalkSpeed(350)
		slasher:SetRunSpeed(350)

		SLASHER.Eyesight = 0
		SLASHER.Perception = 0

		if slasher:GetVelocity():Length() < 3 then
			slasher:SetNWBool("AbomignatCrawling", false)
			slasher.ChaseActivationCooldown = SLASHER.ChaseCooldown
		end

		if not slasher:IsOnGround() then
			slasher:SetNWBool("AbomignatCrawling", false)
			slasher.ChaseActivationCooldown = SLASHER.ChaseCooldown
		end

		slasher:SetViewOffset(Vector(0, 0, 20))
		slasher:SetCurrentViewOffset(Vector(0, 0, 20))
	else
		slasher:SetNWBool("CanChase", slasher:GetNWBool("AbomignatCanMainSlash"))

		eyesight_final = 6
		perception_final = 0.5

		slasher:SetViewOffset(Vector(0, 0, 70))
		slasher:SetCurrentViewOffset(Vector(0, 0, 70))

		if not slasher:GetNWBool("InSlasherChaseMode") then
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		end
	end

	if v1 > 0 and slasher:GetNWBool("AbomignatCanMainSlash") then
		slasher:SetNWBool("AbomignatCanMainSlash", false)
	end

	if v1 <= 0 and not slasher:GetNWBool("AbomignatCanMainSlash") then
		slasher:SetNWBool("AbomignatCanMainSlash", true)
	end

	slasher:SetNWFloat("Slasher_Eyesight", eyesight_final)
	slasher:SetNWInt("Slasher_Perception", perception_final)
end

hook.Add("PlayerDeath", "AbomignatCountKills", function(victim, _, attacker)
	timer.Remove("AbomignatHit_" .. victim:UserID())

	if attacker:GetNWString("Slasher") == "Abomignat" then
		attacker.AbomignatKills = (attacker.AbomignatKills or 0) + 1
	end
end)

function SLASHER.HandleDOT(slasher, target)
	target.AbomignatProcs = target.AbomignatProcs or 0

	if timer.Exists("AbomignatHit_" .. target:UserID()) then
		target:TakeDamage(9999, slasher, slasher)
		target:EmitSound("physics/flesh/flesh_bloody_break.wav")
		return
	end

	timer.Create("AbomignatHit_" .. target:UserID(), 1, target.AbomignatProcs, function()
		if not IsValid(target) or target:Team() == TEAM_SPECTATOR then
			return
		end

		target:TakeDamage(7, slasher, slasher)

		local vPoint = target:GetPos() + Vector(0, 0, 50)
		local bloodfx = EffectData()
		bloodfx:SetOrigin(vPoint)
		util.Effect("BloodImpact", bloodfx)

		target:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav")
	end)

	target.AbomignatProcs = target.AbomignatProcs + 3
end

SLASHER.OnPrimaryFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher:GetNWBool("AbomignatCrawling") then
		return
	end
	if slasher:GetNWBool("AbomignatSlashing") then
		return
	end
	if slasher.SlasherValue1 > 0 then
		return
	end

	slasher:SetNWBool("AbomignatSlashing", true)
	slasher.SlasherValue1 = 6 - (SO * 3)
	slasher.SlasherValue2 = 6

	slasher:EmitSound("slashco/slasher/abomignat_scream" .. math.random(1, 3) .. ".mp3")
	slasher:SlasherHudFunc("ShakeControl", "LMB")

	local function SlashFinish()
		slasher:EmitSound("slashco/slasher/trollge_swing.wav")
		slasher:Freeze(true)
		slasher.SlasherValue2 = 0

		local damage = 25 + slasher.AbomignatKills * 10

		slasher:LagCompensation(true)
		local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 0)),
				Vector(-40, -40, -60), Vector(40, 40, 60), damage, DMG_SLASH, 5, false)
		slasher:LagCompensation(false)

		SlashCo.BustDoor(slasher, target, 20000)

		timer.Simple(1.3, function()
			slasher:SetNWBool("AbomignatSlashing", false)
			slasher:Freeze(false)
		end)

		if target:IsPlayer() then
			if target:Team() ~= TEAM_SURVIVOR then
				return
			end

			SLASHER.HandleDOT(slasher, target)

			local vPoint = target:GetPos() + Vector(0, 0, 50)
			local bloodfx = EffectData()
			bloodfx:SetOrigin(vPoint)
			util.Effect("BloodImpact", bloodfx)

			target:EmitSound("slashco/slasher/trollge_hit.wav")
		end
	end

	timer.Create(slasher:EntIndex() .. "_AbomignatSlash", 1, 1, SlashFinish)
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
	if slasher:GetNWBool("AbomignatCrawling") then
		slasher:SetNWBool("AbomignatCrawling", false)
		slasher.ChaseActivationCooldown = SLASHER.ChaseCooldown

		slasher:SlasherHudFunc("SetControlVisible", "LMB", true)
		slasher:SlasherHudFunc("SetControlVisible", "RMB", true)
		slasher:SlasherHudFunc("SetControlVisible", "F", true)
		return
	end

	if slasher:GetNWBool("InSlasherChaseMode") then
		return
	end
	if slasher:GetNWBool("AbomignatSlashing") then
		return
	end
	if slasher:GetNWBool("AbomignatLunging") then
		return
	end
	if slasher:GetNWBool("AbomignatLungeFinish") then
		return
	end
	if slasher.ChaseActivationCooldown > 0 then
		return
	end

	if not slasher:GetNWBool("AbomignatCrawling") then
		slasher:SetNWBool("AbomignatCrawling", true)

		slasher:SlasherHudFunc("SetControlVisible", "LMB", false)
		slasher:SlasherHudFunc("SetControlVisible", "RMB", false)
		slasher:SlasherHudFunc("SetControlVisible", "F", false)
	end
end

SLASHER.OnSpecialAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher:GetNWBool("AbomignatCrawling") then
		return
	end

	if slasher.SlasherValue1 > 0 then
		return
	end
	slasher.SlasherValue1 = 10 - (SO * 4)
	slasher.SlasherValue2 = 8 + (SO * 4)
	slasher.SlasherValue3 = 0

	slasher:Freeze(true)

	slasher:SetNWBool("AbomignatLunging", true)
	slasher:EmitSound("slashco/slasher/abomignat_lunge.mp3")
	slasher:SlasherHudFunc("ShakeControl", "F")

	timer.Simple(1.75, function()
		if slasher.SlasherValue3 == 0 then
			slasher:SetNWBool("AbomignatLungeFinish", true)
			timer.Simple(0.6, function()
				slasher:EmitSound("slashco/slasher/abomignat_scream" .. math.random(1, 3) .. ".mp3")
			end)

			slasher:SetNWBool("AbomignatLunging", false)
			slasher:SetCycle(0)

			slasher.SlasherValue2 = 0
			slasher.SlasherValue3 = 1
		end

		timer.Simple(4, function()
			if slasher.SlasherValue3 == 1 then
				slasher.SlasherValue3 = 2
				slasher.SlasherValue4 = 0
				slasher:SetNWBool("AbomignatLungeFinish", false)
				slasher:Freeze(false)
			end
		end)
	end)
end

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	local abomignat_mainslash = ply:GetNWBool("AbomignatSlashing")
	local abomignat_lunge = ply:GetNWBool("AbomignatLunging")
	local abomignat_lungefinish = ply:GetNWBool("AbomignatLungeFinish")
	local abomignat_crawl = ply:GetNWBool("AbomignatCrawling")

	if not abomignat_mainslash and not abomignat_lunge and not abomignat_lungefinish then
		ply.anim_antispam = false
	end

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

		if abomignat_crawl then
			ply.CalcSeqOverride = ply:LookupSequence("crawl")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	if abomignat_mainslash then
		ply.CalcSeqOverride = ply:LookupSequence("slash_charge")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if abomignat_lunge then
		ply.CalcSeqOverride = ply:LookupSequence("lunge")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if abomignat_lungefinish then
		ply.CalcSeqOverride = ply:LookupSequence("lunge_post")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		ply:EmitSound("slashco/slasher/abomignat_step" .. math.random(1, 3) .. ".mp3")
		return true
	end

	return true
end

local controlTable = {
	default = Material("slashco/ui/icons/slasher/s_slash"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_11"))
	hud:SetTitle("Abomignat")

	hud:AddControl("R", "enable crawling")
	hud:TieControlText("R", "AbomignatCrawling", "disable crawling", "enable crawling", true)
	hud:AddControl("LMB", "slash charge", controlTable)
	hud:ChaseAndKill(nil, true)
	hud:AddControl("F", "lunge", controlTable)

	hud:TieControl("LMB", "AbomignatCanMainSlash")
	hud:TieControl("F", "AbomignatCanMainSlash")
end

SlashCo.RegisterSlasher(SLASHER, "Abomignat")