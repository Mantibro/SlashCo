local EFFECT = {}

--slow down significantly

EFFECT.Name = "Slowness"
EFFECT.ChangesSpeed = true
function EFFECT.OnApplied(ply)
	ply:AddSpeedEffect("slowEffect", 200, 12)
end
function EFFECT.OnExpired(ply)
	ply:RemoveSpeedEffect("slowEffect")
end

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