local SlashCo = SlashCo

hook.Add("Tick", "HandleSlasherAbilities", function()

    if #ents.FindByClass("sc_generator") < 1 then return end

    --Calculate the Game Progress Value
    --The Game Progress Value - Amount of fuel poured into the Generator + amount of batteries inserted (1 - 10)
    local gpg = SlashCo.GasCansPerGenerator
    local gen1 = SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[1]:EntIndex()].Remaining
    local gen2 = SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[2]:EntIndex()].Remaining
    local bg1 = SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[1]:EntIndex()].HasBattery
    local bg2 = SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[2]:EntIndex()].HasBattery
    if SlashCo.CurRound.SlasherData.GameProgress > -1 then SlashCo.CurRound.SlasherData.GameProgress = (gpg - gen1) + (gpg - gen2) + BoolToNumber(bg1) + BoolToNumber(bg2) end

for i = 1, #team.GetPlayers(TEAM_SLASHER) do

        local slasherid = team.GetPlayers(TEAM_SLASHER)[i]:SteamID64()
        local dist = SlashCo.CurRound.SlasherData[slasherid].ChaseRange

        if SlashCo.CurRound.SlasherData[slasherid].CanChase == false then SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 99 end


        if
        --Handle The Chase Functions \/ \/ \/
        if SlashCo.CurRound.SlasherData[slasherid].SlashID == 3 then goto no_chase end
do
        local slasher = team.GetPlayers(TEAM_SLASHER)[i]
        SlashCo.CurRound.SlasherData[slasherid].IsChasing = slasher:GetNWBool("InSlasherChaseMode")

        if not slasher:GetNWBool("InSlasherChaseMode") then goto CONTINUE end

        a = SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick
        SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = a + 0.01

        if slasher:GetEyeTrace().Entity:IsPlayer() then
            target = slasher:GetEyeTrace().Entity	
    
            if target:Team() == TEAM_SURVIVOR and slasher:GetPos():Distance(target:GetPos()) < (dist * 1.3) then
    
                SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 0
    
            end
    
        end

        if a > SlashCo.CurRound.SlasherData[slasherid].ChaseDuration then 

            slasher:SetNWBool("InSlasherChaseMode", false) 

            slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
            slasher:StopSound(SlashCo.CurRound.SlasherData[slasherid].ChaseMusic)
        end
end
        ::CONTINUE::

        ::no_chase::

        --Handle The Chase Functions /\ /\ /\

        --Other Shared Functionality:

        if SlashCo.CurRound.SlasherData[slasherid].KillDelayTick > 0 then SlashCo.CurRound.SlasherData[slasherid].KillDelayTick = SlashCo.CurRound.SlasherData[slasherid].KillDelayTick - 0.01 end


        --Bababooey's Abilites
        if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 1 then goto SID end
    do
        v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --Cooldown for being able to trigger
        v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Cooldown for being able to kill
        v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --Cooldown for spook animation

        if v1 > 0 then 
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = v1 - 0.01 
        end

        if v2 > 0 then 
            SlashCo.CurRound.SlasherData[slasherid].CanKill = false 
        elseif not slasher:GetNWBool("BababooeyInvisibility") then 
            SlashCo.CurRound.SlasherData[slasherid].CanKill = true 
        else 
            SlashCo.CurRound.SlasherData[slasherid].CanKill = false 
        end

        SlashCo.CurRound.SlasherData[slasherid].CanChase = not slasher:GetNWBool("BababooeyInvisibility")

        if v3 < 0.01 then slasher:SetNWBool("BababooeySpooking", false) end

        if v2 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - 0.01 end
        if v3 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = v3 - 0.01 end

    end
        ::SID::
        --Sid's Abilities
        if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 2 then goto TROLLGE end
    do
        v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --Cookies Eaten
        v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Pacification
        v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --Gun use cooldown
        v4 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 --bullet spread
        v5 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 --chase speed increase

        if v2 > 0 then 

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - 0.01 
            SlashCo.CurRound.SlasherData[slasherid].CanKill = false 
            SlashCo.CurRound.SlasherData[slasherid].CanChase = false 

        elseif slasher:GetNWBool("SidGun") then

            SlashCo.CurRound.SlasherData[slasherid].CanKill = false 
            SlashCo.CurRound.SlasherData[slasherid].CanChase = false 
            slasher:SetNWBool("DemonPacified", false)

        else

            SlashCo.CurRound.SlasherData[slasherid].CanKill = true 
            SlashCo.CurRound.SlasherData[slasherid].CanChase = true 
            slasher:SetNWBool("DemonPacified", false)

        end

        if v3 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = v3 - 0.01 end
        if v4 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = v4 - 0.02 end

        if v5 < 160 and slasher:GetNWBool("InSlasherChaseMode") then 
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 = v5 + 0.01
            slasher:SetRunSpeed(SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed + (v5/3.5))
            slasher:SetWalkSpeed(SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed + (v5/3.5))
        else
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 = 0
        end

        if not slasher:GetNWBool("DemonPacified") then

            if not slasher:GetNWBool("SidGun") then

                SlashCo.CurRound.SlasherData[slasherid].Eyesight = SlashCo.SlasherData[2].Eyesight
                SlashCo.CurRound.SlasherData[slasherid].Perception = SlashCo.SlasherData[2].Perception

            else

                if not slasher:GetNWBool("SidGunRage") then

                    SlashCo.CurRound.SlasherData[slasherid].Eyesight = SlashCo.SlasherData[2].Eyesight + 2
                    SlashCo.CurRound.SlasherData[slasherid].Perception = SlashCo.SlasherData[2].Perception + 1.5

                else

                    SlashCo.CurRound.SlasherData[slasherid].Eyesight = SlashCo.SlasherData[2].Eyesight + 5
                    SlashCo.CurRound.SlasherData[slasherid].Perception = SlashCo.SlasherData[2].Perception + 1

                end

            end

         else

            SlashCo.CurRound.SlasherData[slasherid].Eyesight = 0
            SlashCo.CurRound.SlasherData[slasherid].Perception = 0

        end



        if SlashCo.CurRound.SlasherData.GameProgress > 9 and not slasher:GetNWBool("SidGunRage") then 
            slasher:SetNWBool("SidGunRage", true) 

            if slasher:GetNWBool("SidGunEquipped") then 

                if not slasher:GetNWBool("SidGunAimed") and not slasher:GetNWBool("SidGunAiming") then
                    slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed )
                end

            end
        end

        if slasher:GetNWBool("SidGunRage") and not slasher:GetNWBool("SidGunLetterC") and slasher:GetNWBool("SidGunEquipped") then

            slasher:SetNWBool("SidGunLetterC", true)

            PlayGlobalSound("slashco/slasher/sid_THE_LETTER_C.wav",95,slasher)

        end
    end
        ::TROLLGE::
        --Trollge's Abilities
        if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 3 then goto AMOGUS end
    do
        v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --Stage
        v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Claw cooldown
        v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --blood

        if v2 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - 0.01 end
        if v2 > 2 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2 end
        if v2 < 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0 end

        if v1 == 0 then slasher:SetNWBool("TrollgeStage1", false) slasher:SetNWBool("TrollgeStage2", false) end
        if v1 == 1 then slasher:SetNWBool("TrollgeStage1", true) slasher:SetNWBool("TrollgeStage2", false) end
        if v1 == 2 then slasher:SetNWBool("TrollgeStage1", false) slasher:SetNWBool("TrollgeStage2", true) end

        if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage1") and SlashCo.CurRound.SlasherData.GameProgress > 4 and v1 < 1 then

            slasher:SetNWBool("TrollgeTransition", true)
            slasher:Freeze(true)
            slasher:StopSound("slashco/slasher/trollge_breathing.wav")
            PlayGlobalSound("slashco/slasher/trollge_transition.mp3",125,slasher)

            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("DisplayTrollgeTransition",true)
            end

            timer.Simple(7, function() --transit 
                slasher:StopSound("slashco/slasher/trollge_breathing.wav")
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 1
                slasher:SetNWBool("TrollgeTransition", false)
                slasher:Freeze(false)
                PlayGlobalSound("slashco/slasher/trollge_stage1.wav",60,ply)

                slasher:SetRunSpeed( 280 )
                slasher:SetWalkSpeed( 150  )
                SlashCo.CurRound.SlasherData[slasherid].Eyesight = 4

                for i = 1, #player.GetAll() do
                    local ply = player.GetAll()[i]
                    ply:SetNWBool("DisplayTrollgeTransition",false)
                end
            end)

        end

        if v3 > 8 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 8 end

        if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage2") and SlashCo.CurRound.SlasherData.GameProgress > (10 - (v3/2)) and v1 == 1 then

            slasher:SetNWBool("TrollgeTransition", true)
            slasher:Freeze(true)
            slasher:StopSound("slashco/slasher/trollge_stage1.wav")
            PlayGlobalSound("slashco/slasher/trollge_transition.mp3",125,slasher)

            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("DisplayTrollgeTransition",true)
            end

            timer.Simple(7, function() --transit 
                slasher:StopSound("slashco/slasher/trollge_stage1.wav")
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 2
                slasher:SetNWBool("TrollgeTransition", false)
                slasher:Freeze(false)
                PlayGlobalSound("slashco/slasher/trollge_stage6.wav",60,ply)

                slasher:SetRunSpeed( 450 )
                slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed  )
                SlashCo.CurRound.SlasherData[slasherid].Eyesight = 10

                for i = 1, #player.GetAll() do
                    local ply = player.GetAll()[i]
                    ply:SetNWBool("DisplayTrollgeTransition",false)
                end
            end)

        end

        if v3 == 1 then

            SlashCo.CurRound.SlasherData[slasherid].Eyesight = 10 - (   slasher:GetVelocity():Length() / 35 )
            SlashCo.CurRound.SlasherData[slasherid].Perception = 5 - (   slasher:GetVelocity():Length() / 60 )

        end

    end

    ::AMOGUS::

end

end)