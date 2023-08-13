local ambiences = {
	[1] = "ambient/wind/wind_loop_005.wav",
	[2] = "ambient/windwinter.wav",
	[3] = "ambient/wind/wind_loop_006.wav",
	[4] = "ambient/wind/wind_loop_002.wav",
	[5] = "ambient/wind/wind_loop_003.wav",
	[6] = "ambient/windwinter.wav",
}

local zoneAmbience, snd
hook.Add("scValue_limitedZone", "SlashCoLimitedZone", function(effect)
	local ply = LocalPlayer()

	-- [[ soundpatch method
	if ambiences[effect] then
		timer.Remove("SCFadeOut")
		if snd ~= ambiences[effect] then
			if zoneAmbience then
				zoneAmbience:FadeOut(1)
			end

			zoneAmbience = SlashCo.ReadSound(ambiences[effect])
			zoneAmbience:ChangeVolume(0)
			zoneAmbience:ChangeVolume(1, 1)
			snd = ambiences[effect]
		end
	elseif zoneAmbience then
		timer.Create("SCFadeOut", 0.1, 1, function()
			zoneAmbience:FadeOut(1)
			snd = nil
			zoneAmbience = nil
		end)
	end
	--]]

	--[[ playfile method
	if ambiences[effect] and snd ~= ambiences[effect] then
		if IsValid(zoneAmbience) then
			zoneAmbience:Stop()
		end
		snd = ambiences[effect]
		sound.PlayFile("sound/" .. ambiences[effect], "noplay", function(music, errCode, errStr)
			if IsValid(music) then
				zoneAmbience = music
				zoneAmbience:EnableLooping(true)
				zoneAmbience:Play()
			else
				print("[SlashCo] Error playing zone ambience!", errCode, errStr)
			end
		end)
	elseif IsValid(zoneAmbience) then
		zoneAmbience:Stop()
		snd = nil
	end
	--]]

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
			ply.FogColor = { 255, 255, 255 }
			ply.DefaultFogColor = { 255, 255, 255 }
			ply.FogStart, ply.FogEnd = 2000, 2000
			ply.DefaultFogStart, ply.DefaultFogEnd = 2000, 2000
			return
		end

		ply.FogColor = { render.GetFogColor() }
		ply.DefaultFogColor = { render.GetFogColor() }
		ply.FogStart, ply.FogEnd = render.GetFogDistances()
		ply.DefaultFogStart, ply.DefaultFogEnd = render.GetFogDistances()
	end
end)

local particleSettings = {
	[1] = {
		texture = "effects/slime1",
		distance = 150,
		particle = function(part, delta)
			part:SetDieTime(1)
			part:SetStartSize((1 + math.random() * 1) * delta)
			part:SetEndSize(0)
			part:SetStartAlpha(delta * 192)
			part:SetEndAlpha(0)
			part:SetColor(0, 0, 0)
		end
	},
	[2] = {
		texture = "sprites/dot",
		distance = 200,
		particle = function(part, delta)
			part:SetDieTime(1)
			part:SetStartSize((2 + math.random() * 3) * delta)
			part:SetEndSize(0)
			part:SetColor(delta * 255, delta * 255, delta * 255)
			part:SetGravity(Vector(0, 0, -250))
			part:SetVelocity(VectorRand() * 100 - Vector(100, 100, 250))
		end
	},
	[3] = {
		texture = "effects/slime1",
		distance = 200,
		particle = function(part, delta)
			part:SetDieTime(1)
			part:SetStartSize((1 + math.random() * 1) * delta)
			part:SetEndSize(0)
			part:SetStartAlpha(delta * 192)
			part:SetEndAlpha(0)
			part:SetColor(96, 96, 96)
			part:SetGravity(Vector(0, 0, 50))
			part:SetVelocity(VectorRand() * 50 + Vector(0, 0, 50))
		end
	},
	[4] = {
		texture = "sprites/dot",
		distance = 200,
		particle = function(part, delta)
			part:SetDieTime(1)
			part:SetColor(128 + math.random() * 96, math.random() * 96, math.random() * 96)
			part:SetStartSize((0.5 + math.random() * 1) * delta)
			part:SetEndSize(0)
			part:SetGravity(vector_origin)
			part:SetVelocity(VectorRand() * 75)
		end
	},
	[6] = {
		texture = "effects/slime1",
		distance = 200,
		particle = function(part, delta)
			part:SetDieTime(1)
			part:SetStartSize((2 + math.random() * 3) * delta)
			part:SetEndSize(0)
			part:SetStartAlpha(delta * 192)
			part:SetEndAlpha(delta * 192)
			part:SetColor(0, 0, 0)
			part:SetGravity(Vector(0, 0, -250))
			part:SetVelocity(VectorRand() * 100 - Vector(100, 100, 250))
		end
	}
}

local delta = 0
hook.Add("Think", "SlashCoZoneParticles", function()
	if not LocalPlayer().ZoneEffect or not particleSettings[LocalPlayer().ZoneEffect] then
		delta = 0
		return
	end

	delta = math.Clamp(Lerp(0.005, delta, 1), 0, 1)
	local settings = particleSettings[LocalPlayer().ZoneEffect]
	local pos = LocalPlayer():WorldSpaceCenter()
	local emitter = ParticleEmitter(pos)
	local part = emitter:Add(settings.texture, pos + VectorRand(-settings.distance, settings.distance))
	if part then
		settings.particle(part, delta)
	end
	emitter:Finish()
end)

local fogSettings = {
	[1] = {
		color = { 0, 0, 0 },
		_start = 0,
		_end = 750
	},
	[2] = {
		color = { 255, 255, 255 },
		_start = 0,
		_end = 500
	},
	[3] = {
		color = { 16, 64, 0 },
		_start = 0,
		_end = 2000
	},
	[4] = {
		color = { 255, 0, 0 },
		_start = 0,
		_end = 1000
	},
	[5] = {
		color = { 192, 192, 192 },
		_start = 0,
		_end = 2000
	},
	[6] = {
		color = { 0, 0, 0 },
		_start = 0,
		_end = 300
	}
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
		["$pp_colour_brightness"] = -0.15,
		["$pp_colour_contrast"] = 1.1,
		["$pp_colour_colour"] = 0.75,
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
		["$pp_colour_colour"] = 0.75,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	},
	[3] = {
		["$pp_colour_addr"] = 0.025,
		["$pp_colour_addg"] = 0.1,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1.1,
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
		["$pp_colour_contrast"] = 0.5,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0.2,
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
	},
	[6] = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = -0.15,
		["$pp_colour_contrast"] = 1.1,
		["$pp_colour_colour"] = 0.75,
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