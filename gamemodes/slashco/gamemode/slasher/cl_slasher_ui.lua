local MainIcon

local ProgressBarBack = Material("slashco/ui/icons/slasher/progbar_back")
local ProgressBarBase = Material("slashco/ui/icons/slasher/progbar_base")
local ProgressBarIcon = Material("slashco/ui/icons/slasher/progbar_icon")
local ProgressBarIconTop = Material("slashco/ui/icons/slasher/progbar_icon2")

local SurvivorIcon = Material("slashco/ui/icons/slasher/s_survivor")
local SurvivorDeadIcon = Material("slashco/ui/icons/slasher/s_survivor_dead")

local KillIcon = Material("slashco/ui/icons/slasher/s_0")
local KillDisabledIcon = Material("slashco/ui/icons/slasher/kill_disabled")

local ChaseIcon = Material("slashco/ui/icons/slasher/s_chase")
local ChaseDisabledIcon = Material("slashco/ui/icons/slasher/chase_disabled")

local SlashID = 0

hook.Add("HUDPaint", "BaseSlasherHUD", function()

	local ply = LocalPlayer()

	if ply:Team() ~= TEAM_SLASHER then return end

		local slasherpos = ply:GetPos()
		local inchase = LocalPlayer():GetNWBool("InSlasherChaseMode")

		local cx = ScrW()/2
		local cy = ScrH()/2

		local mainiconposx = cx/20
		local mainiconposy = cy + (cy/2)

		if SlashCoSlasher[LocalPlayer():GetNWString("Slasher")].ID ~= SlashID then
			SlashID = SlashCoSlasher[LocalPlayer():GetNWString("Slasher")].ID
			MainIcon = Material("slashco/ui/icons/slasher/s_"..SlashID)
		end

		local GameProgress = LocalPlayer():GetNWInt("GameProgressDisplay")

		--[[local GasBack = Material("slashco/ui/gas_back")
		local MilkBase = Material("slashco/ui/milk_base")
		local BloodBase = Material("slashco/ui/blood_base")
		local GasTop = Material("slashco/ui/gas_top")

		local MainIcon = Material("slashco/ui/icons/slasher/s_"..SlashID)

		local GenericSlashIcon = Material("slashco/ui/icons/slasher/s_slash")

		local CrimCloneIcon = Material("slashco/ui/icons/slasher/s_12_a1")
		local CrimRage = Material("slashco/ui/icons/slasher/s_12_1")]]

		local willdrawkill = true
		local willdrawchase = true
		local willdrawmain = true

		local pacified = LocalPlayer():GetNWBool("DemonPacified")
		local blinded = LocalPlayer():GetNWBool("SlasherBlinded")

		local CanKill = LocalPlayer():GetNWBool("CanKill")
		local CanChase = LocalPlayer():GetNWBool("CanChase")

		surface.SetDrawColor(255,255,255,255)	

		if blinded then

			local black = Material("models/slashco/slashers/trollge/body")
			surface.SetMaterial(black)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		end

		local g = (GameProgress/10)
		if g_monitor == nil then g_monitor = g end

		if lerper == nil then lerper = 1 end

		if g_monitor < g then

			if g < 1 then
				surface.PlaySound("slashco/slashco_progress.mp3")
			else
				surface.PlaySound("slashco/slashco_progress_full.mp3")
			end

		end
		local gp = g

		g_monitor = g

		local pulse = 5 * math.sin( SysTime()  * ((gp+1)*3) ) * (gp*3)

		--Game Progress Bar
		surface.SetMaterial(ProgressBarBack)
		surface.DrawTexturedRect(cx - (ScrW()/4), -(cy/1.45), ScrW()/2, ScrW()/2)

		surface.SetMaterial(ProgressBarBase)
		surface.DrawTexturedRectUV( cx - (ScrW()/4)	 , 	( -(cy/1.45) ) 	, (	 ScrW()/2	) * (gp)	, ScrW()/2 ,		 0, 0, gp, 1 )

		surface.SetMaterial(ProgressBarIcon)
		surface.DrawTexturedRect( ( cx - (ScrW()/4) + ( gp * (cx)) ) - (ScrW()/40)  , (cy/10), ScrW()/20, ScrW()/20)

		surface.SetMaterial(ProgressBarIconTop)
		if g < 1 then
			surface.DrawTexturedRect( ( cx - (ScrW()/4) + ( gp * (cx)) ) - (ScrW()/60) - (pulse/2) , (cy/7.5) - (pulse/2),  ScrW()/30 + (pulse), ScrW()/30 + (pulse))
		else
			surface.DrawTexturedRect( ( cx - (ScrW()/4) + ( gp * (cx)) ) - (ScrW()/60) - (pulse/2) - 25 , (cy/7.5) - (pulse/2) - 25,  ScrW()/30 + (pulse) + 50, ScrW()/30 + (pulse) + 50)
		end

		local xoffset = 0 

		for i = 1, #SurvivorTeam do --Survivor team visualization

			for x = 1, #team.GetPlayers(TEAM_SURVIVOR) do
				if team.GetPlayers(TEAM_SURVIVOR)[x]:SteamID64() == SurvivorTeam[i].id then --The survivor is alive (is the Survivors Team)
					surface.SetMaterial(SurvivorIcon)
					surface.DrawTexturedRect((cx + (cx/1.25)) - xoffset, mainiconposy + (cy/6), ScrW()/12, ScrW()/12)
					goto SKIP
				end
			end

			surface.SetMaterial(SurvivorDeadIcon)
			surface.DrawTexturedRect((cx + (cx/1.25)) - xoffset, mainiconposy + (cy/6), ScrW()/12, ScrW()/12)

			::SKIP::

			xoffset = xoffset + 170

		end

		if pacified then
			draw.SimpleText( "(DEMON) You have been Pacified by consuming an item. You cannot Chase or Kill and your senses are dulled.", "ItemFontTip", ScrW()/2, ScrH()/4, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end

		--Call for the HUD
		local willdrawkill, willdrawchase, willdrawmain = SlashCoSlasher[LocalPlayer():GetNWString("Slasher")].UserInterface(cx, cy, mainiconposx, mainiconposy)

		--Bababooey \/ \/ \/

		--[[if SlashID ~= 1 then goto sid end

		if SlashID ~= 4 then goto thirsty end
		do
			local AmogusSurvivor = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a1")
			local AmogusFuel = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a2")
			
			local is_survivor = LocalPlayer():GetNWBool("AmogusSurvivorDisguise")
			local is_fuel = LocalPlayer():GetNWBool("AmogusFuelDisguise")
			local is_disguised = LocalPlayer():GetNWBool("AmogusDisguised")

			willdrawmain = true

			if is_survivor then 
				surface.SetMaterial(AmogusSurvivor)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
				willdrawmain = false
				if LocalPlayer():GetVelocity():Length() < 1 then
					surface.SetMaterial(AmogusSurvivor)
					surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
					draw.SimpleText( "M1 - Kill (Sneak)", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

					willdrawkill = false
				else
					willdrawkill = true
				end
			end

			if is_fuel then 
				surface.SetMaterial(AmogusFuel)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
				willdrawmain = false
			end

			if not is_disguised then
				draw.SimpleText( "R - Disguise as Survivor", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

				surface.SetMaterial(AmogusFuel)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
				draw.SimpleText( "F - Disguise as Fuel", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

			else
				draw.SimpleText( "R - Reveal yourself", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
			end

		end

		--Amogus /\ /\ /\

		::thirsty::

		--Thirsty \/ \/ \/
		if SlashID ~= 5 then goto male07 end
do

		local milk = 1 - (V3/100)

		surface.SetMaterial(GasBack)
		surface.DrawTexturedRect((ScrW()/2) - ScrW()/16, (ScrH()/1.25)  - ScrW()/16, ScrW()/8, ScrW()/8)

		surface.SetMaterial(MilkBase)
		surface.DrawTexturedRectUV((ScrW()/2) - ScrW()/16	,		(ScrH()/1.25) - (		(ScrW()/8) * (1-milk) 	)	+	ScrW()/16, 	ScrW()/8	, (ScrW()/8 ) * (1-milk)		,0, milk, 1, 1 )

		surface.SetMaterial(GasTop)
		surface.DrawTexturedRect((ScrW()/2) - ScrW()/16, (ScrH()/1.25)  - ScrW()/16, ScrW()/8, ScrW()/8)

		draw.SimpleText( "R - Drink Milk (Drank: "..V1..")", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
end
		--Thirsty /\ /\ /\

		::male07::

		--Male07 \/ \/ \/
		if SlashID ~= 6 then goto tyler end
do

		local MaleSpecter = Material("slashco/ui/icons/slasher/s_"..SlashID.."_s0")
		local MaleMonster = Material("slashco/ui/icons/slasher/s_"..SlashID.."_s2")
					
		if V1 ~= 0 then
			draw.SimpleText( "R - Unpossess Vessel", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "R - Possess Vessel", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

		if V1 ~= 1 then
			willdrawmain = false

			if V1 == 0 then
				surface.SetMaterial(MaleSpecter)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
			end

			if V1 == 2 then
				surface.SetMaterial(MaleMonster)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 

				willdrawkill = false

				surface.SetMaterial(GenericSlashIcon)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M1 - Slash", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

			end
		else
			willdrawmain = true
		end

end
		--Male07 /\ /\ /\

		::tyler::
		if SlashID ~= 7 then goto borgmire end
do

	local DestroyerIcon = Material("slashco/ui/icons/slasher/s_"..SlashID.."_s1")
	local name = ", The Creator"

	if V1 < 1 then
		draw.SimpleText( "R - Manifest", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	elseif V1 == 1 then
		draw.SimpleText( "(Wait until you're found or you become Destroyer)", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	end

	if V1 > 1 then

		name = ", The Destroyer"

		willdrawmain = false

		surface.SetMaterial(DestroyerIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 

	end

	if V1 > 2 then

		surface.SetMaterial(DestroyerIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
		draw.SimpleText( "M1 - Destroy", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

		willdrawkill = false

	end

	SlashName = "Tyler"..name

	willdrawchase = false

end

	::borgmire::
	if SlashID ~= 8 then goto manspider end
do

	local PunchIcon = Material("slashco/ui/icons/slasher/s_punch")
	local ThrowIcon = Material("slashco/ui/icons/slasher/s_punch")

	willdrawkill = false

	surface.SetMaterial(PunchIcon)
	surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
	draw.SimpleText( "M1 - Punch", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

	surface.SetMaterial(ThrowIcon)
	surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
	draw.SimpleText( "F - Throw", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

end

	::manspider::
	if SlashID ~= 9 then goto watcher end
do

	local LeapIcon = Material("slashco/ui/icons/slasher/s_punch")

	local is_nested = LocalPlayer():GetNWBool("ManspiderNested")

	if V1 ~= "" then

		if IsValid( player.GetBySteamID64( V1 ) ) then

			draw.SimpleText( "Your Prey: "..player.GetBySteamID64( V1 ):Name(), "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/6), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

		end

		for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

			local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

			if ply:SteamID64() == V1 and not ply:GetNWBool("BGoneSoda") then
				ply:SetMaterial( "lights/white" )
				ply:SetColor( Color( 255, 0, 0, 255 ) )
				ply:SetRenderMode( RENDERMODE_TRANSCOLOR )
			end

			if ply:SteamID64() ~= V1 then
				ply:SetMaterial( "" )
				ply:SetColor( Color( 255, 255, 255, 255 ) )
				ply:SetRenderMode( RENDERMODE_TRANSCOLOR )
			end

		end

	else
		for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

			local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

			if ply:GetMaterial() == "lights/white" then
				ply:SetMaterial( "" )
				ply:SetColor( Color( 255, 255, 255, 255 ) )
				ply:SetRenderMode( RENDERMODE_TRANSCOLOR )
			end

		end
	end

	if not is_nested then
		if V1 == "" then draw.SimpleText( "R - Nest", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) end
	else

		if V3 < 100 then
			draw.SimpleText( "(Wait for prey to come)", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "R - Abandon Nest", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

	end

	if inchase then

		surface.SetMaterial(LeapIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
		draw.SimpleText( "F - Leap", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

	end

end

	::watcher::
	if SlashID ~= 10 then goto abomignat end
do

	local SurveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
	local SurveyIcon = Material("slashco/ui/icons/slasher/s_10_a1")

	if LocalPlayer():GetNWBool("WatcherWatched") then
		draw.SimpleText( "YOU ARE BEING WATCHED. . .", "ItemFontTip", ScrW()/2, ScrH()/4, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	if LocalPlayer():GetNWBool("WatcherStalking") then
		draw.SimpleText( "OBSERVING A SURVIVOR. . .", "ItemFontTip", ScrW()/2, ScrH()/4, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

		local survivor = team.GetPlayers(TEAM_SURVIVOR)[i]

		if survivor:GetNWBool("SurvivorWatcherSurveyed") then

			local pos = (survivor:GetPos()+Vector(0,0,60)):ToScreen()

			if pos.visible then
				surface.SetMaterial(SurveyNoticeIcon)
				surface.DrawTexturedRect(pos.x - ScrW()/32, pos.y - ScrW()/32, ScrW()/16, ScrW()/16)
			end

		end

	end

	if V2 < 1 and not LocalPlayer():GetNWBool("WatcherRage") then 
		draw.SimpleText( "R - Survey", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
	else
		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
	end

	if GameProgress > (10 - (V4/25)) and not LocalPlayer():GetNWBool("WatcherRage") and #team.GetPlayers(TEAM_SURVIVOR) > 1 then
		surface.SetMaterial(SurveyIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
		draw.SimpleText( "F - Full Surveillance", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	else
		surface.SetMaterial(SurveyIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	end

end
	::abomignat::
	if SlashID ~= 11 then goto criminal end
do
	local is_crawling = LocalPlayer():GetNWBool("AbomignatCrawling")

	willdrawkill = false
	if not is_crawling and V1 < 0.1 then
		surface.SetMaterial(GenericSlashIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
		draw.SimpleText( "M1 - Slash Charge", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

		surface.SetMaterial(GenericSlashIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
		draw.SimpleText( "F - Lunge", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	else
		surface.SetMaterial(KillDisabledIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

		surface.SetMaterial(KillDisabledIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	end

	if not is_crawling then 
		draw.SimpleText( "R - Start Crawling", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
	else
		draw.SimpleText( "R - Stop Crawling", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
	end
end
	::criminal::
	if SlashID ~= 12 then goto freesmiley end
do
	willdrawchase = false
	local clones_active = LocalPlayer():GetNWBool("CriminalCloning")
	local rage_active = LocalPlayer():GetNWBool("CriminalRage")

	surface.SetMaterial(CrimCloneIcon)
	surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
	if not clones_active then
		draw.SimpleText( "M2 - Summon Clones", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	else
		draw.SimpleText( "M2 - Unsummon Clones", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	end

	if rage_active then
		surface.SetMaterial(CrimRage)
		surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
		willdrawmain = false
	end

	if not rage_active then
		surface.SetMaterial(CrimRage)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
		if GameProgress > 6 then
			draw.SimpleText( "F - Rage", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end
	end
end
	::freesmiley::
	if SlashID ~= 13 then goto leuonard end
do

	local ZanyIcon = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a1")
	local PensiveIcon = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a2")
	local SurveyNoticeIcon = Material("slashco/ui/particle/icon_survey")

	if V1 < 0.1 then 
		draw.SimpleText( "R - Switch your Deal", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT)

		if V2 == 0 then
			surface.SetMaterial(ZanyIcon)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			draw.SimpleText( "F - Deal a Zany", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			surface.SetMaterial(PensiveIcon)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			draw.SimpleText( "F - Deal a Pensive", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

	else
		surface.SetMaterial(KillDisabledIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 

		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
	end

	for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

		local survivor = team.GetPlayers(TEAM_SURVIVOR)[i]

		if survivor:GetNWBool("MarkedBySmiley") then

			local pos = (survivor:GetPos()+Vector(0,0,60)):ToScreen()

			if pos.visible then
				surface.SetMaterial(SurveyNoticeIcon)
				surface.DrawTexturedRect(pos.x - ScrW()/32, pos.y - ScrW()/32, ScrW()/16, ScrW()/16)
			end

		end

	end

end
::leuonard::
if SlashID ~= 14 then goto next end
do

surface.SetDrawColor( 0, 0, 0)
surface.DrawRect( cx-200, cy +ScrH()/4, 400, 25 )

local b_pad = 6

local rape_val = V1

surface.SetDrawColor( 255, 0, 0)
surface.DrawRect( cx-200+(b_pad/2),(b_pad/2)+cy +ScrH()/4, (400-b_pad)*(rape_val/100), 25-b_pad )

draw.SimpleText( "RAPE", "ItemFontTip", cx-300, cy +ScrH()/4 , Color( 255, 0, 0, 255 ), TEXT_ALIGN_TOP, TEXT_ALIGN_RIGHT ) 
draw.SimpleText( math.floor(rape_val).." %", "ItemFontTip", cx+220, cy +ScrH()/4 , Color( 255, 0, 0, 255 ), TEXT_ALIGN_TOP, TEXT_ALIGN_RIGHT ) 

end

::next::]]
	--Slasher-Shared function \/ \/ \/ 

	--Slasher Main Icon

	local SlashName = SlashCoSlasher[LocalPlayer():GetNWString("Slasher")].Name

	draw.SimpleText( SlashName, "LobbyFont2", mainiconposx+(cx/4), mainiconposy+(mainiconposy/4.25), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

	if not willdrawmain then goto skipmain end

	surface.SetMaterial(MainIcon)
	surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8)
	::skipmain::

	if not willdrawkill then goto skipkill end

	if CanKill then
		surface.SetMaterial(KillIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
		draw.SimpleText( "M1 - Kill Survivor", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	else
		surface.SetMaterial(KillDisabledIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	end

	::skipkill::

	if not willdrawchase then goto skipchase end

	if CanChase then
		surface.SetMaterial(ChaseIcon)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
		if not inchase then
			draw.SimpleText( "M2 - Start Chasing", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "M2 - Stop Chasing", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

			--[[if ChaseTick > (ChaseDur / 2) then 
				draw.SimpleText( "Look at a Survivor to maintain the chase!", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2.5), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
			end]]

		end

	else
		surface.SetMaterial(ChaseDisabledIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
		draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
	end

		::skipchase::
	
end)
