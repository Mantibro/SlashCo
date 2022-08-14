local SlashCo = SlashCo
local selectables = {}

SlashCo.BroadcastSelectables = function()
    if SERVER then
        net.Start("slashcoSelectables")
        net.WriteTable(selectables)
        net.Broadcast()
    end
end

SlashCo.MakeSelectable = function(index)
    table.insert(selectables, index)
end

SlashCo.RemoveSelectable = function(index)
    table.RemoveByValue( selectables, index )
end

SlashCo.MakeSelectableNow = function(index)
    table.insert(selectables, index)
    SlashCo.BroadcastSelectables()
end

SlashCo.RemoveSelectableNow = function(index)
    table.RemoveByValue( selectables, index )
    SlashCo.BroadcastSelectables()
end

SlashCo.ClearSelectables = function()
    table.Empty(selectables)
    SlashCo.BroadcastSelectables()
end
