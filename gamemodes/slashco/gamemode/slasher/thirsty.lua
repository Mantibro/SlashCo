SlashCoSlasher.Thirsty = {}

SlashCoSlasher.Thirsty.Name = "Thirsty"
SlashCoSlasher.Thirsty.ID = 5
SlashCoSlasher.Thirsty.Class = 2
SlashCoSlasher.Thirsty.DangerLevel = 2
SlashCoSlasher.Thirsty.IsSelectable = true
SlashCoSlasher.Thirsty.Model = "models/slashco/slashers/thirsty/thirsty.mdl"
SlashCoSlasher.Thirsty.GasCanMod = 0
SlashCoSlasher.Thirsty.KillDelay = 2
SlashCoSlasher.Thirsty.ProwlSpeed = 100
SlashCoSlasher.Thirsty.ChaseSpeed = 260
SlashCoSlasher.Thirsty.Perception = 1.0
SlashCoSlasher.Thirsty.Eyesight = 2
SlashCoSlasher.Thirsty.KillDistance = 150
SlashCoSlasher.Thirsty.ChaseRange = 900
SlashCoSlasher.Thirsty.ChaseRadius = 0.92
SlashCoSlasher.Thirsty.ChaseDuration = 8.0
SlashCoSlasher.Thirsty.ChaseCooldown = 3
SlashCoSlasher.Thirsty.JumpscareDuration = 2
SlashCoSlasher.Thirsty.ChaseMusic = "slashco/slasher/thirsty_chase.wav"
SlashCoSlasher.Thirsty.KillSound = "slashco/slasher/thirsty_kill.mp3"
SlashCoSlasher.Thirsty.Description = "The Milk Slasher whose abilities depend on his level of Thirst.\n\n-Thirsty must drink Jugs of Milk to reset his thirst.\n-The Thirstier he is, the slower he is, but can sense the position of players.\n-Thirsty is really quiet."
SlashCoSlasher.Thirsty.ProTip = "-This Slasher is heavily linked with Milk Jugs."
SlashCoSlasher.Thirsty.SpeedRating = "★☆☆☆☆"
SlashCoSlasher.Thirsty.EyeRating = "★★☆☆☆"
SlashCoSlasher.Thirsty.DiffRating = "★★★☆☆"

SlashCoSlasher.Thirsty.OnSpawn = function(slasher)
    slasher:SetViewOffset( Vector(0,0,20) )
    slasher:SetCurrentViewOffset( Vector(0,0,20) )
end

SlashCoSlasher.Thirsty.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Thirsty.OnTickBehaviour = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO

    v1 = slasher.SlasherValue1 --Milk drank
    v2 = slasher.SlasherValue2 --Pacification
    v3 = slasher.SlasherValue3 --Thirst
    v4 = slasher.SlasherValue4 --prowl speed
    v5 = slasher.SlasherValue5 --chase speed

    local eyesight_final = SlashCoSlasher.Thirsty.Eyesight
    local perception_final = SlashCoSlasher.Thirsty.Perception

    if v2 > 0 then --Thirsty is pacified

        slasher.SlasherValue3 = 0

        slasher.SlasherValue4 = 100
        slasher.SlasherValue5 = 100
        eyesight_final = 0
        perception_final = 0

        slasher.SlasherValue2 = v2 - (0.01 + (SO * 0.04))  
        slasher:SetNWBool("CanKill", false)
        slasher:SetNWBool("CanChase", false)
        slasher.SlasherValue3 = 0
        slasher:SetNWBool("DemonPacified", true)

    else --Thirsty is not pacified

        if v3 < 100 then slasher.SlasherValue3 = v3 + (FrameTime()/(2 - (SO/2))) end
        --Deplete thirst

        slasher.SlasherValue5 = 285 - ( v1 * 10)
        slasher.SlasherValue4 = 100 + ( (    ( v3 / (7 - v1)   )   ) + ( v1 * 20 )   )*(0.8+(SO*0.5))
        eyesight_final = 2 + (    ( v3 / (28.5 - (v1*4))   )   )  
        perception_final = 1.0 + (    ( v3 / (44.5 - (v1*8))   )   )  
        --Thirsty's basic stats raise the thirstier he is, and are also multiplied by how much milk he has drunk.
        --His chase speed is greatest at low milk drank, and the more he drinks, it is converted to prowl speed.

        slasher:SetNWBool("CanKill", true)
        slasher:SetNWBool("CanChase", true)
        slasher:SetNWBool("DemonPacified", false)

        if slasher:GetNWBool("InSlasherChaseMode") then 

            slasher:SetRunSpeed( slasher.SlasherValue5 )
            slasher:SetWalkSpeed( slasher.SlasherValue5 )
        else

            slasher:SetRunSpeed( slasher.SlasherValue4 )
            slasher:SetWalkSpeed( slasher.SlasherValue4 )

        end

    end

    slasher:SetNWInt("ThirstyThirst",math.floor( v3 ))

    if slasher:GetNWInt("ThirstyMilkDrank") ~= v1 then
        slasher:SetNWInt("ThirstyMilkDrank", v1)
    end

    slasher:SetNWFloat("Slasher_Eyesight", eyesight_final)
    slasher:SetNWInt("Slasher_Perception", perception_final)
end

SlashCoSlasher.Thirsty.OnPrimaryFire = function(slasher)
    SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Thirsty.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Thirsty.OnMainAbilityFire = function(slasher)

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO

    if slasher:GetEyeTrace().Entity:GetClass() == "sc_milkjug" then

        target = slasher:GetEyeTrace().Entity	

        if slasher:GetPos():Distance(target:GetPos()) < 150 and not slasher:GetNWBool("ThirstyDrinking") then

            slasher:SetNWBool("ThirstyDrinking", true)
            slasher:SetNWBool("InSlasherChaseMode", false) 
            slasher:StopSound(SlashCoSlasher[slasher:GetNWString("Slasher")].ChaseMusic)
            slasher.SlasherValue2 = 99
            slasher:Freeze(true)

            target:Remove()

            local matrix = slasher:GetBoneMatrix(slasher:LookupBone( "HandR" ))
            local pos = matrix:GetTranslation()
            local ang = matrix:GetAngles()

            local chugjug = ents.Create( "prop_physics" )

		    chugjug:SetMoveType( MOVETYPE_NONE )
            chugjug:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		    chugjug:SetModel( SlashCoItems.MilkJug.Model )
    	    chugjug:SetPos( pos )
    	    chugjug:SetAngles( ang )

            chugjug:FollowBone( slasher, slasher:LookupBone( "HandR" ) )

            timer.Simple(1, function() slasher:EmitSound("slashco/slasher/thirsty_drink.mp3") end)

            timer.Simple(4.5, function() 
                chugjug:Remove() 
            
                local emptyjug = ents.Create( "prop_physics" )
		        emptyjug:SetSolid( SOLID_VPHYSICS )
		        emptyjug:PhysicsInit( SOLID_VPHYSICS )
		        emptyjug:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
		        emptyjug:SetMoveType( MOVETYPE_VPHYSICS)
		        emptyjug:SetModel( SlashCoItems.MilkJug.Model )
    	        emptyjug:SetPos( pos )
    	        emptyjug:SetAngles( ang )
                emptyjug:Spawn()
                emptyjug:Activate()
                local phys = emptyjug:GetPhysicsObject()
	            if phys:IsValid() then phys:Wake() end
                phys:ApplyForceCenter( slasher:GetAimVector() * 450 )

                timer.Simple(4.5, function() 
                    emptyjug:Remove() 
                end)

            end)

            timer.Simple(8, function() 
                slasher:Freeze(false) 
                slasher:SetNWBool("ThirstyDrinking", false) 
                slasher:SetNWBool("DemonPacified", true)

                if slasher.SlasherValue1 < ( 4 + SatO) then
                    slasher.SlasherValue1 = slasher.SlasherValue1 + 1 + SatO
                end

                slasher.SlasherValue2 = math.random(20,35)

                if slasher.SlasherValue1 > 2 then
                    slasher:SetNWBool("ThirstyBigMlik", true)
                end
            end)
        end
    end

end

SlashCoSlasher.Thirsty.OnSpecialAbilityFire = function(slasher)

end



SlashCoSlasher.Thirsty.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")
    local pac = ply:GetNWBool("DemonPacified")

    if not ply:GetNWBool("ThirstyDrinking") then ply.anim_antispam = false end
	
	if ply:IsOnGround() then

		if not chase then 

			if not ply:GetNWBool("ThirstyBigMlik") then

				ply.CalcIdeal = ACT_HL2MP_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("prowl")

			else

				if not pac then

					ply.CalcIdeal = ACT_HL2MP_RUN 
					ply.CalcSeqOverride = ply:LookupSequence("chase2")

				else

					ply.CalcIdeal = ACT_HL2MP_WALK 
					ply.CalcSeqOverride = ply:LookupSequence("prowl")

				end

			end

		else
			ply.CalcIdeal = ACT_HL2MP_RUN 
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if ply:GetNWBool("ThirstyDrinking") then 
		
		ply.CalcSeqOverride = ply:LookupSequence("drink") 

		if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end
	
	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Thirsty.Footstep = function(ply)

    if SERVER then
        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Thirsty.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Thirsty") == true  then

            if LocalPlayer().thrs_f == nil then LocalPlayer().thrs_f = 0 end
            LocalPlayer().thrs_f = LocalPlayer().thrs_f+(FrameTime()*20)
            if LocalPlayer().thrs_f > 29 then LocalPlayer().thrs_f = 25 end

            local Overlay = Material("slashco/ui/overlays/jumpscare_5")
            Overlay:SetInt( "$frame", math.floor(LocalPlayer().thrs_f) )

            surface.SetDrawColor(255,255,255,255)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        else
            LocalPlayer().thrs_f = nil
        end

        if LocalPlayer():GetNWBool("ThirstyFuck") == true  then
            local Overlay = Material("slashco/ui/overlays/thirsty_fuck")
    
            surface.SetDrawColor(255,255,255,60)	
            surface.SetMaterial(Overlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    
            if c == nil then
                surface.PlaySound("slashco/slasher/thirsty_rage1.mp3")
                surface.PlaySound("slashco/slasher/thirsty_rage2.mp3")
                c = true
            end
    
        end

    end)

    local GasBack = Material("slashco/ui/gas_back")
	local MilkBase = Material("slashco/ui/milk_base")
	local GasTop = Material("slashco/ui/gas_top")

    SlashCoSlasher.Thirsty.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        local milk = 1 - ( LocalPlayer():GetNWInt("ThirstyThirst") /100)

		surface.SetMaterial(GasBack)
		surface.DrawTexturedRect((ScrW()/2) - ScrW()/16, (ScrH()/1.25)  - ScrW()/16, ScrW()/8, ScrW()/8)

		surface.SetMaterial(MilkBase)
		surface.DrawTexturedRectUV((ScrW()/2) - ScrW()/16	,		(ScrH()/1.25) - (		(ScrW()/8) * (1-milk) 	)	+	ScrW()/16, 	ScrW()/8	, (ScrW()/8 ) * (1-milk)		,0, milk, 1, 1 )

		surface.SetMaterial(GasTop)
		surface.DrawTexturedRect((ScrW()/2) - ScrW()/16, (ScrH()/1.25)  - ScrW()/16, ScrW()/8, ScrW()/8)

		draw.SimpleText( "R - Drink Milk (Drank: "..LocalPlayer():GetNWInt("ThirstyMilkDrank")..")", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Thirsty.ClientSideEffect = function()

    end

end

if SERVER then

    SlashCoSlasher.ThirstyRage = function(ply)

        local pos = ply:GetPos()
    
        for i = 1, #team.GetPlayers(TEAM_SLASHER) do
    
            local slasherid = team.GetPlayers(TEAM_SLASHER)[i]:SteamID64()
            local slasher = team.GetPlayers(TEAM_SLASHER)[i]
    
            if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID ~= 5 then return end
    
            if slasher:GetPos():Distance( pos ) > 1600 then return end
    
            slasher.SlasherValue1 = 6
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

end