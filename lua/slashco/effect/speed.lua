local EFFECT = {}

--gain a massive speed boost

EFFECT.Name = "Speed"
EFFECT.ChangesSpeed = true
function EFFECT.OnApplied(ply)
	ply:AddSpeedEffect("speedEffect", 400, 4)
end
function EFFECT.OnExpired(ply)
	ply:RemoveSpeedEffect("speedEffect")
end

local colors = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1.25,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

function EFFECT.Screenspace()
	DrawSobel(0.9)
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "Speed")