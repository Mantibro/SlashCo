local ITEM = {}

ITEM.Model = "models/slashco/items/flare.mdl"
ITEM.Name = "Flare"
ITEM.EntClass = "sc_flare"
ITEM.Icon = "slashco/ui/icons/items/item_1"
ITEM.Price = 5
ITEM.Description = "Flare_desc"
ITEM.ReplacesWorldProps = true
ITEM.CamPos = Vector(50,0,20)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	local flare = SlashCo.CreateItem("sc_flare", ply:LocalToWorld( Vector(0, 0, 30) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))
	flare:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 400)
	flare:SetNWBool("FlareActive", true)
	flare:SetNWString("FlareDropperName", ply:Nick())

	SlashCo.AudioSystem.PlaySound({
		soundPath = "weapons/flaregun/burn.wav",
		identifier = "FlareActive",
		minDistance = 200,
		maxDistance = 800,
		entity = flare,
		volume = 1,
		fadeIn = 0,
	})

	SlashCo.CurRound.Items[flare:EntIndex()] = true
end

ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 2, -5),
	angle = Angle(120, -120, -80),
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
	angle = Angle(100, -80, 0),
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
	pos = Vector(3.2, 2, -1),
	angle = Angle(200, 85, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Flare")