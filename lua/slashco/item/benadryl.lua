local ITEM = {}

ITEM.Model = "models/slashco/items/benadryl.mdl"
ITEM.Name = "Benadryl"
ITEM.EntClass = "sc_benadryl"
ITEM.Price = 60
ITEM.Description = "Benadryl_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.DisplayColor = function()
	return 128, 48, 0, 255
end
ITEM.OnUse = function(ply)
	ply:EmitSound("slashco/survivor/benadryl_eat.mp3")

	timer.Simple(60, function()
		if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
			ply:SetNWBool("SurvivorBenadryl", true)
		end

		timer.Simple(60, function()
			if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
				ply:SetNWBool("SurvivorBenadrylFull", true)
			end
		end)

		timer.Simple(480, function()
			if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
				ply:SetNWBool("SurvivorBenadrylFull", false)
			end
		end)

		timer.Simple(535, function()
			if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
				ply:SetNWBool("SurvivorBenadryl", false)
			end
		end)
	end)
end
ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(180, 20, 90),
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

SlashCo.RegisterItem(ITEM, "Benadryl")

if SERVER then
	hook.Add("Think", "Benadryl", function()
		for _, ply in ipairs(player.GetAll()) do
			if ply:Team() ~= TEAM_SURVIVOR then
				if ply:GetNWBool("SurvivorBenadryl") then
					ply:SetNWBool("SurvivorBenadryl", false)
				end

				if ply:GetNWBool("SurvivorBenadrylFull") then
					ply:SetNWBool("SurvivorBenadrylFull", false)
				end
			end
		end
	end)

	return
end

local rand = 0
hook.Add("RenderScreenspaceEffects", "Benadryl", function()
	if LocalPlayer():GetNWBool("SurvivorBenadryl") then
		if not LocalPlayer().BenadrylIntensity then
			LocalPlayer().BenadrylIntensity = RealFrameTime()
		end

		LocalPlayer().BenadrylIntensity = LocalPlayer().BenadrylIntensity + (RealFrameTime() / 277)
		if LocalPlayer().BenadrylIntensity > 1 then
			LocalPlayer().BenadrylIntensity = -1
		end

		local freaker = math.min(math.abs(LocalPlayer().BenadrylIntensity) * 2, 1)
		rand = rand + (math.random() / 3)
		local contrast = 3.5 + math.sin((CurTime() + rand) / 10) * 3
		local bloom = 3 + math.cos((CurTime() + rand) / 2) * 1
		local bloom2 = 3 + math.cos((CurTime() + rand) / 4) * 1
		local bokeh = -3 + math.cos((CurTime() + rand) / 20) * 4

		DrawBloom(0.5, freaker * bloom * 1.5, freaker * bloom2 * 9, freaker * bloom2 * 9, 1, 8, 2, 2, 2)
		DrawBokehDOF(12 * freaker, freaker * bokeh, 4 * freaker)

		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1 + (freaker * contrast),
			["$pp_colour_colour"] = 1 - freaker,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
		DrawMotionBlur(freaker * 0.75 + (contrast * 0.08), freaker * 0.8, freaker * 0.07)
		DrawSharpen(freaker * bloom, freaker * bloom)
	else
		LocalPlayer().BenadrylIntensity = 0
	end
end)

local BenadrylSound
local CreateShadowPerson = function(pos, ang)
	if not LocalPlayer():GetNWBool("SurvivorBenadrylFull") then
		return
	end

	local Ent = ents.CreateClientside("sc_shadowman")

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create a " .. class .. " at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()
	Ent:Activate()

	local id = Ent:EntIndex()

	return id
end

hook.Add("Think", "Benadryl", function()
	if LocalPlayer():GetNWBool("SurvivorBenadryl") then
		if not BenadrylSound then
			sound.PlayFile("sound/slashco/benadryl_base.mp3", "noplay", function(music, errCode, errStr)
				if IsValid(music) then
					BenadrylSound = music

					timer.Simple(0.01, function()
						BenadrylSound:Play()
					end)

				end
			end)
		else
			local vol = 0
			if LocalPlayer().BenadrylIntensity then
				vol = math.abs(LocalPlayer().BenadrylIntensity)
			end
			BenadrylSound:SetVolume(vol)
		end

		if not LocalPlayer().ShadowManTick then
			LocalPlayer().ShadowManTick = CurTime()
		end

		local frequency = 0

		if LocalPlayer().BenadrylIntensity then
			frequency = math.abs(LocalPlayer().BenadrylIntensity)
		end

		if CurTime() - LocalPlayer().ShadowManTick > 3 - (frequency * 2) then
			CreateShadowPerson(LocalPlayer():GetPos() + Vector(math.random(-750, 750), math.random(-750, 750),
					math.random(50, 50)), Angle(0, math.random(1, 360), 0))
			LocalPlayer().ShadowManTick = CurTime()
		end
	elseif IsValid(BenadrylSound) then
		BenadrylSound:Stop()
		BenadrylSound = nil
	end
end)

hook.Add("HUDPaint", "Benadryl", function()
	if LocalPlayer():GetNWBool("SurvivorBenadrylFull") then
		if not LocalPlayer().BenadrylVisionTick then
			LocalPlayer().BenadrylVisionTick = 10
		end

		if not LocalPlayer().BenadrylVision then
			LocalPlayer().BenadrylVision = math.random(0, 30)
		end

		if LocalPlayer().BenadrylVisionTick < 1 then

			local Overlay = Material("slashco/ui/overlays/benadryl_visions")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().BenadrylVision))

			Overlay:SetFloat("$alpha", LocalPlayer().BenadrylVisionTick / 8)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		end

		if LocalPlayer().BenadrylVisionTick < 0 then
			LocalPlayer().BenadrylVision = math.random(0, 30)
			LocalPlayer().BenadrylVisionTick = 1 + (math.random() * 5)
		end

		LocalPlayer().BenadrylVisionTick = LocalPlayer().BenadrylVisionTick - (RealFrameTime() * 1)
	end
end)