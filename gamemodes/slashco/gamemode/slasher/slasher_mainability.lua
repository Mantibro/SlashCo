local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

SlashCo.SlasherMainAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO


    --Tyler's State Switch \/ \/ \/
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 7 then goto MANSPIDER end

    if slasher.SlasherValue1 == 0 then

        slasher.SlasherValue1 = 1

        --local song = math.random(1,6)

        slasher:SetColor(Color(255,255,255,255))
        slasher:DrawShadow(true)
		slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		slasher:SetNoDraw(false)

        --PlayGlobalSound("slashco/slasher/tyler_song_"..song..".mp3", 90 - (math.sqrt(slasher.SlasherValue3) * (25 / SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE)), slasher, 0.8 - (slasher.SlasherValue3 * 0.05))

        --slasher.TylerSong = CreateSound( slasher, "slashco/slasher/tyler_song_"..song..".mp3")
        --slasher.TylerSong:SetSoundLevel( 85 - (math.sqrt(slasher.SlasherValue3) * (25 / SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE)) )
        --slasher.TylerSong:ChangeVolume( 0.8 - (slasher.SlasherValue3 * 0.05))

    end

    --Tyler's State Switch /\ /\ /\

    --Borgmire has no main ability

    ::MANSPIDER::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 9 then goto WATCHER end

    if slasher.SlasherValue1 ~= "" then return end

    if not slasher:GetNWBool("ManspiderNested") then

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local s = team.GetPlayers(TEAM_SURVIVOR)[i]
    
            if s:GetPos():Distance( slasher:GetPos() ) < 1600 then
    
                slasher:ChatPrint("Cannot Nest here, a Survivor is too close. . .")
                return
    
            end
    
        end

        slasher:SetNWBool("ManspiderNested", true)

        slasher:SetRunSpeed( 1 )
        slasher:SetWalkSpeed( 1 )
        slasher:SetSlowWalkSpeed( 1 )

    else

        if slasher.SlasherValue3 > 100 then

            slasher:SetNWBool("ManspiderNested", false)

            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
            slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )

        end

    end

    ::WATCHER::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 10 then goto ABOMIGNAT end

        if slasher.SlasherValue2 > 0 then return end
        if slasher:GetNWBool("WatcherRage") then return end

        slasher.SlasherValue1 = 10 + (SO * 10)
        slasher.SlasherValue2 = 100 - (SO * 35)

        PlayGlobalSound("slashco/slasher/watcher_locate.mp3", 100, slasher, 1)

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do
            local p = team.GetPlayers(TEAM_SURVIVOR)[i]
            p:SetNWBool("WatcherSurveyed", true)
            p:EmitSound("slashco/slasher/watcher_see.mp3")
        end

        timer.Simple(5 + (SO*5), function() 
        
            for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do
                local p = team.GetPlayers(TEAM_SURVIVOR)[i]
                p:SetNWBool("WatcherSurveyed", false)
            end
        
        end)

    ::ABOMIGNAT::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 11 then goto FREESMILEY end

    if slasher:GetNWBool("AbomignatCrawling") then 
        slasher:SetNWBool("AbomignatCrawling",false) 
        SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseCooldown
        return 
    end

    if slasher:GetNWBool("InSlasherChaseMode") then return end
    if slasher:GetNWBool("AbomignatSlashing") then return end
    if slasher:GetNWBool("AbomignatLunging") then return end
    if slasher:GetNWBool("AbomignatLungeFinish") then return end
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown > 0 then return end

    if not slasher:GetNWBool("AbomignatCrawling") then slasher:SetNWBool("AbomignatCrawling",true) end

    ::FREESMILEY::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 13 then goto BREN end

    if slasher:GetNWBool("FreeSmileySummoning") then return end
    if slasher.SlasherValue1 > 0 then return end

    if slasher.SlasherValue2 == 0 then slasher.SlasherValue2 = 1 return end
    if slasher.SlasherValue2 == 1 then slasher.SlasherValue2 = 0 return end

    ::BREN::

end