SlashCoSlasher.Princess = {}

SlashCoSlasher.Princess.Name = "Princess"
SlashCoSlasher.Princess.ID = 17
SlashCoSlasher.Princess.Class = 2
SlashCoSlasher.Princess.DangerLevel = 1
SlashCoSlasher.Princess.IsSelectable = true
SlashCoSlasher.Princess.Model = "models/slashco/slashers/princess/princess.mdl"
SlashCoSlasher.Princess.GasCanMod = 0
SlashCoSlasher.Princess.KillDelay = 3
SlashCoSlasher.Princess.ProwlSpeed = 150
SlashCoSlasher.Princess.ChaseSpeed = 290
SlashCoSlasher.Princess.Perception = 1.0
SlashCoSlasher.Princess.Eyesight = 3
SlashCoSlasher.Princess.KillDistance = 135
SlashCoSlasher.Princess.ChaseRange = 1000
SlashCoSlasher.Princess.ChaseRadius = 0.91
SlashCoSlasher.Princess.ChaseDuration = 10.0
SlashCoSlasher.Princess.ChaseCooldown = 3
SlashCoSlasher.Princess.JumpscareDuration = 1.5
SlashCoSlasher.Princess.ChaseMusic = "slashco/slasher/"
SlashCoSlasher.Princess.KillSound = "slashco/slasher/"
SlashCoSlasher.Princess.Description = [[The Feral Slasher who mauls children.

-Princess can increase his aggression during chase, but up to a threshold.
-The Agression Threshold can be increased by mauling Babies, which will reset your Aggression.
-The higher your aggression, the faster and more brutal your chase is.]]
SlashCoSlasher.Princess.ProTip = "-This Slasher can be distracted with Babies."
SlashCoSlasher.Princess.SpeedRating = "★★★★☆"
SlashCoSlasher.Princess.EyeRating = "★★☆☆☆"
SlashCoSlasher.Princess.DiffRating = "★★☆☆☆"

SlashCoSlasher.Princess.OnSpawn = function(slasher)
    slasher:SetViewOffset( Vector(0,0,50) )
    slasher:SetCurrentViewOffset( Vector(0,0,50) )
    slasher:SetNWBool("CanChase", true)

    slasher.SlasheValue2 = 50

    SlashCoSlasher.Princess.DoSound(slasher)
end

SlashCoSlasher.Princess.DoSound = function(slasher)

    if not slasher:GetNWBool("PrincessMaulingChild") then

        if slasher:GetNWBool("InSlasherChaseMode") then
            slasher:EmitSound("slashco/slasher/princess_chase"..math.random(1,15)..".mp3")
        else
            slasher:EmitSound("slashco/slasher/princess_idle"..math.random(1,9)..".mp3")
        end

    end

    timer.Simple(2, function() SlashCoSlasher.Princess.DoSound(slasher) end)
end

SlashCoSlasher.Princess.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Princess.OnTickBehaviour = function(slasher)

    v1 = slasher.SlasheValue1 --aggression
    v2 = slasher.SlasheValue2 --aggression threshold

    local SO = SlashCo.CurRound.OfferingData.SO

    --find children to maul
    if slasher:GetNWBool("InSlasherChaseMode") then
        for _, v in ipairs(ents.FindByClass("sc_baby")) do
            
            if v:GetPos():Distance( slasher:GetPos() ) < 100 then --mauling child
                SlashCo.StopChase(slasher)
                slasher:SetNWBool("PrincessMaulingChild", true)
                slasher:Freeze(true)

                slasher:EmitSound("slashco/slasher/princess_maul.mp3")

                --baby in jaw

                local matrix = slasher:GetBoneMatrix(slasher:LookupBone( "head" ))
                local pos = matrix:GetTranslation()
                local ang = matrix:GetAngles()

                pos:Add( Vector(22,-13,-52) )
                ang:Add( Angle(90,90,0) )

                local mauled_child = ents.Create( "prop_physics" )

                mauled_child:SetMoveType( MOVETYPE_NONE )
                mauled_child:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
                mauled_child:SetModel( SlashCoItems.Baby.Model )
                mauled_child:SetPos( pos )
                mauled_child:SetAngles( ang )
                mauled_child:FollowBone( slasher, slasher:LookupBone( "head" ) )

                for i = 1, math.random(9,12) do
                    timer.Simple((i/3.5)*(0.7+(math.random()*0.3)), function() 
                        local vPoint = mauled_child:GetPos()
                        local bloodfx = EffectData()
                        bloodfx:SetOrigin( vPoint )
                        util.Effect( "BloodImpact", bloodfx )

                        slasher:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(2,4)..".wav")
                    end)
                end

                timer.Simple(3.75, function() 

                    local vPoint = mauled_child:GetPos()
                    local bloodfx = EffectData()
                    bloodfx:SetOrigin( vPoint )
                    util.Effect( "BloodImpact", bloodfx )

                    slasher:EmitSound("physics/body/body_medium_break"..math.random(2,4)..".wav")

                    mauled_child:Remove() 
                end)


                ---yeah

                timer.Simple(4.5, function() 
                
                    slasher:Freeze(false)
                    slasher:SetNWBool("PrincessMaulingChild", false)
                
                end)

            end

        end
    end

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Princess.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Princess.Perception)
end

SlashCoSlasher.Princess.OnPrimaryFire = function(slasher)
    --SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Princess.OnSecondaryFire = function(slasher)
    SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Princess.OnMainAbilityFire = function(slasher)

end


SlashCoSlasher.Princess.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.Princess.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")
    local maul_child = ply:GetNWBool("PrincessMaulingChild")

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

    if maul_child  then

		ply.CalcSeqOverride = ply:LookupSequence("maul_child")
		ply:SetPlaybackRate( 1 )
		if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end

    else

        ply.anim_antispam = false

	end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Princess.Footstep = function(ply)

    if SERVER then


        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.Princess.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_Princess") == true  then


            
        end

    end)

    SlashCoSlasher.Princess.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = false
        local willdrawchase = true
        local willdrawmain = true

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Princess.ClientSideEffect = function()

    end

end