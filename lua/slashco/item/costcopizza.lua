local ITEM = {}

ITEM.Model = "models/slashco/costcopizza.mdl"
ITEM.Name = "CostcoPizza"
ITEM.EntClass = "sc_costcopizza"
ITEM.Price = 50
ITEM.Description = "CostcoPizza_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	if not SlashCo.IsActivePerk(ply, "Healthy") then
		return true
	end

	local maxHealth = ply:GetMaxHealth()
	local healAmount = maxHealth / 4
	ply:SetHealth(math.min(ply:Health() + healAmount, maxHealth))

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/eat_cookie.mp3",
		identifier = "CostcoPizzaEat",
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	return false
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
	})

	if math.random(1, 3) == 1 or dmg:GetDamage() > 100 then
		SlashCo.RemoveItem(owner, false)

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/pizza_shatter.mp3",
			identifier = "CostcoShatter",
			minDistance = 700,
			maxDistance = 1000,
			entity = self,
			volume = 0.9,
			fadeIn = 0,
		})
	end

	-- if damage is above 200 it must be an insta kill. GG No save for you. Else we'll block it. Insta kill often is around 9999 damage
	if dmg:GetDamage() < 200 then
		dmg:SetDamage(0)
		return true
	end
end

ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, 0),
	angle = Angle(90, -90, -200),
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
	angle = Angle(-80, 0, 0),
	size = Vector(1, 1, 1),
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
	pos = Vector(1, 9.0, -1),
	angle = Angle(75, -10, 0),
	size = Vector(1.3, 1.3, 1.3),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "CostcoPizza")