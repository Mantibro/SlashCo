local ITEM = {}

ITEM.Model = "models/slashco/items/amborgeza.mdl"
ITEM.EntClass = "sc_crazyburger"
ITEM.Name = "Burger"
ITEM.Icon = "slashco/ui/icons/items/item_4"
ITEM.Price = 30
ITEM.Description = "Burger_desc"
ITEM.CamPos = Vector(50,0,20)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	SlashCo.AudioSystem.PlaySound({
		soundPath = SlashCo.AudioSystem.GetSoundFileFromSource("Weapon_Crowbar.Single"),
		identifier = "BurgerUse",
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	ply:ViewPunch(Angle(-10, 0, 0))
	local droppeditem = SlashCo.CreateItem("sc_activecrazyburger", ply:EyePos() + ply:GetAimVector(), ply:LocalToWorldAngles(Angle(0, 0, 0)))
	droppeditem:SetBurgerVelocity(ply:GetAimVector() * 500)
	droppeditem:SetOwner(ply)
end

ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(-40, -90, -120),
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
	angle = Angle(180, -50, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Burger")