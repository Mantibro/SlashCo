local SlashCo = SlashCo

SlashCo.Items.Soda.Model = "models/props_junk/PopCan01a.mdl"
SlashCo.Items.Soda.Name = "B-Gone Soda"
SlashCo.Items.Soda.Icon = "slashco/ui/icons/items/item_8"
SlashCo.Items.Soda.Price = 20
SlashCo.Items.Soda.Description = "A can of strange soda. It has a sweet smell. \nConsuming it will turn you invisible for a short while."
SlashCo.Items.Soda.CamPos = Vector(30,0,0)
SlashCo.Items.Soda.OnUse = function(ply)
    --When used, the survivor will become undetectable for 30 seconds.

    ply:EmitSound("slashco/survivor/soda_drink"..math.random(1,2)..".mp3")

    ply:SetMaterial("Models/effects/vol_light001")
    ply:SetColor(Color(0,0,0,0))
    ply:SetNWBool("BGoneSoda", true)

    timer.Simple(30, function()

        ply:SetMaterial("")
        ply:SetColor(Color(255,255,255,255))
        ply:SetNWBool("BGoneSoda", false)

        ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

    end)
end
SlashCo.Items.Soda.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_soda", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
end