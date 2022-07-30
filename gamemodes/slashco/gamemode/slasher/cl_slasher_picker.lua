net.Receive("mantislashcoSendLobbyItemGlobal", function()

	SlasherData = net.ReadTable()

end)

net.Receive("mantiSlashCoPickingSlasher", function()

	readtable = net.ReadTable()

	if SlasherData == nil then return end

	SlasherIcon = "slashco/ui/icons/slasher/s_0"
	SelectedSlasher = 0

	DrawTheSlasherSelectorBox()

end)

function SelectThisSlasher(slasherID)

	--if LocalPlayer():SteamID64() != readtable.ply then return end

	if ( IsValid(SlasherSelectFrame) ) then
		SlasherSelectFrame:Remove()
		SlasherSelectFrame = nil
	end

	SelectedSlasher = slasherID

	DrawTheSlasherSelectorBox()

end

function HideSelection()

	if ( IsValid(SlasherSelectFrame) ) then
		SlasherSelectFrame:Remove()
		SlasherSelectFrame = nil
	end

end

function SlasherChosen(My_Pick)

	net.Start("mantiSlashCoSelectSlasher")
	net.WriteTable({pick = My_Pick})
	net.SendToServer()

	print("Slasher chosen with the ID of "..My_Pick)

end


function DrawTheSlasherSelectorBox()

	if ( IsValid( ItemSelectFrame ) ) then return end

	if LocalPlayer():SteamID64() != readtable.slashersteamid then return end
	
	local SlasherPickingID = readtable.slashID
	local SlasherPickingCLASS = readtable.slashClass
	local SlasherPickingDANGER = readtable.slashDanger

	local SlasherIcon = SlasherIcon

	if ( IsValid( SlasherSelectFrame ) ) then print("not valid!") return end

	--if  SlasherPickingID != 0 then SlasherChosen(SlasherPickingID) return end
	
	-- Slasher selectionBox
	SlasherSelectFrame = vgui.Create( "DFrame" )
	SlasherSelectFrame:SetTitle( "Pick Your Slasher" )

	local y = 30
	local diff = PickDifficulty
	for i = 1, #SlasherData do
	
		local Slash = vgui.Create( "DButton", SlasherSelectFrame )
		function Slash.DoClick() SelectThisSlasher(i) end
		Slash:SetPos( 10, y )
		Slash:SetSize( 130, 20 )
		Slash:SetText( SlasherData[i].NAME )

		if SlasherPickingCLASS > 0 then
			
			if SlasherData[i].CLS != SlasherPickingCLASS  then --not the desired class
				Slash:SetDisabled( true )
			end

		end

		if SlasherPickingDANGER > 0 then
			
			if SlasherData[i].DNG != SlasherPickingDANGER  then --not the desired danger
				Slash:SetDisabled( true )
			end

		end
			
		y = y + 30

		if SelectedSlasher == i  then
			Slash:SetDisabled( true )
			SlasherIcon = "slashco/ui/icons/slasher/s_"..SelectedSlasher
		end
		
	end

	local confirmselect = vgui.Create( "DButton", SlasherSelectFrame )
	function confirmselect.DoClick() SlasherChosen(SelectedSlasher) HideSelection() end
	confirmselect:SetPos( 600, 680 )
	confirmselect:SetSize( 130, 20 )
	confirmselect:SetText( "Confirm" )

	if SelectedItem == 0  then
		confirmselect:SetDisabled( true )
	end

	SlasherSelectFrame:SetSize( 750, 600 + y )
	SlasherSelectFrame:Center()
	SlasherSelectFrame:MakePopup()
	SlasherSelectFrame:SetKeyboardInputEnabled( false )
	SlasherSelectFrame:SetDraggable( false ) 
	SlasherSelectFrame:ShowCloseButton( false )

	local mat = vgui.Create("Material", SlasherSelectFrame)
	mat:SetPos(150, 50)
	mat:SetSize(20, 20)
	mat:SetMaterial(SlasherIcon)

	local ILabel = vgui.Create( "DLabel", SlasherSelectFrame )
	ILabel:SetPos( 150, 570 )
	ILabel:SetSize(450, 100)

	local ISClass = vgui.Create( "DLabel", SlasherSelectFrame )
	ISClass:SetPos( 250, 570 )
	ISClass:SetSize(450, 100)

	local ISDanger = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDanger:SetPos( 350, 570 )
	ISDanger:SetSize(450, 100)


	local ISDesc = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDesc:SetPos( 150, 600 )
	ISDesc:SetSize(450, 100)

	if SelectedSlasher > 0 then 
		ILabel:SetText( SCInfo.Slasher[SelectedSlasher].Name ) 
		ISDesc:SetText( SCInfo.Slasher[SelectedSlasher].Description ) 
		ISClass:SetText( "Class: "..SCInfo.Slasher[SelectedSlasher].Class ) 
		ISDanger:SetText( "Danger Level: "..SCInfo.Slasher[SelectedSlasher].Danger) 
	else
		ILabel:SetText( "" ) 
		ISDesc:SetText( "" ) 
		ISClass:SetText( "" ) 
		ISDanger:SetText( "") 
	end
	ILabel:SetAutoStretchVertical( true )
	ISClass:SetAutoStretchVertical( true )
	ISDanger:SetAutoStretchVertical( true )
	ISDesc:SetAutoStretchVertical( true )

end