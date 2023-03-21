SlashCoSlasher.Sid = {}

SlashCoSlasher.Sid.Name = "Sid"
SlashCoSlasher.Sid.ID = 2
SlashCoSlasher.Sid.Class = 2
SlashCoSlasher.Sid.DangerLevel = 2
SlashCoSlasher.Sid.IsSelectable = true
SlashCoSlasher.Sid.Model = "models/slashco/slashers/sid/sid.mdl"
SlashCoSlasher.Sid.GasCanMod = 0
SlashCoSlasher.Sid.KillDelay = 7
SlashCoSlasher.Sid.ProwlSpeed = 150
SlashCoSlasher.Sid.ChaseSpeed = 275
SlashCoSlasher.Sid.Perception = 1.0
SlashCoSlasher.Sid.Eyesight = 3
SlashCoSlasher.Sid.KillDistance = 120
SlashCoSlasher.Sid.ChaseRange = 1500
SlashCoSlasher.Sid.ChaseRadius = 0.96
SlashCoSlasher.Sid.ChaseDuration = 6.0
SlashCoSlasher.Sid.ChaseCooldown = 3
SlashCoSlasher.Sid.JumpscareDuration = 1
SlashCoSlasher.Sid.ChaseMusic = "slashco/slasher/sid_chase.wav"
SlashCoSlasher.Sid.KillSound = "slashco/slasher/sid_kill.mp3"
SlashCoSlasher.Sid.Description = "The Psychotic Slasher which keeps his rage in check with Cookies.\n\n-Sid gains speed while chasing over time, but starts out slow.\n-Cookies will pacify him for a while.\n-Sid's special ability allows him to devastate Survivors at long range."
SlashCoSlasher.Sid.ProTip = "-Loud gunshots have been heard in zones where this Slasher was present."
SlashCoSlasher.Sid.SpeedRating = "★★☆☆☆"
SlashCoSlasher.Sid.EyeRating = "★★★☆☆"
SlashCoSlasher.Sid.DiffRating = "★★★★☆"

SlashCoSlasher.Sid.OnSpawn = function(slasher)

end

SlashCoSlasher.Sid.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Sid.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    local v1 = slasher.SlasherValue1 --Cookies Eaten
    local v2 = slasher.SlasherValue2 --Pacification
    local v3 = slasher.SlasherValue3 --Gun use cooldown
    local v4 = slasher.SlasherValue4 --bullet spread
    local v5 = slasher.SlasherValue5 --chase speed increase

    local final_eyesight = SlashCoSlasher.Sid.Eyesight
    local final_perception = SlashCoSlasher.Sid.Perception

        if v2 > 0 then 

            slasher.SlasherValue2 = v2 - (FrameTime() + (SO * 0.04))  
            slasher:SetNWBool("CanKill", false)
            slasher:SetNWBool("CanChase", false)

        elseif slasher:GetNWBool("SidGun") then

            slasher:SetNWBool("CanKill", false)
            slasher:SetNWBool("CanChase", false)
            slasher:SetNWBool("DemonPacified", false)

        else

            slasher:SetNWBool("CanKill", true)
            slasher:SetNWBool("CanChase", true)
            slasher:SetNWBool("DemonPacified", false)

        end

        if v3 > 0 then slasher.SlasherValue3 = v3 - (FrameTime() + (SO * 0.04))  end
        if v4 > 0 then slasher.SlasherValue4 = v4 - (0.02 + (SO * 0.08))  end

        if v5 < 160 and slasher:GetNWBool("InSlasherChaseMode") then 
            slasher.SlasherValue5 = v5 + (FrameTime() + (SO * 0.02)) + (v1*FrameTime()*0.5)
            slasher:SetRunSpeed(SlashCoSlasher.Sid.ChaseSpeed + (v5/3.5))
            slasher:SetWalkSpeed(SlashCoSlasher.Sid.ChaseSpeed + (v5/3.5))
        else
            slasher.SlasherValue5 = 0
        end

        if not slasher:GetNWBool("DemonPacified") then

            if not slasher:GetNWBool("SidGun") then

                final_eyesight = SlashCoSlasher.Sid.Eyesight
                final_perception =  SlashCoSlasher.Sid.Perception

            else

                if not slasher:GetNWBool("SidGunRage") then

                    final_eyesight = SlashCoSlasher.Sid.Eyesight + (2 + (SO * 2))
                    final_perception  = SlashCoSlasher.Sid.Perception + (1.5 + (SO * 1))

                else

                    final_eyesight =  SlashCoSlasher.Sid.Eyesight + (5 + (SO * 2))
                    final_perception = SlashCoSlasher.Sid.Perception + (1 + (SO * 3))

                end

            end

         else

            final_eyesight = 0
            final_perception = 0

        end



        if SlashCo.CurRound.GameProgress > 9 and not slasher:GetNWBool("SidGunRage") then 
            slasher:SetNWBool("SidGunRage", true) 

            if slasher:GetNWBool("SidGunEquipped") then 

                if not slasher:GetNWBool("SidGunAimed") and not slasher:GetNWBool("SidGunAiming") then
                    slasher:SetRunSpeed( SlashCoSlasher.Sid.ChaseSpeed )
                end

            end
        end

        if slasher:GetNWBool("SidGunRage") and not slasher:GetNWBool("SidGunLetterC") and slasher:GetNWBool("SidGunEquipped") then

            slasher:SetNWBool("SidGunLetterC", true)

            PlayGlobalSound("slashco/slasher/sid_THE_LETTER_C.wav",95,slasher, 0.5)

        end

    if slasher:GetNWInt("SidGunUses") ~= v1 then
        slasher:SetNWInt("SidGunUses", v1)
    end

    slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
    slasher:SetNWInt("Slasher_Perception", final_perception)

end

SlashCoSlasher.Sid.OnPrimaryFire = function(slasher)

    if not slasher:GetNWBool("SidGun") then 
        SlashCo.Jumpscare(slasher)
        return 
    end

    local spread = slasher.SlasherValue4

    if slasher:GetNWBool("SidGunAimed") and spread < 2.4 then

        slasher:SetNWBool("SidGunShoot",false)
        timer.Remove("SidGunDecay")

        timer.Simple(0.05, function()       
            slasher:SetNWBool("SidGunShoot",true)

            PlayGlobalSound("slashco/slasher/sid_shot_farthest.mp3", 150, slasher)
            PlayGlobalSound("slashco/slasher/sid_shot.mp3", 85, slasher)
            PlayGlobalSound("slashco/slasher/sid_shot_legacy.mp3", 78, slasher)

            slasher:FireBullets( 
                {
                    
                    Damage = 100, 
                    TracerName = "AirboatGunHeavyTracer", 
                    Dir = slasher:GetAimVector(), 
                    Src = slasher:GetPos() + Vector(0,0,60), 
                    IgnoreEntity = slasher, 
                    Spread = Vector(math.Rand(-1-(spread*25),1+(spread*25))*0.001,math.Rand(-1-(spread*25),1+(spread*25))*0.001,0)

                }, false )

            local vec, ang = slasher:GetBonePosition(slasher:LookupBone( "HandL" ))
            local vPoint = vec
            local muzzle = EffectData()
            muzzle:SetOrigin( vPoint + slasher:GetForward()*8 + Vector(0,0,2) )
            muzzle:SetStart( Vector(255,0,0) )
            muzzle:SetAttachment( 0 )
            util.Effect( "sid_muzzle", muzzle )

            local shell = EffectData()
            shell:SetOrigin( vPoint )
            shell:SetAngles( ang ) 
            util.Effect( "ShellEject", shell )

            slasher.SlasherValue4 = 3

            timer.Create( "SidGunDecay", 1.5, 1, function() slasher:SetNWBool("SidGunShoot",false) end)
        end)

    else

        --Executing a Survivor

        if slasher:GetEyeTrace().Entity:IsPlayer() then
            local target = slasher:GetEyeTrace().Entity	
    
            if target:Team() ~= TEAM_SURVIVOR then return end
    
            if slasher:GetPos():Distance(target:GetPos()) < dist*1.4 and not target:GetNWBool("SurvivorBeingJumpscared") then

                local pick_ang = SlashCo.RadialTester(slasher, 600, target)

                slasher:SetEyeAngles( Angle(0,pick_ang,0) )
                target:SetEyeAngles(  Angle(0,pick_ang,0)  ) 
                slasher:Freeze(true)

                timer.Simple(0.1, function() 

                    target:SetPos(slasher:GetPos())

                    target:Freeze(true)
    
                    target:SetNWBool("SurvivorBeingJumpscared",true)
                    slasher:SetNWBool("CanChase", false)

                    PlayGlobalSound("slashco/slasher/sid_angry_"..math.random(1,4)..".mp3", 85, slasher, 1)

                    slasher:SetNWBool("SidExecuting",true)

                    target:SetNWBool("SurvivorDecapitate",true)

                    target:SetNWBool("SurvivorSidExecution", true)

                    target:SetPos(slasher:GetPos())
                    target:SetEyeAngles(   Angle(0,pick_ang,0)   )  
    
                    SlashCoSlasher[slasher:GetNWBool("Slasher")].KillDelayTick = SlashCoSlasher[slasher:GetNWBool("Slasher")].KillDelay

                    timer.Simple(1, function() 
                        target:EmitSound("ambient/voices/citizen_beaten4.wav") 
                    end)

                    timer.Simple(3, function()               
                        target:EmitSound("ambient/voices/citizen_beaten3.wav")             
                    end)

                    timer.Simple(3.95, function() 
                        target:SetEyeAngles(   Angle(0,180+pick_ang,0)   )        
                    end)
    
                    timer.Simple(4.1, function()
    
                        target:SetNWBool("SurvivorBeingJumpscared",false)

                        PlayGlobalSound("slashco/slasher/sid_shot_farthest.mp3", 150, slasher)

                        slasher:EmitSound("slashco/slasher/sid_shot.mp3", 95)

                        slasher:EmitSound("slashco/slasher/sid_shot_2.mp3", 85)

                        local vec, ang = slasher:GetBonePosition(slasher:LookupBone( "HandL" ))
                        local vPoint = vec
                        local muzzle = EffectData()
                        muzzle:SetOrigin( vPoint + slasher:GetForward()*8 + Vector(0,0,2) )
                        muzzle:SetStart( Vector(255,0,0) )
                        muzzle:SetAttachment( 0 )
                        util.Effect( "sid_muzzle", muzzle )

                        local shell = EffectData()
                        shell:SetOrigin( vPoint )
                        shell:SetAngles( ang ) 
                        util.Effect( "ShellEject", shell )

                        target:SetNWBool("SurvivorSidExecution", false)

                        target:SetPos(slasher:GetPos() + (slasher:GetForward() * 40))

                        target:Freeze(false)
                        target:SetVelocity( slasher:GetForward() * 300 )
                        target:SetNotSolid(false)
                        timer.Simple(0.05, function() target:Kill() end)
            
                    end)

                    timer.Simple(8, function()
                        slasher:Freeze(false)
                        slasher:SetNWBool("SidExecuting",false)
                        target:SetNWBool("SurvivorDecapitate",false)
                    end)

                end)

            end
    
        end

    end

end

SlashCoSlasher.Sid.OnSecondaryFire = function(slasher)

    if not slasher:GetNWBool("SidGunEquipped") then 
        SlashCo.StartChaseMode(slasher)
        return 
    end

    local gunrage = slasher:GetNWBool("SidGunRage")

    if not slasher:GetNWBool("SidGunAimed") and not slasher:GetNWBool("SidGunAiming") and slasher.SlasherValue3 < 0.01 then

        slasher:SetNWBool("SidGunAiming", true)
        slasher.SlasherValue3 = 2
        slasher:SetSlowWalkSpeed( 1 )  
        slasher:SetWalkSpeed( 1 )
        slasher:SetRunSpeed( 1 )
        slasher:EmitSound("slashco/slasher/sid_draw.wav",75,110)

        timer.Simple(1, function() 

            slasher:SetNWBool("SidGunAiming", false)       
            slasher:SetNWBool("SidGunAimed", true)
            slasher:EmitSound("slashco/slasher/sid_clipout.wav")
            slasher.SlasherValue4 = 2

        end)

    elseif slasher:GetNWBool("SidGunAimed") and slasher.SlasherValue3 < 0.01 then

        slasher.SlasherValue3 = 2
        slasher:SetNWBool("SidGunAiming", false)   
        slasher:SetNWBool("SidGunAimed", false) 
        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )  
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )

        if not gunrage then 
            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed ) 
        else
            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed ) 
        end

    end

end

SlashCoSlasher.Sid.OnMainAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO

    if slasher:GetEyeTrace().Entity:GetClass() == "sc_cookie" then

        target = slasher:GetEyeTrace().Entity	

        if slasher:GetPos():Distance(target:GetPos()) < 150 and not slasher:GetNWBool("SidEating") and not slasher:GetNWBool("SidGun")  then

            slasher:SetNWBool("SidEating", true)
            slasher.SlasherValue2 = 99
            slasher:EmitSound("slashco/slasher/sid_cookie"..math.random(1,2)..".mp3")

            target:SetNWBool("BeingEaten", true)

            timer.Simple(1.3, function() 
                slasher:EmitSound("slashco/slasher/sid_eating.mp3")
            end)

            slasher:Freeze(true)

            timer.Simple(10, function() 
                slasher:Freeze(false) 
                slasher:SetNWBool("SidEating", false) 
                slasher:SetNWBool("DemonPacified", true)
                slasher.SlasherValue1 = slasher.SlasherValue1 + 1 + SatO
                slasher.SlasherValue2 = math.random(15,25)
                target:Remove()
            end)
        end
    end

end


SlashCoSlasher.Sid.OnSpecialAbilityFire = function(slasher)

    if SlashCo.CurRound.GameProgress < 5 then return end

    local SO = SlashCo.CurRound.OfferingData.SO

    if not slasher:GetNWBool("SidGun") and slasher.SlasherValue3 < 0.01 and slasher.SlasherValue1 > 0 then --Equip the gun
        slasher:SetNWBool("SidGun", true)
        slasher:SetNWBool("SidGunEquipping", true)
        slasher:Freeze(true)
        slasher.SlasherValue3 = 4 - (SO * 2)
        slasher.SlasherValue2 = 4 - (SO * 2)

        slasher.SlasherValue1 = slasher.SlasherValue1 - 1 --Deplete the uses

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

            slasher.SlasherValue3 = 2

            if slasher:GetNWBool("SidGunRage") then

                slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseSpeed )

            end

        end)

    elseif slasher:GetNWBool("SidGun") and slasher.SlasherValue3 < 0.01 and not slasher:GetNWBool("SidGunAiming") and not slasher:GetNWBool("SidGunAimed") then
        slasher:SetNWBool("SidGunEquipped", false)
        slasher:SetNWBool("SidGun", false)
        slasher:SetBodygroup( 1, 0 )
        slasher:SetNWBool("SidGunLetterC", false)
        slasher:StopSound("slashco/slasher/sid_THE_LETTER_C.wav")
        slasher.SlasherValue2 = math.random(5,15)
    end

end

SlashCoSlasher.Sid.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")
	local pac = ply:GetNWBool("DemonPacified")

	local eating = ply:GetNWBool("SidEating")
	local equipping_gun = ply:GetNWBool("SidGunEquipping")
	local sid_executing = ply:GetNWBool("SidExecuting")

	local gun_state = ply:GetNWBool("SidGunEquipped")
	local aiming_gun = ply:GetNWBool("SidGunAiming")
	local aimed_gun = ply:GetNWBool("SidGunAimed")
	local gun_shooting = ply:GetNWBool("SidGunShoot")
	local gun_rage = ply:GetNWBool("SidGunRage")

    if gun_state then gun_prefix = "g_" else gun_prefix = "" end

    if not eating and not equipping_gun and not aiming_gun and not gun_shooting and not sid_executing then anim_antispam = false end

	if not equipping_gun then

		if not aiming_gun and not aimed_gun then

			if not eating then

				if ply:IsOnGround() then

					if ply:GetVelocity():Length() < 200 then 
						ply.CalcIdeal = ACT_HL2MP_WALK 
						ply.CalcSeqOverride = ply:LookupSequence(gun_prefix.."prowl")
					else
						ply.CalcIdeal = ACT_HL2MP_RUN 
						ply.CalcSeqOverride = ply:LookupSequence(gun_prefix.."chase")
					end

				else

					ply.CalcSeqOverride = ply:LookupSequence(gun_prefix.."float")

				end
			else

				ply.CalcSeqOverride = ply:LookupSequence("eat")
				if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

			end

		end

	else
		ply.CalcSeqOverride = ply:LookupSequence("arm")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end
	end

	if aiming_gun then

		ply.CalcSeqOverride = ply:LookupSequence("readygun")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

	if aimed_gun then

		if not gun_shooting then

			ply.CalcSeqOverride = ply:LookupSequence("readyidle")

		else

			ply.CalcSeqOverride = ply:LookupSequence("shoot")
			if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

		end

	end

	if sid_executing then

		ply.CalcSeqOverride = ply:LookupSequence("execution")
		ply:SetPlaybackRate( 1 )
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Sid.Footstep = function(ply)

    if SERVER then
        ply:EmitSound( "slashco/slasher/sid_step"..math.random(1,2)..".mp3") 
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    SlashCoSlasher.Sid.PlayerJumpscare = function()

        if f == nil then f = 0 end
        if f < 39 then f = f+(FrameTime()*30) end

        local Overlay = Material("slashco/ui/overlays/jumpscare_2")
        Overlay:SetInt( "$frame", math.floor(f) )

        surface.SetDrawColor(255,255,255,255)	
        surface.SetMaterial(Overlay)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

    end

    local SidGunInactive = Material("slashco/ui/icons/slasher/s_2_a1_disabled")
    local SidGunUnavailable = Material("slashco/ui/icons/slasher/s_2_a1_unavailable")
    local SidGun = Material("slashco/ui/icons/slasher/s_2_a1")

    local SidGunShoot = Material("slashco/ui/icons/slasher/s_2_a2")
    local SidGunAim = Material("slashco/ui/icons/slasher/s_2_a3")

    SlashCoSlasher.Sid.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

		local sid_has_gun = LocalPlayer():GetNWBool("SidGun")
		local sid_equipped_gun = LocalPlayer():GetNWBool("SidGunEquipped")
		local is_aiming_gun =  LocalPlayer():GetNWBool("SidGunAimed")

        local gun_uses =  LocalPlayer():GetNWInt("SidGunUses")

		if GameProgress < 5 then
			surface.SetMaterial(SidGunInactive)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		elseif not sid_has_gun then
			surface.SetMaterial(SidGunUnavailable)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			draw.SimpleText( "F - Equip Gun", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

			draw.SimpleText( "Uses: "..gun_uses, "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.5), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			surface.SetMaterial(SidGun)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			if not is_aiming_gun then 
				draw.SimpleText( "F - Unequip Gun", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
			else
				draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
			end
		end

		willdrawkill = not sid_equipped_gun
		willdrawchase = not sid_equipped_gun

		if sid_equipped_gun then
			--icons for shooting/aiming

			if not is_aiming_gun then
				surface.SetMaterial(SidGunShoot)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M2 - Aim", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

				surface.SetMaterial(SidGunAim)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
				draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
			else
				surface.SetMaterial(SidGunShoot)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M2 - Lower Gun", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

				surface.SetMaterial(SidGunAim)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M1 - Shoot", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
			end

		end

		if not sid_has_gun then
			draw.SimpleText( "R - Eat Cookie", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Sid.ClientSideEffect = function()

    end

end