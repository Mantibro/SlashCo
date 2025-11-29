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
	quickescape = 10, --
	slowescape = -10, --
	benadryl = 15, --
	working = 5 --
}

GameData.RoundPoints = GameData.RoundPoints or {}

---adds points the player will earn at game end
function PLAYER:AddRoundPoints(key, amount)
	if not amount then
		amount = pointAmounts[key] or 5
	end

	local steamID64 = self:SteamID64()
	GameData.RoundPoints[steamID64] = GameData.RoundPoints[steamID64] or {}
	GameData.RoundPoints[steamID64][key] = GameData.RoundPoints[steamID64][key] or {}

	table.insert(GameData.RoundPoints[steamID64][key], amount)

	if SERVER then
		SlashCo.SendValue(self, "addRoundPoints", key, amount)
	end
end

---set a point type the player will earn at game end
function PLAYER:SetRoundPoints(key, amount, num)
	local steamID64 = self:SteamID64()
	if not GameData.RoundPoints[steamID64] then
		return
	end

	if not amount then
		amount = pointAmounts[key] or 5
	end

	GameData.RoundPoints[steamID64] = GameData.RoundPoints[steamID64] or {}
	GameData.RoundPoints[steamID64][key] = {}

	num = num or 1

	for i = 1, num do
		table.insert(GameData.RoundPoints[steamID64][key], amount)
	end

	if SERVER then
		SlashCo.SendValue(self, "setRoundPoints", key, amount, num)
	end
end

---remove an entire set of points to earn from a player
function PLAYER:RemoveRoundPointsKey(key)
	local steamID64 = self:SteamID64()
	if not GameData.RoundPoints[steamID64] then
		return
	end

	GameData.RoundPoints[steamID64][key] = nil

	if SERVER then
		SlashCo.SendValue(self, "removeRoundPointsKey", key)
	end
end

---get the keys of a player's points table
function PLAYER:GetRoundPointsKeys()
	local steamID64 = self:SteamID64()
	if not GameData.RoundPoints[steamID64] then
		return {}
	end

	return table.GetKeys(GameData.RoundPoints[steamID64])
end

---get the amount of points for a particular key
function PLAYER:GetRoundPoints(key)
	local steamID64 = self:SteamID64()
	if not GameData.RoundPoints[steamID64] or not GameData.RoundPoints[steamID64][key] then
		return 0
	end

	local tot = 0
	for _, v in ipairs(GameData.RoundPoints[steamID64][key]) do
		tot = tot + v
	end

	return tot, #GameData.RoundPoints[steamID64][key]
end

local function getTotal(id)
	if not GameData.RoundPoints[id] then
		return 0
	end

	local tot = 0
	for _, v in pairs(GameData.RoundPoints[id]) do
		for _, v1 in ipairs(v) do
			tot = tot + v1
		end
	end

	return tot
end

---get the total points a player has
function PLAYER:GetTotalRoundPoints()
	return getTotal(self:SteamID64())
end

if SERVER then
	---set the total points for the round into the database
	function SlashCo.CommitRoundPoints()
		for k, _ in pairs(GameData.RoundPoints) do
			local total = getTotal(k)
			GameData.RoundPoints[k] = nil
			if total == 0 then
				return
			end

			SlashCoDatabase.UpdateStats(k, "Points", total)
			SlashCoDatabase.UpdateStats(k, "Experience", math.floor(total / 2))
		end
	end

	hook.Add("PlayerDeath", "CountKills", function(victim, _, attacker)
		if not IsValid(attacker) then return end

		if victim:Team() ~= TEAM_SLASHER and attacker.Team and attacker:Team() == TEAM_SLASHER then
			attacker:AddRoundPoints("slasher_kill")
		end
	end)
end

hook.Add("scValue_addRoundPoints", "AddRoundPoints", function(key, amount)
	GameData.LocalPlayer:AddRoundPoints(key, amount)
end)

hook.Add("scValue_removeRoundPointsKey", "RemoveRoundPointsKey", function(key)
	GameData.LocalPlayer:RemoveRoundPointsKey(key)
end)

hook.Add("scValue_setRoundPoints", "SetRoundPoints", function(key, amount, num)
	GameData.LocalPlayer:SetRoundPoints(key, amount, num)
end)