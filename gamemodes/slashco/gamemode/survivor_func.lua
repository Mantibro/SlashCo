local SlashCo = SlashCo

--Door Ramming
hook.Add("PlayerButtonDown", "SurvivorFunctions", function(ply, key)

    if ply:Team() ~= TEAM_SURVIVOR then return end

    if game.GetMap() == "sc_lobby" then return end

    local lookent = ply:GetEyeTrace().Entity

    if key == 107 and ply:GetVelocity():Length() > 250 then

        if lookent:GetClass() == "prop_door_rotating" then

            if not CheckDoorWL(lookent) then return end

            if lookent:GetPos():Distance( ply:GetPos() ) > 100 then return end

            lookent:EmitSound("ambient/materials/door_hit1.wav", 80)

            local vals = lookent:GetKeyValues()

            local localpos = lookent:WorldToLocal( ply:GetPos() )

            if localpos.x < 0 then
                lookent:SetKeyValue( "opendir", "1" )
            else
                lookent:SetKeyValue( "opendir", "2" )
            end

            lookent:Fire("SetSpeed", 1000)
            lookent:Fire("Open")
            timer.Simple(0.1, function()
                lookent:Fire("SetSpeed", 1)
                lookent:Fire("Open")
            end)
           
            for i = 1, 10 do
                timer.Simple(i/8, function() lookent:Fire("Open") end)
            end

            timer.Simple(0.5, function() 

                lookent:Fire("SetSpeed", 100) 

                lookent:SetKeyValue( "opendir", "0" )

            end)

        end

    end

end)