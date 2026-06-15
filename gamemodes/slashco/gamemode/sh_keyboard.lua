-- RaphaelIT7: This is translation for all BUTTON_CODE enums (https://wiki.facepunch.com/gmod/Enums/BUTTON_CODE) - NOT IN enums!
SlashCo.KeyboardBinds = {
	USE_ITEM = {
		name = "keyboard_bind_use_item", -- These can be language keys
		button = KEY_R,
	},
	DROP_ITEM = {
		name = "keyboard_bind_drop_item",
		button = KEY_Q,
	},
	PING = {
		name = "keyboard_bind_ping",
		button = MOUSE_MIDDLE,
	},
	TAUNT_MN = {
		name = "keyboard_bind_taunt",
		name2 = "Monday Night",
		button = KEY_1,
	},
	TAUNT_HTG = {
		name = "keyboard_bind_taunt",
		name2 = "Hittin the griddy",
		button = KEY_2,
	},
	TAUNT_CG = {
		name = "keyboard_bind_taunt",
		name2 = "California girls",
		button = KEY_3,
	},
	PLAYERMODEL = {
		name = "SelectPlayermodel",
		button = KEY_G,
	},
	READY_SURVIVOR = {
		name = "ReadyAs",
		name2 = "Survivor", -- I don't like this, but they use two language keys...
		button = KEY_F1,
	},
	READY_SLASHER = {
		name = "ReadyAs",
		name2 = "Slasher",
		button = KEY_F2,
	},
	OFFERING_VOTE = {
		name = "keyboard_bind_offering_vote",
		button = KEY_F4,
	},
	TOGGLE_SPECTATOR = {
		name = "ToggleSpectate",
		button = KEY_R,
	},
	SPECTATE_PLAYER = {
		name = "switch_view",
		button = KEY_SPACE,
	},
	MAIN_ABILITY = {
		name = "keyboard_bind_main_ability",
		button = KEY_R,
	},
	SPECIAL_ABILITY = {
		name = "keyboard_bind_special_ability",
		button = KEY_F,
	},
	GAME_INFO = {
		name = "GameInfo",
		button = KEY_F6,
	},
	VOICE_SELECT = {
		name = "keyboard_bind_voices",
		button = KEY_G,
	},
	OPEN_KEYBINDS = {
		name = "keyboard_bind_keybinds",
		button = KEY_F8,
	}
}

if CLIENT then
	function SlashCo.LoadKeyboardBinds()
		if not GameData.KeyboardBinds then
			GameData.KeyboardBinds = SlashCo.ParseKeyboardBinds(cookie.GetString("SlashCo:KeyboardBinds", ""))
		end

		local stringData = SlashCo.KeyboardBindsToString(GameData.KeyboardBinds)
		net.Start("SlashCo:KeyboardBinds")
			net.WriteString(stringData)
		net.SendToServer()
	end

	function SlashCo.SaveKeyboardBinds()
		cookie.Set("SlashCo:KeyboardBinds", SlashCo.KeyboardBindsToString(GameData.KeyboardBinds))
		SlashCo.LoadKeyboardBinds() -- Acts as verification too
	end

	function SlashCo.TranslateBind(name)
		return GameData.KeyboardBinds[name].name
	end

	function SlashCo.GetKeyButton(name)
		if not GameData.KeyboardBinds or not GameData.KeyboardBinds[name] then
			return SlashCo.KeyboardBinds[name] and SlashCo.KeyboardBinds[name].button or -1
		end

		return GameData.KeyboardBinds[name]
	end

	function SlashCo.GetKeyButtonName(name)
		return string.upper(input.GetKeyName(SlashCo.GetKeyButton(name, ply)) or "UNKNOWN")
	end

	function SlashCo.IsKeyPressed(name, ply, button)
		return button == SlashCo.GetKeyButton(name, ply)
	end

	local blockBinds = CreateClientConVar("slashco_blockbinds", "1", true, false, "If enabled, GMod key binds that overlap with SlashCo's binds will be blocked from executing")
	hook.Add("PlayerBindPress", "SlashCo:KeyboardBinds", function(_, bind, _, code)
		-- We respect blocked concommands and won't block them!
		-- We also won't block any inputs like +attack or +jump!
		if not IsConCommandBlocked(bind) and not bind:StartsWith("+") and not bind:StartsWith("impulse") and GameData.KeyboardBinds and GameData.KeyboardBinds[code] and blockBinds:GetBool() then
			return true
		end
	end)
end

function SlashCo.ParseKeyboardBinds(stringData)
	if not stringData then
		return nil
	end

	local binds = {}
	for _, keyData in ipairs(string.Split(stringData, ";")) do
		local info = string.Split(keyData, "|")
		if #info ~= 2 then continue end

		binds[info[1]] = tonumber(info[2]) -- 1 = Name, 2 = Button Number
		binds[tonumber(info[2])] = true
	end

	for name, info in pairs(SlashCo.KeyboardBinds) do
		if binds[name] then continue end

		binds[name] = tonumber(info.button) -- Add any missing buttons
		binds[tonumber(info.button)] = true
	end

	return binds
end

function SlashCo.KeyboardBindsToString(binds)
	binds = binds or {}
	local data = ""
	for name, info in pairs(SlashCo.KeyboardBinds) do
		if isbool(info) then continue end

		local keyData = name .. "|" .. tostring(binds[name] or info.button)
		if data == "" then
			data = keyData
		else
			data = data .. ";" .. keyData
		end
	end

	return data
end

if CLIENT then return end
util.AddNetworkString("SlashCo:KeyboardBinds")

net.Receive("SlashCo:KeyboardBinds", function(len, ply)
	local stringData = net.ReadString()
	local binds = SlashCo.ParseKeyboardBinds(stringData)

	ply.KEYBOARD_BINDS = binds
end)

function SlashCo.IsKeyPressed(name, ply, button)
	local binds = ply.KEYBOARD_BINDS
	if not binds or not binds[name] then -- Falls back to default if the player didn't network their binds yet
		return button == SlashCo.KeyboardBinds[name].button
	end

	return button == binds[name]
end