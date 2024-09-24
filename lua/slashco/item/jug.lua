local ITEM = {}

ITEM.Model = "models/slashco/items/jug.mdl"
ITEM.Name = "Jug"
ITEM.EntClass = "sc_jug"
ITEM.Price = 10
ITEM.Description = "Jug_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.ChangesSpeed = true
ITEM.IsSpawnable = true

ITEM.ItemDropped = function(ply, droppeditem)
	if ply.JugTele then
		timer.Remove("JugTele_" .. ply:UserID())
		droppeditem:EmitSound("slashco/jug_curse.mp3", 75, 50)
		ply.JugTele = false
	end
end
ITEM.OnSwitchFrom = function(ply)
	ply:RemoveSpeedEffect("jug")
end
ITEM.PrePickUp = function(ply)
	if not ply:GetNWBool("CurseOfTheJug") then
		return
	end

	if ply.JugDropTimer and CurTime() - ply.JugDropTimer < 1 then
		return true
	end
	ply.JugDropTimer = CurTime()

	ply:EmitSound("slashco/jug_reject.mp3")

	return true
end
ITEM.OnPickUp = function(ply)
	if ply:GetNWBool("CurseOfTheJug") then
		timer.Simple(0, function()
			SlashCo.DropItem(ply)
		end)

		return
	end

	ply:AddSpeedEffect("jug", 310, 1)
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

SlashCo.RegisterItem(ITEM, "Jug")

if SERVER then
	local function tele(ply, force)
		if ply.JugTele and not force then
			return
		end
		ply.JugTele = true

		timer.Create("JugTele_" .. ply:UserID(), 2, 1, function()
			if not IsValid(ply) then return end

			ply.JugTele = false

			if ply:GetItem("item") ~= "Jug" then return end

			SlashCo.RemoveItem(ply)
			ply:RandomTeleport()
			ply:AddSpeedEffect("jugCurse", 290, 1)
			ply:SetNWBool("CurseOfTheJug", true)
			ply:EmitSound("slashco/jug_curse.mp3", 75, 70)
		end)

		ply:EmitSound("slashco/jug_curse.mp3")
	end

	concommand.Add("slashco_debug_jugtele", function(ply)
		if not IsValid(ply) or not ply:IsPlayer() or not ply:IsAdmin() then
			doPrint(ply, "Only admins can use debug commands!")
			return
		end

		tele(ply, true)
	end, nil, "Teleport as if you had triggered a jug.", FCVAR_CHEAT + FCVAR_PROTECTED)

	hook.Add("Think", "JugFunc", function()
		for _, surv in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if surv:GetItem("item") ~= "Jug" then continue end
			if surv:GetNWBool("CurseOfTheJug") then continue end

			if surv:GetNWBool("SurvivorChased") then
				tele(surv)
				continue
			end

			for _, ent in ipairs(ents.FindInSphere(surv:GetPos(), 150)) do
				if ent:IsPlayer() and ent:Team() == TEAM_SLASHER and ent:CanBeSeen() then
					tele(surv)
					break
				end
			end
		end
	end)

	hook.Add("SlashCoItemPickUp", "JugCurse", function(ply, item, id)
		if item ~= "GasCan" then
			return
		end

		if not ply:GetNWBool("CurseOfTheJug") then
			return
		end

		if math.random() < 0.5 then
			return
		end

		local ent = Entity(id)
		ent:RandomTeleport(Vector(0, 0, 50))
		ply:SetNWBool("JugCurseActivate", true)

		timer.Create("jugCurse_" .. ply:UserID(), 6, 1, function()
			if IsValid(ply) then
				ply:SetNWBool("JugCurseActivate", false)
			end
		end)

		return true
	end)

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