local SlashCoItems = SlashCoItems

SlashCoItems.GasCan = {}
SlashCoItems.GasCan.IsSecondary = true
SlashCoItems.GasCan.Model = "models/props_junk/metalgascan.mdl"
SlashCoItems.GasCan.Name = "Gas Can"
SlashCoItems.GasCan.Icon = "slashco/ui/icons/items/item_1"
SlashCoItems.GasCan.Price = 15
SlashCoItems.GasCan.Description = "A jerry can full of high-octane gas. Useful for refuelling Cars and \nGenerators. Taking it with you will reduce how much gas you will find\nwithin the Zone. \nOnce you drop this item, you will not be able to store it again."
SlashCoItems.GasCan.CamPos = Vector(80,0,0)
SlashCoItems.GasCan.OnDrop = function(ply)
    timer.Simple(0.25, function()
        if ply:GetNWString("item2", "none") ~= SlashCoItems.GasCan then --janky way of preventing slowdown from being cancelled
            ply:SetRunSpeed(300)
        end
    end)

    local gasCan = SlashCo.CreateGasCan(ply:LocalToWorld(Vector(0, 0, 45)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    gasCan:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
end
SlashCoItems.GasCan.OnBuy = function(_)
    SlashCo.LobbyData.SurvivorGasMod = SlashCo.LobbyData.SurvivorGasMod + 1
end
SlashCoItems.GasCan.OnPickUp = function(ply)
    ply:SetRunSpeed(200)
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