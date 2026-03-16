AddCSLuaFile()

SlashCo = SlashCo or {}
SlashCoItems = SlashCoItems or {}
SlashCoEffects = SlashCoEffects or {}

---load items and effects

function SlashCo.RegisterItem(table, name)
	if SC_LOADEDITEMS then
		error("Tried to register an item illegally", 2)
		return
	end

	name = name or table.Name
	SlashCoItems[name] = table
	SlashCo.PrecacheItem(name)
end

function SlashCo.RegisterEffect(table, name)
	if SC_LOADEDITEMS then
		error("Tried to register an effect illegally", 2)
		return
	end

	name = name or table.Name
	SlashCoEffects[name] = table
end

function SlashCo.GetItemByEntity(class)
	for name, tbl in pairs(SlashCoItems) do
		if tbl.EntClass and tbl.EntClass == class then
			return name
		end
	end

	return nil
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
hook.Add("GameContentChanged", "SlashCo:RefreshItems", SlashCo.LoadItems)
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
	for id, entry in ipairs(perkTable) do
		if entry == "" or entry == "," then
			table.remove(perkTable, id)
		end
	end
end

local function HasEffect(ply, effectName)
	return string.find(ply:GetActiveEffects(), effectName) ~= nil
end

local function GetEffects(ply)
	return string.Split(ply:GetActiveEffects(), ",")
end

local function AddEffect(ply, effectName)
	if HasEffect(ply, effectName) then return end

	local effects = GetEffects(ply)
	table.insert(effects, effectName)
	RemoveEmptyEntires(effects)

	ply:SetActiveEffects(table.concat(effects, ","))
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

		self:EmitSound("slashco/survivor/effectexpire_breath.mp3")
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

	self:EmitSound("slashco/survivor/effectexpire_breath.mp3")

	RemoveEffect(self, effectName)
	for effectID, effName in pairs(self.ActiveEffects or {}) do
		if effName == effectName then
			timer.Remove("itemEffectExpire_" .. effectID)
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

	self:EmitSound("slashco/survivor/effectexpire_breath.mp3")
	for effectID, _ in pairs(self.ActiveEffects or {}) do
		timer.Remove("itemEffectExpire_" .. effectID)
	end
end

-- Collects all things that have this value for a combined result. This sucks... ToDo: Finish/Rework this!
local itemSlots = {"item", "item2"}
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
	return self:GetNW2String(slot, "none")
end

if SERVER then
	-- slot can be omitted if desired
	local validSlots = {
		item2 = true,
		"item2", -- added for table.concat to work as it needs a sequential table.
		item = true,
		"item",
	}
	function PLAYER:SetItem(slot, item)
		if not slot then
			if SlashCoItems[item] then
				slot = SlashCoItems[item].IsSecondary and "item2" or "item"
			else
				return
			end
		end

		if not validSlots[slot] then
			error("Tried to use an invalid item slot! (Got: " .. tostring(slot) .. ", Expected one of: " .. table.concat(validSlots, ", ") .. ")")
			return
		end

		if item ~= "none" and not SlashCoItems[item] and not SlashCoEffects[item] then
			error("Tried to set an invalid item! (Item: " .. (tostring(item) or "") .. ")")
			return
		end

		self:SetNW2String(slot, item)
	end
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

hook.Add("GameContentChanged", "SlashCo:RefreshItems", function()
	SlashCo.LoadItems()
	SlashCo.LoadItemPatches()
end)