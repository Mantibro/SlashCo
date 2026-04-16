local ITEM = {}

ITEM.Model = "models/slashco/items/bgonesoda.mdl"
ITEM.Name = "Soda"
ITEM.EntClass = "sc_soda"
ITEM.Icon = "slashco/ui/icons/items/item_8"
ITEM.Price = 20
ITEM.Description = "Soda_desc"
ITEM.CamPos = Vector(30,0,0)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	local idx = math.random(1, 2)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/soda_drink" .. idx .. ".mp3",
		identifier = "SodaUse" .. idx,
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	ply:AddEffect("Invisibility", 30)
end

ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(45, -70, -120),
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
	angle = Angle(110, -80, 0),
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
	pos = Vector(3, 2.5, -1),
	angle = Angle(180, 0, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Soda")