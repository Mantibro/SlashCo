local SLASHER = {}

SLASHER.Name = "Male_07"
SLASHER.ID = 6
SLASHER.Class = 3
SLASHER.DangerLevel = 3
SLASHER.IsSelectable = true
SLASHER.Model = "models/Humans/Group01/male_07.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 4
SLASHER.ProwlSpeed = 100
SLASHER.ChaseSpeed = 302
SLASHER.Perception = 1.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 160
SLASHER.ChaseRange = 500
SLASHER.ChaseRadius = 0.9
SLASHER.ChaseDuration = 5.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/male07_chase.wav"
SLASHER.KillSound = "slashco/slasher/male07_kill.mp3"
SLASHER.Description = "Male07_desc"
SLASHER.ProTip = "Male07_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★☆☆"

SLASHER.OnSpawn = function(slasher)
	slasher.SlasherValue1 = 1
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --State
	local v2 = slasher.SlasherValue2 --Time Spent Human Chasing
	local v3 = slasher.SlasherValue3 --Cooldown
	local v4 = slasher.SlasherValue4 --Slash Cooldown

	local prowl_final = SLASHER.ProwlSpeed
	local chase_final = SLASHER.ChaseSpeed
	local eyesight_final = SLASHER.Eyesight
	local perception_final = SLASHER.Perception

	if v3 > 0 then
		slasher.SlasherValue3 = v3 - FrameTime()
	end
	if v4 > 0 then
		slasher.SlasherValue4 = v4 - FrameTime()
	end

	if v1 == 0 then
		--Specter mode

		prowl_final = 300
		chase_final = 300
		perception_final = 0.0
		eyesight_final = 10

		slasher:SetNWBool("CanKill", false)
		slasher:SetNWBool("CanChase", false)
	elseif v1 == 1 then
		--Human mode

		prowl_final = 100
		chase_final = 302
		perception_final = 1.0
		eyesight_final = 2

		slasher:SetNWBool("CanKill", true)
		slasher:SetNWBool("CanChase", true)

		if slasher.CurrentChaseTick == 99 then
			slasher.CurrentChaseTick = 0
		end
	elseif v1 == 2 then
		--Monster mode

		prowl_final = 150
		chase_final = 285
		perception_final = 1.5
		eyesight_final = 5

		slasher:SetNWBool("CanKill", false)
	end

	if slasher:GetNWBool("InSlasherChaseMode") then
		if v1 == 1 then
			slasher.SlasherValue2 = v2 + FrameTime()

			--Timer - 10 seconds + Game Progress (1-10) ^ 3 (SO - x2)

			if v2 > 1 + (SlashCo.CurRound.GameProgress * 1.5) + (0.75 * math.pow(SlashCo.CurRound.GameProgress,
					2)) * (1 + SO) then
				--Become Monster

				local modelname = "models/slashco/slashers/male_07/male_07_monster.mdl"
				util.PrecacheModel(modelname)
				slasher:SetModel(modelname)

				slasher:SetNWBool("Male07Transforming", true)
				slasher:SetNWBool("Male07Slashing", false)
				slasher:Freeze(true)

				local vPoint = slasher:GetPos() + Vector(0, 0, 50)
				local bloodfx = EffectData()
				bloodfx:SetOrigin(vPoint)
				util.Effect("BloodImpact", bloodfx)

				slasher:EmitSound("vo/npc/male01/no02.wav")

				slasher:EmitSound("NPC_Manhack.Slice")

				timer.Simple(3, function()
					slasher:SetNWBool("Male07Transforming", false)
					slasher:Freeze(false)

					if slasher:GetNWBool("InSlasherChaseMode") then
						slasher:SetRunSpeed(285)
						slasher:SetWalkSpeed(285)
					end
				end)

				slasher.SlasherValue1 = 2
			end
		end
	else
		slasher.SlasherValue2 = 0
	end

	if slasher:GetNWInt("Male07State") ~= v1 then
		slasher:SetNWInt("Male07State", v1)
	end

	slasher:SetNWFloat("Slasher_Eyesight", eyesight_final)
	slasher:SetNWInt("Slasher_Perception", perception_final)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if slasher.SlasherValue1 == 1 then
		SlashCo.Jumpscare(slasher, target)
		return
	end

	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher.SlasherValue1 == 0 then
		return
	end

	if slasher.SlasherValue4 < 0.01 then
		slasher:SetNWBool("Male07Slashing", false)
		timer.Remove("Male07SlashDecay")
		slasher.SlasherValue4 = 2

		timer.Simple(0.5, function()
			slasher:EmitSound("slashco/slasher/trollge_swing.wav")

			if SERVER then
				local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 60)),
						Vector(-30, -40, -60), Vector(30, 40, 60), 50 + (SO * 50), DMG_SLASH, 2, false)

				if not target:IsValid() then
					return
				end

				if target:IsPlayer() then
					if target:Team() ~= TEAM_SURVIVOR then
						return
					end

					local vPoint = target:GetPos() + Vector(0, 0, 50)
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					target:EmitSound("slashco/slasher/trollge_hit.wav")
				end

				SlashCo.BustDoor(slasher, target, 30000)
			end
		end)

		timer.Simple(0.1, function()
			slasher:SetNWBool("Male07Slashing", true)

			timer.Create("Male07SlashDecay", 1.5, 1, function()
				slasher:SetNWBool("Male07Slashing", false)
			end)
		end)
	end
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher, target)
	if slasher.SlasherValue3 > 0 or slasher:GetNWBool("InSlasherChaseMode") then
		return
	end

	if IsValid(target) and target:GetClass() == "sc_maleclone" and slasher:GetPos():Distance(target:GetPos()) < 150 then
		slasher:EmitSound("slashco/slasher/male07_possess.mp3")

		slasher:SetPos(target:GetPos())
		slasher:SetEyeAngles(target:EyeAngles())
		target:Remove()

		local modelname = "models/Humans/Group01/male_07.mdl"
		util.PrecacheModel(modelname)
		slasher:SetModel(modelname)

		slasher:SetColor(Color(255, 255, 255, 255))
		slasher:DrawShadow(true)
		slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		slasher:SetNoDraw(false)
		slasher:SetMoveType(MOVETYPE_WALK)

		slasher.SlasherValue1 = 1
		slasher.CurrentChaseTick = 0
		slasher.SlasherValue3 = 3

		slasher:SetWalkSpeed(100)
		slasher:SetRunSpeed(100)

		return
	end

	if slasher.SlasherValue1 > 0 then
		local modelname = "models/hunter/plates/plate.mdl"
		util.PrecacheModel(modelname)
		slasher:SetModel(modelname)

		slasher:SetColor(Color(0, 0, 0, 0))
		slasher:DrawShadow(false)
		slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		slasher:SetNoDraw(true)
		--slasher:SetPos(slasher:GetPos() + Vector(0, 0, 60))

		SlashCo.CreateItem("sc_maleclone", slasher:GetPos(), slasher:GetAngles())

		slasher.SlasherValue1 = 0
		slasher:EmitSound("slashco/slasher/male07_unpossess" .. math.random(1, 2) .. ".mp3")
		slasher.SlasherValue3 = 3

		slasher:SetWalkSpeed(300)
		slasher:SetRunSpeed(300)

		return
	end
end

SLASHER.Animator = function(ply)
	local male_slashing = ply:GetNWBool("Male07Slashing")
	local male_transforming = ply:GetNWBool("Male07Transforming")
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if ply:GetModel() == "models/humans/group01/male_07.mdl" then
		if ply:IsOnGround() then
			if not chase then
				ply.CalcIdeal = ACT_WALK
				ply.CalcSeqOverride = ply:LookupSequence("walk_all")
			else
				ply.CalcIdeal = ACT_RUN_SCARED
				ply.CalcSeqOverride = ply:LookupSequence("run_all_panicked")
			end
		else
			ply.CalcIdeal = ACT_JUMP
			ply.CalcSeqOverride = ply:LookupSequence("jump_holding_jump")
		end

		ply:SetPoseParameter("move_x", ply:GetVelocity():Length() / 100)

		if ply:GetVelocity():Length() < 30 then
			ply.CalcIdeal = ACT_IDLE
			ply.CalcSeqOverride = ply:LookupSequence("idle_all")
		end
	elseif ply:GetModel() == "models/slashco/slashers/male_07/male_07_monster.mdl" then
		if not male_slashing and not male_transforming then
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
		else
			ply.CalcSeqOverride = ply:LookupSequence("float")
		end

		if male_slashing and ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("slash"), 0, true)
			ply.anim_antispam = true
		end

		if male_transforming then
			ply.CalcSeqOverride = ply:LookupSequence("transform")

			if ply.anim_antispam == nil or ply.anim_antispam == false then
				ply:SetCycle(0)
				ply.anim_antispam = true
			end
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.OnItemSpawn = function()
	local diff = SlashCo.CurRound.Difficulty

	--SCInfo.Maps[game.GetMap()].SIZE
	for _ = 1, (math.random(0, 6) + (10 * SlashCo.MapSize) + (diff * 4)) do
		SlashCo.CreateItem("sc_maleclone", SlashCo.RandomPosLocator(), angle_zero)
	end
end

SLASHER.Footstep = function(ply)
	if SERVER then
		if ply:GetModel() == "models/hunter/plates/plate.mdl" then
			return true
		else
			return false
		end
	end

	return true
end

local possessTable = {
	["possess vessel"] = Material("slashco/ui/icons/slasher/s_6"),
	["d/possess vessel"] = Material("slashco/ui/icons/slasher/kill_disabled"),
	["unpossess vessel"] = Material("slashco/ui/icons/slasher/s_6_s0")
}

local avatarTable = {
	default = Material("slashco/ui/icons/slasher/s_6"),
	specter = Material("slashco/ui/icons/slasher/s_6_s0"),
	monster = Material("slashco/ui/icons/slasher/s_6_s2")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Male07")

	hud:AddControl("R", "possess vessel", possessTable)
	hud:ChaseAndKill()

	hud.prevState = not LocalPlayer():GetNWInt("Male07State")
	hud.prevPossess = true
	function hud.AlsoThink()
		local target = LocalPlayer():GetEyeTrace().Entity
		local curState = LocalPlayer():GetNWInt("Male07State")

		if target:GetClass() == "sc_maleclone" and LocalPlayer():GetPos():Distance(target:GetPos()) < 150
				or curState ~= 0 then
			if not hud.prevPossess then
				hud:SetControlEnabled("R", true)
				hud.prevPossess = true
			end
		else
			if hud.prevPossess then
				hud:SetControlEnabled("R", false)
				hud.prevPossess = nil
			end
		end

		if curState == hud.prevState then
			return
		end

		local avatar = "default"
		if curState == 0 then
			hud:SetControlText("R", "possess vessel")
			hud:SetControlVisible("LMB", false)
			hud:SetControlVisible("RMB", false)
			hud:ShakeControl("R")
			avatar = "specter"
		else
			if hud.prevState == 0 then
				hud:ShakeControl("R")
			end

			hud:SetControlVisible("LMB", true)
			hud:SetControlVisible("RMB", true)
			hud:SetControlText("R", "unpossess vessel")
		end

		if curState == 2 then
			hud:SetControlText("LMB", "slash")
			hud:UntieControl("LMB")
			timer.Simple(0, function()
				hud:SetControlEnabled("LMB", true)
			end)
			hud:ShakeControl("LMB")
			avatar = "monster"
		else
			hud:SetControlText("LMB", "kill survivor")
			hud:TieControl("LMB", "CanKill")
		end

		hud:SetAvatar(avatar)
		hud.prevState = curState
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Male07") == true then
			if LocalPlayer().male_f == nil then
				LocalPlayer().male_f = 0
			end
			LocalPlayer().male_f = LocalPlayer().male_f + (FrameTime() * 20)
			if LocalPlayer().male_f > 49 then
				return
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_6")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().male_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().male_f = nil
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Male07")