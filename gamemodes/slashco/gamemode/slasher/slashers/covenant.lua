SlashCoSlasher.Covenant = {}

SlashCoSlasher.Covenant.PlayersToBecomePartOfCovenant = {}

SlashCoSlasher.Covenant.Name = "The Covenant"
SlashCoSlasher.Covenant.ID = 18
SlashCoSlasher.Covenant.Class = 1
SlashCoSlasher.Covenant.DangerLevel = 1
SlashCoSlasher.Covenant.IsSelectable = true
SlashCoSlasher.Covenant.Model = "models/slashco/slashers/covenant/covenant.mdl"
SlashCoSlasher.Covenant.GasCanMod = 0
SlashCoSlasher.Covenant.KillDelay = 3
SlashCoSlasher.Covenant.ProwlSpeed = 150
SlashCoSlasher.Covenant.ChaseSpeed = 297
SlashCoSlasher.Covenant.Perception = 1.0
SlashCoSlasher.Covenant.Eyesight = 3
SlashCoSlasher.Covenant.KillDistance = 135
SlashCoSlasher.Covenant.ChaseRange = 1000
SlashCoSlasher.Covenant.ChaseRadius = 0.7
SlashCoSlasher.Covenant.ChaseDuration = 160.0
SlashCoSlasher.Covenant.ChaseCooldown = 7
SlashCoSlasher.Covenant.JumpscareDuration = 1.5
SlashCoSlasher.Covenant.ChaseMusic = "slashco/slasher/covenant_chase.wav"
SlashCoSlasher.Covenant.KillSound = "slashco/slasher/"
SlashCoSlasher.Covenant.Description = [[The Leader Slasher who commands his trusted Cloaks.

-Catching a Survivor will sacrifice their soul, making them become your Covenant Cloak.
-The first Survivor you catch will be handed the Saturn Stick, becoming your most powerful ally, Rocks.
-Without the power of the Saturn Stick, must must rely on your Cloaks to catch Survivors.]]
SlashCoSlasher.Covenant.ProTip = "-This Slasher can enlist others into its ranks."
SlashCoSlasher.Covenant.SpeedRating = "★★★★★"
SlashCoSlasher.Covenant.EyeRating = "★★☆☆☆"
SlashCoSlasher.Covenant.DiffRating = "★★★☆☆"

SlashCoSlasher.Covenant.OnSpawn = function(slasher)
    slasher:SetNWBool("CanChase", true)
end

SlashCoSlasher.Covenant.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Covenant.SummonCovenantMembers = function()

    for _, v in ipairs(SlashCoSlasher.Covenant.PlayersToBecomePartOfCovenant) do
        
        local clk = player.GetBySteamID64( v.steamid )
        SlashCo.SelectSlasher("CovenantCloak", v.steamid)
        clk:SetTeam(TEAM_SLASHER)
        clk:Spawn()

    end



end

SlashCoSlasher.Covenant.SummonRocks = function(vic)
    SlashCo.SelectSlasher("CovenantRocks", vic:SteamID64())
    vic:SetTeam(TEAM_SLASHER)
    vic:Spawn()
end

SlashCoSlasher.Covenant.OnTickBehaviour = function(slasher)

    for _, cloak in ipairs(team.GetPlayers(TEAM_SLASHER)) do --Sync the chase for every slasher, meaning every covenant member

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

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Covenant.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Covenant.Perception)
end

SlashCoSlasher.Covenant.OnPrimaryFire = function(slasher, target)
    
    if not slasher:GetNWBool("CovenantSummoned") then

        if not slasher:GetNWBool("CovenantSummoning") then

            local dist = slasher:SlasherValue("KillDistance", 135)

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
                                PhysBone:EnableGravity( false )
                            end
                        end
                    end)

                    timer.Simple(4, function()              
                        SlashCoSlasher.Covenant.SummonRocks(slasher.PlayerToBecomeRocks) 
                        slasher.PlayerToBecomeRocks:Freeze(true)
                        
                        timer.Simple(3, function()              
                            slasher.PlayerToBecomeRocks:Freeze(false)
                            slasher.PlayerToBecomeRocks:SetNWBool("RocksBeingSummoned", false)
                        end)
                        
                    end)

                    timer.Simple(6, function() 

                        local Dissolver = ents.Create( "env_entity_dissolver" )
                        timer.Simple(1, function()
                            if IsValid(Dissolver) then
                                Dissolver:Remove() -- backup edict save on error
                            end
                        end)

                        Dissolver.Target = "dissolve"..ragdoll:EntIndex()
                        Dissolver:SetKeyValue( "dissolvetype", 0)
                        Dissolver:SetKeyValue( "magnitude", 0 )
                        Dissolver:SetPos( ragdoll:GetPos() )
                        Dissolver:SetPhysicsAttacker( slasher )
                        Dissolver:Spawn()

                        ragdoll:SetName( Dissolver.Target )

                        Dissolver:Fire( "Dissolve", Dissolver.Target, 0 )
                        Dissolver:Fire( "Kill", "", 0.1 )

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

SlashCoSlasher.Covenant.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Covenant.OnMainAbilityFire = function(slasher)

end


SlashCoSlasher.Covenant.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.Covenant.Animator = function(ply) 

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

SlashCoSlasher.Covenant.Footstep = function(ply)

    if SERVER then


        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    SlashCoSlasher.Covenant.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Covenant.ClientSideEffect = function()

    end

end