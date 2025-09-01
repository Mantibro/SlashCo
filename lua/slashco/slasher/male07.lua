local SLASHER = {}

SLASHER.Name = "Male_07"
SLASHER.ID = 6
SLASHER.Class = SlashCo.SlasherClass.Umbra
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
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
SLASHER.ChaseMusic = "slashco/slasher/male07/male07_chase.ogg"
SLASHER.KillSound = "slashco/slasher/male07/male07_kill.mp3"
SLASHER.Description = "Male07_desc"
SLASHER.ProTip = "Male07_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★☆☆"
SLASHER.PrimaryDamage = 50 -- How much damage he does with his primary attack.
SLASHER.GameProgressMult = 1 -- Used to multiply the GameProgress when deciding if he should become a monster. Raising it will allow him to enter the monster form earlier.

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.GameProgressMult = math.max(1 + SO + (0.05 * additionalSurvivors), 0.5)
	SLASHER.PrimaryDamage = 50 + (SO * 50) + (2 * additionalSurvivors)

	SLASHER.ProwlSpeed = 100 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 302 + (7.5 * additionalSurvivors)
	if additionalSurvivors > 0 then -- Only increase the chase duration if we have more than the default survivors.
		SLASHER.ChaseDuration = 5.0 + (1 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	slasher.MaleState = 1
	slasher.TimeChasingAsHuman = 0
	slasher.MaleCooldown = 0
	slasher.SlashCooldown = 0
end

local monsterModelName = "models/slashco/slashers/male_07/male_07_monster.mdl"
local maleModelName = "models/Humans/Group01/male_07.mdl"
function SLASHER.Precache()
	SlashCo.PrecacheModel(monsterModelName)
	SlashCo.PrecacheModel(maleModelName)
end

function SLASHER.OnTickBehaviour(slasher)
	local State = slasher.MaleState or 0 --State
	local ChaseAsHuman = slasher.TimeChasingAsHuman or 0 --Time Spent Human Chasing
	local MaleCD = slasher.MaleCooldown or 0 --Cooldown
	local SlashCD = slasher.SlashCooldown or 0 --Slash Cooldown

	local eyesight_final = SLASHER.Eyesight
	local perception_final = SLASHER.Perception

	if MaleCD > 0 then
		slasher.MaleCooldown = MaleCD - FrameTime()
	end
	if SlashCD > 0 then
		slasher.SlashCooldown = SlashCD - FrameTime()
	end

	if State == 0 then
		--Specter mode

		prowl_final = 300
		chase_final = 300
		perception_final = 0.0
		eyesight_final = 10

		slasher:SetNWBool("CanKill", false)
		slasher:SetNWBool("CanChase", false)
		slasher:SetImpervious(true)
	elseif State == 1 then
		--Human mode

		prowl_final = 100
		chase_final = 302
		perception_final = 1.0
		eyesight_final = 2

		slasher:SetNWBool("CanKill", true)
		slasher:SetNWBool("CanChase", true)
		slasher:SetImpervious(false)

		if slasher.CurrentChaseTick == 99 then
			slasher.CurrentChaseTick = 0
		end
	elseif State == 2 then
		--Monster mode

		prowl_final = 150
		chase_final = 285
		perception_final = 1.5
		eyesight_final = 5

		slasher:SetNWBool("CanKill", false)
		slasher:SetImpervious(false)
	end

	if slasher:GetNWBool("InSlasherChaseMode") then
		if State == 1 then
			slasher.TimeChasingAsHuman = ChaseAsHuman + FrameTime()

			--Timer - 10 seconds + Game Progress (1-10) ^ 3 (SO - x2)

			if ChaseAsHuman > 1 + (SlashCo.CurRound.GameProgress * 1.5) + (0.75 * math.pow(SlashCo.CurRound.GameProgress, 2)) * SLASHER.GameProgressMult then
				--Become Monster

				slasher:SetModel(monsterModelName)

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

				slasher.MaleState = 2
			end
		end
	else
		slasher.TimeChasingAsHuman = 0
	end

	if slasher:GetNWInt("Male07State") ~= State then
		slasher:SetNWInt("Male07State", State)
	end

	slasher:SetNWFloat("Slasher_Eyesight", eyesight_final)
	slasher:SetNWInt("Slasher_Perception", perception_final)
end

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher.MaleState == 1 then
		SlashCo.Jumpscare(slasher, target)
		return
	end

	if slasher.MaleState == 0 then
		return
	end

	if slasher.SlashCooldown < 0.01 then
		slasher:SetNWBool("Male07Slashing", false)
		timer.Remove("Male07SlashDecay")
		slasher.SlashCooldown = 2

		timer.Simple(0.5, function()
			slasher:EmitSound("slashco/slasher/trollge/trollge_swing.mp3")

			if SERVER then
				local target1 = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 60)),
						Vector(-30, -40, -60), Vector(30, 40, 60), SLASHER.PrimaryDamage, DMG_SLASH, 2, false)

				if not target1:IsValid() then
					return
				end

				if target1:IsPlayer() then
					if target1:Team() ~= TEAM_SURVIVOR then
						return
					end

					local vPoint = target1:GetPos() + Vector(0, 0, 50)
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					target1:EmitSound("slashco/slasher/trollge/trollge_hit.mp3")
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

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher, target)
	if slasher.MaleCooldown > 0 or slasher:GetNWBool("InSlasherChaseMode") then
		return
	end

	if IsValid(target) and target:GetClass() == "sc_maleclone" and slasher:GetPos():Distance(target:GetPos()) < 150 then
		slasher:EmitSound("slashco/slasher/male07/male07_possess.mp3")

		slasher:SetPos(target:GetPos())
		slasher:SetEyeAngles(target:EyeAngles())
		target:Remove()

		slasher:SetModel(maleModelName)

		slasher:SetColor(Color(255, 255, 255, 255))
		slasher:DrawShadow(true)
		slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		slasher:SetVisible(true)
		slasher:SetMoveType(MOVETYPE_WALK)

		slasher.MaleState = 1
		slasher.CurrentChaseTick = 0
		slasher.MaleCooldown = 3

		slasher:SetWalkSpeed(100)
		slasher:SetRunSpeed(100)

		return
	end

	if slasher.MaleState > 0 then
		slasher:SetModel(maleModelName)

		slasher:SetVisible(false)

		SlashCo.CreateItem("sc_maleclone", slasher:GetPos(), slasher:GetAngles())

		slasher.MaleState = 0
		slasher:EmitSound("slashco/slasher/male07/male07_unpossess" .. math.random(1, 2) .. ".mp3")
		slasher.MaleCooldown = 3

		slasher:SetWalkSpeed(300)
		slasher:SetRunSpeed(300)

		return
	end
end

function SLASHER.Animator(ply)
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
	elseif ply:GetModel() == monsterModelName then
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

function SLASHER.OnItemSpawn()
	local diff = SlashCo.CurRound.Difficulty

	for _ = 1, (math.random(0, 6) + (10 * SlashCo.MapSize) + (diff * 4)) do
		SlashCo.CreateItem("sc_maleclone", SlashCo.RandomPosLocator(), angle_zero)
	end
end

function SLASHER.Footstep(ply)
	return not ply:IsVisible()
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

function SLASHER.InitHud(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Male07")

	hud:AddControl("R", "possess vessel", possessTable)
	hud:ChaseAndKill()

	hud.prevState = not GameData.LocalPlayer:GetNWInt("Male07State")
	hud.prevPossess = true
	function hud.AlsoThink()
		local target = GameData.LocalPlayer:GetEyeTrace().Entity
		local curState = GameData.LocalPlayer:GetNWInt("Male07State")

		if target:GetClass() == "sc_maleclone" and GameData.LocalPlayer:GetPos():Distance(target:GetPos()) < 150
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
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Male07") == true then
			if GameData.LocalPlayer.male_f == nil then
				GameData.LocalPlayer.male_f = 0
			end
			GameData.LocalPlayer.male_f = GameData.LocalPlayer.male_f + (FrameTime() * 20)
			if GameData.LocalPlayer.male_f > 49 then
				return
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_6")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.male_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.male_f = nil
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Male07")