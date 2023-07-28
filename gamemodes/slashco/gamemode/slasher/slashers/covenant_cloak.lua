SlashCoSlasher.CovenantCloak = {}

SlashCoSlasher.CovenantCloak.Name = "Covenant Cloak"
SlashCoSlasher.CovenantCloak.ID = "covenantcloak"
SlashCoSlasher.CovenantCloak.Class = 1
SlashCoSlasher.CovenantCloak.DangerLevel = 1
SlashCoSlasher.CovenantCloak.IsSelectable = false
SlashCoSlasher.CovenantCloak.Model = "models/slashco/slashers/covenant/cloak.mdl"
SlashCoSlasher.CovenantCloak.GasCanMod = 0
SlashCoSlasher.CovenantCloak.KillDelay = 3
SlashCoSlasher.CovenantCloak.ProwlSpeed = 100
SlashCoSlasher.CovenantCloak.ChaseSpeed = 297
SlashCoSlasher.CovenantCloak.Perception = 1.0
SlashCoSlasher.CovenantCloak.Eyesight = 5
SlashCoSlasher.CovenantCloak.KillDistance = 135
SlashCoSlasher.CovenantCloak.ChaseRange = 1000
SlashCoSlasher.CovenantCloak.ChaseRadius = 0.91
SlashCoSlasher.CovenantCloak.ChaseDuration = 10.0
SlashCoSlasher.CovenantCloak.ChaseCooldown = 1
SlashCoSlasher.CovenantCloak.JumpscareDuration = 1.5
SlashCoSlasher.CovenantCloak.ChaseMusic = ""
SlashCoSlasher.CovenantCloak.KillSound = ""
SlashCoSlasher.CovenantCloak.Description = ""
SlashCoSlasher.CovenantCloak.ProTip = ""
SlashCoSlasher.CovenantCloak.SpeedRating = "★☆☆☆☆"
SlashCoSlasher.CovenantCloak.EyeRating = "★☆☆☆☆"
SlashCoSlasher.CovenantCloak.DiffRating = "★☆☆☆☆"

SlashCoSlasher.CovenantCloak.OnSpawn = function(slasher)

end

SlashCoSlasher.CovenantCloak.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.CovenantCloak.TackleFail = function(slasher)

    if IsValid( slasher ) then
        if slasher.TackledPlayer == nil then
            slasher:SetNWBool("CloakTackleFail", true)
            slasher:Freeze(true)

            timer.Simple(2.5, function() 
                slasher:SetNWBool("CloakTackle", false)
                slasher:SetNWBool("CloakTackleFail", false)
                slasher:Freeze(false)
            end)

        end
    end

end

SlashCoSlasher.CovenantCloak.OnTickBehaviour = function(slasher, target)

    if IsValid( slasher.TackledPlayer ) then
        if not slasher:IsFrozen() then
            slasher:Freeze( true )
        end

        if not slasher.TackledPlayer:IsFrozen() then
            slasher.TackledPlayer:Freeze( true )
        end

        slasher:SetPos( slasher.TackledPlayer:GetPos() + Vector(10,0,0) )

        if slasher.TackledPlayer.TackleStruggle ~= nil and slasher.TackledPlayer.TackleStruggle > 100 then
            slasher.TackledPlayer.TackleStruggle = 0
            slasher.TackledPlayer:Freeze( false )
            slasher.TackledPlayer:SetNWBool("SurvivorTackled", false)
            slasher:SetPos( slasher.TackledPlayer:GetPos() + Vector(0,0,80) )
            slasher.TackledPlayer = nil
        end
    end

    if slasher:GetNWBool("CloakTackling") then
        if slasher:IsOnGround() then 
            slasher:SetVelocity(slasher:GetForward() * 70) 
        end

        if IsValid(target) and target:IsPlayer() and target:Team() == TEAM_SURVIVOR and target:GetPos():Distance( slasher:GetPos() ) < 100 then
            slasher.TackledPlayer = target
            slasher:SetNWBool("CloakTackling", false)

            slasher.TackledPlayer:SetNWBool("SurvivorTackled", true)
            slasher:SetNWInt("CloakTacklePosition", 1)
        end

        if IsValid(target) and target:GetPos():Distance( slasher:GetPos() ) < 120 then
            slasher:SlamDoor(target)
        end

    elseif slasher:GetNWBool("CloakTackle") and slasher.TackledPlayer == nil and not slasher:GetNWBool("CloakTackleFail") then

        slasher:SetNWInt("CloakTacklePosition", 0)
        SlashCoSlasher.CovenantCloak.TackleFail(slasher)

    end

    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.CovenantCloak.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.CovenantCloak.Perception)
end

SlashCoSlasher.CovenantCloak.OnPrimaryFire = function(slasher)
    if not slasher:GetNWBool("CloakTackle") then
        slasher:SetNWBool("CloakTackle", true)
        slasher:SetNWBool("CloakTackling", true)
        slasher.TackledPlayer = nil

        if slasher:IsOnGround() then 
            slasher:SetVelocity(slasher:GetForward() * 500) 
        end

        slasher:Freeze(true)

        timer.Simple(0.5, function() 
            slasher:SetNWBool("CloakTackling", false)
            --SlashCoSlasher.CovenantCloak.TackleFail(slasher)
        end)
    end
end

SlashCoSlasher.CovenantCloak.OnSecondaryFire = function(slasher)
    --SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.CovenantCloak.OnMainAbilityFire = function(slasher)

end


SlashCoSlasher.CovenantCloak.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.CovenantCloak.Animator = function(ply, veloc) 

    local chase = ply:GetNWBool("InSlasherChaseMode")

    if ply:IsOnGround() then

        if ply:GetVelocity():Length() > 0 then

            if not chase then 
                ply.CalcSeqOverride = ply:LookupSequence("walk_all")
            else
                ply.CalcIdeal = ACT_HL2MP_RUN 
                ply.CalcSeqOverride = ply:LookupSequence("run_all_02")
            end

        else

            ply.CalcSeqOverride = ply:LookupSequence("menu_combine")

        end

    else

        ply.CalcSeqOverride = ply:LookupSequence("jump_slam")

    end

    if ply:GetNWBool("CloakTackling") then
        ply.CalcSeqOverride = ply:LookupSequence("zombie_leap_mid")
    end

    if ply:GetNWBool("CloakTackleFail") then
        ply.CalcSeqOverride = ply:LookupSequence("zombie_slump_rise_01")
        if ply.anim_antispam == nil or ply.anim_antispam == false then ply:SetCycle( 0 ) ply.anim_antispam = true end
    else
        ply.anim_antispam = false 
    end

    if ply:GetNWInt("CloakTacklePosition") > 0 then
        ply.CalcSeqOverride = ply:LookupSequence("zombie_slump_rise_02_slow")
        ply:SetCycle( 0.6 )
    end

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.CovenantCloak.Footstep = function(ply)

    if SERVER then
        return false 
    end

    if CLIENT then
		return false 
    end

end

if CLIENT then

    SlashCoSlasher.CovenantCloak.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.CovenantCloak.ClientSideEffect = function()

    end

end