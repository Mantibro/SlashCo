local ITEM = {}

ITEM.Model = "models/slashco/items/deathward.mdl"
ITEM.EntClass = "sc_deathward"
ITEM.Name = "Deathward"
ITEM.Icon = "slashco/ui/icons/items/item_2"
ITEM.Price = 80
ITEM.Description = "Deathward_desc"
ITEM.CamPos = Vector(40, 0, 15)
function ITEM.MaxAllowed()
	return 2
end
ITEM.IsSpawnable = true
function ITEM.OnDie(ply)
	SlashCo.ChangeSurvivorItem(ply, "DeathWard (Used)", true)
	local pos = ply:WorldSpaceCenter()
	SlashCo.DropItem(ply, function(ply, item, droppedItem, phys)
		phys:SetPos(pos, true)
		phys:SetVelocityInstantaneous(vector_origin)
	end)

	ply:SetVisible(false)
	ply:SetImpervious(true)
	ply:GodEnable()
	ply:Freeze(true)

	ply:SetNW2Bool("ShowDeathUI", true)
	ply:SetNW2Bool("DeathWardUI", true)
	ply:SetNW2Float("DeathUITime", CurTime())

	timer.Simple(9, function()
		if not IsValid(ply) then return end

		local spawnEnt = SlashCo.FindSpawn(ply)
		SlashCo.AudioSystem.PlaySound({ -- Leak the location of the player that respawned to everyone >:3
			soundPath = "slashco/survivor/deathward.mp3",
			identifier = "DeathWard",
			position = IsValid(spawnEnt) and spawnEnt:GetPos() or ply:GetPos(),
			minDistance = 2500,
			maxDistance = 15000,
			volume = 1,
			fadeIn = 0,
		})

		timer.Simple(1, function()
			if not IsValid(ply) then return end

			ply:SetNW2Bool("ShowDeathUI", false)
			ply:SetNW2Bool("DeathWardUI", false)

			ply:SetVisible(true)
			ply:SetImpervious(false)
			ply:GodDisable()
			ply:Freeze(false)
		end)
	end)

	return true
end
function ITEM.OnSwitchFrom(ply)
	timer.Remove("deathWardDamage_" .. ply:UserID())
end
function ITEM.OnPickUp(ply)
	if GameData.IsLobby then
		return
	end

	local userid = ply:UserID()
	timer.Create("deathWardDamage_" .. userid, 30, 0, function()
		if not IsValid(ply) then
			timer.Remove("deathWardDamage_" .. userid)
			return
		end

		local hp = ply:Health()
		if hp >= 100 then
			return
		end
		ply:SetHealth(hp + 1)
	end)
end
ITEM.ViewModel = {
	model = "models/slashco/items/deathward.mdl",
	pos = Vector(64, 0, -6),
	angle = Angle(45, -70, -120),
	size = Vector(0.5, 0.5, 0.5),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = { [0] = 0 }
}
ITEM.WorldModelHolstered = {
	model = "models/slashco/items/deathward.mdl",
	bone = "ValveBiped.Bip01_Pelvis",
	pos = Vector(5, 2, 5),
	angle = Angle(110, -80, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = { [0] = 0 }
}
ITEM.WorldModel = {
	holdtype = "slam",
	model = "models/slashco/items/deathward.mdl",
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(4, 1, -2),
	angle = Angle(10, -20, 200),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = { [0] = 0 }
}

SlashCo.RegisterItem(ITEM, "DeathWard")