local ITEM = {}

ITEM.Model = "models/slashco/items/annoyingorange.mdl"
ITEM.EntClass = "sc_orange"
ITEM.Name = "Orange"
ITEM.Icon = "slashco/ui/icons/items/item_4"
ITEM.Price = 40
ITEM.Description = "Orange_desc"
ITEM.CamPos = Vector(50,0,20)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	if GameData.IsLobby then return end

	SlashCo.AudioSystem.PlaySound({
		soundPath = SlashCo.AudioSystem.GetSoundFileFromSource("Weapon_Crowbar.Single"),
		identifier = "OrangeThrow",
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	ply:SetNWBool("HoldingOrange", false)
	ply:ViewPunch(Angle(-10, 0, 0))
	local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:EyePos() + ply:GetAimVector(), ply:LocalToWorldAngles(Angle(0, 0, 0)))
	droppeditem:SetOrangeVelocity(ply:GetAimVector() * 150)
	SlashCo.CurRound.Items[droppeditem:EntIndex()] = true
	droppeditem:SetOwner(ply)
end

function ITEM.OnDie(ply)
	ply:SetNWBool("HoldingOrange", false)
end

function ITEM.OnDrop(ply)
	ply:SetNWBool("HoldingOrange", false)
end

function ITEM.OnPickUp(ply)
	ITEM.Orange(ply)
	ply:SetNWBool("HoldingOrange", true)
end

function ITEM.Orange(ply)
	local idx = math.random(1, 9)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/items/orange/orange_yap" .. idx .. ".mp3",
		identifier = "OrangeVoice" .. idx,
		minDistance = 200,
		maxDistance = 800,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(math.random(7, 15), function()
		if not IsValid(ply) then return end
		if not ply:GetNWBool("HoldingOrange") then return end

		ITEM.Orange(ply)
	end)
end

ITEM.ViewModel = {
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_Spine4",
	pos = Vector(64, 0, -5),
	angle = Angle(90, -10, -70),
	size = Vector(0.7, 0.7, 0.7),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModelHolstered = {
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_Head1",
	pos = Vector(3, 4.5, 0),
	angle = Angle(90, 105, 0),
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
	pos = Vector(3, 5, -1),
	angle = Angle(-80, 0, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Orange")