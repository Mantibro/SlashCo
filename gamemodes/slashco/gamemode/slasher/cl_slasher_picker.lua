net.Receive("SlashCo:PickingSlasher", function()
	DrawTheSlasherSelectorBox(net.ReadTable())
end)

GameData.SelectedSlasher = GameData.SelectedSlasher or "None"
function HideSelection()
	if IsValid(SlasherSelectFrame) then
		SlasherSelectFrame:Remove()
		SlasherSelectFrame = nil
	end
end

function SlasherChosen(pickedSlasher)
	net.Start("SlashCo:SelectSlasher")
		net.WriteString(pickedSlasher)
	net.SendToServer()

	-- print("[SlashCo] Slasher chosen \"" .. pickedSlasher .. "\"")
end

function DrawTheSlasherSelectorBox(pickSlasherTbl)
	SlashCo.FlashWindows() -- RaphaelIT7: Let's notify the player that they can pick

	local SlasherPickingCLASS = SlashCo.SlasherClass.Unknown
	local SlasherPickingDANGER = SlashCo.DangerLevel.Unknown
	local bannedSlashers = {}
	if pickSlasherTbl then
		SlasherPickingCLASS = pickSlasherTbl.slasherClass or SlashCo.SlasherClass.Unknown
		SlasherPickingDANGER = pickSlasherTbl.slasherDanger or SlashCo.DangerLevel.Unknown
		bannedSlashers = pickSlasherTbl.bannedSlashers or {}
	end

	GameData.SelectedSlasher = "None"
	if IsValid(SlasherSelectFrame) then
		SlasherSelectFrame:Remove()
	end

	-- Slasher selectionBox
	SlasherSelectFrame = vgui.Create("DFrame")
	SlasherSelectFrame:SetTitle("")
	--SlasherSelectFrame:ParentToHUD() -- RaphaelIT7: We don't parent to HUD since we want this rendered even if the mainmenu is open

	local x = ScrW() / 50
	local y = ScrH() / 25
	local icon_size = ScrW() / 15
	local row = 0
	local count = 1
	local updateSelection -- We set this variable further down
	for slasherName, v in SortedPairs(SlashCoSlashers) do
		if not v.IsSelectable then continue end

		local Slash = vgui.Create("DButton", SlasherSelectFrame)
		function Slash.DoClick()
			GameData.SelectedSlasher = slasherName
			updateSelection()
			GameData.LocalPlayer:EmitSound("slashco/slasher_preview.mp3")
		end
		Slash:SetPos(30 + x, 30 + y)
		Slash:SetSize(icon_size, icon_size)
		Slash:SetText("")
		--Slash:SetFont("MenuFont1")
		local is_available = true

		if SlasherPickingCLASS > 0 and v.Class ~= SlasherPickingCLASS then
			Slash:SetDisabled(true)
			is_available = false
		end

		if SlasherPickingDANGER > 0 and v.DangerLevel ~= SlasherPickingDANGER then
			Slash:SetDisabled(true)
			is_available = false
		end

		if bannedSlashers[v.Name] then
			Slash:SetDisabled(true)
			is_available = false
		end

		if GameData.SelectedSlasher == slasherName then
			Slash:SetDisabled(true)
			Slash:SetSize(icon_size * 1.12, icon_size * 1.12)
			Slash:SetPos((30 + x) - icon_size * 0.06, (30 + y) - icon_size * 0.06)
		end

		function Slash.Paint(self, w, h)
			if is_available then
				surface.SetMaterial(Material("slashco/ui/icons/slasher/s_" .. SlashCoSlashers[slasherName].ID))
			else
				surface.SetMaterial(Material("slashco/ui/icons/slasher/kill_disabled"))
			end

			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)
		end

		x = x + ScrW() / 13
		if math.floor(count / 6) > row then
			row = math.floor(count / 6)
			y = y + ScrW() / 13
			x = ScrW() / 50
		end

		count = count + 1
	end

	local confirmselect = vgui.Create("DButton", SlasherSelectFrame)
	function confirmselect.DoClick()
		SlasherChosen(GameData.SelectedSlasher)
		HideSelection()
		GameData.LocalPlayer:EmitSound("slashco/slasher_select.mp3")
	end
	confirmselect:SetPos(ScrW() / 2, ScrH() / 1.1)
	confirmselect:SetSize(ScrW() / 4, 40)
	confirmselect:SetText(SlashCo.Language("ItemConfirm"))
	confirmselect:SetFont("MenuFont2")
	function confirmselect.Paint(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0, 255))
	end

	SlasherSelectFrame:SetSize(ScrW(), ScrH())
	SlasherSelectFrame:Center()
	SlasherSelectFrame:MakePopup()
	SlasherSelectFrame:SetKeyboardInputEnabled(false)
	SlasherSelectFrame:SetDraggable(false)
	SlasherSelectFrame:ShowCloseButton(false)
	function SlasherSelectFrame.Paint(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, color_black)
	end

	local ILabel = vgui.Create("DLabel", SlasherSelectFrame)
	ILabel:SetPos(ScrW() / 2, ScrH() / 2)
	ILabel:SetSize(1024, 100)

	local ISClass = vgui.Create("DLabel", SlasherSelectFrame)
	ISClass:SetPos(ScrW() / 2, ScrH() / 1.7)
	ISClass:SetSize(450, 100)

	local ISDanger = vgui.Create("DLabel", SlasherSelectFrame)
	ISDanger:SetPos(ScrW() / 2, ScrH() / 1.55)
	ISDanger:SetSize(450, 100)

	local ISDesc = vgui.Create("DLabel", SlasherSelectFrame)
	ISDesc:SetPos(ScrW() / 2, ScrH() / 1.4)
	ISDesc:SetSize(ScrW() / 2, 100)

	ILabel:SetAutoStretchVertical(true)
	ISClass:SetAutoStretchVertical(true)
	ISDanger:SetAutoStretchVertical(true)
	ISDesc:SetAutoStretchVertical(true)
	ILabel:SetFont("MenuFont3")
	ILabel:SetColor(Color(255, 0, 0))
	ISClass:SetFont("MenuFont4")
	ISDanger:SetFont("MenuFont4")
	ISDesc:SetFont("MenuFont1")

	local Descriptor = vgui.Create("DLabel", SlasherSelectFrame)
	Descriptor:SetPos(ScrW() / 2, ScrH() / 1.75)
	Descriptor:SetSize(1024, 600)
	Descriptor:SetText("")
	Descriptor:SetFont("MenuFont1")
	Descriptor:SetAutoStretchVertical(true)

	local mat = vgui.Create("Material", SlasherSelectFrame)
	mat:SetPos(ScrW() - (ScrW() / 2.5), 0)
	mat:SetSize(ScrW() / 2.5, ScrH() / 1.5)
	mat:SetMaterial("slashco/ui/icons/slasher/preview/preview_1")
	mat.AutoSize = false
	mat:SetZPos(-1) -- Else it would cut off our labels. This took like an hour to figure out :sob:
	mat:SetVisible(false)

	function updateSelection()
		if GameData.SelectedSlasher == "None" then
			confirmselect:SetDisabled(true)

			ILabel:SetText("")
			ISDesc:SetText("")
			ISClass:SetText("")
			ISDanger:SetText("")
		else
			confirmselect:SetDisabled(false)
			mat:SetVisible(true)
			mat:SetMaterial("slashco/ui/icons/slasher/preview/preview_" .. SlashCoSlashers[GameData.SelectedSlasher].ID)

			ILabel:SetText(SlashCo.Language(GameData.SelectedSlasher))
			ISDesc:SetText(SlashCo.Language(GameData.SelectedSlasher .. "_desc") .. "\n\n" .. SlashCo.Language("slasher_speedrate") .. ": " .. SlashCoSlashers[GameData.SelectedSlasher].SpeedRating .. "\n" .. SlashCo.Language("slasher_eyerate") .. ": " .. SlashCoSlashers[GameData.SelectedSlasher].EyeRating .. "\n" .. SlashCo.Language("slasher_diffrate") .. ": " .. SlashCoSlashers[GameData.SelectedSlasher].DiffRating)
			ISClass:SetText(SlashCo.Language(TranslateSlasherClass(SlashCoSlashers[GameData.SelectedSlasher].Class)))
			ISDanger:SetText(SlashCo.Language(TranslateDangerLevel(SlashCoSlashers[GameData.SelectedSlasher].DangerLevel)))

			if SlashCoSlashers[GameData.SelectedSlasher].DangerLevel == 1 then
				ISDanger:SetTextColor(Color(255, 200, 0))
			end

			if SlashCoSlashers[GameData.SelectedSlasher].DangerLevel == 2 then
				ISDanger:SetTextColor(Color(255, 120, 120))
			end

			if SlashCoSlashers[GameData.SelectedSlasher].DangerLevel == 3 then
				ISDanger:SetTextColor(Color(255, 0, 0))
			end

			Descriptor:SetText(SlashCo.Language("Class", "") .. [[



			]] .. SlashCo.Language("DangerLevel",""))
		end
	end
	updateSelection()
end

local Death = {
	CurInput = 1,
	Sequence = {
		18,
		14,
		3,
		1,
		2,
		8,
		64
	}
}

hook.Add("PlayerButtonDown", "FriendlyMatch", function(ply, key)
	if ply ~= LocalPlayer() then return end
	if not IsFirstTimePredicted() then return end

	if IsValid(SlasherSelectFrame) then
		if key == Death.Sequence[Death.CurInput] then
			Death.CurInput = Death.CurInput + 1
			ply:EmitSound("slashco/blip.wav")
			if Death.CurInput > 7 then
				ply:ChatPrint("What have you done. . .")
				ply:EmitSound("slashco/slasher/hoovydundy/kill.mp3")
				SlashCoSlashers.Hoovydundy.IsSelectable = true
				if (IsValid(SlasherSelectFrame)) then
					SlasherSelectFrame:Remove()
					SlasherSelectFrame = nil
				end
				SelectedSlasher = "Hoovydundy"
				DrawTheSlasherSelectorBox()
			end
		else
			Death.CurInput = 1
		end
	end
end)