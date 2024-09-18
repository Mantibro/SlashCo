local ITEM = {}

ITEM.Model = "models/props_c17/light_cagelight01_on.mdl"
ITEM.EntClass = "sc_beacon"
ITEM.Name = "Beacon"
ITEM.Icon = "slashco/ui/icons/items/item_9"
ITEM.Price = 15
ITEM.Description = "Beacon_desc"
ITEM.CamPos = Vector(50,0,35)
ITEM.MaxAllowed = function()
    return 1
end
ITEM.IsSpawnable = false
ITEM.OnUse = function(ply)
    --If the holder of the item is the last one alive and at least one generator has been activated, the rescue helicopter will come prematurely.

    if SlashCo.CurRound.EscapeHelicopterSummoned then 
        ply:ChatText("Beacon_already_on_way") 
        return true 
    end

    local gens = ents.FindByClass( "sc_generator")
    local runningCount = 0
    for _, v in ipairs(gens) do
        if v.IsRunning then runningCount = runningCount + 1 end
    end

    for k, v in ipairs(ents.FindByClass( "sc_activebeacon")) do
        if not v:GetNWBool("BeaconBroken") then
            ply:ChatText("Beacon_already_active")
            return true 
        end
    end

    if runningCount >= 1 then
        if not SlashCo.CurRound.DistressBeaconUsed then
            if team.NumPlayers(TEAM_SURVIVOR) > 1 then --slow beacon arming
                if not ply.BeaconWarning then
                    ply:ChatText("Beacon_confirm")
                    ply.BeaconWarning = true
                    timer.Simple(3, function() ply.BeaconWarning = false end)
                    return true
                else
                    local ent = SlashCo.CreateItem("sc_activebeacon", ply:GetPos(), Angle(0, 0, 0))
                    Entity(ent).DoArming = true
                    Entity(ent):SetNWBool("ArmingBeacon", true)
                    return
                end
            else --instant because alone
                SlashCo.CurRound.DistressBeaconUsed = true
                SlashCo.SummonEscapeHelicopter(true)
                local ent = SlashCo.CreateItem("sc_activebeacon", ply:GetPos(), Angle(0, 0, 0))
                ent:PlayGlobalSound("slashco/survivor/distress_siren.wav", 100)

                return
            end
        end
    else
        ply:ChatText("Beacon_unavailable")
        return true
    end
end
ITEM.ViewModel = {
    type = "Model",
    model = "models/props_c17/light_cagelight01_on.mdl",
    rel = "",
    pos = Vector(66, 0, -7),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
ITEM.WorldModelHolstered = {
    model = "models/props_c17/light_cagelight01_on.mdl",
    bone = "ValveBiped.Bip01_Spine2",
    pos = Vector(4, 1, 4),
    angle = Angle(0, -90, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
ITEM.WorldModel = {
    holdtype = "passive",
    model = "models/props_c17/light_cagelight01_on.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(9, 1, 4),
    angle = Angle(-30, 180, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Beacon")