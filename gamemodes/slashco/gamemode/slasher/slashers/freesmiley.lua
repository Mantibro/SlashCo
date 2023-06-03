SlashCoSlasher.FreeSmiley = {}

SlashCoSlasher.FreeSmiley.Name = "Free Smiley Dealer"
SlashCoSlasher.FreeSmiley.ID = 13
SlashCoSlasher.FreeSmiley.Class = 1
SlashCoSlasher.FreeSmiley.DangerLevel = 2
SlashCoSlasher.FreeSmiley.IsSelectable = true
SlashCoSlasher.FreeSmiley.Model = "models/slashco/slashers/freesmiley/freesmiley.mdl"
SlashCoSlasher.FreeSmiley.GasCanMod = 0
SlashCoSlasher.FreeSmiley.KillDelay = 3
SlashCoSlasher.FreeSmiley.ProwlSpeed = 100
SlashCoSlasher.FreeSmiley.ChaseSpeed = 275
SlashCoSlasher.FreeSmiley.Perception = 2.5
SlashCoSlasher.FreeSmiley.Eyesight = 8
SlashCoSlasher.FreeSmiley.KillDistance = 150
SlashCoSlasher.FreeSmiley.ChaseRange = 1600
SlashCoSlasher.FreeSmiley.ChaseRadius = 0.85
SlashCoSlasher.FreeSmiley.ChaseDuration = 5.0
SlashCoSlasher.FreeSmiley.ChaseCooldown = 4
SlashCoSlasher.FreeSmiley.JumpscareDuration = 2
SlashCoSlasher.FreeSmiley.ChaseMusic = "slashco/slasher/freesmiley_chase.wav"
SlashCoSlasher.FreeSmiley.KillSound = "slashco/slasher/freesmiley_kill.mp3"
SlashCoSlasher.FreeSmiley.Description = "The Summoner Slasher which uses his minions to take control of the map.\n\n-Free Smiley Dealer can summon two types of minions, Pensive and Zany.\nBoth will alert him when a Survivor is detected.\n-Pensive can stun a Survivor for a short while.\n-Zany will charge at Survivors and damage them."
SlashCoSlasher.FreeSmiley.ProTip = "-This Slasher does not work alone."
SlashCoSlasher.FreeSmiley.SpeedRating = "★☆☆☆☆"
SlashCoSlasher.FreeSmiley.EyeRating = "★★★☆☆"
SlashCoSlasher.FreeSmiley.DiffRating = "★★☆☆☆"

SlashCoSlasher.FreeSmiley.OnSpawn = function(slasher)
    SlashCoSlasher.FreeSmiley.SmileyIdle(slasher)
    slasher:SetNWBool("CanKill", true)
    slasher:SetNWBool("CanChase", true)
end

SlashCoSlasher.FreeSmiley.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.FreeSmiley.OnTickBehaviour = function(slasher)

    v1 = slasher.SlasherValue1 --Summon Cooldown
    v2 = slasher.SlasherValue2 --Selected Summon

    if v1 > 0 then slasher.SlasherValue1 = v1 - FrameTime() end

    slasher:SetNWInt("SmileySummonCooldown", math.floor(v1))
    slasher:SetNWInt("SmileySummonSelect", v2)

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.FreeSmiley.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.FreeSmiley.Perception)
end

SlashCoSlasher.FreeSmiley.OnPrimaryFire = function(slasher)
    SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.FreeSmiley.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.FreeSmiley.OnMainAbilityFire = function(slasher)

    if slasher:GetNWBool("FreeSmileySummoning") then return end
    if slasher.SlasherValue1 > 0 then return end

    if slasher.SlasherValue2 == 0 then slasher.SlasherValue2 = 1 return end
    if slasher.SlasherValue2 == 1 then slasher.SlasherValue2 = 0 return end

end


SlashCoSlasher.FreeSmiley.OnSpecialAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher.SlasherValue1 > 0 then return end
    slasher.SlasherValue1 = 50 - (SO*25)

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

end

SlashCoSlasher.FreeSmiley.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")
    local smiley_summon = ply:GetNWBool("FreeSmileySummoning")

    if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_HL2MP_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN 
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if smiley_summon then

		ply.CalcSeqOverride = ply:LookupSequence("summon")
		if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end

    else
        ply.anim_antispam = false
	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.FreeSmiley.Footstep = function(ply)

    if SERVER then

        if ply.SmileyStepTick == nil or ply.SmileyStepTick > 1 then ply.SmileyStepTick = 0 end

			if ply.SmileyStepTick == 0 then 
				ply:EmitSound( "npc/footsteps/hardboot_generic"..math.random(1,6)..".wav",50,70,0.75) 
				ply.SmileyStepTick = ply.SmileyStepTick + 1
				return false
			end

			ply.SmileyStepTick = ply.SmileyStepTick + 1

        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.FreeSmiley.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_FreeSmiley") == true  then

            local Overlay = Material("slashco/ui/overlays/jumpscare_13")

            Overlay:SetFloat( "$alpha", 1 )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
            
        end

    end)

    local ZanyIcon = Material("slashco/ui/icons/slasher/s_13_a1")
    local PensiveIcon = Material("slashco/ui/icons/slasher/s_13_a2")
    local SurveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
    local KillDisabledIcon = Material("slashco/ui/icons/slasher/kill_disabled")

    SlashCoSlasher.FreeSmiley.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        local V1 = LocalPlayer():GetNWInt("SmileySummonCooldown")
        local V2 = LocalPlayer():GetNWInt("SmileySummonSelect")

        if V1 < 0.1 then 
            draw.SimpleText( "R - Switch your Deal", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT)

            if V2 == 0 then
                surface.SetMaterial(ZanyIcon)
                surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
                draw.SimpleText( "F - Deal a Zany", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
            else
                surface.SetMaterial(PensiveIcon)
                surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
                draw.SimpleText( "F - Deal a Pensive", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
            end

        else
            surface.SetMaterial(KillDisabledIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
            draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 

            draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
        end

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local survivor = team.GetPlayers(TEAM_SURVIVOR)[i]

            if survivor:GetNWBool("MarkedBySmiley") then

                local pos = (survivor:GetPos()+Vector(0,0,60)):ToScreen()

                if pos.visible then
                    surface.SetMaterial(SurveyNoticeIcon)
                    surface.DrawTexturedRect(pos.x - ScrW()/32, pos.y - ScrW()/32, ScrW()/16, ScrW()/16)
                end

            end

        end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.FreeSmiley.ClientSideEffect = function()

    end

end

if SERVER then

    SlashCoSlasher.FreeSmiley.SmileyIdle = function(slasher)

        if not slasher:GetNWBool("InSlasherChaseMode") then 
            slasher:EmitSound("slashco/slasher/freesmiley_idle"..math.random(1,7)..".mp3")     
        end
    
        timer.Simple(math.random(3,5), function()
    
            SlashCoSlasher.FreeSmiley.SmileyIdle(slasher)
        
        end)
        
    
    end
    
    
end