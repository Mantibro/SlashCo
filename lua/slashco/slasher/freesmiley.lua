local SLASHER = {}

SLASHER.Name = "Free Smiley Dealer"
SLASHER.ID = 13
SLASHER.Class = 1
SLASHER.DangerLevel = 2
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/freesmiley/freesmiley.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 100
SLASHER.ChaseSpeed = 275
SLASHER.Perception = 2.5
SLASHER.Eyesight = 8
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 1600
SLASHER.ChaseRadius = 0.85
SLASHER.ChaseDuration = 5.0
SLASHER.ChaseCooldown = 4
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/freesmiley_chase.wav"
SLASHER.KillSound = "slashco/slasher/freesmiley_kill.mp3"
SLASHER.Description = "FreeSmiley_desc"
SLASHER.ProTip = "FreeSmiley_tip"
SLASHER.SpeedRating = "★☆☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★☆☆☆"

SLASHER.OnSpawn = function(slasher)
	SLASHER.SmileyIdle(slasher)
	slasher:SetNWBool("CanKill", true)
	slasher:SetNWBool("CanChase", true)
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	local v1 = slasher.SlasherValue1 --Summon Cooldown
	local v2 = slasher.SlasherValue2 --Selected Summon

	if v1 > 0 then
		slasher.SlasherValue1 = v1 - FrameTime()
	end

	slasher:SetNWInt("SmileySummonCooldown", math.floor(v1))
	slasher:SetNWInt("SmileySummonSelect", v2)

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
	if slasher:GetNWBool("FreeSmileySummoning") then
		return
	end
	if slasher.SlasherValue1 > 0 then
		return
	end

	if slasher.SlasherValue2 == 0 then
		slasher.SlasherValue2 = 1
		return
	end
	if slasher.SlasherValue2 == 1 then
		slasher.SlasherValue2 = 0
		return
	end
end

SLASHER.OnSpecialAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if not SlashCo.IsPositionLegalForSlashers(slasher:GetPos()) then
		return
	end

	if slasher.SlasherValue1 > 0 then
		return
	end
	slasher.SlasherValue1 = 50 - (SO * 25)

	slasher:SetNWBool("FreeSmileySummoning", true)

	slasher:Freeze(true)
	timer.Simple(4, function()
		if slasher.SlasherValue2 == 0 then
			local smiley = ents.Create("sc_zanysmiley")
			smiley:SetPos(slasher:LocalToWorld(Vector(60, 0, 0)))
			smiley:SetAngles(slasher:GetAngles())
			smiley:Spawn()
			smiley:Activate()
		end
		if slasher.SlasherValue2 == 1 then
			local smiley = ents.Create("sc_pensivesmiley")
			smiley:SetPos(slasher:LocalToWorld(Vector(60, 0, 0)))
			smiley:SetAngles(slasher:GetAngles())
			smiley:Spawn()
			smiley:Activate()
		end
	end)

	timer.Simple(6, function()
		slasher:Freeze(false)
		slasher:SetNWBool("FreeSmileySummoning", false)
	end)
end

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local smiley_summon = ply:GetNWBool("FreeSmileySummoning")

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

	if smiley_summon then
		ply.CalcSeqOverride = ply:LookupSequence("summon")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	else
		ply.anim_antispam = false
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		if ply.SmileyStepTick == nil or ply.SmileyStepTick > 1 then
			ply.SmileyStepTick = 0
		end
		if ply.SmileyStepTick == 0 then
			ply:EmitSound("npc/footsteps/hardboot_generic" .. math.random(1, 6) .. ".wav", 50, 70, 0.75)
			ply.SmileyStepTick = ply.SmileyStepTick + 1
			return false
		end

		ply.SmileyStepTick = ply.SmileyStepTick + 1

		return true
	end

	if CLIENT then
		return true
	end
end

local dealTable = {
	["deal a zany"] = Material("slashco/ui/icons/slasher/s_13_a1"),
	["deal a pensive"] = Material("slashco/ui/icons/slasher/s_13_a2"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

local dealSwitchTable = {
	default = Material("slashco/ui/icons/slasher/s_13"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_13"))
	hud:SetTitle("FreeSmiley")

	hud:AddControl("R", "switch deal", dealSwitchTable)
	hud:ChaseAndKill()
	hud:AddControl("F", "deal a zany", dealTable)

	hud.prevDeal = -1
	hud.prevDealAllow = -1
	function hud.AlsoThink()
		local deal = LocalPlayer():GetNWInt("SmileySummonSelect")
		if deal ~= hud.prevDeal then
			hud:ShakeControl("R")
			if deal == 0 then
				hud:SetControlText("F", "deal a zany")
			else
				hud:SetControlText("F", "deal a pensive")
			end

			hud.prevDeal = deal
		end

		local canDeal = SlashCo.IsPositionLegalForSlashers(LocalPlayer():GetPos())
		if canDeal ~= hud.prevCanDeal then
			hud:SetControlEnabled("F", canDeal)
			hud.prevCanDeal = canDeal
		end

		local cooldown = LocalPlayer():GetNWInt("SmileySummonCooldown")
		if not hud.prevDealAllow and cooldown < 0.1 then
			hud:SetControlEnabled("R", true)
			hud:SetControlVisible("F", true)
			hud:SetControlText("R", "switch deal")
			hud:ShakeControl("R")
			hud:ShakeControl("F")
			hud.prevDealAllow = true
		elseif hud.prevDealAllow and cooldown >= 0.1 then
			hud:SetControlEnabled("R", false)
			hud:SetControlVisible("F", false)
			hud:SetControlText("R", "no deal")
			hud:ShakeControl("F")
			hud.prevDealAllow = false
		end
	end

	local surveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
	hook.Add("HUDPaint", "SlashCoZanySurvey", function()
		if LocalPlayer():Team() ~= TEAM_SLASHER then
			hook.Remove("HUDPaint", "SlashCoZanySurvey")
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if survivor:GetNWBool("MarkedBySmiley") then
				local pos = survivor:WorldSpaceCenter():ToScreen()

				if pos.visible then
					surface.SetMaterial(surveyNoticeIcon)
					surface.DrawTexturedRect(pos.x - ScrW() / 32, pos.y - ScrW() / 32, ScrW() / 16, ScrW() / 16)
				end
			end
		end
	end)
end

SLASHER.SmileyIdle = function(slasher)
	if not slasher:GetNWBool("InSlasherChaseMode") then
		slasher:EmitSound("slashco/slasher/freesmiley_idle" .. math.random(1, 7) .. ".mp3")
	end

	timer.Simple(math.random(3, 5), function()
		SLASHER.SmileyIdle(slasher)
	end)
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_FreeSmiley") == true then
			local Overlay = Material("slashco/ui/overlays/jumpscare_13")

			Overlay:SetFloat("$alpha", 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "FreeSmiley")