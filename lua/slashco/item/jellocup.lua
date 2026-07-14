local ITEM = {}

ITEM.Model = "models/slashco/jellocup.mdl"
ITEM.Name = "JelloCup"
ITEM.EntClass = "sc_jellocup"
ITEM.Price = 70
ITEM.Description = "JelloCup_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	-- RaphaelIT7: Yes, it's intentional that it can go over the max health! It's limited to 1.5x of the max health
	local maxHealth = ply:GetMaxHealth()
	local healAmount = maxHealth / 3

	if SlashCo.GetFoodHealMultiplier then
		healAmount = healAmount * SlashCo.GetFoodHealMultiplier(ply)
	end

	ply:SetHealth(math.min(ply:Health() + healAmount, maxHealth * 1.5))

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/eat_mayo.mp3",
		identifier = "JelloUse",
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	ply:AddEffect("Resistance", math.random(20, 50))
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