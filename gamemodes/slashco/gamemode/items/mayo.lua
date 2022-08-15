local SlashCoItems = SlashCoItems

SlashCoItems.Mayonnaise = {}
SlashCoItems.Mayonnaise.Model = "models/props_lab/jar01a.mdl"
SlashCoItems.Mayonnaise.Name = "Mayonnaise"
SlashCoItems.Mayonnaise.Icon = "slashco/ui/icons/items/item_5"
SlashCoItems.Mayonnaise.Price = 15
SlashCoItems.Mayonnaise.Description = "A large jar full of highly caloric mayonnaise. Consuming it will grant \nyou a massive boost to your health."
SlashCoItems.Mayonnaise.CamPos = Vector(50,0,20)
SlashCoItems.Mayonnaise.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their health to 200, regardless of current health.

    ply:SetHealth( 200 )

    ply:EmitSound("slashco/survivor/eat_mayo.mp3")
end
SlashCoItems.Mayonnaise.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_mayo", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
end