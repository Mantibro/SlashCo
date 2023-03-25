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

	--if ( IsValid( ItemSelectFrame ) ) then return end

	--if LocalPlayer():SteamID64() ~= readtable.slashersteamid then return end

	local SlasherPickingID = 0
	local SlasherPickingCLASS = 0
	local SlasherPickingDANGER = 0

	if readtable ~= nil then
		SlasherPickingID = readtable.slashID
		SlasherPickingCLASS = readtable.slashClass
		SlasherPickingDANGER = readtable.slashDanger
	else

	end

	local SlasherIcon = SlasherIcon

	if ( IsValid( SlasherSelectFrame ) ) then print("not valid!") return end

	if  SlasherPickingID ~= 0 then SlasherChosen(SlasherPickingID) return end
	
	-- Slasher selectionBox
	SlasherSelectFrame = vgui.Create( "DFrame" )
	SlasherSelectFrame:SetTitle( "Pick Your Slasher" )

	local x = ScrW()/50
	local y = ScrH()/25
	local diff = PickDifficulty
	local icon_size = ScrW()/15
	local row = 0
	local count = 1

	for k, v in SortedPairs( SlashCoSlasher ) do
	
		if not v.IsSelectable then continue end

		local Slash = vgui.Create( "DButton", SlasherSelectFrame )
		function Slash.DoClick() 
			SelectThisSlasher(k) 
			LocalPlayer():EmitSound("slashco/slasher_preview.mp3")
		end
		Slash:SetPos( 30 + x, 30 + y )
		Slash:SetSize( icon_size, icon_size)
		Slash:SetText( "" )
		--Slash:SetFont( "MenuFont1" )
		local select_color = 1

		if SlasherPickingCLASS > 0 then
			
			if v.Class ~= SlasherPickingCLASS  then --not the desired class
				Slash:SetDisabled( true )
				select_color = 0.25
			end

		end

		if SlasherPickingDANGER > 0 then
			
			if v.DangerLevel ~= SlasherPickingDANGER  then --not the desired danger
				select_color = 0.25
			end

		end
		

		if SelectedSlasher == k  then
			Slash:SetDisabled( true )
			select_color = 0.7
			Slash:SetSize( icon_size*1.12, icon_size*1.12)
			Slash:SetPos( (30 + x) - icon_size*0.06, (30 + y) - icon_size*0.06)
		end

		Slash.Paint = function( self, w, h )
			surface.SetMaterial( Material( "slashco/ui/icons/slasher/s_"..SlashCoSlasher[k].ID ) )
			surface.SetDrawColor( 255,255,255,255*select_color )
			surface.DrawTexturedRect( 0, 0, w, h)
		end

		x = x + ScrW()/13
		if math.floor(count / 6) > row then 
			row = math.floor(count / 6) 
			y = y + ScrW()/13
			x = ScrW()/50
		end

		count = count + 1

		
		
	end

	local confirmselect = vgui.Create( "DButton", SlasherSelectFrame )
	function confirmselect.DoClick() SlasherChosen(SelectedSlasher) HideSelection() LocalPlayer():EmitSound("slashco/slasher_select.mp3") end
	confirmselect:SetPos( ScrW()/2, ScrH()/1.1 )
	confirmselect:SetSize( ScrW()/4, 40 )
	confirmselect:SetText( "SELECT" )
	confirmselect:SetFont( "MenuFont2" )
	confirmselect.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
	end

	if SelectedSlasher == "None"  then
		confirmselect:SetDisabled( true )
	end

	local mat = vgui.Create("Material", SlasherSelectFrame)
	mat:SetPos(ScrW() - (ScrW()/2.5 ), 0)
	mat:SetSize(ScrW()/2.5, ScrH()/1.5)
	mat:SetMaterial("slashco/ui/icons/slasher/preview/preview_"..SlashCoSlasher[SelectedSlasher].ID)
	--mat:SetMaterial("slashco/ui/icons/slasher/preview/preview_1" )
	mat.AutoSize = false
			
	SlasherSelectFrame:SetSize( ScrW(), ScrH() )
	SlasherSelectFrame:Center()
	SlasherSelectFrame:MakePopup()
	SlasherSelectFrame:SetKeyboardInputEnabled( false )
	SlasherSelectFrame:SetDraggable( false ) 
	SlasherSelectFrame:ShowCloseButton( false )
	SlasherSelectFrame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 255 ) ) 
	end

	local ILabel = vgui.Create( "DLabel", SlasherSelectFrame )
	ILabel:SetPos( ScrW()/2, ScrH()/2 )
	ILabel:SetSize(1024, 100)

	local ISClass = vgui.Create( "DLabel", SlasherSelectFrame )
	ISClass:SetPos( ScrW()/2, ScrH()/1.8 )
	ISClass:SetSize(450, 100)

	local ISDanger = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDanger:SetPos( ScrW()/2, ScrH()/1.7 )
	ISDanger:SetSize(450, 100)

	local ISDesc = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDesc:SetPos( ScrW()/2, ScrH()/1.4 )
	ISDesc:SetSize(ScrW()/2, 100)

	if SelectedSlasher ~= "None" then 
		ILabel:SetText( SlashCoSlasher[SelectedSlasher].Name ) 
		ISDesc:SetText(SlashCoSlasher[SelectedSlasher].Description.."\n\nSpeed: "..SlashCoSlasher[SelectedSlasher].SpeedRating.."\nEyesight: "..SlashCoSlasher[SelectedSlasher].EyeRating.."\nDifficulty: "..SlashCoSlasher[SelectedSlasher].DiffRating ) 
		ISClass:SetText( "Class: "..TranslateSlasherClass(SlashCoSlasher[SelectedSlasher].Class) ) 
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
	ISClass:SetFont( "MenuFont2" )
	ISDanger:SetFont( "MenuFont2" )
	ISDesc:SetFont( "MenuFont1" )

end