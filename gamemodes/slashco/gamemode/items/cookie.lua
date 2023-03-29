local SlashCoItems = SlashCoItems

SlashCoItems.Cookie = SlashCoItems.Cookie or {}
SlashCoItems.Cookie.Model = "models/slashco/items/cookie.mdl"
SlashCoItems.Cookie.EntClass = "sc_cookie"
SlashCoItems.Cookie.Name = "Cookie"
SlashCoItems.Cookie.Icon = "slashco/ui/icons/items/item_4"
SlashCoItems.Cookie.Price = 15
SlashCoItems.Cookie.Description = "Gain a temporary bonus to fuel pouring on use.\nA certain Slasher seems to really like this item."
SlashCoItems.Cookie.CamPos = Vector(50,0,20)
SlashCoItems.Cookie.IsSpawnable = true
SlashCoItems.Cookie.OnUse = function(ply)

    ply:SetNWBool("CookieEaten", true)

    ply:EmitSound("slashco/survivor/eat_cookie.mp3")

    timer.Simple(30, function()

        ply:SetNWBool("CookieEaten", false)

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
