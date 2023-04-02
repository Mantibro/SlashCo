local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

SlashCo.UseItem = function(ply)
    if CLIENT then
        return
    end

    if game.GetMap() == "sc_lobby" then
        return
    end

    if ply:Team() ~= TEAM_SURVIVOR then
        return
    end

    if ply:IsFrozen() then
        return
    end

    local item = ply:GetNWString("item2", "none")
    if item == "none" then
        item = ply:GetNWString("item", "none")
    end

    if SlashCoItems[item] and SlashCoItems[item].OnUse then
        local doNotRemove = SlashCoItems[item].OnUse(ply)
        if not doNotRemove then
            SlashCo.ChangeSurvivorItem(ply, "none")
        end
    end
end

SlashCo.DropAllItems = function(ply)
    if ply:GetNWString("item2", "none") ~= "none" then
        SlashCo.DropItem(ply)
    end

    SlashCo.DropItem(ply)
end

SlashCo.DropItem = function(ply)
    if CLIENT then
        return
    end

    if game.GetMap() == "sc_lobby" then
        return
    end

    if ply:Team() ~= TEAM_SURVIVOR then
        return
    end

    if ply:IsFrozen() then
        return
    end

    local item = ply:GetNWString("item2", "none")
    if item == "none" then
        item = ply:GetNWString("item", "none")
    end

    if SlashCoItems[item] and SlashCoItems[item].OnDrop then

        if SlashCoItems[item].IsSecondary then
            ply:SetNWString("item2", "none")
            timer.Simple(0.25, function()
                SlashCoItems[item].OnDrop(ply)
            end)
        else
            ply:SetNWString("item", "none")
            timer.Simple(0.18, function()
                SlashCoItems[item].OnDrop(ply)
            end)
        end
    end
end

SlashCo.RemoveItem = function(ply, isSec)
    if isSec then
        local item = ply:GetNWString("item2", "none")
        timer.Simple(0.25, function()
            if (SlashCoItems[item] and SlashCoItems[item].OnSwitchFrom) then
                SlashCoItems[item].OnSwitchFrom(ply)
            end
        end)
        ply:SetNWString("item2", "none")
    else
        local item = ply:GetNWString("item", "none")
        timer.Simple(0.18, function()
            if (SlashCoItems[item] and SlashCoItems[item].OnSwitchFrom) then
                SlashCoItems[item].OnSwitchFrom(ply)
            end
        end)
        ply:SetNWString("item", "none")
    end
end

SlashCo.ChangeSurvivorItem = function(ply, id)
    if CLIENT then
        return
    end

    if SlashCoItems[id] then
        if SlashCoItems[id].IsSecondary then
            local item = ply:GetNWString("item2", "none")
            if (SlashCoItems[item] and SlashCoItems[item].OnSwitchFrom) then
                SlashCoItems[item].OnSwitchFrom(ply)
            end
            ply:SetNWString("item2", id)
        else
            local item = ply:GetNWString("item", "none")
            if (SlashCoItems[item] and SlashCoItems[item].OnSwitchFrom) then
                SlashCoItems[item].OnSwitchFrom(ply)
            end
            ply:SetNWString("item", id)
        end

        if SlashCoItems[id].OnPickUp then
            SlashCoItems[id].OnPickUp(ply)
        end

        if SlashCoItems[id].EquipSound then
            ply:EmitSound(SlashCoItems[id].EquipSound())
        else
            ply:EmitSound("slashco/survivor/item_equip" .. math.random(1, 2) .. ".mp3")
        end
    elseif id == "none" then
        ply:SetNWString("item", "none")
    end
end

SlashCo.ItemPickUp = function(ply, item, itid)
    if CLIENT then
        return
    end

    if SlashCoItems[itid].IsSecondary and ply:GetNWString("item2", "none") ~= "none"
            or not SlashCoItems[itid].IsSecondary and ply:GetNWString("item", "none") ~= "none" then
        return
    end

    SlashCo.ChangeSurvivorItem(ply, itid)

    ents.GetByIndex(item):Remove()
end