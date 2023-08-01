local ITEM = {}

ITEM.Model = "models/slashco/items/flare.mdl"
ITEM.Name = "Flare"
ITEM.EntClass = "sc_flare"
ITEM.Icon = "slashco/ui/icons/items/item_1"
ITEM.Price = 5
ITEM.Description = "Flare_desc"
ITEM.CamPos = Vector(50,0,20)
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
    local flare = SlashCo.CreateItem("sc_flare", ply:LocalToWorld( Vector(0, 0, 30) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))
    Entity( flare ):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 400)
    Entity( flare ):SetNWBool("FlareActive", true)
    Entity( flare ):SetNWString("FlareDropperName", ply:Nick())
    SlashCo.CurRound.Items[flare] = true
end
ITEM.OnDrop = function(ply)
end
ITEM.ViewModel = {
    model = "models/slashco/items/flare.mdl",
    pos = Vector(65, 0, -5),
    angle = Angle(120, -120, -80),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
ITEM.WorldModelHolstered = {
    model = "models/slashco/items/flare.mdl",
    bone = "ValveBiped.Bip01_R_Foot",
    pos = Vector(2.5, 3, -0.2),
    angle = Angle(0, -33, 90),
    size = Vector(1.3, 1.3, 1.3),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
ITEM.WorldModel = {
    holdtype = "slam",
    model = "models/slashco/items/flare.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(4, 6, -1),
    angle = Angle(180, 90, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Flare")