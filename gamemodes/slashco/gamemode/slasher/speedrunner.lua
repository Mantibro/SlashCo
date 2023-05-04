SlashCoSlasher.Speedrunner = {}

SlashCoSlasher.Speedrunner.Name = "Speedrunner"
SlashCoSlasher.Speedrunner.ID = 15
SlashCoSlasher.Speedrunner.Class = 1
SlashCoSlasher.Speedrunner.DangerLevel = 3
SlashCoSlasher.Speedrunner.IsSelectable = true
SlashCoSlasher.Speedrunner.Model = "models/slashco/slashers/dream/dream.mdl"
SlashCoSlasher.Speedrunner.GasCanMod = 0
SlashCoSlasher.Speedrunner.KillDelay = 8
SlashCoSlasher.Speedrunner.ProwlSpeed = 50
SlashCoSlasher.Speedrunner.ChaseSpeed = 50
SlashCoSlasher.Speedrunner.Perception = 2.0
SlashCoSlasher.Speedrunner.Eyesight = 5
SlashCoSlasher.Speedrunner.KillDistance = 125
SlashCoSlasher.Speedrunner.ChaseRange = 0
SlashCoSlasher.Speedrunner.ChaseRadius = 1
SlashCoSlasher.Speedrunner.ChaseDuration = 0.0
SlashCoSlasher.Speedrunner.ChaseCooldown = 1
SlashCoSlasher.Speedrunner.JumpscareDuration = 1.5
SlashCoSlasher.Speedrunner.ChaseMusic = ""
SlashCoSlasher.Speedrunner.KillSound = "slashco/slasher/speedrunner_kill.mp3"
SlashCoSlasher.Speedrunner.Description = [[The Speed Slasher whose speed grows at a constant rate over time.

-Speedrunner will start out extremely slow.
-After gaining enough speed, he will gain the ability to perform RNG sacrifice, resetting speed,
but allowing him to regain it faster, and more of it.
-RNG Sacrifice will have additional effects on the round when it is used.]]
SlashCoSlasher.Speedrunner.ProTip = "-This Slasher grows exeptionally faster with time."
SlashCoSlasher.Speedrunner.SpeedRating = "★★★★★"
SlashCoSlasher.Speedrunner.EyeRating = "★★★☆☆"
SlashCoSlasher.Speedrunner.DiffRating = "★★★★★"

SlashCoSlasher.Speedrunner.OnSpawn = function(slasher)
    PlayGlobalSound("slashco/slasher/speedrunner_1.wav",100,slasher)
    slasher:SetNWBool("CanKill", true)
    slasher.SlasherValue2 = 1
    slasher.SlasherValue3 = 235
end

SlashCoSlasher.Speedrunner.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Speedrunner.OnTickBehaviour = function(slasher)

    v1 = slasher.SlasherValue1 --Speed
    v2 = slasher.SlasherValue2 --Speed Gain multiplier
    v3 = slasher.SlasherValue3 --max speed allowed

    local ms = SCInfo.Maps[SlashCo.ReturnMapIndex()].SIZE

    local size_multiplier =  ( ((5 - ms) / 10) + ((ms-1) / 15) )

    if v1 < v3 then

        slasher.SlasherValue1 = v1 + (( FrameTime() * (size_multiplier)) * (v2))

    end

    slasher:SetRunSpeed( 50+slasher.SlasherValue1 )
    slasher:SetWalkSpeed( 50+slasher.SlasherValue1 )
    slasher:SetSlowWalkSpeed( 50+slasher.SlasherValue1 )
    
    if slasher:GetNWInt("SpeedrunnerSpeed") ~= math.floor( v1 ) then
        slasher:SetNWInt("SpeedrunnerSpeed", math.floor( v1 ))
    end

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Speedrunner.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Speedrunner.Perception)
end

SlashCoSlasher.Speedrunner.OnPrimaryFire = function(slasher)
    SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Speedrunner.OnSecondaryFire = function(slasher)
    --SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Speedrunner.OnMainAbilityFire = function(slasher)

    if v1 >= v3 and not slasher:GetNWBool("SpeedrunnerSacrificeTwo") then
        slasher:StopSound("slashco/slasher/speedrunner_1.wav")
        slasher:StopSound("slashco/slasher/speedrunner_2.wav")
        timer.Simple(0.1, function()   
            slasher:StopSound("slashco/slasher/speedrunner_1.wav")
            slasher:StopSound("slashco/slasher/speedrunner_2.wav")
        end)

        slasher:Freeze(true)

        if not slasher:GetNWBool("SpeedrunnerSacrificeOne") then
            slasher:EmitSound("slashco/slasher/speedrunner_rng1.mp3", 85, 100)
        else
            slasher:EmitSound("slashco/slasher/speedrunner_rng2.mp3", 85, 100)
        end

        timer.Simple(2, function() 
        
            slasher:Freeze(false)

            slasher.SlasherValue1 = 0

            if not slasher:GetNWBool("SpeedrunnerSacrificeOne") then
                slasher:SetNWBool("SpeedrunnerSacrificeOne", true)
                PlayGlobalSound("slashco/slasher/speedrunner_2.wav",100,slasher)
                slasher.SlasherValue2 = 2
                slasher.SlasherValue3 = 275

                -- the great ability
                for _, ent in ipairs( ents.FindByClass("sc_gascan") ) do
                    ent:SetPos(SlashCo.TraceHullLocator() + Vector(0,0,50))
                    ent:SetAngles(Angle( math.random(0,360),math.random(0,360),math.random(0,360) ))
                    ent:GetPhysicsObject():ApplyForceCenter( Vector( (math.random()-0.5)*100 , (math.random()-0.5)*100 , (math.random()-0.5)*100 ) )
                end

                return
            end

            if not slasher:GetNWBool("SpeedrunnerSacrificeTwo") then
                slasher:SetNWBool("SpeedrunnerSacrificeTwo", true)
                PlayGlobalSound("slashco/slasher/speedrunner_3.wav",100,slasher)
                slasher.SlasherValue2 = 4
                slasher.SlasherValue3 = 450
                slasher:SetBodygroup(1,1)

                -- the great ability
                for _, ent in ipairs( ents.FindByClass("sc_gascan") ) do
                    ent:SetPos(SlashCo.TraceHullLocator() + Vector(0,0,50))
                    ent:SetAngles(Angle( math.random(0,360),math.random(0,360),math.random(0,360) ))
                    ent:GetPhysicsObject():ApplyForceCenter( Vector( (math.random()-0.5)*200 , (math.random()-0.5)*200 , (math.random()-0.5)*200 ) )
                end

                return
            end

        end)
    end

end


SlashCoSlasher.Speedrunner.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.Speedrunner.Animator = function(ply, veloc) 

    local move_vel = ply:WorldToLocal(veloc + ply:GetPos())
    local anim_vel = veloc:Length()

    if ply:IsOnGround() then

        if anim_vel > 1 then

            if anim_vel < 100 then
		        ply.CalcSeqOverride = ply:LookupSequence("slow")
                ply:SetPoseParameter( "runner_speed", move_vel[1]/200)
            end

            if anim_vel >= 150 and anim_vel < 320 then
                ply.CalcSeqOverride = ply:LookupSequence("fast")
                ply:SetPoseParameter( "runner_speed", move_vel[1]/250)
            end

            if anim_vel >= 320 then
                ply.CalcSeqOverride = ply:LookupSequence("fastest")
                ply:SetPoseParameter( "runner_speed", move_vel[1]/100)
            end

        else
            ply.CalcSeqOverride = ply:LookupSequence("idle")
        end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

    if ply:GetNWBool("SpeedrunnerSacrificeTwo") then ply.CalcSeqOverride = ply:LookupSequence("ascended") end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Speedrunner.Footstep = function(ply)

    if SERVER then


        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Speedrunner.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Speedrunner") == true  then

            if LocalPlayer().spd_f == nil then LocalPlayer().spd_f = 0 end
            LocalPlayer().spd_f = LocalPlayer().spd_f+(FrameTime()*20)
            if LocalPlayer().spd_f > 25 then LocalPlayer().spd_f = 25 end

            local Overlay = Material("slashco/ui/overlays/jumpscare_15")
            Overlay:SetInt( "$frame", math.floor(LocalPlayer().spd_f) )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

        else
            LocalPlayer().spd_f = nil
        end

    end)

    SlashCoSlasher.Speedrunner.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = false
        local willdrawmain = true

        local curspeed = LocalPlayer():GetNWInt("SpeedrunnerSpeed")
        local speedprc = 0

        speedprc = (curspeed / 235) * 100

        if LocalPlayer():GetNWBool("SpeedrunnerSacrificeOne") then
            speedprc = (curspeed / 275) * 100
        end

        if LocalPlayer():GetNWBool("SpeedrunnerSacrificeTwo") then
            speedprc = (curspeed / 450) * 100
        end

        speedprc = math.floor(speedprc)

        if not LocalPlayer():GetNWBool("SpeedrunnerSacrificeTwo") then

            if speedprc >= 100 then
                draw.SimpleText( "R - RNG Sacrifice", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
            else
                draw.SimpleText( "-Not enough speed-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
            end

        end

        draw.SimpleText( "SPEED: "..speedprc.."%", "ItemFontTip", cx, cy +ScrH()/4 , Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Speedrunner.ClientSideEffect = function()

    end

    hook.Add("Tick", "SpeedrunnerBones", function() 
    
        for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do

            if v:GetNWString("Slasher") == "Speedrunner" then

                if v.AllBones == nil then

                    v.AllBones = {}

                    for b = 1, v:GetBoneCount() - 1 do
                        table.insert( v.AllBones, {Bone = v:GetBoneName( b ), Offset = Vector(0,0,0)} )
                    end

                    return

                end

                local r_bone = math.random(1, v:GetBoneCount()-1)

                local cur_off = v.AllBones[r_bone].Offset

                v.AllBones[r_bone].Offset = v.AllBones[r_bone].Offset+ Vector(( (math.random()-0.5)), ( (math.random()-0.5)), ( (math.random()-0.5)))
                if v.AllBones[r_bone].Offset:Length() > 3 then v.AllBones[r_bone].Offset = Vector((math.random()-0.5),(math.random()-0.5),(math.random()-0.5)) end

                local intensity = 0

                if v:GetNWBool("SpeedrunnerSacrificeOne") then intensity = 0.5 end
                if v:GetNWBool("SpeedrunnerSacrificeTwo") then intensity = 1.5 end

                for b = 1, v:GetBoneCount() - 1 do
                    if b == 5 then
                        v:ManipulateBoneAngles( b, Angle(0,0,intensity*v.AllBones[r_bone].Offset:Length()*20) )
                        continue
                    end

                    if b == 6 then
                        v:ManipulateBoneAngles( b, Angle(0,0,-intensity*v.AllBones[r_bone].Offset:Length()*20) )
                        continue
                    end

                    if b == 21 then
                        v:ManipulateBoneAngles( b, Angle(v.AllBones[r_bone].Offset.x*20,v.AllBones[r_bone].Offset.y*20,v.AllBones[r_bone].Offset.z*2) )
                        continue
                    end

                    if b == 25 then
                        v:ManipulateBoneAngles( b, Angle(v.AllBones[r_bone].Offset.x*20,v.AllBones[r_bone].Offset.y*20,v.AllBones[r_bone].Offset.z*2) )
                        continue
                    end

                    if b == 30 then
                        v:ManipulateBoneAngles( b, Angle(v.AllBones[r_bone].Offset.x*20,v.AllBones[r_bone].Offset.y*20,v.AllBones[r_bone].Offset.z*2) )
                        continue
                    end

                    v:ManipulateBonePosition( b, v.AllBones[b].Offset * 2 * intensity )
                end

            end

            if v:GetNWBool("SpeedrunnerSacrificeTwo") then
        
                local tlight = DynamicLight( v:EntIndex() + 965 )
                   if ( tlight ) then
                        tlight.pos = v:LocalToWorld( Vector(0,0,20) )
                        tlight.r = 80
                        tlight.g = 255
                        tlight.b = 80
                        tlight.brightness = 5
                        tlight.Decay = 1000
                        tlight.Size = 500
                        tlight.DieTime = CurTime() + 1
                    end
    
            end

        end
    
    end)

end