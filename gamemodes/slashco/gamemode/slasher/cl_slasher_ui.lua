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
