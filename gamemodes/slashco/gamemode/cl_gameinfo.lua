include( "ui/fonts.lua" )

hook.Add("HUDPaint", "GameInfo_Info", function()

	if LocalPlayer():Team() ~= TEAM_LOBBY and LocalPlayer():Team() ~= TEAM_SPECTATOR  then return end

	draw.SimpleText("[F6] GAME INFO" , "TVCD", ScrW() * 0.975, (ScrH() * 0.95), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
end)

hook.Add("PlayerButtonDown", "GameInfo", function(ply, key) 

	if ply ~= LocalPlayer() then return end

	if LocalPlayer():Team() ~= TEAM_LOBBY and LocalPlayer():Team() ~= TEAM_SPECTATOR  then return end

	if key == 97  then 
		DrawTheGameInfoBox()
	end

end)

function SelectInfo(infotype)

	if ( IsValid(GameInfo) ) then
		GameInfo:Remove()
		GameInfo = nil
	end

	CurrentDisplayedInfo = infotype

	DrawTheGameInfoBox()

end

function DrawTheGameInfoBox()

	if ( IsValid( GameInfo ) ) then return end
	
	-- Slasher selectionBox
	GameInfo = vgui.Create( "DFrame" )
	GameInfo:SetTitle( "SlashCo" )

	if CurrentDisplayedInfo == nil then CurrentDisplayedInfo = -1 end

	local SurvivorButton = vgui.Create( "DButton", GameInfo )
	function SurvivorButton.DoClick() SelectInfo(0) end
	SurvivorButton:SetPos( 400, 40 )
	SurvivorButton:SetSize( 250, 50 )
	SurvivorButton:SetText( "Survivor" )
	SurvivorButton:SetFont( "MenuFont1" )

	local SlasherButton = vgui.Create( "DButton", GameInfo )
	function SlasherButton.DoClick() SelectInfo(1) end
	SlasherButton:SetPos( 700, 40 )
	SlasherButton:SetSize( 250, 50 )
	SlasherButton:SetText( "Slasher" )
	SlasherButton:SetFont( "MenuFont1" )

	local mat = vgui.Create("Material", GameInfo)
	mat:SetPos(40, -50)
	mat:SetSize(20, 20)
	mat:SetMaterial("slashco/ui/slashco_score")

	local MainInfo = vgui.Create( "DLabel", GameInfo )
	MainInfo:SetPos( 40, 250 )
	MainInfo:SetSize(1200, 700)
	--MainInfo:SetText( SCInfo.Main.Base )
	MainInfo:SetFont( "MenuFont1" )
	MainInfo:SetAutoStretchVertical( true )

	if CurrentDisplayedInfo == 0 then

		MainInfo:SetText( SCInfo.Main.Base )

	else

		MainInfo:SetText( SCInfo.Main.SlasherBase )

	end


	local IDesc = vgui.Create( "DLabel", GameInfo )
	IDesc:SetPos( 180, 260 )
	IDesc:SetSize(600, 200)
	IDesc:SetText(  " " )
	IDesc:SetFont( "MenuFont1" )
	IDesc:SetAutoStretchVertical( true )

	GameInfo:SetSize( 1200, 800 )
	GameInfo:Center()
	GameInfo:MakePopup()
	GameInfo:SetKeyboardInputEnabled( false )

end
