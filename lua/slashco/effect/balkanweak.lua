local EFFECT = {}

EFFECT.Name = "BalkanTripWeak"
EFFECT.ChangesSpeed = true
EFFECT.FuelSpeed = 1.75
function EFFECT.OnApplied(ply)
	ply:AddSpeedEffect("balkantripweak", 600, 20)
end
function EFFECT.OnExpired(ply)
	ply:RemoveSpeedEffect("balkantripweak")
end

local colors = {
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

function EFFECT.Screenspace()
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "BalkanTripWeak")