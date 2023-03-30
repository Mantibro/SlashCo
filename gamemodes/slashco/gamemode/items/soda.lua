local SlashCoItems = SlashCoItems

SlashCoItems.Soda = SlashCoItems.Soda or {}
SlashCoItems.Soda.Model = "models/props_junk/PopCan01a.mdl"
SlashCoItems.Soda.Name = "B-Gone Soda"
SlashCoItems.Soda.EntClass = "sc_soda"
SlashCoItems.Soda.Icon = "slashco/ui/icons/items/item_8"
SlashCoItems.Soda.Price = 20
SlashCoItems.Soda.Description = "Become invisible on use."
SlashCoItems.Soda.CamPos = Vector(30,0,0)
SlashCoItems.Soda.IsSpawnable = true
SlashCoItems.Soda.OnUse = function(ply)
    --When used, the survivor will become undetectable for 30 seconds.

    ply:EmitSound("slashco/survivor/soda_drink"..math.random(1,2)..".mp3")

    ply:SetMaterial("Models/effects/vol_light001")
    ply:SetColor(Color(0,0,0,0))
    ply:SetNWBool("BGoneSoda", true)

    timer.Simple(30, function()

        ply:SetMaterial("")
        ply:SetColor(Color(255,255,255,255))
        ply:SetNWBool("BGoneSoda", false)

        ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

    end)
end
SlashCoItems.Soda.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem(SlashCoItems.Soda.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
SlashCoItems.Soda.ViewModel = {
    model = "models/props_junk/PopCan01a.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Soda.WorldModelHolstered = {
    model = "models/props_junk/PopCan01a.mdl",
    bone = "ValveBiped.Bip01_Pelvis",
    pos = Vector(5, 2, 5),
    angle = Angle(110, -80, 0),
    size = Vector(1, 1, 1),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Soda.WorldModel = {
    holdtype = "slam",
    model = "models/props_junk/PopCan01a.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(3, 2.5, -1),
    angle = Angle(180, 0, 0),
    size = Vector(1, 1, 1),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}