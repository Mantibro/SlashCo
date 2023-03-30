local SlashCoItems = SlashCoItems

SlashCoItems.Beacon = SlashCoItems.Beacon or {}
SlashCoItems.Beacon.Model = "models/props_c17/light_cagelight01_on.mdl"
SlashCoItems.Beacon.EntClass = "sc_beacon"
SlashCoItems.Beacon.Name = "Distress Beacon"
SlashCoItems.Beacon.Icon = "slashco/ui/icons/items/item_9"
SlashCoItems.Beacon.Price = 15
SlashCoItems.Beacon.Description = "Alerts the SlashCo Headquarters to abort the mission. Only IMPORTANT circumstances get a fast response."
SlashCoItems.Beacon.CamPos = Vector(50,0,35)
SlashCoItems.Beacon.MaxAllowed = function()
    return 1
end
SlashCoItems.Beacon.IsSpawnable = false
SlashCoItems.Beacon.OnUse = function(ply)
    --If the holder of the item is the last one alive and at least one generator has been activated, the rescue helicopter will come prematurely.

    if SlashCo.CurRound.EscapeHelicopterSummoned then 
        ply:ChatPrint("The Helicopter is already on its way.") 
        return true 
    end

    local gens = ents.FindByClass( "sc_generator")
    local runningCount = 0
    for _, v in ipairs(gens) do
        if v.IsRunning then runningCount = runningCount + 1 end
    end

    for k, v in ipairs(ents.FindByClass( "sc_activebeacon")) do
        if not v:GetNWBool("BeaconBroken") then
            ply:ChatPrint("There is already a beacon deployed.")
            return true 
        end
    end

    if runningCount >= 1 then

        if not SlashCo.CurRound.DistressBeaconUsed then

            if #team.GetPlayers(TEAM_SURVIVOR) > 1 then --slow beacon arming

                if not ply.BeaconWarning then
                    ply:ChatPrint("Using the beacon with more than 1 living survivor will cause it to take time to arm. Use again to confirm.")
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
                PlayGlobalSound("slashco/survivor/distress_siren.wav", 98, Entity(ent))

                return

            end

        end

    else
        ply:ChatPrint("You can activate the beacon once one generator has been turned on.")
        return true
    end
end
SlashCoItems.Beacon.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_beacon", ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
SlashCoItems.Beacon.ViewModel = {
    type = "Model",
    model = "models/props_c17/light_cagelight01_on.mdl",
    rel = "",
    pos = Vector(66, 0, -7),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Beacon.WorldModelHolstered = {
    model = "models/props_c17/light_cagelight01_on.mdl",
    bone = "ValveBiped.Bip01_Spine2",
    pos = Vector(4, 1, 4),
    angle = Angle(0, -90, 0),
    size = Vector(1, 1, 1),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.Beacon.WorldModel = {
    holdtype = "passive",
    model = "models/props_c17/light_cagelight01_on.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(9, 1, 4),
    angle = Angle(-30, 180, 0),
    size = Vector(1, 1, 1),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
