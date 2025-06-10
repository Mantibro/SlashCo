local EFFECT = {}

--me tira me tira me tiraaaa

EFFECT.Name = "Balkan"
EFFECT.ChangesSpeed = true
EFFECT.FuelSpeed = 3.5
function EFFECT.OnApplied(ply)
	ply:AddSpeedEffect("balkanEffect", 600, 20)
end
function EFFECT.OnExpired(ply)
	ply:RemoveSpeedEffect("balkanEffect")
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

function EFFECT.Screenspace()
	DrawSobel(0.13	)
	DrawSharpen(0.8, 0.8)
	DrawMotionBlur(0.5, 0.6, 0.05)
	DrawToyTown(4, ScrH() / 2)
	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "BalkanTrip")