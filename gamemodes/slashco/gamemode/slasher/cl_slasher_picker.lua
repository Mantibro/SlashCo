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

	if LocalPlayer():SteamID64() ~= readtable.slashersteamid then return end

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

	if not SelectedSlasher then
		SelectedSlasher = "None"
	end

	if ( IsValid( SlasherSelectFrame ) ) then print("not valid!") return end

	if  SlasherPickingID ~= 0 then SlasherChosen(SlasherPickingID) return end
	
	-- Slasher selectionBox
	SlasherSelectFrame = vgui.Create( "DFrame" )
	SlasherSelectFrame:SetTitle( "" )

	local x = ScrW()/50
	local y = ScrH()/25
	local diff = PickDifficulty
	local icon_size = ScrW()/15
	local row = 0
	local count = 1

	for k, v in SortedPairs( SlashCoSlashers ) do
	
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
		local is_available = true

		if SlasherPickingCLASS > 0 then
			
			if v.Class ~= SlasherPickingCLASS  then --not the desired class
				Slash:SetDisabled( true )
				is_available = false
			end

		end

		if SlasherPickingDANGER > 0 then
			
			if v.DangerLevel ~= SlasherPickingDANGER  then --not the desired danger
				Slash:SetDisabled( true )
				is_available = false
			end

		end
		

		if SelectedSlasher == k  then
			Slash:SetDisabled( true )
			Slash:SetSize( icon_size*1.12, icon_size*1.12)
			Slash:SetPos( (30 + x) - icon_size*0.06, (30 + y) - icon_size*0.06)
		end

		Slash.Paint = function( self, w, h )
			if is_available then
				surface.SetMaterial( Material( "slashco/ui/icons/slasher/s_"..SlashCoSlashers[k].ID ) )
			else
				surface.SetMaterial( Material( "slashco/ui/icons/slasher/kill_disabled" ) )
			end
			surface.SetDrawColor( 255,255,255,255 )
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
	confirmselect:SetText( SlashCoLanguage("ItemConfirm") )
	confirmselect:SetFont( "MenuFont2" )
	confirmselect.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
	end

	if SelectedSlasher == "None"  then
		confirmselect:SetDisabled( true )
	else
		local mat = vgui.Create("Material", SlasherSelectFrame)
		mat:SetPos(ScrW() - (ScrW()/2.5 ), 0)
		mat:SetSize(ScrW()/2.5, ScrH()/1.5)
		mat:SetMaterial("slashco/ui/icons/slasher/preview/preview_"..SlashCoSlashers[SelectedSlasher].ID)
		--mat:SetMaterial("slashco/ui/icons/slasher/preview/preview_1" )
		mat.AutoSize = false
	end
			
	SlasherSelectFrame:SetSize( ScrW(), ScrH() )
	SlasherSelectFrame:Center()
	SlasherSelectFrame:MakePopup()
	SlasherSelectFrame:SetKeyboardInputEnabled( false )
	SlasherSelectFrame:SetDraggable( false ) 
	SlasherSelectFrame:ShowCloseButton( false )
	SlasherSelectFrame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, color_black )
	end

	local ILabel = vgui.Create( "DLabel", SlasherSelectFrame )
	ILabel:SetPos( ScrW()/2, ScrH()/2 )
	ILabel:SetSize(1024, 100)

	local ISClass = vgui.Create( "DLabel", SlasherSelectFrame )
	ISClass:SetPos( ScrW()/2, ScrH()/1.7 )
	ISClass:SetSize(450, 100)

	local ISDanger = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDanger:SetPos( ScrW()/2, ScrH()/1.55 )
	ISDanger:SetSize(450, 100)

	local ISDesc = vgui.Create( "DLabel", SlasherSelectFrame )
	ISDesc:SetPos( ScrW()/2, ScrH()/1.4 )
	ISDesc:SetSize(ScrW()/2, 100)

	if SelectedSlasher ~= "None" then 
		ILabel:SetText( SlashCoLanguage(SelectedSlasher) ) 
		ISDesc:SetText(SlashCoLanguage(SelectedSlasher.."_desc").."\n\n"..SlashCoLanguage("slasher_speedrate")..": "..SlashCoSlashers[SelectedSlasher].SpeedRating.."\n"..SlashCoLanguage("slasher_eyerate")..": "..SlashCoSlashers[SelectedSlasher].EyeRating.."\n"..SlashCoLanguage("slasher_diffrate")..": "..SlashCoSlashers[SelectedSlasher].DiffRating )
		ISClass:SetText( SlashCoLanguage(TranslateSlasherClass(SlashCoSlashers[SelectedSlasher].Class)) )
		ISDanger:SetText( SlashCoLanguage(TranslateDangerLevel(SlashCoSlashers[SelectedSlasher].DangerLevel)))

		if SlashCoSlashers[SelectedSlasher].DangerLevel == 1 then
			ISDanger:SetTextColor( Color( 255, 200, 0) )
		end

		if SlashCoSlashers[SelectedSlasher].DangerLevel == 2 then
			ISDanger:SetTextColor( Color( 255, 120, 120) )
		end

		if SlashCoSlashers[SelectedSlasher].DangerLevel == 3 then
			ISDanger:SetTextColor( Color( 255, 0, 0) )
		end

		local Descriptor = vgui.Create( "DLabel", SlasherSelectFrame )
		Descriptor:SetPos( ScrW()/2, ScrH()/1.75 )
		Descriptor:SetSize(1024, 600)
		Descriptor:SetText(SlashCoLanguage("Class")..[[:
		

		
		]]..SlashCoLanguage("DangelLevel")..[[:]])
		Descriptor:SetFont( "MenuFont1" )
		Descriptor:SetAutoStretchVertical( true )
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
	ISClass:SetFont( "MenuFont4" )
	ISDanger:SetFont( "MenuFont4" )
	ISDesc:SetFont( "MenuFont1" )

end

local Fun = {
	CurInput = 1,
	Sequence = {
		88,
		88,
		90,
		90,
		89,
		91,
		89,
		91,
		12,
		11,
		64
	}
}

hook.Add("PlayerButtonDown", "TheCoder", function(ply, key) 

	if ply ~= LocalPlayer() then return end

	if not IsFirstTimePredicted() then return end

	if ( IsValid(SlasherSelectFrame) ) then

		if key == Fun.Sequence[Fun.CurInput] then
			Fun.CurInput = Fun.CurInput + 1
			ply:EmitSound("slashco/blip.wav")
			if Fun.CurInput > 11 then
				ply:ChatPrint("You unleashed the Beast.")
				ply:EmitSound("slashco/slasher/leuonard_yell1.mp3")
				SlashCoSlashers.Leuonard.IsSelectable = true
				if ( IsValid(SlasherSelectFrame) ) then
					SlasherSelectFrame:Remove()
					SlasherSelectFrame = nil
				end
				SelectedSlasher = "Leuonard"
				DrawTheSlasherSelectorBox()
			end
		else
			Fun.CurInput = 1
		end

	end

end)