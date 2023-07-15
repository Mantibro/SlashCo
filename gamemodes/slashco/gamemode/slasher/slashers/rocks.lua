SlashCoSlasher.Rocks = {}

SlashCoSlasher.Rocks.Name = "Rocks"
SlashCoSlasher.Rocks.ID = "rocks"
SlashCoSlasher.Rocks.Class = 1
SlashCoSlasher.Rocks.DangerLevel = 1
SlashCoSlasher.Rocks.IsSelectable = true
SlashCoSlasher.Rocks.Model = "models/slashco/slashers/covenant/rocks.mdl"
SlashCoSlasher.Rocks.GasCanMod = 0
SlashCoSlasher.Rocks.KillDelay = 3
SlashCoSlasher.Rocks.ProwlSpeed = 150
SlashCoSlasher.Rocks.ChaseSpeed = 297
SlashCoSlasher.Rocks.Perception = 1.0
SlashCoSlasher.Rocks.Eyesight = 3
SlashCoSlasher.Rocks.KillDistance = 135
SlashCoSlasher.Rocks.ChaseRange = 1000
SlashCoSlasher.Rocks.ChaseRadius = 0.7
SlashCoSlasher.Rocks.ChaseDuration = 160.0
SlashCoSlasher.Rocks.ChaseCooldown = 1
SlashCoSlasher.Rocks.JumpscareDuration = 1.5
SlashCoSlasher.Rocks.ChaseMusic = ""
SlashCoSlasher.Rocks.KillSound = ""
SlashCoSlasher.Rocks.Description = ""
SlashCoSlasher.Rocks.ProTip = ""
SlashCoSlasher.Rocks.SpeedRating = "★★★★★"
SlashCoSlasher.Rocks.EyeRating = "★★☆☆☆"
SlashCoSlasher.Rocks.DiffRating = "★★★☆☆"

SlashCoSlasher.Rocks.OnSpawn = function(slasher)

end

SlashCoSlasher.Rocks.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.Rocks.OnTickBehaviour = function(slasher)


    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Rocks.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Rocks.Perception)
end

SlashCoSlasher.Rocks.OnPrimaryFire = function(slasher)
    --SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Rocks.OnSecondaryFire = function(slasher)
    --SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.Rocks.OnMainAbilityFire = function(slasher)

end


SlashCoSlasher.Rocks.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.Rocks.Animator = function(ply) 

    local chase = ply:GetNWBool("InSlasherChaseMode")

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

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.Rocks.Footstep = function(ply)

    if SERVER then


        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    SlashCoSlasher.Rocks.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Rocks.ClientSideEffect = function()

    end

end