local ITEM = {}

ITEM.Model = "models/props_c17/doll01.mdl"
ITEM.EntClass = "sc_baby"
ITEM.Name = "Baby"
ITEM.Icon = "slashco/ui/icons/items/item_7"
ITEM.Price = 35
ITEM.Description = "Baby_desc"
ITEM.CamPos = Vector(50,0,0)
ITEM.IsSpawnable = true

function ITEM.DisplayColor(ply)
	local setcolor = 360 - math.Clamp(ply:Health(), 0, 100) * 1.2
	local color = HSVToColor(setcolor, 1, 0.5)

	return color.r, color.g, color.b, color.a
end

function ITEM.OnUse(ply)
	--When used, half of the survivors health is consumed, and the survivor is teleported to a random location which is at least 2000u away from their currect position.
	--Activation takes 1 second. If the survivors health is lower than 51, the chance that the survivor will die upon use of the item will start increasing the lower their health.
	--(50 - 10%, 25 - 60% ,1 - 100%).
	--Using it will spawn a spent baby in the position the survivor used it.

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/baby_use.mp3",
		identifier = "BabyUse",
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	local deathchance = math.random(0, math.floor(ply:Health() / 5))
	local hpafter = ply:Health() / 2

	ply:SetHealth(hpafter)

	timer.Simple(1, function()
		if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
			if ply:Health() < 51 and deathchance < 2 then
				ply:Kill()

				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/survivor/devildie_kill.mp3",
					identifier = "BabyKill",
					minDistance = 400,
					maxDistance = 600,
					entity = ply,
					volume = 1,
					fadeIn = 0,
				})

				local slasher = team.GetPlayers(TEAM_SLASHER)
				slasher = slasher[math.random(1, #slasher)] -- If there are multiple slasher's we need to be fair and pick a random one, the previous code always chose the second slasher.

				if IsValid(slasher) then
					slasher:RandomTeleport()

					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/survivor/baby_use.mp3",
						identifier = "BabyUse",
						minDistance = 400,
						maxDistance = 600,
						entity = slasher,
						volume = 1,
						fadeIn = 0,
					})
				end

				return
			end

			ply:RandomTeleport()
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

SlashCo.RegisterItem(ITEM, "Baby")