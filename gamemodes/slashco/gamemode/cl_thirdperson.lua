
hook.Add("CalcView", "SlashCoThirdPerson", function(ply, pos, angles, fov, znear, zfar)
	local _team = ply:Team()
	if _team == TEAM_SURVIVOR then
		if not ply:ItemFunction("Thirdperson") then
			return
		end
	elseif _team == TEAM_SLASHER then
		if not ply:SlasherFunction("Thirdperson") then
			return
		end
	else
		return
	end

	local view = {
		fov = fov,
		znear = znear,
		zfar = zfar,
		drawviewer = true
	}

	angles.p = angles.p + 15

	local traceData = {}
	traceData.start = pos
	traceData.endpos = traceData.start + angles:Forward() * -120
	traceData.filter = ply

	local trace = util.TraceLine(traceData)

	pos = trace.HitPos
	if trace.Fraction < 1.0 then
		pos = pos + trace.HitNormal * 5
	end

	view.origin = pos
	view.angles = angles

	return view
end)