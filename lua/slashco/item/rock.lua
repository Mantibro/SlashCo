local ITEM = {}

ITEM.Model = "models/slashco/items/rock.mdl"
ITEM.Name = "Rock"
ITEM.EntClass = "sc_rock"
ITEM.Icon = "slashco/ui/icons/items/item_7"
ITEM.Price = 30
ITEM.Description = "Rock_desc"
ITEM.CamPos = Vector(50,0,0)
ITEM.ChangesSpeed = true
ITEM.IsSpawnable = true
ITEM.OnFootstep = function()
    return true
end
ITEM.OnSwitchFrom = function(ply)
    ply:RemoveSpeedEffect("rock")
end
ITEM.OnPickUp = function(ply)
    ply:AddSpeedEffect("rock", 200, 10)
end
ITEM.ViewModel = {
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
ITEM.WorldModelHolstered = {
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
ITEM.WorldModel = {
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

SlashCo.RegisterItem(ITEM, "Rock")