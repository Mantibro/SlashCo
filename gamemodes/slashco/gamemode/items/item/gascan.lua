local SlashCoItems = SlashCoItems

SlashCoItems.GasCan = {}
SlashCoItems.GasCan.IsSecondary = true
SlashCoItems.GasCan.Model = "models/props_junk/metalgascan.mdl"
SlashCoItems.GasCan.Name = "GasCan"
SlashCoItems.GasCan.EntClass = "sc_gascan"
SlashCoItems.GasCan.Icon = "slashco/ui/icons/items/item_1"
SlashCoItems.GasCan.Price = 0
SlashCoItems.GasCan.Description = "GasCan_desc"
SlashCoItems.GasCan.CamPos = Vector(80,0,0)
SlashCoItems.GasCan.ChangesSpeed = true
SlashCoItems.GasCan.IsSpawnable = false
SlashCoItems.GasCan.IsFuel = true
SlashCoItems.GasCan.MaxAllowed = function()
    return 2
end
SlashCoItems.GasCan.OnDrop = function(ply)
    return 45
end
SlashCoItems.GasCan.OnSwitchFrom = function(ply)
    timer.Simple(0.25, function()
        ply:RemoveSpeedEffect("gas")
    end)
end
SlashCoItems.GasCan.OnBuy = function(_)
    SlashCo.LobbyData.SurvivorGasMod = SlashCo.LobbyData.SurvivorGasMod + 1
end
SlashCoItems.GasCan.OnPickUp = function(ply)
    ply:AddSpeedEffect("gas", 200, 10)
end
SlashCoItems.GasCan.EquipSound = function()
    return "slashco/survivor/gascan_pickup"..math.random(1, 3)..".wav"
end
SlashCoItems.GasCan.ViewModel = {
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
SlashCoItems.GasCan.WorldModel = {
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