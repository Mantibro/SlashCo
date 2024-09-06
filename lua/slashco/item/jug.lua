local ITEM = {}

ITEM.Model = "models/slashco/items/jug.mdl"
ITEM.Name = "Jug"
ITEM.EntClass = "sc_jug"
ITEM.Price = 7
ITEM.Description = "Jug_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.ChangesSpeed = true
ITEM.IsSpawnable = true

ITEM.PrePickUpSecondary = function(ply, item, id)
	if item ~= "GasCan" then
		return
	end

	local ent = Entity(id)

	if not ply:GetNWBool("CurseOfTheJug") or not ent:GetNWBool("JugCursed") then
		return
	end

	ent:RandomTeleport(Vector(0, 0, 50))
	ent:SetNWBool("JugCursed", false)

	ply:SetNWBool("JugCurseActivate", true)

	timer.Simple(6, function()
		if IsValid(ply) then
			ply:SetNWBool("JugCurseActivate", false)
		end
	end)

	return true
end

ITEM.OnSwitchFrom = function(ply)
	ply:RemoveSpeedEffect("jug")
end
ITEM.OnPickUp = function(ply)
	if ply:GetNWBool("CurseOfTheJug") then
		ply:EmitSound("slashco/jug_reject.mp3")
		timer.Simple(0, function()
			SlashCo.DropItem(ply)
		end)
	end

	ply:AddSpeedEffect("jug", 310, 3)
end

hook.Add("Think", "JugFunc", function()
	if SERVER then
		for _, surv in ipairs( team.GetPlayers(TEAM_SURVIVOR) ) do
			if surv:GetNWString("item") ~= "Jug" then continue end

			if surv:GetNWBool("CurseOfTheJug") then continue end

			local find = ents.FindInSphere(surv:GetPos(), 120)

			for i = 1, #find do
				local ent = find[i]

				if ent:IsPlayer() and ent:Team() == TEAM_SLASHER then
					surv:RandomTeleport()
					surv:EmitSound("slashco/jug_curse.mp3")
					SlashCo.RemoveItem(surv)
					surv:SetNWBool("CurseOfTheJug", true)
				end
			end
		end
	end
end)

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

SlashCo.RegisterItem(ITEM, "Jug")

if SERVER then
	return
end

hook.Add("HUDPaint", "JugVisions", function()
	if LocalPlayer():GetNWBool("JugCurseActivate") then
		local Overlay = Material("slashco/ui/overlays/jug_freeze")

		if LocalPlayer().JugFrame < 61 then
			Overlay:SetInt("$frame", math.floor(LocalPlayer().JugFrame))
			Overlay:SetFloat("$alpha", 1)
		else
			Overlay:SetInt("$frame", 60)
			Overlay:SetFloat("$alpha", 1 - ((LocalPlayer().JugFrame - 61) / 60))

			if math.floor(LocalPlayer().JugFrame) == 61 then
				LocalPlayer():EmitSound("slashco/jug_curse.mp3")
			end

		end

		LocalPlayer().JugFrame = LocalPlayer().JugFrame + RealFrameTime() * 30
		if LocalPlayer().JugFrame < 120 then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0 - (ScrW() / 6), ScrW(), ScrW())
		end
	else
		LocalPlayer().JugFrame = 0
	end
end)