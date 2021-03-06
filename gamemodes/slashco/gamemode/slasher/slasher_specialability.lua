local SlashCo = SlashCo

SlashCo.SlasherSpecialAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO

    --Bababooey's Clone ability
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 1 then goto SID end
do
    if #ents.FindByClass( "sc_babaclone") > SO then return end
    local clone = SlashCo.CreateItem("sc_babaclone",slasher:GetPos(), slasher:GetAngles())
end

    ::SID::
    --Sid's Gun
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 2 then goto AMOGUS end
    if SlashCo.CurRound.SlasherData.GameProgress < 5 then return end

    if not slasher:GetNWBool("SidGun") and SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 < 0.01 and SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 > 0 then --Equip the gun
        slasher:SetNWBool("SidGun", true)
        slasher:SetNWBool("SidGunEquipping", true)
        slasher:Freeze(true)
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 4 - (SO * 2)
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 4 - (SO * 2)

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 - 1 --Deplete the uses

        timer.Simple(0.5, function() --Show the gun model
        
            slasher:SetBodygroup( 1, 1 )
            slasher:EmitSound("slashco/slasher/sid_draw.wav")

        end)
        timer.Simple(2.25, function() --sound  
            slasher:EmitSound("slashco/slasher/sid_slideback.wav",75,75)
        end)

        timer.Simple(4.5, function() --Apply the state

            slasher:SetNWBool("SidGunEquipping", false)
        
            slasher:SetNWBool("SidGunEquipped", true)

            slasher:Freeze(false)

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 2

            if slasher:GetNWBool("SidGunRage") then

                slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed )

            end

        end)

    elseif slasher:GetNWBool("SidGun") and SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 < 0.01 and not slasher:GetNWBool("SidGunAiming") and not slasher:GetNWBool("SidGunAimed") then
        slasher:SetNWBool("SidGunEquipped", false)
        slasher:SetNWBool("SidGun", false)
        slasher:SetBodygroup( 1, 0 )
        slasher:SetNWBool("SidGunLetterC", false)
        slasher:StopSound("slashco/slasher/sid_THE_LETTER_C.wav")
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = math.random(5,15)
    end

    --Trollge has no special ability

    ::AMOGUS::

    --Amogus Fuel Transform \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 4 then goto BORGMIRE end

    if not slasher:GetNWBool("AmogusDisguising") and v2 < 0.01 and not slasher:GetNWBool("AmogusFuelDisguise") and not slasher:GetNWBool("AmogusDisguised") then

        slasher:SetNWBool("AmogusDisguising", true)
        slasher:Freeze(true)

        slasher:EmitSound("slashco/slasher/amogus_transform"..math.random(1,2)..".mp3")

        timer.Simple(2, function() 
            slasher:Freeze(false) 
            slasher:SetNWBool("AmogusDisguising", false)
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2

            slasher:SetNWBool("AmogusFuelDisguise", true)
            slasher:SetNWBool("AmogusDisguised", true)

            slasher:EmitSound("slashco/slasher/amogus_sus.mp3")

            slasher:SetColor(Color(0,0,0,0))
            slasher:DrawShadow(false)
		    slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		    slasher:SetNoDraw(true)

            local g = ents.Create( "prop_physics" )

            g:SetPos( slasher:GetPos() + Vector(0,0,15) )
            g:SetAngles( slasher:GetAngles() + Angle(0,90,0) )
            g:SetModel( SlashCo.GasCanModel )
            g:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
            g:Spawn()

            g:FollowBone( slasher, slasher:LookupBone( "Hips" ) )

            local id = g:EntIndex()
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = id

            slasher:SetRunSpeed( 200 )
            slasher:SetWalkSpeed( 200 )

        end)

    end

    --Amogus Fuel Transform /\ /\ /\

    --Thirsty has no special ability.
    --Male07 has no special ability.
    --Tyler has no special ability.

    ::BORGMIRE::
    --Borgmire's Throw \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 8 then goto FREESMILEY end

    if slasher:GetEyeTrace().Entity:IsPlayer() and not slasher:GetNWBool("BorgmireThrow") then
        local target = slasher:GetEyeTrace().Entity	

        if target:Team() != TEAM_SURVIVOR then return end

        if slasher:GetPos():Distance(target:GetPos()) < 200 and not target:GetNWBool("SurvivorBeingJumpscared") then

            slasher:SetNWBool("BorgmireThrow",true)

            SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown = 99

            slasher:EmitSound("slashco/slasher/borgmire_throw.mp3")
                
            target:Freeze(true)
            slasher:Freeze(true)

            target:SetPos(slasher:GetPos() + Vector(0,0,100))

            for i = 1, 13 do
            
                timer.Simple(0.1 + (i/10), function() target:SetPos(slasher:GetPos() + Vector(0,0,100)) end)

            end

            timer.Simple(1.5, function()

                target:SetPos(slasher:GetPos() + Vector(47,0,53))

                target:SetVelocity( (slasher:GetForward() * 1600) + Vector(0,0,800) )

                target:Freeze(false)
                if target:Health() > 1 then target:SetHealth( target:Health() - (target:Health() / 4) ) end
        
            end)

            timer.Simple(2, function()
                slasher:Freeze(false)
                slasher:SetNWBool("BorgmireThrow",false)
                SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown = 2
            end)

        end

    end

    --Borgmire's Throw /\ /\ \/

    ::FREESMILEY::
    
end