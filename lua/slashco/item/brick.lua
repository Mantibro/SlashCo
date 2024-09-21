local ITEM = {}

ITEM.Model = "models/props_junk/cinderblock01a.mdl"
ITEM.Name = "Brick"
ITEM.EntClass = "sc_brick"
ITEM.Price = 5
ITEM.Description = "Brick_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.ReplacesWorldProps = true
ITEM.DisplayColor = function()
	return 128, 48, 0, 255
end
ITEM.OnUse = function(ply)
	ply:EmitSound("Weapon_Crowbar.Miss")
	ply:ViewPunch(Angle(-10, 0, 0))
	local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
	droppeditem:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 1400)
	SlashCo.CurRound.Items[droppeditem:EntIndex()] = true

	droppeditem:SetCollisionGroup(COLLISION_GROUP_NONE)
	droppeditem:SetCustomCollisionCheck(true)
	timer.Simple(0.2, function()
		if not IsValid(droppeditem) then
			return
		end
		droppeditem:SetCustomCollisionCheck(false)
	end)
	timer.Simple(3, function()
		if not IsValid(droppeditem) then
			return
		end
		droppeditem:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
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

SlashCo.RegisterItem(ITEM, "Brick")

hook.Add("ShouldCollide", "SlashCo_CinderBlockCollision", function(ent1, ent2)
	if ent1:GetClass() == "sc_brick" and ent2:IsPlayer() and ent2:Team() == TEAM_SURVIVOR then
		return false
	end
	if ent2:GetClass() == "sc_brick" and ent1:IsPlayer() and ent1:Team() == TEAM_SURVIVOR then
		return false
	end
end)
