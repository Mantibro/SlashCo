 local SLASHER = {}

SLASHER.PlayersToBecomePartOfCovenant = {}

SLASHER.Name = "The Covenant"
SLASHER.ID = 18
SLASHER.Class = 1
SLASHER.DangerLevel = 1
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/covenant/covenant.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 297
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.7
SLASHER.ChaseDuration = 160.0
SLASHER.ChaseCooldown = 7
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = "slashco/slasher/covenant_chase.wav"
SLASHER.KillSound = "slashco/slasher/"
SLASHER.Description = "Covenant_desc"
SLASHER.ProTip = "Covenant_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★☆☆"

SLASHER.OnSpawn = function(slasher)
	slasher:SetNWBool("CanChase", true)
end

SLASHER.PickUpAttempt = function(ply)
	return false
end

SLASHER.SummonCovenantMembers = function()
	for _, v in ipairs(SLASHER.PlayersToBecomePartOfCovenant) do
		local clk = player.GetBySteamID64(v.steamid)
		SlashCo.SelectSlasher("CovenantCloak", v.steamid)
		clk:SetTeam(TEAM_SLASHER)
		clk:Spawn()
	end
end

SLASHER.SummonRocks = function(vic)
	SlashCo.SelectSlasher("CovenantRocks", vic:SteamID64())
	vic:SetTeam(TEAM_SLASHER)
	vic:Spawn()
end

SLASHER.OnTickBehaviour = function(slasher)
	for _, cloak in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		--Sync the chase for every slasher, meaning every covenant member

		if slasher:GetNWBool("InSlasherChaseMode") then
			if not cloak:GetNWBool("InSlasherChaseMode") then
				SlashCo.StartChaseMode(cloak)
			end

			cloak.CurrentChaseTick = 0
		else
			if cloak:GetNWBool("InSlasherChaseMode") then
				SlashCo.StopChase(cloak)
			end
		end
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if not slasher:GetNWBool("CovenantSummoned") then
		if not slasher:GetNWBool("CovenantSummoning") then
			--local dist = slasher:SlasherValue("KillDistance", 135)

			if IsValid(target) and target:IsPlayer() then
				target:Kill()

				timer.Simple(FrameTime(), function()
					local ragdoll = target.DeadBody
					--[[ragdoll:SetModel("models/player/corpse1.mdl")
					ragdoll:SetPos(slasher:LocalToWorld( Vector(20,0,5) ))
					ragdoll:SetNoDraw(false)
					ragdoll:Spawn()]]

					local physCount = ragdoll:GetPhysicsObjectCount()

					timer.Simple(2, function()
						for i = 0, (physCount - 1) do
							local PhysBone = ragdoll:GetPhysicsObjectNum(i)

							if PhysBone:IsValid() then
								PhysBone:EnableGravity(false)
							end
						end
					end)

					timer.Simple(4, function()
						SLASHER.SummonRocks(slasher.PlayerToBecomeRocks)
						slasher.PlayerToBecomeRocks:Freeze(true)

						timer.Simple(3, function()
							slasher.PlayerToBecomeRocks:Freeze(false)
							slasher.PlayerToBecomeRocks:SetNWBool("RocksBeingSummoned", false)
						end)
					end)

					timer.Simple(6, function()
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

						slasher:SetNWBool("CovenantSummoning", false)

						slasher:Freeze(false)
					end)

					slasher:EmitSound("slashco/slasher/ltg_summoning.mp3")

					slasher.PlayerToBecomeRocks = target
					target:SetNWBool("RocksBeingSummoned", true)

					slasher:SetNWBool("CovenantSummoning", true)
					slasher:Freeze(true)
				end)
			end
		end
	end
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
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

SLASHER.Footstep = function()
	return true
end

SlashCo.RegisterSlasher(SLASHER, "Covenant")