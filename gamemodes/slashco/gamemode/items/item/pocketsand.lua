local SlashCoItems = SlashCoItems

SlashCoItems.PocketSand = SlashCoItems.PocketSand or {}
SlashCoItems.PocketSand.Model = "models/slashco/items/pocketsand.mdl"
SlashCoItems.PocketSand.EntClass = "sc_pocketsand"
SlashCoItems.PocketSand.Name = "PocketSand"
SlashCoItems.PocketSand.Icon = "slashco/ui/icons/items/item_1"
SlashCoItems.PocketSand.Price = 30
SlashCoItems.PocketSand.Description = "PocketSand_desc"
SlashCoItems.PocketSand.CamPos = Vector(50,0,0)
SlashCoItems.PocketSand.DisplayColor = function(ply)
    local setcolor = 360-math.Clamp(ply:Health(),0,100)*1.2
    local color = HSVToColor(setcolor,1,0.5)

    return color.r, color.g, color.b, color.a
end
SlashCoItems.PocketSand.IsSpawnable = true
SlashCoItems.PocketSand.OnUse = function(ply)

    if #team.GetPlayers(TEAM_SLASHER) > 1 then return true end

    local found = false

    for i = 1, #team.GetPlayers(TEAM_SLASHER) do

        local s = team.GetPlayers(TEAM_SLASHER)[i]

        if s:GetPos():Distance(ply:GetPos()) < 120 then

            local tr = util.TraceLine( {
                start = s:EyePos(),
                endpos = ply:GetPos()+Vector(0,0,50),
                filter = slasher
            } )

            if tr.Entity:IsPlayer() and tr.Entity:Team() == TEAM_SLASHER then found = tr.Entity goto FOUNDMAN end

        end

    end

    ::FOUNDMAN::

    if found == false then return true end

    found:SetNWBool("SlasherBlinded", true)

    ply:EmitSound("slashco/survivor/pocketsand_throw"..math.random(1,2)..".mp3")
    ply:EmitSound("slashco/survivor/pocketsand_linger.mp3")

    timer.Simple(8, function()
        found:SetNWBool("SlasherBlinded", false)
    end)
end
SlashCoItems.PocketSand.OnDrop = function(ply)
end
SlashCoItems.PocketSand.ViewModel = {
    model = "models/slashco/items/pocketsand.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.PocketSand.WorldModelHolstered = {
    model = "models/slashco/items/pocketsand.mdl",
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
SlashCoItems.PocketSand.WorldModel = {
    holdtype = "slam",
    model = "models/slashco/items/pocketsand.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(3, 2.5, -1),
    angle = Angle(180, 0, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}

