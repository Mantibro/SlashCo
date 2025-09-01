local SLASHER = {}

SLASHER.Name = "The Mindblower" -- unfinished slasher, code may be messy or not even working
SLASHER.Aliases = {
	"Pancake Hater",
	"Waffle Enthusiast",
}
SLASHER.ID = "22"
SLASHER.Class = SlashCo.SlasherClass.Demon
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = false
SLASHER.Model = "models/Humans/Group01/male_05.mdl" -- placeholder
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 200
SLASHER.ChaseSpeed = 255
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 100
SLASHER.ChaseRange = 1500
SLASHER.ChaseRadius = 0.9
SLASHER.ChaseDuration = 25.0
SLASHER.ChaseCooldown = 5
SLASHER.JumpscareDuration = 3.0
SLASHER.ChaseMusic = "slashco/slasher/mindblower_chase.wav"
SLASHER.KillSound = "slashco/slasher/mindblower_pancakeblow.mp3"
SLASHER.Description = "Mindblower_desc"
SLASHER.ProTip = "Mindblower_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★☆☆☆"
SLASHER.SurvivorSpeedAddition = 0 -- Additional Survivor Speed added for each survivor in range
SLASHER.PacificationAddition = 0 -- Additional Pacification added each frame.

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.SurvivorSpeedAddition = 0.02 * SO
	SLASHER.PacificationAddition = 0.04 * SO
end

function SLASHER.OnSpawn(slasher)
	SlashCo.CreateItem("sc_pancake", SlashCo.RandomPosLocator(), Angle(0, 0, 0))
	slasher:SetNWBool("CanKill", true)
	slasher:SetNWBool("CanChase", true)
end

function SLASHER.OnTickBehaviour(slasher)
	local SurvSpeed = slasher.SurvivorSpeed or 0 --Survivor speed decrease when being chased
	local Pacification = slasher.Pacification or 0 --Pacification
	local _ents = ents.FindInSphere(self:GetPos())
	
	for _, v in ipairs(_ents) do
		if v:IsPlayer() and v:Team() == TEAM_SURVIVOR and v:GetPos():Distance(slasher:GetPos()) < 1700 and SurvSpeed < 160 and slasher:GetNWBool("InSlasherChaseMode") then
			slasher.SurvivorSpeed = SurvSpeed + (FrameTime() + SLASHER.SurvivorSpeedAddition) + (FrameTime() * 0.5)
			v:SetSlowWalkSpeed(SlowWalkSpeed - (SurvSpeed / 0.5))
			v:SetWalkSpeed(WalkSpeed - (SurvSpeed / 0.5))
			v:SetRunSpeed(RunSpeed - (SurvSpeed / 0.5))
		else
			slasher.SurvivorSpeed = 0
		end
	end
	
	if Pacification > 0 then
		slasher.Pacification = Pacification - (FrameTime() + SLASHER.PacificationAddition)
		slasher:SetNWBool("CanKill", false)
		slasher:SetNWBool("CanChase", false)
	else
		slasher:SetNWBool("CanKill", true)
		slasher:SetNWBool("CanChase", true)
		slasher:SetNWBool("DemonPacified", false)
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	SlashCo.Jumpscare(slasher, target)
	
	if target:GetNWBool("SurvivorBeingJumpscared") then
		target:Kill()
		timer.Simple(FrameTime(), function()
			local ragdoll = target.DeadBody

			local physCount = ragdoll:GetPhysicsObjectCount()

			timer.Simple(0.1, function()
				slasher:Freeze(true)
				for i = 0, (physCount - 1) do
					local PhysBone = ragdoll:GetPhysicsObjectNum(i)

					if PhysBone:IsValid() then
						PhysBone:EnableGravity(false)
					end
				end
			end)
			
			timer.Simple(2, function()
				local explosion = EffectData()
				explosion:SetOrigin(ragdoll:GetPos() + Vector(0, 0, 0))
				util.Effect("ExplosionCore_wall", explosion)
				local Dissolver = ents.Create("env_entity_dissolver")
				timer.Simple(1, function()
					if IsValid(Dissolver) then
						Dissolver:Remove() -- backup edict save on error
					end
				end)

				Dissolver.Target = "dissolve" .. ragdoll:EntIndex()
				Dissolver:SetKeyValue("dissolvetype", 0)
				Dissolver:SetKeyValue("magnitude", 0)
				Dissolver:SetPos(ragdoll:GetPos())
				Dissolver:SetPhysicsAttacker(slasher)
				Dissolver:Spawn()

				ragdoll:SetName(Dissolver.Target)

				Dissolver:Fire("Dissolve", Dissolver.Target, 0)
				Dissolver:Fire("Kill", "", 0.1)

				slasher:Freeze(false)
			end)
		end)
	end
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher, target)
	if not IsValid(target) or target:GetClass() ~= "sc_pancake" then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) >= 150 then
		return
	end
	
	slasher:Freeze(true)
	slasher:EmitSound("slashco/slasher/mindblower_pancakeblow.mp3")

	timer.Simple(2.5, function()
		if not IsValid(slasher) then
			return
		end
		
		slasher:SetNWBool("DemonPacified", true)
		slasher:Freeze(false)
		if IsValid(target) then
			local explosion = EffectData()
			explosion:SetOrigin(target:GetPos() + Vector(0, 0, 0))
			util.Effect("ExplosionCore_wall", explosion)
			target:Remove()
		end
	end)

end

function SLASHER.OnSpecialAbilityFire(slasher)
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("walk_all")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("run_magic")
		end
	else
		if not chase then
			ply.CalcSeqOverride = ply:LookupSequence("jump_slam")
		else
			ply.CalcSeqOverride = ply:LookupSequence("jump_magic")
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("walk_all")
		else
			ply.CalcIdeal = ACT_RUN
			ply.CalcSeqOverride = ply:LookupSequence("run_magic")
		end
	else
		ply.CalcIdeal = ACT_JUMP
		ply.CalcSeqOverride = ply:LookupSequence("jump_magic")
	end
	
	ply:SetPoseParameter("move_x", ply:GetVelocity():Length() / 100)
	if ply:GetVelocity():Length() < 30 then
		ply.CalcIdeal = ACT_IDLE
		ply.CalcSeqOverride = ply:LookupSequence("idle_all_01")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER not ply:GetNWBool("InSlasherChaseMode") then
		return false
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_0"))
	hud:SetTitle("Mindblower")
	hud:AddControl("LMB", "blow survivor", Material("slashco/ui/icons/slasher/s_0"))
	hud:AddControl("RMB", "chase", Material("slashco/ui/icons/slasher/s_0"))
	hud:AddControl("R", "blow pancake", Material("slashco/ui/icons/slasher/s_0"))
end

SlashCo.RegisterSlasher(SLASHER, "Mindblower")
