local ITEM = {}

ITEM.Model = "models/props_c17/utilityconnecter006c.mdl"
ITEM.EntClass = "sc_teslacoil"
ITEM.Name = "TeslaCoil"
ITEM.Icon = "slashco/ui/icons/items/item_teslacoil"
ITEM.Price = 150
ITEM.Description = "TeslaCoil_desc"
ITEM.CamPos = Vector(110, 0, 80)
ITEM.IsSpawnable = false
ITEM.ViewModel = {
	type = "Model",
	model = ITEM.Model,
	rel = "",
	pos = Vector(60, 0, -4),
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

function ITEM.OnUse(ply)
	--If the holder of the item is the last one alive and at least one generator has been activated, the rescue helicopter will come prematurely.

	local ent = SlashCo.CreateItem("sc_activeteslacoil", ply:WorldSpaceCenter(), Angle(0, 0, 0))
	ent:DropToFloor()
end

function ITEM.MaxAllowed()
	return 1
end

SlashCo.RegisterItem(ITEM, ITEM.Name)