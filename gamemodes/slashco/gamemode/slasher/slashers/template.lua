SlashCoSlasher.ZYZZ = {}

SlashCoSlasher.ZYZZ.Name = "ZYZZ"
SlashCoSlasher.ZYZZ.ID = 0
SlashCoSlasher.ZYZZ.Class = 1
SlashCoSlasher.ZYZZ.DangerLevel = 1
SlashCoSlasher.ZYZZ.IsSelectable = true
SlashCoSlasher.ZYZZ.Model = "models/slashco/slashers/"
SlashCoSlasher.ZYZZ.GasCanMod = 0
SlashCoSlasher.ZYZZ.KillDelay = 3
SlashCoSlasher.ZYZZ.ProwlSpeed = 150
SlashCoSlasher.ZYZZ.ChaseSpeed = 295
SlashCoSlasher.ZYZZ.Perception = 1.0
SlashCoSlasher.ZYZZ.Eyesight = 5
SlashCoSlasher.ZYZZ.KillDistance = 135
SlashCoSlasher.ZYZZ.ChaseRange = 1000
SlashCoSlasher.ZYZZ.ChaseRadius = 0.91
SlashCoSlasher.ZYZZ.ChaseDuration = 10.0
SlashCoSlasher.ZYZZ.ChaseCooldown = 3
SlashCoSlasher.ZYZZ.JumpscareDuration = 1.5
SlashCoSlasher.ZYZZ.ChaseMusic = "slashco/slasher/"
SlashCoSlasher.ZYZZ.KillSound = "slashco/slasher/"
SlashCoSlasher.ZYZZ.Description = ""
SlashCoSlasher.ZYZZ.ProTip = ""
SlashCoSlasher.ZYZZ.SpeedRating = "★☆☆☆☆"
SlashCoSlasher.ZYZZ.EyeRating = "★☆☆☆☆"
SlashCoSlasher.ZYZZ.DiffRating = "★☆☆☆☆"

SlashCoSlasher.ZYZZ.OnSpawn = function(slasher)

end

SlashCoSlasher.ZYZZ.PickUpAttempt = function(ply)
    return false
end

SlashCoSlasher.ZYZZ.OnTickBehaviour = function(slasher)


    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.ZYZZ.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.ZYZZ.Perception)
end

SlashCoSlasher.ZYZZ.OnPrimaryFire = function(slasher, target)
    --SlashCo.Jumpscare(slasher, target)
end

SlashCoSlasher.ZYZZ.OnSecondaryFire = function(slasher)
    --SlashCo.StartChaseMode(slasher)
end

SlashCoSlasher.ZYZZ.OnMainAbilityFire = function(slasher)

end


SlashCoSlasher.ZYZZ.OnSpecialAbilityFire = function(slasher)

end

SlashCoSlasher.ZYZZ.Animator = function(ply) 

   

    return ply.CalcIdeal, ply.CalcSeqOverride

end

SlashCoSlasher.ZYZZ.Footstep = function(ply)

    if SERVER then


        return true 
    end

    if CLIENT then
		return true 
    end

end

if CLIENT then

    hook.Add("HUDPaint", SlashCoSlasher.ZYZZ.Name.."_Jumpscare", function()

        if LocalPlayer():GetNWBool("SurvivorJumpscare_ZYZZ") == true  then


            
        end

    end)

    SlashCoSlasher.ZYZZ.UserInterface = function(cx, cy, mainiconposx, mainiconposy)

        local willdrawkill = true
        local willdrawchase = true
        local willdrawmain = true

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.ZYZZ.ClientSideEffect = function()

    end

end