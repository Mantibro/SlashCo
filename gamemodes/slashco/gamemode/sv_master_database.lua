--local SlashCo = SlashCo

--The Master Player Database

--[[

	Serverside SQL database which holds player stats and achievements.

]]

SlashCoDatabase = {}

SlashCoDatabase.EstablishDatabase = function(_)
	if not sql.TableExists( "slashco_master_database" ) then --Create the database table for basic statistics
		for _, ply in ipairs( player.GetAll() ) do
			ply:ChatPrint("[SlashCo] The Master Database does not exist. Creating it now.")
		end

		sql.Query("CREATE TABLE slashco_master_database(PlayerID TEXT, PlayerName TEXT, SurvivorRoundsWon NUMBER, SlasherRoundsWon NUMBER, Points NUMBER);" )
	end
end

if not sql.TableExists( "slashco_master_database" ) then
	SlashCoDatabase.EstablishDatabase()
end

SlashCoDatabase.OnPlayerJoined = function(id)
	if SERVER then
		local database = sql.Query("SELECT * FROM slashco_master_database; ")

		if database == nil or database == false then
			sql.Query("INSERT INTO slashco_master_database(PlayerID, PlayerName, SurvivorRoundsWon, SlasherRoundsWon, Points) VALUES( '" .. id .. "', '" .. player.GetBySteamID64(id):GetName() .. "', 0, 0, 0 ); ")

			print("[SlashCo] Master Database has no entries. This Player will be the first entry.")

			return
		end

		local is_in = false
		local index = 0

		for i = 1, #database do
			if database[i].PlayerID == id then
				is_in = true
				index = i
				break
			end
		end

		if is_in == false then
			sql.Query("INSERT INTO slashco_master_database(PlayerID, PlayerName, SurvivorRoundsWon, SlasherRoundsWon, Points) VALUES( '" .. id .. "', '" .. player.GetBySteamID64(id):GetName() .. "', 0, 0, 0 ); ")

			print("[SlashCo] This Player is not in the Database, and has been inserted.")
		elseif is_in == true then
			--Check if the player has changed their name
			if database[index].PlayerName ~= player.GetBySteamID64(id):GetName() then
				sql.Query("UPDATE slashco_master_database SET PlayerName = " .. player.GetBySteamID64(id):GetName() .. " WHERE PlayerID = '" .. id .. "';")
			end
		end
	end
end

SlashCoDatabase.UpdateStats = function(id, s_type, increase)
	if s_type ~= "SurvivorRoundsWon" and s_type ~= "SlasherRoundsWon" and s_type ~= "Points" then
		ErrorNoHalt("[SlashCo] Database Error. Invalid Type: " .. s_type)
		return
	end

	local database = sql.Query("SELECT " .. s_type .. " FROM slashco_master_database WHERE PlayerID ='" .. id .. "'; ")
	local name = sql.Query("SELECT PlayerName FROM slashco_master_database WHERE PlayerID ='" .. id .. "'; ")[1].PlayerName

	local current_stat

	if s_type == "SurvivorRoundsWon" then
		current_stat = database[1].SurvivorRoundsWon
	elseif s_type == "SlasherRoundsWon" then
		current_stat = database[1].SlasherRoundsWon
	elseif s_type == "Points" then
		current_stat = database[1].Points
	end

	if current_stat == nil then
		ErrorNoHalt("[SlashCo] Database Error. Bad read.")
		return
	end

	sql.Query("UPDATE slashco_master_database SET " .. s_type .. " = " .. current_stat + increase .. " WHERE PlayerID = '" .. id .. "';")

	print("[SlashCo] (Database) " .. name .. "'s stats updated!")
end

SlashCoDatabase.ClearDatabase = function()
	sql.Query("DROP TABLE slashco_master_database;")

	print("[SlashCo] Master Database Cleared.")
end

SlashCoDatabase.GetStat = function(id, s_type)
	if s_type ~= "SurvivorRoundsWon" and s_type ~= "SlasherRoundsWon" and s_type ~= "Points" then
		ErrorNoHalt("[SlashCo] Database Error. Invalid Type: " .. s_type)
		return 0
	end

	local database = sql.Query("SELECT " .. s_type .. " FROM slashco_master_database WHERE PlayerID ='" .. id .. "'; ")

	if s_type == "SurvivorRoundsWon" then
		return database[1].SurvivorRoundsWon
	elseif s_type == "SlasherRoundsWon" then
		return database[1].SlasherRoundsWon
	elseif s_type == "Points" then
		return database[1].Points
	end
end