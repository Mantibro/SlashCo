include( "ui/fonts.lua" )

function SelectThisOffering(offerID)

	if LocalPlayer():SteamID64() ~= readtable_offering.ply then return end

	if ( IsValid(OfferSelectFrame) ) then
		OfferSelectFrame:Remove()
		OfferSelectFrame = nil
	end

	SelectedOffering = offerID

	DrawTheOfferSelectorBox()

end

net.Receive("mantislashcoStartOfferingPicking", function()

	readtable_offering = net.ReadTable()

	if LocalPlayer():SteamID64() ~= readtable_offering.ply then return end

	DrawTheOfferSelectorBox()

end)

function DrawTheOfferSelectorBox()

	if ( IsValid( OfferSelectFrame ) ) then return end

	if LocalPlayer():SteamID64() ~= readtable_offering.ply then return end
	
	-- Slasher selectionBox
	OfferSelectFrame = vgui.Create( "DFrame" )
	OfferSelectFrame:SetTitle( "Make an Offering" )

	if SelectedOffering == nil then SelectedOffering = 1 end

	local y = 30
	for i = 1, #SCInfo.Offering do
	
		local Item = vgui.Create( "DButton", OfferSelectFrame )
		function Item.DoClick() SelectThisOffering(i) end
		Item:SetPos( 10, y )
		Item:SetSize( 200, 30 )
		Item:SetText( SCInfo.Offering[i].Name.." Offering" )
		Item:SetFont( "MenuFont1" )

		if SelectedOffering == i  then
			Item:SetDisabled( true )
		end
			
		y = y + 40
		
	end

	local confirmselect = vgui.Create( "DButton", OfferSelectFrame )
	function confirmselect.DoClick() OfferingChosen(SelectedOffering) HideOfferingSelection() end
	confirmselect:SetPos( 440, y + 150 )
	confirmselect:SetSize( 150, 40 )
	confirmselect:SetText( "Confirm" )
	confirmselect:SetFont( "MenuFont1" )

	if SelectedOffering == 0  then
		confirmselect:SetDisabled( true )
	end


	-- Model panel
	local mdl = vgui.Create("DModelPanel", OfferSelectFrame)
	mdl:SetPos(200, 30)
	mdl:SetSize(350, 200)
	mdl:SetLookAt(Vector(0, 0, 10))
	mdl:SetFOV(40)

	local ILabel = vgui.Create( "DLabel", OfferSelectFrame )
	ILabel:SetPos( 230, 230 )
	ILabel:SetSize(450, 100)
	ILabel:SetText( " " )
	ILabel:SetFont( "MenuFont2" )
	ILabel:SetAutoStretchVertical( true )

	local IDesc = vgui.Create( "DLabel", OfferSelectFrame )
	IDesc:SetPos( 230, 260 )
	IDesc:SetSize(450, 100)
	IDesc:SetText(  " " )
	IDesc:SetFont( "MenuFont1" )
	IDesc:SetAutoStretchVertical( true )


	mdl:SetModel("models/slashco/other/offerings/o_"..SelectedOffering..".mdl")
	mdl:SetCamPos(Vector(60, 0, 0))

	if SelectedOffering ~= nil and SelectedOffering > 0 then
		ILabel:SetText( SCInfo.Offering[SelectedOffering].Name.." Offering" )
		IDesc:SetText( SCInfo.Offering[SelectedOffering].Description )
	end


	OfferSelectFrame:SetSize( 600, y + 200 )
	OfferSelectFrame:Center()
	OfferSelectFrame:MakePopup()
	OfferSelectFrame:SetKeyboardInputEnabled( false )

end

function HideOfferingSelection()

	if ( IsValid(OfferSelectFrame) ) then
		OfferSelectFrame:Remove()
		OfferSelectFrame = nil
		SelectedOffering = 1
	end

end

function OfferingChosen(offerID)

	if offerID == 4 and #team.GetPlayers(TEAM_SPECTATOR) < 1 then

		LocalPlayer():ChatPrint("This Offering is currently unavailable.")

		return
	end

	net.Start("mantislashcoBeginOfferingVote")
	net.WriteTable({ply = LocalPlayer():SteamID64(), id = offerID})
	net.SendToServer()

	DrawTheOfferSelectorBox()

end

