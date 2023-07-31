local EFFECT = {}

--gain a massive speed boost

EFFECT.Name = "Speed"
EFFECT.ChangesSpeed = true
EFFECT.OnApplied = function(ply)
	ply:AddSpeedEffect("speedEffect", 400, 4)
end
EFFECT.OnExpired = function(ply)
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

EFFECT.Screenspace = function()
	DrawSobel(0.9)
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "Speed")