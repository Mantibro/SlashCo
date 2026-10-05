local SLASHER = {}

SLASHER.Name = "Covenant Cloak"
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

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	SLASHER.ChaseDuration = 9.0 + (2 * additionalSurvivors)

	if additionalSurvivors > 0 then
		SLASHER.ProwlSpeed = 150 + (3 * additionalSurvivors)
		SLASHER.ChaseSpeed = 275 + (0.5 * additionalSurvivors)
	end
end

local TACKLE_TIME = 0.8
local TACKLE_SPEED = 500
local TACKLE_FAIL_TIME = 2.5
local SURVIVOR_STUN_TIME = 5.0
local SLASHER_STUN_TIME = 7.0
local NO_JUMP_OR_DUCK = bit.bnot(bit.bor(IN_JUMP, IN_DUCK))
local function isLocked(slasher)
	return CurTime() < slasher:GetNW2Float("CloakLockEnd", 0)
end

local function isTackling(slasher)
	local now = CurTime()
	if now < slasher:GetNW2Float("CloakTackleEnd", 0) then
		return true
	end

	local predictedStart = slasher.CloakPredictedStart
	return predictedStart and now >= predictedStart and now < predictedStart + math.min(TACKLE_TIME, 0.1 + slasher:Ping() / 1000) or false
end

function SLASHER.OnSpawn(slasher)
	slasher:SetNWBool("CanChase", true)
end

function SLASHER.TackleFail(slasher)
	if not IsValid(slasher) then return end
	if slasher.TackledPlayer ~= nil then return end

	slasher:SetNWBool("CloakTackleFail", true)
	slasher:SetNW2Float("CloakLockEnd", CurTime() + TACKLE_FAIL_TIME)

	timer.Simple(TACKLE_FAIL_TIME, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("CloakTackle", false)
		slasher:SetNWBool("CloakTackleFail", false)
		slasher.KillDelayTick = SLASHER.KillDelay
	end)
end

function SLASHER.Move(ply, mv)
	local now = CurTime()
	if CLIENT and mv:KeyPressed(IN_ATTACK) and ply:GetNW2Bool("CloakCanTackle") and not isTackling(ply) then
		ply.CloakPredictedStart = now
	end

	local tackling = isTackling(ply)
	if tackling or isLocked(ply) then
		mv:SetForwardSpeed(tackling and TACKLE_SPEED or 0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)
		mv:SetButtons(bit.band(mv:GetButtons(), NO_JUMP_OR_DUCK))

		if tackling then
			mv:SetMaxSpeed(TACKLE_SPEED)
			mv:SetMaxClientSpeed(TACKLE_SPEED)
		end
	end
end

function SLASHER.OnTickBehaviour(slasher, target)
	if IsValid(slasher.TackledPlayer) then
		if slasher.TackledPlayer:GetNWBool("SurvivorTackled") and not slasher.TackledPlayer:IsFrozen() then
			slasher.TackledPlayer:Freeze(true)
		end

		slasher:SetPos(slasher.TackledPlayer:GetPos() + Vector(10, 0, 0))

		if slasher.TackledPlayer.TackleStruggle ~= nil and slasher.TackledPlayer.TackleStruggle > 50 then
			slasher.TackledPlayer.TackleStruggle = 0
			slasher.TackledPlayer:Freeze(false)
			slasher.TackledPlayer:SetNWBool("SurvivorTackled", false)
			slasher:SetPos(slasher.TackledPlayer:GetPos() + Vector(0, 0, 80))
			slasher.TackledPlayer = nil
			slasher:SetNW2Float("CloakLockEnd", CurTime() + 2.0)
		end
	end

	if slasher:GetNWBool("CloakTackling") then
		if SERVER and not slasher.TackledPlayer then
			for _, ply in ipairs(ents.FindInSphere(slasher:GetPos(), 60)) do
				if ply:IsPlayer() and ply:Team() == TEAM_SURVIVOR and not ply:GetNWBool("SurvivorTackled") then
					slasher.TackledPlayer = ply
					slasher:SetNWBool("CloakTackling", false)
					slasher:SetNWBool("CloakTackle", false)
					slasher:SetNW2Float("CloakTackleEnd", 0)

					ply:SetNWBool("SurvivorTackled", true)
					ply:SetNWBool("MarkedByCloaks", true)
					ply.SlashCo_PushDir = (ply:GetPos() - slasher:GetPos()):GetNormalized()
					ply:SetImpervious(true)
					timer.Simple(SURVIVOR_STUN_TIME, function()
						if not IsValid(ply) then return end

						ply:SetNWBool("SurvivorTackled", false)
						ply:Freeze(false)
						ply:SetImpervious(false)
						if IsValid(slasher) and slasher.TackledPlayer == ply then
							slasher.TackledPlayer.TackleStruggle = 0
							timer.Simple(0.1, function()
								if not IsValid(slasher) then return end

								slasher.TackledPlayer = nil
							end)
						end

						if ply.SlashCo_PushDir then
							local pushStrength = 400
							ply:SetVelocity(ply.SlashCo_PushDir * pushStrength + Vector(0,0,120))
							ply.SlashCo_PushDir = nil
						end
					end)

					-- Stun slasher
					slasher:SetNW2Float("CloakLockEnd", CurTime() + SLASHER_STUN_TIME)
					slasher:SetImpervious(true)
					timer.Simple(SLASHER_STUN_TIME, function()
						if not IsValid(slasher) then return end

						slasher:SetImpervious(false)
						slasher.KillDelayTick = SLASHER.KillDelay

						if not IsValid(ply) then return end
						ply:SetNWBool("MarkedByCloaks", false)
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

	slasher:SetNW2Bool("CloakCanTackle", not IsValid(slasher.TackledPlayer) and not slasher:IsFrozen() and not isLocked(slasher) and slasher.KillDelayTick <= 0 and not slasher:GetNWBool("CloakTackle"))
	slasher:SetEyeSight(SLASHER.Eyesight)
	slasher:SetPerception(SLASHER.Perception)
end

function SLASHER.OnPlayerDeath(slasher, victim)
	if slasher.TackledPlayer ~= victim then return end

	slasher.TackledPlayer = nil
	victim:SetNWBool("SurvivorTackled", false)
	victim:SetNWBool("MarkedByCloaks", false)

	slasher:SetNW2Float("CloakLockEnd", 0)
	slasher:SetImpervious(false)
end

function SLASHER.OnPrimaryFire(slasher)
	if IsValid(slasher.TackledPlayer) then return end
	if slasher:IsFrozen() or isLocked(slasher) then return end
	if slasher.KillDelayTick > 0 then return end
	if slasher:GetNWBool("CloakTackle") then return end

	slasher:SetNWBool("CloakTackle", true)
	slasher:SetNWBool("CloakTackling", true)
	slasher:SetNW2Float("CloakTackleEnd", CurTime() + TACKLE_TIME)
	slasher.TackledPlayer = nil

	timer.Simple(TACKLE_TIME, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("CloakTackling", false)
	end)
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("CloakTackle") or ply:GetNWBool("CloakTackling") or isTackling(ply)
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

	if ply:GetNWBool("CloakTackling") or isTackling(ply) then
		ply.CalcSeqOverride = ply:LookupSequence("zombie_leap_mid")
	end

	if ply:GetNWBool("CloakTackleFail") then
		ply.CalcSeqOverride = ply:LookupSequence("zombie_slump_rise_01")
		if not ply.anim_antispam then
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
			group = "SlasherFootstep",
			minDistance = 200,
			maxDistance = 500,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/covenantcloak"))
	hud:SetTitle("CovenantCloak")

	hud:AddControl("LMB", "tackle", Material("slashco/ui/icons/slasher/unknown"))
end

local cloakNoticeIcon = Material("slashco/ui/particle/icon_survey")
function SLASHER.DrawHUD(localPly)
	for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if not survivor:CanBeSeen() then
			continue
		end

		if survivor:GetNWBool("MarkedByCloaks") then
			local pos = survivor:WorldSpaceCenter():ToScreen()

			if pos.visible then
				surface.SetDrawColor(255, 255, 255, 60)
				surface.SetMaterial(cloakNoticeIcon)
				surface.DrawTexturedRect(pos.x - ScrW() / 32, pos.y - ScrW() / 32, ScrW() / 16, ScrW() / 16)
			end
		end
	end
end

SlashCo.RegisterSlasher(SLASHER, "CovenantCloak")