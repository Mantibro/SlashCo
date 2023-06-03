SlashCoSlasher.Male07 = {}

SlashCoSlasher.Male07.Name = "Male_07"
SlashCoSlasher.Male07.ID = 6
SlashCoSlasher.Male07.Class = 3
SlashCoSlasher.Male07.DangerLevel = 3
SlashCoSlasher.Male07.IsSelectable = true
SlashCoSlasher.Male07.Model = "models/Humans/Group01/male_07.mdl"
SlashCoSlasher.Male07.GasCanMod = 0
SlashCoSlasher.Male07.KillDelay = 4
SlashCoSlasher.Male07.ProwlSpeed = 100
SlashCoSlasher.Male07.ChaseSpeed = 302
SlashCoSlasher.Male07.Perception = 1.0
SlashCoSlasher.Male07.Eyesight = 5
SlashCoSlasher.Male07.KillDistance = 160
SlashCoSlasher.Male07.ChaseRange = 500
SlashCoSlasher.Male07.ChaseRadius = 0.9
SlashCoSlasher.Male07.ChaseDuration = 5.0
SlashCoSlasher.Male07.ChaseCooldown = 3
SlashCoSlasher.Male07.JumpscareDuration = 2
SlashCoSlasher.Male07.ChaseMusic = "slashco/slasher/male07_chase.wav"
SlashCoSlasher.Male07.KillSound = "slashco/slasher/male07_kill.mp3"
SlashCoSlasher.Male07.Description = "The Omniscient Slasher which can possess one of his many clones.\n\n-Male_07 will turn into a monstrous entity after a long enough chase.\n-He can keep his deadlier human form for longer as the game progresses."
SlashCoSlasher.Male07.ProTip = "-This Slasher is incorporeal and can possess vessels."
SlashCoSlasher.Male07.SpeedRating = "★★★★★"
SlashCoSlasher.Male07.EyeRating = "★★☆☆☆"
SlashCoSlasher.Male07.DiffRating = "★★★☆☆"

SlashCoSlasher.Male07.OnSpawn = function(slasher)
    slasher.SlasherValue1 = 1
end

SlashCoSlasher.Male07.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Male07.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    v1 = slasher.SlasherValue1 --State
    v2 = slasher.SlasherValue2 --Time Spent Human Chasing
    v3 = slasher.SlasherValue3 --Cooldown
    v4 = slasher.SlasherValue4 --Slash Cooldown

    local prowl_final = SlashCoSlasher.Male07.ProwlSpeed
    local chase_final = SlashCoSlasher.Male07.ChaseSpeed
    local eyesight_final = SlashCoSlasher.Male07.Eyesight
    local perception_final = SlashCoSlasher.Male07.Perception

    if v3 > 0 then slasher.SlasherValue3 = v3 - FrameTime() end
    if v4 > 0 then slasher.SlasherValue4 = v4 - FrameTime() end

    if v1 == 0 then --Specter mode

        prowl_final = 300
        chase_final = 300
        perception_final = 0.0
        eyesight_final = 10

        slasher:SetNWBool("CanKill", false)
        slasher:SetNWBool("CanChase", false)

    elseif v1 == 1 then --Human mode

        prowl_final = 100
        chase_final = 302
        perception_final = 1.0
        eyesight_final = 2

        slasher:SetNWBool("CanKill", true)
        slasher:SetNWBool("CanChase", true)

        if slasher.CurrentChaseTick == 99 then slasher.CurrentChaseTick = 0 end

    elseif v1 == 2 then --Monster mode

        prowl_final = 150
        chase_final = 285
        perception_final = 1.5
        eyesight_final = 5

        slasher:SetNWBool("CanKill", false)

    end

    if slasher:GetNWBool("InSlasherChaseMode") then 

        if v1 == 1 then

            slasher.SlasherValue2 = v2 + FrameTime()

            --Timer - 10 seconds + Game Progress (1-10) ^ 3 (SO - x2)

            if v2 > 1 + (SlashCo.CurRound.GameProgress*1.5) +  (0.75 * math.pow( SlashCo.CurRound.GameProgress, 2 ) ) * (1 + SO) then 

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

                slasher.SlasherValue1 = 2

            end

        end

    else

        slasher.SlasherValue2 = 0

    end

    if slasher:GetNWInt("Male07State") ~= v1 then
        slasher:SetNWInt("Male07State", v1)
    end

    slasher:SetNWFloat("Slasher_Eyesight", eyesight_final)
    slasher:SetNWInt("Slasher_Perception", perception_final)
end

SlashCoSlasher.Male07.OnPrimaryFire = function(slasher)
    if slasher.SlasherValue1 == 1 then
        SlashCo.Jumpscare(slasher)
        return
    end

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher.SlasherValue1 == 0 then return end

    if slasher.SlasherValue4 < 0.01 then

        slasher:SetNWBool("Male07Slashing",false)
        timer.Remove("Male07SlashDecay")
        slasher.SlasherValue4 = 2

        timer.Simple(0.5, function() 

            slasher:EmitSound("slashco/slasher/trollge_swing.wav")

            if SERVER then

                local target = slasher:TraceHullAttack( slasher:EyePos(), slasher:LocalToWorld(Vector(45,0,60)), Vector(-30,-40,-60), Vector(30,40,60), 50 + (SO*50), DMG_SLASH, 2, false )

                if not target:IsValid() then return end

                if target:IsPlayer() then

                    if target:Team() ~= TEAM_SURVIVOR then return end

                    local vPoint = target:GetPos() + Vector(0,0,50)
                    local bloodfx = EffectData()
                    bloodfx:SetOrigin( vPoint )
                    util.Effect( "BloodImpact", bloodfx )

                    target:EmitSound("slashco/slasher/trollge_hit.wav") 

                end

                SlashCo.BustDoor(slasher, target, 30000)

            end

        end)

        timer.Simple(0.1, function() 

            slasher:SetNWBool("Male07Slashing",true)

            timer.Create( "Male07SlashDecay", 1.5, 1, function() slasher:SetNWBool("Male07Slashing",false) end)

        end)

    end

end

SlashCoSlasher.Male07.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Male07.OnMainAbilityFire = function(slasher)

    if slasher.SlasherValue3 > 0 or slasher:GetNWBool("InSlasherChaseMode") then return end

    if slasher.SlasherValue1 == 0 and slasher:GetEyeTrace().Entity:GetClass() == "sc_maleclone" then

        target = slasher:GetEyeTrace().Entity	

        if slasher:GetPos():Distance(target:GetPos()) < 150 then

            slasher:EmitSound("slashco/slasher/male07_possess.mp3")

            slasher:SetPos(target:GetPos())
            slasher:SetAngles(target:GetAngles())
            target:Remove()

            local modelname = "models/Humans/Group01/male_07.mdl"
	        util.PrecacheModel( modelname )
	        slasher:SetModel( modelname )

		    slasher:SetColor(Color(255,255,255,255))
            slasher:DrawShadow(true)
		    slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		    slasher:SetNoDraw(false)
            slasher:SetMoveType(MOVETYPE_WALK)

            slasher.SlasherValue1 = 1

            slasher.CurrentChaseTick = 0

            slasher.SlasherValue3 = 3

            slasher:SetWalkSpeed(100)
            slasher:SetRunSpeed(100)

            return

        end

    end

    if slasher.SlasherValue1 > 0 then

        local modelname = "models/hunter/plates/plate.mdl"
	    util.PrecacheModel( modelname )
	    slasher:SetModel( modelname )

        slasher:SetColor(Color(0,0,0,0))
        slasher:DrawShadow(false)
		slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		slasher:SetNoDraw(true)
        slasher:SetPos(slasher:GetPos() + Vector(0,0,60))

        SlashCo.CreateItem("sc_maleclone",slasher:GetPos(),slasher:GetAngles())

        slasher.SlasherValue1 = 0

        slasher:EmitSound("slashco/slasher/male07_unpossess"..math.random(1,2)..".mp3")

        slasher.SlasherValue3 = 3

        slasher:SetWalkSpeed(300)
        slasher:SetRunSpeed(300)

        return

    end

end


SlashCoSlasher.Male07.OnSpecialAbilityFire = function(slasher)

end



SlashCoSlasher.Male07.Animator = function(ply) 

    local male_slashing = ply:GetNWBool("Male07Slashing")
	local male_transforming = ply:GetNWBool("Male07Transforming")
    local chase = ply:GetNWBool("InSlasherChaseMode")
    
    if ply:GetModel() == "models/humans/group01/male_07.mdl" then 
	
		if ply:IsOnGround() then

			if not chase then 
				ply.CalcIdeal = ACT_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("walk_all")
			else
				ply.CalcIdeal = ACT_RUN_SCARED
				ply.CalcSeqOverride = ply:LookupSequence("run_all_panicked")
			end
	
		else
	
			ply.CalcIdeal = ACT_JUMP
			ply.CalcSeqOverride = ply:LookupSequence("jump_holding_jump")
	
		end

		ply:SetPoseParameter( "move_x", ply:GetVelocity():Length()/100 )

		if ply:GetVelocity():Length() < 30 then 

			ply.CalcIdeal = ACT_IDLE
			ply.CalcSeqOverride = ply:LookupSequence("idle_all")

		end

	elseif ply:GetModel() == "models/slashco/slashers/male_07/male_07_monster.mdl" then

		if not male_slashing and not male_transforming then ply.anim_antispam = false end
		
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

		if male_slashing and ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:AddVCDSequenceToGestureSlot( 1, ply:LookupSequence("slash"), 0, true )
			ply.anim_antispam = true 
		end

		if male_transforming then 
		
			ply.CalcSeqOverride = ply:LookupSequence("transform") 
	
			if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end
		
		end
	
	
	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Male07.Footstep = function(ply)

    if SERVER then
        if ply:GetModel() == "models/hunter/plates/plate.mdl" then
            return true 
        else
            return false
        end
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Male07.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Male07") == true  then

            if LocalPlayer().male_f == nil then LocalPlayer().male_f = 0 end
            LocalPlayer().male_f = LocalPlayer().male_f+(FrameTime()*20)
            if LocalPlayer().male_f > 49 then return end

            local Overlay = Material("slashco/ui/overlays/jumpscare_6")
            Overlay:SetInt( "$frame", math.floor(LocalPlayer().male_f) )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

        else
            LocalPlayer().male_f = nil
        end

    end)

    local MaleSpecter = Material("slashco/ui/icons/slasher/s_6_s0")
	local MaleMonster = Material("slashco/ui/icons/slasher/s_6_s2")
    local GenericSlashIcon = Material("slashco/ui/icons/slasher/s_slash")

    SlashCoSlasher.Male07.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        local V1 = LocalPlayer():GetNWInt("Male07State")
					
		if V1 ~= 0 then
			draw.SimpleText( "R - Unpossess Vessel", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "R - Possess Vessel", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

		if V1 ~= 1 then
			willdrawmain = false

			if V1 == 0 then
				surface.SetMaterial(MaleSpecter)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
			end

			if V1 == 2 then
				surface.SetMaterial(MaleMonster)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 

				willdrawkill = false

				surface.SetMaterial(GenericSlashIcon)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M1 - Slash", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

			end
		else
			willdrawmain = true
		end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Male07.ClientSideEffect = function()

    end

end