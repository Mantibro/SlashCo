local SlashCo = SlashCo

SlashCo.Items.GasCan.Model = SlashCo.GasCanModel
SlashCo.Items.GasCan.Name = "Gas Can"
SlashCo.Items.GasCan.Icon = "slashco/ui/icons/items/item_1"
SlashCo.Items.GasCan.Price = 15
SlashCo.Items.GasCan.Description = "A jerry can full of high-octane gas. Useful for refuelling Cars and \nGenerators. Taking it with you will reduce how much gas you will find\nwithin the Zone. \nOnce you drop this item, you will not be able to store it again."
SlashCo.Items.GasCan.CamPos = Vector(80,0,0)
SlashCo.Items.GasCan.OnDrop = function(ply)
    SlashCo.CreateGasCan(ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
end