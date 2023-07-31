local EFFECT = {}

--messes up your screen depending on the nearness of slashers

EFFECT.Name = "Awareness"

local colors = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.5,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 1,
	["$pp_colour_mulg"] = 0.75,
	["$pp_colour_mulb"] = 0
}

EFFECT.Screenspace = function()
	local blur, pos = 99999
	for _, v in pairs(ents.FindInSphere(LocalPlayer():EyePos(), 1000)) do
		if v:IsPlayer() and v:Team() == TEAM_SLASHER then
			local dist = math.max(8 - (v:WorldSpaceCenter():DistToSqr(LocalPlayer():EyePos()) * 0.000008), 0)
			if dist < blur then
				blur = dist
				pos = v:WorldSpaceCenter()
			end
		end
	end

	if blur < 99999 then
		local diff = pos - LocalPlayer():GetShootPos()
		local aim = (LocalPlayer():GetAimVector():Dot(diff) / diff:Length()) + 1

		DrawSharpen(blur * 0.25 + aim * 4, blur)
	end

	DrawColorModify(colors)
end

SlashCo.RegisterEffect(EFFECT, "Awareness")