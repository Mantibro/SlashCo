local SLASHER = {}

SLASHER.Name = "Bababooey"
SLASHER.ID = 1
SLASHER.Class = 1
SLASHER.DangerLevel = 1
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
SLASHER.ChaseMusic = "slashco/slasher/baba_chase.wav"
SLASHER.KillSound = "slashco/slasher/baba_kill.mp3"
SLASHER.Description = "Bababooey_desc"
SLASHER.ProTip = "Bababooey_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★☆☆☆☆"

SLASHER.OnSpawn = function(slasher)
	SLASHER.DoSound(slasher)
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.DoSound = function(slasher)
	if slasher:GetNWBool("BababooeyInvisibility") then
		slasher:EmitSound("slashco/slasher/baba_laugh" .. math.random(2, 4) .. ".mp3", 30 + math.random(1, 45))
	end

	timer.Simple(math.random(6, 10), function()
		SLASHER.DoSound(slasher)
	end)
end

SLASHER.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --Cooldown for being able to trigger
	local v2 = slasher.SlasherValue2 --Cooldown for being able to kill
	local v3 = slasher.SlasherValue3 --Cooldown for spook animation

	if v1 > 0 then
		slasher.SlasherValue1 = v1 - (FrameTime() + (SO * 0.04))
	end

	if v2 > 0 then
		slasher:SetNWBool("CanKill", false)
	elseif not slasher:GetNWBool("BababooeyInvisibility") then
		slasher:SetNWBool("CanKill", true)
	else
		slasher:SetNWBool("CanKill", false)
	end

	slasher:SetNWBool("CanChase", not slasher:GetNWBool("BababooeyInvisibility"))

	if v3 < 0.01 then
		slasher:SetNWBool("BababooeySpooking", false)
	end

	if v2 > 0 then
		slasher.SlasherValue2 = v2 - (FrameTime() + (SO * 0.04))
	end
	if v3 > 0 then
		slasher.SlasherValue3 = v3 - (FrameTime() + (SO * 0.04))
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher, target)
	local SO = SlashCo.CurRound.OfferingData.SO

	local cooldown = slasher.SlasherValue1

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
		--slasher:SlasherHudFunc("SetControlIcon", "R", "invisible")
		--slasher:SlasherHudFunc("ShakeControl", "R")

		slasher.SlasherValue1 = 4
		slasher:EmitSound("slashco/slasher/baba_hide.mp3")

		timer.Simple(1, function()
			--Delay for entering invisibility

			slasher:SetMaterial("Models/effects/vol_light001")
			slasher:SetColor(Color(0, 0, 0, 0))

			PlayGlobalSound("slashco/slasher/bababooey_loud.mp3", 130, slasher)

			slasher:SetRunSpeed(200)
			slasher:SetWalkSpeed(200)
		end)
	else
		slasher:EmitSound("slashco/slasher/baba_reveal.mp3")

		slasher:SlasherHudFunc("SetAvatar", "default")
		slasher:SlasherHudFunc("SetControlVisible", "LMB", true)
		slasher:SlasherHudFunc("SetControlVisible", "RMB", true)
		--slasher:SlasherHudFunc("SetControlIcon", "R", "default")
		--slasher:SlasherHudFunc("ShakeControl", "R")

		--Spook Appear
		if IsValid(target) and target:IsPlayer() then
			if target:Team() ~= TEAM_SURVIVOR then
				goto SKIP
			end

			if slasher:GetPos():Distance(target:GetPos()) < 150 then

				slasher:SetNWBool("BababooeySpooking", true)
				slasher.SlasherValue2 = 2
				slasher.SlasherValue3 = 2
				slasher:EmitSound("slashco/slasher/baba_scare.mp3", 100)
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
		slasher.SlasherValue2 = math.random(3, (13 - (SO * 6)))
		slasher.SlasherValue1 = 8

		:: SPOOKAPPEAR ::

		slasher:SetMaterial("")
		slasher:SetColor(Color(255, 255, 255, 255))

		slasher:SetRunSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)
		slasher:SetWalkSpeed(SlashCoSlashers[slasher:GetNWString("Slasher")].ProwlSpeed)
	end
end

SLASHER.OnSpecialAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if #ents.FindByClass("sc_babaclone") > SO then
		return
	end
	SlashCo.CreateItem("sc_babaclone", slasher:GetPos(), slasher:GetAngles())
end

SLASHER.Animator = function(ply)
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

SLASHER.Footstep = function(ply)
	if SERVER then
		if ply:GetNWBool("BababooeyInvisibility") then
			return true
		end

		ply:EmitSound("slashco/slasher/babastep_0" .. math.random(1, 3) .. ".mp3")
		return true
	end

	if CLIENT then
		return true
	end
end

hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
	if LocalPlayer():GetNWBool("SurvivorJumpscare_Bababooey") == true then
		if LocalPlayer().baba_f == nil then
			LocalPlayer().baba_f = 0
		end
		LocalPlayer().baba_f = LocalPlayer().baba_f + (FrameTime() * 20)
		if LocalPlayer().baba_f > 45 then
			return
		end

		local Overlay = Material("slashco/ui/overlays/jumpscare_1")
		Overlay:SetInt("$frame", math.floor(LocalPlayer().baba_f))

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	else
		LocalPlayer().baba_f = nil
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

SLASHER.InitHud = function(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("bababooey")

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