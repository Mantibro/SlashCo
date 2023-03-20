net.Receive("mantiSlashCoPickingSlasher", function()

	readtable = net.ReadTable()

	SlasherIcon = "slashco/ui/icons/slasher/s_0"
	SelectedSlasher = "None"

	DrawTheSlasherSelectorBox()

end)

function SelectThisSlasher(slasherName)

	--if LocalPlayer():SteamID64() ~= readtable.ply then return end

	if ( IsValid(SlasherSelectFrame) ) then
		SlasherSelectFrame:Remove()
		SlasherSelectFrame = nil
	end

	SelectedSlasher = slasherName

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

	print("Slasher chosen with the Name of "..My_Pick)

end


function DrawTheSlasherSelectorBox()

	if ( IsValid( ItemSelectFrame ) ) then return end

	if LocalPlayer():SteamID64() ~= readtable.slashersteamid then return end
	
	local SlasherPickingID = readtable.slashID
	local SlasherPickingCLASS = readtable.slashClass
	local SlasherPickingDANGER = readtable.slashDanger

	local SlasherIcon = SlasherIcon

	if ( IsValid( SlasherSelectFrame ) ) then print("not valid!") return end

	if  SlasherPickingID ~= 0 then SlasherChosen(SlasherPickingID) return end
	
	-- Slasher selectionBox
	SlasherSelectFrame = vgui.Create( "DFrame" )
	SlasherSelectFrame:SetTitle( "Pick Your Slasher" )

	local y = 30
	local diff = PickDifficulty

	for k, v in pairs( SlashCoSlasher ) do
	
		if not v.IsSelectable then continue end

		local Slash = vgui.Create( "DButton", SlasherSelectFrame )
		function Slash.DoClick() SelectThisSlasher(k) end
		Slash:SetPos( 30, y )
		Slash:SetSize( 200, 30 )
		Slash:SetText( v.Name )
		Slash:SetFont( "MenuFont1" )

		if SlasherPickingCLASS > 0 then
			
			if v.Class ~= SlasherPickingCLASS  then --not the desired class
				Slash:SetDisabled( true )
			end

		end

		if SlasherPickingDANGER > 0 then
			
			if v.DangerLevel ~= SlasherPickingDANGER  then --not the desired danger
				Slash:SetDisabled( true )
			end

		end
			
		y = y + 40

		if SelectedSlasher == k  then
			Slash:SetDisabled( true )
			SlasherIcon = "slashco/ui/icons/slasher/s_"..SlashCoSlasher[SelectedSlasher].ID
		end
		
	end

	local confirmselect = vgui.Create( "DButton", SlasherSelectFrame )
	function confirmselect.DoClick() SlasherChosen(SelectedSlasher) HideSelection() end
	confirmselect:SetPos( 730, 800 )
	confirmselect:SetSize( 160, 40 )
	confirmselect:SetText( "Confirm" )
	confirmselect:SetFont( "MenuFont1" )

	if SelectedSlasher == "None"  then
		confirmselect:SetDisabled( true )
	end

	SlasherSelectFrame:SetSize( 900, 1000 )
	SlasherSelectFrame:Center()
	SlasherSelectFrame:MakePopup()
	SlasherSelectFrame:SetKeyboardInputEnabled( false )
	SlasherSelectFrame:SetDraggable( false ) 
	SlasherSelectFrame:ShowCloseButton( false )

	local mat = vgui.Create("Material", SlasherSelectFrame)
	mat:SetPos(250, 50)
	mat:SetSize(20, 20)
	mat:SetMaterial(SlasherIcon)

	local ILabel = vgui.Create( "DLabel", SlasherSelectFrame )
	ILabel:SetPos( 250, 570 )
	ILabel:SetSize(450, 100)

	local ISClass = vgui.Create( "DLabel", SlasherSelectFrame )
	ISClass:SetPos( 250, 605 )
	ISClass:SetSize(450, 100)

	local ISDanger = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDanger:SetPos( 400, 605 )
	ISDanger:SetSize(450, 100)

	local ISDesc = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDesc:SetPos( 250, 650 )
	ISDesc:SetSize(650, 100)

	if SelectedSlasher ~= "None" then 
		ILabel:SetText( SlashCoSlasher[SelectedSlasher].Name ) 
		ISDesc:SetText(SlashCoSlasher[SelectedSlasher].Description.."\n\nSpeed: "..SlashCoSlasher[SelectedSlasher].SpeedRating.."\nEyesight: "..SlashCoSlasher[SelectedSlasher].EyeRating.."\nDifficulty: "..SlashCoSlasher[SelectedSlasher].DiffRating ) 
		ISClass:SetText( "Class: ".. TranslateSlasherClass(SlashCoSlasher[SelectedSlasher].Class) ) 
		ISDanger:SetText( "Danger Level: "..TranslateDangerLevel(SlashCoSlasher[SelectedSlasher].DangerLevel)) 
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
	ILabel:SetFont( "MenuFont3" )
	ILabel:SetColor(Color(255, 0, 0))
	ISClass:SetFont( "MenuFont1" )
	ISDanger:SetFont( "MenuFont1" )
	ISDesc:SetFont( "MenuFont1" )

end