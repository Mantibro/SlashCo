local SlashCo = SlashCo

SlashCo.SelectSlasher = function(slasher_name, plyid)
    SlashCo.CurRound.Slashers[plyid] = {}
    SlashCo.CurRound.Slashers[plyid].SlasherID = slasher_name
    SlashCo.CurRound.Slashers[plyid].GasCanMod = SlashCoSlasher[slasher_name].GasCanMod
end

SlashCo.ApplySlasherToPlayer = function(ply)

    if SlashCo.CurRound.Slashers[ply:SteamID64()] ~= nil then
        --Set the correct Slasher
       print("Assinging the correct Slasher to the player.")
       ply:SetNWBool("Slasher", SlashCo.CurRound.Slashers[ply:SteamID64()].SlasherID)

   end

end

SlashCo.PrepareSlasherForSpawning = function()

    --[[

    If the Difficulty is Hard, the Slasher immediately spawns with them. On other difficulties the Slasher has a spawn delay.
    (1,2 - 30 seconds), (0 - 60 seconds) 
    (The Delay is cancelled once the Survivors have performed any kind of action on a Generator). 
    The Slasher will spawn at a spawn point furthest away from the Survivors.

    ]]

if SERVER then

    local delay = 1

    delay = 1 +( (4 - SlashCo.CurRound.Difficulty ) ) * 20

    print("[SlashCo] Slasher set to spawn in "..delay.." seconds.")

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
                    rand = math.random( 1, #SlashCo.CurConfig.Spawnpoints.Slasher)

                    local pos = Vector(SlashCo.CurConfig.Spawnpoints.Slasher[rand].pos[1],SlashCo.CurConfig.Spawnpoints.Slasher[rand].pos[2],SlashCo.CurConfig.Spawnpoints.Slasher[rand].pos[3])
                    local ang = Angle( 0, SlashCo.CurConfig.Spawnpoints.Slasher[rand].ang ,0 )

                    p:SetTeam(TEAM_SLASHER)
                    p:Spawn()
                    p:SetPos( pos )
                    p:SetAngles( ang )

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

    local plyid = ply:SteamID64()

    if type( SlashCoSlasher[ply:GetNWString("Slasher")].OnSpawn ) ~= "function" then return end

    ply:SetRunSpeed(SlashCoSlasher[ply:GetNWString("Slasher")].ProwlSpeed)
    ply:SetWalkSpeed(SlashCoSlasher[ply:GetNWString("Slasher")].ProwlSpeed)

    ply.ChaseActivationCooldown = 0
    ply.KillDelayTick = 0
    ply.CurrentChaseTick = 0
    ply.SlasherValue1 = 0
    ply.SlasherValue2 = 0
    ply.SlasherValue3 = 0
    ply.SlasherValue4 = 0
    ply.SlasherValue5 = 0

    SlashCoSlasher[ply:GetNWString("Slasher")].OnSpawn(ply)

end



--On-Tick Behaviour

hook.Add("Tick", "HandleSlasherAbilities", function()

    local gens = ents.FindByClass("sc_generator")
    if #gens < 1 then return end

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

for i = 1, #team.GetPlayers(TEAM_SLASHER) do

        local slasher = team.GetPlayers(TEAM_SLASHER)[i]
        local dist = SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseRange + (SO * 250)

        local slasher = team.GetPlayers(TEAM_SLASHER)[i]

        --Handle The Chase Functions \/ \/ \/
        SlashCoSlasher[slasher:GetNWString("Slasher")].IsChasing = slasher:GetNWBool("InSlasherChaseMode")
        if slasher:GetNWBool("CanChase") == false then slasher.CurrentChaseTick = 99 end

        if slasher.ChaseActivationCooldown > 0 then 

            slasher.ChaseActivationCooldown = slasher.ChaseActivationCooldown - FrameTime() 

        end

        if not slasher:GetNWBool("InSlasherChaseMode") then goto CONTINUE end
do
        slasher.CurrentChaseTick = slasher.CurrentChaseTick + FrameTime()

        --local inv = (1 - SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseRadius) / 2
        local inv = -0.2

        local find = ents.FindInCone( slasher:GetPos(), slasher:GetEyeTrace().Normal, dist * 2, SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseRadius + inv )
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

        if IsValid( find_p ) and not find_p:GetNWBool("SurvivorChased") then find_p:SetNWBool("SurvivorChased",true) end

        if slasher.CurrentChaseTick > SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseDuration then 

            slasher:SetNWBool("InSlasherChaseMode", false) 

            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed )
            slasher:StopSound(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseMusic)

            slasher.ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseCooldown

            timer.Simple(0.25, function() 
                slasher:StopSound(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseMusic) 

                for _, pl in ipairs(player.GetAll()) do
                    if pl:GetNWBool("SurvivorChased") then pl:SetNWBool("SurvivorChased",false) end
                end
            end)
        end
end
        ::CONTINUE::

        --Handle The Chase Functions /\ /\ /\

        --Other Shared Functionality:

        if slasher.KillDelayTick > 0 then slasher.KillDelayTick = slasher.KillDelayTick - 0.01 end

        if type( SlashCoSlasher[slasher:GetNWString("Slasher")].OnTickBehaviour ) ~= "function" then return end

        SlashCoSlasher[slasher:GetNWString("Slasher")].OnTickBehaviour(slasher)

end

end)

SlashCo.Jumpscare = function(slasher)

    if not slasher:GetNWBool("CanKill") then return end

    if slasher.KillDelayTick > 0 then return end

    local dist = SlashCoSlasher[slasher:GetNWString("Slasher")].KillDistance
    
    if slasher:GetEyeTrace().Entity:IsPlayer() then
        local target = slasher:GetEyeTrace().Entity	

        if target:Team() ~= TEAM_SURVIVOR then return end

        if slasher:GetPos():Distance(target:GetPos()) < dist and not target:GetNWBool("SurvivorBeingJumpscared") then

            target:SetNWBool("SurvivorBeingJumpscared",true)
            target:SetNWBool("SurvivorJumpscare_"..slasher:GetNWString("Slasher"), true)

            slasher:SetNWBool("CanChase", false)

            slasher:EmitSound(SlashCoSlasher[slasher:GetNWString("Slasher")].KillSound)
                
            target:Freeze(true)
            slasher:Freeze(true)

            slasher.KillDelayTick = SlashCoSlasher[slasher:GetNWString("Slasher")].KillDelay

            timer.Simple(SlashCoSlasher[slasher:GetNWString("Slasher")].JumpscareDuration, function()

                target:SetNWBool("SurvivorBeingJumpscared",false)
                target:SetNWBool("SurvivorJumpscare_"..slasher:GetNWString("Slasher"), false)
                target:EmitSound("slashco/survivor/effectexpire_breath.mp3")

                slasher:Freeze(false)
                target:Freeze(false)
                target:Kill()
                slasher.CurrentChaseTick = 0
                slasher:SetNWBool("CanChase", true)
        
            end)
        end

    end

end

SlashCo.StopChase = function(slasher)

    slasher:SetNWBool("InSlasherChaseMode", false)
    slasher:SetRunSpeed(SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed)
    slasher:SetWalkSpeed(SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed)
    slasher:StopSound(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseMusic)

    timer.Simple(0.25, function()
        if not IsValid(slasher) then
            return
        end
        slasher:StopSound(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseMusic)
    end)

    for _, pl in ipairs(player.GetAll()) do
        if pl:GetNWBool("SurvivorChased") then pl:SetNWBool("SurvivorChased",false) end
    end

end

SlashCo.StartChaseMode = function(slasher)

    if not slasher:GetNWBool("CanChase") then return end

    if slasher.ChaseActivationCooldown > 0 then return end

    slasher.ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseCooldown

    if slasher:GetNWBool("InSlasherChaseMode") then 

        SlashCo.StopChase(slasher)

        return 
    end

    local dist = SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseRange

    local find = ents.FindInCone( slasher:GetPos(), slasher:GetEyeTrace().Normal, dist, SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseRadius )

    local target = NULL

    if slasher:GetEyeTrace().Entity:IsPlayer() and slasher:GetEyeTrace().Entity:Team() == TEAM_SURVIVOR and slasher:GetPos():Distance(slasher:GetEyeTrace().Entity:GetPos()) < dist then
        target = slasher:GetEyeTrace().Entity
        goto FOUND
    end

do

    for i = 1, #find do

        if find[i]:IsPlayer() and find[i]:Team() == TEAM_SURVIVOR then 
            target = find[i]
            break 
        end

    end

    if not target:IsValid() then 
        return
    end

    local tr = util.TraceLine( {
        start = slasher:EyePos(),
        endpos = target:GetPos()+Vector(0,0,50),
        filter = slasher
    } )

    if tr.Entity ~= target then return end
end
    ::FOUND::

    if slasher:GetPos():Distance(target:GetPos()) < dist then

        slasher:SetNWBool("InSlasherChaseMode", true)
        slasher.CurrentChaseTick = 0

    end

    local chase = slasher:GetNWBool("InSlasherChaseMode")

    if chase then 

        slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseSpeed )
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseSpeed  )
        PlayGlobalSound(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseMusic,95,slasher)

    else
        SlashCo.StopChase(slasher)
    end

end

SlashCo.BustDoor = function(slasher, target, force)

    if !target:IsValid() then return end

    if target:GetClass() == "prop_door_rotating" then

        if SERVER then target:Fire("Open") end

        timer.Simple(0.05, function() 

            local tr = util.TraceLine( {
                start = slasher:EyePos(),
                endpos = slasher:EyePos() + slasher:GetForward() * 10000,
                filter = slasher
            } )

            local trace = util.GetSurfaceData( tr.SurfaceProps ).name

            if !target:IsValid() then return end

            local prop = ents.Create( "prop_physics" )
            local model = target:GetModel()
            prop:SetModel(model)
            prop:SetMoveType( MOVETYPE_NONE )
            --prop:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
            prop:SetPos( target:GetPos() + slasher:GetForward()*6 + Vector(0,0,1) )
            prop:SetAngles( target:GetAngles() )
            prop:Spawn()
            prop:Activate()
            prop:SetSkin (target:GetSkin() )
            local phys = prop:GetPhysicsObject()
            if phys:IsValid() then phys:Wake() end
            phys:ApplyForceCenter( slasher:GetForward() * force )

            if trace == "wood" then
                target:EmitSound("physics/wood/wood_crate_break"..math.random(1,5)..".wav")
            end

            if trace == "metal" then
                target:EmitSound("physics/metal/metal_box_break"..math.random(1,2)..".wav")
            end

            target:Remove()

        end)

    end

end