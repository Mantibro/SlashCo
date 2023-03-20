local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

SlashCo.SlasherMainAbility = function(slasher)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO
    local SatO = SlashCo.CurRound.OfferingData.SatO

    --Amogus Human Transform \/ \/ \/
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 4 then goto THIRSTY end

    if not slasher:GetNWBool("AmogusDisguising") and v2 < 0.01 and not slasher:GetNWBool("AmogusSurvivorDisguise") and not slasher:GetNWBool("AmogusDisguised") then

        slasher:SetNWBool("AmogusDisguising", true)
        slasher:Freeze(true)

        slasher:EmitSound("slashco/slasher/amogus_transform"..math.random(1,2)..".mp3")

        timer.Simple(2, function() 
            slasher:Freeze(false) 
            slasher:SetNWBool("AmogusDisguising", false)
            slasher.SlasherValue2 = 2

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

        slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )

        SlashCoSlasher[slasher:GetNWBool("Slasher")].KillDelayTick = 2 - (SO * 1.95) 

        if IsValid(ents.GetByIndex(slasher.SlasherValue3)) then

            ents.GetByIndex(slasher.SlasherValue3):Remove()

        end

        timer.Simple(2 - (SO * 1.95), function() 
            slasher:Freeze(false) 
            slasher.SlasherValue2 = 2.5 - (SO * 2.4)
        end)

    end

    --Amogus Human Transform /\ /\ /\

    ::THIRSTY::

    --Thirsty's Milk Drinking \/ \/ \/
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 5 then goto MALE07 end

    if slasher:GetEyeTrace().Entity:GetClass() == "sc_milkjug" then

        target = slasher:GetEyeTrace().Entity	

        if slasher:GetPos():Distance(target:GetPos()) < 150 and not slasher:GetNWBool("ThirstyDrinking") then

            slasher:SetNWBool("ThirstyDrinking", true)
            slasher:SetNWBool("InSlasherChaseMode", false) 
            slasher:StopSound(SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseMusic)
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
    --Thirsty's Milk Drinking /\ /\ /\

    ::MALE07::
    --Male07's State Switch \/ \/ \/
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 6 then goto TYLER end

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

            SlashCoSlasher[slasher:GetNWBool("Slasher")].CurrentChaseTick = 0

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

    --Male07's State Switch /\ /\ /\

    ::TYLER::
    --Tyler's State Switch \/ \/ \/
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 7 then goto MANSPIDER end

    if slasher.SlasherValue1 == 0 then

        slasher.SlasherValue1 = 1

        --local song = math.random(1,6)

        slasher:SetColor(Color(255,255,255,255))
        slasher:DrawShadow(true)
		slasher:SetRenderMode(RENDERMODE_TRANSCOLOR)
		slasher:SetNoDraw(false)

        --PlayGlobalSound("slashco/slasher/tyler_song_"..song..".mp3", 90 - (math.sqrt(slasher.SlasherValue3) * (25 / SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE)), slasher, 0.8 - (slasher.SlasherValue3 * 0.05))

        --slasher.TylerSong = CreateSound( slasher, "slashco/slasher/tyler_song_"..song..".mp3")
        --slasher.TylerSong:SetSoundLevel( 85 - (math.sqrt(slasher.SlasherValue3) * (25 / SlashCo.Maps[SlashCo.ReturnMapIndex()].SIZE)) )
        --slasher.TylerSong:ChangeVolume( 0.8 - (slasher.SlasherValue3 * 0.05))

    end

    --Tyler's State Switch /\ /\ /\

    --Borgmire has no main ability

    ::MANSPIDER::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 9 then goto WATCHER end

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

            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
            slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )
            slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")].ProwlSpeed )

        end

    end

    ::WATCHER::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 10 then goto ABOMIGNAT end

        if slasher.SlasherValue2 > 0 then return end
        if slasher:GetNWBool("WatcherRage") then return end

        slasher.SlasherValue1 = 10 + (SO * 10)
        slasher.SlasherValue2 = 100 - (SO * 35)

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
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 11 then goto FREESMILEY end

    if slasher:GetNWBool("AbomignatCrawling") then 
        slasher:SetNWBool("AbomignatCrawling",false) 
        SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseCooldown
        return 
    end

    if slasher:GetNWBool("InSlasherChaseMode") then return end
    if slasher:GetNWBool("AbomignatSlashing") then return end
    if slasher:GetNWBool("AbomignatLunging") then return end
    if slasher:GetNWBool("AbomignatLungeFinish") then return end
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].ChaseActivationCooldown > 0 then return end

    if not slasher:GetNWBool("AbomignatCrawling") then slasher:SetNWBool("AbomignatCrawling",true) end

    ::FREESMILEY::
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 13 then goto BREN end

    if slasher:GetNWBool("FreeSmileySummoning") then return end
    if slasher.SlasherValue1 > 0 then return end

    if slasher.SlasherValue2 == 0 then slasher.SlasherValue2 = 1 return end
    if slasher.SlasherValue2 == 1 then slasher.SlasherValue2 = 0 return end

    ::BREN::

end