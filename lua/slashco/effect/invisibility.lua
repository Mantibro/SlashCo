local EFFECT = {}

--become undetectable

EFFECT.Name = "Invisibility"
EFFECT.OnFootstep = function()
	return true
end
EFFECT.CanBeSeen = function()
	return false
end

local colors = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0.2,
	["$pp_colour_mulr"] = -1,
	["$pp_colour_mulg"] = -1,
	["$pp_colour_mulb"] = -0.8
}

EFFECT.Screenspace = function()
	DrawMotionBlur(0.1, 0.4, 0.01)
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "Invisibility")