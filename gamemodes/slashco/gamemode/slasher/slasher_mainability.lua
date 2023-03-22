local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

SlashCo.SlasherMainAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO

    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 10 then goto ABOMIGNAT end

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
    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 11 then goto FREESMILEY end

    if slasher:GetNWBool("AbomignatCrawling") then 
        slasher:SetNWBool("AbomignatCrawling",false) 
        SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseCooldown
        return 
    end

    if slasher:GetNWBool("InSlasherChaseMode") then return end
    if slasher:GetNWBool("AbomignatSlashing") then return end
    if slasher:GetNWBool("AbomignatLunging") then return end
    if slasher:GetNWBool("AbomignatLungeFinish") then return end
    if SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseActivationCooldown > 0 then return end

    if not slasher:GetNWBool("AbomignatCrawling") then slasher:SetNWBool("AbomignatCrawling",true) end

    ::FREESMILEY::
    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 13 then goto BREN end

    if slasher:GetNWBool("FreeSmileySummoning") then return end
    if slasher.SlasherValue1 > 0 then return end

    if slasher.SlasherValue2 == 0 then slasher.SlasherValue2 = 1 return end
    if slasher.SlasherValue2 == 1 then slasher.SlasherValue2 = 0 return end

    ::BREN::

end