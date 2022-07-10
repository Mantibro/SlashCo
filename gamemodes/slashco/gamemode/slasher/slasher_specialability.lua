local SlashCo = SlashCo

SlashCo.SlasherSpecialAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    --Bababooey's Clone ability
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 1 then goto SID end
do
    if #ents.FindByClass( "sc_babaclone") > 0 then return end
    local clone = SlashCo.CreateItem("sc_babaclone",slasher:GetPos(), slasher:GetAngles())
end

    ::SID::
    --Sid's Gun
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 2 then goto AMOGUS end
    if SlashCo.CurRound.SlasherData.GameProgress < 5 then return end

    if not slasher:GetNWBool("SidGun") and SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 < 0.01 and SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 > 0 then --Equip the gun
        slasher:SetNWBool("SidGun", true)
        slasher:SetNWBool("SidGunEquipping", true)
        slasher:Freeze(true)
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 4
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 4

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 - 1 --Deplete the uses

        timer.Simple(0.5, function() --Show the gun model
        
            slasher:SetBodygroup( 1, 1 )
            slasher:EmitSound("slashco/slasher/sid_draw.wav")

        end)
        timer.Simple(2.25, function() --sound  
            slasher:EmitSound("slashco/slasher/sid_slideback.wav",75,75)
        end)

        timer.Simple(4.5, function() --Apply the state

            slasher:SetNWBool("SidGunEquipping", false)
        
            slasher:SetNWBool("SidGunEquipped", true)

            slasher:Freeze(false)

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 2

            if slasher:GetNWBool("SidGunRage") then

                slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed )

            end

        end)

    elseif slasher:GetNWBool("SidGun") and SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 < 0.01 and not slasher:GetNWBool("SidGunAiming") and not slasher:GetNWBool("SidGunAimed") then
        slasher:SetNWBool("SidGunEquipped", false)
        slasher:SetNWBool("SidGun", false)
        slasher:SetBodygroup( 1, 0 )
        slasher:SetNWBool("SidGunLetterC", false)
        slasher:StopSound("slashco/slasher/sid_THE_LETTER_C.wav")
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = math.random(5,15)
    end

    --Trollge has no special ability

    ::AMOGUS::


    
end