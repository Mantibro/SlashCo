local SLASHER = {}

SLASHER.Name = "Covenant Cloak"
SLASHER.ID = "covenantcloak"
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Moderate
SLASHER.IsSelectable = false
SLASHER.Model = "models/slashco/slashers/covenant/cloak.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 275
SLASHER.Perception = 1.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 137
SLASHER.ChaseRange = 1500
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 0
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = ""
SLASHER.Description = ""
SLASHER.ProTip = ""
SLASHER.SpeedRating = "★☆☆☆☆"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★☆☆☆☆"

function SLASHER.OnSpawn(slasher)
	slasher:SetNWBool("CanChase", true)
end

function SLASHER.TackleFail(slasher)
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

local SURVIVOR_STUN_TIME = 1.2
local SLASHER_STUN_TIME = 4.5

function SLASHER.OnTickBehaviour(slasher, target)
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
			timer.Simple(2.0, function()
				slasher:Freeze(false)
			end)
		end
	end

	if slasher:GetNWBool("CloakTackling") then
		if slasher:IsOnGround() then
			slasher:SetVelocity(slasher:GetForward() * 70)
		end

		if SERVER and not slasher.TackledPlayer then
			for _, ply in ipairs(ents.FindInSphere(slasher:GetPos(), 60)) do
				if ply:IsPlayer() and ply:Team() == TEAM_SURVIVOR and not ply:GetNWBool("SurvivorTackled") then
					slasher.TackledPlayer = ply
					slasher:SetNWBool("CloakTackling", false)
					slasher:SetNWBool("CloakTackle", false)

					ply:SetNWBool("SurvivorTackled", true)
					ply:SetNWBool("MarkedByCloaks", true)
					ply.SlashCo_PushDir = (ply:GetPos() - slasher:GetPos()):GetNormalized()
					timer.Simple(SURVIVOR_STUN_TIME, function()
						if IsValid(ply) then
							ply:SetNWBool("SurvivorTackled", false)
							ply:Freeze(false)
							if IsValid(slasher) and slasher.TackledPlayer == ply then
								slasher.TackledPlayer = nil
							end
							if ply.SlashCo_PushDir then
								local pushStrength = 400
								ply:SetVelocity(ply.SlashCo_PushDir * pushStrength + Vector(0,0,120))
								ply.SlashCo_PushDir = nil
							end
						end
					end)
					
					timer.Simple(10.0, function()
						if IsValid(ply) then
							ply:SetNWBool("MarkedByCloaks", false)
						end
					end)

					-- Stun slasher
					slasher:Freeze(true)
					slasher:SetImpervious(true)
					timer.Simple(SLASHER_STUN_TIME, function()
						if IsValid(slasher) then
							slasher:Freeze(false)
							slasher:SetImpervious(false)
						end
					end)

					break
				end
			end
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

function SLASHER.OnPrimaryFire(slasher)
	if IsValid(slasher.TackledPlayer) then
		return
	end

	if slasher:IsFrozen() then
		return 
	end

	if not slasher:GetNWBool("CloakTackle") then
		slasher:SetNWBool("CloakTackle", true)
		slasher:SetNWBool("CloakTackling", true)
		slasher.TackledPlayer = nil

		if slasher:IsOnGround() then
			slasher:SetVelocity(slasher:GetForward() * 500)
		end

		slasher:Freeze(true)

		timer.Simple(0.8, function()
			slasher:SetNWBool("CloakTackling", false)
			--SLASHER.TackleFail(slasher)
		end)
	end
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("CloakTackle") or ply:GetNWBool("CloakTackling")
end

function SLASHER.Animator(ply, veloc)
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

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/bababooey/babastep_0" .. idx .. ".mp3",
			identifier = "CovenantCloakFootstep" .. idx,
			minDistance = 200,
			maxDistance = 500,
			entity = ply,
			volume = 1,
			fadeIn = 0,
			unreliable = true,
		})
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_covenantcloak"))
	hud:SetTitle("CovenantCloak")
	
	hud:AddControl("LMB", "tackle", Material("slashco/ui/icons/slasher/s_0"))
	
	local surveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
	hook.Add("HUDPaint", "SlashCoZanySurvey", function()
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			hook.Remove("HUDPaint", "SlashCoZanySurvey")
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:CanBeSeen() then
				continue
			end

			if survivor:GetNWBool("MarkedByCloaks") then
				local pos = survivor:WorldSpaceCenter():ToScreen()

				if pos.visible then
					surface.SetMaterial(surveyNoticeIcon)
					surface.DrawTexturedRect(pos.x - ScrW() / 32, pos.y - ScrW() / 32, ScrW() / 16, ScrW() / 16)
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "CovenantCloak")