local ITEM = {}

ITEM.Model = "models/props_junk/garbage_milkcarton001a.mdl"
ITEM.Name = "MilkJug"
ITEM.EntClass = "sc_milkjug"
ITEM.Icon = "slashco/ui/icons/items/item_3"
ITEM.Price = 10
ITEM.Description = "MilkJug_desc"
ITEM.CamPos = Vector(60,0,10)
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their sprint speed to 400 for 15 seconds.

    ply:EmitSound("slashco/survivor/drink_milk.mp3")
    SlashCoSlashers.Thirsty.ThirstyRage(ply)
    ply:AddEffect("Speed", 15)
end
ITEM.OnDrop = function(ply)
end
ITEM.ViewModel = {
    model = "models/props_junk/garbage_milkcarton001a.mdl",
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
    model = "models/props_junk/garbage_milkcarton001a.mdl",
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
    model = "models/props_junk/garbage_milkcarton001a.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(1, 4.5, 1),
    angle = Angle(180, -20, -25),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "MilkJug")