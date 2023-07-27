local EFFECT = SlashCoEffects.FuelSpeed or {}
SlashCoEffects.FuelSpeed = EFFECT

--increases fuel speed (wow!)

EFFECT.Name = "Fuel Speed"
EFFECT.FuelSpeed = 2.5

EFFECT.Screenspace = function()
	DrawSobel(0.9)
	DrawToyTown(3, ScrH() / 2)
end