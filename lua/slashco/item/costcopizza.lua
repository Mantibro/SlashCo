local ITEM = {}

ITEM.Model = "models/slashco/costcopizza.mdl"
ITEM.Name = "Costco Frozen Pizza"
ITEM.EntClass = "sc_costcopizza"
ITEM.Price = 50
ITEM.Description = "CostcoPizza_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.ReplacesWorldProps = true
function ITEM.DisplayColor()
	return 128, 48, 0, 255
end
function ITEM.OnUse() -- You don't use it. You just hold it.
	return true
end
function ITEM.OnOwnerTakeDamage(owner, dmg)
	local rng = math.random(1, 4)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/concreteimpact" .. rng .. ".mp3", -- It's so cold that we consider it to be concrete at this point :hehe:
		identifier = "CostcoPizzaImpact" .. rng,
		minDistance = 400,
		maxDistance = 600,
		entity = self,
		volume = 0.9,
		fadeIn = 0,
		unreliable = true,
	})

	if math.random(1, 5) == 1 then
		SlashCo.RemoveItem(owner, false)

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/pizza_shatter.mp3",
			identifier = "CostcoShatter",
			minDistance = 700,
			maxDistance = 1000,
			entity = self,
			volume = 0.9,
			fadeIn = 0,
			unreliable = true,
		})
	end

	dmg:SetDamage(0)
	return true
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

SlashCo.RegisterItem(ITEM, "CostcoPizza")