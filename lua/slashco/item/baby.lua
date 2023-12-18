local ITEM = {}

ITEM.Model = "models/props_c17/doll01.mdl"
ITEM.EntClass = "sc_baby"
ITEM.Name = "Baby"
ITEM.Icon = "slashco/ui/icons/items/item_7"
ITEM.Price = 35
ITEM.Description = "Baby_desc"
ITEM.CamPos = Vector(50,0,0)
ITEM.DisplayColor = function(ply)
    local setcolor = 360-math.Clamp(ply:Health(),0,100)*1.2
    local color = HSVToColor(setcolor,1,0.5)

    return color.r, color.g, color.b, color.a
end
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
    --When used, half of the survivors health is consumed, and the survivor is teleported to a random location which is at least 2000u away from their currect position.
    --Activation takes 1 second. If the survivors health is lower than 51, the chance that the survivor will die upon use of the item will start increasing the lower their health.
    --(50 - 10%, 25 - 60% ,1 - 100%).
    --Using it will spawn a spent baby in the position the survivor used it.

    ply:EmitSound("slashco/survivor/baby_use.mp3")

    local deathchance = math.random(0, math.floor( ply:Health() / 5 ) )

    local hpafter = ply:Health() / 2

    ply:SetHealth( hpafter )

    timer.Simple(1, function()

        if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then

            if ply:Health() < 51 then
                if deathchance < 2 then
                    ply:Kill()
                    ply:EmitSound("slashco/survivor/devildie_kill.mp3")

                    local slasher = team.GetPlayers(TEAM_SLASHER)[#team.GetPlayers(TEAM_SLASHER)]

                    if IsValid(slasher) then
                        slasher:SetPos(SlashCo.RandomPosLocator())
                        slasher:EmitSound("slashco/survivor/baby_use.mp3")
                    end
                    
                    return
                end
            end

            ply:SetPos(SlashCo.RandomPosLocator())

        end
    end)
end
ITEM.OnDrop = function(ply)
end
ITEM.ViewModel = {
    model = "models/props_c17/doll01.mdl",
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
    model = "models/props_c17/doll01.mdl",
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
    model = "models/props_c17/doll01.mdl",
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

SlashCo.RegisterItem(ITEM, "Baby")