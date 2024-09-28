local ITEM = {}

ITEM.Model = "models/slashco/items/deathward.mdl"
ITEM.EntClass = "sc_deathward"
ITEM.Name = "Deathward"
ITEM.Icon = "slashco/ui/icons/items/item_2"
ITEM.Price = 50
ITEM.Description = "Deathward_desc"
ITEM.CamPos = Vector(40, 0, 15)
ITEM.MaxAllowed = function()
	return 2
end
ITEM.IsSpawnable = true
ITEM.OnDie = function(ply)
	ply:EmitSound("slashco/survivor/deathward.mp3")
	ply:EmitSound("slashco/survivor/deathward_break" .. math.random(1, 2) .. ".mp3")

	SlashCo.ChangeSurvivorItem(ply, "DeathWardUsed")

	return true
end
ITEM.OnSwitchFrom = function(ply)
	timer.Remove("deathWardDamage_" .. ply:UserID())
end
ITEM.OnPickUp = function(ply)
	if game.GetMap() == "sc_lobby" then
		return
	end

	local userid = ply:UserID()
	timer.Create("deathWardDamage_" .. userid, 30, 0, function()
		if not IsValid(ply) then
			timer.Remove("deathWardDamage_" .. userid)
			return
		end

		local hp = ply:Health()
		if hp >= 100 then
			return
		end
		ply:SetHealth(hp + 1)
	end)
end
ITEM.ViewModel = {
	model = "models/slashco/items/deathward.mdl",
	pos = Vector(64, 0, -6),
	angle = Angle(45, -70, -120),
	size = Vector(0.5, 0.5, 0.5),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = { [0] = 0 }
}
ITEM.WorldModelHolstered = {
	model = "models/slashco/items/deathward.mdl",
	bone = "ValveBiped.Bip01_Pelvis",
	pos = Vector(5, 2, 5),
	angle = Angle(110, -80, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = { [0] = 0 }
}
ITEM.WorldModel = {
	holdtype = "slam",
	model = "models/slashco/items/deathward.mdl",
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(4, 1, -2),
	angle = Angle(10, -20, 200),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = { [0] = 0 }
}

SlashCo.RegisterItem(ITEM, "DeathWard")