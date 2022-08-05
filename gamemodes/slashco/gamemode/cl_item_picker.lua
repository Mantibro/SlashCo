include( "ui/fonts.lua" )

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

	if SelectedItem == nil then SelectedItem = 0 end

	local y = 30
	for i = 1, #SCInfo.Item do
	
		local Item = vgui.Create( "DButton", ItemSelectFrame )
		function Item.DoClick() SelectThisItem(i) end
		Item:SetPos( 10, y )
		Item:SetSize( 160, 30 )
		Item:SetText( SCInfo.Item[i].Name )
		Item:SetFont( "MenuFont1" )

		if SelectedItem == i  then
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

	if SelectedItem == 0  then
		confirmselect:SetDisabled( true )
	end

	if SelectedItem == 2 and readtable.wardsleft < 1 then
		confirmselect:SetDisabled( true )
	end


	-- Model panel
	local mdl = vgui.Create("DModelPanel", ItemSelectFrame)
	mdl:SetPos(250, 30)
	mdl:SetSize(350, 200)
	--mdl:SetModel("models/props_junk/metalgascan.mdl")
	--mdl:SetCamPos(Vector(80, 0, 0))
	mdl:SetLookAt(Vector(0, 0, 0))
	mdl:SetFOV(40)

	local ILabel = vgui.Create( "DLabel", ItemSelectFrame )
	ILabel:SetPos( 180, 230 )
	ILabel:SetSize(600, 200)
	ILabel:SetText( " " )
	ILabel:SetFont( "MenuFont2" )
	ILabel:SetAutoStretchVertical( true )

	local IDesc = vgui.Create( "DLabel", ItemSelectFrame )
	IDesc:SetPos( 180, 260 )
	IDesc:SetSize(600, 200)
	IDesc:SetText(  " " )
	IDesc:SetFont( "MenuFont1" )
	IDesc:SetAutoStretchVertical( true )

	if SelectedItem == 1 then

		mdl:SetModel("models/props_junk/metalgascan.mdl")
		mdl:SetCamPos(Vector(80, 0, 0))

		ILabel:SetText( SCInfo.Item[1].Name.." ( "..SCInfo.Item[1].Price.." Points )" )
		IDesc:SetText( SCInfo.Item[1].Description )

	elseif SelectedItem == 2 then

		mdl:SetModel("models/slashco/items/deathward.mdl")
		mdl:SetCamPos(Vector(40, 0, 15))

		ILabel:SetText( SCInfo.Item[2].Name.." ( "..SCInfo.Item[2].Price.." Points )" )
		IDesc:SetText( SCInfo.Item[2].Description.."\nWards left: "..tostring(readtable.wardsleft) )

	elseif SelectedItem == 3 then

		mdl:SetModel("models/props_junk/garbage_milkcarton001a.mdl")
		mdl:SetCamPos(Vector(60, 0, 10))

		ILabel:SetText( SCInfo.Item[3].Name.." ( "..SCInfo.Item[3].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[3].Description )

	elseif SelectedItem == 4 then

		mdl:SetModel("models/slashco/items/cookie.mdl")
		mdl:SetCamPos(Vector(50, 0, 20))

		ILabel:SetText( SCInfo.Item[4].Name.." ( "..SCInfo.Item[4].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[4].Description )

	elseif SelectedItem == 5 then

		mdl:SetModel("models/props_lab/jar01a.mdl")
		mdl:SetCamPos(Vector(60, 0, 10))

		ILabel:SetText( SCInfo.Item[5].Name.." ( "..SCInfo.Item[5].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[5].Description )

	elseif SelectedItem == 6 then

		mdl:SetModel("models/props_junk/Shoe001a.mdl")
		mdl:SetCamPos(Vector(50, 0, 20))

		ILabel:SetText( SCInfo.Item[6].Name.." ( "..SCInfo.Item[6].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[6].Description )

	elseif SelectedItem == 7 then

		mdl:SetModel("models/props_c17/doll01.mdl")
		mdl:SetCamPos(Vector(50, 0, 0))

		ILabel:SetText( SCInfo.Item[7].Name.." ( "..SCInfo.Item[7].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[7].Description )

	elseif SelectedItem == 8 then

		mdl:SetModel("models/props_junk/PopCan01a.mdl")
		mdl:SetCamPos(Vector(30, 0, 0))

		ILabel:SetText( SCInfo.Item[8].Name.." ( "..SCInfo.Item[8].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[8].Description )

	elseif SelectedItem == 9 then

		mdl:SetModel("models/props_c17/light_cagelight01_on.mdl")
		mdl:SetCamPos(Vector(50, 0, 10))

		ILabel:SetText( SCInfo.Item[9].Name.." ( "..SCInfo.Item[9].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[9].Description )

	elseif SelectedItem == 10 then

		mdl:SetModel("models/slashco/items/devildie.mdl")
		mdl:SetCamPos(Vector(30, 0, 10))

		ILabel:SetText( SCInfo.Item[10].Name.." ( "..SCInfo.Item[10].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[10].Description )

	elseif SelectedItem == 11 then

		mdl:SetModel("models/props_phx/gibs/flakgib1.mdl")
		mdl:SetCamPos(Vector(30, 0, 10))

		ILabel:SetText( SCInfo.Item[11].Name.." ( "..SCInfo.Item[11].Price.." Points )"  )
		IDesc:SetText( SCInfo.Item[11].Description )

	end

	ItemSelectFrame:SetSize( 800, y )
	ItemSelectFrame:Center()
	ItemSelectFrame:MakePopup()
	ItemSelectFrame:SetKeyboardInputEnabled( false )

end

function HideItemSelection()

	if ( IsValid(ItemSelectFrame) ) then
		ItemSelectFrame:Remove()
		ItemSelectFrame = nil
		SelectedItem = 0
		ReceivedLocalPlayerID = ""
	end

end

function ItemChosen(itemID)

	net.Start("mantislashcoPickItem")
	net.WriteTable({ply = LocalPlayer():SteamID64(), id = itemID})
	net.SendToServer()

	DrawTheSelectorBox()

end

