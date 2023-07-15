local SlashCo = SlashCo

--Door Ramming
hook.Add("PlayerButtonDown", "SurvivorFunctions", function(ply, key)

    if ply:Team() ~= TEAM_SURVIVOR then return end

    if game.GetMap() == "sc_lobby" then return end

    --Covenant Tackle


    if ply:GetNWBool("SurvivorTackled") then
           
        if key == 14 or key == 11 and ply.LastTackleStruggleKey ~= key then
            ply.LastTackleStruggleKey = key
            ply.TackleStruggle = ply.TackleStruggle or 0
            ply.TackleStruggle = ply.TackleStruggle + 1
        end

    end

    local lookent = ply:GetEyeTrace().Entity

    if key == 107 and ply:GetVelocity():Length() > 250 then

        if lookent:GetPos():Distance( ply:GetPos() ) > 120 then return end

        if SlashCo.SlamDoor(lookent, ply) then
            ply:ViewPunch( Angle( 10, 0, 0 ) )
            timer.Simple(0.2, function() 
                ply:ViewPunch( Angle( -20, 0, 0 ) )
            end)
        end

    end

end)

SlashCo.SlamDoor = function(door_ent, ply)

    if door_ent:GetClass() == "prop_door_rotating" then

        if not CheckDoorWL(door_ent) then return end

        local vals = door_ent:GetKeyValues()

        if vals.speed > 500 then return end

        door_ent:EmitSound("ambient/materials/door_hit1.wav", 80)

        local localpos = door_ent:WorldToLocal( ply:GetPos() )

        if localpos.x < 0 then
            door_ent:SetKeyValue( "opendir", "1" )
        else
            door_ent:SetKeyValue( "opendir", "2" )
        end

        door_ent:Fire("SetSpeed", 1000)
        door_ent:Fire("Open")
        timer.Simple(0.1, function()
            door_ent:Fire("SetSpeed", 1)
            door_ent:Fire("Open")
        end)
       
        for i = 1, 10 do
            timer.Simple(i/8, function() door_ent:Fire("Open") end)
        end

        timer.Simple(0.5, function() 

            door_ent:Fire("SetSpeed", 100) 

            door_ent:SetKeyValue( "opendir", "0" )

        end)

        return true

    end

end