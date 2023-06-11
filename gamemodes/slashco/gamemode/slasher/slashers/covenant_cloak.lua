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

SlashCoSlasher.CovenantCloak.OnTickBehaviour = function(slasher)


    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.CovenantCloak.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.CovenantCloak.Perception)
end

SlashCoSlasher.CovenantCloak.OnPrimaryFire = function(slasher)
    --SlashCo.Jumpscare(slasher)
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

    --zombie_leap_mid
    --zombie_slump_rise_02_slow

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