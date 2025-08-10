local ITEM = {}

ITEM.Model = "models/slashco/items/nvg.mdl"
ITEM.Name = "NightVisionGoggles"
ITEM.EntClass = "sc_nvg"
ITEM.Icon = "slashco/ui/icons/items/item_7"
ITEM.Price = 40
ITEM.Description = "NightVisionGoggles_desc"
ITEM.CamPos = Vector(50,0,0)
ITEM.ChangesSpeed = false
ITEM.IsSpawnable = true

local nvgSoundFile = {
	[1] = "slashco/nvg_off.mp3",
	[2] = "slashco/nvg_on.mp3"
}

function GenDynLight(entIndex)
	local dlight = DynamicLight(MAX_EDICT + entIndex)
	if dlight then
		dlight.r = 19
		dlight.g = 194
		dlight.b = 107
	end

	return dlight
end

function ITEM.OnPickUp(ply)
	if GameData.IsLobby then
		return
	end
	ply:SetNWBool("NightVision", true)
	ply:ScreenFade(1, color_white, 0.5, 0.2)
	ply:EmitSound(nvgSoundFile[1], 75, 100, 1)
	ply.Eyesight = 8
	ply:SetNWFloat("Ply_Eyesight", ply.Eyesight)
	ply:EmitSound(nvgSoundFile[2], 75, 100, 1)
end
function ITEM.ItemDropped(ply, droppeditem)
	ply:SetNWBool("NightVision", false)
	ply:ScreenFade(1, color_black, 0.5, 0.2)
	ply:EmitSound(nvgSoundFile[1], 75, 100, 1)
end
function ITEM.OnDie(ply)
	ply:SetNWBool("NightVision", false)
	ply:ScreenFade(1, color_black, 0.5, 0.2)
	ply:EmitSound(nvgSoundFile[1], 75, 100, 1)
end

ITEM.ViewModel = {
	model = "models/slashco/items/nvg.mdl",
	pos = Vector(64, 0, -6),
	angle = Angle(45, -70, -120),
	size = Vector(0, 0, 0),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModelHolstered = {
	model = "models/slashco/items/nvg.mdl",
	bone = "ValveBiped.Bip01_Head1",
	pos = Vector(5, 6, 0),
	angle = Angle(0, 100, 90),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "normal",
	model = "models/slashco/items/nvg.mdl",
	bone = "ValveBiped.Bip01_Head1",
	pos = Vector(5, 6, 0),
	angle = Angle(0, 100, 90),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

hook.Add("RenderScreenspaceEffects", "NightVision", function()
	local ply = GameData.LocalPlayer
	if GameData.LocalPlayer:GetNWBool("NightVision") then
	
		local tr = ply:GetEyeTraceNoCursor()
		local dlight = GenDynLight(ply:EntIndex())

		if dlight then
			dlight.pos = tr.StartPos
			dlight.brightness = 7
			dlight.size = 700
			dlight.decay = 6000
			dlight.dieTime = CurTime() + 1
			dlight.style = 0
		end

		local nvg = {
			["$pp_colour_addr"] = -1,
			["$pp_colour_addg"] = 0.1,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0.3,
			["$pp_colour_contrast"] = 1.2,
			["$pp_colour_colour"] = 0.37,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(nvg)
		DrawMaterialOverlay("models/props_slashco/items/nvg/filter.png", 0)
	else
		return
	end
end)

SlashCo.RegisterItem(ITEM, "NightVisionGoggles")
