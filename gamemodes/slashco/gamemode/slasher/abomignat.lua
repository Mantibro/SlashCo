SlashCoSlasher.Abomignat = {}

SlashCoSlasher.Abomignat.Name = "Abomignat"
SlashCoSlasher.Abomignat.ID = 11
SlashCoSlasher.Abomignat.Class = 1
SlashCoSlasher.Abomignat.DangerLevel = 1
SlashCoSlasher.Abomignat.IsSelectable = true
SlashCoSlasher.Abomignat.Model = "models/slashco/slashers/abomignat/abomignat.mdl"
SlashCoSlasher.Abomignat.GasCanMod = 0
SlashCoSlasher.Abomignat.KillDelay = 5
SlashCoSlasher.Abomignat.ProwlSpeed = 150
SlashCoSlasher.Abomignat.ChaseSpeed = 293
SlashCoSlasher.Abomignat.Perception = 0.5
SlashCoSlasher.Abomignat.Eyesight = 6
SlashCoSlasher.Abomignat.KillDistance = 150
SlashCoSlasher.Abomignat.ChaseRange = 1400
SlashCoSlasher.Abomignat.ChaseRadius = 0.82
SlashCoSlasher.Abomignat.ChaseDuration = 5.0
SlashCoSlasher.Abomignat.ChaseCooldown = 5
SlashCoSlasher.Abomignat.JumpscareDuration = 2
SlashCoSlasher.Abomignat.ChaseMusic = "slashco/slasher/abomignat_chase.wav"
SlashCoSlasher.Abomignat.KillSound = ""
SlashCoSlasher.Abomignat.Description = "The Monstrous Slasher which uses basic abilities to achieve quick kills.\n\n-Abomignat can use its sharp claws to quickly damage Survivors.\n-It can perform a short-range high-speed lunge to finish off its victims.\n-Its Crawling Mode can enable swift map traversal."
SlashCoSlasher.Abomignat.ProTip = "-This Slasher enters bursts of speed while attacking."
SlashCoSlasher.Abomignat.SpeedRating = "★★★☆☆"
SlashCoSlasher.Abomignat.EyeRating = "★★★★☆"
SlashCoSlasher.Abomignat.DiffRating = "★☆☆☆☆"

SlashCoSlasher.Abomignat.OnSpawn = function(slasher)
    PlayGlobalSound("slashco/slasher/abomignat_breathing.wav",65,slasher)
end

SlashCoSlasher.Abomignat.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Abomignat.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    v1 = slasher.SlasherValue1 --Main Slash Cooldown
    v2 = slasher.SlasherValue2 --Forward charge
    v3 = slasher.SlasherValue3 --Lunge Finish Antispam
    v4 = slasher.SlasherValue4 --Lunge Duration

    local eyesight_final = SlashCoSlasher.Abomignat.Eyesight
    local perception_final = SlashCoSlasher.Abomignat.Perception

    if v1 > 0 then slasher.SlasherValue1 = v1 - FrameTime() end

    if slasher:IsOnGround() then slasher:SetVelocity(slasher:GetForward() * v2 * 8) end

    if slasher:GetNWBool("AbomignatLunging") then

        local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,30)), Vector(-15,-15,-60), Vector(15,15,60), 50, DMG_SLASH, 5, false )

        SlashCo.BustDoor(slasher, target, 25000)

        slasher.SlasherValue4 = v4 + 1

        if ( slasher:GetVelocity():Length() < 450 or target:IsValid() ) and v4 > 30 and slasher.SlasherValue3 == 0 then

            slasher:SetNWBool("AbomignatLungeFinish",true)
            timer.Simple(0.6, function() slasher:EmitSound("slashco/slasher/abomignat_scream"..math.random(1,3)..".mp3") end)

            slasher:SetNWBool("AbomignatLunging",false)
            slasher:SetCycle( 0 )

            slasher.SlasherValue2 = 0
            slasher.SlasherValue3 = 1

            timer.Simple(4, function() 
                if v3 == 1 then
                    slasher.SlasherValue3 = 2
                    slasher.SlasherValue4 = 0
                    slasher:SetNWBool("AbomignatLungeFinish",false)   
                    slasher:Freeze(false)  
                end       
            end)

        end


    end

    if slasher:GetNWBool("AbomignatCrawling") then 
    
        slasher:SetNWBool("CanChase", false)

        slasher:SetSlowWalkSpeed( 350 )
        slasher:SetWalkSpeed( 350 )
        slasher:SetRunSpeed( 350 )

        SlashCoSlasher.Abomignat.Eyesight = 0
        SlashCoSlasher.Abomignat.Perception = 0

        if slasher:GetVelocity():Length() < 3 then 
            slasher:SetNWBool("AbomignatCrawling",false) 
            slasher.ChaseActivationCooldown = SlashCoSlasher.Abomignat.ChaseCooldown 
        end

        if not slasher:IsOnGround() then 
            slasher:SetNWBool("AbomignatCrawling",false) 
            slasher.ChaseActivationCooldown = SlashCoSlasher.Abomignat.ChaseCooldown 
        end

        slasher:SetViewOffset( Vector(0,0,20) )
        slasher:SetCurrentViewOffset( Vector(0,0,20) )

    else

        slasher:SetNWBool("CanChase", true)

        eyesight_final = 6
        perception_final = 0.5

        slasher:SetViewOffset( Vector(0,0,70) )
        slasher:SetCurrentViewOffset( Vector(0,0,70) )

        if not slasher:GetNWBool("InSlasherChaseMode") then
            slasher:SetSlowWalkSpeed( SlashCoSlasher.Abomignat.ProwlSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher.Abomignat.ProwlSpeed )
            slasher:SetRunSpeed( SlashCoSlasher.Abomignat.ProwlSpeed )
        end

    end

    if v1 > 0 and slasher:GetNWBool("AbomignatCanMainSlash") then
        slasher:SetNWBool("AbomignatCanMainSlash", false)
    end

    if v1 <= 0 and not slasher:GetNWBool("AbomignatCanMainSlash") then
        slasher:SetNWBool("AbomignatCanMainSlash", true)
    end

    slasher:SetNWFloat("Slasher_Eyesight", eyesight_final)
    slasher:SetNWInt("Slasher_Perception", perception_final)
end

SlashCoSlasher.Abomignat.OnPrimaryFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher:GetNWBool("AbomignatCrawling") then return end
    --slasher:Freeze(true)
    slasher:SetNWBool("AbomignatSlashing",true)
    slasher.SlasherValue1 = 6  - (SO * 3)
    slasher.SlasherValue2 = 6

    slasher:EmitSound("slashco/slasher/abomignat_scream"..math.random(1,3)..".mp3")

    timer.Simple(1, function() 

        slasher:EmitSound("slashco/slasher/trollge_swing.wav")
        slasher:Freeze(true)
        slasher.SlasherValue2 = 0

        if SERVER then

            local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,0)), Vector(-30,-30,-60), Vector(30,30,60), 35, DMG_SLASH, 5, false )

            SlashCo.BustDoor(slasher, target, 20000)

            if target:IsPlayer() then

                if target:Team() ~= TEAM_SURVIVOR then return end

                local vPoint = target:GetPos() + Vector(0,0,50)
                local bloodfx = EffectData()
                bloodfx:SetOrigin( vPoint )
                util.Effect( "BloodImpact", bloodfx )

                target:EmitSound("slashco/slasher/trollge_hit.wav")

            end

        end

    end)

    timer.Simple(2.3, function() 

        slasher:SetNWBool("AbomignatSlashing",false)
        slasher:Freeze(false)

    end)

end

SlashCoSlasher.Abomignat.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Abomignat.OnMainAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher:GetNWBool("AbomignatCrawling") then 
        slasher:SetNWBool("AbomignatCrawling",false) 
        slasher.ChaseActivationCooldown = SlashCoSlasher.Abomignat.ChaseCooldown
        return 
    end

    if slasher:GetNWBool("InSlasherChaseMode") then return end
    if slasher:GetNWBool("AbomignatSlashing") then return end
    if slasher:GetNWBool("AbomignatLunging") then return end
    if slasher:GetNWBool("AbomignatLungeFinish") then return end
    if slasher.ChaseActivationCooldown > 0 then return end

    if not slasher:GetNWBool("AbomignatCrawling") then slasher:SetNWBool("AbomignatCrawling",true) end

end


SlashCoSlasher.Abomignat.OnSpecialAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher:GetNWBool("AbomignatCrawling") then return end

    if slasher.SlasherValue1 > 0 then return end
    slasher.SlasherValue1 = 10 - (SO * 4)
    slasher.SlasherValue2 = 8 + (SO*4)
    slasher.SlasherValue3 = 0

    slasher:Freeze(true)

    slasher:SetNWBool("AbomignatLunging", true)
    slasher:EmitSound("slashco/slasher/abomignat_lunge.mp3")

    timer.Simple(1.75, function()
        if slasher.SlasherValue3 == 0 then
            slasher:SetNWBool("AbomignatLungeFinish",true)
            timer.Simple(0.6, function() slasher:EmitSound("slashco/slasher/abomignat_scream"..math.random(1,3)..".mp3") end)

            slasher:SetNWBool("AbomignatLunging",false)
            slasher:SetCycle( 0 )

            slasher.SlasherValue2 = 0
            slasher.SlasherValue3 = 1
        end

        timer.Simple(4, function() 
            if slasher.SlasherValue3 == 1 then
                slasher.SlasherValue3 = 2
                slasher.SlasherValue4 = 0
                slasher:SetNWBool("AbomignatLungeFinish",false)     
                slasher:Freeze(false)
            end       
        end)

    end)

end

SlashCoSlasher.Abomignat.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")

    local abomignat_mainslash = ply:GetNWBool("AbomignatSlashing")
	local abomignat_lunge = ply:GetNWBool("AbomignatLunging")
	local abomignat_lungefinish = ply:GetNWBool("AbomignatLungeFinish")
	local abomignat_crawl = ply:GetNWBool("AbomignatCrawling")

    if not abomignat_mainslash and not abomignat_lunge and not abomignat_lungefinish then ply.anim_antispam = false end

	if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_HL2MP_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN 
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

		if abomignat_crawl then
			ply.CalcSeqOverride = ply:LookupSequence("crawl")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if abomignat_mainslash then

		ply.CalcSeqOverride = ply:LookupSequence("slash_charge")
		if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end

	end

	if abomignat_lunge then

		ply.CalcSeqOverride = ply:LookupSequence("lunge")
		if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end

	end

	if abomignat_lungefinish then

		ply.CalcSeqOverride = ply:LookupSequence("lunge_post")
		if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Abomignat.Footstep = function(ply)

    if SERVER then
        ply:EmitSound( "slashco/slasher/abomignat_step"..math.random(1,3)..".mp3")
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    local GenericSlashIcon = Material("slashco/ui/icons/slasher/s_slash")
    local KillDisabledIcon = Material("slashco/ui/icons/slasher/kill_disabled")

    SlashCoSlasher.Abomignat.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = false
        local willdrawchase = true
        local willdrawmain = true

        local is_crawling = LocalPlayer():GetNWBool("AbomignatCrawling")

        if not is_crawling and LocalPlayer():GetNWBool("AbomignatCanMainSlash") then
            surface.SetMaterial(GenericSlashIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
            draw.SimpleText( "M1 - Slash Charge", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

            surface.SetMaterial(GenericSlashIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
            draw.SimpleText( "F - Lunge", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        else
            surface.SetMaterial(KillDisabledIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
            draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

            surface.SetMaterial(KillDisabledIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
            draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        end

        if not is_crawling then 
            draw.SimpleText( "R - Start Crawling", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
        else
            draw.SimpleText( "R - Stop Crawling", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
        end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Abomignat.ClientSideEffect = function()

    end

end