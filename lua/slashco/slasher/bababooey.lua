local SLASHER = {}

SLASHER.Name = "Bababooey"
SLASHER.Aliases = {
	"Phantom",
	"The Man",
	"The Mist",
}
SLASHER.ID = 1
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Moderate
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/baba/baba.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 298
SLASHER.Perception = 1.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 600
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = "slashco/slasher/bababooey/baba_chase.ogg"
SLASHER.KillSound = "slashco/slasher/bababooey/baba_kill.mp3"
SLASHER.Description = "Bababooey_desc"
SLASHER.ProTip = "Bababooey_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★☆☆☆☆"
-- Balancement Vars
SLASHER.CooldownReduction = 0 -- Additional number that is added to FrameTime to decrease cooldowns.
SLASHER.AppearCooldownReduction = 0 -- Appear Cooldown reduction, same as above but used when quitely appearing
SLASHER.MaxClones = 1 -- How many clones he can have.

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.CooldownReduction = (SO * 0.04) + (0.01 * additionalSurvivors)
	SLASHER.AppearCooldownReduction = (SO * 6) + (0.25 * additionalSurvivors)
	SLASHER.MaxClones = 1 + SO
	if additionalSurvivors > 0 then -- If we got more than the default players, we allow more clones.
		SLASHER.MaxClones = SLASHER.MaxClones + math.floor(additionalSurvivors / 4) -- For every 4 additional survivors we allow one more clone.
	end

	SLASHER.ProwlSpeed = 150 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 298 + (7.5 * additionalSurvivors)
	SLASHER.KillDistance = 135 + (5 * additionalSurvivors)
	SLASHER.ChaseDuration = 10.0 + (1 * additionalSurvivors)
end

function SLASHER.OnSpawn(slasher)
	SLASHER.DoSound(slasher)

	slasher.TriggerCooldown = 0
	slasher.KillCooldown = 0
	slasher.SpookCooldown = 0
end

function SLASHER.DoSound(slasher)
	if slasher:GetNWBool("BababooeyInvisibility") then
		slasher:EmitSound("slashco/slasher/bababooey/baba_laugh" .. math.random(2, 4) .. ".mp3", 30 + math.random(1, 45))
	end

	timer.Simple(math.random(6, 10), function()
		SLASHER.DoSound(slasher)
	end)
end

function SLASHER.OnTickBehaviour(slasher)
	local TriggerCD = slasher.TriggerCooldown or 0 --Cooldown for being able to trigger
	local KillCD = slasher.KillCooldown or 0 --Cooldown for being able to kill
	local SpookCD = slasher.SpookCooldown or 0 --Cooldown for spook animation

	if TriggerCD > 0 then
		slasher.TriggerCooldown = TriggerCD - (FrameTime() + SLASHER.CooldownReduction)
	end

	if KillCD > 0 then
		slasher:SetNWBool("CanKill", false)
	elseif not slasher:GetNWBool("BababooeyInvisibility") then
		slasher:SetNWBool("CanKill", true)
	else
		slasher:SetNWBool("CanKill", false)
	end

	slasher:SetNWBool("CanChase", not slasher:GetNWBool("BababooeyInvisibility"))

	if SpookCD < 0.01 then
		slasher:SetNWBool("BababooeySpooking", false)
	end

	if KillCD > 0 then
		slasher.KillCooldown = KillCD - (FrameTime() + SLASHER.CooldownReduction)
	end

	if SpookCD > 0 then
		slasher.SpookCooldown = SpookCD - (FrameTime() + SLASHER.CooldownReduction)
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher, target)
	local cooldown = slasher.TriggerCooldown

	if cooldown > 0 then
		return
	end
	if slasher:GetNWBool("InSlasherChaseMode") then
		return
	end

	slasher:SetNWBool("BababooeyInvisibility", not slasher:GetNWBool("BababooeyInvisibility"))

	if slasher:GetNWBool("BababooeyInvisibility") then
		--Turning invisible

		slasher:SlasherHudFunc("SetAvatar", "invisible")
		slasher:SlasherHudFunc("SetControlVisible", "LMB", false)
		slasher:SlasherHudFunc("SetControlVisible", "RMB", false)

		slasher.TriggerCooldown = 4
		slasher:EmitSound("slashco/slasher/bababooey/baba_hide.mp3")

		timer.Simple(1, function()
			--Delay for entering invisibility

			slasher:SetVisible(false)

			slasher:PlayGlobalSound("slashco/slasher/bababooey/bababooey_loud.mp3", 130)

			slasher:SetRunSpeed(200)
			slasher:SetWalkSpeed(200)
		end)
	else
		slasher:EmitSound("slashco/slasher/bababooey/baba_reveal.mp3")

		slasher:SlasherHudFunc("SetAvatar", "default")
		slasher:SlasherHudFunc("SetControlVisible", "LMB", true)
		slasher:SlasherHudFunc("SetControlVisible", "RMB", true)

		--Spook Appear
		if IsValid(target) and target:IsPlayer() then
			if target:Team() ~= TEAM_SURVIVOR then
				goto SKIP
			end

			if slasher:GetPos():Distance(target:GetPos()) < 150 then
				slasher:SetNWBool("BababooeySpooking", true)
				slasher.KillCooldown = 2
				slasher.SpookCooldown = 2
				slasher:EmitSound("slashco/slasher/bababooey/baba_scare.mp3", 100)
				slasher:Freeze(true)
				timer.Simple(2.5, function()
					slasher:Freeze(false)
				end)

				goto SPOOKAPPEAR
			else
				goto SKIP
			end
		else
			goto SKIP
		end
		:: SKIP ::

		--Quiet appear
		slasher.KillCooldown = math.random(3, 13 - SLASHER.AppearCooldownReduction)
		slasher.TriggerCooldown = 8

		:: SPOOKAPPEAR ::

		slasher:SetVisible(true)

		slasher:SetRunSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)
		slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)
	end
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if #ents.FindByClass("sc_babaclone") >= SLASHER.MaxClones then
		return
	end

	local ent = SlashCo.CreateItem("sc_babaclone", slasher:GetPos(), slasher:GetAngles())
	if IsValid(ent) then
		SlashCo.CurRound.SlasherEntities[ent:EntIndex()] = {
			activateWalk = false,
			activateSpook = false,
			PostActivation = false
		}
	end
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local spook = ply:GetNWBool("BababooeySpooking")

	if ply:IsOnGround() then
		if not spook then
			if not chase then
				ply.CalcIdeal = ACT_HL2MP_WALK
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			else
				ply.CalcIdeal = ACT_HL2MP_RUN
				ply.CalcSeqOverride = ply:LookupSequence("chase")
			end
		else
			ply.CalcSeqOverride = ply:LookupSequence("spook")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER and not ply:GetNWBool("BababooeyInvisibility") then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/bababooey/babastep_0" .. idx .. ".mp3",
			identifier = "BababooeyFootstep" .. idx,
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

hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
	if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Bababooey") == true then
		if GameData.LocalPlayer.baba_f == nil then
			GameData.LocalPlayer.baba_f = 0
		end
		GameData.LocalPlayer.baba_f = GameData.LocalPlayer.baba_f + (FrameTime() * 20)
		if GameData.LocalPlayer.baba_f > 45 then
			return
		end

		local Overlay = Material("slashco/ui/overlays/jumpscare_1")
		Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.baba_f))

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	else
		GameData.LocalPlayer.baba_f = nil
	end
end)

local avatarTable = {
	default = Material("slashco/ui/icons/slasher/s_1"),
	invisible = Material("slashco/ui/icons/slasher/s_1_a1")
}

local invisTable = {
	["disable invisibility"] = Material("slashco/ui/icons/slasher/s_1"),
	["enable invisibility"] = Material("slashco/ui/icons/slasher/s_1_a1")
}

local cloneTable = {
	["set clone"] = Material("slashco/ui/icons/slasher/s_1_a2"),
	["d/set clone"] = Material("slashco/ui/icons/slasher/s_1_a2_1")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Bababooey")

	hud:AddControl("R", "enable invisibilty", invisTable)
	hud:TieControlText("R", "BababooeyInvisibility", "disable invisibility", "enable invisibility", true)
	hud:ChaseAndKill()
	hud:AddControl("F", "set clone", cloneTable)

	local control = hud:GetControl("F")
	control.PrevClone = -1
	function control.AlsoThink()
		local val = #ents.FindByClass("sc_babaclone")
		if val ~= control.PrevClone then
			control:Shake()
			control.PrevClone = val

			control:SetEnabled(val == 0)
		end
	end
end

SlashCo.RegisterSlasher(SLASHER, "Bababooey")