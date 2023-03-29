local SlashCoItems = SlashCoItems

SlashCoItems.GasCan = {}
SlashCoItems.GasCan.IsSecondary = true
SlashCoItems.GasCan.Model = "models/props_junk/metalgascan.mdl"
SlashCoItems.GasCan.Name = "Fuel Can"
SlashCoItems.GasCan.EntClass = "sc_gascan"
SlashCoItems.GasCan.Icon = "slashco/ui/icons/items/item_1"
SlashCoItems.GasCan.Price = 0
SlashCoItems.GasCan.Description = "Take a gas can with you instead of having to find one. There will be less gas cans to find if you do this."
SlashCoItems.GasCan.CamPos = Vector(80,0,0)
SlashCoItems.GasCan.ChangesSpeed = true
SlashCoItems.GasCan.IsSpawnable = false
SlashCoItems.GasCan.MaxAllowed = function()
    return 2
end
SlashCoItems.GasCan.OnDrop = function(ply)
    SlashCoItems.GasCan.OnSwitchFrom(ply)
    local gasCan = SlashCo.CreateGasCan(ply:LocalToWorld(Vector(0, 0, 45)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    gasCan:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
end
SlashCoItems.GasCan.OnSwitchFrom = function(ply)
    timer.Simple(0.25, function()
        local item = ply:GetNWString("item2", "none")
        if item == "none" then
            item = ply:GetNWString("item", "none")
        end
        if not SlashCoItems[item] or not SlashCoItems[item].ChangesSpeed then
            ply:SetRunSpeed(300)
        end
    end)
end
SlashCoItems.GasCan.OnBuy = function(_)
    SlashCo.LobbyData.SurvivorGasMod = SlashCo.LobbyData.SurvivorGasMod + 1
end
SlashCoItems.GasCan.OnPickUp = function(ply)
    ply:SetRunSpeed(200)
end
SlashCoItems.GasCan.EquipSound = function()
    return "slashco/survivor/gascan_pickup"..math.random(1, 3)..".wav"
end
SlashCoItems.GasCan.ViewModel = {
    model = "models/props_junk/metalgascan.mdl",
    pos = Vector(60, 0, 0),
    angle = Angle(0, 90, 90),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
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
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}