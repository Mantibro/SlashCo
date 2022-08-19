include( "ui/fonts.lua" )

local SlashCoItems = SlashCoItems
local ReceivedLocalPlayerID = ""

function SelectThisItem(itemID)

	if LocalPlayer():SteamID64() ~= ReceivedLocalPlayerID then return end

	if ( IsValid(ItemSelectFrame) ) then
		ItemSelectFrame:Remove()
		ItemSelectFrame = nil
	end

	SelectedItem = itemID

	DrawTheSelectorBox()

end

net.Receive("mantislashcoStartItemPicking", function()

	readtable = net.ReadTable()

	if LocalPlayer():SteamID64() ~= readtable.ply then return end

	ReceivedLocalPlayerID = readtable.ply 

	DrawTheSelectorBox()

end)

function DrawTheSelectorBox()

	if ( IsValid( ItemSelectFrame ) ) then return end

	if LocalPlayer():SteamID64() ~= ReceivedLocalPlayerID then return end
	
	-- Slasher selectionBox
	ItemSelectFrame = vgui.Create( "DFrame" )
	ItemSelectFrame:SetTitle( "Pick Your Item" )

	if SelectedItem == nil then SelectedItem = "Baby" end

	local y = 30
	for k, p in SortedPairs(SlashCoItems) do
		if not p.Price then continue end
		local Item = vgui.Create( "DButton", ItemSelectFrame )
		function Item.DoClick() SelectThisItem(k) end
		Item:SetPos( 10, y )
		Item:SetSize( 160, 30 )
		Item:SetText( p.Name )
		Item:SetFont( "MenuFont1" )

		if SelectedItem == k then
			Item:SetDisabled( true )
		end

		y = y + 40
	end

	local confirmselect = vgui.Create( "DButton", ItemSelectFrame )
	function confirmselect.DoClick() ItemChosen(SelectedItem) HideItemSelection() end
	confirmselect:SetPos( 600, y - 40 )
	confirmselect:SetSize( 160, 30 )
	confirmselect:SetText( "Confirm" )
	confirmselect:SetFont( "MenuFont1" )

	-- Model panel
	local mdl = vgui.Create("DModelPanel", ItemSelectFrame)
	mdl:SetPos(250, 30)
	mdl:SetSize(350, 200)
	mdl:SetLookAt(Vector(0, 0, 0))
	mdl:SetFOV(40)
	mdl:SetModel(SlashCoItems[SelectedItem].Model)
	mdl:SetCamPos(SlashCoItems[SelectedItem].CamPos)

	local ILabel = vgui.Create( "DLabel", ItemSelectFrame )
	ILabel:SetPos( 180, 230 )
	ILabel:SetSize(600, 200)
	if (SlashCoItems[SelectedItem].MaxAllowed) then
		local numRemain = SlashCoItems[SelectedItem].MaxAllowed()
		for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if v:GetNWString("item", "none") == SelectedItem then numRemain = numRemain - 1 end
		end
		ILabel:SetText(SlashCoItems[SelectedItem].Name.." ( "..SlashCoItems[SelectedItem].Price.." Points ) ( "..numRemain.." remaining )")
	else
		ILabel:SetText(SlashCoItems[SelectedItem].Name.." ( "..SlashCoItems[SelectedItem].Price.." Points )")
	end
	ILabel:SetFont( "MenuFont2" )
	ILabel:SetAutoStretchVertical( true )

	local IDesc = vgui.Create( "DLabel", ItemSelectFrame )
	IDesc:SetPos( 180, 260 )
	IDesc:SetSize(600, 200)
	IDesc:SetText(SlashCoItems[SelectedItem].Description)
	IDesc:SetFont( "MenuFont1" )
	IDesc:SetAutoStretchVertical( true )

	ItemSelectFrame:SetSize( 800, y )
	ItemSelectFrame:Center()
	ItemSelectFrame:MakePopup()
	ItemSelectFrame:SetKeyboardInputEnabled( false )

end

function HideItemSelection()

	if ( IsValid(ItemSelectFrame) ) then
		ItemSelectFrame:Remove()
		ItemSelectFrame = nil
		SelectedItem = "Baby"
		ReceivedLocalPlayerID = ""
	end

end

function ItemChosen(itemID)

	net.Start("mantislashcoPickItem")
	net.WriteTable({ply = LocalPlayer():SteamID64(), id = itemID})
	net.SendToServer()

	DrawTheSelectorBox()

end

