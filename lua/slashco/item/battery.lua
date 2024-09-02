local ITEM = {}

ITEM.IsSecondary = true
ITEM.Model = "models/items/car_battery01.mdl"
ITEM.Name = "Battery"
ITEM.EntClass = "sc_battery"
ITEM.Description = "Battery_desc"
ITEM.CamPos = Vector(80,0,0)
ITEM.IsSpawnable = false
ITEM.IsBattery = true
ITEM.OnDrop = function(ply)
	return 55
end
ITEM.ViewModel = {
	model = "models/items/car_battery01.mdl",
	pos = Vector(63, 0, 0),
	angle = Angle(0, 90, 90),
	size = Vector(0.5, 0.5, 0.5),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "duel",
	model = "models/items/car_battery01.mdl",
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(-2.5, 11, -3),
	angle = Angle(0, -10, 180),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Battery")