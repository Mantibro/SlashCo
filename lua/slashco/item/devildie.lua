local ITEM = {}

ITEM.Model = "models/slashco/items/devildie.mdl"
ITEM.EntClass = "sc_devildie"
ITEM.Name = "DevilDie"
ITEM.Icon = "slashco/ui/icons/items/item_10"
ITEM.Price = 40
ITEM.Description = "DevilDie_desc"
ITEM.CamPos = Vector(30,0,10)
ITEM.IsSpawnable = true

function ITEM.OnUse(ply)
	--[[

	Upon use, this item will apply a random effect from the set.
	-Spawn two Fuel Cans in front of the Survivor
	-Set their sprint speed to 450 for 45 seconds.
	-Heal the Survivor by 1-100
	-Damage the Survivor by 1-100
	-Teleport them 100u in front of the Slasher and hardlock their speed at 200 for 5 seconds.
	-Play a really loud sound which can be heard mapwide
	-Kill the Survivor

	]]

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/devildie_roll.mp3",
		identifier = "DevilDieRoll",
		minDistance = 400,
		maxDistance = 600,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(2, function()
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/survivor/devildie_break.mp3",
			identifier = "DevilDieBreak",
			minDistance = 400,
			maxDistance = 600,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})

		local rand = math.random(1, 6)

		if rand == 1 then
			SlashCo.CreateGasCan(ply:LocalToWorld(Vector(30, 20, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
			SlashCo.CreateGasCan(ply:LocalToWorld(Vector(30, -20, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/survivor/devildie_fuel.mp3",
				identifier = "DevilDieFuel",
				minDistance = 400,
				maxDistance = 600,
				entity = ply,
				volume = 1,
				fadeIn = 0,
			})
		elseif rand == 2 then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/survivor/devildie_speed.mp3",
				identifier = "DevilDieSpeed",
				minDistance = 400,
				maxDistance = 600,
				entity = ply,
				volume = 1,
				fadeIn = 0,
			})

			ply:AddEffect("Speed", 45)
		elseif rand == 3 then
			local hpd = math.random(-100, 100)

			if hpd + ply:Health() > 200 then
				hpd = 200 - ply:Health()
			elseif hpd <= ply:Health() then
				hpd = (-ply:Health()) + 1
			end

			ply:SetHealth(ply:Health() + hpd)

			if hpd <= 0 then
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/survivor/devildie_hurt.mp3",
					identifier = "DevilDieHurt",
					minDistance = 400,
					maxDistance = 600,
					entity = ply,
					volume = 1,
					fadeIn = 0,
				})

				local vPoint = ply:GetPos() + Vector(0, 0, 50)
				local bloodfx = EffectData()
				bloodfx:SetOrigin(vPoint)
				util.Effect("BloodImpact", bloodfx)
			end

			if hpd > 0 then
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/survivor/devildie_heal.mp3",
					identifier = "DevilDieHeal",
					minDistance = 400,
					maxDistance = 600,
					entity = ply,
					volume = 1,
					fadeIn = 0,
				})

				local vPoint = ply:GetPos() + Vector(0, 0, 50)
				local healfx = EffectData()
				healfx:SetOrigin(vPoint)
				util.Effect("TeslaZap", healfx)
			end
		elseif rand == 4 then
			local slasher = team.GetPlayers(TEAM_SLASHER)[1]
			if not IsValid(slasher) then return end

			ply:SetPos(slasher:LocalToWorld(Vector(100, 0, 10)))
			ply:AddEffect("Slowness", 5)
		elseif rand == 5 then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/survivor/devildie_siren.mp3",
				identifier = "DevilDieSiren",
				minDistance = 800 * SlashCo.MapSize,
				maxDistance = 1200 * SlashCo.MapSize,
				entity = ply,
				volume = 1,
				fadeIn = 0,
			})
		elseif rand == 6 then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/survivor/devildie_kill.mp3",
				identifier = "DevilDieKill",
				minDistance = 400,
				maxDistance = 600,
				entity = ply,
				volume = 1,
				fadeIn = 0,
			})

			timer.Simple(0.5, function()
				local vPoint = ply:GetPos() + Vector(0, 0, 50)
				local killfx = EffectData()
				killfx:SetOrigin(vPoint)
				util.Effect("HelicopterImpact", killfx)

				ply:Kill()
			end)
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
	pos = Vector(2, 3.5, -1.5),
	angle = Angle(200, 0, -20),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "DevilDie")