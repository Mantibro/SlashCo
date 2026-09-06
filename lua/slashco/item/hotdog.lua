local ITEM = {}

ITEM.Model = "models/slashco/items/meal_hotdog.mdl"
ITEM.Name = "Hotdog"
ITEM.EntClass = "sc_hotdog"
ITEM.Icon = "slashco/ui/icons/items/item_1"
ITEM.Description = "Hotdog_desc"
ITEM.CamPos = Vector(50,0,20)
ITEM.IsSpawnable = false
function ITEM.OnUse(ply)
	local hp = ply:Health()

	ply:EmitSound("slashco/survivor/eat_hotdog.mp3")
	ply:AddEffect("Speed", 5)

	if ply:Health() < 100 then
		ply:SetHealth(hp + 40)
	end
end
ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 2, -5),
	angle = Angle(120, -120, -80),
	size = Vector(0.5, 0.5, 0.5),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModelHolstered = {
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_Pelvis",
	pos = Vector(5, 2, 5),
	angle = Angle(100, -80, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "slam",
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(3.2, 2, -1),
	angle = Angle(200, 85, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Hotdog")