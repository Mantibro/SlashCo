local SlashCoItems = SlashCoItems

SlashCoItems.Rock = SlashCoItems.Rock or {}
SlashCoItems.Rock.Model = "models/slashco/items/rock.mdl"
SlashCoItems.Rock.Name = "The Rock"
SlashCoItems.Rock.EntClass = "sc_rock"
SlashCoItems.Rock.Icon = "slashco/ui/icons/items/item_7"
SlashCoItems.Rock.Price = 30
SlashCoItems.Rock.Description = "Become silent but unable to sprint while equipped. When dropped, this will occasionally nudge itself to the nearest gas can."
SlashCoItems.Rock.CamPos = Vector(50,0,0)
SlashCoItems.Rock.ChangesSpeed = true
SlashCoItems.Rock.IsSpawnable = true
SlashCoItems.Rock.OnDrop = function(ply)
end
SlashCoItems.Rock.OnFootstep = function()
    return true
end
SlashCoItems.Rock.OnSwitchFrom = function(ply)
    timer.Simple(0.18, function()
        ply:RemoveSpeedEffect("rock")
    end)
end
SlashCoItems.Rock.OnPickUp = function(ply)
    ply:AddSpeedEffect("rock", 200, 10)
end
SlashCoItems.Rock.ViewModel = {
    model = "models/slashco/items/rock.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Rock.WorldModelHolstered = {
    model = "models/slashco/items/rock.mdl",
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
SlashCoItems.Rock.WorldModel = {
    holdtype = "slam",
    model = "models/slashco/items/rock.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(3, 3, -1),
    angle = Angle(180, 0, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}