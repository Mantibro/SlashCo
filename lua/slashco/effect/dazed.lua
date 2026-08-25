local EFFECT = {}

--apply blur effects on screen

EFFECT.Name = "Dazed"

function EFFECT.Screenspace()
	DrawSobel(0.3)
	DrawSharpen(0.6, 0.6)
	DrawBloom(9, 2, 8, 2, 2, 2, 2, 2, 2)
	DrawMotionBlur(0.1, 1, 0.01)
	DrawToyTown(4, ScrH() / 2)
end

SlashCo.RegisterEffect(EFFECT, "Dazed")