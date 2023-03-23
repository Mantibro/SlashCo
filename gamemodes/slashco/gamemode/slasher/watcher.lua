SlashCoSlasher.Watcher = {}

SlashCoSlasher.Watcher.Name = "The Watcher"
SlashCoSlasher.Watcher.ID = 10
SlashCoSlasher.Watcher.Class = 3
SlashCoSlasher.Watcher.DangerLevel = 2
SlashCoSlasher.Watcher.IsSelectable = true
SlashCoSlasher.Watcher.Model = "models/slashco/slashers/watcher/watcher.mdl"
SlashCoSlasher.Watcher.GasCanMod = 0
SlashCoSlasher.Watcher.KillDelay = 5
SlashCoSlasher.Watcher.ProwlSpeed = 200
SlashCoSlasher.Watcher.ChaseSpeed = 340
SlashCoSlasher.Watcher.Perception = 0.8
SlashCoSlasher.Watcher.Eyesight = 7
SlashCoSlasher.Watcher.KillDistance = 150
SlashCoSlasher.Watcher.ChaseRange = 2000
SlashCoSlasher.Watcher.ChaseRadius = 0.96
SlashCoSlasher.Watcher.ChaseDuration = 2.0
SlashCoSlasher.Watcher.ChaseCooldown = 2
SlashCoSlasher.Watcher.JumpscareDuration = 2
SlashCoSlasher.Watcher.ChaseMusic = "slashco/slasher/watcher_chase.wav"
SlashCoSlasher.Watcher.KillSound = "slashco/slasher/watcher_kill.mp3"
SlashCoSlasher.Watcher.Description = "The Observing Slasher whose power relies on sight.\n\n-The Watcher can Survey the map every once in a while to locate all survivors.\n-He will be slowed down if he is looked at, but anyone who does so will be located.\n-The Watcher can stalk Survivors to build up his special ability, Full Surveillance."
SlashCoSlasher.Watcher.ProTip = "-This Slasher suffers from a loss of speed while observed."
SlashCoSlasher.Watcher.SpeedRating = "★★★★☆"
SlashCoSlasher.Watcher.EyeRating = "★★★★☆"
SlashCoSlasher.Watcher.DiffRating = "★★☆☆☆"

SlashCoSlasher.Watcher.OnSpawn = function(slasher)
    slasher:SetViewOffset( Vector(0,0,100) )
    slasher:SetCurrentViewOffset( Vector(0,0,100) )
end

SlashCoSlasher.Watcher.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Watcher.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

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
        SlashCoSlasher[slasher:GetNWString("Slasher")].CanChase = false
    end

    if slasher:GetNWBool("InSlasherChaseMode") or slasher:GetNWBool("WatcherRage") then

        slasher:SetSlowWalkSpeed( SlashCoSlasher.Watcher.ChaseSpeed - (v3 * 80) )
        slasher:SetWalkSpeed( SlashCoSlasher.Watcher.ChaseSpeed - (v3 * 80) )
        slasher:SetRunSpeed( SlashCoSlasher.Watcher.ChaseSpeed - (v3 * 80) )

    else

        slasher:SetSlowWalkSpeed( SlashCoSlasher.Watcher.ProwlSpeed - (v3 * 120) )
        slasher:SetWalkSpeed( SlashCoSlasher.Watcher.ProwlSpeed - (v3 * 120) )
        slasher:SetRunSpeed( SlashCoSlasher.Watcher.ProwlSpeed - (v3 * 120) )

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

    if v2 < 0.1 and slasher:GetNWBool("WatcherCanSurvey") ~= true then
        slasher:SetNWBool("WatcherCanSurvey", true)
    end

    if v2 >= 0.1 and slasher:GetNWBool("WatcherCanSurvey") ~= false then
        slasher:SetNWBool("WatcherCanSurvey", false)
    end

    slasher:SetNWInt("WatcherStalkTime", v4)

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Watcher.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Watcher.Perception)
end

SlashCoSlasher.Watcher.OnPrimaryFire = function(slasher)
    SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Watcher.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Watcher.OnMainAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

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

end


SlashCoSlasher.Watcher.OnSpecialAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    if SlashCo.CurRound.GameProgress < (10 - (slasher.SlasherValue4/25)) then return end
    if slasher:GetNWBool("WatcherRage") then return end
    if #team.GetPlayers(TEAM_SURVIVOR) < 2 then return end

    slasher:SetNWBool("WatcherRage", true)
    PlayGlobalSound("slashco/slasher/watcher_rage.wav", 100, slasher, 1)

end

SlashCoSlasher.Watcher.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")

    if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Watcher.Footstep = function(ply)

    if SERVER then
        ply:EmitSound( "npc/footsteps/hardboot_generic"..math.random(1,6)..".wav",50,90,0.75)
        return false
    end

    if CLIENT then
		return false
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Watcher.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Watcher") == true  then

            local Overlay = Material("slashco/ui/overlays/watcher_see")

            Overlay:SetFloat( "$alpha", 1 )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
            
        end

        if LocalPlayer():GetNWBool("WatcherSurveyed") == true  then
            if LocalPlayer().al_watch == nil then LocalPlayer().al_watch = 0 end
            if LocalPlayer().al_watch < 100 then LocalPlayer().al_watch = LocalPlayer().al_watch+(FrameTime()*100) end
    
            local Overlay = Material("slashco/ui/overlays/watcher_see")
    
            Overlay:SetFloat( "$alpha", 1 - (LocalPlayer().al_watch/100) )
    
            surface.SetDrawColor(255,255,255,60)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        else
            LocalPlayer().al_watch = nil
        end

    end)

    local SurveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
    local SurveyIcon = Material("slashco/ui/icons/slasher/s_10_a1")

    SlashCoSlasher.Watcher.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        local GameProgress = LocalPlayer():GetNWInt("GameProgressDisplay")

        if LocalPlayer():GetNWBool("WatcherWatched") then
            draw.SimpleText( "YOU ARE BEING WATCHED. . .", "ItemFontTip", ScrW()/2, ScrH()/4, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        end

        if LocalPlayer():GetNWBool("WatcherStalking") then
            draw.SimpleText( "OBSERVING A SURVIVOR. . .", "ItemFontTip", ScrW()/2, ScrH()/4, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        end

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local survivor = team.GetPlayers(TEAM_SURVIVOR)[i]

            if survivor:GetNWBool("SurvivorWatcherSurveyed") then

                local pos = (survivor:GetPos()+Vector(0,0,60)):ToScreen()

                if pos.visible then
                    surface.SetMaterial(SurveyNoticeIcon)
                    surface.DrawTexturedRect(pos.x - ScrW()/32, pos.y - ScrW()/32, ScrW()/16, ScrW()/16)
                end

            end

        end

        if LocalPlayer():GetNWBool("WatcherCanSurvey") and not LocalPlayer():GetNWBool("WatcherRage") then 
            draw.SimpleText( "R - Survey", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
        else
            draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
        end

        if GameProgress > (10 - ( LocalPlayer():GetNWInt("WatcherStalkTime") /25)) and not LocalPlayer():GetNWBool("WatcherRage") and #team.GetPlayers(TEAM_SURVIVOR) > 1 then
            surface.SetMaterial(SurveyIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
            draw.SimpleText( "F - Full Surveillance", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        else
            surface.SetMaterial(SurveyIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
            draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Watcher.ClientSideEffect = function()

    end

end