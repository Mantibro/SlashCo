local SlashCoItems = SlashCoItems

SlashCoItems.GasCan = {}
SlashCoItems.GasCan.Model = "models/props_junk/metalgascan.mdl"
SlashCoItems.GasCan.Name = "Gas Can"
SlashCoItems.GasCan.Icon = "slashco/ui/icons/items/item_1"
SlashCoItems.GasCan.Price = 15
SlashCoItems.GasCan.Description = "A jerry can full of high-octane gas. Useful for refuelling Cars and \nGenerators. Taking it with you will reduce how much gas you will find\nwithin the Zone. \nOnce you drop this item, you will not be able to store it again."
SlashCoItems.GasCan.CamPos = Vector(80,0,0)
SlashCoItems.GasCan.OnDrop = function(ply)
    SlashCo.CreateGasCan(ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
end
SlashCoItems.GasCan.OnBuy = function(_)
    SlashCo.LobbyData.SurvivorGasMod = SlashCo.LobbyData.SurvivorGasMod + 1
end