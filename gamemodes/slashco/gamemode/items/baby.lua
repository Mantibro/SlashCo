local SlashCoItems = SlashCoItems

SlashCoItems.Baby = {}
SlashCoItems.Baby.Model = "models/props_c17/doll01.mdl"
SlashCoItems.Baby.Name = "The Baby"
SlashCoItems.Baby.Icon = "slashco/ui/icons/items/item_7"
SlashCoItems.Baby.Price = 35
SlashCoItems.Baby.Description = "A decrepit-looking doll of a baby. Upon use, this item will halve your \nhealth and teleport you away from the slasher. \nThe lower your health, the more likely you are to\nsuffer a premature death upon use."
SlashCoItems.Baby.CamPos = Vector(50,0,0)
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
    local droppeditem = SlashCo.CreateItem("sc_baby", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
end