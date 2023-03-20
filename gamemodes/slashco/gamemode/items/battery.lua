local SlashCoItems = SlashCoItems

SlashCoItems.Battery = {}
SlashCoItems.Battery.IsSecondary = true
SlashCoItems.Battery.Model = "models/items/car_battery01.mdl"
SlashCoItems.Battery.Name = "Battery"
SlashCoItems.Battery.EntClass = "sc_battery"
SlashCoItems.Battery.Description = "A lead-acid battery that serves as a reusable source of electric current."
SlashCoItems.Battery.CamPos = Vector(80,0,0)
SlashCoItems.Battery.IsSpawnable = false
SlashCoItems.Battery.OnDrop = function(ply)
    local battery = SlashCo.CreateBattery(ply:LocalToWorld(Vector(0, 0, 55)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    battery:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
end
SlashCoItems.Battery.ViewModel = {
    model = "models/items/car_battery01.mdl",
    pos = Vector(63, 0, 0),
    angle = Angle(0, 90, 90),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Battery.WorldModel = {
    holdtype = "duel",
    model = "models/items/car_battery01.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(-2.5, 11, -3),
    angle = Angle(0, -10, 180),
    size = Vector(1, 1, 1),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}