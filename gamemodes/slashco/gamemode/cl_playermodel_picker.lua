include( "ui/fonts.lua" )

function DrawThePlayermodelSelectorBox()

	if ( IsValid( PMSelectFrame ) ) then return end
	
	-- Slasher selectionBox
	PMSelectFrame = vgui.Create( "DFrame" )
	PMSelectFrame:SetTitle( "Choose your Playermodel" )

	local x = 0
	for i = 1, 9 do
	
		local Item = vgui.Create( "SpawnIcon", PMSelectFrame )
		function Item.DoClick() PlayerModelChosen("models/slashco/survivor/male_0"..i..".mdl") HidePlayermodelSelection() end
		Item:SetPos( 10 + x, 30 )
		Item:SetModel( "models/slashco/survivor/male_0"..i..".mdl" )
		
		x = x + 80
		
	end

	PMSelectFrame:SetSize( 100 + x, 100 )
	PMSelectFrame:Center()
	PMSelectFrame:MakePopup()
	PMSelectFrame:SetKeyboardInputEnabled( false )

end

function HidePlayermodelSelection()

	if ( IsValid(PMSelectFrame) ) then
		PMSelectFrame:Remove()
		PMSelectFrame = nil
	end

end

function PlayerModelChosen(mod)

	RunConsoleCommand( "cl_slashco_playermodel", mod )

end

