AddCSLuaFile("cl_documents.lua")
include("sh_documents.lua")

--[[
	How documents are stored:
		key - name
		value - document table

	document table(json):
		number - rating - The rating ranges from 0 to 3, only used by slasher documents

		it's a table to allow for more stuff in the future

	document rating:
		0 = you never survived the slasher
		1 = you survived the slasher
		2 = you survived the slasher and quickly escaped
		3 = you survived the slasher and quickly escaped and were never seen by the slasher

	document networking:
		1 bit - deletion - if 1 then were deleting documents
		
		loop:
		x bits - document name
		2 bits - document rating
]]

local PLAYER = FindMetaTable("Player")

util.AddNetworkString("slashCo_NetworkDocuments")
function PLAYER:NetworkDocuments()
	local documents = self.Documents or {}
	net.Start("slashCo_NetworkDocuments")
		net.WriteBool(false)
		for name, documentTbl in pairs(documents) do
			net.WriteString(name)
			net.WriteUInt(documentTbl.rating, 2)
		end
	net.Send(self)
end

-- Re-networks the document to the player even when it was deleted
function PLAYER:NetworkDocument(name)
	local documentTbl = (self.Documents or {})[name]
	net.Start("slashCo_NetworkDocuments")
		net.WriteBool(not documentTbl)
		net.WriteString(name)
		if documentTbl then
			net.WriteUInt(documentTbl.rating, 2)
		end
	net.Send(self)
end

function PLAYER:LoadDocuments()
	local sqlDocuments = sql.Query("SELECT * FROM slashco_documents WHERE PlayerID ='" .. self:SteamID64() .. "';") or {}
	local documents = {}
	self.Documents = documents

	local duplicates = {} -- if for some magical reason a document got inserted multiple times
	for k, documentTbl in ipairs(sqlDocuments) do
		if documents[documentTbl.Document] then -- duplicate document!!!
			duplicates[documentTbl.Document] = duplicates[documentTbl.Document] or {documents[documentTbl.Document]}
			table.insert(duplicates[documentTbl.Document], {
				rating = tonumber(documentTbl.Rating)
			})
			continue
		end

		documents[documentTbl.Document] = {
			rating = tonumber(documentTbl.Rating)
		}
	end

	for name, duplicateDocuments in pairs(duplicates) do
		local highestRating = 0
		for _, documentTbl in ipairs(duplicateDocuments) do
			if documentTbl.rating > highestRating then
				highestRating = documentTbl.rating
			end
		end

		self:RevokeDocument(name) -- Removes all instances of the document
		self:GiveDocument(name, highestRating)
	end

	self:NetworkDocuments()
end

-- Can also be called to update the rating of a document
function PLAYER:GiveDocument(name, rating)
	local documents = (self.Documents or {})
	if not documents[name] then
		sql.Query("INSERT INTO slashco_documents(PlayerID, Document, Rating) VALUES('" .. self:SteamID64() .. "', '".. name .. "', " .. rating .. ");")
		documents[name] = {
			rating = rating
		}
	else
		if documents[name].rating < rating then -- We only allow a increase in the rating
			sql.Query("UPDATE slashco_documents SET Rating = " .. rating .. " WHERE PlayerID = '" .. self:SteamID64() .. "';")
			documents[name].rating = rating
		end
	end

	self:NetworkDocument(name)
end

-- You've lost your document privileges >:3
function PLAYER:RevokeDocument(name)
	sql.Query("DELETE FROM slashco_documents WHERE PlayerID = '" .. self:SteamID64() .. "' AND Document = '" .. name .. "';")
	self.Documents = self.Documents or {}
	self.Documents[name] = nil

	self:NetworkDocument(name)
end

hook.Add("PlayerInitialSpawn", "SlashCo:LoadDocuments", function(ply)
	ply:LoadDocuments()
end)

function SlashCo.CreateDocumentsDB()
	if sql.TableExists("slashco_documents") then return end --Create the database table for basic statistics
	for _, ply in ipairs( player.GetAll() ) do
		ply:ChatPrint("[SlashCo] The Documents Database does not exist. Creating it now.")
	end

	sql.Query("CREATE TABLE slashco_documents(PlayerID TEXT, Document TEXT, Rating NUMBER);")
end
SlashCo.CreateDocumentsDB()

hook.Add("SlashCo:EndRound", "SlashCo:HandoutDocuments", function(winners)
	local slashers = {}
	for _, ply in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		slashers[ply:GetNWString("Slasher")] = true
	end

	for _, ply in ipairs(player.GetAll()) do
		if not ply.WasSurvivor then continue end

		local rating = 3
		if ply:WasSeenBySlasher() then
			rating = rating - 1
		end

		if not ply:GetNW2Bool("QuickEscape") then
			rating = rating - 1
		end

		if not winners[ply:SteamID64()] then
			rating = 0 -- Didn't survive
		end

		for name, _ in pairs(slashers) do
			if not SlashCo.GetDocumentTable(name) then continue end -- No document with the Slasher's name exists...

			ply:GiveDocument(name, rating)
		end
	end
end)