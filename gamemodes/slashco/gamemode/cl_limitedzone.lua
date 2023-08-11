hook.Add("scValue_limitedZone", "SlashCoLimitedZone", function(effect)
	local ply = LocalPlayer()

	ply.ZoneEffect = effect
	if not ply.FogColor then
		ply.ColorTable = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		ply.DefaultFogMode = render.GetFogMode()

		if ply.DefaultFogMode == MATERIAL_FOG_NONE then
			ply.FogColor = {255, 255, 255}
			ply.DefaultFogColor = {255, 255, 255}
			ply.FogStart, ply.FogEnd = 2000, 2000
			ply.DefaultFogStart, ply.DefaultFogEnd = 2000, 2000
			return
		end

		ply.FogColor = {render.GetFogColor()}
		ply.DefaultFogColor = {render.GetFogColor()}
		ply.FogStart, ply.FogEnd = render.GetFogDistances()
		ply.DefaultFogStart, ply.DefaultFogEnd = render.GetFogDistances()
	end
end)

local fogSettings = {
	[1] = {
		color = {0, 0, 0},
		_start = 0,
		_end = 500
	},
	[2] = {
		color = {255, 255, 255},
		_start = 0,
		_end = 500
	},
	[3] = {
		color = {64, 255, 0},
		_start = 0,
		_end = 2000
	},
	[4] = {
		color = {255, 0, 0},
		_start = 0,
		_end = 1000
	},
	[5] = {
		color = {192, 192, 192},
		_start = 0,
		_end = 2000
	},
}

local function renderFog(scale)
	local ply = LocalPlayer()

	local targetColor, targetStart, targetEnd = ply.DefaultFogColor, ply.DefaultFogStart, ply.DefaultFogEnd
	if fogSettings[ply.ZoneEffect] then
		targetColor = fogSettings[ply.ZoneEffect].color
		targetStart = fogSettings[ply.ZoneEffect]._start
		targetEnd = fogSettings[ply.ZoneEffect]._end
	end

	ply.FogColor[1] = math.Clamp(Lerp(0.02, ply.FogColor[1], targetColor[1]), 0, 255)
	ply.FogColor[2] = math.Clamp(Lerp(0.02, ply.FogColor[2], targetColor[2]), 0, 255)
	ply.FogColor[3] = math.Clamp(Lerp(0.02, ply.FogColor[3], targetColor[3]), 0, 255)
	ply.FogStart = math.Clamp(Lerp(0.02, ply.FogStart, targetStart), 0, 1000000)
	ply.FogEnd = math.Clamp(Lerp(0.02, ply.FogEnd, targetEnd), 0, 1000000)

	if math.abs(ply.FogStart - ply.DefaultFogStart) < 0.1 then
		render.FogMode(ply.DefaultFogMode)
		render.FogColor(unpack(ply.DefaultFogColor))
		render.FogStart(ply.DefaultFogStart * scale)
		render.FogEnd(ply.DefaultFogEnd * scale)
		return
	else
		render.FogMode(MATERIAL_FOG_LINEAR)
		render.FogColor(unpack(ply.FogColor))
		render.FogStart(ply.FogStart * scale)
		render.FogEnd(ply.FogEnd * scale)
		return true
	end
end

hook.Add("SetupWorldFog", "SlashCoZoneFog", function()
	if not LocalPlayer().ZoneEffect then
		return
	end

	return renderFog(1)
end)

hook.Add("SetupSkyboxFog", "SlashCoZoneFog", function(scale)
	if not LocalPlayer().ZoneEffect then
		return
	end

	return renderFog(scale)
end)

local colorSettings = {
	[0] = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	},
	[1] = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = -0.1,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	},
	[2] = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0.1,
		["$pp_colour_contrast"] = 0.75,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	},
	[3] = {
		["$pp_colour_addr"] = 0.025,
		["$pp_colour_addg"] = 0.1,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	},
	[4] = {
		["$pp_colour_addr"] = 0.2,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	},
	[5] = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}
}

hook.Add("RenderScreenspaceEffects", "SlashCoZoneScreenSpace", function()
	if not LocalPlayer().ZoneEffect then
		return
	end

	for k, v in pairs(LocalPlayer().ColorTable) do
		LocalPlayer().ColorTable[k] = math.Clamp(Lerp(0.01, v, colorSettings[LocalPlayer().ZoneEffect][k]), -10, 10)
	end
	DrawColorModify(LocalPlayer().ColorTable)
end)