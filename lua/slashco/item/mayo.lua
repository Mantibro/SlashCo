local ITEM = {}

ITEM.Model = "models/props_lab/jar01a.mdl"
ITEM.EntClass = "sc_mayo"
ITEM.Name = "Mayo"
ITEM.Icon = "slashco/ui/icons/items/item_5"
ITEM.Price = 15
ITEM.Description = "Mayo_desc"
ITEM.CamPos = Vector(50,0,20)
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their health to 200, regardless of current health.

    ply:SetHealth( 200 )

    ply:EmitSound("slashco/survivor/eat_mayo.mp3")
end
ITEM.OnDrop = function(ply)
end
ITEM.ViewModel = {
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
ITEM.WorldModelHolstered = {
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
ITEM.WorldModel = {
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

SlashCo.RegisterItem(ITEM, "Mayonnaise")