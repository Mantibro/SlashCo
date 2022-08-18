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
    local droppeditem = SlashCo.CreateItem("sc_mayo", ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
    SlashCo.MakeSelectable(droppeditem)
end
SlashCoItems.Mayonnaise.ViewModel = {
    model = "models/props_lab/jar01a.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}