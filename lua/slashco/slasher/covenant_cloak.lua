local SLASHER = {}

SLASHER.Name = "Covenant Cloak"
SLASHER.ID = "covenantcloak"
SLASHER.Class = 1
SLASHER.DangerLevel = 1
SLASHER.IsSelectable = false
SLASHER.Model = "models/slashco/slashers/covenant/cloak.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 100
SLASHER.ChaseSpeed = 297
SLASHER.Perception = 1.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 1
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = ""
SLASHER.Description = ""
SLASHER.ProTip = ""
SLASHER.SpeedRating = "★☆☆☆☆"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★☆☆☆☆"

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.TackleFail = function(slasher)
	if IsValid(slasher) then
		if slasher.TackledPlayer == nil then
			slasher:SetNWBool("CloakTackleFail", true)
			slasher:Freeze(true)

			timer.Simple(2.5, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("CloakTackle", false)
				slasher:SetNWBool("CloakTackleFail", false)
				slasher:Freeze(false)
			end)
		end
	end
end

SLASHER.OnTickBehaviour = function(slasher, target)
	if IsValid(slasher.TackledPlayer) then
		if not slasher:IsFrozen() then
			slasher:Freeze(true)
		end

		if not slasher.TackledPlayer:IsFrozen() then
			slasher.TackledPlayer:Freeze(true)
		end

		slasher:SetPos(slasher.TackledPlayer:GetPos() + Vector(10, 0, 0))

		if slasher.TackledPlayer.TackleStruggle ~= nil and slasher.TackledPlayer.TackleStruggle > 100 then
			slasher.TackledPlayer.TackleStruggle = 0
			slasher.TackledPlayer:Freeze(false)
			slasher.TackledPlayer:SetNWBool("SurvivorTackled", false)
			slasher:SetPos(slasher.TackledPlayer:GetPos() + Vector(0, 0, 80))
			slasher.TackledPlayer = nil
		end
	end

	if slasher:GetNWBool("CloakTackling") then
		if slasher:IsOnGround() then
			slasher:SetVelocity(slasher:GetForward() * 70)
		end

		if IsValid(target) and target:IsPlayer() and target:Team() == TEAM_SURVIVOR and target:GetPos():Distance(slasher:GetPos()) < 100 then
			slasher.TackledPlayer = target
			slasher:SetNWBool("CloakTackling", false)

			slasher.TackledPlayer:SetNWBool("SurvivorTackled", true)
			slasher:SetNWInt("CloakTacklePosition", 1)
		end

		if IsValid(target) and target:GetPos():Distance(slasher:GetPos()) < 120 then
			slasher:SlamDoor(target)
		end
	elseif slasher:GetNWBool("CloakTackle") and slasher.TackledPlayer == nil and not slasher:GetNWBool("CloakTackleFail") then
		slasher:SetNWInt("CloakTacklePosition", 0)
		SLASHER.TackleFail(slasher)
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher)
	if not slasher:GetNWBool("CloakTackle") then
		slasher:SetNWBool("CloakTackle", true)
		slasher:SetNWBool("CloakTackling", true)
		slasher.TackledPlayer = nil

		if slasher:IsOnGround() then
			slasher:SetVelocity(slasher:GetForward() * 500)
		end

		slasher:Freeze(true)

		timer.Simple(0.5, function()
			slasher:SetNWBool("CloakTackling", false)
			--SLASHER.TackleFail(slasher)
		end)
	end
end

SLASHER.OnSecondaryFire = function(slasher)
	--SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)

end

SLASHER.OnSpecialAbilityFire = function(slasher)

end

SLASHER.Animator = function(ply, veloc)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if ply:IsOnGround() then
		if ply:GetVelocity():Length() > 0 then
			if not chase then
				ply.CalcSeqOverride = ply:LookupSequence("walk_all")
			else
				ply.CalcIdeal = ACT_HL2MP_RUN
				ply.CalcSeqOverride = ply:LookupSequence("run_all_02")
			end
		else
			ply.CalcSeqOverride = ply:LookupSequence("menu_combine")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("jump_slam")
	end

	if ply:GetNWBool("CloakTackling") then
		ply.CalcSeqOverride = ply:LookupSequence("zombie_leap_mid")
	end

	if ply:GetNWBool("CloakTackleFail") then
		ply.CalcSeqOverride = ply:LookupSequence("zombie_slump_rise_01")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	else
		ply.anim_antispam = false
	end

	if ply:GetNWInt("CloakTacklePosition") > 0 then
		ply.CalcSeqOverride = ply:LookupSequence("zombie_slump_rise_02_slow")
		ply:SetCycle(0.6)
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function()
	return false
end

SlashCo.RegisterSlasher(SLASHER, "CovenantCloak")