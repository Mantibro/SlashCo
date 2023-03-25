local SlashCoItems = SlashCoItems

SlashCoItems.Cookie = {}
SlashCoItems.Cookie.Model = "models/slashco/items/cookie.mdl"
SlashCoItems.Cookie.EntClass = "sc_cookie"
SlashCoItems.Cookie.Name = "Cookie"
SlashCoItems.Cookie.Icon = "slashco/ui/icons/items/item_4"
SlashCoItems.Cookie.Price = 15
SlashCoItems.Cookie.Description = "A large chocolate chip cookie. Consuming it will grant you a speed boost\nfor a limited time. \nA certain Slasher seems to really like this item."
SlashCoItems.Cookie.CamPos = Vector(50,0,20)
SlashCoItems.Cookie.IsSpawnable = true
SlashCoItems.Cookie.OnUse = function(ply)
    --While the item is stored, a survivor can press R to consume it. It will set their sprint speed to 350 for 30 seconds.

    ply:SetRunSpeed( 350 )

    ply:EmitSound("slashco/survivor/eat_cookie.mp3")

    timer.Simple(30, function()

        ply:SetRunSpeed( 300 )

        ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

    end)

    SlashCoSlasher.Sid.SidRage(ply)
end
SlashCoItems.Cookie.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem(SlashCoItems.Cookie.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
SlashCoItems.Cookie.ViewModel = {
    model = "models/slashco/items/cookie.mdl",
    bone = "ValveBiped.Bip01_Spine4",
    pos = Vector(64, 0, -5),
    angle = Angle(45, -140, -60),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
