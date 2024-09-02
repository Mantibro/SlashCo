local ITEM = {}

ITEM.Model = "models/slashco/items/cookie.mdl"
ITEM.EntClass = "sc_cookie"
ITEM.Name = "Cookie"
ITEM.Icon = "slashco/ui/icons/items/item_4"
ITEM.Price = 15
ITEM.Description = "Cookie_desc"
ITEM.CamPos = Vector(50,0,20)
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
    ply:EmitSound("slashco/survivor/eat_cookie.mp3")
    SlashCoSlashers.Sid.SidRage(ply)
    ply:AddEffect("FuelSpeed", 30)
end
ITEM.ViewModel = {
    model = "models/slashco/items/cookie.mdl",
    bone = "ValveBiped.Bip01_Spine4",
    pos = Vector(64, 0, -5),
    angle = Angle(45, -140, -60),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
ITEM.WorldModelHolstered = {
    model = "models/slashco/items/cookie.mdl",
    bone = "ValveBiped.Bip01_Head1",
    pos = Vector(3, 4.5, 0),
    angle = Angle(90, 105, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
ITEM.WorldModel = {
    holdtype = "camera",
    model = "models/slashco/items/cookie.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(3, 5, -1),
    angle = Angle(-80, 0, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Cookie")