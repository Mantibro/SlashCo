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
    selectables[index] = true
end

SlashCo.RemoveSelectable = function(index)
    selectables[index] = nil
end

SlashCo.MakeSelectableNow = function(index)
    selectables[index] = true
    SlashCo.BroadcastSelectables()
end

SlashCo.RemoveSelectableNow = function(index)
    selectables[index] = nil
    SlashCo.BroadcastSelectables()
end

SlashCo.ClearSelectables = function()
    table.Empty(selectables)
    SlashCo.BroadcastSelectables()
end
