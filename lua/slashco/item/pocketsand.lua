local ITEM = {}

ITEM.Model = "models/slashco/items/pocketsand.mdl"
ITEM.EntClass = "sc_pocketsand"
ITEM.Name = "PocketSand"
ITEM.Icon = "slashco/ui/icons/items/item_1"
ITEM.Price = 30
ITEM.Description = "PocketSand_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	-- RaphaelIT7: We use their center to be more accurate of the origin of the particles & as the origin to find all slashers.
	local particlePos = ply:WorldSpaceCenter()
	local found = SlashCo.FindPlayersInRange(particlePos, 200, TEAM_SLASHER, ply)
	if table.IsEmpty(found) then
		return true
	end

	GameData.PocketSandID = (GameData.PocketSandID or 0) + 1
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/pocketsand_throw" .. math.random(1, 2) .. ".mp3",
		identifier = "PocketSandThrow" .. GameData.PocketSandID,
		minDistance = 200,
		maxDistance = 400,
		position = particlePos,
		volume = 1,
		fadeIn = 0,
	})

	GameData.PocketSandID = (GameData.PocketSandID or 0) + 1
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/pocketsand_linger.mp3",
		identifier = "PocketSandLinger" .. GameData.PocketSandID,
		minDistance = 200,
		maxDistance = 400,
		position = particlePos,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(0, function() -- Something causes particles to be nuked >:(
		ParticleEffect("pocketsand", particlePos, angle_zero)
	end)

	for _, slasher in ipairs(found) do
		slasher:SetNWBool("SlasherBlinded", true)
		slasher:SlasherFunction("OnHitByPocketSand", ply)
	end

	timer.Simple(8, function()
		for _, slasher in ipairs(found) do
			if not IsValid(slasher) then continue end
			slasher:SetNWBool("SlasherBlinded", false)
		end
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
	angle = Angle(180, 0, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "PocketSand")

