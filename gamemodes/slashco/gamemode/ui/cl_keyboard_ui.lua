function SlashCo.OpenKeyboardUI()
	if GameData.KeyBoardUI then
		GameData.KeyBoardUI:Remove()
	end

	GameData.KeyBoardUI = vgui.Create("DFrame")
	GameData.KeyBoardUI:SetSize(ScrW() / 2, ScrH() / 2)
	GameData.KeyBoardUI:SetTitle("SlashCo - KeyboardUI")
	GameData.KeyBoardUI:ParentToHUD()
	GameData.KeyBoardUI:Center()
	GameData.KeyBoardUI:MakePopup()
	GameData.KeyBoardUI.OnRemove = function()
		SlashCo.SaveKeyboardBinds()
	end

	local KeyBindings = vgui.Create("DScrollPanel", GameData.KeyBoardUI)
	KeyBindings:Dock(FILL)
	KeyBindings:DockMargin(0, 0, 0, 0)

	local pressedButton = nil
	for bindName, info in SortedPairs(SlashCo.KeyboardBinds) do
		local currentValue = SlashCo.GetKeyButtonName(bindName)

		local KeyPanel = vgui.Create("DPanel", KeyBindings)
		KeyPanel:SetSize(200, 100)
		KeyPanel:Dock(TOP)
		KeyPanel:DockMargin(0, 0, 10, 10)

		local KeyName = vgui.Create("DLabel", KeyPanel)
		KeyName:SetPos(40, 40)
		KeyName:Dock(TOP)
		KeyName:DockMargin(10, 0, 0, 0)
		KeyName:SetColor(color_black)

		local name = SlashCo.Language(info.name, info.name2)
		if name:StartsWith("[") then
			name = string.Trim(string.sub(name, string.find(name, "]") + 1))
		end

		KeyName:SetText(SlashCo.Language("keyboard_keyname", name))
		KeyName:SetFont("HudDefault")

		local CurrentKey = vgui.Create("DLabel", KeyPanel)
		CurrentKey:SetPos(70, 70)
		CurrentKey:Dock(TOP)
		CurrentKey:DockMargin(10, 0, 0, 0)
		CurrentKey:SetColor(color_black)

		CurrentKey:SetText(SlashCo.Language("keyboard_currentkey", currentValue))
		CurrentKey:SetFont("HudDefault")

		local ChangeKey = vgui.Create("DButton", KeyPanel)
		ChangeKey:SetText(SlashCo.Language("keyboard_changekey"))
		ChangeKey:SetFont("HudDefault")
		ChangeKey:Dock(FILL)
		ChangeKey:DockMargin(10, 10, 10, 10)
		ChangeKey.DoClick = function()
			pressedButton = ChangeKey
			ChangeKey:SetText(SlashCo.Language("keyboard_pressnewkey"))
		end

		ChangeKey.ConfirmKey = function(keyName, keyCode)
			if ChangeKey.NewKey == keyCode then
				GameData.KeyboardBinds[bindName] = ChangeKey.NewKey
				CurrentKey:SetText(SlashCo.Language("keyboard_currentkey", string.upper(input.GetKeyName(ChangeKey.NewKey))))
				ChangeKey:SetText(SlashCo.Language("keyboard_changekey"))
				pressedButton = nil
				return
			end

			ChangeKey.NewKey = keyCode
			ChangeKey:SetText(SlashCo.Language("keyboard_confirmkey", keyName))
		end
	end

	GameData.KeyBoardUI.OnKeyCodeReleased = function(pnl, keyCode)
		if not IsValid(pressedButton) then
			-- Let them close it with the same key if they aren't selecting a new key right now
			if SlashCo.IsKeyPressed("OPEN_KEYBINDS", nil, keyCode) then
				GameData.KeyBoardUI:Remove()
			end

			return
		end

		local keyName = input.GetKeyName(keyCode)
		if keyName then -- Apparently some keys got no name... what?
			pressedButton.ConfirmKey(string.upper(keyName), keyCode)
		end
	end
end

concommand.Add("slashco_openkeyboardbinds", function()
	SlashCo.OpenKeyboardUI()
end)