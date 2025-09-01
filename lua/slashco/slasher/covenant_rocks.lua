local SLASHER = {}

SLASHER.Name = "CovenantRocks"
SLASHER.ID = "covenantrocks"
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Moderate
SLASHER.IsSelectable = false
SLASHER.Model = "models/slashco/slashers/covenant/rocks.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 275
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 137
SLASHER.ChaseRange = 1500
SLASHER.ChaseRadius = 0.7
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 0
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = ""
SLASHER.Description = ""
SLASHER.ProTip = ""
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★☆☆"

function SLASHER.OnSpawn(slasher)
	slasher:SetNWBool("CanChase", true)

	slasher.ShockCooldown = 0
end

function SLASHER.OnTickBehaviour(slasher)
	local ShockCD = slasher.ShockCooldown or 0 --Shock cooldown
	
	if ShockCD > 0 then
		slasher.ShockCooldown = ShockCD - FrameTime()
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	if not slasher:GetNWBool("InSlasherChaseMode") then
		return
	end

	if not IsValid(target) or not target:IsPlayer() then
		return
	end
	
	if target:Team() ~= TEAM_SURVIVOR then
		return
	end
	
	if slasher:GetPos():Distance(target:GetPos()) >= 137 then
		return
	end

	if slasher.ShockCooldown < 0.01 then
		slasher:SetNWBool("RockPunching", false)
		timer.Remove("RockPunchDecay")
		slasher.ShockCooldown = 2

		timer.Simple(0.3, function()
			if not IsValid(slasher) then
				return
			end

			if SERVER then
				local target1 = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(137, 0, 0)),
						Vector(-30, -30, -60), Vector(30, 30, 60), 25, DMG_SLASH, 5, false)

				if target1:IsPlayer() then
					if target1:Team() ~= TEAM_SURVIVOR then
						return
					end
					
					target1:EmitSound("ambient/energy/spark"..tostring(math.random(1,6))..".wav", 100, 100, 0.25)
					local vec, ang = slasher:GetBonePosition(slasher:LookupBone("Hand.R"))
					local vPoint = vec
					local lightning = EffectData()
					lightning:SetOrigin(vPoint + target1:GetPos() + Vector(0, 0, 0))
					lightning:SetStart(Vector(0, 0, 0))
					lightning:SetAttachment(0)
					util.Effect("rocks_lightning", lightning)
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

		end)
	end
end

function SLASHER.Animator(ply)
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

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/bababooey/babastep_0" .. idx .. ".mp3",
			identifier = "CovenantRocksFootstep" .. idx,
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
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_rocks"))
	hud:SetTitle("CovenantRocks")
	
	hud:AddControl("LMB", "shock", Material("slashco/ui/icons/slasher/s_0"))
	hud:UntieControl("LMB")
	hud:TieControlVisible("LMB", "InSlasherChaseMode", false, false, true)
	
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

SlashCo.RegisterSlasher(SLASHER, "CovenantRocks")