local SlashCoItems = SlashCoItems

SlashCoItems.MilkJug = SlashCoItems.MilkJug or {}
SlashCoItems.MilkJug.Model = "models/props_junk/garbage_milkcarton001a.mdl"
SlashCoItems.MilkJug.Name = "MilkJug"
SlashCoItems.MilkJug.EntClass = "sc_milkjug"
SlashCoItems.MilkJug.Icon = "slashco/ui/icons/items/item_3"
SlashCoItems.MilkJug.Price = 10
SlashCoItems.MilkJug.Description = "MilkJug_desc"
SlashCoItems.MilkJug.CamPos = Vector(60,0,10)
SlashCoItems.MilkJug.IsSpawnable = true
SlashCoItems.MilkJug.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their sprint speed to 400 for 15 seconds.

    ply:EmitSound("slashco/survivor/drink_milk.mp3")
    SlashCoSlasher.Thirsty.ThirstyRage(ply)
    ply:AddEffect("Speed", 15)
end
SlashCoItems.MilkJug.OnDrop = function(ply)
end
SlashCoItems.MilkJug.ViewModel = {
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
SlashCoItems.MilkJug.WorldModelHolstered = {
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
SlashCoItems.MilkJug.WorldModel = {
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