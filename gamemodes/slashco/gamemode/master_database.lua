local SlashCo = SlashCo

--The Master Player Database

--[[

	Serverside SQL database which holds player stats and achievements.

]]

SlashCoDatabase = {}

SlashCoDatabase.EstablishDatabase = function(id)

	if !sql.TableExists( "slashco_master_database" ) then --Create the database table for basic statistics

		for i, ply in ipairs( player.GetAll() ) do
			ply:ChatPrint("[SlashCo] The Master Database does not exist. Creating it now.")
		end

		sql.Query("CREATE TABLE slashco_master_database(PlayerID TEXT, PlayerName TEXT, SurvivorRoundsWon NUMBER, SlasherRoundsWon NUMBER, Points NUMBER);" )
	
	end

end

if !sql.TableExists( "slashco_master_database" ) then
	SlashCoDatabase.EstablishDatabase()
end

SlashCoDatabase.OnPlayerJoined = function(id)

	if SERVER then

		local database = sql.Query("SELECT * FROM slashco_master_database; ")

		if database == nil then

			sql.Query("INSERT INTO slashco_master_database VALUES ( "..id..", "..player.GetBySteamID64(id):GetName()..", 0, 0, 0 ); ")
			print("[SlashCo] Master Database has no entries. This Player will be the first entry.")

		end

	end

end