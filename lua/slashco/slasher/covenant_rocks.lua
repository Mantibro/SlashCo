local SLASHER = {}

SLASHER.Name = "CovenantRocks"
SLASHER.ID = "covenantrocks"
SLASHER.Class = 1
SLASHER.DangerLevel = 1
SLASHER.IsSelectable = false
SLASHER.Model = "models/slashco/slashers/covenant/rocks.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 297
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.7
SLASHER.ChaseDuration = 60.0
SLASHER.ChaseCooldown = 1
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = ""
SLASHER.Description = ""
SLASHER.ProTip = ""
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★☆☆"

SLASHER.OnSpawn = function(slasher)
    slasher:SetNWBool("CanChase", true)
end

SLASHER.OnTickBehaviour = function(slasher)
	local v1 = math.Clamp(slasher.SlasherValue1, 0, 2) --Punch cooldown
	slasher.SlasherValue1 = v1
	
	if v1 > 0 then
		slasher.SlasherValue1 = v1 - FrameTime()
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if not slasher:GetNWBool("InSlasherChaseMode") then
		return
	end

    if not IsValid(target) or not target:IsPlayer() then
		return
	end
	
	if target:Team() ~= TEAM_SURVIVOR then
		return
	end
	
	if slasher:GetPos():Distance(target:GetPos()) >= 55 then
		return
	end

	if slasher.SlasherValue1 < 0.01 then
		slasher:SetNWBool("RockPunching", false)
		timer.Remove("RockPunchDecay")

		timer.Simple(0.3, function()
			if not IsValid(slasher) then
				return
			end

			slasher:EmitSound("ambient/energy/spark"..tostring(math.random(1,6))..".wav", 100, 100, 0.25)

			if SERVER then
				local target1 = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(55, 0, 0)),
						Vector(-30, -30, -60), Vector(30, 30, 60), 35, DMG_SLASH, 5, false)

				if target1:IsPlayer() then
					if target1:Team() ~= TEAM_SURVIVOR then
						return
					end

					local vPoint = target1:GetPos()
					local lightning = EffectData()
					lightning:SetOrigin(vPoint)
					lightning:SetMagnitude(6)
					lightning:SetScale(1)
			        lightning:SetNormal(Vector(55, 0, 1))
			        lightning:SetRadius(100)
					util.Effect( "Sparks", lightning )
					target1:SetNWBool("MarkedByRocks", true)
				end
			end
		end)

		timer.Simple(0.1, function()
			if not IsValid(slasher) then
				return
			end

			slasher:SetNWBool("RockPunching", true)

			timer.Create("RockPunchDecay", 0.6, 1, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("RockPunching", false)
			end)

			slasher.SlasherValue1 = slasher.SlasherValue1 + 0.5
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

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		ply:EmitSound("slashco/slasher/babastep_0" .. math.random(1, 3) .. ".mp3")
		return true
	end

	if CLIENT then
		return true
	end
end

SLASHER.InitHud = function(_, hud)
    hud:SetAvatar(Material("slashco/ui/icons/slasher/s_rocks"))
	hud:SetTitle("CovenantRocks")
	
    hud:AddControl("LMB", "shock", Material("slashco/ui/icons/slasher/s_0"))
	hud:UntieControl("LMB")
    hud:TieControlVisible("LMB", "InSlasherChaseMode", false, false, true)
	
	local surveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
	hook.Add("HUDPaint", "SlashCoZanySurvey", function()
		if LocalPlayer():Team() ~= TEAM_SLASHER then
			hook.Remove("HUDPaint", "SlashCoZanySurvey")
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:CanBeSeen() then
				continue
			end

			if survivor:GetNWBool("MarkedByRocks") then
				local pos = survivor:WorldSpaceCenter():ToScreen()

				if pos.visible then
					surface.SetMaterial(surveyNoticeIcon)
					surface.DrawTexturedRect(pos.x - ScrW() / 32, pos.y - ScrW() / 32, ScrW() / 16, ScrW() / 16)
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "CovenantRocks")