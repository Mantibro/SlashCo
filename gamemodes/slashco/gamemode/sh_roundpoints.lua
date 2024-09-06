local PLAYER = FindMetaTable("Player")

local pointAmounts = {
    slasher_kill = 10,
    slasher_demon = 10,
    slasher_win = 25,
    slasher_escape = 10,
    slasher_perfect = 15,
    objective = 25,
    optional = 10,
    escape = 10,
    all_survive = 15,
    last_survive = 5,
    left_behind = 5,
    survive = 10,
    item = 10,
    fast = 5,
    benadryl = 15,
    working = 5
}

---adds points the player will earn at game end
function PLAYER:AddPoints(key, amount)
    if not amount then
        amount = pointAmounts[key] or 5
    end

    self.PointsToEarn = self.PointsToEarn or {}
    self.PointsToEarn[key] = self.PointsToEarn[key] or {}

    table.insert(self.PointsToEarn[key], amount)

    if SERVER then
        SlashCo.SendValue(self, "addPoints", key, amount)
    end
end

---set a point type the player will earn at game end
function PLAYER:SetPoints(key, amount, num)
    if not self.PointsToEarn then
        return
    end

    if not amount then
        amount = pointAmounts[key] or 5
    end

    self.PointsToEarn = self.PointsToEarn or {}
    self.PointsToEarn[key] = {}

    num = num or 1

    for i = 1, num do
        table.insert(self.PointsToEarn[key], amount)
    end

    if SERVER then
        SlashCo.SendValue(self, "setPoints", key, amount, num)
    end
end

---remove an entire set of points to earn from a player
function PLAYER:RemovePointsKey(key)
    if not self.PointsToEarn then
        return
    end

    self.PointsToEarn[key] = nil

    if SERVER then
        SlashCo.SendValue(self, "removePointsKey", key)
    end
end

---get the keys of a player's points table
function PLAYER:GetPointsKeys()
    if not self.PointsToEarn then
        return {}
    end

    return table.GetKeys(self.PointsToEarn)
end

---get the amount of points for a particular key
function PLAYER:GetPoints(key)
    if not self.PointsToEarn or not self.PointsToEarn[key] then
        return 0
    end

    local tot = 0
    for _, v in ipairs(self.PointsToEarn[key]) do
        tot = tot + v
    end

    return tot, #self.PointsToEarn[key]
end

---get the total points a player has
function PLAYER:GetTotalPoints()
    if not self.PointsToEarn then
        return 0
    end

    local tot = 0
    for _, v in pairs(self.PointsToEarn) do
        for _, v1 in ipairs(v) do
            tot = tot + v1
        end
    end

    return tot
end

if SERVER then
    return
end

hook.Add("scValue_addPoints", "AddPoints", function(key, amount)
    LocalPlayer():AddPoints(key, amount)
end)

hook.Add("scValue_removePointsKey", "RemovePointsKey", function(key)
    LocalPlayer():RemovePointsKey(key)
end)

hook.Add("scValue_setPoints", "SetPoints", function(key, amount, num)
    LocalPlayer():SetPoints(key, amount, num)
end)