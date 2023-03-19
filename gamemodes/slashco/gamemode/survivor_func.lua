local SlashCo = SlashCo

--Door Ramming
hook.Add("PlayerButtonDown", "SurvivorFunctions", function(ply, key)

    if ply:Team() ~= TEAM_SURVIVOR then return end

    local lookent = ply:GetEyeTrace().Entity

    if key == 107 and ply:GetVelocity():Length() > 250 then

        if lookent:GetClass() == "prop_door_rotating" or lookent:GetClass() == "func_door_rotating" then

            if lookent:GetPos():Distance( ply:GetPos() ) > 100 then return end

            lookent:EmitSound("ambient/materials/door_hit1.wav", 80)

            local vals = lookent:GetKeyValues()

            local localpos = lookent:WorldToLocal( ply:GetPos() )

            if localpos.x < 0 then
                lookent:SetKeyValue( "opendir", "1" )
            else
                lookent:SetKeyValue( "opendir", "2" )
            end

            lookent:Fire("SetSpeed", 750)
            lookent:Fire("Open")
            --lookent:Fire("OpenAwayFrom", ply)
            timer.Simple(0.5, function() 

                lookent:Fire("SetSpeed", 100) 

                lookent:SetKeyValue( "opendir", "0" )

            end)

        end

    end

end)