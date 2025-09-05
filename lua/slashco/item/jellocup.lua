local ITEM = {}

ITEM.Model = "models/slashco/jellocup.mdl"
ITEM.Name = "JelloCup (Unfinished)" -- ToDo (Unfinished), still need to finish the ITEM.OnUse function
ITEM.EntClass = "sc_jellocup"
ITEM.Price = 150
ITEM.Description = "JelloCup_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.ReplacesWorldProps = true
function ITEM.DisplayColor()
	return 128, 48, 0, 255
end
function ITEM.OnUse(ply)

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
	pos = Vector(10, 2, 5),
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
	pos = Vector(1, 4.5, -1),
	angle = Angle(180, 0, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "JelloCup")