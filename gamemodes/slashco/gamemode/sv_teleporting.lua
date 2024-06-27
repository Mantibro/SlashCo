local ENTITY = FindMetaTable("Entity")

--- return a random position that something can spawn at
function SlashCo.RandomPosLocator()
	local navtable = navmesh.GetAllNavAreas()

	for i = 1, 150 do
		local navdata = navtable[math.random(1, #navtable)]

		local NW = navdata:GetCorner( 0 )
		local SE = navdata:GetCorner( 2 )

		local pos = Vector(math.random(NW[1], SE[1]),math.random(NW[2], SE[2]), 2 + math.max(NW[3], SE[3]))

		local tr = util.TraceHull({
			start = pos + Vector(0, 0, 1),
			endpos = pos,
			maxs = Vector(12, 12, 72),
			mins = Vector(-12, -12, 0),
		})

		if not tr.Hit then
			return pos
		end
	end
end

--- for compat with things that still use the old name
SlashCo.TraceHullLocator = SlashCo.RandomPosLocator

--- teleport an entity to a random positon
function ENTITY:RandomTeleport(add)
	if not IsValid(self) then
		return
	end

	local vec = SlashCo.RandomPosLocator()

	if not vec then
		return
	end

	if not add then
		add = vector_origin
	end

	local ang = Angle(0, math.Rand(-180, 180), 0)

	if g_SlashCoDebug then
		debugoverlay.Cross(vec + add, 20, 20, blue, true)
	end

	self:SetPos(vec + add)
	self:DropToFloor()
	if self:IsPlayer() then
		self:SetEyeAngles(ang)
	else
		self:SetAngles(ang)
	end
end

local height_offset = 25
local up = Vector(0, 0, height_offset)
local down = Vector(0, 0, -200)
function SlashCo.LocalizedTraceHullLocator(ent, min_range, range, offset)
	if not offset then
		offset = 0
	end

	if not range then
		range = min_range
		min_range = math.min(25, min_range)
	end

	--Repeatedly positioning a TraceHull to a random localized position to find a spot with enough space for a player or npc.

	local pos = vector_origin
	local linePos = vector_origin
	local err_linehit = 0
	local err_hullhit = 0
	local offset_local = ent:GetForward() * offset
	local success
	for _ = 0, 350 do
		local randPos = vector_up * math.random(min_range, range)
		randPos:Rotate(AngleRand())
		randPos.z = randPos.z / 2 + height_offset * 2

		pos = ent:LocalToWorld(offset_local + randPos)

		local tr_l = util.TraceLine({
			start = pos,
			endpos = pos + down,
		})

		if not tr_l.Hit then
			err_linehit = err_linehit + 1
			continue
		end

		linePos = pos
		pos = tr_l.HitPos + up

		local mins, maxs = ent:WorldSpaceAABB()
		mins.z = 0
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
		if err_hullhit > 125 and not tr.HitNonWorld then
			success = true
			break
		end

		err_hullhit = err_hullhit + 1
	end

	if success then
		if g_SlashCoDebug then
			debugoverlay.Line(linePos, pos - Vector(0, 0, 200), 4, Color(0, 0, 255), true)
			debugoverlay.Cross(linePos, 40, 4, Color(255, 0, 255), true)
			debugoverlay.Cross(pos, 20, 4, Color(0, 128, 255), true)
		end

		return pos
	end

	if g_SlashCoDebug then
		print(string.format("TRACE LOCATOR FAILURE -- line fails: %d; hull fails: %d", err_linehit, err_hullhit))
		debugoverlay.Line(linePos, pos - Vector(0, 0, 200), 4, Color(0, 0, 255), true)
		debugoverlay.Cross(linePos, 40, 4, Color(255, 0, 0), true)
		debugoverlay.Cross(pos, 20, 4, Color(0, 128, 255), true)
	end
end

--- for compat with things that still use the old function
SlashCo.LocalizedTraceHullLocatorAdvanced = SlashCo.LocalizedTraceHullLocator