--[[
	The Master Player Database
	Serverside SQL database which holds player stats and achievements.
]]

SlashCoDatabase = SlashCoDatabase or {}

function SlashCoDatabase.EstablishDatabase()
	if sql.TableExists("slashco_master_database") then
		local columnResults = sql.Query("PRAGMA table_info(slashco_master_database);")
		local columns = {}
		for _, resultData in ipairs(columnResults or {}) do
			columns[resultData.name] = true
		end

		if not columns["Experience"] then
			print("Adding missing database column Experience")
			sql.Query("ALTER TABLE slashco_master_database ADD COLUMN Experience NUMBER;")
		end

		if not columns["ActivePerks"] then
			print("Adding missing database column ActivePerks")
			sql.Query("ALTER TABLE slashco_master_database ADD COLUMN ActivePerks TEXT;")
			sql.Query("ALTER TABLE slashco_master_database ADD COLUMN OwnedPerks TEXT;")
		end

		return
	end --Create the database table for basic statistics

	for _, ply in ipairs( player.GetAll() ) do
		ply:ChatPrint("[SlashCo] The Master Database does not exist. Creating it now.")
	end

	sql.Query("CREATE TABLE slashco_master_database(PlayerID TEXT, PlayerName TEXT, SurvivorRoundsWon NUMBER, SlasherRoundsWon NUMBER, Points NUMBER, Experience NUMBER, ActivePerks TEXT, OwnedPerks TEXT);")
end
SlashCoDatabase.EstablishDatabase()

local validStats = { -- RaphaelIT7: This provides better readability than 4 ~= xxx checks
	["SurvivorRoundsWon"] = "number",
	["SlasherRoundsWon"] = "number",
	["Points"] = "number",
	["Experience"] = "number",
	["ActivePerks"] = "string", -- UpdateStats will instead SET the increase instead of adding like it does with numbers
	["OwnedPerks"] = "string", -- UpdateStats will instead SET the increase instead of adding like it does with numbers
}

local plyMeta = FindMetaTable("Player")
function SlashCoDatabase.UpdateStats(steamid, statType, increase)
	if not validStats[statType] then
		ErrorNoHaltWithStack("[SlashCo] Database Error. Invalid Type: " .. statType)
		return
	end

	local database = sql.Query("SELECT " .. statType .. " FROM slashco_master_database WHERE PlayerID = " .. sql.SQLStr(steamid) .. ";")
	local name = sql.Query("SELECT PlayerName FROM slashco_master_database WHERE PlayerID = " .. sql.SQLStr(steamid) .. ";")[1].PlayerName
	local current_stat = database[1][statType]

	if not current_stat then
		ErrorNoHaltWithStack("[SlashCo] Database Error. Bad read. (" .. statType .. ")")
		return
	end

	if validStats[statType] == "string" then
		increase = sql.SQLStr(increase)
	end

	local newAmount = validStats[statType] == "number" and (tonumber(current_stat) + increase) or increase
	sql.Query("UPDATE slashco_master_database SET " .. statType .. " = " .. newAmount .. " WHERE PlayerID = " .. sql.SQLStr(steamid) .. ";")

	local ply = player.GetBySteamID64(steamid)
	if IsValid(ply) then
		-- RaphaelIT7: Variables were setup using SetupSlashCoNetworkVar
		plyMeta["Set" .. statType](ply, newAmount)
	end

	print("[SlashCo] (Database) " .. name .. "'s stats for " .. statType .. " updated!")
end

function SlashCoDatabase.ClearDatabase()
	sql.Query("DROP TABLE slashco_master_database;")

	print("[SlashCo] Master Database Cleared.")
end

function SlashCoDatabase.GetStat(steamid, statType)
	if not validStats[statType] then
		ErrorNoHaltWithStack("[SlashCo] Database Error. Invalid Type: " .. statType)
		return 0
	end

	local database = sql.Query("SELECT " .. statType .. " FROM slashco_master_database WHERE PlayerID = " .. sql.SQLStr(steamid) .. ";")
	return database[1][statType] or 0
end

function SlashCoDatabase.OnPlayerJoined(steamid)
	local database = sql.Query("SELECT * FROM slashco_master_database;")

	local ply = player.GetBySteamID64(steamid)
	if not ply then return end -- The SteamID is not valid...

	if not database then
		sql.Query("INSERT INTO slashco_master_database(PlayerID, PlayerName, SurvivorRoundsWon, SlasherRoundsWon, Points, Experience) VALUES(" .. sql.SQLStr(steamid) .. ", " .. sql.SQLStr(ply:GetName()) .. ", 0, 0, 0, 0);")

		print("[SlashCo] Master Database has no entries. This Player will be the first entry.")
		return
	end

	local hasEntry = false
	local entryIndex = 0
	for index, entry in ipairs(database) do
		if entry.PlayerID == steamid then
			hasEntry = true
			entryIndex = index
			break
		end
	end

	if not hasEntry then
		sql.Query("INSERT INTO slashco_master_database(PlayerID, PlayerName, SurvivorRoundsWon, SlasherRoundsWon, Points, Experience) VALUES(" .. sql.SQLStr(steamid) .. ", " .. sql.SQLStr(ply:GetName()) .. ", 0, 0, 0, 0);")

		print("[SlashCo] This Player is not in the Database, and has been inserted.")
	elseif hasEntry then
		--Check if the player has changed their name
		if database[entryIndex].PlayerName ~= ply:GetName() then
			sql.Query("UPDATE slashco_master_database SET PlayerName = " .. ply:GetName() .. " WHERE PlayerID = '" .. steamid .. "';")
		end
	end
end