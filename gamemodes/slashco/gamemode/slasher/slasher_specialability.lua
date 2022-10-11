local SlashCo = SlashCo

SlashCo.SlasherSpecialAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO

    --Bababooey's Clone ability
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 1 then goto SID end
do
    if #ents.FindByClass( "sc_babaclone") > SO then return end
    local clone = SlashCo.CreateItem("sc_babaclone",slasher:GetPos(), slasher:GetAngles())
end

    ::SID::
    --Sid's Gun
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 2 then goto AMOGUS end
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
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 4 then goto BORGMIRE end

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
            g:SetModel( SlashCoItems.GasCan.Model )
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
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 8 then goto MANSPIDER end

    if slasher:GetEyeTrace().Entity:IsPlayer() and not slasher:GetNWBool("BorgmireThrow") then
        local target = slasher:GetEyeTrace().Entity	

        if target:Team() ~= TEAM_SURVIVOR then return end

        if slasher:GetPos():Distance(target:GetPos()) < 200 and not target:GetNWBool("SurvivorBeingJumpscared") then

            slasher:SetNWBool("BorgmireThrow",true)

            local pick_ang = SlashCo.RadialTester(slasher, 200, target)

            --slasher:SetEyeAngles( Angle(0,pick_ang,0) )

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

                local strength_forward = 1600 + (SO * 450)
                local strength_up = 800 + (SO * 150)

                target:SetVelocity( (slasher:GetForward() * strength_forward) + Vector(0,0,strength_up) )

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

    --Borgmire's Throw /\ /\ /\
    ::MANSPIDER::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 9 then goto WATCHER end
    --Manspider's Leap \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 > 0 then return end

    if not slasher:IsOnGround() then return end

    if not slasher:GetNWBool("InSlasherChaseMode") then return end

    SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 4

    slasher:Freeze(true)
    slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")

    timer.Simple(1, function()  

        local strength_forward = 800 + (SO * 500)
        local strength_up = 200 + (SO * 100)
    
        slasher:SetVelocity(  (slasher:EyeAngles():Forward() * strength_forward) + Vector(0,0,strength_up)  )
        slasher:Freeze(false)

    end)

    --Manspider's Leap /\ /\ /\

    ::WATCHER::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 10 then goto ABOMIGNAT end
    --Watcher Surveillance \/ \/ \/

    if SlashCo.CurRound.SlasherData.GameProgress < (10 - (SlashCo.CurRound.SlasherData[slasherid].SlasherValue4/25)) then return end
    if slasher:GetNWBool("WatcherRage") then return end
    if #team.GetPlayers(TEAM_SURVIVOR) < 2 then return end

    slasher:SetNWBool("WatcherRage", true)
    PlayGlobalSound("slashco/slasher/watcher_rage.wav", 100, slasher, 1)

    --Watcher Surveillance /\ /\ /\

    ::ABOMIGNAT::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 11 then goto CRIMINAL end
    
    --Abomignat lunge \/ \/ \/

    if slasher:GetNWBool("AbomignatCrawling") then return end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 > 0 then return end
    SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 10 - (SO * 4)
    SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 8 + (SO*4)
    SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 0

    slasher:Freeze(true)

    slasher:SetNWBool("AbomignatLunging", true)
    slasher:EmitSound("slashco/slasher/abomignat_lunge.mp3")

    timer.Simple(1.75, function()
        if SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 == 0 then
            slasher:SetNWBool("AbomignatLungeFinish",true)
            timer.Simple(0.6, function() slasher:EmitSound("slashco/slasher/abomignat_scream"..math.random(1,3)..".mp3") end)

            slasher:SetNWBool("AbomignatLunging",false)
            slasher:SetCycle( 0 )

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 1
        end

        timer.Simple(4, function() 
            if SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 == 1 then
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 2
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = 0
                slasher:SetNWBool("AbomignatLungeFinish",false)     
                slasher:Freeze(false)
            end       
        end)

    end)

    --Abomignat lunge /\ /\ /\
    ::CRIMINAL::
end