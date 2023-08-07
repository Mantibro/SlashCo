AddCSLuaFile()

local PLAYER = FindMetaTable("Player")

if SERVER then
	---print a translated message to a player's chat
	---follows the rules of chat.AddText()
	---for a translated string that need formatting, use a table:
	---{<translation key>, <insert>...}
	function PLAYER:ChatText(...)
		SlashCo.SendValue(self, "ChatText", ...)
	end

	return
end

---print a translated message to a player's chat
---follows the rules of chat.AddText()
---for a translated string that need formatting, use a table:
---{<translation key>, <insert>...}
function SlashCo.ChatText(...)
	local toPrint = {}
	for _, v in ipairs({...}) do
		if type(v) == "string" then
			table.insert(toPrint, SlashCo.Language(v))
		elseif type(v) == "table" and not IsColor(v) then
			table.insert(toPrint, SlashCo.Language(v[1], select(2, unpack(v))))
		else
			table.insert(toPrint, v)
		end
	end
	chat.AddText(unpack(toPrint))
end
hook.Add("scValue_ChatText", "SlashCoChatText", SlashCo.ChatText)