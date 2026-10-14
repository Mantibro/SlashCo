AddCSLuaFile()

SlashCo = SlashCo or {}
SlashCoItems = SlashCoItems or {}
SlashCoEffects = SlashCoEffects or {}

-- RaphaelIT7 (ToDo): Needs more testing about possibly desyncing IDs (Could possibly happen on mounting/unmounting of workshop items?)
local ITEM_ID_BITS = 16
local ITEM_ID_MASK = 0xFFFF
local itemIDs, itemNames
local function BuildItemIDs()
	itemIDs, itemNames = {}, {}

	local names = table.GetKeys(SlashCoItems)
	table.Add(names, table.GetKeys(SlashCoEffects))
	table.sort(names)

	for id, name in ipairs(names) do
		itemIDs[name] = id
		itemNames[id] = name
	end
end

function SlashCo.GetItemID(name)
	if not itemIDs then
		BuildItemIDs()
	end

	return itemIDs[name] or 0
end

function SlashCo.GetItemName(id)
	if not itemNames then
		BuildItemIDs()
	end

	return itemNames[id] or "none"
end

---load items and effects

function SlashCo.RegisterItem(table, name)
	if SC_LOADEDITEMS then
		error("Tried to register an item illegally", 2)
		return
	end

	name = name or table.Name
	SlashCoItems[name] = table
	itemIDs, itemNames = nil, nil
	SlashCo.PrecacheItem(name)
end

function SlashCo.RegisterEffect(table, name)
	if SC_LOADEDITEMS then
		error("Tried to register an effect illegally", 2)
		return
	end

	name = name or table.Name
	SlashCoEffects[name] = table
	itemIDs, itemNames = nil, nil
end

function SlashCo.GetItemByEntity(class)
	for name, tbl in pairs(SlashCoItems) do
		if tbl.EntClass and tbl.EntClass == class then
			return name
		end
	end

	return nil
end

function SlashCo.FindItemWithField(key, value)
	for name, tbl in pairs(SlashCoItems) do
		if tbl[key] == value then
			return name, tbl
		end
	end

	return nil, nil
end

function SlashCo.GetItemTable(name)
	return SlashCoItems[name]
end

function SlashCo.GetEffectTable(name)
	return SlashCoEffects[name]
end

function SlashCo.LoadItems()
	SC_LOADEDITEMS = nil
	local effect_files = file.Find("slashco/effect/*.lua", "LUA")
	for _, v in ipairs(effect_files) do
		AddCSLuaFile("slashco/effect/" .. v)
		include("slashco/effect/" .. v)
	end

	local item_files = file.Find("slashco/item/*.lua", "LUA")
	for _, v in ipairs(item_files) do
		AddCSLuaFile("slashco/item/" .. v)
		include("slashco/item/" .. v)
	end
	SC_LOADEDITEMS = true
end
SlashCo.LoadItems()

---remainder of init code

SlashCo.SpawnableItems = {}
for k, v in pairs(SlashCoItems) do
	if v.IsSpawnable then
		table.insert(SlashCo.SpawnableItems, k)
	end
end

local PLAYER = FindMetaTable("Player")

local function RemoveEmptyEntires(perkTable)
	for id = #perkTable, 1, -1 do
		local entry = perkTable[id]
		if entry == "" or entry == "," then
			table.remove(perkTable, id)
		end
	end
end

local function GetEffects(ply)
	return string.Split(ply:GetActiveEffects(), ",")
end

local function HasEffect(ply, effectName)
	return table.HasValue(GetEffects(ply), effectName)
end

local function AddEffect(ply, effectName)
	if HasEffect(ply, effectName) then return end

	local effects = GetEffects(ply)
	table.insert(effects, effectName)
	RemoveEmptyEntires(effects)

	ply:SetActiveEffects(table.concat(effects, ","))
	ply:UpdateSpeed()
end

local function RemoveEffect(ply, effectName)
	if not HasEffect(ply, effectName) then return end

	local effects = GetEffects(ply)
	for id, effName in ipairs(effects) do
		if effName == effectName then
			table.remove(effects, id)
			break
		end
	end
	RemoveEmptyEntires(effects)

	ply:SetActiveEffects(table.concat(effects, ","))
	ply:UpdateSpeed()
end

---gives a player an effect
function PLAYER:AddEffect(effectName, duration)
	if not self:EffectFunction(effectName, "OnRemoved") then
		self:EffectFunction(effectName, "OnExpired")
	end
	AddEffect(self, effectName)
	self:EffectFunction(effectName, "OnApplied")
	GameData.EffectCounter = (GameData.EffectCounter or 0) + 1
	local effectID = GameData.EffectCounter
	self.ActiveEffects = self.ActiveEffects or {}
	self.ActiveEffects[effectID] = effectName
	timer.Create("itemEffectExpire_" .. GameData.EffectCounter, duration, 1, function()
		if not IsValid(self) then
			return
		end

		self.ActiveEffects[effectID] = nil

		for _, effName in pairs(self.ActiveEffects) do
			-- There is another effect stacked on top of this- so skip.
			if effName == effectName then return end
		end

		SlashCo.AudioSystem.EmitSound(self, "slashco/survivor/effectexpire_breath.mp3")
		self:EffectFunction(effectName, "OnExpired")
		RemoveEffect(self, effectName)
	end)
end

---calls the <funcName> function of a player's effect with passed args
function PLAYER:EffectFunction(effectName, funcName, ...)
	if not HasEffect(self, effectName) then return end

	if SlashCoEffects[effectName] and SlashCoEffects[effectName][funcName] then
		return SlashCoEffects[effectName][funcName](self, ...)
	end
end

---removes a player's effect (removes all instances of it in case it's stacked)
function PLAYER:ClearEffect(effectName)
	if not HasEffect(self, effectName) then return end
	if not self:EffectFunction(effectName, "OnRemoved") then
		self:EffectFunction(effectName, "OnExpired")
	end

	SlashCo.AudioSystem.EmitSound(self, "slashco/survivor/effectexpire_breath.mp3")

	RemoveEffect(self, effectName)
	for effectID, effName in pairs(self.ActiveEffects or {}) do
		if effName == effectName then
			timer.Remove("itemEffectExpire_" .. effectID)
			self.ActiveEffects[effectID] = nil
		end
	end
end

function PLAYER:ClearEffects()
	local effects = GetEffects(self)
	for _, effectName in ipairs(effects) do
		if not self:EffectFunction(effectName, "OnRemoved") then
			self:EffectFunction(effectName, "OnExpired")
		end

		RemoveEffect(self, effectName)
	end

	SlashCo.AudioSystem.EmitSound(self, "slashco/survivor/effectexpire_breath.mp3")
	for effectID, _ in pairs(self.ActiveEffects or {}) do
		timer.Remove("itemEffectExpire_" .. effectID)
	end
	self.ActiveEffects = {}
end

-- RaphaelIT7: speed effects of items & effects are known shared so that the client can predict them
-- ToDo: Look into making a few tirggers predictable to further avoid server-only effects
local BASE_RUN_SPEED = 300
local BASE_WALK_SPEED = 200
local BASE_SLOW_WALK_SPEED = 100
-- RaphaelIT7: We use KeyedSpeed to network both speed and priority as 16 bits each (saves a delta change & using up another slot)
local MAX_SHORT = 0x7FFF
local itemSlots = {"item", "item2"}
local function UpdateKeyedSpeed(ply)
	local speed, priority
	for _, effect in pairs(ply.SpeedEffects or {}) do
		if not priority or effect[2] > priority then
			speed, priority = effect[1], effect[2]
		end
	end

	ply:SetKeyedSpeed(speed and bit.bor(bit.lshift(priority, 16), math.Clamp(math.floor(speed), 0, MAX_SHORT)) or 0)
	ply:UpdateSpeed()
end

function PLAYER:AddSpeedEffect(key, speed, priority)
	self.SpeedEffects = self.SpeedEffects or {}
	self.SpeedEffects[key] = { speed, priority }
	UpdateKeyedSpeed(self)
end

function PLAYER:RemoveSpeedEffect(key)
	if not self.SpeedEffects then return end

	self.SpeedEffects[key] = nil
	UpdateKeyedSpeed(self)
end

function PLAYER:UpdateSpeed()
	if self:Team() ~= TEAM_SURVIVOR then return end

	local speed, priority
	local function CheckNewSpeed(newSpeed, newPriority)
		if not priority or newPriority > priority then
			speed, priority = newSpeed, newPriority
		end
	end

	local keyedSpeed = self:GetKeyedSpeed()
	if keyedSpeed ~= 0 then
		CheckNewSpeed(bit.band(keyedSpeed, 0xFFFF), bit.arshift(keyedSpeed, 16))
	end

	for _, effectName in ipairs(GetEffects(self)) do
		local effect = SlashCoEffects[effectName]
		if effect and effect.Speed then
			CheckNewSpeed(effect.Speed, effect.SpeedPriority)
		end
	end

	for _, slot in ipairs(itemSlots) do
		local item = SlashCoItems[self:GetItem(slot)]
		if item and item.Speed then
			local itemSpeed = item.Speed
			if isfunction(itemSpeed) then
				itemSpeed = itemSpeed(self)
			end

			CheckNewSpeed(itemSpeed, item.SpeedPriority)
		end
	end

	speed = speed or BASE_RUN_SPEED
	self:SetRunSpeed(speed)
	self:SetWalkSpeed(math.min(speed, BASE_WALK_SPEED))
	self:SetSlowWalkSpeed(math.min(speed, BASE_SLOW_WALK_SPEED))
	self:SetMaxSpeed(speed) -- RaphaelIT7: While "This is called automatically by the engine" is true, it does not apply to prediction which is why were setting it ourselves
end

if SERVER then
	hook.Add("SlashCo:PlayerDeath", "SlashCo:ResetSpeedEffects", function(ply)
		ply.SpeedEffects = nil
		UpdateKeyedSpeed(ply)
	end)
end

-- Collects all things that have this value for a combined result. This sucks... ToDo: Finish/Rework this!
function PLAYER:StackedItemValue(valueName, initialValue)
	local value = 0
	local activePerks = SlashCo.GetActivePerks(self)
	for _, perk in ipairs(activePerks) do
		local perkValue = activePerks[perk][valueName]
		if perkValue ~= nil then
			value = value + AddItemValue(perkValue)
		end
	end

	local effects = GetEffects(self)
	for _, effectName in ipairs(effects) do
		if SlashCoEffects[effectName] and SlashCoEffects[effectName][valueName] then
			value = value + AddItemValue(SlashCoEffects[effectName][valueName])
		end
	end

	for _, slot in ipairs(itemSlots) do
		local item = self:GetItem(slot)
		if SlashCoItems[item] and SlashCoItems[item][valueName] then
			value = value + AddItemValue(SlashCoItems[item][valueName])
		end
	end

	return value == 0 and initialValue or math.max(value, 0.1)
end

---check the <valueName> value of a player's item in a specific slot
--this doesn't include a team check because we assume that it's in a survivor-only context
function PLAYER:ItemValue(valueName, fallback, isSecondary)
	local effects = GetEffects(self)
	for _, effectName in ipairs(effects) do
		if SlashCoEffects[effectName] and SlashCoEffects[effectName][valueName] then
			return SlashCoEffects[effectName][valueName]
		end
	end

	local slot = isSecondary and "item2" or "item"
	local item = self:GetItem(slot)
	if SlashCoItems[item] and SlashCoItems[item][valueName] then
		return SlashCoItems[item][valueName]
	end

	return fallback
end

---check the <valueName> value across a player's entire 'inventory' (effect first, then item2, then item1)
function PLAYER:ItemValue2(value, fallback, noEffect)
	local item
	if not noEffect then
		item = GetEffects(self)
		for _, effectName in ipairs(item) do
			if SlashCoEffects[effectName] and SlashCoEffects[effectName][value] then
				return SlashCoEffects[effectName][value]
			end
		end
	end

	item = self:GetItem("item2")
	if item == "none" then
		item = self:GetItem("item")
	end
	if SlashCoItems[item] and SlashCoItems[item][value] then
		return SlashCoItems[item][value]
	end

	return fallback
end

---returns whether a player has a specific item
function PLAYER:HasItem(item, isSecondary)
	return self:GetItem(isSecondary and "item2" or "item") == item
end

---calls the <funcName> function of a player's item1 with passed args
---checks the player's effect slot first!
function PLAYER:ItemFunction(funcName, ...)
	return self:ItemFunctionInternal(funcName, "item", ...)
end

---calls the <funcName> function of a player's item1 with passed args, or a fallback if it doesn't return anything
---function and fallback must both return tables
---checks the player's effect slot first!
function PLAYER:ItemFunctionOrElse(funcName, fallback, ...)
	local val = { self:ItemFunctionInternal(funcName, "item", ...) }
	if val[1] then
		return unpack(val)
	end
	return unpack(fallback)
end

---calls the <funcName> function of a player's item2 with passed args
---checks the player's effect slot first!
function PLAYER:SecondaryItemFunction(funcName, ...)
	return self:ItemFunctionInternal(funcName, "item2", ...)
end

---calls the <funcName> function of a player's item2 with passed args, or a fallback if it doesn't return anything
---function and fallback must both return tables
---checks the player's effect slot first!
function PLAYER:SecondaryItemFunctionOrElse(funcName, fallback, ...)
	local val = { self:ItemFunctionInternal(funcName, "item2", ...) }
	if val[1] then
		return unpack(val)
	end
	return unpack(fallback)
end

---calls the <funcName> function of a specific item; ignores the player's 'inventory' entirely
---good for situations where you already know the player's item
function PLAYER:ItemFunction2(funcName, item, ...)
	if SlashCoItems[item] and SlashCoItems[item][funcName] then
		return SlashCoItems[item][funcName](self, ...)
	end
end

function PLAYER:ItemFunction2OrElse(funcName, item, fallback, ...)
	if not SlashCoItems[item] or not SlashCoItems[item][funcName] then
		return unpack(fallback)
	end

	local val = { SlashCoItems[item][funcName](self, ...) }
	if val[1] then
		return unpack(val)
	end
	return unpack(fallback)
end

function PLAYER:GetItem(slot)
	local items = self:GetItems()
	if slot == "item2" then
		items = bit.rshift(items, ITEM_ID_BITS)
	end

	return SlashCo.GetItemName(bit.band(items, ITEM_ID_MASK))
end

-- slot can be omitted if desired
function PLAYER:SetItem(slot, item)
	if not slot then
		if SlashCoItems[item] then
			slot = SlashCoItems[item].IsSecondary and "item2" or "item"
		else
			return
		end
	end

	if slot ~= "item" and slot ~= "item2" then
		error("Tried to use an invalid item slot! (Got: " .. tostring(slot) .. ", Expected one of: item, item2)")
		return
	end

	if item ~= "none" and not SlashCoItems[item] and not SlashCoEffects[item] then
		error("Tried to set an invalid item! (Item: " .. (tostring(item) or "") .. ")")
		return
	end

	local id = SlashCo.GetItemID(item)
	local items = self:GetItems()
	if slot == "item2" then
		items = bit.bor(bit.band(items, ITEM_ID_MASK), bit.lshift(id, ITEM_ID_BITS))
	else
		items = bit.bor(bit.band(items, bit.lshift(ITEM_ID_MASK, ITEM_ID_BITS)), id)
	end

	self:SetItems(items)
	self:UpdateSpeed()
end

---internal: checks effect function first before checking the specified slot
function PLAYER:ItemFunctionInternal(value, slot, ...)
	local effects = GetEffects(self)
	for _, effectName in ipairs(effects) do
		if SlashCoEffects[effectName] and SlashCoEffects[effectName][value] then
			local ret = SlashCoEffects[effectName][value](self, ...)
			-- RaphaelIT7: If an effect returns nothing we will continue the next active effects.
			-- This allows multiple effects to for example render Screenscpace at once.
			if ret ~= nil then
				return ret
			end
		end
	end

	local item = self:GetItem(slot)
	if SlashCoItems[item] and SlashCoItems[item][value] then
		return SlashCoItems[item][value](self, ...)
	end
end

function SlashCo.LoadItemPatches()
	---load patch files; these are specifically intended to modify existing addon code
	local effect_patches = file.Find("slashco/patch/effect/*.lua", "LUA")
	for _, v in ipairs(effect_patches) do
		AddCSLuaFile("slashco/patch/effect/" .. v)
		include("slashco/patch/effect/" .. v)
	end

	local item_patches = file.Find("slashco/patch/item/*.lua", "LUA")
	for _, v in ipairs(item_patches) do
		AddCSLuaFile("slashco/patch/item/" .. v)
		include("slashco/patch/item/" .. v)
	end
end
SlashCo.LoadItemPatches()

hook.Add("SlashCo:GameContentChanged", "SlashCo:RefreshItems", function()
	SlashCo.LoadItems()
	SlashCo.LoadItemPatches()
end)

local USE_RADIUS = 80
local USE_MASK = bit.bor(MASK_SOLID, CONTENTS_DEBRIS, CONTENTS_PLAYERCLIP)
local USE_HULL_SIZE = Vector(16, 16, 16)
local USE_TANGENTS = {0, 1, 0.57735026919, 0.3639702342, 0.267949192431, 0.1763269807, -0.1763269807, -0.267949192431}
local function IntervalDistance(value, min, max)
	if value < min then
		return min - value
	elseif value > max then
		return value - max
	end

	return 0
end

local function DistanceToLine(point, lineA, lineB)
	local dir = lineB - lineA
	local div = dir:Dot(dir)
	local t = div < 0.00001 and 0 or dir:Dot(point - lineA) / div

	return point:Distance(lineA + dir * t)
end

local function IsKnownUseable(ent)
	return ent.PredictPickUp ~= nil or ent.PredictUse ~= nil
end

local function IsNeverUseable(ent)
	return (ent:IsWorld() or ent:IsPlayer()) and not IsValid(ent:GetParent())
end

local FCAP_USE_ONGROUND = 0x00000100
local FCAP_USE_IN_RADIUS = 0x00000200
local function IsUsableOnGround(ent)
	return bit.band(ent:ObjectCaps(), FCAP_USE_ONGROUND) ~= 0
end

local function IsUsableInRadius(ent)
	return bit.band(ent:ObjectCaps(), FCAP_USE_IN_RADIUS) ~= 0
end

-- RaphaelIT7: We try to mimic CBasePlayer::FindUseEntity
-- if we ever pick up a item that the server would've not have, I'd have no idea how the client could recover nicely from that
-- See https://github.com/RaphaelIT7/obsolete-source-engine/blob/48416f1a3b1ab318c79d513117056a708eda6eee/game/shared/baseplayer_shared.cpp#L1070
function SlashCo.FindUseEntity(ply)
	local eyePos = ply:EyePos()
	local angles = ply:EyeAngles()
	local forward, up = angles:Forward(), angles:Up()
	local centerZ = ply:WorldSpaceCenter().z
	local minZ, maxZ = centerZ + ply:OBBMins().z, centerZ + ply:OBBMaxs().z

	local nearest
	for i, tangent in ipairs(USE_TANGENTS) do
		local tr
		if i == 1 then
			tr = util.TraceLine({
				start = eyePos,
				endpos = eyePos + forward * 1024,
				mask = USE_MASK,
				filter = ply,
			})
		else
			tr = util.TraceHull({
				start = eyePos,
				endpos = eyePos + (forward - up * tangent):GetNormalized() * 72,
				mins = -USE_HULL_SIZE,
				maxs = USE_HULL_SIZE,
				mask = USE_MASK,
				filter = ply,
			})
		end

		local ent = tr.Entity
		if not IsValid(ent) or IsNeverUseable(ent) then continue end

		local usable = IsKnownUseable(ent)
		while not usable do
			local parent = ent:GetMoveParent()
			if not IsValid(parent) then break end

			ent = parent
			if IsNeverUseable(ent) then break end

			usable = IsKnownUseable(ent)
		end

		if not usable then continue end

		local delta = tr.HitPos - eyePos
		delta.z = IntervalDistance(tr.HitPos.z, minZ, maxZ)

		if delta:Length() >= USE_RADIUS then continue end
		if i == 1 then
			return ent
		end

		nearest = ent
	end

	local ground = ply:GetGroundEntity()
	if IsValid(ground) and IsUsableOnGround(ground) then
		nearest = ground
	end

	local nearestDist = math.huge
	if nearest then
		nearestDist = DistanceToLine(nearest:NearestPoint(eyePos), eyePos, forward)
	end

	for _, ent in ents.Iterator() do
		if ent == nearest or IsNeverUseable(ent) then continue end
		if not IsUsableInRadius(ent) then continue end

		local mins, maxs = ent:WorldSpaceAABB()
		if not util.IsBoxIntersectingSphere(mins, maxs, eyePos, USE_RADIUS) then continue end

		local point = ent:NearestPoint(eyePos)
		local dir = point - eyePos

		if dir:LengthSqr() == 0 then
			dir = forward
		else
			dir:Normalize()
		end

		-- Need to be looking at the object more or less
		if dir:Dot(forward) < 0.8 then continue end

		local dist = DistanceToLine(point, eyePos, forward)
		if dist >= nearestDist then continue end

		-- Since this has purely been a radius search to this point, we now
		-- make sure the object isn't behind glass or a grate.
		local tr = util.TraceLine({
			start = eyePos,
			endpos = point,
			mask = USE_MASK,
			filter = ply,
		})

		if tr.Fraction == 1 or tr.Entity == ent then
			nearest = ent
			nearestDist = dist
		end
	end

	return nearest
end

if SERVER then
	local debugUse = CreateConVar("slashco_debug_use", "0", FCVAR_NONE)
	hook.Add("FindUseEntity", "SlashCo:DebugFindUseEntity", function(ply, defaultEnt)
		if not debugUse:GetBool() then return end

		local ent = SlashCo.FindUseEntity(ply)
		if ent == defaultEnt or (not ent and not (IsValid(defaultEnt) and (defaultEnt.PredictPickUp or defaultEnt.PredictUse))) then return end

		MsgN("[SlashCo] FindUseEntity \"", ply:Nick(), "\" found ", tostring(ent), " - engine found ", tostring(defaultEnt))
	end)

	return
end

local function CanHandleItems(ply)
	return not GameData.IsLobby and ply:Team() == TEAM_SURVIVOR and not ply:IsFrozen()
end

local function GetUsedItem(ply)
	local item = ply:GetItem("item2")
	if item == "none" then
		return ply:GetItem("item")
	end

	return item
end

local function PredictUse(ply)
	local itemTable = SlashCoItems[GetUsedItem(ply)]
	if not itemTable or not itemTable.OnUsePredicted then return end

	if itemTable.OnUsePredicted(ply) then return end

	if itemTable.UseEffect then
		AddEffect(ply, itemTable.UseEffect)
	end

	ply:SetItem("item", "none")
end

local lastDropTime = 0
local function PredictDrop(ply)
	local item = GetUsedItem(ply)
	local itemTable = SlashCoItems[item]
	if not itemTable or ply:ItemFunction2("PreDrop", item) then return end

	if itemTable.IsSecondary then
		if ply:ItemFunction("PreDropSecondary", item) then return end

		ply:PredictedViewPunch(Angle(-6, 0, 0))
		ply:SetItem("item2", "none")
	else
		ply:PredictedViewPunch(Angle(-2, 0, 0))
		ply:SetItem("item", "none")
	end

	lastDropTime = CurTime()
end

local PICKUP_COOLDOWN = 1
local function PredictPickUp(ply, ent)
	if ply:GetCurseOfTheJug() or CurTime() - lastDropTime < PICKUP_COOLDOWN or ent:GetDontPickup() then return end

	local item = ent.PrintName
	local itemTable = SlashCoItems[item]
	if not itemTable or itemTable.PrePickUp then return end

	local slot = itemTable.IsSecondary and "item2" or "item"
	if ply:GetItem(slot) ~= "none" then return end

	ply:SetItem(slot, item)
end

hook.Add("PlayerButtonDown", "SlashCo:PredictItems", function(ply, button)
	if not CanHandleItems(ply) then return end

	if SlashCo.IsKeyPressed("USE_ITEM", ply, button) then
		PredictUse(ply)
	elseif SlashCo.IsKeyPressed("DROP_ITEM", ply, button) then
		PredictDrop(ply)
	end
end)

local function CallPredictedUse(ply, ent)
	if ent.PredictUse then
		ent:PredictUse(ply)
	elseif ent.PredictPickUp then
		PredictPickUp(ply, ent)
	end
end

GameData.PredictedUse = GameData.PredictedUse or {}
local function TriggerPredictedUse(ply)
	local serverCurTime = UnPredictedCurTime()
	for curTime, ent in SortedPairs(GameData.PredictedUse) do
		if not IsValid(ent) or serverCurTime > curTime then
			GameData.PredictedUse[curTime] = nil
			continue
		end

		CallPredictedUse(ply, ent)
	end
end

hook.Add("KeyPress", "SlashCo:PredictEntityUse", function(ply, key)
	if key ~= IN_USE or not CanHandleItems(ply) then return end

	-- RaphaelIT7: After the first use prediction will replay the input yet the player may have moved so traces may no longer hit anymore!
	-- So to compensate for that we simply kept track of which were hit and call the functions
	if not IsFirstTimePredicted() then
		TriggerPredictedUse(ply)
		return
	end

	local ent = SlashCo.FindUseEntity(ply)
	if not ent then return end

	GameData.PredictedUse[CurTime()] = ent
	CallPredictedUse(ply, ent)
end)