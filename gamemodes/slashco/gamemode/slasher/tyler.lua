SlashCoSlasher.Tyler = {}

SlashCoSlasher.Tyler.Name = "Tyler"
SlashCoSlasher.Tyler.ID = 7
SlashCoSlasher.Tyler.Class = 2
SlashCoSlasher.Tyler.DangerLevel = 3
SlashCoSlasher.Tyler.IsSelectable = true
SlashCoSlasher.Tyler.Model = "models/slashco/slashers/tyler/tyler.mdl"
SlashCoSlasher.Tyler.GasCanMod = -6
SlashCoSlasher.Tyler.KillDelay = 6
SlashCoSlasher.Tyler.ProwlSpeed = 300
SlashCoSlasher.Tyler.ChaseSpeed = 580
SlashCoSlasher.Tyler.Perception = 0.0
SlashCoSlasher.Tyler.Eyesight = 5
SlashCoSlasher.Tyler.KillDistance = 200
SlashCoSlasher.Tyler.ChaseRange = 0
SlashCoSlasher.Tyler.ChaseRadius = 1
SlashCoSlasher.Tyler.ChaseDuration = 0.0
SlashCoSlasher.Tyler.ChaseCooldown = 3
SlashCoSlasher.Tyler.JumpscareDuration = 2
SlashCoSlasher.Tyler.ChaseMusic = ""
SlashCoSlasher.Tyler.KillSound = "slashco/slasher/tyler_kill.mp3"
SlashCoSlasher.Tyler.Description = "The Balance Slasher who controls the progress of the round.\n\n-Tyler has two forms. Creator, and Destroyer.\n-Tyler, the Creator will create gas cans for survivors upon being found.\nTyler, the Destroyer will destroy anything in its path."
SlashCoSlasher.Tyler.ProTip = "-Noticeably fewer Fuel Cans were spotted in this Slasher's Zone."
SlashCoSlasher.Tyler.SpeedRating = "★★★★★"
SlashCoSlasher.Tyler.EyeRating = "★☆☆☆☆"
SlashCoSlasher.Tyler.DiffRating = "★★★★☆"

SlashCoSlasher.Tyler.OnSpawn = function(slasher)

    slasher.SlasherValue1 = 0

    slasher:SetColor(Color(0,0,0,0))
    slasher:DrawShadow(false)
	slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
	slasher:SetNoDraw(true)

end

SlashCoSlasher.Tyler.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Tyler.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    v1 = slasher.SlasherValue1 --State
    v2 = slasher.SlasherValue2 --Time Spent as Creator or destroyer
    v3 = slasher.SlasherValue3 --Times Found
    v4 = slasher.SlasherValue4 --Destruction power
    v5 = slasher.SlasherValue5 --Destoyer Blink

    local final_eyesight = SlashCoSlasher.Tyler.Eyesight
    local final_perception = SlashCoSlasher.Tyler.Perception

    local ms = SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE

    if v1 == 0 then --Specter

        slasher.TylerSongPickedID = nil

        slasher:SetNWBool("TylerFlash", false)

        slasher:SetSlowWalkSpeed( SlashCoSlasher.Tyler.ProwlSpeed ) 
        slasher:SetRunSpeed(SlashCoSlasher.Tyler.ProwlSpeed )
        slasher:SetWalkSpeed(SlashCoSlasher.Tyler.ProwlSpeed )
        slasher:SetNWBool("TylerTheCreator", false)
        slasher:SetBodygroup( 0, 0 )
        slasher.SlasherValue2 = 0
        slasher:SetNWBool("CanKill", false)
        final_perception = 6.0

    elseif v1 == 1 then --Creator

        slasher:SetNWBool("TylerFlash", false)

        slasher:SetSlowWalkSpeed( 1 ) 
        slasher:SetRunSpeed(1)
        slasher:SetWalkSpeed(1)
        slasher:Freeze(true)
        slasher:SetNWBool("TylerTheCreator", true)
        slasher:SetBodygroup( 0, 0 )
        slasher.SlasherValue2 = v2 + FrameTime()
        slasher:SetNWBool("CanKill", false)
        final_perception = 0.0

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
        slasher:SetNWBool("CanKill", false)
        final_perception = 0.0

    elseif v1 == 3 then --Destroyer

        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseSpeed ) 
        slasher:SetRunSpeed(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseSpeed)
        slasher:SetWalkSpeed(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseSpeed)
        slasher:SetNWBool("TylerTheCreator", false)
        slasher:SetBodygroup( 0, 1 )
        slasher.SlasherValue2 = v2 + FrameTime()
        slasher:SetNWBool("CanKill", true)
        final_perception = 2.0

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

    if slasher:GetNWInt("TylerState") ~= v1 then
        slasher:SetNWInt("TylerState", v1)
    end

    slasher:SetNWFloat("Slasher_Eyesight", final_eyesight )
    slasher:SetNWInt("Slasher_Perception", final_perception )
end

SlashCoSlasher.Tyler.OnPrimaryFire = function(slasher)

    if slasher.SlasherValue1 ~= 3 then return end

        if slasher:GetNWBool("CanKill") == false then return end
    
        if slasher.KillDelayTick > 0 then return end
        
        if slasher:GetEyeTrace().Entity then

            local target = slasher:GetEyeTrace().Entity	

            local c = target:GetClass()
    
            if not target:IsPlayer() and c ~= "prop_physics" and c ~= "sc_milkjug" and c ~= "sc_cookie" and c ~= "sc_stepdecoy" and c ~= "sc_baby" and c ~= "sc_devildie" and c ~= "sc_mayo" and c ~= "sc_soda" then return end
    
            if slasher:GetPos():Distance(target:GetPos()) < dist and not target:GetNWBool("SurvivorBeingJumpscared") then
    
                target:SetNWBool("SurvivorBeingJumpscared",true)
                target:SetNWBool("SurvivorJumpscare_Tyler", true)
    
                slasher:EmitSound(SlashCoSlasher[slasher:GetNWString("Slasher")].KillSound)
                    
                if target:IsPlayer() then target:Freeze(true) end
                slasher:Freeze(true)
    
                slasher.KillDelayTick = slasher.KillDelay

                slasher.SlasherValue2 = 0
    
                timer.Simple(SlashCoSlasher[slasher:GetNWString("Slasher")].JumpscareDuration, function()
    
                    target:SetNWBool("SurvivorBeingJumpscared",false)
                    target:SetNWBool("SurvivorJumpscare_Tyler", false)
    
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

SlashCoSlasher.Tyler.OnSecondaryFire = function(slasher)

end

SlashCoSlasher.Tyler.OnMainAbilityFire = function(slasher)

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

end


SlashCoSlasher.Tyler.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.Tyler.Animator = function(ply) 

    local tyler_creator = ply:GetNWBool("TylerTheCreator")
	local tyler_creating = ply:GetNWBool("TylerCreating")

    if tyler_creator then

		if not tyler_creating then

			--ply.CalcIdeal = ACT_HL2MP_IDLE 
			ply.CalcSeqOverride = ply:LookupSequence("creator idle")

			ply.anim_antispam = false

		else

			ply.CalcSeqOverride = ply:LookupSequence("create") 
			if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end

		end

	else

		if ply:GetVelocity():LengthSqr() > 5 then

			--ply.CalcIdeal = ACT_HL2MP_IDLE 
			ply.CalcSeqOverride = ply:LookupSequence("destroyer walk")

		else

			--ply.CalcIdeal = ACT_HL2MP_IDLE 
			ply.CalcSeqOverride = ply:LookupSequence("destroyer activated")

		end

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Tyler.Footstep = function(ply)

    if SERVER then
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Tyler.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Tyler") == true  then

            if LocalPlayer().tyl_f == nil then LocalPlayer().tyl_f = 0 end
            LocalPlayer().tyl_f = LocalPlayer().tyl_f+(FrameTime()*20)
            if LocalPlayer().tyl_f > 39 then LocalPlayer().tyl_f = 25 end
    
            local Overlay = Material("slashco/ui/overlays/jumpscare_7")
            Overlay:SetInt( "$frame", math.floor(LocalPlayer().tyl_f) )
    
            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        else
            LocalPlayer().tyl_f = nil
        end

        if LocalPlayer():GetNWBool("DisplayTylerTheDestroyerEffects") == true  then

            local Overlay = Material("slashco/ui/overlays/tyler_static")
    
            local DestroyerFace = Material("slashco/ui/overlays/tyler_destroyer_face")
    
            Overlay:SetFloat( "$alpha", math.Rand(0.2,0.23) )
    
            DestroyerFace:SetFloat( "$alpha", math.Rand(0,0.1) )
    
            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    
            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(DestroyerFace)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

        end

    end)

    local DestroyerIcon = Material("slashco/ui/icons/slasher/s_7_s1")

    SlashCoSlasher.Tyler.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = false
        local willdrawmain = true

        local V1 = LocalPlayer():GetNWInt("TylerState")

        --local name = ", The Creator"

        if V1 < 1 then
            draw.SimpleText( "R - Manifest", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        elseif V1 == 1 then
            draw.SimpleText( "(Wait until you're found or you become Destroyer)", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        end

        if V1 > 1 then

            --name = ", The Destroyer"

            willdrawmain = false

            surface.SetMaterial(DestroyerIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 

        end

        if V1 > 2 then

            surface.SetMaterial(DestroyerIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
            draw.SimpleText( "M1 - Destroy", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

            willdrawkill = false

        end

            --SlashName = "Tyler"..name

            return willdrawkill, willdrawchase, willdrawmain

        end

        SlashCoSlasher.Tyler.ClientSideEffect = function()

        end

end