SlashCoSlasher.Trollge = {}

SlashCoSlasher.Trollge.Name = "Trollge"
SlashCoSlasher.Trollge.ID = 3
SlashCoSlasher.Trollge.Class = 3
SlashCoSlasher.Trollge.DangerLevel = 3
SlashCoSlasher.Trollge.IsSelectable = true
SlashCoSlasher.Trollge.Model = "models/slashco/slashers/trollge/trollge.mdl"
SlashCoSlasher.Trollge.GasCanMod = 0
SlashCoSlasher.Trollge.KillDelay = 1.5
SlashCoSlasher.Trollge.ProwlSpeed = 150
SlashCoSlasher.Trollge.ChaseSpeed = 295
SlashCoSlasher.Trollge.Perception = 1.0
SlashCoSlasher.Trollge.Eyesight = 2
SlashCoSlasher.Trollge.KillDistance = 100
SlashCoSlasher.Trollge.ChaseRange = 0
SlashCoSlasher.Trollge.ChaseRadius = 0.0
SlashCoSlasher.Trollge.ChaseDuration = 0.0
SlashCoSlasher.Trollge.ChaseCooldown = 3
SlashCoSlasher.Trollge.JumpscareDuration = 2
SlashCoSlasher.Trollge.ChaseMusic = ""
SlashCoSlasher.Trollge.KillSound = "slashco/slasher/trollge_kill.wav"
SlashCoSlasher.Trollge.Description = "The Bloodthirsty Slasher whose power grows with the amount of\nblood he has collected.\n\n-Trollge cannot see Survivors who stand still.\n-He must collect enough blood to unlock his true form.\n-He can not collect blood after the round has progressed enough."
SlashCoSlasher.Trollge.ProTip = "-Its eyesight seems to be limited to moving objects."
SlashCoSlasher.Trollge.SpeedRating = "★★☆☆☆"
SlashCoSlasher.Trollge.EyeRating = "★★☆☆☆"
SlashCoSlasher.Trollge.DiffRating = "★★★★★"

SlashCoSlasher.Trollge.OnSpawn = function(slasher)
    PlayGlobalSound("slashco/slasher/trollge_breathing.wav",50,slasher)
end

SlashCoSlasher.Trollge.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Trollge.OnTickBehaviour = function(slasher)
    local v1 = slasher.SlasherValue1 --Stage
    local v2 = slasher.SlasherValue2 --Claw cooldown
    local v3 = slasher.SlasherValue3 --blood

    local final_eyesight = SlashCoSlasher.Trollge.Eyesight
    local final_perception = SlashCoSlasher.Trollge.Perception

    if v2 > 0 then slasher.SlasherValue2 = v2 - FrameTime() end
    if v2 > 2 then slasher.SlasherValue2 = 2 end
    if v2 < 0 then slasher.SlasherValue2 = 0 end

    if v1 == 0 then slasher:SetNWBool("TrollgeStage1", false) slasher:SetNWBool("TrollgeStage2", false) end
    if v1 == 1 then slasher:SetNWBool("TrollgeStage1", true) slasher:SetNWBool("TrollgeStage2", false) end
    if v1 == 2 then slasher:SetNWBool("TrollgeStage1", false) slasher:SetNWBool("TrollgeStage2", true) end

    if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage1") and SlashCo.CurRound.GameProgress > 4 and v1 < 1 then

        slasher:SetNWBool("TrollgeTransition", true)
        slasher:Freeze(true)
        slasher:StopSound("slashco/slasher/trollge_breathing.wav")
        PlayGlobalSound("slashco/slasher/trollge_transition.mp3",125,slasher)

        for p = 1, #player.GetAll() do
            local ply = player.GetAll()[p]
            ply:SetNWBool("DisplayTrollgeTransition",true)
        end

        timer.Simple(7, function() --transit 
            slasher:StopSound("slashco/slasher/trollge_breathing.wav")
            slasher.SlasherValue1 = 1
            slasher:SetNWBool("TrollgeTransition", false)
            slasher:Freeze(false)
            PlayGlobalSound("slashco/slasher/trollge_stage1.wav",60,slasher)

            slasher:SetRunSpeed( 280 )
            slasher:SetWalkSpeed( 150  )
            slasher:SetNWBool("CanKill", true)

            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("DisplayTrollgeTransition",false)
            end
        end)

    end

    if v3 > 8 then slasher.SlasherValue3 = 8 end

    if not slasher:GetNWBool("TrollgeTransition") and not slasher:GetNWBool("TrollgeStage2") and SlashCo.CurRound.GameProgress > (10 - (v3/2)) and v1 == 1 then

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
            slasher.SlasherValue1 = 2
            slasher:SetNWBool("TrollgeTransition", false)
            slasher:Freeze(false)
            PlayGlobalSound("slashco/slasher/trollge_stage6.wav",60,slasher)

            slasher:SetRunSpeed( 450 )
            slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseSpeed  )
            final_eyesight = 10

            for i = 1, #player.GetAll() do
                local ply = player.GetAll()[i]
                ply:SetNWBool("DisplayTrollgeTransition",false)
            end
        end)

    end

    if v1 == 1 then

        final_eyesight = 10 - (   slasher:GetVelocity():Length() / 35 )
        final_perception = 5 - (   slasher:GetVelocity():Length() / 60 )

    end

    if slasher:GetNWInt("TrollgeStage") ~= v1 then
        slasher:SetNWInt("TrollgeStage", v1)
    end

    slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
    slasher:SetNWInt("Slasher_Perception", final_perception)

end

SlashCoSlasher.Trollge.OnPrimaryFire = function(slasher)

    if slasher.SlasherValue1 ~= 0 then 
        SlashCo.Jumpscare(slasher)
        return 
    end
    
    local SO = SlashCo.CurRound.OfferingData.SO

        if slasher.SlasherValue2 < 0.01 and not slasher:GetNWBool("TrollgeTransition") then
    
            slasher:SetNWBool("TrollgeSlashing",false)
            timer.Remove("TrollgeSlashDecay")
    
            timer.Simple(0.3, function() 
    
                slasher:EmitSound("slashco/slasher/trollge_swing.wav")
    
                if SERVER then
    
                    local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,0)), Vector(-30,-30,-60), Vector(30,30,60), 10, DMG_SLASH, 5, false )
    
                    if target:IsPlayer() then
    
                        if target:Team() ~= TEAM_SURVIVOR then return end
    
                        local vPoint = target:GetPos() + Vector(0,0,50)
                        local bloodfx = EffectData()
                        bloodfx:SetOrigin( vPoint )
                        util.Effect( "BloodImpact", bloodfx )
    
                        target:EmitSound("slashco/slasher/trollge_hit.wav")
    
                        slasher.SlasherValue3 = slasher.SlasherValue3 + 1 + SO
    
                    end
    
                end
    
            end)
    
            timer.Simple(0.1, function() 
    
                slasher:SetNWBool("TrollgeSlashing",true)
    
                timer.Create( "TrollgeSlashDecay", 0.6, 1, function() slasher:SetNWBool("TrollgeSlashing",false) end)
    
                slasher.SlasherValue2 = slasher.SlasherValue2 + 0.5
    
            end)
    
        end

end

SlashCoSlasher.Trollge.OnSecondaryFire = function(slasher)
    --SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Trollge.OnMainAbilityFire = function(slasher)

end


SlashCoSlasher.Trollge.OnSpecialAbilityFire = function(slasher)

end



SlashCoSlasher.Trollge.Animator = function(ply) 

    local trollge_stage1 = ply:GetNWBool("TrollgeStage1")
	local trollge_stage2 = ply:GetNWBool("TrollgeStage2")
	local trollge_slashing = ply:GetNWBool("TrollgeSlashing")

    if not trollge_slashing then ply.anim_antispam = false end

	if not trollge_stage1 and not trollge_stage2 then

		if ply:IsOnGround() then
		
			if not trollge_slashing then

				ply.CalcIdeal = ACT_HL2MP_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("walk")

			else

				ply.CalcSeqOverride = ply:LookupSequence("walk")

				if ply.anim_antispam == nil or ply.anim_antispam == false then
					ply:AddVCDSequenceToGestureSlot( 1, 2, 0, true )
					ply.anim_antispam = true 
				end

			end

		else

			--ply.CalcSeqOverride = ply:LookupSequence("float")

		end

	elseif trollge_stage2 then

		ply.CalcSeqOverride = ply:LookupSequence("fly")

	else

		ply.CalcSeqOverride = ply:LookupSequence("glide")

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Trollge.Footstep = function(ply)

    if SERVER then
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Trollge.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Trollge") == true  then

            if LocalPlayer().troll_f == nil then LocalPlayer().troll_f = 0 end
            LocalPlayer().troll_f = LocalPlayer().troll_f+(FrameTime()*30)
            if LocalPlayer().troll_f > 86 then return end

            local Overlay = Material("slashco/ui/overlays/jumpscare_3")
            Overlay:SetInt( "$frame", math.floor(LocalPlayer().troll_f) )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        else
            LocalPlayer().troll_f = nil
        end

        if LocalPlayer():GetNWBool("DisplayTrollgeTransition") == true  then

            local Overlay = Material("slashco/ui/overlays/trollge_overlays")
            Overlay:SetInt( "$frame", 0 )
    
            surface.SetDrawColor(255,255,255,60)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

        end

    end)

    local TrollgeStage1 = Material("slashco/ui/icons/slasher/s_3_s1")
    local TrollgeStage2 = Material("slashco/ui/icons/slasher/s_3_s2")
    local TrollgeClaw = Material("slashco/ui/icons/slasher/s_3_a1")

    SlashCoSlasher.Trollge.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = false
        local willdrawmain = true

        local trollge_stage = LocalPlayer():GetNWInt("TrollgeStage")

        if trollge_stage == 0 then
            willdrawkill = false

            surface.SetMaterial(TrollgeClaw)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
            draw.SimpleText( "M1 - Claw", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        else
            willdrawkill = true
        end

        if trollge_stage == 1 then
            surface.SetMaterial(TrollgeStage1)
            surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
            willdrawmain = false
        elseif trollge_stage == 2 then
            surface.SetMaterial(TrollgeStage2)
            surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
            willdrawmain = false
        end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Trollge.ClientSideEffect = function()

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

            if not LocalPlayer():GetNWBool("TrollgeStage2") then

                local l_ang = math.abs(ply:EyeAngles()[1]) + math.abs(ply:EyeAngles()[2]) + math.abs(ply:EyeAngles()[3])

                if ply.MonitorLook == nil then ply.MonitorLook = 0 end

                ply.LookSpeed = math.abs(ply.MonitorLook - l_ang) * 20

                ply.MonitorLook = l_ang

                ply:SetMaterial( "lights/white" )
                ply:SetColor( Color( 255, 255, 255, (ply.LookSpeed + ply:GetVelocity():Length()) * 3) ) 
                ply:SetRenderMode( RENDERMODE_TRANSCOLOR )

            else

                ply:SetMaterial( "lights/white" )
                ply:SetColor( Color( 255, 255, 255, 255 ) )
                ply:SetRenderMode( RENDERMODE_TRANSCOLOR )

            end
        end

    end

end