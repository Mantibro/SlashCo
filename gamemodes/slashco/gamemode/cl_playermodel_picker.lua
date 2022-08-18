include( "ui/fonts.lua" )

function DrawThePlayermodelSelectorBox()

	if ( IsValid( PMSelectFrame ) ) then return end
	
	-- Slasher selectionBox
	PMSelectFrame = vgui.Create( "DFrame" )
	PMSelectFrame:SetTitle( "Choose your Playermodel" )

	--local x = 0
	--local y = 0
	for c = 0, 2 do
		for i = 0, 2 do

			local Item = vgui.Create( "SpawnIcon", PMSelectFrame )
			local val = i+c+1
			function Item.DoClick() PlayerModelChosen("models/slashco/survivor/male_0"..val..".mdl") HidePlayermodelSelection() end
			Item:SetPos( 10 + i*80, 30 + c*80 )
			Item:SetModel( "models/slashco/survivor/male_0"..val..".mdl" )

			--x = x + 80

		end
		--y = y + 80
	end

	PMSelectFrame:SetSize( 240, 260 )
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

