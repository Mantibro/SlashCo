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

	SlashCoItems[name] = table
end

function SlashCo.RegisterEffect(table, name)
	if SC_LOADEDITEMS then
		error("Tried to register an effect illegally", 2)
		return
	end

	SlashCoEffects[name] = table
end

function SlashCo.GetItemTable(name)
	return SlashCoItems[name]
end

function SlashCo.GetEffectTable(name)
	return SlashCoEffects[name]
end

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

---remainder of init code

SlashCo.SpawnableItems = {}
for k, v in pairs(SlashCoItems) do
	if v.IsSpawnable then
		table.insert(SlashCo.SpawnableItems, k)
	end
end

local PLAYER = FindMetaTable("Player")

---gives a player an effect
function PLAYER:AddEffect(value, duration)
	if not self:EffectFunction("OnRemoved") then
		self:EffectFunction("OnExpired")
	end
	self:SetItem("itemEffect", value)
	self:EffectFunction("OnApplied")
	timer.Create("itemEffectExpire_" .. self:UserID(), duration, 1, function()
		if not IsValid(self) then
			return
		end
		self:EmitSound("slashco/survivor/effectexpire_breath.mp3")
		self:EffectFunction("OnExpired")
		self:SetItem("itemEffect", "none")
	end)
end

---calls the <funcName> function of a player's effect with passed args
function PLAYER:EffectFunction(funcName, ...)
	local effect = self:GetItem("itemEffect")
	if SlashCoEffects[effect] and SlashCoEffects[effect][funcName] then
		return SlashCoEffects[effect][funcName](self, ...)
	end
end

---removes a player's effect
function PLAYER:ClearEffect()
	if not self:EffectFunction("OnRemoved") then
		self:EffectFunction("OnExpired")
	end
	if self:GetItem("itemEffect") ~= "none" then
		self:EmitSound("slashco/survivor/effectexpire_breath.mp3")
	end

	self:SetItem("itemEffect", "none")
	timer.Remove("itemEffectExpire_" .. self:UserID())
end

---check the <valueName> value of a player's item in a specific slot
--this doesn't include a team check because we assume that it's in a survivor-only context
function PLAYER:ItemValue(valueName, fallback, isSecondary)
	local effect = self:GetItem("itemEffect")
	if SlashCoEffects[effect] and SlashCoEffects[effect][valueName] then
		return SlashCoEffects[effect][valueName]
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
		item = self:GetItem("itemEffect")
		if SlashCoItems[item] and SlashCoItems[item][value] then
			return SlashCoItems[item][value]
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

if SERVER then
	function PLAYER:GetItem(slot)
		return self:GetNWString(slot, "none")
	end

	-- slot can be omitted if desired
	function PLAYER:SetItem(slot, item)
		if not slot then
			if SlashCoItems[item] then
				slot = SlashCoItems[item].IsSecondary and "item2" or "item"
			elseif SlashCoEffects[item] then
				slot = "itemEffect"
			else
				return
			end
		end

		self:SetNWString(slot, item)
		SlashCo.SendValue(self, "preItem", item) -- networking on nwvars can be slow, this acts as a backup
	end
else
	SlashCo.PreItem = SlashCo.PreItem or "none"

	hook.Add("scValue_preItem", "SlashCoPreItem", function(item, slot)
		if not slot then
			SlashCo.PreItem = item or "none"
			return
		end

		if not SlashCoItems[SlashCo.PreItem] then
			return
		end

		local isSecondary = slot == "item2"
		local itemSecondary = SlashCoItems[SlashCo.PreItem].IsSecondary or false
		if itemSecondary == isSecondary then
			SlashCo.PreItem = "none"
		end
	end)

	function PLAYER:GetItem(slot)
		local item = self:GetNWString(slot, "none")

		if self ~= LocalPlayer() or SlashCo.PreItem == "none" or slot == "itemEffect" then
			return item
		end

		local isSecondary = slot == "item2"
		local itemSecondary = SlashCoItems[SlashCo.PreItem].IsSecondary or false
		if itemSecondary == isSecondary then
			if item == "none" and SlashCoItems[SlashCo.PreItem] then
				return SlashCo.PreItem
			end

			SlashCo.PreItem = "none"
		end

		return item
	end
end

---internal: checks effect function first before checking the specified slot
function PLAYER:ItemFunctionInternal(value, slot, ...)
	local effect = self:GetItem("itemEffect")
	if SlashCoEffects[effect] and SlashCoEffects[effect][value] then
		return SlashCoEffects[effect][value](self, ...)
	end

	local item = self:GetItem(slot)
	if SlashCoItems[item] and SlashCoItems[item][value] then
		return SlashCoItems[item][value](self, ...)
	end
end
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