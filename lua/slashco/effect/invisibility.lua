local EFFECT = {}

--become undetectable

EFFECT.Name = "Invisibility"
function EFFECT.OnFootstep()
	return true
end
function EFFECT.CanBeSeen()
	return false
end
function EFFECT.OnApplied(ply)
	ply:AddSpeedEffect("invis", 250, 2)
	ply:DrawShadow(false)
end
function EFFECT.OnExpired(ply)
	ply:RemoveSpeedEffect("invis")
	ply:DrawShadow(true)
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

function EFFECT.Screenspace()
	DrawMotionBlur(0.1, 0.4, 0.01)
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "Invisibility")