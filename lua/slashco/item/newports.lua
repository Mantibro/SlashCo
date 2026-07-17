local ITEM = {}

ITEM.Model = "models/slashco/newports.mdl"
ITEM.Name = "Newports"
ITEM.EntClass = "sc_newports"
ITEM.Price = 40
ITEM.Description = "Newports_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply) -- Unlike in SlashCo VR, this item will decrease the fog.
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/newports_eat.ogg",
		identifier = "NewportsEat",
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 0.8,
		fadeIn = 0,
	})
	
	SlashCo.AddFog({
		name = "Newports",
		multiplier = 3,
		priority = 1,
		fogType = SlashCo.FogType.PLAYER,
		entity = ply,
	})

	local duration = math.random(140, 200)

	duration = SlashCo.GetConsumableEffectDuration(ply, duration)

	timer.Simple(duration, function()
		if not IsValid(ply) then return end

		SlashCo.RemoveFog("Newports", ply)
	end)
end

ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(45, -70, -120),
	size = Vector(1, 1, 1),
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

SlashCo.RegisterItem(ITEM, "Newports")