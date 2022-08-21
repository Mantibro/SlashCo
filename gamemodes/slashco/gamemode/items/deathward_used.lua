local SlashCoItems = SlashCoItems

SlashCoItems.DeathWardUsed = {}
SlashCoItems.DeathWardUsed.Model = "models/slashco/items/deathward.mdl"
SlashCoItems.DeathWardUsed.Name = "Death Ward"
SlashCoItems.DeathWardUsed.Icon = "slashco/ui/icons/items/item_2_99"
SlashCoItems.DeathWardUsed.Description = "You broke it!"
SlashCoItems.DeathWardUsed.CamPos = Vector(40,0,15)
SlashCoItems.DeathWardUsed.DisplayColor = function()
    return 128, 0, 0, 255
end
SlashCoItems.DeathWardUsed.ViewModel = {
    model = "models/slashco/items/deathward.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {1}
}