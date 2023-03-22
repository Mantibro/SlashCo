local SlashCo = SlashCo

SlashCo.ThirstyRage = function(ply)

    local pos = ply:GetPos()

    for i = 1, #team.GetPlayers(TEAM_SLASHER) do

        local slasherid = team.GetPlayers(TEAM_SLASHER)[i]:SteamID64()
        local slasher = team.GetPlayers(TEAM_SLASHER)[i]

        if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 5 then return end

        if slasher:GetPos():Distance( pos ) > 1600 then return end

        slasher.SlasherValue1 = 6
        slasher:SetNWBool("ThirstyBigMlik", true)

        for i = 1, #player.GetAll() do
            local ply = player.GetAll()[i]
            ply:SetNWBool("ThirstyFuck",true)
        end

        timer.Simple(3, function() 
        
            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("ThirstyFuck",false)
            end
        
        end)

    end

end








-------------------------------------------------------------------------------------------------------------------------------------------------

SlashCo.NEVERDOTHIS = function()

do

    v1 = slasher.SlasherValue1 --State
    v2 = slasher.SlasherValue2 --Time Spent as Creator or destroyer
    v3 = slasher.SlasherValue3 --Times Found
    v4 = slasher.SlasherValue4 --Destruction power
    v5 = slasher.SlasherValue5 --Destoyer Blink

    local ms = SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE

    SlashCoSlasher[slasher:GetNWBool("Slasher")].CanChase = false

    if v1 == 0 then --Specter

        slasher.TylerSongPickedID = nil

        slasher:SetNWBool("TylerFlash", false)

        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed ) 
        slasher:SetRunSpeed(SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed)
        slasher:SetWalkSpeed(SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed)
        slasher:SetNWBool("TylerTheCreator", false)
        slasher:SetBodygroup( 0, 0 )
        slasher.SlasherValue2 = 0
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = false
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 6.0

    elseif v1 == 1 then --Creator

        slasher:SetNWBool("TylerFlash", false)

        slasher:SetSlowWalkSpeed( 1 ) 
        slasher:SetRunSpeed(1)
        slasher:SetWalkSpeed(1)
        slasher:Freeze(true)
        slasher:SetNWBool("TylerTheCreator", true)
        slasher:SetBodygroup( 0, 0 )
        slasher.SlasherValue2 = v2 + FrameTime()
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = false
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 0.0

        if not slasher:GetNWBool("TylerCreating") and slasher.TylerSongPickedID == nil then
            slasher.TylerSongPickedID = math.random(1,6)

            PlayGlobalSound("slashco/slasher/tyler_song_"..slasher.TylerSongPickedID..".mp3",  98 , slasher,  0.8 - (slasher.SlasherValue3 * 0.12))
        end

        if v2 > ( ms * 40) - (v4 * 4) then --Time ran out

            local stop_song = slasher.TylerSongPickedID

            slasher.SlasherValue1 = 2
            slasher:StopSound("slashco/slasher/tyler_song_"..stop_song..".mp3")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/tyler_song_"..stop_song..".mp3") end)
            slasher.TylerSongPickedID = nil

        end

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do --Survivor found tyler

            local surv = team.GetPlayers(TEAM_SURVIVOR)[i]

            local stop_song = slasher.TylerSongPickedID

            if not slasher:GetNWBool("TylerCreating") and surv:GetPos():Distance( slasher:GetPos() ) < 400 and surv:GetEyeTrace().Entity == slasher then

                slasher:SetNWBool("TylerCreating", true)
                slasher.SlasherValue2 = 0
                slasher:StopSound("slashco/slasher/tyler_song_"..stop_song..".mp3")
                timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/tyler_song_"..stop_song..".mp3") end)
                slasher.TylerSongPickedID = nil

            end

        end

        if slasher:GetNWBool("TylerCreating") and slasher.SlasherValue5 ~= 1.8 then

            slasher.SlasherValue5 = 1.8
            slasher.SlasherValue2 = 0

            slasher:EmitSound("slashco/slasher/tyler_create.mp3")

            timer.Simple(3, function() 
            
                SlashCo.CreateGasCan(slasher:GetPos() + (slasher:GetForward() * 60) + Vector(0,0,18), Angle(0,0,0))
            
            end)

            timer.Simple(4, function() 
            
                slasher:SetNWBool("TylerCreating", false)
                slasher.SlasherValue1 = 0
                slasher.SlasherValue2 = 0
                slasher.SlasherValue3 = slasher.SlasherValue3 + 1
                slasher.SlasherValue5 = 0

                slasher:Freeze(false)

                slasher:SetColor(Color(0,0,0,0))
                slasher:DrawShadow(false)
		        slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		        slasher:SetNoDraw(true)
            
            end)

        end

        slasher.tyler_destroyer_entrance_antispam = nil

    elseif v1 == 2 then --Pre-Destroyer

        slasher.TylerSongPickedID = nil

        slasher:Freeze(true)

        if slasher.tyler_destroyer_entrance_antispam == nil then

            PlayGlobalSound("slashco/slasher/tyler_alarm.wav", 110, slasher, 1)
            if CLIENT then
                slasher.TylerSong:Stop() 
                slasher.TylerSong = nil
            end

            slasher.tyler_destroyer_entrance_antispam = 0
        end

        local decay = v4 / 2

        if v4 > 14 then decay = 7 end 

        if slasher.tyler_destroyer_entrance_antispam < (12 - decay) then
            slasher.tyler_destroyer_entrance_antispam = slasher.tyler_destroyer_entrance_antispam + FrameTime()
        else

            slasher:StopSound("slashco/slasher/tyler_alarm.wav")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/tyler_alarm.wav") end) --idk man only works if i stop it twice shut up

            PlayGlobalSound("slashco/slasher/tyler_destroyer_theme.wav", 98, slasher, 1)
            PlayGlobalSound("slashco/slasher/tyler_destroyer_whisper.wav", 101, slasher, 0.75)

            slasher:Freeze(false)

            slasher.SlasherValue1 = 3

            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("DisplayTylerTheDestroyerEffects",true)
            end

        end

        slasher:SetSlowWalkSpeed( 1 ) 
        slasher:SetRunSpeed(1)
        slasher:SetWalkSpeed(1)
        slasher:SetNWBool("TylerTheCreator", false)
        slasher:SetBodygroup( 0, 1 )
        slasher.SlasherValue2 = 0
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = false
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 0.0

    elseif v1 == 3 then --Destroyer

        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed ) 
        slasher:SetRunSpeed(SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed)
        slasher:SetWalkSpeed(SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed)
        slasher:SetNWBool("TylerTheCreator", false)
        slasher:SetBodygroup( 0, 1 )
        slasher.SlasherValue2 = v2 + FrameTime()
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = true
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 2.0

        if v2 > ((ms * 15) + 60 + (v4 * 10)) then

            slasher.SlasherValue1 = 0

            slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
            slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav") slasher:StopSound("slashco/slasher/tyler_destroyer_whisper.wav") end)

            slasher:SetColor(Color(0,0,0,0))
            slasher:DrawShadow(false)
            slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
            slasher:SetNoDraw(true)
            slasher:SetNWBool("TylerFlash", false)

            slasher.SlasherValue4 = slasher.SlasherValue4 - 1

            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("DisplayTylerTheDestroyerEffects",false)
            end

        end

    end

    if v1 > 1 then

        slasher.SlasherValue5 = v5 + FrameTime()

        if v5 > 0.85 then slasher.SlasherValue5 = 0 end

        if v5 <= 0.5 then 
            slasher:SetColor(Color(0,0,0,0))
            slasher:DrawShadow(false)
		    slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		    slasher:SetNoDraw(true)
            slasher:SetNWBool("TylerFlash", false)
        else
            slasher:SetColor(Color(255,255,255,255))
            slasher:DrawShadow(true)
		    slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		    slasher:SetNoDraw(false)
            slasher:SetNWBool("TylerFlash", true)
        end

    end

end
    ::BORGMIRE::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 8 then goto MANSPIDER end
do

    v1 = slasher.SlasherValue1 --Time Spent chasing
    v2 = slasher.SlasherValue2 --Punch Cooldown
    v3 = slasher.SlasherValue3 --Punch Slowdown

    if v2 > 0 then slasher.SlasherValue2 = v2 - FrameTime() end

    if v3 > 1 then slasher.SlasherValue3 = v3 - (FrameTime()/(2-SO)) end
    if v3 < 1 then slasher.SlasherValue3 = 1 end

    if not slasher:GetNWBool("InSlasherChaseMode") then

        slasher.SlasherValue1 = 0

        slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )

        slasher.ChaseSound = nil 

        if slasher.IdleSound == nil then

            PlayGlobalSound("slashco/slasher/borgmire_breath_base.wav", 60, slasher, 1)

            slasher:StopSound("slashco/slasher/borgmire_breath_chase.wav")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/borgmire_breath_chase.wav") end)

            slasher.IdleSound = true
        end

    else

        slasher.IdleSound = nil 

        slasher.SlasherValue1 = v1 + FrameTime()

        slasher:SetRunSpeed(  (     SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed - math.sqrt( v1 * (14-(SO*7)) )   ) / v3 )
        slasher:SetWalkSpeed( (     SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed - math.sqrt( v1 * (14-(SO*7)) )   ) / v3 )

        if slasher.ChaseSound == nil then

            PlayGlobalSound("slashco/slasher/borgmire_breath_chase.wav", 70, slasher, 1)

            PlayGlobalSound("slashco/slasher/borgmire_anger.mp3", 75, slasher, 1)

            PlayGlobalSound("slashco/slasher/borgmire_anger_far.mp3", 110, slasher, 1)

            slasher:StopSound("slashco/slasher/borgmire_breath_base.wav")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/borgmire_breath_base.wav") end)

            slasher.ChaseSound = true
        end

    end

end
    ::MANSPIDER::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 9 then goto WATCHER end
do

    v1 = slasher.SlasherValue1 --Target SteamID
    v2 = slasher.SlasherValue2 --Leap Cooldown
    v3 = slasher.SlasherValue3 --Time spend nested
    v4 = slasher.SlasherValue4 --Aggression

    if v2 > 0 then slasher.SlasherValue2 = v2 - FrameTime() end

    if not isstring(v1) or v1 == 0 then slasher.SlasherValue1 = "" end

    if v1 == "" then

        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanChase = false
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = false

    else

        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanChase = true
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = true

        if not IsValid(  player.GetBySteamID64( v1 ) ) or player.GetBySteamID64( v1 ):Team() ~= TEAM_SURVIVOR then slasher.SlasherValue1 = "" end

    end

    for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do --Switch Target if too close

        local s = team.GetPlayers(TEAM_SURVIVOR)[i]

        local d = s:GetPos():Distance( slasher:GetPos() )

        if d < (150) then

            local tr = util.TraceLine( {
                start = slasher:EyePos(),
                endpos = s:GetPos()+Vector(0,0,40),
                filter = slasher
            } )

            if tr.Entity == s then

                if slasher.SlasherValue1 ~= s:SteamID64() then

                    slasher.SlasherValue1 = s:SteamID64()
                    slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")

                end

            end

        end

    end

    if slasher:GetNWBool("ManspiderNested") then

        --Find a survivor
        slasher.SlasherValue3 = v3 + FrameTime()

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local s = team.GetPlayers(TEAM_SURVIVOR)[i]

            if s:GetPos():Distance( slasher:GetPos() ) < (1000 + (v3 * 3) + (SO * 750)) then

                local tr = util.TraceLine( {
                    start = slasher:EyePos(),
                    endpos = s:GetPos()+Vector(0,0,40),
                    filter = slasher
                } )

                if tr.Entity == s then
                    slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")
                    slasher.SlasherValue1 = s:SteamID64()
                    slasher:SetNWBool("ManspiderNested", false)

                    slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
                    slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
                    slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
                end

            end

        end

        slasher.SlasherValue4 = 0

    else

        --Not nested
        slasher.SlasherValue3 = 0

        if v1 == "" then

            for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

                local s = team.GetPlayers(TEAM_SURVIVOR)[i]

                local d = s:GetPos():Distance( slasher:GetPos() )
    
                if d < (1000) then
    
                    local tr = util.TraceLine( {
                        start = slasher:EyePos(),
                        endpos = s:GetPos()+Vector(0,0,40),
                        filter = slasher
                    } )
    
                    if tr.Entity == s then

                        slasher.SlasherValue4 = v4 + ( FrameTime() + (  (1000-d)  / 10000  )   )  + (SO * FrameTime())

                        if v4 > 100 then
                            slasher.SlasherValue1 = s:SteamID64()
                            slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")
                        end

                    end
    
                end
    
            end

        else

            slasher.SlasherValue4 = 0

        end

    end

end

    ::WATCHER::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 10 then goto ABOMIGNAT end
do

    v1 = slasher.SlasherValue1 --Survey Length
    v2 = slasher.SlasherValue2 --Survey Cooldown
    v3 = slasher.SlasherValue3 --Watched
    v4 = slasher.SlasherValue4 --Stalk time

    slasher.SlasherValue3 = BoolToNumber( slasher:GetNWBool("WatcherWatched") )

    if not slasher:GetNWBool("WatcherRage") then
        if v1 > 0 then slasher.SlasherValue1 = v1 - FrameTime() end
    else
        slasher.SlasherValue1 = 1
        slasher.SlasherValue3 = 0.65 
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanChase = false
    end

    if slasher:GetNWBool("InSlasherChaseMode") or slasher:GetNWBool("WatcherRage") then

        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed - (v3 * 80) )
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed - (v3 * 80) )
        slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed - (v3 * 80) )

    else

        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed - (v3 * 120) )
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed - (v3 * 120) )
        slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed - (v3 * 120) )

    end

    if v2 > 0 then slasher.SlasherValue2 = v2 - FrameTime() end

    local isSeen = false

    for s = 1, #team.GetPlayers(TEAM_SURVIVOR) do

        local surv = team.GetPlayers(TEAM_SURVIVOR)[s]

        if v1 > 0 then

            if not surv:GetNWBool("SurvivorWatcherSurveyed") then surv:SetNWBool("SurvivorWatcherSurveyed", true) end

        else

            if surv:GetNWBool("SurvivorWatcherSurveyed") then surv:SetNWBool("SurvivorWatcherSurveyed", false) end

            local find = ents.FindInCone( surv:GetPos(), surv:GetEyeTrace().Normal, 3000, 0.5 )

            local target = NULL

            if surv:GetEyeTrace().Entity == slasher then
                target = slasher
                goto FOUND
            end

            do
                for i = 1, #find do
                    if find[i] == slasher then 
                        target = find[i]
                        break 
                    end
                end

                if IsValid(target) then
                    local tr = util.TraceLine( {
                        start = surv:EyePos(),
                        endpos = target:GetPos()+Vector(0,0,50),
                        filter = surv
                    } )

                    if tr.Entity ~= target then target = NULL end
                end

            end
            ::FOUND::

            if IsValid(target) and target == slasher then 
                surv:SetNWBool("SurvivorWatcherSurveyed", true) 
                isSeen = true
            else
                if surv:GetNWBool("SurvivorWatcherSurveyed") then surv:SetNWBool("SurvivorWatcherSurveyed", false) end
            end

        end

    end

    slasher:SetNWBool("WatcherWatched", isSeen) 

    --Stalk Survivors

    local find = ents.FindInCone( slasher:GetPos(), slasher:GetEyeTrace().Normal, 1500, 0.85 )

    local target = NULL

    if slasher:GetEyeTrace().Entity:IsPlayer() and slasher:GetEyeTrace().Entity:Team() == TEAM_SURVIVOR then
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

        if IsValid(target) then
            local tr = util.TraceLine( {
                start = slasher:EyePos(),
                endpos = target:GetPos()+Vector(0,0,50),
                filter = slasher
            } )

            if tr.Entity ~= target then target = NULL end
        end

    end
    ::FOUND::

    if IsValid( target ) and isSeen == false and not slasher:GetNWBool("InSlasherChaseMode") then
        slasher.SlasherValue4 = v4 + FrameTime()
        if not slasher:GetNWBool("WatcherStalking") then slasher:SetNWBool("WatcherStalking", true) end
    else
        if slasher:GetNWBool("WatcherStalking") then slasher:SetNWBool("WatcherStalking", false) end
    end

end

    ::ABOMIGNAT::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 11 then goto CRIMINAL end
do

    v1 = slasher.SlasherValue1 --Main Slash Cooldown
    v2 = slasher.SlasherValue2 --Forward charge
    v3 = slasher.SlasherValue3 --Lunge Finish Antispam
    v4 = slasher.SlasherValue4 --Lunge Duration

    if v1 > 0 then slasher.SlasherValue1 = v1 - FrameTime() end

    if slasher:IsOnGround() then slasher:SetVelocity(slasher:GetForward() * v2 * 8) end

    if slasher:GetNWBool("AbomignatLunging") then

        local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,30)), Vector(-15,-15,-60), Vector(15,15,60), 50, DMG_SLASH, 5, false )

        SlashCo.BustDoor(slasher, target, 25000)

        slasher.SlasherValue4 = v4 + 1

        if ( slasher:GetVelocity():Length() < 450 or target:IsValid() ) and v4 > 30 and slasher.SlasherValue3 == 0 then

            slasher:SetNWBool("AbomignatLungeFinish",true)
            timer.Simple(0.6, function() slasher:EmitSound("slashco/slasher/abomignat_scream"..math.random(1,3)..".mp3") end)

            slasher:SetNWBool("AbomignatLunging",false)
            slasher:SetCycle( 0 )

            slasher.SlasherValue2 = 0
            slasher.SlasherValue3 = 1

            timer.Simple(4, function() 
                if v3 == 1 then
                    slasher.SlasherValue3 = 2
                    slasher.SlasherValue4 = 0
                    slasher:SetNWBool("AbomignatLungeFinish",false)   
                    slasher:Freeze(false)  
                end       
            end)

        end


    end

    if slasher:GetNWBool("AbomignatCrawling") then 
    
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanChase = false

        slasher:SetSlowWalkSpeed( 350 )
        slasher:SetWalkSpeed( 350 )
        slasher:SetRunSpeed( 350 )

        SlashCoSlasher[slasher:GetNWBool("Slasher")].Eyesight = 0
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 0

        if slasher:GetVelocity():Length() < 3 then 
            slasher:SetNWBool("AbomignatCrawling",false) 
            SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseCooldown 
        end

        if not slasher:IsOnGround() then 
            slasher:SetNWBool("AbomignatCrawling",false) 
            SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseCooldown 
        end

        slasher:SetViewOffset( Vector(0,0,20) )
        slasher:SetCurrentViewOffset( Vector(0,0,20) )

    else

        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanChase = true

        SlashCoSlasher[slasher:GetNWBool("Slasher")].Eyesight = 6
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 0.5

        slasher:SetViewOffset( Vector(0,0,70) )
        slasher:SetCurrentViewOffset( Vector(0,0,70) )

        if not slasher:GetNWBool("InSlasherChaseMode") then
            slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
        end

    end

end

    ::CRIMINAL::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 12 then goto FREESMILEY end
do

    v1 = slasher.SlasherValue1 --Cloning Duration

    if slasher:GetVelocity():Length() > 5 then
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = false
    else
        SlashCoSlasher[slasher:GetNWBool("Slasher")].CanKill = true
    end

    
    if slasher:GetNWBool("CriminalCloning") then

        slasher.SlasherValue1 = v1 + FrameTime()

        if not slasher:GetNWBool("CriminalRage") then

            local speed = SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed - ( v1 / (4 + SO))

            slasher:SetSlowWalkSpeed( speed )
            slasher:SetWalkSpeed( speed  )
            slasher:SetRunSpeed( speed  )
        else

            local speed = 25 + SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed - ( v1 / (5 + SO))

            slasher:SetSlowWalkSpeed( speed )
            slasher:SetWalkSpeed( speed  )
            slasher:SetRunSpeed( speed  )
        end

        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 0
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Eyesight = 3

    else
        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
        slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
        slasher.SlasherValue1 = 0

        SlashCoSlasher[slasher:GetNWBool("Slasher")].Perception = 1
        SlashCoSlasher[slasher:GetNWBool("Slasher")].Eyesight = 6

    end

end
    ::FREESMILEY::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 13 then goto LEUONARD end
do

    v1 = slasher.SlasherValue1 --Summon Cooldown
    v2 = slasher.SlasherValue2 --Selected Summon

    if v1 > 0 then slasher.SlasherValue1 = v1 - FrameTime() end



end
::LEUONARD::
if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 14 then goto NEXT end
do

v1 = slasher.SlasherValue1 --Rape
v2 = slasher.SlasherValue2 --Tick to change mouse drift
v3 = slasher.SlasherValue3 --Tick to move mouse

if slasher.MouseDrift == nil then

    slasher.MouseDrift = Vector(0,0,0)

end

if v1 < 100 then
    if not slasher:GetNWBool("LeuonardRaping") then

        slasher.SlasherValue1 = v1 + ( FrameTime() * 0.5)

        --LOCATE THE DOG..........

        local find = ents.FindInSphere(slasher:GetPos(), 80)

        for f = 1, #find do
            local ent = find[f]

            if ent:GetClass() == "sc_dogg" then --I FOUND YOU........
                ent:Remove()
                slasher:SetNWBool("LeuonardRaping", true)
                slasher:EmitSound("slashco/slasher/leuonard_yell1.mp3")
                slasher:Freeze(true)
                timer.Simple(4, function() 
                    slasher:EmitSound("slashco/slasher/leuonard_grunt_loop.wav")
                    slasher:SetPlaybackRate(5)
                end)
            end

        end

    else
        if v1 > 0 then
            slasher.SlasherValue1 = v1 - ( FrameTime() * 2)
            slasher:SetBodygroup(1,1)
        else
            slasher:SetNWBool("LeuonardRaping", false)
            slasher:SetBodygroup(1,0)
            slasher:Freeze(false)

            SlashCo.CreateItem("sc_dogg", SlashCo.TraceHullLocator(), Angle(0,0,0))

            slasher:StopSound("slashco/slasher/leuonard_grunt_loop.wav")
            slasher:EmitSound("slashco/slasher/leuonard_grunt_finish.mp3")

        end
    end
else

    slasher.SlasherValue1 = 100.25
    slasher:SetNWBool("LeuonardFullRape", true)

end

if v1 == 100.25 then --100% bad word n stuff

    slasher:SetWalkSpeed(450)
    slasher:SetRunSpeed(450)

    if v2 < 0 then
        slasher.MouseDrift = Vector(math.random(-10,10),math.random(-10,10),0)
        slasher.SlasherValue2 = 2 + (math.random() * 2)

        slasher:EmitSound("slashco/slasher/leuonard_yell"..math.random(1,7)..".mp3")
    end

    slasher.SlasherValue2 = slasher.SlasherValue2 - FrameTime()
    slasher.SlasherValue3 = v3 + 1

    if slasher.SlasherValue3 > 1 then
        slasher.SlasherValue3 = 0
        slasher:SetEyeAngles( Angle( slasher:EyeAngles()[1] + (slasher.MouseDrift[1]/5), slasher:EyeAngles()[2] + (slasher.MouseDrift[2]/2), 0 ) )
    end

    local lol = math.random(0,1)

    slasher:SetVelocity( Vector(slasher.MouseDrift[1+lol] * 6,slasher.MouseDrift[2-lol] * 6,0) )

    local find = ents.FindInSphere(slasher:GetPos(), 80)

    for i = 1, #find do
        local ent = find[i]

        if ent:GetClass() == "prop_door_rotating" then
            SlashCo.BustDoor(slasher, ent, 25000)
        end

        if ent:IsPlayer() and ent ~= slasher then
            ent:SetVelocity( slasher:GetForward() * 300 )
            timer.Simple(0.05, function() ent:Kill() end)
        end

    end

end

end

::NEXT::

end