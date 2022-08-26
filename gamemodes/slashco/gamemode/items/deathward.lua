local SlashCoItems = SlashCoItems

SlashCoItems.DeathWard = {}
SlashCoItems.DeathWard.Model = "models/slashco/items/deathward.mdl"
SlashCoItems.DeathWard.Name = "Deathward"
SlashCoItems.DeathWard.Icon = "slashco/ui/icons/items/item_2"
SlashCoItems.DeathWard.Price = 50
SlashCoItems.DeathWard.Description = "A ceramic, skull-shaped charm. Will save you from certain death,\nbut only once. Your team can only have a limited amount of them.\nThis item will take up your Item Slot, even if spent."
SlashCoItems.DeathWard.CamPos = Vector(40,0,15)
SlashCoItems.DeathWard.MaxAllowed = function()
    return 2
end
SlashCoItems.DeathWard.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_deathward", ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
SlashCoItems.DeathWard.OnDie = function(ply)
    ply:EmitSound( "slashco/survivor/deathward.mp3")
    ply:EmitSound( "slashco/survivor/deathward_break"..math.random(1,2)..".mp3")

    SlashCo.RespawnPlayer(ply)

    SlashCo.ChangeSurvivorItem(ply, "DeathWardUsed")

    return true
end
SlashCoItems.DeathWard.ViewModel = {
    model = "models/slashco/items/deathward.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
