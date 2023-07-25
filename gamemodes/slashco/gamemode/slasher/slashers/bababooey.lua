SlashCoSlasher.Bababooey = {}

SlashCoSlasher.Bababooey.Name = "Bababooey"
SlashCoSlasher.Bababooey.ID = 1
SlashCoSlasher.Bababooey.Class = 1
SlashCoSlasher.Bababooey.DangerLevel = 1
SlashCoSlasher.Bababooey.IsSelectable = true
SlashCoSlasher.Bababooey.Model = "models/slashco/slashers/baba/baba.mdl"
SlashCoSlasher.Bababooey.GasCanMod = 0
SlashCoSlasher.Bababooey.KillDelay = 3
SlashCoSlasher.Bababooey.ProwlSpeed = 150
SlashCoSlasher.Bababooey.ChaseSpeed = 298
SlashCoSlasher.Bababooey.Perception = 1.0
SlashCoSlasher.Bababooey.Eyesight = 5
SlashCoSlasher.Bababooey.KillDistance = 135
SlashCoSlasher.Bababooey.ChaseRange = 600
SlashCoSlasher.Bababooey.ChaseRadius = 0.91
SlashCoSlasher.Bababooey.ChaseDuration = 10.0
SlashCoSlasher.Bababooey.ChaseCooldown = 3
SlashCoSlasher.Bababooey.JumpscareDuration = 1.5
SlashCoSlasher.Bababooey.ChaseMusic = "slashco/slasher/baba_chase.wav"
SlashCoSlasher.Bababooey.KillSound = "slashco/slasher/baba_kill.mp3"
SlashCoSlasher.Bababooey.Description = "The Phantom Slasher which specialises in illusion abilities to catch \nsurvivors off-guard.\n\n-Bababooey can turn himself invisible.\n-He can create a phantom clone of himself to scare and locate Survivors."
SlashCoSlasher.Bababooey.ProTip = "-This Slasher has the ability to vanish into thin air."
SlashCoSlasher.Bababooey.SpeedRating = "★★★☆☆"
SlashCoSlasher.Bababooey.EyeRating = "★★★☆☆"
SlashCoSlasher.Bababooey.DiffRating = "★☆☆☆☆"

SlashCoSlasher.Bababooey.OnSpawn = function(slasher)
    SlashCoSlasher.Bababooey.DoSound(slasher)
end

SlashCoSlasher.Bababooey.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Bababooey.DoSound = function(slasher)

    if slasher:GetNWBool("BababooeyInvisibility") then
        slasher:EmitSound("slashco/slasher/baba_laugh"..math.random(2,4)..".mp3", 30+math.random(1,45))
    end

    timer.Simple(math.random(6,10), function() SlashCoSlasher.Bababooey.DoSound(slasher) end)
end

SlashCoSlasher.Bababooey.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    local v1 = slasher.SlasherValue1 --Cooldown for being able to trigger
    local v2 = slasher.SlasherValue2 --Cooldown for being able to kill
    local v3 = slasher.SlasherValue3 --Cooldown for spook animation

    if v1 > 0 then 
        slasher.SlasherValue1 = v1 - (FrameTime() + (SO * 0.04)) 
    end

    if v2 > 0 then 
        slasher:SetNWBool("CanKill", false)
    elseif not slasher:GetNWBool("BababooeyInvisibility") then 
        slasher:SetNWBool("CanKill", true)
    else 
        slasher:SetNWBool("CanKill", false)
    end

    slasher:SetNWBool("CanChase", not slasher:GetNWBool("BababooeyInvisibility"))

    if v3 < 0.01 then slasher:SetNWBool("BababooeySpooking", false) end

    if v2 > 0 then slasher.SlasherValue2 = v2 - (FrameTime() + (SO * 0.04)) end
    if v3 > 0 then slasher.SlasherValue3 = v3 - (FrameTime() + (SO * 0.04)) end



    
    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Bababooey.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Bababooey.Perception)

end

SlashCoSlasher.Bababooey.OnPrimaryFire = function(slasher)
    SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Bababooey.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Bababooey.OnMainAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    local cooldown = slasher.SlasherValue1

    if cooldown > 0 then return end
    if slasher:GetNWBool("InSlasherChaseMode") then return end

    slasher:SetNWBool("BababooeyInvisibility", not slasher:GetNWBool("BababooeyInvisibility")) 

    if slasher:GetNWBool("BababooeyInvisibility") then --Turning invisible

        slasher.SlasherValue1 = 4
        slasher:EmitSound("slashco/slasher/baba_hide.mp3")

        timer.Simple(1, function() --Delay for entering invisibility

			slasher:SetMaterial("Models/effects/vol_light001")
		    slasher:SetColor(Color(0,0,0,0))

            PlayGlobalSound("slashco/slasher/bababooey_loud.mp3", 130, slasher)

            slasher:SetRunSpeed( 200 )
            slasher:SetWalkSpeed( 200 )

        end)

    else

        slasher:EmitSound("slashco/slasher/baba_reveal.mp3")

        --Spook Appear
        if slasher:GetEyeTrace().Entity:IsPlayer() then

            target = slasher:GetEyeTrace().Entity	

            if target:Team() ~= TEAM_SURVIVOR then goto SKIP end

            if slasher:GetPos():Distance(target:GetPos()) < 150 then
  
                slasher:SetNWBool("BababooeySpooking", true)
                slasher.SlasherValue2 = 2
                slasher.SlasherValue3 = 2
                slasher:EmitSound("slashco/slasher/baba_scare.mp3",100)
                slasher:Freeze(true)
                timer.Simple(2.5, function() slasher:Freeze(false) end)

                goto SPOOKAPPEAR
            else 
                goto SKIP
            end
        else 
            goto SKIP  
        end
        ::SKIP::

        --Quiet appear
        slasher.SlasherValue2 = math.random(3,(13 - (SO * 6)))
        slasher.SlasherValue1 = 8

        ::SPOOKAPPEAR::

        slasher:SetMaterial("")
		slasher:SetColor(Color(255,255,255,255))

        slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ProwlSpeed )

    end

end


SlashCoSlasher.Bababooey.OnSpecialAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    if #ents.FindByClass( "sc_babaclone") > SO then return end
    local clone = SlashCo.CreateItem("sc_babaclone",slasher:GetPos(), slasher:GetAngles())

end

SlashCoSlasher.Bababooey.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")
    local spook = ply:GetNWBool("BababooeySpooking")

	if ply:IsOnGround() then

		if not spook then

			if not chase then 
				ply.CalcIdeal = ACT_HL2MP_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			else
				ply.CalcIdeal = ACT_HL2MP_RUN 
				ply.CalcSeqOverride = ply:LookupSequence("chase")
			end

		else
			ply.CalcSeqOverride = ply:LookupSequence("spook")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Bababooey.Footstep = function(ply)

    if SERVER then

        if ply:GetNWBool("BababooeyInvisibility") then return true end

        ply:EmitSound( "slashco/slasher/babastep_0"..math.random(1,3)..".mp3") 
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Bababooey.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Bababooey") == true  then

            if LocalPlayer().baba_f == nil then LocalPlayer().baba_f = 0 end
            LocalPlayer().baba_f = LocalPlayer().baba_f+(FrameTime()*20)
            if LocalPlayer().baba_f > 45 then return end

            local Overlay = Material("slashco/ui/overlays/jumpscare_1")
            Overlay:SetInt( "$frame", math.floor(LocalPlayer().baba_f) )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        --else
            --f = nil --????? leftover code maybe?
        end

    end)

    local BababooeyInvisible = Material("slashco/ui/icons/slasher/s_1_a1")
    local BababooeyInactiveClone = Material("slashco/ui/icons/slasher/s_1_a2_1")
    local BababooeyActiveClone = Material("slashco/ui/icons/slasher/s_1_a2")

    SlashCoSlasher.Bababooey.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        local invis =  LocalPlayer():GetNWBool("BababooeyInvisibility")

        if #ents.FindByClass( "sc_babaclone") > 0 then
            surface.SetMaterial(BababooeyInactiveClone)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
            draw.SimpleText( "Clone Set", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        else
            surface.SetMaterial(BababooeyActiveClone)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.33), ScrW()/16, ScrW()/16)
            draw.SimpleText( "F - Set Clone", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        end
            

        if invis then 
            surface.SetMaterial(BababooeyInvisible)
            surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
        end

        willdrawmain = not invis

        draw.SimpleText( "R - Toggle Invisibility", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Bababooey.ClientSideEffect = function()

    end

end