local ENTITY = FindMetaTable("Entity")

--- return a random position that something can spawn at
function SlashCo.RandomPosLocator()
	local navtable = navmesh.GetAllNavAreas()

	for i = 1, 150 do
		local navdata = navtable[math.random(1, #navtable)]

		local NW = navdata:GetCorner(0)
		local SE = navdata:GetCorner(2)

		local pos = Vector(math.random(NW[1], SE[1]), math.random(NW[2], SE[2]), 2 + math.max(NW[3], SE[3]))

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

--- for compat with things that still use the old function
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

local up = Vector(0, 0, 25)
local down = Vector(0, 0, -200)

---Get a position near an entity that it can be near
--minRange - minimum distance away
--range - maximum distance away
--offset - offset the center of the search this many units way from the entity in the direction they are looking
--If offset it unspecified, it defaults to 0
--If range is unspecified, minRange becomes the range value and the minimum range becomes 25
function ENTITY:LocalRandomPosition(minRange, range, offset)
	SlashCo.LocalizedTraceHullLocator(self, minRange, range, offset)
end

--- for compat with things that still use the old function
function SlashCo.LocalizedTraceHullLocator(ent, minRange, range, offset)
	if not offset then
		offset = 0
	end

	if not range then
		range = minRange
		minRange = math.min(25, minRange)
	end

	--Repeatedly positioning a TraceHull to a random localized position to find a spot with enough space for a player or npc.

	local pos = vector_origin
	local linePos = vector_origin
	local errorLineHit = 0
	local errorHullHit = 0
	local offsetLocal = ent:GetForward() * offset
	local success
	for _ = 0, 350 do
		local randPos = vector_up * math.random(minRange, range)
		randPos:Rotate(AngleRand())
		randPos.z = randPos.z / 2 + 50

		pos = ent:LocalToWorld(offsetLocal + randPos)

		local trLine = util.TraceLine({
			start = pos,
			endpos = pos + down,
		})

		if not trLine.Hit then
			errorLineHit = errorLineHit + 1
			continue
		end

		linePos = pos
		pos = trLine.HitPos + up

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
		if errorHullHit > 125 and not tr.HitNonWorld then
			success = true
			break
		end

		errorHullHit = errorHullHit + 1
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
		print(string.format("TRACE LOCATOR FAILURE -- line fails: %d; hull fails: %d", errorLineHit, errorHullHit))
		debugoverlay.Line(linePos, pos - Vector(0, 0, 200), 4, Color(0, 0, 255), true)
		debugoverlay.Cross(linePos, 40, 4, Color(255, 0, 0), true)
		debugoverlay.Cross(pos, 20, 4, Color(0, 128, 255), true)
	end
end

--- for compat with things that still use the old function
SlashCo.LocalizedTraceHullLocatorAdvanced = SlashCo.LocalizedTraceHullLocator

--Determines map size
local function init()
	local verts = {}
	for _, v in ipairs(game.GetWorld():GetBrushSurfaces()) do
		if v:IsNoDraw() or v:IsSky() or v:IsWater() then
			continue
		end
		local verts1 = v:GetVertices()
		table.Add(verts, verts1)
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
	SlashCo.MapSize = math.ceil(SlashCo.MaxVec:Distance(SlashCo.MinVec) / 12500)
	SetGlobal2Int("SlashCoMapSize", SlashCo.MapSize)
end
hook.Add("InitPostEntity", "SlashCo_InitMapMesh", init)