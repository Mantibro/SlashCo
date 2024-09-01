local ITEM = {}

ITEM.IsSecondary = true
ITEM.Model = "models/props_junk/metalgascan.mdl"
ITEM.Name = "GasCan"
ITEM.EntClass = "sc_gascan"
ITEM.Icon = "slashco/ui/icons/items/item_1"
ITEM.Price = 0
ITEM.Description = "GasCan_desc"
ITEM.CamPos = Vector(80, 0, 0)
ITEM.ChangesSpeed = true
ITEM.IsSpawnable = false
ITEM.IsFuel = true
ITEM.MaxAllowed = function()
    return 2
end
ITEM.OnDrop = function(ply)
    return 45
end
ITEM.OnSwitchFrom = function(ply)
    ply:RemoveSpeedEffect("gas")
end
ITEM.OnBuy = function(_)
    SlashCo.LobbyData.SurvivorGasMod = SlashCo.LobbyData.SurvivorGasMod + 1
end
ITEM.OnPickUp = function(ply)
    ply:AddSpeedEffect("gas", 200, 10)
end
ITEM.EquipSound = function()
    return "slashco/survivor/gascan_pickup" .. math.random(1, 3) .. ".wav"
end
ITEM.ViewModel = {
    model = "models/props_junk/metalgascan.mdl",
    pos = Vector(60, 0, 0),
    angle = Angle(0, 90, 90),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
ITEM.WorldModel = {
    holdtype = "duel",
    model = "models/props_junk/metalgascan.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(-2.597, 10.909, 1.557),
    angle = Angle(0, -10, 180),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "GasCan")