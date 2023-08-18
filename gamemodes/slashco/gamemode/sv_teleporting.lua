local yellow = Color(255, 255, 0, 16)
local red = Color(255, 0, 0)
local blue = Color(0, 0, 255)

local vecBase = { "x", "y", "z" }

local height_offset = 25
local mins, maxs = Vector(-18, -18, 0), Vector(18, 18, 72)
local function traceHullCheck(center, min, max, limit)
	limit = limit or 100
	local pos = vector_origin
	local err_hullhit = 0
	local success
	for _ = 0, limit do
		for _, v in pairs(vecBase) do
			pos[v] = center[v] + math.Rand(center[v] - min[v], center[v] - max[v])
		end

		local tr_l = util.TraceLine({
			start = pos,
			endpos = pos - Vector(0, 0, 2048),
		})

		if not tr_l.Hit then
			continue
		end

		pos = tr_l.HitPos + Vector(0, 0, height_offset)

		local tr = util.TraceHull({
			start = pos,
			endpos = pos,
			maxs = maxs,
			mins = mins,
		})

		if not tr.Hit then
			success = true
			break
		end

		--be less specific if it's not working out
		if err_hullhit > limit * 0.66 and not tr.HitNonWorld then
			success = true
			break
		end

		err_hullhit = err_hullhit + 1
	end

	return pos
end

--SlashCo.MapSurfs = SlashCo.MapSurfs or {}
local function init()
	local verts = {}
	for _, v in ipairs(game.GetWorld():GetBrushSurfaces()) do
		if v:IsNoDraw() or v:IsSky() or v:IsWater() then
			continue
		end
		local verts1 = v:GetVertices()
		table.Add(verts, verts1)

		--if #verts1 >= 3 then
		--	table.insert(SlashCo.MapSurfs, v)
		--end
	end

	local amt = #verts
	for i = 1, amt - 1 do
		OrderVectors(verts[i], verts[i + 1])
	end
	SlashCo.MaxVec = verts[amt]

	for i = 2, amt - 1 do
		OrderVectors(verts[amt - i], verts[amt - i + 1])
	end
	SlashCo.MinVec = verts[1]

	SlashCo.MidVec = (SlashCo.MaxVec + SlashCo.MinVec) / 2
	SlashCo.MapSize = math.ceil(SlashCo.MaxVec:Distance(SlashCo.MinVec) / 20000)
end
hook.Add("InitPostEntity", "SlashCo_InitMapMesh", init)

--[[ surfs method, heavily favors regions with more cut up brushes
local function randomPosition()
	for i = 1, 25 do
		local id = math.random(1, #SlashCo.MapSurfs)
		local surf = SlashCo.MapSurfs[id]
		local verts = surf:GetVertices()
		local dir = (verts[3] - verts[1]):Cross(verts[2] - verts[1])
		local norm = dir / dir:Length()
		local pos = (verts[1] + verts[2] + verts[3]) / 3
		local start = pos + norm * 36

		local tr_l = util.TraceLine({
			start = start,
			endpos = start - Vector(0, 0, 2048),
		})

		if not tr_l.Hit or i == 25 then
			table.remove(SlashCo.MapSurfs, id) --take out incompatible surf
			continue
		elseif i < 25 then
			start = tr_l.HitPos + Vector(0, 0, height_offset)
		end

		local tr = util.TraceHull({
			start = start,
			endpos = start,
			maxs = maxs,
			mins = mins
		})

		if not tr.Hit or i == 25 then -- if can't find suitable spot, let it clip into the surface
			return tr.HitPos
		else
			table.remove(SlashCo.MapSurfs, id) --take out incompatible surf
		end
	end
end
]]--

-- [[ random vector method, more intensive due to being more likely to fail, but better randomness
local function randomPosition()
	return traceHullCheck(SlashCo.MidVec, SlashCo.MinVec, SlashCo.MaxVec, 350)
end
--]]

--[[
timer.Create("scTestTeleportZones", 1, 0, function()
	if SlashCo.MaxVec then
		debugoverlay.Cross(SlashCo.MaxVec, 20, 20, red, true)
		debugoverlay.Cross(SlashCo.MinVec, 20, 20, red, true)
		debugoverlay.Cross(SlashCo.MidVec, 20, 20, red, true)
	end
	local randomPos = randomPosition()
	if randomPos then
		debugoverlay.Cross(randomPosition(), 20, 20, blue, true)
	else
		print(randomPos)
	end
end)
--]]

function SlashCo.TraceHullLocator()
	return randomPosition()
end

local function teleCondForced(ent)
	return SlashCo.DefaultConditionsForced(ent) and not ent.IsExclusive
end
local function teleCondNonForced(ent)
	return SlashCo.DefaultConditionsNonForced(ent) and not ent.IsExclusive
end

function SlashCo.RandomTeleport(target)
	if not IsValid(target) then
		return
	end

	local elements = ents.FindByClass("func_sc_teleportzone")
	table.Add(elements, ents.FindByClass("info_sc_player_teleport"))
	local ent = SlashCo.SelectSpawns(elements, nil, teleCondForced, teleCondNonForced)

	local vec, ang
	if not IsValid(ent) then
		vec = randomPosition()
		ang = Angle(0, math.Rand(-180, 180), 0)
	elseif ent:GetClass() == "func_sc_teleportzone" then
		vec = traceHullCheck(ent:OBBCenter(), ent:WorldSpaceAABB())
		ang = Angle(0, math.Rand(-180, 180), 0)

		if g_SlashCoDebug then
			local min, max = ent:WorldSpaceAABB()
			debugoverlay.Box(ent:GetPos(), min, max, 20, yellow)
		end

		ent.SpawnedEntity = target
		ent:SpawnEnt()
	else
		vec, ang = ent:GetPos(), ent:GetAngles()

		ent.SpawnedEntity = target
		ent:SpawnEnt()
	end

	if not vec then
		return
	end

	if g_SlashCoDebug then
		debugoverlay.Cross(vec, 20, 20, blue, true)
	end

	target:SetPos(vec)
	target:DropToFloor()
	if target:IsPlayer() then
		target:SetEyeAngles(ang)
	else
		target:SetAngles(ang)
	end
end