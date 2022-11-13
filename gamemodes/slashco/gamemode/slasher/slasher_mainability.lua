local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

SlashCo.SlasherMainAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO

    --Bababooey's Invisibility ability \/ \/ \/

    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 1 then goto SID end

do --To Prevent local value jump error
    local cooldown = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1

    if cooldown > 0 then return end
    if slasher:GetNWBool("InSlasherChaseMode") then return end

    slasher:SetNWBool("BababooeyInvisibility", not slasher:GetNWBool("BababooeyInvisibility")) 

    if slasher:GetNWBool("BababooeyInvisibility") then --Turning invisible

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 4
        slasher:EmitSound("slashco/slasher/baba_hide.mp3")

        timer.Simple(1, function() --Delay for entering invisibility

			slasher:SetMaterial("Models/effects/vol_light001")
		    slasher:SetColor(Color(0,0,0,0))

            PlayGlobalSound("slashco/slasher/bababooey_loud.mp3", 130, slasher)

            slasher:SetRunSpeed( 250 )
            slasher:SetWalkSpeed( 250 )

        end)

    else

        slasher:EmitSound("slashco/slasher/baba_reveal.mp3")

        --Spook Appear
        if slasher:GetEyeTrace().Entity:IsPlayer() then

            target = slasher:GetEyeTrace().Entity	

            if target:Team() ~= TEAM_SURVIVOR then goto SKIP end

            if slasher:GetPos():Distance(target:GetPos()) < 150 then
  
                slasher:SetNWBool("BababooeySpooking", true)
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 2
                slasher:EmitSound("slashco/slasher/baba_scare.mp3",100)
                slasher:Freeze(true)
                timer.Simple(2.5, function() slasher:Freeze(false) end)

                goto SPOOKAPPEAR
            else 
                goto SKIP
            end
        else 
            goto SKIP  
        end
        ::SKIP::

        --Quiet appear
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = math.random(3,(13 - (SO * 6)))
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 8

        ::SPOOKAPPEAR::

        slasher:SetMaterial("")
		slasher:SetColor(Color(255,255,255,255))

        slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )

    end

end --ends here

    --Bababooey's Invisibility ability /\ /\ /\

    ::SID::

    --Sid's Cookie Eating \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 2 then goto AMOGUS end

    if slasher:GetEyeTrace().Entity:GetClass() == "sc_cookie" then

        target = slasher:GetEyeTrace().Entity	

        if slasher:GetPos():Distance(target:GetPos()) < 150 and not slasher:GetNWBool("SidEating") and not slasher:GetNWBool("SidGun")  then

            slasher:SetNWBool("SidEating", true)
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 99
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
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 + 1 + SatO
                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = math.random(15,25)
                target:Remove()
            end)
        end
    end

    --Sid's Cookie Eating /\ /\ /\

    --Trollge has no main ability

    ::AMOGUS::

    --Amogus Human Transform \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 4 then goto THIRSTY end

    if not slasher:GetNWBool("AmogusDisguising") and v2 < 0.01 and not slasher:GetNWBool("AmogusSurvivorDisguise") and not slasher:GetNWBool("AmogusDisguised") then

        slasher:SetNWBool("AmogusDisguising", true)
        slasher:Freeze(true)

        slasher:EmitSound("slashco/slasher/amogus_transform"..math.random(1,2)..".mp3")

        timer.Simple(2, function() 
            slasher:Freeze(false) 
            slasher:SetNWBool("AmogusDisguising", false)
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2

            slasher:SetNWBool("AmogusSurvivorDisguise", true)
            slasher:SetNWBool("AmogusDisguised", true)

            slasher:EmitSound("slashco/slasher/amogus_sus.mp3")


            local s = team.GetPlayers(TEAM_SURVIVOR)
            local modelname = "models/slashco/survivor/male_01.mdl"
            if #s > 0 then
	            modelname = s[math.random(1,#s)]:GetModel()
            end
	        util.PrecacheModel( modelname )
	        slasher:SetModel( modelname )

            slasher:SetRunSpeed( 300 )
            slasher:SetWalkSpeed( 200 )

        end)

    elseif not slasher:GetNWBool("AmogusDisguising") and v2 < 0.01 and slasher:GetNWBool("AmogusDisguised") then

        slasher:Freeze(true)
        slasher:SetNWBool("AmogusSurvivorDisguise", false)
        slasher:SetNWBool("AmogusFuelDisguise", false)
        slasher:SetNWBool("AmogusDisguised", false)
        slasher:EmitSound("slashco/slasher/amogus_reveal.mp3")
        slasher:SetNWBool("DynamicFlashlight", false)

        util.PrecacheModel( "models/slashco/slashers/amogus/amogus.mdl" )
	    slasher:SetModel( "models/slashco/slashers/amogus/amogus.mdl" )

        slasher:SetColor(Color(255,255,255,255))
        slasher:DrawShadow(true)
		slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		slasher:SetNoDraw(false)

        slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )

        SlashCo.CurRound.SlasherData[slasherid].KillDelayTick = 2 - (SO * 1.95) 

        if IsValid(ents.GetByIndex(SlashCo.CurRound.SlasherData[slasherid].SlasherValue3)) then

            ents.GetByIndex(SlashCo.CurRound.SlasherData[slasherid].SlasherValue3):Remove()

        end

        timer.Simple(2 - (SO * 1.95), function() 
            slasher:Freeze(false) 
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 2.5 - (SO * 2.4)
        end)

    end

    --Amogus Human Transform /\ /\ /\

    ::THIRSTY::

    --Thirsty's Milk Drinking \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 5 then goto MALE07 end

    if slasher:GetEyeTrace().Entity:GetClass() == "sc_milkjug" then

        target = slasher:GetEyeTrace().Entity	

        if slasher:GetPos():Distance(target:GetPos()) < 150 and not slasher:GetNWBool("ThirstyDrinking") then

            slasher:SetNWBool("ThirstyDrinking", true)
            slasher:SetNWBool("InSlasherChaseMode", false) 
            slasher:StopSound(SlashCo.CurRound.SlasherData[slasherid].ChaseMusic)
            SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 99
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

                if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 < ( 4 + SatO) then
                    SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 + 1 + SatO
                end

                SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = math.random(20,35)

                if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 > 2 then
                    slasher:SetNWBool("ThirstyBigMlik", true)
                end
            end)
        end
    end
    --Thirsty's Milk Drinking /\ /\ /\

    ::MALE07::
    --Male07's State Switch \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 6 then goto TYLER end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 > 0 or slasher:GetNWBool("InSlasherChaseMode") then return end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 == 0 and slasher:GetEyeTrace().Entity:GetClass() == "sc_maleclone" then

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

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 1

            SlashCo.CurRound.SlasherData[slasherid].CurrentChaseTick = 0

            SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 3

            slasher:SetWalkSpeed(100)
            slasher:SetRunSpeed(100)

            return

        end

    end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 > 0 then

        local modelname = "models/hunter/plates/plate.mdl"
	    util.PrecacheModel( modelname )
	    slasher:SetModel( modelname )

        slasher:SetColor(Color(0,0,0,0))
        slasher:DrawShadow(false)
		slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
		slasher:SetNoDraw(true)
        slasher:SetPos(slasher:GetPos() + Vector(0,0,60))

        SlashCo.CreateItem("sc_maleclone",slasher:GetPos(),slasher:GetAngles())

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 0

        slasher:EmitSound("slashco/slasher/male07_unpossess"..math.random(1,2)..".mp3")

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 = 3

        slasher:SetWalkSpeed(300)
        slasher:SetRunSpeed(300)

        return

    end

    --Male07's State Switch /\ /\ /\

    ::TYLER::
    --Tyler's State Switch \/ \/ \/
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 7 then goto MANSPIDER end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 == 0 then

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 1

        --local song = math.random(1,6)

        slasher:SetColor(Color(255,255,255,255))
        slasher:DrawShadow(true)
		slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		slasher:SetNoDraw(false)

        --PlayGlobalSound("slashco/slasher/tyler_song_"..song..".mp3", 90 - (math.sqrt(SlashCo.CurRound.SlasherData[slasherid].SlasherValue3) * (25 / SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE)), slasher, 0.8 - (SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 * 0.05))

        --slasher.TylerSong = CreateSound( slasher, "slashco/slasher/tyler_song_"..song..".mp3")
        --slasher.TylerSong:SetSoundLevel( 85 - (math.sqrt(SlashCo.CurRound.SlasherData[slasherid].SlasherValue3) * (25 / SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE)) )
        --slasher.TylerSong:ChangeVolume( 0.8 - (SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 * 0.05))

    end

    --Tyler's State Switch /\ /\ /\

    --Borgmire has no main ability

    ::MANSPIDER::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 9 then goto WATCHER end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 ~= "" then return end

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

        if SlashCo.CurRound.SlasherData[slasherid].SlasherValue3 > 100 then

            slasher:SetNWBool("ManspiderNested", false)

            slasher:SetRunSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )
            slasher:SetSlowWalkSpeed( SlashCo.CurRound.SlasherData[slasherid].ProwlSpeed )

        end

    end

    ::WATCHER::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 10 then goto ABOMIGNAT end

        if SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 > 0 then return end
        if slasher:GetNWBool("WatcherRage") then return end

        SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 = 10 + (SO * 10)
        SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 100 - (SO * 35)

        PlayGlobalSound("slashco/slasher/watcher_locate.mp3", 100, slasher, 1)

        for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do
            local p = team.GetPlayers(TEAM_SURVIVOR)[i]
            p:SetNWBool("WatcherSurveyed", true)
            p:EmitSound("slashco/slasher/watcher_see.mp3")
        end

        timer.Simple(5 + (SO*5), function() 
        
            for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do
                local p = team.GetPlayers(TEAM_SURVIVOR)[i]
                p:SetNWBool("WatcherSurveyed", false)
            end
        
        end)

    ::ABOMIGNAT::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 11 then goto FREESMILEY end

    if slasher:GetNWBool("AbomignatCrawling") then 
        slasher:SetNWBool("AbomignatCrawling",false) 
        SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown = SlashCo.CurRound.SlasherData[slasherid].ChaseCooldown
        return 
    end

    if slasher:GetNWBool("InSlasherChaseMode") then return end
    if slasher:GetNWBool("AbomignatSlashing") then return end
    if slasher:GetNWBool("AbomignatLunging") then return end
    if slasher:GetNWBool("AbomignatLungeFinish") then return end
    if SlashCo.CurRound.SlasherData[slasherid].ChaseActivationCooldown > 0 then return end

    if not slasher:GetNWBool("AbomignatCrawling") then slasher:SetNWBool("AbomignatCrawling",true) end

    ::FREESMILEY::
    if SlashCo.CurRound.SlasherData[slasherid].SlasherID ~= 13 then goto BREN end

    if slasher:GetNWBool("FreeSmileySummoning") then return end
    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue1 > 0 then return end

    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 == 0 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 1 return end
    if SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 == 1 then SlashCo.CurRound.SlasherData[slasherid].SlasherValue2 = 0 return end

    ::BREN::

end