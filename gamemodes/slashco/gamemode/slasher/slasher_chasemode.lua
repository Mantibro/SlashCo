local SlashCo = SlashCo

--[[SlashCo.SlasherCallForChaseMode = function(ply)

do
    if SlashCoSlasher[slasher:GetNWBool("Slasher")].SlasherID ~= 12 then return end

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