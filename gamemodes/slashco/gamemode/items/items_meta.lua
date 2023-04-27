local doStuff = {}

local metaMaker = {}

local itemsMeta = {}
local effectsMeta = {}
setmetatable(itemsMeta, { __index = metaMaker })
setmetatable(effectsMeta, { __index = metaMaker })

local items = {}
local effects = {}

doStuff.MakeItem = function(id, name, model, entClass, isSecondary, description, camPos)
    local item = {}
    items[id] = item
    item.ID = id
    item.Name = name or "Item"
    item.Model = model or "models/props_junk/PopCan01a.mdl"
    item.EntClass = entClass or "sc_soda"
    item.Description = description
    item.campos = camPos or Vector(30, 0, 0)
    item.IsSecondary = isSecondary or false
    setmetatable(item, { __index = itemsMeta })
    return item
end

doStuff.MakeEffect = function(id, name)
    local effect = {}
    effects[id] = effect
    effect.Name = name or "Item"
    setmetatable(effect, { __index = effectsMeta })
    return effect
end

function itemsMeta:Register()
    SlashCoItems[self.ID] = self
end
function effectsMeta:Register()
    SlashCoEffects[self.ID] = self
end

function metaMaker:MakeElement(name)
    self[name] = function(self1, value)
        self1[name] = value
    end

    return self
end

metaMaker
        :MakeElement("Name")
        :MakeElement("ChangesSpeed")
        :MakeElement("FuelSpeed")
        :MakeElement("OnFootstep")

itemsMeta
        :MakeElement("Model")
        :MakeElement("EntClass")
        :MakeElement("Icon")
        :MakeElement("Price")
        :MakeElement("Description")
        :MakeElement("CamPos")
        :MakeElement("IsSpawnable")
        :MakeElement("MaxAllowed")
        :MakeElement("OnUse")
        :MakeElement("OnDrop")
        :MakeElement("OnPickUp")
        :MakeElement("IsSecondary")
        :MakeElement("EquipSound")
        :MakeElement("OnBuy")
        :MakeElement("OnSwitchFrom")
        :MakeElement("IsFuel")
        :MakeElement("IsBattery")
        :MakeElement("ViewModel")
        :MakeElement("WorldModelHolstered")
        :MakeElement("WorldModel")
        :MakeElement("OnRenderHolstered")
        :MakeElement("OnRenderWorld")
        :MakeElement("OnRenderHand")

effectsMeta
        :MakeElement("OnExpired")
        :MakeElement("OnApplied")
        :MakeElement("OnRemoved")

SlashCoItems.Generator = doStuff
SLASHCOITEMS_LOADED = true