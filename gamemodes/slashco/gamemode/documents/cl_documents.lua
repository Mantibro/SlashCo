include("sh_documents.lua")

SlashCo.Documents = SlashCo.Documents or {} -- a table containing all collected documents of thelocal player
function SlashCo.HasDocument(name)
	return SlashCo.Documents[name] != nil
end

function SlashCo.GetDocumentRating(name)
	local document = SlashCo.Documents[name]
	if not document then return 0 end

	return document.rating or 0
end

net.Receive("slashCo_NetworkDocuments", function()
	local deletions = net.ReadBool()
	for k=1, 500 do -- would do while true but I don't like the idea of a possible infinite loop even if its impossible in this setup
		local name = net.ReadString()
		if not name or name == "" then break end

		if deletions then
			SlashCo.Documents[name] = nil
			continue
		end

		local rating = net.ReadUInt(2)
		SlashCo.Documents[name] = {
			rating = rating,
		}
	end
end)