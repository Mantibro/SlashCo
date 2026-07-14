local ITEM = {}

ITEM.Model = "models/dog.mdl"
ITEM.EntClass = "sc_merlton"
ITEM.Name = "MERLT0N"
ITEM.Icon = "slashco/ui/icons/items/item_merlton"
ITEM.Price = 100
ITEM.Description = "MERLT0N_desc"
ITEM.CamPos = Vector(100, 200, 300)
ITEM.IsSpawnable = false

function ITEM.OnUse(ply)
	local ent = SlashCo.CreateItem("sc_merlton", ply:WorldSpaceCenter(), Angle(0, 0, 0))
	ent:DropToFloor()
end

ITEM.ViewModel = {
	type = "Model",
	model = ITEM.Model,
	rel = "",
	pos = Vector(30, -25, -5),
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
	bone = "ValveBiped.Bip01_Spine2",
	pos = Vector(-3, 5, 4),
	angle = Angle(0, -0, 0),
	size = Vector(0.4, 0.4, 0.4),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "passive",
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(3, 2, 0),
	angle = Angle(0, -20, 180),
	size = Vector(0.3, 0.3, 0.3),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, ITEM.Name)