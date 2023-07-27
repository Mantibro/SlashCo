local ITEM = SlashCoItems.Alcohol or {}
SlashCoItems.Alcohol = ITEM

ITEM.Model = "models/props_junk/garbage_glassbottle003a.mdl"
ITEM.Name = "Alcohol"
ITEM.EntClass = "sc_alcohol"
ITEM.Description = "Unfortunate."
ITEM.CamPos = Vector(30,0,0)
ITEM.ReplacesWorldProps = true
ITEM.IsSpawnable = true
ITEM.OnUse = function(ply)
	ply:EmitSound("slashco/survivor/soda_drink"..math.random(1,2)..".mp3")
	ply:AddEffect("Buzzed", 45)
end
ITEM.OnDrop = function(ply)
end
ITEM.DisplayColor = function()
	return 0, 128, 0, 255
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