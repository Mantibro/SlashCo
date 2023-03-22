local SlashCo = SlashCo

SlashCo.SlasherPrimaryFire = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO

    local dist = SlashCoSlasher[slasher:GetNWBool("Slasher")].KillDistance

    ::tylerdestroy::

    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 7 then return end

    if slasher.SlasherValue1 ~= 3 then return end

    do

        if SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill == false then return end
    
        if SlashCoSlasher[slasher:GetNWBool("Slasher")].KillDelayTick > 0 then return end
        
        if slasher:GetEyeTrace().Entity then

            local target = slasher:GetEyeTrace().Entity	

            local c = target:GetClass()
    
            if not target:IsPlayer() and c ~= "prop_physics" and c ~= "sc_milkjug" and c ~= "sc_cookie" and c ~= "sc_stepdecoy" and c ~= "sc_baby" and c ~= "sc_devildie" and c ~= "sc_mayo" and c ~= "sc_soda" then return end
    
            if slasher:GetPos():Distance(target:GetPos()) < dist and not target:GetNWBool("SurvivorBeingJumpscared") then
    
                target:SetNWBool("SurvivorBeingJumpscared",true)
                target:SetNWBool("SurvivorJumpscare_"..SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID, true)
    
                slasher:EmitSound(SlashCoSlasher[slasher:GetNWBool("Slasher")].KillSound)
                    
                if target:IsPlayer() then target:Freeze(true) end
                slasher:Freeze(true)
    
                SlashCoSlasher[slasher:GetNWBool("Slasher")].KillDelayTick = SlashCoSlasher[slasher:GetNWBool("Slasher")].KillDelay

                slasher.SlasherValue2 = 0
    
                timer.Simple(SlashCoSlasher[slasher:GetNWBool("Slasher")].JumpscareDuration, function()
    
                    target:SetNWBool("SurvivorBeingJumpscared",false)
                    target:SetNWBool("SurvivorJumpscare_"..SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID, false)
    
                    slasher:Freeze(false)

                    if target:IsPlayer() then 

                        target:Freeze(false) 
                        target:Kill() 

                    else
                        target:Remove()
                        slasher.SlasherValue4 = slasher.SlasherValue4 + 0.5
                    end

                    slasher.SlasherValue4 = slasher.SlasherValue4 + 1

                    slasher.SlasherValue1 = 0

                    slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
                    slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav")
                    timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav") slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav") end)

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
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 8 or slasher:GetNWBool("BorgmireThrow") then goto abomslash end
do

    if slasher.SlasherValue2 < 0.01 then

        slasher:SetNWBool("BorgmirePunch",false)
        timer.Remove("BorgmirePunchDecay")
        slasher.SlasherValue2 = 2

        timer.Simple(0.3, function() 

            slasher:EmitSound("slashco/slasher/borgmire_swing"..math.random(1,2)..".mp3")

            slasher.SlasherValue3 = 2

            if SERVER then

                local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(50,0,50)), Vector(-35,-45,-60), Vector(35,45,60), 35 + (SO*20), DMG_SLASH, 5, false )

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

                SlashCo.BustDoor(slasher, target, 60000)

            end

        end)

        timer.Simple(0.05, function() 

            slasher:SetNWBool("BorgmirePunch",true)

            timer.Create( "BorgmirePunchDecay", 1.5, 1, function() slasher:SetNWBool("BorgmirePunch",false) end)

        end)

    end

end

    ::abomslash::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 11 or slasher.SlasherValue1 > 0 then return end
do

    if slasher:GetNWBool("AbomignatCrawling") then return end
    --slasher:Freeze(true)
    slasher:SetNWBool("AbomignatSlashing",true)
    slasher.SlasherValue1 = 6  - (SO * 3)
    slasher.SlasherValue2 = 5

    slasher:EmitSound("slashco/slasher/abomignat_scream"..math.random(1,3)..".mp3")

        timer.Simple(1, function() 

            slasher:EmitSound("slashco/slasher/trollge_swing.wav")
            slasher:Freeze(true)
            slasher.SlasherValue2 = 0

            if SERVER then

                local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,0)), Vector(-30,-30,-60), Vector(30,30,60), 35, DMG_SLASH, 5, false )

                SlashCo.BustDoor(slasher, target, 20000)

                if target:IsPlayer() then

                    if target:Team() ~= TEAM_SURVIVOR then return end

                    local vPoint = target:GetPos() + Vector(0,0,50)
                    local bloodfx = EffectData()
                    bloodfx:SetOrigin( vPoint )
                    util.Effect( "BloodImpact", bloodfx )

                    target:EmitSound("slashco/slasher/trollge_hit.wav")

                end

            end

        end)

        timer.Simple(2.3, function() 

            slasher:SetNWBool("AbomignatSlashing",false)
            slasher:Freeze(false)

        end)

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