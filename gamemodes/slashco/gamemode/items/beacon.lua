local SlashCo = SlashCo

SlashCo.Items.Beacon.Model = "models/props_c17/light_cagelight01_on.mdl"
SlashCo.Items.Beacon.Name = "Distress Beacon"
SlashCo.Items.Beacon.Icon = "slashco/ui/icons/items/item_9"
SlashCo.Items.Beacon.Price = 45
SlashCo.Items.Beacon.Description = "A personal emergency terminal. \nIf at least one Generator has been activated and you are the last one alive, upon use \nthis item will alert the SlashCo headquarters to send emergency rescue. \nOnly one can be taken."
SlashCo.Items.Beacon.CamPos = Vector(50,0,10)
SlashCo.Items.Beacon.OnUse = function(ply)
    --If the holder of the item is the last one alive and at least one generator has been activated, the rescue helicopter will come prematurely.

    if #team.GetPlayers(TEAM_SURVIVOR) > 1 then ply:ChatPrint("You can activate the beacon only if you're the last living survivor.") return end

    if SlashCo.CurRound.EscapeHelicopterSummoned then ply:ChatPrint("The Helicopter is already on its way.") return end

    local r1 = ents.FindByClass( "sc_generator")[1]:EntIndex()
    local r2 = ents.FindByClass( "sc_generator")[2]:EntIndex()

    if SlashCo.CurRound.Generators[r1].Running or SlashCo.CurRound.Generators[r2].Running then

        if SlashCo.CurRound.DistressBeaconUsed == false then

            SlashCo.SummonEscapeHelicopter()

            SlashCo.CurRound.DistressBeaconUsed = true

            SlashCo.CreateItem("sc_activebeacon",ply:GetPos(),Angle(0,0,0))


        end

    else
        ply:ChatPrint("You can activate the beacon once one generator has been turned on.")
        return
    end
end
SlashCo.Items.Beacon.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_beacon", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 750)
end