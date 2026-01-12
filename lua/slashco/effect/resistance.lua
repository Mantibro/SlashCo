local EFFECT = {}

--become undetectable

EFFECT.Name = "Resistance"
function EFFECT.OnOwnerTakeDamage(ply, dmg)
	dmg:ScaleDamage(0.1) -- Reduce all damage by 10x
end

local colors = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1.3,
	["$pp_colour_mulr"] = 0.1,
	["$pp_colour_mulg"] = -1,
	["$pp_colour_mulb"] = -1
}

function EFFECT.Screenspace()
	DrawMotionBlur(0.1, 0.1, 0)
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "Resistance")