local ITEM = {}

ITEM.Model = "models/slashco/newports.mdl"
ITEM.Name = "Newport Menthols"
ITEM.EntClass = "sc_newports"
ITEM.Price = 40
ITEM.Description = "Newports_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.IsSpawnable = true
function ITEM.DisplayColor()
	return 128, 48, 0, 255
end
function ITEM.OnUse(ply) -- Unlike in SlashCo VR, this item will decrease the fog.
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/newports_eat.ogg", -- It's so cold that we consider it to be concrete at this point :hehe:
		identifier = "NewportsEat",
		minDistance = 300,
		maxDistance = 500,
		entity = self,
		volume = 0.8,
		fadeIn = 0,
	})

	GameData.ClientSideFogMult = 5

	timer.Simple(math.random(140, 200), function()
		if GameData.ClientSideFogMult != 5 then return end -- Something overwrote us? ok... us sad now :cry:

		GameData.ClientSideFogMult = nil
	end)
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

SlashCo.RegisterItem(ITEM, "Newports")