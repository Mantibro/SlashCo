AddCSLuaFile()

SlashCoDocuments = SlashCoDocuments or {} -- a table containing all existing documents.
SlashCoDocumentTypes = SlashCoDocumentTypes or {} -- a table containing all documents split into the different types

function SlashCo.RegisterDocument(table)
	if SC_LOADEDDOCUMENTS then
		error("Tried to register a document illegally", 2)
		return
	end

	if not table.Slasher and table.Type == "Slasher" then
		table.Slasher = table.Name
	end

	SlashCoDocuments[table.Name] = table

	if not SlashCoDocumentTypes[table.Type] then
		SlashCoDocumentTypes[table.Type] = {}
	end

	SlashCoDocumentTypes[table.Type][table.Name] = table
end

function SlashCo.GetDocumentTable(name)
	return SlashCoDocuments[name]
end

function SlashCo.LoadDocuments()
	SC_LOADEDDOCUMENTS = nil
	for _, v in ipairs(file.Find("slashco/documents/*.lua", "LUA")) do
		AddCSLuaFile("slashco/documents/" .. v)
		include("slashco/documents/" .. v)
	end
	SC_LOADEDDOCUMENTS = true
end
hook.Add("SlashCo:GameContentChanged", "SlashCo:RefreshDocuments", SlashCo.LoadDocuments)
SlashCo.LoadDocuments()