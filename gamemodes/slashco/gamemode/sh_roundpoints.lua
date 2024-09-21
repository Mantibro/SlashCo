local PLAYER = FindMetaTable("Player")

local pointAmounts = {
    slasher_kill = 5, --
    slasher_demon = 10, -- not implemented
    slasher_win = 20, --
    slasher_escape = 10, --
    slasher_perfect = 15, --
    objective = 20, --
    optional = 10, -- not implemented
    escape = 10, --
    all_survive = 10, --
    last_survive = 3, --
    left_behind = 5, --
    survive = 15, --
    item = 10, -- not implemented
    fast = 5, -- not implemented
    benadryl = 15, --
    working = 5 --
}

local plyPoints = {}

---adds points the player will earn at game end
function PLAYER:AddPoints(key, amount)
    if not amount then
        amount = pointAmounts[key] or 5
    end

    plyPoints[self:SteamID64()] = plyPoints[self:SteamID64()] or {}
    plyPoints[self:SteamID64()][key] = plyPoints[self:SteamID64()][key] or {}

    table.insert(plyPoints[self:SteamID64()][key], amount)

    if SERVER then
        SlashCo.SendValue(self, "addPoints", key, amount)
    end
end

---set a point type the player will earn at game end
function PLAYER:SetPoints(key, amount, num)
    if not plyPoints[self:SteamID64()] then
        return
    end

    if not amount then
        amount = pointAmounts[key] or 5
    end

    plyPoints[self:SteamID64()] = plyPoints[self:SteamID64()] or {}
    plyPoints[self:SteamID64()][key] = {}

    num = num or 1

    for i = 1, num do
        table.insert(plyPoints[self:SteamID64()][key], amount)
    end

    if SERVER then
        SlashCo.SendValue(self, "setPoints", key, amount, num)
    end
end

---remove an entire set of points to earn from a player
function PLAYER:RemovePointsKey(key)
    if not plyPoints[self:SteamID64()] then
        return
    end

    plyPoints[self:SteamID64()][key] = nil

    if SERVER then
        SlashCo.SendValue(self, "removePointsKey", key)
    end
end

---get the keys of a player's points table
function PLAYER:GetPointsKeys()
    if not plyPoints[self:SteamID64()] then
        return {}
    end

    return table.GetKeys(plyPoints[self:SteamID64()])
end

---get the amount of points for a particular key
function PLAYER:GetPoints(key)
    if not plyPoints[self:SteamID64()] or not plyPoints[self:SteamID64()][key] then
        return 0
    end

    local tot = 0
    for _, v in ipairs(plyPoints[self:SteamID64()][key]) do
        tot = tot + v
    end

    return tot, #plyPoints[self:SteamID64()][key]
end

local function getTotal(id)
    if not plyPoints[id] then
        return 0
    end

    local tot = 0
    for _, v in pairs(plyPoints[id]) do
        for _, v1 in ipairs(v) do
            tot = tot + v1
        end
    end

    return tot
end

---get the total points a player has
function PLAYER:GetTotalPoints()
    return getTotal(self:SteamID64())
end

if SERVER then
    ---set the total points for the round into the database
    function SlashCo.CommitPoints()
        for k, _ in pairs(plyPoints) do
            local total = getTotal(k)
            plyPoints[k] = nil
            if total == 0 then
                return
            end

            SlashCoDatabase.UpdateStats(k, "Points", SlashCo.PlayerData[k].PointsTotal + total)
        end
    end

    hook.Add("PlayerDeath", "CountKills", function(_, _, attacker)
        if not IsValid(attacker) then return end

        if attacker.Team and attacker:Team() == TEAM_SLASHER then
            attacker:AddPoints("slasher_kill")
        end
    end)
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