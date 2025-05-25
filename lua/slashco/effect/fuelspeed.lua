local EFFECT = {}

--increases fuel speed (wow!)

EFFECT.Name = "Fuel Speed"
EFFECT.FuelSpeed = 2.5

function EFFECT.Screenspace()
	DrawSobel(0.9)
	DrawToyTown(3, ScrH() / 2)
end

SlashCo.RegisterEffect(EFFECT, "FuelSpeed")