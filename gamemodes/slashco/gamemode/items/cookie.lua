local SlashCo = SlashCo

SlashCo.Items.Cookie.Model = "models/slashco/items/cookie.mdl"
SlashCo.Items.Cookie.Name = "Cookie"
SlashCo.Items.Cookie.Icon = "slashco/ui/icons/items/item_4"
SlashCo.Items.Cookie.Price = 15
SlashCo.Items.Cookie.Description = "A large chocolate chip cookie. Consuming it will grant you a speed boost\nfor a limited time. \nA certain Slasher seems to really like this item."
SlashCo.Items.Cookie.CamPos = Vector(50,0,20)
SlashCo.Items.Cookie.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their sprint speed to 350 for 30 seconds.

    ply:SetRunSpeed( 350 )

    ply:EmitSound("slashco/survivor/eat_cookie.mp3")

    timer.Simple(30, function()

        ply:SetRunSpeed( 300 )

        ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

    end)

    SlashCo.SidRage(ply)
end
SlashCo.Items.Cookie.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_cookie", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
end