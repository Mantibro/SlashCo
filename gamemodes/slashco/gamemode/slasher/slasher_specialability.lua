local SlashCo = SlashCo

SlashCo.SlasherSpecialAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    --Borgmire's Throw \/ \/ \/
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 8 then goto MANSPIDER end

    if slasher:GetEyeTrace().Entity:IsPlayer() and not slasher:GetNWBool("BorgmireThrow") then
        local target = slasher:GetEyeTrace().Entity	

        if target:Team() ~= TEAM_SURVIVOR then return end

        if slasher:GetPos():Distance(target:GetPos()) < 200 and not target:GetNWBool("SurvivorBeingJumpscared") then

            slasher:SetNWBool("BorgmireThrow",true)

            local pick_ang = SlashCo.RadialTester(slasher, 200, target)

            --slasher:SetEyeAngles( Angle(0,pick_ang,0) )

            SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown = 99

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
                SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown = 2
            end)

        end

    end

    --Borgmire's Throw /\ /\ /\
    ::MANSPIDER::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 9 then goto WATCHER end
    --Manspider's Leap \/ \/ \/
    if slasher.SlasherValue2 > 0 then return end

    if not slasher:IsOnGround() then return end

    if not slasher:GetNWBool("InSlasherChaseMode") then return end

    slasher.SlasherValue2 = 4

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
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 10 then goto ABOMIGNAT end
    --Watcher Surveillance \/ \/ \/

    if SlashCo.CurRound.GameProgress < (10 - (slasher.SlasherValue4/25)) then return end
    if slasher:GetNWBool("WatcherRage") then return end
    if #team.GetPlayers(TEAM_SURVIVOR) < 2 then return end

    slasher:SetNWBool("WatcherRage", true)
    PlayGlobalSound("slashco/slasher/watcher_rage.wav", 100, slasher, 1)

    --Watcher Surveillance /\ /\ /\

    ::ABOMIGNAT::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 11 then goto CRIMINAL end
    
    --Abomignat lunge \/ \/ \/

    if slasher:GetNWBool("AbomignatCrawling") then return end

    if slasher.SlasherValue1 > 0 then return end
    slasher.SlasherValue1 = 10 - (SO * 4)
    slasher.SlasherValue2 = 8 + (SO*4)
    slasher.SlasherValue3 = 0

    slasher:Freeze(true)

    slasher:SetNWBool("AbomignatLunging", true)
    slasher:EmitSound("slashco/slasher/abomignat_lunge.mp3")

    timer.Simple(1.75, function()
        if slasher.SlasherValue3 == 0 then
            slasher:SetNWBool("AbomignatLungeFinish",true)
            timer.Simple(0.6, function() slasher:EmitSound("slashco/slasher/abomignat_scream"..math.random(1,3)..".mp3") end)

            slasher:SetNWBool("AbomignatLunging",false)
            slasher:SetCycle( 0 )

            slasher.SlasherValue2 = 0
            slasher.SlasherValue3 = 1
        end

        timer.Simple(4, function() 
            if slasher.SlasherValue3 == 1 then
                slasher.SlasherValue3 = 2
                slasher.SlasherValue4 = 0
                slasher:SetNWBool("AbomignatLungeFinish",false)     
                slasher:Freeze(false)
            end       
        end)

    end)

    --Abomignat lunge /\ /\ /\
    ::CRIMINAL::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 12 then goto FREESMILEY end
    --Criminal Rage \/ \/ \/

    if not slasher:GetNWBool("CriminalCloning") then return end
    if slasher:GetNWBool("CriminalRage") then return end
    if SlashCo.CurRound.GameProgress < 7 then return end

    for i = 1, math.random(2+(SO * 2),4+(SO * 2)) do

        local clone = ents.Create( "sc_crimclone" )

        clone:SetPos( slasher:GetPos() )
        clone:SetAngles( slasher:GetAngles() )
        clone.AssignedSlasher = slasher:SteamID64()
        clone.IsMain = false
        clone:Spawn()
        clone:Activate()

    end

    slasher.SlasherValue1 = 0
    slasher:SetNWBool("CriminalRage",true)

    --Criminal Rage /\ /\ /\
    ::FREESMILEY::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 13 then goto BREN end

    if slasher.SlasherValue1 > 0 then return end
    slasher.SlasherValue1 = 80 - (SO*40)

    slasher:SetNWBool("FreeSmileySummoning", true)

    slasher:Freeze(true)
    timer.Simple(4, function() 
        
        if slasher.SlasherValue2 == 0 then 
            local smiley = ents.Create( "sc_zanysmiley" ) 
            smiley:SetPos( slasher:LocalToWorld(Vector(60,0,0)) )
            smiley:SetAngles( slasher:GetAngles() )
            smiley:Spawn()
            smiley:Activate()
        end
        if slasher.SlasherValue2 == 1 then 
            local smiley = ents.Create( "sc_pensivesmiley" ) 
            smiley:SetPos( slasher:LocalToWorld(Vector(60,0,0)) )
            smiley:SetAngles( slasher:GetAngles() )
            smiley:Spawn()
            smiley:Activate()
        end

    end)

    timer.Simple(6, function() 

        slasher:Freeze(false)
        slasher:SetNWBool("FreeSmileySummoning", false)

    end)

    ::BREN::
end