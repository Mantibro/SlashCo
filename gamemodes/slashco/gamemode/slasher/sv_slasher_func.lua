local SlashCo = SlashCo

SlashCo.SelectSlasher = function(slasher_name, plyid)
	print(slasher_name)
	SlashCo.CurRound.Slashers[plyid] = {}
	SlashCo.CurRound.Slashers[plyid].SlasherID = slasher_name
	SlashCo.CurRound.Slashers[plyid].GasCanMod = SlashCoSlashers[slasher_name].GasCanMod
end

SlashCo.ApplySlasherToPlayer = function(ply)
	if SlashCo.CurRound.Slashers[ply:SteamID64()] ~= nil then
		--Set the correct Slasher
		print("Assigning the correct Slasher to the player.")
		ply:SetNWString("Slasher", SlashCo.CurRound.Slashers[ply:SteamID64()].SlasherID)
	end
end

SlashCo.PrepareSlasherForSpawning = function()
	--[[

	If the Difficulty is Hard, the Slasher immediately spawns with them. On other difficulties the Slasher has a spawn delay.
	(1,2 - 30 seconds), (0 - 60 seconds)
	(The Delay is cancelled once the Survivors have performed any kind of action on a Generator).
	The Slasher will spawn at a spawn powint furthest away from the Survivors.

	]]

	if SERVER then
		local delay = 1
		delay = 1 + ((4 - SlashCo.CurRound.Difficulty)) * 20

		print("[SlashCo] Slasher set to spawn in " .. delay .. " seconds.")

		timer.Simple(delay, function()
			SlashCo.SpawnSlasher()
		end)
	end
end

local SlasherSpawned

SlashCo.SpawnSlasher = function()
	if SERVER then
		if not SlasherSpawned then
			print("[SlashCo] Spawning Slasher...")

			if SlashCo.CurRound.SlashersToBeSpawned then
				for _, p in ipairs(SlashCo.CurRound.SlashersToBeSpawned) do
					local rand = math.random(1, #SlashCo.CurConfig.Spawnpoints.Slasher)

					local pos = Vector(SlashCo.CurConfig.Spawnpoints.Slasher[rand].pos[1],
							SlashCo.CurConfig.Spawnpoints.Slasher[rand].pos[2],
							SlashCo.CurConfig.Spawnpoints.Slasher[rand].pos[3])
					local ang = Angle(0, SlashCo.CurConfig.Spawnpoints.Slasher[rand].ang, 0)

					p:SetTeam(TEAM_SLASHER)
					p:Spawn()
					p:SetPos(pos)
					p:SetAngles(ang)

					SlashCo.OnSlasherSpawned(p)
				end

				SlasherSpawned = true
			else
				print("[SlashCo] Error! Cannot spawn Slasher as they are not prepared for spawning or the player was not assigned correctly!")
			end
		end
	end
end

SlashCo.OnSlasherSpawned = function(ply)
	ply:SetRunSpeed(SlashCoSlashers[ply:GetNWString("Slasher")].ProwlSpeed)
	ply:SetWalkSpeed(SlashCoSlashers[ply:GetNWString("Slasher")].ProwlSpeed)

	ply.ChaseActivationCooldown = 0
	ply.KillDelayTick = 0
	ply.CurrentChaseTick = 0
	ply.SlasherValue1 = 0
	ply.SlasherValue2 = 0
	ply.SlasherValue3 = 0
	ply.SlasherValue4 = 0
	ply.SlasherValue5 = 0

	ply:SlasherFunction("OnSpawn")
end


--On-Tick Behaviour

hook.Add("Tick", "HandleSlasherAbilities", function()
	local gens = ents.FindByClass("sc_generator")
	if #gens < 1 then
		return
	end

	local SO = SlashCo.CurRound.OfferingData.SO

	--Calculate the Game Progress Value
	--The Game Progress Value - Amount of fuel poured into the Generator + amount of batteries inserted (1 - 10)
	local totalProgress = 0
	for _, v in ipairs(gens) do
		totalProgress = totalProgress + (SlashCo.GasCansPerGenerator - (v.CansRemaining or SlashCo.GasCansPerGenerator)) + ((v.HasBattery and 1) or 0)
	end
	if SlashCo.CurRound.GameProgress > -1 then
		SlashCo.CurRound.GameProgress = totalProgress
	end

	for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		local slasher = v
		local dist = slasher:SlasherValue("ChaseRange", 600) + (SO * 250)

		--Handle The Chase Functions \/ \/ \/
		--SlashCoSlashers[slasher:GetNWString("Slasher")].IsChasing = slasher:GetNWBool("InSlasherChaseMode")
		if slasher:GetNWBool("CanChase") == false then
			slasher.CurrentChaseTick = 99
		end

		if slasher.ChaseActivationCooldown > 0 then
			slasher.ChaseActivationCooldown = slasher.ChaseActivationCooldown - FrameTime()
		end

		if slasher:GetNWBool("InSlasherChaseMode") then
			slasher.CurrentChaseTick = slasher.CurrentChaseTick + FrameTime()

			--local inv = (1 - SlashCoSlashers[slasher:GetNWString("Slasher")].ChaseRadius) / 2
			local inv = -0.2

			local find = ents.FindInCone(slasher:GetPos(), slasher:GetEyeTrace().Normal, dist * 2,
					slasher:SlasherValue("ChaseRadius", 0.91) + inv)
			local find_p = NULL

			for p = 1, #find do
				if find[p]:IsPlayer() and find[p]:Team() == TEAM_SURVIVOR then
					slasher.CurrentChaseTick = 0
					find_p = find[p]
				end
			end

			if slasher:GetEyeTrace().Entity:IsPlayer() and slasher:GetEyeTrace().Entity:Team() == TEAM_SURVIVOR and slasher:GetPos():Distance(slasher:GetEyeTrace().Entity:GetPos()) < dist * 2 then
				slasher.CurrentChaseTick = 0
				find_p = slasher:GetEyeTrace().Entity
			end

			if IsValid(find_p) and not find_p:GetNWBool("SurvivorChased") then
				find_p:SetNWBool("SurvivorChased", true)
			end

			if slasher.CurrentChaseTick > slasher:SlasherValue("ChaseDuration", 10) then
				SlashCo.StopChase(slasher)
			end

			if not slasher:GetNWBool("InSlasherChaseMode") then
				for p = 1, team.NumPlayers(TEAM_SURVIVOR) do
					local ply = team.GetPlayers(TEAM_SURVIVOR)[p]
					if ply:GetNWBool("SurvivorChased") then
						ply:SetNWBool("SurvivorChased", false)
					end
				end
			end
		end

		--Handle The Chase Functions /\ /\ /\

		--Other Shared Functionality:

		if slasher.KillDelayTick > 0 then
			slasher.KillDelayTick = slasher.KillDelayTick - 0.01
		end

		slasher:SlasherFunction("OnTickBehaviour")
	end
end)

SlashCo.Jumpscare = function(slasher, target)
	if not slasher:GetNWBool("CanKill") then
		return
	end

	if slasher.KillDelayTick > 0 then
		return
	end

	--[[
	slasher:LagCompensation(true)
	local target = slasher:GetEyeTrace().Entity
	slasher:LagCompensation(false)
	--]]

	if not IsValid(target) or not target:IsPlayer() then
		return
	end

	if target:Team() ~= TEAM_SURVIVOR then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) > slasher:SlasherValue("KillDistance", 135) and not target:GetNWBool("SurvivorBeingJumpscared") then
		return
	end

	target:SetNWBool("SurvivorBeingJumpscared", true)
	target:SetNWBool("SurvivorJumpscare_" .. slasher:GetNWString("Slasher"), true)
	target:Freeze(true)

	slasher:SetNWBool("CanChase", false)
	slasher:EmitSound(slasher:SlasherValue("KillSound"))
	slasher:Freeze(true)
	slasher.KillDelayTick = slasher:SlasherValue("KillDelay", 3)

	timer.Simple(slasher:SlasherValue("JumpscareDuration", 1.5), function()
		if IsValid(target) then
			target:SetNWBool("SurvivorBeingJumpscared", false)
			target:SetNWBool("SurvivorJumpscare_" .. slasher:GetNWString("Slasher"), false)
			target:EmitSound("slashco/survivor/effectexpire_breath.mp3")
			target:Freeze(false)
			target:Kill()
		end

		if IsValid(slasher) then
			slasher:Freeze(false)
			slasher.CurrentChaseTick = 0
			slasher:SetNWBool("CanChase", true)
		end
	end)

	return true
end

SlashCo.StopChase = function(slasher)
	slasher:SetNWBool("InSlasherChaseMode", false)
	slasher:SetRunSpeed(slasher:SlasherValue("ProwlSpeed", 150))
	slasher:SetWalkSpeed(slasher:SlasherValue("ProwlSpeed", 150))
	slasher:StopSound(slasher:SlasherValue("ChaseMusic"))
	slasher.ChaseActivationCooldown = slasher:SlasherValue("ChaseCooldown", 3)

	timer.Simple(0.25, function()
		if not IsValid(slasher) then
			return
		end
		slasher:StopSound(slasher:SlasherValue("ChaseMusic"))
	end)

	for _, pl in ipairs(player.GetAll()) do
		if pl:GetNWBool("SurvivorChased") then
			pl:SetNWBool("SurvivorChased", false)
		end
	end
end

SlashCo.StartChaseMode = function(slasher)
	if slasher.ChaseActivationCooldown > 0 then
		return
	end

	if not slasher:GetNWBool("CanChase") then
		return
	end

	if slasher:GetNWBool("InSlasherChaseMode") then
		SlashCo.StopChase(slasher)
		return
	end

	slasher:LagCompensation(true)
	local trace = slasher:GetEyeTrace()
	slasher:LagCompensation(false)

	local target
	local isFound = false
	local dist = slasher:SlasherValue("ChaseRange", 1000)
	if trace.Entity:IsPlayer() and trace.Entity:Team() == TEAM_SURVIVOR
			and slasher:GetPos():Distance(trace.Entity:GetPos()) < dist then

		target = trace.Entity
		isFound = true
	end

	if not isFound then
		local find = ents.FindInCone(slasher:GetPos(), trace.Normal, dist, slasher:SlasherValue("ChaseRadius", 0.91))

		for i = 1, #find do
			if find[i]:IsPlayer() and find[i]:Team() == TEAM_SURVIVOR then
				target = find[i]
				break
			end
		end

		if not IsValid(target) then
			return
		end

		local tr = util.TraceLine({
			start = slasher:EyePos(),
			endpos = target:WorldSpaceCenter(),
			filter = slasher
		})

		if tr.Entity ~= target then
			return
		end

		if slasher:GetPos():Distance(target:GetPos()) >= dist then
			return
		end
	end

	slasher:SetNWBool("InSlasherChaseMode", true)
	slasher.CurrentChaseTick = 0
	slasher.ChaseActivationCooldown = slasher:SlasherValue("ChaseCooldown", 3)
	slasher:SetRunSpeed(slasher:SlasherValue("ChaseSpeed"))
	slasher:SetWalkSpeed(slasher:SlasherValue("ChaseSpeed"))
	PlayGlobalSound(slasher:SlasherValue("ChaseMusic"), 95, slasher)
end

SlashCo.BustDoor = function(slasher, target, force)
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "prop_door_rotating" then
		return
	end

	if SERVER then
		target:Fire("Open")
	end

	timer.Simple(0.05, function()
		local tr = util.TraceLine({
			start = slasher:EyePos(),
			endpos = slasher:EyePos() + slasher:GetForward() * 10000,
			filter = slasher
		})

		local trace = util.GetSurfaceData(tr.SurfaceProps).name

		if not target:IsValid() then
			return
		end

		local prop = ents.Create("prop_physics")
		local model = target:GetModel()
		prop:SetModel(model)
		prop:SetMoveType(MOVETYPE_NONE)
		--prop:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
		prop:SetPos(target:GetPos() + slasher:GetForward() * 6 + Vector(0, 0, 1))
		prop:SetAngles(target:GetAngles())
		prop:Spawn()
		prop:Activate()
		prop:SetSkin(target:GetSkin())
		local phys = prop:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
		end
		phys:ApplyForceCenter(slasher:GetForward() * force)

		if trace == "wood" then
			target:EmitSound("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav")
		end

		if trace == "metal" then
			target:EmitSound("physics/metal/metal_box_break" .. math.random(1, 2) .. ".wav")
		end

		target:Remove()
	end)
end