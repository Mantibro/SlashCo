SlashCoSlasher.Dolphinman = {}

SlashCoSlasher.Dolphinman.Name = "Dolphinman"
SlashCoSlasher.Dolphinman.ID = 16
SlashCoSlasher.Dolphinman.Class = 1
SlashCoSlasher.Dolphinman.DangerLevel = 2
SlashCoSlasher.Dolphinman.IsSelectable = true
SlashCoSlasher.Dolphinman.Model = "models/slashco/slashers/dolphinman/dolphinman.mdl"
SlashCoSlasher.Dolphinman.GasCanMod = 0
SlashCoSlasher.Dolphinman.KillDelay = 0.25
SlashCoSlasher.Dolphinman.ProwlSpeed = 150
SlashCoSlasher.Dolphinman.ChaseSpeed = 300
SlashCoSlasher.Dolphinman.Perception = 1.0
SlashCoSlasher.Dolphinman.Eyesight = 3
SlashCoSlasher.Dolphinman.KillDistance = 135
SlashCoSlasher.Dolphinman.ChaseRange = 0
SlashCoSlasher.Dolphinman.ChaseRadius = 0.91
SlashCoSlasher.Dolphinman.ChaseDuration = 10.0
SlashCoSlasher.Dolphinman.ChaseCooldown = 3
SlashCoSlasher.Dolphinman.JumpscareDuration = 0.5
SlashCoSlasher.Dolphinman.ChaseMusic = ""
SlashCoSlasher.Dolphinman.KillSound = "slashco/slasher/dolfin_kill.mp3"
SlashCoSlasher.Dolphinman.Description = [[The Patient Slasher who waits for survivors to come to him.

-Dolphinman must hide away from survivors, to build up Hunt.
-Upon being found, his power will activate, and stay active until he runs out of Hunt.
-Killing Survivors increases Hunt.]]
SlashCoSlasher.Dolphinman.ProTip = "-This Slasher does not appear to approach victims on its own."
SlashCoSlasher.Dolphinman.SpeedRating = "★★☆☆☆"
SlashCoSlasher.Dolphinman.EyeRating = "★★★☆☆"
SlashCoSlasher.Dolphinman.DiffRating = "★★★★☆"

SlashCoSlasher.Dolphinman.OnSpawn = function(slasher)

end

SlashCoSlasher.Dolphinman.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Dolphinman.OnTickBehaviour = function(slasher)

    local v1 = slasher.SlasherValue1 --Hunt power

    local hunt_boost = 0

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher:GetNWBool("DolphinInHiding") then

        slasher:SetRunSpeed( 1 )
        slasher:SetWalkSpeed( 1 )
        slasher:SetSlowWalkSpeed( 1 )

        --get hunt yes.....
        if v1 < 100 then slasher.SlasherValue1 = v1 + ( FrameTime() / (2 -  ( (SO-1) / 2) ) ) end

        --Survivore finderore

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local s = team.GetPlayers(TEAM_SURVIVOR)[i]

            if s:GetPos():Distance( slasher:GetPos() ) < 500 then

                local tr = util.TraceLine( {
                    start = slasher:EyePos(),
                    endpos = s:GetPos()+Vector(0,0,40),
                    filter = slasher
                } )

                if tr.Entity == s then

                    slasher:SetNWBool("DolphinFound", true)

                    PlayGlobalSound("slashco/slasher/dolfin_call.wav",85,slasher)
                    PlayGlobalSound("slashco/slasher/dolfin_call_far.wav",145,slasher)

                    timer.Simple(10, function() 
                        slasher:SetNWBool("DolphinFound", false)
                        slasher:SetNWBool("DolphinInHiding", false)

                        slasher:SetNWBool("DolphinHunting", true)
                    
                    end)

                end

            end

        end

        if slasher:GetNWBool("CanKill") then
            slasher:SetNWBool("CanKill", false)   
        end

    else

        if not slasher:GetNWBool("CanKill") then
            slasher:SetNWBool("CanKill", true)   
        end

        --urgh i can move yes lmao

        if not slasher:GetNWBool("DolphinHunting") then
            --auggh im slow :((

            slasher:SetRunSpeed( SlashCoSlasher.Dolphinman.ProwlSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher.Dolphinman.ProwlSpeed )
            slasher:SetSlowWalkSpeed( SlashCoSlasher.Dolphinman.ProwlSpeed )

        else
            --you're fucking dead

            slasher:SetRunSpeed( SlashCoSlasher.Dolphinman.ChaseSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher.Dolphinman.ChaseSpeed )
            slasher:SetSlowWalkSpeed( SlashCoSlasher.Dolphinman.ChaseSpeed )

            hunt_boost = 1

            --oh fuck i'm losing my hunt!!
            slasher.SlasherValue1 = v1 - ( FrameTime() / 1+SO)

            --damn shit
            if v1 <= 0 then
                slasher:SetNWBool("DolphinHunting", false)

                slasher:StopSound("slashco/slasher/dolfin_call.wav")
                slasher:StopSound("slashco/slasher/dolfin_call_far.wav")
                for i = 1, 8 do --WHY THE FUCK DO I HAVE TO DO THIS HOLY SHIT
                    timer.Simple((i/10), function() 
                        slasher:StopSound("slashco/slasher/dolfin_call.wav") 
                        slasher:StopSound("slashco/slasher/dolfin_call_far.wav") 
                    end)
                end
            end

        end


    end

    if slasher:GetNWInt("DolphinHunt") ~= math.floor( v1 ) then
        slasher:SetNWInt("DolphinHunt", math.floor( v1 ))
    end

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Dolphinman.Eyesight + ( hunt_boost * 5 ))
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Dolphinman.Perception + ( hunt_boost * 3 ))
end

SlashCoSlasher.Dolphinman.OnPrimaryFire = function(slasher)
    if SlashCo.Jumpscare(slasher) then
        slasher.SlasherValue1 = math.min(100, slasher.SlasherValue1 + 25)
    end
end

SlashCoSlasher.Dolphinman.OnSecondaryFire = function(slasher)

end

SlashCoSlasher.Dolphinman.OnMainAbilityFire = function(slasher)

    if not slasher:GetNWBool("DolphinHunting") and not slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") then

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do
            local s = team.GetPlayers(TEAM_SURVIVOR)[i]
            if s:GetPos():Distance( slasher:GetPos() ) < 1000 then
                slasher:ChatPrint("You cannot hide here. A survivor is too close.")
                return
            end
        end

        slasher:SetNWBool("DolphinInHiding", true)

        return

    end

    if slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") and slasher.SlasherValue1 > 5 then

        slasher:SetNWBool("DolphinInHiding", false)

        slasher.SlasherValue1 = slasher.SlasherValue1 - math.floor( slasher.SlasherValue1 / 2 )


    end

end


SlashCoSlasher.Dolphinman.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.Dolphinman.Animator = function(ply) 

    local hunt = ply:GetNWBool("DolphinHunting")
    local hide = ply:GetNWBool("DolphinInHiding")
    local found = ply:GetNWBool("DolphinFound")

    if ply:IsOnGround() then

        if not hunt then 
            ply.CalcIdeal = ACT_HL2MP_WALK 
            ply.CalcSeqOverride = ply:LookupSequence("prowl")
        else
            ply.CalcIdeal = ACT_HL2MP_RUN 
            ply.CalcSeqOverride = ply:LookupSequence("hunt")
        end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

    if hide then
        ply.CalcSeqOverride = ply:LookupSequence("hide")
    end

    if found then
        ply.CalcSeqOverride = ply:LookupSequence("found")
    end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Dolphinman.Footstep = function(ply)

    if SERVER then
        ply:EmitSound( "slashco/slasher/amogus_step"..math.random(1,3)..".wav", 75, 130) 
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Dolphinman.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Dolphinman") == true  then


            
        end

    end)

    SlashCoSlasher.Dolphinman.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = false
        local willdrawmain = true

        local hiding = LocalPlayer():GetNWBool("DolphinInHiding")
        local hunting = LocalPlayer():GetNWBool("DolphinHunting")

        surface.SetDrawColor( 0, 0, 0)
        surface.DrawRect( cx-200, cy +ScrH()/4, 400, 25 )

        local b_pad = 6

        local hunt_val = LocalPlayer():GetNWInt("DolphinHunt")

        surface.SetDrawColor( 255, 0, 0)
        surface.DrawRect( cx-200+(b_pad/2),(b_pad/2)+cy +ScrH()/4, (400-b_pad)*(hunt_val/100), 25-b_pad )

        draw.SimpleText( "HUNT", "ItemFontTip", cx-300, cy +ScrH()/4 , Color( 255, 0, 0, 255 ), TEXT_ALIGN_TOP, TEXT_ALIGN_RIGHT ) 
        draw.SimpleText( math.floor(hunt_val).." %", "ItemFontTip", cx+220, cy +ScrH()/4 , Color( 255, 0, 0, 255 ), TEXT_ALIGN_TOP, TEXT_ALIGN_RIGHT )

        if not hiding and not hunting then
            draw.SimpleText( "R - Hide", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        else
            draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
        end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Dolphinman.ClientSideEffect = function()

    end

    hook.Add("Tick", "DolphinmanLight", function() 
    
        for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do

            if v == LocalPlayer() then return end

            if v:GetNWBool("DolphinHunting") then
        
                local tlight = DynamicLight( v:EntIndex() + 915 )
                   if ( tlight ) then
                        tlight.pos = v:LocalToWorld( Vector(0,0,20) )
                        tlight.r = 249
                        tlight.g = 215
                        tlight.b = 10
                        tlight.brightness = 5
                        tlight.Decay = 1000
                        tlight.Size = 500
                        tlight.DieTime = CurTime() + 1
                    end
    
            end

        end

    end)

end