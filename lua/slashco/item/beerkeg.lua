local ITEM = {}

ITEM.Model = "models/slashco/beerkeg.mdl"
ITEM.Name = "Beer Keg"
ITEM.EntClass = "sc_beerkeg"
ITEM.Price = 30
ITEM.Description = "BeerKeg_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.IsSpawnable = true
function ITEM.DisplayColor()
	return 128, 48, 0, 255
end
function ITEM.OnUse(ply)
	ply:EmitSound("Weapon_Crowbar.Miss")
	ply:ViewPunch(Angle(-10, 0, 0))
	local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:EyePos() + ply:GetAimVector(), ply:LocalToWorldAngles(Angle(0, 0, 0)))
	droppeditem:SetBeerKegVelocity(ply:GetAimVector() * 150)
	SlashCo.CurRound.Items[droppeditem:EntIndex()] = true
	droppeditem:SetOwner(ply)
end
ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(45, -70, -120),
	size = Vector(0.4, 0.4, 0.4),
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
	size = Vector(0.5, 0.5, 0.5),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "duel",
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(1, 10.0, -1),
	angle = Angle(180, 0, 0),
	size = Vector(0.7, 0.7, 0.7),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "BeerKeg")