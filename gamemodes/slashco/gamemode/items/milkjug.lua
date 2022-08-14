local SlashCo = SlashCo

SlashCo.Items.MilkJug.Model = "models/props_junk/garbage_milkcarton001a.mdl"
SlashCo.Items.MilkJug.Name = "Milk Jug"
SlashCo.Items.MilkJug.Icon = "slashco/ui/icons/items/item_3"
SlashCo.Items.MilkJug.Price = 10
SlashCo.Items.MilkJug.Description = "A jug of fresh milk. Consuming it will grant you a large speed boost\n for a short while.\nA certain Slasher seems to really like this item."
SlashCo.Items.MilkJug.CamPos = Vector(60,0,10)
SlashCo.Items.MilkJug.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their sprint speed to 400 for 15 seconds.

    ply:SetRunSpeed( 400 )

    ply:EmitSound("slashco/survivor/drink_milk.mp3")

    timer.Simple(15, function()

        ply:SetRunSpeed( 300 )

        ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

    end)

    SlashCo.ThirstyRage(ply)
end
SlashCo.Items.MilkJug.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_milkjug", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
end