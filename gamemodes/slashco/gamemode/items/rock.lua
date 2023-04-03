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
    SlashCoItems.Rock.OnSwitchFrom(ply)
    local droppeditem = SlashCo.CreateItem(SlashCoItems.Rock.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
SlashCoItems.Rock.OnFootstep = function()
    return true
end
SlashCoItems.Rock.OnSwitchFrom = function(ply)
    timer.Simple(0.18, function()
        if not ply:ItemValue2("ChangesSpeed") then
            ply:SetRunSpeed(300)
        end
    end)
end
SlashCoItems.Rock.OnPickUp = function(ply)
    ply:SetRunSpeed(200)
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