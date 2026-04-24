local ITEM = {}

ITEM.Model = "models/slashco/items/cocacola.mdl"
ITEM.Name = "CocaCola"
ITEM.EntClass = "sc_cocacola"
ITEM.Price = 60
ITEM.Description = "CocaCola_desc"
ITEM.CamPos = Vector(150, 0, 0)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	local idx = math.random(1, 2)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/items/coca/cocacolaopen" .. idx .. ".mp3",
		identifier = "CocaColaOpen" .. idx,
		minDistance = 200,
		maxDistance = 500,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(1, function()
		if not IsValid(ply) then return end

		SlashCo.AudioSystem.PlaySound({
			soundPath = SlashCo.AudioSystem.GetSoundFileFromSource("Weapon_Crowbar.Single"),
			identifier = "BeerKegThrow",
			minDistance = 400,
			maxDistance = 600,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})

		ply:ViewPunch(Angle(-10, 0, 0))
		local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:EyePos() + ply:GetAimVector(), ply:LocalToWorldAngles(Angle(0, 0, 0)))
		droppeditem:SetColaVelocity(ply:GetAimVector() * 150)
		SlashCo.CurRound.Items[droppeditem:EntIndex()] = true
		droppeditem:SetOwner(ply)
		droppeditem:WarningSound()

		if math.random(1, 200) == 1 then
			droppeditem:Explode()
		end
	end)
end

function ITEM.OnPickUp(ply)
	SlashCo.AudioSystem.StopSound("CocaColaIdle", 0, ply)
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

SlashCo.RegisterItem(ITEM, "CocaCola")