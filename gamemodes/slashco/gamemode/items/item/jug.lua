local ITEM = SlashCoItems.Jug or {}
SlashCoItems.Jug = ITEM

ITEM.Model = "models/slashco/items/jug.mdl"
ITEM.Name = "Jug"
ITEM.EntClass = "sc_jug"
ITEM.Price = 7
ITEM.Description = "Jug_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.ChangesSpeed = true
ITEM.IsSpawnable = true
ITEM.OnDrop = function(ply)
end

ITEM.OnSwitchFrom = function(ply)
    timer.Simple(0.18, function()
        ply:RemoveSpeedEffect("jug")
    end)
end
ITEM.OnPickUp = function(ply)
    if ply:GetNWBool("CurseOfTheJug") then
        ply:EmitSound("slashco/jug_reject.mp3")
        timer.Simple(0, function()
            SlashCo.DropItem(ply)
        end)
    end

    ply:AddSpeedEffect("jug", 310, 3)
end

hook.Add("Think", "JugFunc", function()
    if SERVER then
        for _, surv in ipairs( team.GetPlayers(TEAM_SURVIVOR) ) do

            if surv:GetNWString("item") ~= "Jug" then continue end

            local find = ents.FindInSphere(surv:GetPos(), 120)

            for i = 1, #find do
                local ent = find[i]

                if ent:IsPlayer() and ent:Team() == TEAM_SLASHER then
                    surv:SetPos(SlashCo.TraceHullLocator())
                    surv:EmitSound("slashco/jug_curse.mp3")
                    SlashCo.RemoveItem(surv)
                    surv:SetNWBool("CurseOfTheJug", true)
                end
            end
        end
    end
end)

ITEM.ViewModel = {
    model = ITEM.Model,
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
    model = ITEM.Model,
    bone = "ValveBiped.Bip01_Pelvis",
    pos = Vector(10, 2, 5),
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
    model = ITEM.Model,
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(1, 4.5, -1),
    angle = Angle(180, 0, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}