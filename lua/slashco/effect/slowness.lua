local EFFECT = {}

--slow down significantly

EFFECT.Name = "Slowness"
EFFECT.Speed = 200
EFFECT.SpeedPriority = 12

local colors = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0.8,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

function EFFECT.Screenspace()
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "Slowness")