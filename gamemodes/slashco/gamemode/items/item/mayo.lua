local SlashCoItems = SlashCoItems

SlashCoItems.Mayonnaise = SlashCoItems.Mayonnaise or {}
SlashCoItems.Mayonnaise.Model = "models/props_lab/jar01a.mdl"
SlashCoItems.Mayonnaise.EntClass = "sc_mayo"
SlashCoItems.Mayonnaise.Name = "Mayo"
SlashCoItems.Mayonnaise.Icon = "slashco/ui/icons/items/item_5"
SlashCoItems.Mayonnaise.Price = 15
SlashCoItems.Mayonnaise.Description = "Mayo_desc"
SlashCoItems.Mayonnaise.CamPos = Vector(50,0,20)
SlashCoItems.Mayonnaise.IsSpawnable = true
SlashCoItems.Mayonnaise.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their health to 200, regardless of current health.

    ply:SetHealth( 200 )

    ply:EmitSound("slashco/survivor/eat_mayo.mp3")
end
SlashCoItems.Mayonnaise.OnDrop = function(ply)
end
SlashCoItems.Mayonnaise.ViewModel = {
    model = "models/props_lab/jar01a.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Mayonnaise.WorldModelHolstered = {
    model = "models/props_lab/jar01a.mdl",
    bone = "ValveBiped.Bip01_Pelvis",
    pos = Vector(10, 2, 5),
    angle = Angle(110, -80, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Mayonnaise.WorldModel = {
    holdtype = "slam",
    model = "models/props_lab/jar01a.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(1, 4.5, -1),
    angle = Angle(180, 0, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}