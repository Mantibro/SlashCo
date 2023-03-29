local SlashCoItems = SlashCoItems

SlashCoItems.Baby = {}
SlashCoItems.Baby.Model = "models/props_c17/doll01.mdl"
SlashCoItems.Baby.EntClass = "sc_baby"
SlashCoItems.Baby.Name = "The Baby"
SlashCoItems.Baby.Icon = "slashco/ui/icons/items/item_7"
SlashCoItems.Baby.Price = 35
SlashCoItems.Baby.Description = "Halve your health to teleport to a random location. Using this item at low health increases the chance of randomly dying."
SlashCoItems.Baby.CamPos = Vector(50,0,0)
SlashCoItems.Baby.DisplayColor = function(ply)
    local setcolor = 360-math.Clamp(ply:Health(),0,100)*1.2
    local color = HSVToColor(setcolor,1,0.5)

    return color.r, color.g, color.b, color.a
end
SlashCoItems.Baby.IsSpawnable = true
SlashCoItems.Baby.OnUse = function(ply)
    --When used, half of the survivors health is consumed, and the survivor is teleported to a random location which is at least 2000u away from their currect position.
    --Activation takes 1 second. If the survivors health is lower than 51, the chance that the survivor will die upon use of the item will start increasing the lower their health.
    --(50 - 10%, 25 - 60% ,1 - 100%).
    --Using it will spawn a spent baby in the position the survivor used it.

    ply:EmitSound("slashco/survivor/baby_use.mp3")

    local deathchance = math.random(0, math.floor( ply:Health() / 5 ) )

    local hpafter = ply:Health() / 2

    ply:SetHealth( hpafter )

    timer.Simple(1, function()


        if ply:Health() < 51 then

            if deathchance < 2 then ply:Kill() return end

        end

        ply:SetPos( SlashCo.TraceHullLocator() )

    end)
end
SlashCoItems.Baby.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem(SlashCoItems.Baby.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
SlashCoItems.Baby.ViewModel = {
    model = "models/props_c17/doll01.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
