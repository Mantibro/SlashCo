local ITEM = {}

ITEM.Model = "models/slashco/items/BalkanBoost.mdl"
ITEM.EntClass = "sc_balkanboost"
ITEM.Name = "BalkanBoost"
ITEM.Icon = "slashco/ui/icons/items/item_20"
ITEM.Price = 100
ITEM.Description = "BalkanBoost_desc"
ITEM.CamPos = Vector(50, 0, 0)
function ITEM.MaxAllowed()
	return 4
end
ITEM.IsSpawnable = false
function ITEM.DisplayColor()
	return 232, 23, 55, 255
end
function ITEM.OnUse(ply)
	ply:EmitSound("slashco/survivor/balkan_eat.wav")

	timer.Simple(0.01, function()
		if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
			ply:SetNWBool("SurvivorBalkan", true)
			ply:AddEffect("Slowness", 31.5)
		end

	   	timer.Simple(32, function()
			if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
				ply:SetNWBool("SurvivorBalkanFull", true)
				ply:SetNWBool("MarkedBySmiley", true)
				ply:AddEffect("BalkanTrip", 132)
			end
		end)
		
		timer.Simple(164, function()
			if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
				ply:SetNWBool("SurvivorBalkanFull", false)
				ply:SetNWBool("SurvivorBalkan", false)
				ply:SetNWBool("MarkedBySmiley", false)
				ply:AddEffect("Slowness", 9999)
				local hpafter = ply:Health() / 6
				ply:SetHealth(hpafter)
			end
		end)
	end)
end
ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(-40, -90, -120),
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
	angle = Angle(180, -50, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "BalkanBoost")

if SERVER then
	hook.Add("Think", "BalkanBoost", function()
		for _, ply in ipairs(player.GetAll()) do
			if ply:Team() ~= TEAM_SURVIVOR then
				if ply:GetNWBool("SurvivorBalkan") then
					ply:SetNWBool("SurvivorBalkan", false)
				end
				
				if ply:GetNWBool("SurvivorBalkanFull") then
					ply:SetNWBool("SurvivorBalkanFull", false)
				end
			end
		end
	end)

	return
end

hook.Add("RenderScreenspaceEffects", "BalkanBoost", function()
	if GameData.LocalPlayer:GetNWBool("SurvivorBalkanFull") then

		local tab = {
			["$pp_colour_addr"] = 0.07,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 2,
			["$pp_colour_colour"] = 4,
			["$pp_colour_mulr"] = 0.07,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
	end
end)

local BalkanSound

hook.Add("Think", "BalkanBoost", function()
	if GameData.LocalPlayer:GetNWBool("SurvivorBalkan") then
		if not BalkanSound then
			sound.PlayFile("sound/slashco/balkan_icantstopnow.mp3", "noplay", function(music, errCode, errStr)
				if IsValid(music) then
					BalkanSound = music

					timer.Simple(0.01, function()
						BalkanSound:Play()
					end)

				end
			end)
		else
			local vol = 3
			BalkanSound:SetVolume(vol)
		end

		local frequency = 0

	elseif IsValid(BalkanSound) then
		BalkanSound:Stop()
		BalkanSound = nil
	end
end)