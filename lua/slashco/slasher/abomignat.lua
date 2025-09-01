local SLASHER = {}

SLASHER.Name = "Abomignat"
SLASHER.Aliases = {
	"The Alien",
	"The Rat",
}
SLASHER.ID = 11
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/abomignat/abomignat.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 2
SLASHER.ProwlSpeed = 200
SLASHER.ChaseSpeed = 325
SLASHER.Perception = 0.5
SLASHER.Eyesight = 6
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 1400
SLASHER.ChaseRadius = 0.82
SLASHER.ChaseDuration = 7.0
SLASHER.ChaseCooldown = 5
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/abomignat/abomignat_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Abomignat_desc"
SLASHER.ProTip = "Abomignat_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★★★☆"
SLASHER.DiffRating = "★★☆☆☆"
-- Balancement Vars
SLASHER.CrawlSpeed = 400 -- SlowWalk,Walk,Run speed when he's crawling
SLASHER.CooldownReduction = 0 -- Additional cooldown reduction applied to SlashCooldown

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	-- For every 5 additional or missing survivors we increase/decrease by 1 second.
	SLASHER.CooldownReduction = math.max((SO * 4) + (0.2 * additionalSurvivors), 0) -- math.max so we don't go below 0

	SLASHER.ProwlSpeed = 200 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 325 + (7.5 * additionalSurvivors)
	SLASHER.KillDistance = 150 + (5 * additionalSurvivors)
	SLASHER.ChaseDuration = 7.0 + (1 * additionalSurvivors)
end

function SLASHER.OnSpawn(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/abomignat/abomignat_breathing.mp3",
		identifier = "AbomignatBreath",
		minDistance = 400,
		maxDistance = 600,
		looping = true,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	slasher.AbomignatKills = 0

	slasher.SlashCooldown = 0
	slasher.FowardCharge = 0
	slasher.LungeAntiSpam = 0
	slasher.LungeDuration = 0
end

local function AbomignatScream()
	local idx = math.random(1, 3)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/abomignat/abomignat_scream" .. idx .. ".mp3",
		identifier = "AbomignatScream" .. idx,
		minDistance = 600,
		maxDistance = 800,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})
end

-- We create these only once since we use them every tick.
local crawling_viewoffset = Vector(0, 0, 20)
local standing_viewoffset = Vector(0, 0, 70)
function SLASHER.OnTickBehaviour(slasher)
	local SlashCooldown = slasher.SlashCooldown or 0 --Main Slash Cooldown
	local FCharge = slasher.FowardCharge or 0 --Forward charge
	local AntiSpam = slasher.LungeAntiSpam or 0 --Lunge Finish Antispam
	local LungeDuration = slasher.LungeDuration or 0 --Lunge Duration

	local eyesight_final = SLASHER.Eyesight
	local perception_final = SLASHER.Perception

	if SlashCooldown > 0 then
		slasher.SlashCooldown = SlashCooldown - FrameTime()
	end

	if slasher:IsOnGround() then
		slasher:SetVelocity(slasher:GetForward() * FCharge * 8)
	end

	if slasher:GetNWBool("AbomignatLunging") then
		local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(55, 0, 30)),
				Vector(-15, -15, -60), Vector(15, 15, 60), 100, DMG_SLASH, 5, false)

		SlashCo.BustDoor(slasher, target, 25000)

		slasher.LungeDuration = LungeDuration + 1

		if (slasher:GetVelocity():Length() < 450 or target:IsValid()) and LungeDuration > 30 and slasher.LungeAntiSpam == 0 then
			slasher:SetNWBool("AbomignatLungeFinish", true)
			timer.Simple(0.6, function()
				AbomignatScream()
			end)

			slasher:SetNWBool("AbomignatLunging", false)
			slasher:SetCycle(0)

			slasher.FowardCharge = 0
			slasher.LungeAntiSpam = 1

			timer.Simple(4, function()
				if AntiSpam == 1 then
					slasher.LungeAntiSpam = 2
					slasher.LungeDuration = 0
					slasher:SetNWBool("AbomignatLungeFinish", false)
					slasher:Freeze(false)
				end
			end)
		end
	end

	if slasher:GetNWBool("AbomignatCrawling") then
		slasher:SetNWBool("CanChase", false)

		slasher:SetSlowWalkSpeed(SLASHER.CrawlSpeed)
		slasher:SetWalkSpeed(SLASHER.CrawlSpeed)
		slasher:SetRunSpeed(SLASHER.CrawlSpeed)

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

		slasher:SetViewOffset(crawling_viewoffset)
		slasher:SetCurrentViewOffset(crawling_viewoffset)
	else
		slasher:SetNWBool("CanChase", slasher:GetNWBool("AbomignatCanMainSlash"))

		eyesight_final = 6
		perception_final = 0.5

		slasher:SetViewOffset(standing_viewoffset)
		slasher:SetCurrentViewOffset(standing_viewoffset)

		if not slasher:GetNWBool("InSlasherChaseMode") then
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		end
	end

	if SlashCooldown > 0 and slasher:GetNWBool("AbomignatCanMainSlash") then
		slasher:SetNWBool("AbomignatCanMainSlash", false)
	end

	if SlashCooldown <= 0 and not slasher:GetNWBool("AbomignatCanMainSlash") then
		slasher:SetNWBool("AbomignatCanMainSlash", true)
	end

	slasher:SetNWFloat("Slasher_Eyesight", eyesight_final)
	slasher:SetNWInt("Slasher_Perception", perception_final)
end

hook.Add("PlayerDeath", "AbomignatCountKills", function(victim, _, attacker)
	timer.Remove("AbomignatHit_" .. victim:UserID())
	if not IsValid(attacker) then return end

	if victim:Team() ~= TEAM_SLASHER and attacker.GetNWString and attacker:GetNWString("Slasher") == "Abomignat" then
		attacker.AbomignatKills = (attacker.AbomignatKills or 0) + 1
	end
end)

function SLASHER.HandleDOT(slasher, target)
	target.AbomignatProcs = target.AbomignatProcs or 3

	if timer.Exists("AbomignatHit_" .. target:UserID()) then
		target:TakeDamage(99999, slasher, slasher)
		target:EmitSound("physics/flesh/flesh_bloody_break.wav")
		return
	end

	timer.Create("AbomignatHit_" .. target:UserID(), 0.75, target.AbomignatProcs, function()
		if not IsValid(target) or target:Team() == TEAM_SPECTATOR then
			return
		end

		target:TakeDamage(3, slasher, slasher)

		local vPoint = target:GetPos() + Vector(0, 0, 50)
		local bloodfx = EffectData()
		bloodfx:SetOrigin(vPoint)
		util.Effect("BloodImpact", bloodfx)

		target:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav")
	end)

	target.AbomignatProcs = target.AbomignatProcs + 3
end

function SLASHER.OnPrimaryFire(slasher)
	if slasher:GetNWBool("AbomignatCrawling") then
		return
	end
	if slasher:GetNWBool("AbomignatSlashing") then
		return
	end
	if slasher.SlashCooldown > 0 then
		return
	end

	slasher:SetNWBool("AbomignatSlashing", true)
	slasher.SlashCooldown = math.max(3 - SLASHER.CooldownReduction, 0)
	slasher.FowardCharge = 6

	AbomignatScream()
	slasher:SlasherHudFunc("ShakeControl", "LMB")

	local function SlashFinish()
		slasher:EmitSound("slashco/slasher/trollge/trollge_swing.mp3")
		slasher:Freeze(true)
		slasher.FowardCharge = 0

		local damage = 50 + slasher.AbomignatKills * 10

		local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(55, 0, 0)),
				Vector(-40, -40, -60), Vector(40, 40, 60), damage, DMG_SLASH, 5, false)

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

			target:EmitSound("slashco/slasher/trollge/trollge_hit.mp3")
		end
	end

	timer.Create(slasher:EntIndex() .. "_AbomignatSlash", 1, 1, SlashFinish)
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
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

function SLASHER.OnSpecialAbilityFire(slasher)
	if slasher:GetNWBool("AbomignatCrawling") then
		return
	end

	if slasher.SlashCooldown > 0 then
		return
	end
	slasher.SlashCooldown = 10 - SLASHER.CooldownReduction
	slasher.FowardCharge = 8 + SLASHER.CooldownReduction
	slasher.LungeAntiSpam = 0

	slasher:Freeze(true)

	slasher:SetNWBool("AbomignatLunging", true)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/abomignat/abomignat_lunge.mp3",
		identifier = "AbomignatLunge",
		minDistance = 600,
		maxDistance = 800,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
		unreliable = true,
	})
	slasher:SlasherHudFunc("ShakeControl", "F")

	timer.Simple(1.75, function()
		if slasher.LungeAntiSpam == 0 then
			slasher:SetNWBool("AbomignatLungeFinish", true)
			timer.Simple(0.6, function()
				AbomignatScream()
			end)

			slasher:SetNWBool("AbomignatLunging", false)
			slasher:SetCycle(0)

			slasher.FowardCharge = 0
			slasher.LungeAntiSpam = 1
		end

		timer.Simple(4, function()
			if slasher.LungeAntiSpam == 1 then
				slasher.LungeAntiSpam = 2
				slasher.LungeDuration = 0
				slasher:SetNWBool("AbomignatLungeFinish", false)
				slasher:Freeze(false)
			end
		end)
	end)
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("AbomignatLunging") or ply:GetNWBool("AbomignatLungeFinish")
end

function SLASHER.Animator(ply)
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

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/abomignat/abomignat_step" .. idx .. ".mp3",
			identifier = "AbomignatFootstep" .. idx,
			minDistance = 200,
			maxDistance = 400,
			entity = ply,
			volume = 1,
			fadeIn = 0,
			unreliable = true,
		})
	end

	return true
end

local controlTable = {
	default = Material("slashco/ui/icons/slasher/s_slash"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
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