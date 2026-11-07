local ITEM = {}

ITEM.Model = "models/props_junk/glassjug01.mdl"
ITEM.Name = "Alcohol"
ITEM.EntClass = "sc_alcohol"
ITEM.Description = "Unfortunate."
ITEM.CamPos = Vector(30, 0, 0)
ITEM.ReplacesWorldProps = true
ITEM.IsSpawnable = true
ITEM.UseEffect = "Buzzed"

function ITEM.OnUsePredicted(ply)
	local idx = math.random(1, 2)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/soda_drink" .. idx .. ".mp3",
		identifier = "MoonshineUse" .. idx,
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
		excludeSendTo = ply,
	})
end

function ITEM.OnUse(ply)
	ITEM.OnUsePredicted(ply)

	ply:AddEffect(ITEM.UseEffect, SlashCo.GetConsumableEffectDuration(ply, 45))
end

ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(62, 0, -6),
	angle = Angle(45, -70, -120),
	size = Vector(0.5, 0.5, 0.5),
	color = Color(121, 68, 59),
	surpresslightning = false,
	material = "models/shiny",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModelHolstered = {
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_Pelvis",
	pos = Vector(5, 5, 8),
	angle = Angle(110, -80, 0),
	size = Vector(1, 1, 1),
	color = Color(121, 68, 59),
	surpresslightning = false,
	material = "models/shiny",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "slam",
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(3, 2.5, 10),
	angle = Angle(180, 0, 0),
	size = Vector(1, 1, 1),
	color = Color(121, 68, 59),
	surpresslightning = false,
	material = "models/shiny",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Alcohol")