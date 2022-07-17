local SlashCo = SlashCo

SlashCo.SlasherPrimaryFire = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID == 3 and SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 < 1 then goto trollclaw end
    if slasher:GetNWBool("SidGun") then goto sidgun end
do

    if SlashCo.CurRound.SlasherData[slasherid].CanKill == false then return end

    if SlashCo.CurRound.SlasherData[slasherid].KillDelayTick > 0 then return end

    local dist = SlashCo.CurRound.SlasherData[slasherid].KillDistance
    
    if slasher:GetEyeTrace().Entity:IsPlayer() then
        local target = slasher:GetEyeTrace().Entity	

        if target:Team() != TEAM_SURVIVOR then return end

        if slasher:GetPos():Distance(target:GetPos()) < dist and not target:GetNWBool("SurvivorBeingJumpscared") then

            target:SetNWBool("SurvivorBeingJumpscared",true)
            target:SetNWBool("SurvivorJumpscare_"..SlashCo.CurRound.SlasherData[slasherid].SlasherID, true)

            SlashCo.CurRound.SlasherData[slasherid].CanChase = false
            SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 99

            slasher:EmitSound(SlashCo.CurRound.SlasherData[slasherid].KillSound)
                
            target:Freeze(true)
            slasher:Freeze(true)

            SlashCo.CurRound.SlasherData[slasherid].KillDelayTick = SlashCo.CurRound.SlasherData[slasherid].KillDelay

            timer.Simple(SlashCo.CurRound.SlasherData[slasherid].JumpscareDuration, function()

                target:SetNWBool("SurvivorBeingJumpscared",false)
                target:SetNWBool("SurvivorJumpscare_"..SlashCo.CurRound.SlasherData[slasherid].SlasherID, false)
                target:EmitSound("slashco/survivor/effectexpire_breath.mp3")

                slasher:Freeze(false)
                target:Freeze(false)
                target:Kill()
        
            end)
        end

    end

end

    ::sidgun::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 2  then return end
do

    local spread = SlashCo.CurRound.SlasherData[slasherid].SlasherValue4

    if slasher:GetNWBool("SidGunAimed") and spread < 1.8 then

        slasher:SetNWBool("SidGunShoot",false)
        timer.Remove("SidGunDecay")

        timer.Simple(0.05, function()       
            slasher:SetNWBool("SidGunShoot",true)

            PlayGlobalSound("slashco/slasher/sid_shot_farthest.mp3", 150, slasher)

            slasher:EmitSound("slashco/slasher/sid_shot.mp3",95,100,1,6)

            slasher:FireBullets( 
                {
                    
                    Damage = 100, 
                    TracerName = "AirboatGunHeavyTracer", 
                    Dir = slasher:GetAimVector(), 
                    Src = slasher:GetPos() + Vector(0,0,60), 
                    IgnoreEntity = slasher, 
                    Spread = Vector(math.random(-5-(spread*25),5+(spread*25))*0.001,math.random(-5-(spread*25),5+(spread*25))*0.001,0)

                }, false )

            local vec, ang = slasher:GetBonePosition(slasher:LookupBone( "HandL" ))
            local vPoint = vec
            local muzzle = EffectData()
            muzzle:SetOrigin( vPoint )
            muzzle:SetAttachment( 1 )
            util.Effect( "GunshipMuzzleFlash", muzzle )

            local shell = EffectData()
            shell:SetOrigin( vPoint )
            shell:SetAngles( ang ) 
            util.Effect( "ShellEject", shell )

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue4 = 2

            timer.Create( "SidGunDecay", 1.5, 1, function() slasher:SetNWBool("SidGunShoot",false) end)
        end)

    end

end

    ::trollclaw::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID != 3 then return end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 != 0 then return end
do
    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 < 0.01 and not slasher:GetNWBool("TrollgeTransition") then

        slasher:SetNWBool("TrollgeSlashing",false)
        timer.Remove("TrollgeSlashDecay")

        timer.Simple(0.2, function() 
            slasher:EmitSound("slashco/slasher/trollge_swing.wav")
        end)

        timer.Simple(0.1, function() 

            slasher:SetNWBool("TrollgeSlashing",true)

            timer.Create( "TrollgeSlashDecay", 0.6, 1, function() slasher:SetNWBool("TrollgeSlashing",false) end)

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 + 0.5

            if SERVER then

                local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,0)), Vector(-30,-30,-60), Vector(30,30,60), 10, DMG_SLASH, 50, false )

                if target:IsPlayer() then

                    if target:Team() != TEAM_SURVIVOR then return end

                    if slasher:GetPos():Distance(target:GetPos()) < 200 then

                        local vPoint = target:GetPos() + Vector(0,0,50)
                        local bloodfx = EffectData()
                        bloodfx:SetOrigin( vPoint )
                        util.Effect( "BloodImpact", bloodfx )

                        slasher:EmitSound("slashco/slasher/trollge_hit.wav")

                        target:TakeDamage( (10 + (SO * 10)), slasher, slasher )

                        SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 + 1 + SO

                    end

                end

            end

        end)

    end

end

end