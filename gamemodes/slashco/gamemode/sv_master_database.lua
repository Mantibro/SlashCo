--[[
	The Master Player Database
	Serverside SQL database which holds player stats and achievements.

	slashco_master_database (Current Version)
		number PlayerID - SteamID64 (PRIMARY KEY)
		number PlayerName - Last known used name (Only used for nice logging?)
		number SurvivorRoundsWon - Total number of survivor rounds won 
		number SlasherRoundsWon - Total number of slasher rounds won
		number SlasherChance - Current Slasher chance
		number Points - Current points
		number Experience - Current experience
		string OwnedPerks - Owned perks
		string UnlockedContent - Content/Things that can be unlocked while playing

	slashco_master_database_migration_v1 (Old Version)
		number PlayerID - SteamID64
		number PlayerName - Last known used name (Only used for nice logging?)
		number SurvivorRoundsWon - Total number of survivor rounds won 
		number SlasherRoundsWon - Total number of slasher rounds won
		number Points - Current points
		number Experience - Current experience
		string ActivePerks - Active perks (REMOVED - This was removed in migrated versions)
		string OwnedPerks - Owned perks
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
			sql.Query("ALTER TABLE slashco_master_database ADD COLUMN Experience NUMBER DEFAULT 0;")
		end

		if not columns["OwnedPerks"] then
			print("Adding missing database column OwnedPerks")
			sql.Query("ALTER TABLE slashco_master_database ADD COLUMN OwnedPerks TEXT DEFAULT '';")
		end

		if columns["ActivePerks"] then
			print("Migrating ActivePerks into OwnedPerks")

			sql.m_strError = nil -- Clear any old errors

			-- GMod's uses SQLite 3.26.0 BUT DROP COLUMN was added with 3.35.0
			sql.Query("DROP TABLE IF EXISTS slashco_master_database_new;")
			sql.Query([[
				CREATE TABLE slashco_master_database_new(
					PlayerID TEXT PRIMARY KEY,
					PlayerName TEXT,
					SurvivorRoundsWon NUMBER DEFAULT 0,
					SlasherRoundsWon NUMBER DEFAULT 0,
					SlasherChance NUMBER DEFAULT 0,
					Points NUMBER DEFAULT 0,
					Experience NUMBER DEFAULT 0,
					OwnedPerks TEXT DEFAULT '',
					UnlockedContent TEXT DEFAULT ''
				);
			]])

			if sql.LastError() then
				print("[DEBUG] 0 - ActivePerks migration failed! (" .. sql.LastError() .. ")")
			end

			sql.Query([[
				INSERT INTO slashco_master_database_new
				SELECT
					PlayerID,
					MAX(PlayerName),
					SUM(COALESCE(SurvivorRoundsWon, 0)),
					SUM(COALESCE(SlasherRoundsWon, 0)),
					0,
					SUM(COALESCE(Points, 0)),
					SUM(COALESCE(Experience, 0)),
					(
						SELECT t2.OwnedPerks
						FROM slashco_master_database t2
						WHERE t2.PlayerID = t1.PlayerID
						ORDER BY LENGTH(COALESCE(t2.OwnedPerks, '')) DESC
						LIMIT 1
					),
					''
				FROM slashco_master_database t1
				GROUP BY PlayerID;
			]])

			if sql.LastError() then
				print("[DEBUG] 1 - ActivePerks migration failed! (" .. sql.LastError() .. ")")
			end

			local rows = sql.Query("SELECT PlayerID, OwnedPerks, ActivePerks FROM slashco_master_database;")

			for _, row in ipairs(rows or {}) do
				local ownedPerks = {}
				local activePerks = {}

				for perk in string.gmatch(row.OwnedPerks or "", "[^,]+") do
					ownedPerks[perk] = true
				end

				for perk in string.gmatch(row.ActivePerks or "", "[^,]+") do
					activePerks[perk] = true
					ownedPerks[perk] = true
				end

				local mergedPerks = {}
				for perk in pairs(ownedPerks) do
					if activePerks[perk] then
						table.insert(mergedPerks, "!" .. perk)
					else
						table.insert(mergedPerks, perk)
					end
				end

				sql.Query(string.format("UPDATE slashco_master_database_new SET OwnedPerks=%s WHERE PlayerID=%s;", sql.SQLStr(table.concat(mergedPerks, ",")), sql.SQLStr(row.PlayerID)))
			end

			if sql.LastError() then
				print("ActivePerks migration failed! (" .. sql.LastError() .. ")")
				sql.Query("ALTER DROP TABLE slashco_master_database_new;")
			else
				-- RaphaelIT7: We DONT drop the old table! Just in case we somehow messed something up!
				sql.Query("ALTER TABLE slashco_master_database RENAME TO slashco_master_database_migration_v1;")
				sql.Query("ALTER TABLE slashco_master_database_new RENAME TO slashco_master_database;")

				print("ActivePerks migration complete")
			end
		end

		return
	end --Create the database table for basic statistics

	for _, ply in player.Iterator() do
		ply:ChatPrint("[SlashCo] The Master Database does not exist. Creating it now.")
	end

	sql.Query([[
		CREATE TABLE slashco_master_database(
			PlayerID TEXT PRIMARY KEY,
			PlayerName TEXT,
			SurvivorRoundsWon NUMBER DEFAULT 0,
			SlasherRoundsWon NUMBER DEFAULT 0,
			SlasherChance NUMBER DEFAULT 0,
			Points NUMBER DEFAULT 0,
			Experience NUMBER DEFAULT 0,
			OwnedPerks TEXT DEFAULT '',
			UnlockedContent TEXT DEFAULT ''
		);
	]])
end
SlashCoDatabase.EstablishDatabase()

local validStats = { -- RaphaelIT7: This provides better readability than 4 ~= xxx checks
	["SurvivorRoundsWon"] = "number",
	["SlasherRoundsWon"] = "number",
	["SlasherChance"] = "number",
	["Points"] = "number",
	["Experience"] = "number",
	["OwnedPerks"] = "string", -- UpdateStats will instead SET the increase instead of adding like it does with numbers
	["UnlockedContent"] = "string",
}

local plyMeta = FindMetaTable("Player")
function SlashCoDatabase.UpdateStats(steamid, statType, increase, forceSet)
	-- forceSet = if true then "increase" is instead set instead of being added!
	if not validStats[statType] then
		ErrorNoHaltWithStack("[SlashCo] Database Error. Invalid Type: " .. statType)
		return
	end

	local current_stat = SlashCoDatabase.GetStat(steamid, statType)
	local name = sql.Query("SELECT PlayerName FROM slashco_master_database WHERE PlayerID = " .. sql.SQLStr(steamid) .. ";")[1].PlayerName
	if not current_stat then
		ErrorNoHaltWithStack("[SlashCo] Database Error. Bad read. (" .. statType .. ")")
		return
	end

	if validStats[statType] == "string" then
		increase = sql.SQLStr(increase)
		current_stat = nil
	end

	-- We don't allow any amount to become negative!
	local newAmount = (validStats[statType] == "number" and not forceSet) and math.max((tonumber(current_stat) + increase), 0) or increase
	sql.Query("UPDATE slashco_master_database SET " .. statType .. " = " .. newAmount .. " WHERE PlayerID = " .. sql.SQLStr(steamid) .. ";")

	local ply = player.GetBySteamID64(steamid)
	if IsValid(ply) then
		if isstring(newAmount) then
			if newAmount:StartsWith("'") then
				newAmount = newAmount:sub(2)
			end

			if newAmount:EndsWith("'") then
				newAmount = newAmount:sub(1, -2)
			end
		end

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
	return (database[1][statType] and database[1][statType] ~= "NULL") and database[1][statType] or (validStats[statType] == "number" and 0 or "")
end

function SlashCoDatabase.OnPlayerJoined(steamid)
	local ply = player.GetBySteamID64(steamid)
	if not ply then return end -- The SteamID is not valid...

	-- PlayerID is a primary key with our migration to a new table so this should work nicely
	sql.Query("INSERT OR IGNORE INTO slashco_master_database(PlayerID, PlayerName, SurvivorRoundsWon, SlasherRoundsWon, Points, Experience, OwnedPerks) VALUES(" .. sql.SQLStr(steamid) .. ", " .. sql.SQLStr(ply:GetName()) .. ", 0, 0, 0, 0, '');")
	sql.Query("UPDATE slashco_master_database SET PlayerName = " .. sql.SQLStr(ply:GetName()) .. " WHERE PlayerID = " .. sql.SQLStr(steamid) .. ";")

	SlashCoDatabase.LoadPlayer(ply)
end

function SlashCoDatabase.LoadPlayer(ply)
	if not IsValid(ply) then return end

	local data = sql.Query("SELECT * FROM slashco_master_database WHERE PlayerID = " .. sql.SQLStr(ply:SteamID64()) .. ";")
	if not data or not data[1] then return end

	for statName, statType in pairs(validStats) do
		local setFunc = plyMeta["Set" .. statName]
		if not setFunc then
			ErrorNoHaltWithStack("The Stat \"" .. statName .. "\" has no Set function! It is required to have one!")
			continue
		end

		if statType == "string" then
			setFunc(ply, data[1][statName])
		else
			setFunc(ply, tonumber(data[1][statName]))
		end
	end
end