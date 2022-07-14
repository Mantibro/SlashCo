local SlashCo = SlashCo

SlashCo.SlasherMainAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO

    --Bababooey's Invisibility ability \/ \/ \/

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 1 then goto SID end

do --To Prevent local value jump error
    local cooldown = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1

    if cooldown > 0 then return end
    if slasher:GetNWBool("InSlasherChaseMode") then return end

    slasher:SetNWBool("BababooeyInvisibility", not slasher:GetNWBool("BababooeyInvisibility")) 

    if slasher:GetNWBool("BababooeyInvisibility") then --Turning invisible

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 4
        slasher:EmitSound("slashco/slasher/baba_hide.mp3")

        timer.Simple(1, function() --Delay for entering invisibility

			slasher:SetMaterial("Models/effects/vol_light001")
		    slasher:SetColor(Color(0,0,0,0))

            PlayGlobalSound("slashco/slasher/bababooey_loud.mp3", 130, slasher)

            slasher:SetRunSpeed( 250 )
            slasher:SetWalkSpeed( 250 )

        end)

    else

        slasher:EmitSound("slashco/slasher/baba_reveal.mp3")

        --Spook Appear
        if slasher:GetEyeTrace().Entity:IsPlayer() then

            target = slasher:GetEyeTrace().Entity	

            if target:Team() != TEAM_SURVIVOR then goto SKIP end  

            if slasher:GetPos():Distance(target:GetPos()) < 150 then
  
                slasher:SetNWBool("BababooeySpooking", true)
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 2
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
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = math.random(3,(13 - (SO * 6)))
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 8

        ::SPOOKAPPEAR::

        slasher:SetMaterial("")
		slasher:SetColor(Color(255,255,255,255))

        slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )

    end

end --ends here

    --Bababooey's Invisibility ability /\ /\ /\

    ::SID::

    --Sid's Cookie Eating \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 2 then goto AMOGUS end

    if slasher:GetEyeTrace().Entity:GetClass() == "sc_cookie" then

        target = slasher:GetEyeTrace().Entity	

        if slasher:GetPos():Distance(target:GetPos()) < 150 and not slasher:GetNWBool("SidEating") and not slasher:GetNWBool("SidGun")  then

            slasher:SetNWBool("SidEating", true)
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 99
            slasher:EmitSound("slashco/slasher/sid_cookie"..math.random(1,2)..".mp3")

            timer.Simple(1.3, function() 
                slasher:EmitSound("slashco/slasher/sid_eating.mp3")
            end)

            slasher:Freeze(true)

            timer.Simple(10, function() 
                slasher:Freeze(false) 
                slasher:SetNWBool("SidEating", false) 
                slasher:SetNWBool("DemonPacified", true)
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 + 1 + SatO
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = math.random(15,25)
                target:Remove()
            end)
        end
    end

    --Sid's Cookie Eating /\ /\ /\

    --Trollge has no main ability

    ::AMOGUS::

    --Amogus Human Transform \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 4 then goto THIRSTY end

    if not slasher:GetNWBool("AmogusDisguising") and v2 < 0.01 and not slasher:GetNWBool("AmogusSurvivorDisguise") and not slasher:GetNWBool("AmogusDisguised") then

        slasher:SetNWBool("AmogusDisguising", true)
        slasher:Freeze(true)

        slasher:EmitSound("slashco/slasher/amogus_transform"..math.random(1,2)..".mp3")

        timer.Simple(2, function() 
            slasher:Freeze(false) 
            slasher:SetNWBool("AmogusDisguising", false)
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2

            slasher:SetNWBool("AmogusSurvivorDisguise", true)
            slasher:SetNWBool("AmogusDisguised", true)

            slasher:EmitSound("slashco/slasher/amogus_sus.mp3")

            local rand = math.random( 1, 5 )
	        local id = 1
	        if rand < 3 then id = rand elseif rand == 3 then id = 5 elseif rand == 4 then id = 7 end
	        local modelname = "models/slashco/survivor/male_0"..id..".mdl"
	        util.PrecacheModel( modelname )
	        slasher:SetModel( modelname )

            slasher:SetRunSpeed( 300 )
            slasher:SetWalkSpeed( 200 )

        end)

    elseif not slasher:GetNWBool("AmogusDisguising") and v2 < 0.01 and slasher:GetNWBool("AmogusDisguised") then

        slasher:Freeze(true)
        slasher:SetNWBool("AmogusSurvivorDisguise", false)
        slasher:SetNWBool("AmogusFuelDisguise", false)
        slasher:SetNWBool("AmogusDisguised", false)
        slasher:EmitSound("slashco/slasher/amogus_reveal.mp3")

        util.PrecacheModel( "models/slashco/slashers/amogus/amogus.mdl" )
	    slasher:SetModel( "models/slashco/slashers/amogus/amogus.mdl" )

        slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )

        timer.Simple(2 - (SO * 1.95), function() 
            slasher:Freeze(false) 
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 3 - (SO * 2.8)
        end)

    end

    --Amogus Human Transform /\ /\ /\

    ::THIRSTY::


end