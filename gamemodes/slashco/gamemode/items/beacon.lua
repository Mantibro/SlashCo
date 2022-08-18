local SlashCoItems = SlashCoItems

SlashCoItems.Beacon = {}
SlashCoItems.Beacon.Model = "models/props_c17/light_cagelight01_on.mdl"
SlashCoItems.Beacon.Name = "Distress Beacon"
SlashCoItems.Beacon.Icon = "slashco/ui/icons/items/item_9"
SlashCoItems.Beacon.Price = 45
SlashCoItems.Beacon.Description = "A personal emergency terminal. \nIf at least one Generator has been activated and you are the last one alive, upon use \nthis item will alert the SlashCo headquarters to send emergency rescue. \nOnly one can be taken."
SlashCoItems.Beacon.CamPos = Vector(50,0,10)
SlashCoItems.Beacon.MaxAllowed = function()
    return 1
end
SlashCoItems.Beacon.OnUse = function(ply)
    --If the holder of the item is the last one alive and at least one generator has been activated, the rescue helicopter will come prematurely.

    if #team.GetPlayers(TEAM_SURVIVOR) > 1 then ply:ChatPrint("You can activate the beacon only if you're the last living survivor.") return true end

    if SlashCo.CurRound.EscapeHelicopterSummoned then ply:ChatPrint("The Helicopter is already on its way.") return true end

    local gens = ents.FindByClass( "sc_generator")
    local runningCount = 0
    for _, v in ipairs(gens) do
        if v.IsRunning then runningCount = runningCount + 1 end

    end

    if runningCount >= 1 then

        if not SlashCo.CurRound.DistressBeaconUsed then

            local failed = SlashCo.SummonEscapeHelicopter()

            if not failed then
                SlashCo.CurRound.DistressBeaconUsed = true

                SlashCo.CreateItem("sc_activebeacon", ply:GetPos(), Angle(0, 0, 0))
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
    SlashCo.MakeSelectable(droppeditem)
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
