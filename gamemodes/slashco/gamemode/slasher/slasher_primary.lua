local SlashCo = SlashCo

SlashCo.SlasherPrimaryFire = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO

    local dist = SlashCo.CurRound.SlasherData[slasherid].KillDistance

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID == 3 and SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 < 1 then goto trollclaw end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID == 6 and SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 == 2 then goto maleclaw end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID == 7 and SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 == 3 then goto tylerdestroy end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID == 8 then goto borgpunch end

    if slasher:GetNWBool("SidGun") then goto sidgun end
do

    if SlashCo.CurRound.SlasherData[slasherid].CanKill == false then return end

    if SlashCo.CurRound.SlasherData[slasherid].KillDelayTick > 0 then return end
    
    if slasher:GetEyeTrace().Entity:IsPlayer() then
        local target = slasher:GetEyeTrace().Entity	

        if target:Team() != TEAM_SURVIVOR then return end

        if slasher:GetPos():Distance(target:GetPos()) < dist and not target:GetNWBool("SurvivorBeingJumpscared") then

            target:SetNWBool("SurvivorBeingJumpscared",true)
            target:SetNWBool("SurvivorJumpscare_"..SlashCo.CurRound.SlasherData[slasherid].SlasherID, true)

            SlashCo.CurRound.SlasherData[slasherid].CanChase = false
            SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 99

            slasher:EmitSound(SlashCo.CurRound.SlasherData[slasherid].KillSound)
                
            target:Freeze(true)
            slasher:Freeze(true)

            SlashCo.CurRound.SlasherData[slasherid].KillDelayTick = SlashCo.CurRound.SlasherData[slasherid].KillDelay

            timer.Simple(SlashCo.CurRound.SlasherData[slasherid].JumpscareDuration, function()

                target:SetNWBool("SurvivorBeingJumpscared",false)
                target:SetNWBool("SurvivorJumpscare_"..SlashCo.CurRound.SlasherData[slasherid].SlasherID, false)
                target:EmitSound("slashco/survivor/effectexpire_breath.mp3")

                slasher:Freeze(false)
                target:Freeze(false)
                target:Kill()
        
            end)
        end

    end

end

    ::sidgun::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 2  then return end
do

    local spread = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4

    if slasher:GetNWBool("SidGunAimed") and spread < 2.4 then

        slasher:SetNWBool("SidGunShoot",false)
        timer.Remove("SidGunDecay")

        timer.Simple(0.05, function()       
            slasher:SetNWBool("SidGunShoot",true)

            PlayGlobalSound("slashco/slasher/sid_shot_farthest.mp3", 150, slasher)

            PlayGlobalSound("slashco/slasher/sid_shot.mp3", 85, slasher)

            PlayGlobalSound("slashco/slasher/sid_shot_legacy.mp3", 78, slasher)

            slasher:FireBullets( 
                {
                    
                    Damage = 100, 
                    TracerName = "AirboatGunHeavyTracer", 
                    Dir = slasher:GetAimVector(), 
                    Src = slasher:GetPos() + Vector(0,0,60), 
                    IgnoreEntity = slasher, 
                    Spread = Vector(math.Rand(-1-(spread*25),1+(spread*25))*0.001,math.Rand(-1-(spread*25),1+(spread*25))*0.001,0)

                }, false )

            local vec, ang = slasher:GetBonePosition(slasher:LookupBone( "HandL" ))
            local vPoint = vec
            local muzzle = EffectData()
            muzzle:SetOrigin( vPoint + slasher:GetForward()*8 + Vector(0,0,2) )
            muzzle:SetStart( Vector(255,0,0) )
            muzzle:SetAttachment( 0 )
            util.Effect( "sid_muzzle", muzzle )

            local shell = EffectData()
            shell:SetOrigin( vPoint )
            shell:SetAngles( ang ) 
            util.Effect( "ShellEject", shell )

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = 3

            timer.Create( "SidGunDecay", 1.5, 1, function() slasher:SetNWBool("SidGunShoot",false) end)
        end)

    else

        --Executing a Survivor

        if slasher:GetEyeTrace().Entity:IsPlayer() then
            local target = slasher:GetEyeTrace().Entity	
    
            if target:Team() != TEAM_SURVIVOR then return end
    
            if slasher:GetPos():Distance(target:GetPos()) < dist and not target:GetNWBool("SurvivorBeingJumpscared") then
    
                target:SetNWBool("SurvivorBeingJumpscared",true)
    
                SlashCo.CurRound.SlasherData[slasherid].CanChase = false
                SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 99

                PlayGlobalSound("slashco/slasher/sid_angry_"..math.random(1,4)..".mp3", 85, slasher, 1)

                slasher:SetNWBool("SidExecuting",true)

                target:SetNWBool("SurvivorDecapitate",true)

                target:SetNWBool("SurvivorSidExecution", true)

                target:SetPos(slasher:GetPos())
                target:SetEyeAngles(   Angle(0,slasher:GetAngles()[2],0)   )  
                    
                target:Freeze(true)
                target:SetNotSolid(true)
                slasher:Freeze(true)
    
                SlashCo.CurRound.SlasherData[slasherid].KillDelayTick = SlashCo.CurRound.SlasherData[slasherid].KillDelay

                timer.Simple(1, function() 
                    target:EmitSound("ambient/voices/citizen_beaten4.wav") 
                end)

                timer.Simple(3, function()               
                    target:EmitSound("ambient/voices/citizen_beaten3.wav")              
                end)

                timer.Simple(3.95, function() 
                
                    target:SetEyeAngles(   Angle(0,180+slasher:GetAngles()[2],0)   ) 
                
                end)
    
                timer.Simple(4.1, function()
    
                    target:SetNWBool("SurvivorBeingJumpscared",false)

                    PlayGlobalSound("slashco/slasher/sid_shot_farthest.mp3", 150, slasher)

                    slasher:EmitSound("slashco/slasher/sid_shot.mp3", 95)

                    slasher:EmitSound("slashco/slasher/sid_shot_2.mp3", 85)

                    local vec, ang = slasher:GetBonePosition(slasher:LookupBone( "HandL" ))
                    local vPoint = vec
                    local muzzle = EffectData()
                    muzzle:SetOrigin( vPoint + slasher:GetForward()*8 + Vector(0,0,2) )
                    muzzle:SetStart( Vector(255,0,0) )
                    muzzle:SetAttachment( 0 )
                    util.Effect( "sid_muzzle", muzzle )

                    local shell = EffectData()
                    shell:SetOrigin( vPoint )
                    shell:SetAngles( ang ) 
                    util.Effect( "ShellEject", shell )

                    target:SetNWBool("SurvivorSidExecution", false)

                    target:SetPos(slasher:GetPos() + (slasher:GetForward() * 40))

                    target:Freeze(false)
                    target:SetVelocity( slasher:GetForward() * 300 )
                    target:SetNotSolid(false)
                    timer.Simple(0.05, function() target:Kill() end)
            
                end)

                timer.Simple(8, function()
                    slasher:Freeze(false)
                    slasher:SetNWBool("SidExecuting",false)
                    target:SetNWBool("SurvivorDecapitate",false)
                end)
            end
    
        end

    end

end

    ::trollclaw::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 3 then return end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 != 0 then return end
do
    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 < 0.01 and not slasher:GetNWBool("TrollgeTransition") then

        slasher:SetNWBool("TrollgeSlashing",false)
        timer.Remove("TrollgeSlashDecay")

        timer.Simple(0.3, function() 

            slasher:EmitSound("slashco/slasher/trollge_swing.wav")

            if SERVER then

                local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,0)), Vector(-30,-30,-60), Vector(30,30,60), 10, DMG_SLASH, 50, false )

                if target:IsPlayer() then

                    if target:Team() != TEAM_SURVIVOR then return end

                    local vPoint = target:GetPos() + Vector(0,0,50)
                    local bloodfx = EffectData()
                    bloodfx:SetOrigin( vPoint )
                    util.Effect( "BloodImpact", bloodfx )

                    target:EmitSound("slashco/slasher/trollge_hit.wav")

                    SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 + 1 + SO

                end

            end

        end)

        timer.Simple(0.1, function() 

            slasher:SetNWBool("TrollgeSlashing",true)

            timer.Create( "TrollgeSlashDecay", 0.6, 1, function() slasher:SetNWBool("TrollgeSlashing",false) end)

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 + 0.5

        end)

    end

end

    ::maleclaw::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 6 then return end

do

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 < 0.01 then

        slasher:SetNWBool("Male07Slashing",false)
        timer.Remove("Male07SlashDecay")
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = 2

        timer.Simple(0.5, function() 

            slasher:EmitSound("slashco/slasher/trollge_swing.wav")

            if SERVER then

                local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,0)), Vector(-30,-30,-60), Vector(30,30,60), 50 + (SO*50), DMG_SLASH, 2, false )

                if not target:IsValid() then return end

                if target:IsPlayer() then

                    if target:Team() != TEAM_SURVIVOR then return end

                    local vPoint = target:GetPos() + Vector(0,0,50)
                    local bloodfx = EffectData()
                    bloodfx:SetOrigin( vPoint )
                    util.Effect( "BloodImpact", bloodfx )

                    target:EmitSound("slashco/slasher/trollge_hit.wav") 

                end

                if target:GetClass() == "prop_door_rotating" then

                    if SERVER then target:Fire("Open") end

                    timer.Simple(0.05, function() 

                        local tr = util.TraceLine( {
                            start = slasher:EyePos(),
                            endpos = slasher:EyePos() + slasher:GetForward() * 10000,
                            filter = slasher
                        } )

                        local trace = util.GetSurfaceData( tr.SurfaceProps ).name


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
                        phys:ApplyForceCenter( slasher:GetForward() * 30000 )

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

        end)

        timer.Simple(0.1, function() 

            slasher:SetNWBool("Male07Slashing",true)

            timer.Create( "Male07SlashDecay", 1.5, 1, function() slasher:SetNWBool("Male07Slashing",false) end)

        end)

    end

end

    ::tylerdestroy::

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 7 then return end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 != 3 then return end

    do

        if SlashCo.CurRound.SlasherData[slasherid].CanKill == false then return end
    
        if SlashCo.CurRound.SlasherData[slasherid].KillDelayTick > 0 then return end
        
        if slasher:GetEyeTrace().Entity then

            local target = slasher:GetEyeTrace().Entity	

            local c = target:GetClass()
    
            if not target:IsPlayer() and c != "prop_physics" and c != "sc_milkjug" and c != "sc_cookie" and c != "sc_stepdecoy" and c != "sc_baby" and c != "sc_devildie" and c != "sc_mayo" and c != "sc_soda" then return end
    
            if slasher:GetPos():Distance(target:GetPos()) < dist and not target:GetNWBool("SurvivorBeingJumpscared") then
    
                target:SetNWBool("SurvivorBeingJumpscared",true)
                target:SetNWBool("SurvivorJumpscare_"..SlashCo.CurRound.SlasherData[slasherid].SlasherID, true)
    
                slasher:EmitSound(SlashCo.CurRound.SlasherData[slasherid].KillSound)
                    
                if target:IsPlayer() then target:Freeze(true) end
                slasher:Freeze(true)
    
                SlashCo.CurRound.SlasherData[slasherid].KillDelayTick = SlashCo.CurRound.SlasherData[slasherid].KillDelay

                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0
    
                timer.Simple(SlashCo.CurRound.SlasherData[slasherid].JumpscareDuration, function()
    
                    target:SetNWBool("SurvivorBeingJumpscared",false)
                    target:SetNWBool("SurvivorJumpscare_"..SlashCo.CurRound.SlasherData[slasherid].SlasherID, false)
    
                    slasher:Freeze(false)

                    if target:IsPlayer() then 

                        target:Freeze(false) 
                        target:Kill() 

                    else
                        target:Remove()
                        SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 + 0.5
                    end

                    SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 + 1

                    SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 0

                    slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
                    timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav") end)

                    slasher:SetColor(Color(0,0,0,0))
                    slasher:DrawShadow(false)
		            slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		            slasher:SetNoDraw(true)
                    slasher:SetNWBool("TylerFlash", false)

                    for i = 1, #player.GetAll() do
                        local ply = player.GetAll()[i]
                        ply:SetNWBool("DisplayTylerTheDestroyerEffects",false)
                    end
            
                end)
            end
    
        end
    
    end

    ::borgpunch::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 8 or slasher:GetNWBool("BorgmireThrow") then return end
do

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 < 0.01 then

        slasher:SetNWBool("BorgmirePunch",false)
        timer.Remove("BorgmirePunchDecay")
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2

        timer.Simple(0.3, function() 

            slasher:EmitSound("slashco/slasher/borgmire_swing"..math.random(1,2)..".mp3")

            if SERVER then

                local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(50,0,50)), Vector(-35,-35,-60), Vector(35,35,60), 35 + (SO*20), DMG_SLASH, 5, false )

                if not target:IsValid() then return end

                if (target:IsPlayer() and target:Team() == TEAM_SURVIVOR) or target:GetClass() == "prop_ragdoll" then

                    local o = Vector(0,0,0)

                    if (target:IsPlayer() and target:Team() == TEAM_SURVIVOR) then o = Vector(0,0,50) end

                    local vPoint = target:GetPos() + o
                    local bloodfx = EffectData()
                    bloodfx:SetOrigin( vPoint )
                    util.Effect( "BloodImpact", bloodfx )

                    target:EmitSound("slashco/slasher/borgmire_hit"..math.random(1,2)..".mp3")

                end

                if target:GetClass() == "prop_door_rotating" then

                    if SERVER then target:Fire("Open") end

                    timer.Simple(0.05, function() 

                        local tr = util.TraceLine( {
                            start = slasher:EyePos(),
                            endpos = slasher:EyePos() + slasher:GetForward() * 10000,
                            filter = slasher
                        } )

                        local trace = util.GetSurfaceData( tr.SurfaceProps ).name


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
                        phys:ApplyForceCenter( slasher:GetForward() * 60000 )

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

        end)

        timer.Simple(0.05, function() 

            slasher:SetNWBool("BorgmirePunch",true)

            timer.Create( "BorgmirePunchDecay", 1.5, 1, function() slasher:SetNWBool("BorgmirePunch",false) end)

        end)

    end

end

end