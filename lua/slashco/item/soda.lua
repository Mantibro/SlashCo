local ITEM = {}

ITEM.Model = "models/props_junk/PopCan01a.mdl"
ITEM.Name = "Soda"
ITEM.EntClass = "sc_soda"
ITEM.Icon = "slashco/ui/icons/items/item_8"
ITEM.Price = 20
ITEM.Description = "Soda_desc"
ITEM.CamPos = Vector(30,0,0)
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
    ply:EmitSound("slashco/survivor/soda_drink" .. math.random(1,2) .. ".mp3")
    ply:AddEffect("Invisibility", 30)
end
ITEM.ViewModel = {
    model = "models/props_junk/PopCan01a.mdl",
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
    model = "models/props_junk/PopCan01a.mdl",
    bone = "ValveBiped.Bip01_Pelvis",
    pos = Vector(5, 2, 5),
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
    model = "models/props_junk/PopCan01a.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(3, 2.5, -1),
    angle = Angle(180, 0, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Soda")