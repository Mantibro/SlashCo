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
SlashCoSlasher.Dolphinman.ChaseSpeed = 295
SlashCoSlasher.Dolphinman.Perception = 1.0
SlashCoSlasher.Dolphinman.Eyesight = 3
SlashCoSlasher.Dolphinman.KillDistance = 135
SlashCoSlasher.Dolphinman.ChaseRange = 1000
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


    slasher:SetNWFloat("Slasher_Eyesight", SlashCoSlasher.Dolphinman.Eyesight)
    slasher:SetNWInt("Slasher_Perception", SlashCoSlasher.Dolphinman.Perception)
end

SlashCoSlasher.Dolphinman.OnPrimaryFire = function(slasher)
    SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Dolphinman.OnSecondaryFire = function(slasher)

end

SlashCoSlasher.Dolphinman.OnMainAbilityFire = function(slasher)

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

        return willdrawkill, willdrawchase, willdrawmain

    end

    SlashCoSlasher.Dolphinman.ClientSideEffect = function()

    end

end