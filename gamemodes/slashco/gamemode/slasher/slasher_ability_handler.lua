local SlashCo = SlashCo

hook.Add("Tick", "HandleSlasherAbilities", function()

    if #ents.FindByClass("sc_generator") < 1 then return end

    local SO = SlashCo.CurRound.OfferingData.SO

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
        local dist = SlashCo.CurRound.SlasherData[slasherid].ChaseRange + (SO * 250)

        local slasher = team.GetPlayers(TEAM_SLASHER)[i]

        --Handle The Chase Functions \/ \/ \/
        SlashCo.CurRound.SlasherData[slasherid].IsChasing = slasher:GetNWBool("InSlasherChaseMode")
        if SlashCo.CurRound.SlasherData[slasherid].CanChase == false then SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 99 end

        if SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown > 0 then 

            SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown = SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown - FrameTime() 

        end

        if not slasher:GetNWBool("InSlasherChaseMode") or  SlashCo.CurRound.SlasherData[slasherid].SlashID == 3 then goto CONTINUE end
do
        a = SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick
        SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = a + FrameTime()

        --local inv = (1 - SlashCo.CurRound.SlasherData[slasherid].ChaseRadius) / 2
        local inv = -0.2

        local find = ents.FindInCone( slasher:GetPos(), slasher:GetEyeTrace().Normal, dist * 2, SlashCo.CurRound.SlasherData[slasherid].ChaseRadius + inv )

        for i = 1, #find do

            if find[i]:IsPlayer() and find[i]:Team() == TEAM_SURVIVOR then 

                SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 0

            end

        end

        if slasher:GetEyeTrace().Entity:IsPlayer() and slasher:GetEyeTrace().Entity:Team() == TEAM_SURVIVOR and slasher:GetPos():Distance(slasher:GetEyeTrace().Entity:GetPos()) < dist * 2 then
            SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 0
            find = slasher:GetEyeTrace().Entity
        end

        if not find:GetNWBool("SurvivorChased") then find:SetNWBool("SurvivorChased",true) end

        if a > SlashCo.CurRound.SlasherData[slasherid].ChaseDuration then 

            slasher:SetNWBool("InSlasherChaseMode", false) 

            slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
            slasher:StopSound(SlashCo.CurRound.SlasherData[slasherid].ChaseMusic)

            SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown = SlashCo.CurRound.SlasherData[slasherid].ChaseCooldown

            timer.Simple(0.25, function() slasher:StopSound(SlashCo.CurRound.SlasherData[slasherid].ChaseMusic) end)
        end

        if not slasher:GetNWBool("InSlasherChaseMode") then
            for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do
                local ply = team.GetPlayers(TEAM_SURVIVOR)[i]
                if ply:GetNWBool("SurvivorChased") then ply:SetNWBool("SurvivorChased",false) end
            end
        end
end
        ::CONTINUE::

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
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = v1 - (FrameTime() + (SO * 0.04)) 
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

        if v2 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - (FrameTime() + (SO * 0.04)) end
        if v3 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = v3 - (FrameTime() + (SO * 0.04)) end

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

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - (FrameTime() + (SO * 0.04))  
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

        if v3 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = v3 - (FrameTime() + (SO * 0.04))  end
        if v4 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = v4 - (0.02 + (SO * 0.08))  end

        if v5 < 160 and slasher:GetNWBool("InSlasherChaseMode") then 
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 = v5 + (FrameTime() + (SO * 0.02)) + (v1*FrameTime()*0.5)
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

                    SlashCo.CurRound.SlasherData[slasherid].Eyesight = SlashCo.SlasherData[2].Eyesight + (2 + (SO * 2))
                    SlashCo.CurRound.SlasherData[slasherid].Perception = SlashCo.SlasherData[2].Perception + (1.5 + (SO * 1))

                else

                    SlashCo.CurRound.SlasherData[slasherid].Eyesight = SlashCo.SlasherData[2].Eyesight + (5 + (SO * 2))
                    SlashCo.CurRound.SlasherData[slasherid].Perception = SlashCo.SlasherData[2].Perception + (1 + (SO * 3))

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

            PlayGlobalSound("slashco/slasher/sid_THE_LETTER_C.wav",95,slasher, 0.5)

        end
    end
        ::TROLLGE::
        --Trollge's Abilities
        if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 3 then goto AMOGUS end
    do
        v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --Stage
        v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Claw cooldown
        v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --blood

        if v2 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - FrameTime() end
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
                --SlashCo.CurRound.SlasherData[slasherid].Eyesight = 4

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

        if v1 == 1 then

            SlashCo.CurRound.SlasherData[slasherid].Eyesight = 10 - (   slasher:GetVelocity():Length() / 35 )
            SlashCo.CurRound.SlasherData[slasherid].Perception = 5 - (   slasher:GetVelocity():Length() / 60 )

        end

    end

    ::AMOGUS::

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 4 then goto THIRSTY end
    --Amogus' Abilities
do
    v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --Transformation type
    v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Transform cooldown
    v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --Fuel Can EntIndex

    if IsValid(ents.GetByIndex(SlashCo.CurRound.SlasherData[slasherid].SlasherValue3)) then
        ents.GetByIndex(SlashCo.CurRound.SlasherData[slasherid].SlasherValue3):SetAngles(Angle(0,slasher:EyeAngles()[2],0))
    end

    if v2 > 0 then 
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - FrameTime() 
        SlashCo.CurRound.SlasherData[slasherid].CanKill = false
        --SlashCo.CurRound.SlasherData[slasherid].CanChase = false
    else
        if not slasher:GetNWBool("AmogusDisguised") and not slasher:GetNWBool("AmogusDisguising") then
            SlashCo.CurRound.SlasherData[slasherid].CanKill = true
            SlashCo.CurRound.SlasherData[slasherid].CanChase = true
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 0
        else
            SlashCo.CurRound.SlasherData[slasherid].CanKill = false
            SlashCo.CurRound.SlasherData[slasherid].CanChase = false
        end
    end   
    
    
end
    ::THIRSTY::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 5 then goto MALE07 end
    --Thirsty's Abilities
do
    v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --Milk drank
    v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Pacification
    v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --Thirst

    if v2 > 0 then --Thirsty is pacified

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 0

        SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed = 100
        SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed = 100
        SlashCo.CurRound.SlasherData[slasherid].Eyesight = 0
        SlashCo.CurRound.SlasherData[slasherid].Perception = 0

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - (0.01 + (SO * 0.04))  
        SlashCo.CurRound.SlasherData[slasherid].CanKill = false 
        SlashCo.CurRound.SlasherData[slasherid].CanChase = false 
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 0
        slasher:SetNWBool("DemonPacified", true)

    else --Thirsty is not pacified

        if v3 < 100 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = v3 + (FrameTime()/(2 - (SO/2))) end
        --Deplete thirst

        SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed = 285 - ( v1 * 10)
        SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed = 100 + ( (    ( v3 / (7 - v1)   )   ) + ( v1 * 20 )   )*(0.8+(SO*0.5))
        SlashCo.CurRound.SlasherData[slasherid].Eyesight = 2 + (    ( v3 / (28.5 - (v1*4))   )   )  
        SlashCo.CurRound.SlasherData[slasherid].Perception = 1.0 + (    ( v3 / (44.5 - (v1*8))   )   )  
        --Thirsty's basic stats raise the thirstier he is, and are also multiplied by how much milk he has drunk.
        --His chase speed is greatest at low milk drank, and the more he drinks, it is converted to prowl speed.

        SlashCo.CurRound.SlasherData[slasherid].CanKill = true 
        SlashCo.CurRound.SlasherData[slasherid].CanChase = true 
        slasher:SetNWBool("DemonPacified", false)

        if slasher:GetNWBool("InSlasherChaseMode") then 

            slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed )
            slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed )
        else

            slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )

        end

    end

end
    ::MALE07::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 6 then goto TYLER end
    --Male_07's Abilities
do
    v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --State
    v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Time Spent Human Chasing
    v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --Cooldown
    v4 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 --Slash Cooldown

    if v3 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = v3 - FrameTime() end
    if v4 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = v4 - FrameTime() end

    if v1 == 0 then --Specter mode

        SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed = 300
        SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed = 300
        SlashCo.CurRound.SlasherData[slasherid].Perception = 0.0
        SlashCo.CurRound.SlasherData[slasherid].Eyesight = 10

        SlashCo.CurRound.SlasherData[slasherid].CanKill = false 
        SlashCo.CurRound.SlasherData[slasherid].CanChase = false

    elseif v1 == 1 then --Human mode

        SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed = 100
        SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed = 302
        SlashCo.CurRound.SlasherData[slasherid].Perception = 1.0
        SlashCo.CurRound.SlasherData[slasherid].Eyesight = 2
        SlashCo.CurRound.SlasherData[slasherid].ChaseRange = 400

        SlashCo.CurRound.SlasherData[slasherid].CanKill = true 
        SlashCo.CurRound.SlasherData[slasherid].CanChase = true

        if SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick == 99 then SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 0 end

    elseif v1 == 2 then --Monster mode

        SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed = 150
        SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed = 285
        SlashCo.CurRound.SlasherData[slasherid].Perception = 1.5
        SlashCo.CurRound.SlasherData[slasherid].Eyesight = 5
        SlashCo.CurRound.SlasherData[slasherid].ChaseRange = 700

        SlashCo.CurRound.SlasherData[slasherid].CanKill = false 

    end

    if slasher:GetNWBool("InSlasherChaseMode") then 

        if v1 == 1 then

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 + FrameTime()

            --Timer - 10 seconds + Game Progress (1-10) ^ 3 (SO - x2)

            if v2 > 1 + (SlashCo.CurRound.SlasherData.GameProgress*1.5) +  (0.75 * math.pow( SlashCo.CurRound.SlasherData.GameProgress, 2 ) ) * (1 + SO) then 

                --Become Monster

                local modelname = "models/slashco/slashers/male_07/male_07_monster.mdl"
	            util.PrecacheModel( modelname )
	            slasher:SetModel( modelname )

                slasher:SetNWBool("Male07Transforming", true)
                slasher:SetNWBool("Male07Slashing", false)
                slasher:Freeze(true)

                local vPoint = slasher:GetPos() + Vector(0,0,50)
                local bloodfx = EffectData()
                bloodfx:SetOrigin( vPoint )
                util.Effect( "BloodImpact", bloodfx )

                slasher:EmitSound("vo/npc/male01/no02.wav") 

                slasher:EmitSound("NPC_Manhack.Slice") 
               
                timer.Simple(3, function() 

                    slasher:SetNWBool("Male07Transforming", false)
                    slasher:Freeze(false)

                    if slasher:GetNWBool("InSlasherChaseMode") then

                        slasher:SetRunSpeed(285)
                        slasher:SetWalkSpeed(285)

                    end

                end)

                SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 2

            end

        end

    end

end
    ::TYLER::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 7 then goto BORGMIRE end
    --Tyler's Abilities
do

    v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --State
    v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Time Spent as Creator or destroyer
    v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --Times Found
    v4 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 --Destruction power
    v5 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 --Destoyer Blink

    local ms = SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE

    SlashCo.CurRound.SlasherData[slasherid].CanChase = false

    if v1 == 0 then --Specter

        slasher.TylerSongPickedID = nil

        slasher:SetNWBool("TylerFlash", false)

        slasher:SetSlowWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed ) 
        slasher:SetRunSpeed(SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed)
        slasher:SetWalkSpeed(SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed)
        slasher:SetNWBool("TylerTheCreator", false)
        slasher:SetBodygroup( 0, 0 )
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0
        SlashCo.CurRound.SlasherData[slasherid].CanKill = false
        SlashCo.CurRound.SlasherData[slasherid].Perception = 6.0

    elseif v1 == 1 then --Creator

        slasher:SetNWBool("TylerFlash", false)

        slasher:SetSlowWalkSpeed( 1 ) 
        slasher:SetRunSpeed(1)
        slasher:SetWalkSpeed(1)
        slasher:Freeze(true)
        slasher:SetNWBool("TylerTheCreator", true)
        slasher:SetBodygroup( 0, 0 )
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 + FrameTime()
        SlashCo.CurRound.SlasherData[slasherid].CanKill = false
        SlashCo.CurRound.SlasherData[slasherid].Perception = 0.0

        if slasher.TylerSongPickedID == nil then
            slasher.TylerSongPickedID = math.random(1,6)
        end

        if CLIENT then
            if slasher.TylerSong == nil then 
                slasher.TylerSong = CreateSound( slasher, "slashco/slasher/tyler_song_"..slasher.TylerSongPickedID..".mp3")
            else
                slasher.TylerSong:SetSoundLevel( 85 - (math.sqrt(SlashCo.CurRound.SlasherData[slasherid].SlasherValue3*1.5) * (30 / SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE)) )
                slasher.TylerSong:Play() 
                slasher.TylerSong:ChangeVolume( 0.8 - (SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 * 0.05))
            end
        end


        if v2 > ( ms * 40) - (v4 * 4) then --Time ran out

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 2

        end

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do --Survivor found tyler

            local surv = team.GetPlayers(TEAM_SURVIVOR)[i]

            if surv:GetPos():Distance( slasher:GetPos() ) < 400 and surv:GetEyeTrace().Entity == slasher then

                slasher:SetNWBool("TylerCreating", true)
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0

            end

        end

        if slasher:GetNWBool("TylerCreating") and SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 != 1.8 then

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 = 1.8
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0

            timer.Simple(3, function() 
            
                SlashCo.CreateGasCan(slasher:GetPos() + (slasher:GetForward() * 60) + Vector(0,0,18), Angle(0,0,0))
            
            end)

            timer.Simple(4, function() 
            
                slasher:SetNWBool("TylerCreating", false)
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 0
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 + 1
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 = 0

                slasher:Freeze(false)

                slasher:SetColor(Color(0,0,0,0))
                slasher:DrawShadow(false)
		        slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		        slasher:SetNoDraw(true)
                if CLIENT then
                    slasher.TylerSong:Stop() 
                    slasher.TylerSong = nil
                end
            
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

            slasher:Freeze(false)

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 3

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
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0
        SlashCo.CurRound.SlasherData[slasherid].CanKill = false
        SlashCo.CurRound.SlasherData[slasherid].Perception = 0.0

    elseif v1 == 3 then --Destroyer

        slasher:SetSlowWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed ) 
        slasher:SetRunSpeed(SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed)
        slasher:SetWalkSpeed(SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed)
        slasher:SetNWBool("TylerTheCreator", false)
        slasher:SetBodygroup( 0, 1 )
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 + FrameTime()
        SlashCo.CurRound.SlasherData[slasherid].CanKill = true
        SlashCo.CurRound.SlasherData[slasherid].Perception = 2.0

        if v2 > ((ms * 15) + 60 + (v4 * 10)) then

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 0

            slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/tyler_destroyer_theme.wav") end)

            slasher:SetColor(Color(0,0,0,0))
            slasher:DrawShadow(false)
            slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
            slasher:SetNoDraw(true)
            slasher:SetNWBool("TylerFlash", false)

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 - 1

            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("DisplayTylerTheDestroyerEffects",false)
            end

        end

    end

    if v1 > 1 then

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 = v5 + FrameTime()

        if v5 > 0.85 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 = 0 end

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

end
    ::BORGMIRE::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 8 then goto FREESMILEY end
do

    v1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 --Time Spent chasing
    v2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 --Punch Cooldown
    --v3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 --Times Found
    --v4 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 --Destruction power
    --v5 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue5 --Destoyer Blink

    if v2 > 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = v2 - FrameTime() end

    if not slasher:GetNWBool("InSlasherChaseMode") then

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 0

        slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )

        slasher.ChaseSound = nil 

        if slasher.IdleSound == nil then

            PlayGlobalSound("slashco/slasher/borgmire_breath_base.wav", 60, slasher, 1)

            slasher:StopSound("slashco/slasher/borgmire_breath_chase.wav")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/borgmire_breath_chase.wav") end)

            slasher.IdleSound = true
        end

    else

        slasher.IdleSound = nil 

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = v1 + FrameTime()

        slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed - math.sqrt( v1 * 12 ) )
        slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ChaseSpeed - math.sqrt( v1 * 12 )  )

        if slasher.ChaseSound == nil then

            PlayGlobalSound("slashco/slasher/borgmire_breath_chase.wav", 70, slasher, 1)

            PlayGlobalSound("slashco/slasher/borgmire_anger.mp3", 75, slasher, 1)

            PlayGlobalSound("slashco/slasher/borgmire_anger_far.mp3", 102, slasher, 1)

            slasher:StopSound("slashco/slasher/borgmire_breath_base.wav")
            timer.Simple(0.1, function() slasher:StopSound("slashco/slasher/borgmire_breath_base.wav") end)

            slasher.ChaseSound = true
        end

    end

end
    ::FREESMILEY::

end

end)

SlashCo.ThirstyRage = function(ply)

    local pos = ply:GetPos()

    for i = 1, #team.GetPlayers(TEAM_SLASHER) do

        local slasherid = team.GetPlayers(TEAM_SLASHER)[i]:SteamID64()
        local slasher = team.GetPlayers(TEAM_SLASHER)[i]

        if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 5 then return end

        if slasher:GetPos():Distance( pos ) > 1600 then return end

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 6
        slasher:SetNWBool("ThirstyBigMlik", true)

        for i = 1, #player.GetAll() do
            local ply = player.GetAll()[i]
            ply:SetNWBool("ThirstyFuck",true)
        end

        timer.Simple(3, function() 
        
            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("ThirstyFuck",false)
            end
        
        end)

    end

end

SlashCo.SidRage = function(ply)

    local pos = ply:GetPos()

    for i = 1, #team.GetPlayers(TEAM_SLASHER) do

        local slasherid = team.GetPlayers(TEAM_SLASHER)[i]:SteamID64()
        local slasher = team.GetPlayers(TEAM_SLASHER)[i]

        if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 2 then return end

        if slasher:GetPos():Distance( pos ) > 1800 then return end

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 + 2

        PlayGlobalSound("slashco/slasher/sid_angry_"..math.random(1,4)..".mp3", 95, slasher, 1)

        for i = 1, #player.GetAll() do
            local ply = player.GetAll()[i]
            ply:SetNWBool("SidFuck",true)
        end

        timer.Simple(3, function() 
        
            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("SidFuck",false)
            end

            PlayGlobalSound("slashco/slasher/sid_sad_1.mp3", 85, slasher, 1)
        
        end)

    end

end