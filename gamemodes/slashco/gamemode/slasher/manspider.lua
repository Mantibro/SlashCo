SlashCoSlasher.Manspider = {}

SlashCoSlasher.Manspider.Name = "Manspider"
SlashCoSlasher.Manspider.ID = 9
SlashCoSlasher.Manspider.Class = 1
SlashCoSlasher.Manspider.DangerLevel = 2
SlashCoSlasher.Manspider.IsSelectable = true
SlashCoSlasher.Manspider.Model = "models/slashco/slashers/manspider/manspider.mdl"
SlashCoSlasher.Manspider.GasCanMod = 0
SlashCoSlasher.Manspider.KillDelay = 5
SlashCoSlasher.Manspider.ProwlSpeed = 150
SlashCoSlasher.Manspider.ChaseSpeed = 296
SlashCoSlasher.Manspider.Perception = 1.0
SlashCoSlasher.Manspider.Eyesight = 5
SlashCoSlasher.Manspider.KillDistance = 150
SlashCoSlasher.Manspider.ChaseRange = 1200
SlashCoSlasher.Manspider.ChaseRadius = 0.9
SlashCoSlasher.Manspider.ChaseDuration = 9.0
SlashCoSlasher.Manspider.ChaseCooldown = 2
SlashCoSlasher.Manspider.JumpscareDuration = 2
SlashCoSlasher.Manspider.ChaseMusic = "slashco/slasher/manspider_chase.wav"
SlashCoSlasher.Manspider.KillSound = "slashco/slasher/manspider_kill.mp3"
SlashCoSlasher.Manspider.Description = "The Huntsman Slasher which is picky with its victims.\n\n-Manspider can only target one Survivor at a time.\n-He will slowly gather aggression while close to Survivors.\n-He can nest somewhere for a chance to instantly find Prey."
SlashCoSlasher.Manspider.ProTip = "-This Slasher is a very selective hunter."
SlashCoSlasher.Manspider.SpeedRating = "★★★☆☆"
SlashCoSlasher.Manspider.EyeRating = "★★★☆☆"
SlashCoSlasher.Manspider.DiffRating = "★☆☆☆☆"

SlashCoSlasher.Manspider.OnSpawn = function(slasher)

    slasher:SetViewOffset( Vector(0,0,20) )
    slasher:SetCurrentViewOffset( Vector(0,0,20) )
    PlayGlobalSound("slashco/slasher/manspider_idle.wav",50,slasher)

end

SlashCoSlasher.Manspider.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Manspider.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    v1 = slasher.SlasherValue1 --Target SteamID
    v2 = slasher.SlasherValue2 --Leap Cooldown
    v3 = slasher.SlasherValue3 --Time spend nested
    v4 = slasher.SlasherValue4 --Aggression

    if v2 > 0 then slasher.SlasherValue2 = v2 - FrameTime() end

    if not isstring(v1) or v1 == 0 then slasher.SlasherValue1 = "" end

    if v1 == "" then

        slasher:SetNWBool("CanChase", false)
        slasher:SetNWBool("CanKill", false)

        if #team.GetPlayers(TEAM_SURVIVOR) < 2 then
            v1 = team.GetPlayers(TEAM_SURVIVOR)[1]:SteamID64()
        end

    else

        slasher:SetNWBool("CanChase", true)
        slasher:SetNWBool("CanKill", true)

        if not IsValid(  player.GetBySteamID64( v1 ) ) or player.GetBySteamID64( v1 ):Team() ~= TEAM_SURVIVOR then slasher.SlasherValue1 = "" end

    end

    for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do --Switch Target if too close

        local s = team.GetPlayers(TEAM_SURVIVOR)[i]

        local d = s:GetPos():Distance( slasher:GetPos() )

        if d < (150) then

            local tr = util.TraceLine( {
                start = slasher:EyePos(),
                endpos = s:GetPos()+Vector(0,0,40),
                filter = slasher
            } )

            if tr.Entity == s then

                if slasher.SlasherValue1 ~= s:SteamID64() then

                    slasher.SlasherValue1 = s:SteamID64()
                    slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")

                end

            end

        end

    end

    if slasher:GetNWBool("ManspiderNested") then

        --Find a survivor
        slasher.SlasherValue3 = v3 + FrameTime()

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local s = team.GetPlayers(TEAM_SURVIVOR)[i]

            if s:GetPos():Distance( slasher:GetPos() ) < (1000 + (v3 * 3) + (SO * 750)) then

                local tr = util.TraceLine( {
                    start = slasher:EyePos(),
                    endpos = s:GetPos()+Vector(0,0,40),
                    filter = slasher
                } )

                if tr.Entity == s then
                    slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")
                    slasher.SlasherValue1 = s:SteamID64()
                    slasher:SetNWBool("ManspiderNested", false)

                    slasher:SetRunSpeed( SlashCoSlasher.Manspider.ProwlSpeed )
                    slasher:SetWalkSpeed( SlashCoSlasher.Manspider.ProwlSpeed )
                    slasher:SetSlowWalkSpeed( SlashCoSlasher.Manspider.ProwlSpeed )
                end

            end

        end

        slasher.SlasherValue4 = 0

    else

        --Not nested
        slasher.SlasherValue3 = 0

        if v1 == "" then

            for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

                local s = team.GetPlayers(TEAM_SURVIVOR)[i]

                local d = s:GetPos():Distance( slasher:GetPos() )
    
                if d < (1000) then
    
                    local tr = util.TraceLine( {
                        start = slasher:EyePos(),
                        endpos = s:GetPos()+Vector(0,0,40),
                        filter = slasher
                    } )
    
                    if tr.Entity == s then

                        slasher.SlasherValue4 = v4 + ( FrameTime() + (  (1000-d)  / 10000  )   )  + (SO * FrameTime())

                        if v4 > 100 then
                            slasher.SlasherValue1 = s:SteamID64()
                            slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")
                        end

                    end
    
                end
    
            end

        else

            slasher.SlasherValue4 = 0

        end

    end

    if slasher:GetNWString("ManspiderTarget") ~= v1 then
        slasher:SetNWString("ManspiderTarget", v1)
    end
    
    if v3 > 100 then
        if slasher:GetNWBool("ManspiderCanLeaveNest") ~= true then slasher:SetNWBool("ManspiderCanLeaveNest", true) end
    else
        if slasher:GetNWBool("ManspiderCanLeaveNest") ~= false then slasher:SetNWBool("ManspiderCanLeaveNest", false) end
    end

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Manspider.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Manspider.Perception)
end

SlashCoSlasher.Manspider.OnPrimaryFire = function(slasher)
    local target = slasher:GetEyeTrace().Entity	

    if not target:IsPlayer() then return end

    if target:SteamID64() ~= slasher.SlasherValue1 then
        slasher:ChatPrint("You can only kill your Prey.")
        return 
    else
        SlashCo.Jumpscare(slasher)
    end

end

SlashCoSlasher.Manspider.OnSecondaryFire = function(slasher)

    local target = slasher:GetEyeTrace().Entity	

    if not target:IsPlayer() then return end

    if target:SteamID64() ~= slasher.SlasherValue1 then return end

    SlashCo.StartChaseMode(slasher)

end

SlashCoSlasher.Manspider.OnMainAbilityFire = function(slasher)

    if slasher.SlasherValue1 ~= "" then return end

    if not slasher:GetNWBool("ManspiderNested") then

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

            local s = team.GetPlayers(TEAM_SURVIVOR)[i]
    
            if s:GetPos():Distance( slasher:GetPos() ) < 1600 then
    
                slasher:ChatPrint("Cannot Nest here, a Survivor is too close. . .")
                return
    
            end
    
        end

        slasher:SetNWBool("ManspiderNested", true)

        slasher:SetRunSpeed( 1 )
        slasher:SetWalkSpeed( 1 )
        slasher:SetSlowWalkSpeed( 1 )

    else

        if slasher.SlasherValue3 > 100 then

            slasher:SetNWBool("ManspiderNested", false)

            slasher:SetRunSpeed( SlashCoSlasher.Manspider.ProwlSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher.Manspider.ProwlSpeed )
            slasher:SetSlowWalkSpeed( SlashCoSlasher.Manspider.ProwlSpeed )

        end

    end

end


SlashCoSlasher.Manspider.OnSpecialAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher.SlasherValue2 > 0 then return end

    if not slasher:IsOnGround() then return end

    if not slasher:GetNWBool("InSlasherChaseMode") then return end

    slasher.SlasherValue2 = 4

    slasher:Freeze(true)
    slasher:EmitSound("slashco/slasher/manspider_scream"..math.random(1,4)..".mp3")

    timer.Simple(1, function()  

        local strength_forward = 800 + (SO * 500)
        local strength_up = 200 + (SO * 100)
    
        slasher:SetVelocity(  (slasher:EyeAngles():Forward() * strength_forward) + Vector(0,0,strength_up)  )
        slasher:Freeze(false)

    end)

end

SlashCoSlasher.Manspider.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")
    local manspider_nest = ply:GetNWBool("ManspiderNested")

    if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if manspider_nest then

		ply.CalcSeqOverride = ply:LookupSequence("nest")

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Manspider.Footstep = function(ply)

    if SERVER then
        ply:EmitSound( "slashco/slasher/manspider_step.mp3")
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Manspider.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Manspider") == true  then

            if LocalPlayer().mans_f == nil then LocalPlayer().mans_f = 0 end
            LocalPlayer().mans_f = LocalPlayer().mans_f+(FrameTime()*20)
            if LocalPlayer().mans_f > 59 then LocalPlayer().mans_f = 58 end

            local Overlay = Material("slashco/ui/overlays/jumpscare_9")
            Overlay:SetInt( "$frame", math.floor(LocalPlayer().mans_f) )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

        else
            LocalPlayer().mans_f = nil
        end

    end)

    local LeapIcon = Material("slashco/ui/icons/slasher/s_punch")

    SlashCoSlasher.Manspider.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        local is_nested = LocalPlayer():GetNWBool("ManspiderNested")
        local V1 = LocalPlayer():GetNWString("ManspiderTarget")

        if V1 ~= "" then

            if IsValid( player.GetBySteamID64( V1 ) ) then

                draw.SimpleText( "Your Prey: "..player.GetBySteamID64( V1 ):Name(), "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/6), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

            end

            for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

                local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

                if ply:SteamID64() == V1 and not ply:GetNWBool("BGoneSoda") then
                    ply:SetMaterial( "lights/white" )
                    ply:SetColor( Color( 255, 0, 0, 255 ) )
                    ply:SetRenderMode( RENDERMODE_TRANSCOLOR )
                end

                if ply:SteamID64() ~= V1 then
                    ply:SetMaterial( "" )
                    ply:SetColor( Color( 255, 255, 255, 255 ) )
                    ply:SetRenderMode( RENDERMODE_TRANSCOLOR )
                end

            end

        else
            for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

                local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

                if ply:GetMaterial() == "lights/white" then
                    ply:SetMaterial( "" )
                    ply:SetColor( Color( 255, 255, 255, 255 ) )
                    ply:SetRenderMode( RENDERMODE_TRANSCOLOR )
                end

            end
        end

        if not is_nested then
            if V1 == "" then draw.SimpleText( "R - Nest", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) end
        else

            if not LocalPlayer():GetNWBool("ManspiderCanLeaveNest") then
                draw.SimpleText( "(Wait for prey to come)", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
            else
                draw.SimpleText( "R - Abandon Nest", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
            end

        end

        if inchase then

            surface.SetMaterial(LeapIcon)
            surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
            draw.SimpleText( "F - Leap", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

        end

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Manspider.ClientSideEffect = function()

    end

end