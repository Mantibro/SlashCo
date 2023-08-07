local ITEM = {}

ITEM.Model = "models/slashco/items/labmeat.mdl"
ITEM.Name = "LabMeat"
ITEM.EntClass = "sc_labmeat"
ITEM.Price = 35
ITEM.Description = "LabMeat_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.IsSpawnable = true
ITEM.OnDrop = function()
	return nil, nil, true
end
ITEM.ItemDropped = function(ply, ent)
	local physCount = ent.ragdoll:GetPhysicsObjectCount()
	for i = 0, (physCount - 1) do
		local PhysBone = ent.ragdoll:GetPhysicsObjectNum(i)

		if PhysBone:IsValid() then
			PhysBone:SetVelocity(ply:GetAimVector() * 150)
			PhysBone:AddAngleVelocity(VectorRand(-5, 5))
		end
	end
end
ITEM.OnUse = function(ply)
	ply:EmitSound("slashco/survivor/benadryl_eat.mp3")
	ply:EmitSound("slashco/slasher/amogus_transform" .. math.random(1, 2) .. ".mp3")
	ply:AddEffect("Awareness", 120)
end
ITEM.OnSetModel = function(model)
	model:SetSequence(0)
end
ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(130, 50, 120),
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
	pos = Vector(6, 2, 6),
	angle = Angle(60, -60, -60),
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
	pos = Vector(4, 5, -1.5),
	angle = Angle(180, 0, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "LabMeat")