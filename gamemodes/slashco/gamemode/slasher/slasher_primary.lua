local SlashCo = SlashCo

SlashCo.SlasherPrimaryFire = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO

    local dist = SlashCoSlasher[slasher:GetNWString("Slasher")].KillDistance

    ::abomslash::
    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 11 or slasher.SlasherValue1 > 0 then return end
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