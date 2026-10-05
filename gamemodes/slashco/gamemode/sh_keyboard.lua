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
	},
	-- Keys for the Map tools (WIP)
	MAPTOOL_SWITCH_SURVIVOR = {
		ui_priority = -999,
		name = "maptools_become_survivor",
		button = KEY_F1, -- BUG: GMod has it's debug menu bound to SHIFT + F1, no idea how we could supress that yet
		--button2 = KEY_LSHIFT,
	},
	MAPTOOL_SWITCH_SLASHER = {
		ui_priority = -999,
		name = "maptools_become_slasher",
		button = KEY_F2,
		--button2 = KEY_LSHIFT,
	},
	MAPTOOL_UNDO = {
		ui_priority = -999,
		name = "maptools_undo",
		button = KEY_Z,
		button2 = KEY_LCONTROL,
	},
	MAPTOOL_REDO = {
		ui_priority = -999,
		name = "maptools_redo",
		button = KEY_Y,
		button2 = KEY_LCONTROL,
	},
}

function SlashCo.GetDefaultKey(name)
	local bind = SlashCo.KeyboardBinds[name]
	if not bind then return nil end

	return bind.button
end

function SlashCo.ParseKeyboardBinds(stringData)
	if not stringData then
		return nil
	end

	local binds = {}
	for _, keyData in ipairs(string.Split(stringData, ";")) do
		local info = string.Split(keyData, "|")
		if #info ~= 2 then continue end

		local buttonData = info[2]
		if buttonData:StartsWith("#") then
			-- sub so that we skip the #
			local buttons = string.Split(buttonData:sub(2), ".")
			buttonData = {
				button = tonumber(buttons[1]),
				button2 = tonumber(buttons[2])
			}
		else
			buttonData = {
				button = tonumber(info[2])
			}
		end

		-- 1 = Name
		binds[info[1]] = buttonData
		binds[buttonData.button] = true
		if buttonData.button2 then
			binds[buttonData.button2] = true
		end
	end

	for name, info in pairs(SlashCo.KeyboardBinds) do
		if binds[name] then continue end

		binds[name] = {
			button = tonumber(info.button), -- Add any missing buttons
		}
		binds[tonumber(info.button)] = true

		if info.button2 then
			binds[name].button2 = tonumber(info.button2)
			binds[tonumber(info.button2)] = true
		end
	end

	return binds
end

function SlashCo.KeyboardBindsToString(binds)
	binds = binds or {}
	local data = ""
	for name, info in pairs(SlashCo.KeyboardBinds) do
		if isbool(info) then continue end

		local button = binds[name] and binds[name].button or info.button
		local button2 = binds[name] and binds[name].button2 or info.button2
		local buttonData = isnumber(info.button2) and ("#" .. tostring(button) .. "." .. tostring(button2)) or tostring(button)
		local keyData = name .. "|" .. buttonData
		if data == "" then
			data = keyData
		else
			data = data .. ";" .. keyData
		end
	end

	return data
end

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
		if cookie.GetString("SlashCo:KeyboardBinds_BACKUP_05_10_2026", nil) == nil then
			-- RaphaelIT7: Just to be sure so we can recover in the case I fked up as I really don't want people to lose their bindings
			cookie.Set("SlashCo:KeyboardBinds_BACKUP_05_10_2026", cookie.GetString("SlashCo:KeyboardBinds", ""))
		end

		cookie.Set("SlashCo:KeyboardBinds", SlashCo.KeyboardBindsToString(GameData.KeyboardBinds))
		SlashCo.LoadKeyboardBinds() -- Acts as verification too
	end

	function SlashCo.TranslateBind(name)
		if not name then return nil end

		return GameData.KeyboardBinds[name].name
	end

	function SlashCo.GetKeyButton(name)
		if not GameData.KeyboardBinds or not GameData.KeyboardBinds[name] then
			if not SlashCo.KeyboardBinds[name] then
				return -1
			end

			return SlashCo.KeyboardBinds[name].button or -1, SlashCo.KeyboardBinds[name].button2
		end

		return GameData.KeyboardBinds[name].button, GameData.KeyboardBinds[name].button2
	end

	function SlashCo.GetKeyButtonName(name)
		local button1, button2 = SlashCo.GetKeyButton(name, ply)
		local buttonName = string.upper(input.GetKeyName(button1) or "UNKNOWN")
		if button2 then
			buttonName = buttonName .. " + " .. string.upper(input.GetKeyName(button2) or "UNKNOWN")
		end

		return buttonName
	end

	function SlashCo.IsKeyPressed(name, ply, button)
		local button1, button2 = SlashCo.GetKeyButton(name, ply)
		if button1 == button then
			if not button2 then
				return true
			else
				return input.IsButtonDown(button2)
			end
		end

		if button2 == button then
			return input.IsButtonDown(button1)
		end

		return false
	end

	local blockBinds = CreateClientConVar("slashco_blockbinds", "1", true, false, "If enabled, GMod key binds that overlap with SlashCo's binds will be blocked from executing")
	hook.Add("PlayerBindPress", "SlashCo:KeyboardBinds", function(_, bind, _, code)
		-- We respect blocked concommands and won't block them!
		-- We also won't block any inputs like +attack or +jump!
		if not IsConCommandBlocked(bind) and not bind:StartsWith("+") and not bind:StartsWith("impulse") and GameData.KeyboardBinds and GameData.KeyboardBinds[code] and blockBinds:GetBool() then
			return true
		end
	end)

	return
end

util.AddNetworkString("SlashCo:KeyboardBinds")

net.Receive("SlashCo:KeyboardBinds", function(len, ply)
	local stringData = net.ReadString()
	local binds = SlashCo.ParseKeyboardBinds(stringData)

	ply.KEYBOARD_BINDS = binds
end)

function SlashCo.IsKeyPressed(name, ply, button)
	local binds = ply.KEYBOARD_BINDS
	if not binds or not binds[name] then -- Falls back to default if the player didn't network their binds yet
		local defaultBind = SlashCo.KeyboardBinds[name]
		if not defaultBind then return false end

		return button == defaultBind.button
	end

	local bind = binds[name]
	if not bind.button2 then
		return button == bind.button
	else
		local buttons = ply.KEYBOARD_BUTTONS
		if button == bind.button then
			-- We check if the second button is pressed too
			return buttons[bind.button2] or false
		end

		if button == bind.button2 then
			return buttons[bind.button] or false
		end

		return false
	end
end

-- We must keep track of this ourselves... ugly
function SlashCo.OnPlayerButtonDown(ply, button)
	local buttons = ply.KEYBOARD_BUTTONS
	if not buttons then
		buttons = {}
		ply.KEYBOARD_BUTTONS = buttons
	end

	buttons[button] = true

	-- This one is needed as hook order is funky
	hook.Run("SlashCo:PlayerButtonDown", ply, button)
end

function SlashCo.OnPlayerButtonUp(ply, button)
	local buttons = ply.KEYBOARD_BUTTONS
	if not buttons then
		buttons = {}
		ply.KEYBOARD_BUTTONS = buttons
	end

	buttons[button] = nil
end

hook.Add("PlayerButtonDown", "SlashCo:Keyboard", SlashCo.OnPlayerButtonDown)
hook.Add("PlayerButtonUp", "SlashCo:Keyboard", SlashCo.OnPlayerButtonUp)