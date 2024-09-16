local EFFECT = {}

--messes up your screen depending on the nearness of slashers

EFFECT.Name = "Awareness"

EFFECT.OnApplied = function(ply)
	SlashCo.SendValue(ply, "Awareness", true)
end
EFFECT.OnExpired = function(ply)
	SlashCo.SendValue(ply, "Awareness", false)
end

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

if CLIENT then
	local mat = Material("lights/white")

	local function showSurvivors()
		cam.Start3D()
		render.MaterialOverride(mat)

		local num = render.GetBlend()
		local dist = 0.5
		for _, v in pairs(ents.FindInSphere(LocalPlayer():EyePos(), 1000)) do
			if v:IsPlayer() and v:Team() == TEAM_SLASHER then
				local lDist = math.max(v:WorldSpaceCenter():DistToSqr(LocalPlayer():EyePos()) * 0.0000001, 0)
				if lDist < dist then
					dist = lDist
				end
			end
		end
		render.SetBlend(math.Clamp(dist, 0, 0.1))

		for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			ply:DrawModel()
		end
		for _, v in ipairs(ents.FindByClass("sc_generator")) do
			v:DrawModel()
		end

		render.SetBlend(num)
		cam.End3D()
	end

	hook.Add("scValue_Awareness", "SlashCoAwareness", function(state)
		if state then
			hook.Add("HUDPaint", "SlashCoAwareness", showSurvivors)
			return
		end

		hook.Remove("HUDPaint", "SlashCoAwareness")
	end)
end

SlashCo.RegisterEffect(EFFECT, "Awareness")
