local SlashCo = SlashCo

SlashCo.Items.Mayonnaise.Model = "models/props_lab/jar01a.mdl"
SlashCo.Items.Mayonnaise.Name = "Mayonnaise"
SlashCo.Items.Mayonnaise.Icon = "slashco/ui/icons/items/item_5"
SlashCo.Items.Mayonnaise.Price = 15
SlashCo.Items.Mayonnaise.Description = "A large jar full of highly caloric mayonnaise. Consuming it will grant \nyou a massive boost to your health."
SlashCo.Items.Mayonnaise.CamPos = Vector(50,0,20)
SlashCo.Items.Mayonnaise.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their health to 200, regardless of current health.

    ply:SetHealth( 200 )

    ply:EmitSound("slashco/survivor/eat_mayo.mp3")
end
SlashCo.Items.Mayonnaise.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_mayo", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
end