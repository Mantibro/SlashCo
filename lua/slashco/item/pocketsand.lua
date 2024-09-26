local ITEM = {}

ITEM.Model = "models/slashco/items/pocketsand.mdl"
ITEM.EntClass = "sc_pocketsand"
ITEM.Name = "PocketSand"
ITEM.Icon = "slashco/ui/icons/items/item_1"
ITEM.Price = 30
ITEM.Description = "PocketSand_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
    local found = {}

    for _, s in ipairs(team.GetPlayers(TEAM_SLASHER)) do
        if s:GetPos():Distance(ply:GetPos()) > 200 then
            return
        end

        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = s:WorldSpaceCenter(),
            filter = ply
        })

        if tr.Entity == s then
            table.insert(found, s)
            break
        end
    end

    if table.IsEmpty(found) then
        return true
    end

    for _, v in ipairs(found) do
        v:SetNWBool("SlasherBlinded", true)
    end

    ply:EmitSound("slashco/survivor/pocketsand_throw" .. math.random(1, 2) .. ".mp3")
    ply:EmitSound("slashco/survivor/pocketsand_linger.mp3")

    timer.Simple(8, function()
        for _, v in ipairs(found) do
            if not IsValid(v) then continue end
            v:SetNWBool("SlasherBlinded", false)
        end
    end)
end
ITEM.ViewModel = {
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
ITEM.WorldModelHolstered = {
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
ITEM.WorldModel = {
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

SlashCo.RegisterItem(ITEM, "PocketSand")

