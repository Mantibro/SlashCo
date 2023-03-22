local SlashCo = SlashCo

SlashCo.SlasherSpecialAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 10 then goto ABOMIGNAT end
    --Watcher Surveillance \/ \/ \/

    if SlashCo.CurRound.GameProgress < (10 - (slasher.SlasherValue4/25)) then return end
    if slasher:GetNWBool("WatcherRage") then return end
    if #team.GetPlayers(TEAM_SURVIVOR) < 2 then return end

    slasher:SetNWBool("WatcherRage", true)
    PlayGlobalSound("slashco/slasher/watcher_rage.wav", 100, slasher, 1)

    --Watcher Surveillance /\ /\ /\

    ::ABOMIGNAT::
    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 11 then goto CRIMINAL end
    
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
    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 12 then goto FREESMILEY end
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
    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 13 then goto BREN end

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