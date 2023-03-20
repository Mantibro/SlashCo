local SlashCo = SlashCo

--[[SlashCo.SlasherCallForChaseMode = function(ply)

    if type( SlashCoSlasher[ply:GetNWString("Slasher")].OnSecondaryFire ) ~= "function" then return end

    SlashCoSlasher[ply:GetNWString("Slasher")].OnSecondaryFire(ply)

    local slasherid = slasher:SteamID64()

    local SO = SlashCo.CurRound.OfferingData.SO

    if slasher:GetNWBool("SidGunEquipped") then goto sidaim end

    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID == 12 then goto crimclone end

    ::sidaim::
do
    if not slasher:GetNWBool("SidGunEquipped") then return end
    local gunrage = slasher:GetNWBool("SidGunRage")

    if not slasher:GetNWBool("SidGunAimed") and not slasher:GetNWBool("SidGunAiming") and SlashCoSlasher[slasher:GetNWBool("Slasher")]SlasherValue3 < 0.01 then

        slasher:SetNWBool("SidGunAiming", true)
        SlashCoSlasher[slasher:GetNWBool("Slasher")]SlasherValue3 = 2
        slasher:SetSlowWalkSpeed( 1 )  
        slasher:SetWalkSpeed( 1 )
        slasher:SetRunSpeed( 1 )
        slasher:EmitSound("slashco/slasher/sid_draw.wav",75,110)

        timer.Simple(1, function() 

            slasher:SetNWBool("SidGunAiming", false)       
            slasher:SetNWBool("SidGunAimed", true)
            slasher:EmitSound("slashco/slasher/sid_clipout.wav")
            SlashCoSlasher[slasher:GetNWBool("Slasher")]SlasherValue4 = 2

        end)

    elseif slasher:GetNWBool("SidGunAimed") and SlashCoSlasher[slasher:GetNWBool("Slasher")]SlasherValue3 < 0.01 then

        SlashCoSlasher[slasher:GetNWBool("Slasher")]SlasherValue3 = 2
        slasher:SetNWBool("SidGunAiming", false)   
        slasher:SetNWBool("SidGunAimed", false) 
        slasher:SetSlowWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")]ProwlSpeed )  
        slasher:SetWalkSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")]ProwlSpeed )

        if not gunrage then 
            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")]ProwlSpeed ) 
        else
            slasher:SetRunSpeed( SlashCoSlasher[slasher:GetNWBool("Slasher")]ChaseSpeed ) 
        end

    end
end
    ::crimclone::
do
    if SlashCoSlasher[slasher:GetNWBool("Slasher")]SlasherID ~= 12 then return end

    if SlashCoSlasher[slasher:GetNWBool("Slasher")]ChaseActivationCooldown > 0 then return end
    SlashCoSlasher[slasher:GetNWBool("Slasher")]ChaseActivationCooldown = SlashCoSlasher[slasher:GetNWBool("Slasher")]ChaseCooldown

    if slasher:GetNWBool("CriminalCloning") then

        for i = 1, #ents.FindByClass("sc_crimclone") do

            local cln = ents.FindByClass("sc_crimclone")[i]

            if cln.IsMain ~= true then cln:Remove() end
            cln:StopSound("slashco/slasher/criminal_loop.wav")	
            cln:StopSound("slashco/slasher/criminal_rage.wav")	

        end

        slasher:SetNWBool("CriminalCloning", false)
        slasher:SetNWBool("CriminalRage", false)

    else

        for i = 1, math.random(4+(SO * 3),6+(SO * 3)) do

            local clone = ents.Create( "sc_crimclone" )

            clone:SetPos( slasher:GetPos() )
            clone:SetAngles( slasher:GetAngles() )
            clone.AssignedSlasher = slasher:SteamID64()
            clone.IsMain = false
            clone:Spawn()
            clone:Activate()

        end

        slasher:SetNWBool("CriminalCloning", true)

    end
end

end]]