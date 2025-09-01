local SLASHER = {}

SLASHER.Name = "Free Smiley Dealer"
SLASHER.Aliases = {
	"Yellow Guy",
	"Smiley",
}
SLASHER.ID = 13
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
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
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 4
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/freesmiley/freesmiley_chase.ogg"
SLASHER.KillSound = "slashco/slasher/freesmiley/freesmiley_kill.mp3"
SLASHER.Description = "FreeSmiley_desc"
SLASHER.ProTip = "FreeSmiley_tip"
SLASHER.SpeedRating = "★☆☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★☆☆☆"
SLASHER.SummonCooldown = 50 -- Summon cooldown

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.SummonCooldown = 50 - (25 * SO)
end

function SLASHER.OnSpawn(slasher)
	SLASHER.SmileyIdle(slasher)
	slasher:SetNWBool("CanKill", true)
	slasher:SetNWBool("CanChase", true)

	slasher.SummonCooldown = 0
	slasher.SummonChoose = 0
end

function SLASHER.OnTickBehaviour(slasher)
	local SummonCD = slasher.SummonCooldown or 0 --Summon Cooldown
	local SummonChoose = slasher.SummonChoose or 0 --Selected Summon

	if SummonCD > 0 then
		slasher.SummonCooldown = SummonCD - FrameTime()
	end

	slasher:SetNWInt("SmileySummonCooldown", math.floor(SummonCD))
	slasher:SetNWInt("SmileySummonSelect", SummonChoose)

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher:GetNWBool("FreeSmileySummoning") then
		return
	end
	if slasher.SummonCooldown > 0 then
		return
	end

	if slasher.SummonChoose == 0 then
		slasher.SummonChoose = 1
		return
	end
	if slasher.SummonChoose == 1 then
		slasher.SummonChoose = 0
		return
	end
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if not SlashCo.IsPositionLegalForSlashers(slasher:GetPos()) then
		return
	end

	if slasher.SummonCooldown > 0 then
		return
	end

	local zanies = ents.FindByClass("sc_zanysmiley")
	if slasher.SummonChoose == 0 and #zanies >= 2 then
		for _, v in ipairs(zanies) do
			v:Use(slasher)
		end

		return
	end

	slasher.SummonCooldown = SLASHER.SummonCooldown

	slasher:SetNWBool("FreeSmileySummoning", true)

	slasher:Freeze(true)
	timer.Simple(4, function()
		if slasher.SummonChoose == 0 then
			local smiley = ents.Create("sc_zanysmiley")
			smiley:SetPos(slasher:LocalToWorld(Vector(60, 0, 0)))
			smiley:SetAngles(slasher:GetAngles())
			smiley:Spawn()
			smiley:Activate()
		end
		if slasher.SummonChoose == 1 then
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

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("FreeSmileySummoning")
end

function SLASHER.Animator(ply)
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

function SLASHER.Footstep(ply)
	if SERVER then
		if ply.SmileyStepTick == nil or ply.SmileyStepTick > 1 then
			ply.SmileyStepTick = 0
		end

		if ply.SmileyStepTick == 0 then
			local idx = math.random(1, 6)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "npc/footsteps/hardboot_generic" .. idx .. ".wav",
				identifier = "FreeSmileyFootstep" .. idx,
				minDistance = 200,
				maxDistance = 500,
				entity = ply,
				volume = 1,
				fadeIn = 0,
				unreliable = true,
			})
		end

		ply.SmileyStepTick = ply.SmileyStepTick + 1
	end

	return true
end

local dealTable = {
	["deal a zany"] = Material("slashco/ui/icons/slasher/s_13_a1"),
	["deal a pensive"] = Material("slashco/ui/icons/slasher/s_13_a2"),
	["max zanies"] = Material("slashco/ui/icons/slasher/s_0"),
	["max pensives"] = Material("slashco/ui/icons/slasher/s_0"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

local dealSwitchTable = {
	default = Material("slashco/ui/icons/slasher/s_13"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_13"))
	hud:SetTitle("FreeSmiley")

	hud:AddControl("R", "switch deal", dealSwitchTable)
	hud:ChaseAndKill()
	hud:AddControl("F", "deal a zany", dealTable)

	hud.prevDeal = -1
	hud.prevDealAllow = -1
	hud.prevNumZanies = -1
	function hud.AlsoThink()
		local deal = GameData.LocalPlayer:GetNWInt("SmileySummonSelect")
		local numZanies
		if deal == 0 then
			numZanies = (#ents.FindByClass("sc_zanysmiley") >= 2)
		end

		if numZanies ~= hud.prevNumZanies or deal ~= hud.prevDeal then
			if deal == 0 then
				if numZanies then
					hud:SetControlText("F", "max zanies")
				else
					hud:ShakeControl("R")
					hud:SetControlText("F", "deal a zany")
				end
			else
				hud:ShakeControl("R")
				hud:SetControlText("F", "deal a pensive")
			end

			hud.prevNumZanies = numZanies
			hud.prevDeal = deal
		end

		local canDeal = SlashCo.IsPositionLegalForSlashers(GameData.LocalPlayer:GetPos())
		if canDeal ~= hud.prevCanDeal then
			hud:SetControlEnabled("F", canDeal)
			hud.prevCanDeal = canDeal
		end

		local cooldown = GameData.LocalPlayer:GetNWInt("SmileySummonCooldown")
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
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			hook.Remove("HUDPaint", "SlashCoZanySurvey")
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:CanBeSeen() then
				continue
			end

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

function SLASHER.SmileyIdle(slasher)
	if not slasher:GetNWBool("InSlasherChaseMode") then
		slasher:EmitSound("slashco/slasher/freesmiley/freesmiley_idle" .. math.random(1, 7) .. ".mp3")
	end

	timer.Simple(math.random(3, 5), function()
		SLASHER.SmileyIdle(slasher)
	end)
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_FreeSmiley") == true then
			local Overlay = Material("slashco/ui/overlays/jumpscare_13")

			Overlay:SetFloat("$alpha", 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "FreeSmiley")