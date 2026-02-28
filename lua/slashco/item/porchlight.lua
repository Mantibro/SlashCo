local ITEM = {}

ITEM.Model = "models/slashco/porchlight.mdl"
ITEM.Name = "PorchLight"
ITEM.EntClass = "sc_porchlight"
ITEM.Price = 150
ITEM.Description = "PorchLight_desc"
ITEM.CamPos = Vector(150, 0, 0)

function ITEM.DisplayColor()
	return 128, 48, 0, 255
end
function ITEM.OnUse(ply)
	ply:EmitSound("Weapon_Crowbar.Miss")
	ply:ViewPunch(Angle(-10, 0, 0))
	local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:EyePos() + ply:GetAimVector(), ply:LocalToWorldAngles(Angle(0, 0, 0)))
	SlashCo.CurRound.Items[droppeditem:EntIndex()] = true
	droppeditem:SetOwner(ply)
	droppeditem:DropToFloor()
	droppeditem:BecomeTheSun()
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

SlashCo.RegisterItem(ITEM, "PorchLight")