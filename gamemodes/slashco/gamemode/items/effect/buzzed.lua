local EFFECT = SlashCoEffects.Buzzed or {}
SlashCoEffects.Buzzed = EFFECT

--slow down slightly; this speed change overrides every other item effect (including gas can slowness)

EFFECT.Name = "Buzzed"
EFFECT.ChangesSpeed = true
EFFECT.FuelSpeed = 0.75
EFFECT.OnApplied = function(ply)
	ply:AddSpeedEffect("buzzEffect", 275, 12)
end
EFFECT.OnExpired = function(ply)
	ply:RemoveSpeedEffect("buzzEffect")
end

local colors = {
	["$pp_colour_addr"] = 0.01,
	["$pp_colour_addg"] = 0.01,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1.1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

EFFECT.Screenspace = function()
	DrawSharpen(0.6, 0.6)
	DrawMotionBlur(0.1, 0.2, 0.01)
	DrawToyTown(3, ScrH() / 2)
	DrawColorModify(colors)
end