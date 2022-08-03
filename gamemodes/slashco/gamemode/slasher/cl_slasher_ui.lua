hook.Add("HUDPaint", "BaseSlasherHUD", function()

	local ply = LocalPlayer()

	if ply:Team() == TEAM_SLASHER then

		--Fallback	
		if SlashID == nil then
			GameProgress = 0
			SurvivorTeam = {}
			SlashID = 1
			SlashName = "ERROR"
			Eyesight = 5
			PerceptionReal = 1
			CanChase = false
			ChaseRange = 500
			CanKill = false
			ChaseDur = 10.0
			ChaseTick = SlasherTable[lid].CurrentChaseTick
		end

		--Range (in units) = 2.5 * SurvivorSpeed * PerceptionReal
		local slasherpos = ply:GetPos()
		local inchase = LocalPlayer():GetNWBool("InSlasherChaseMode")

		local cx = ScrW()/2
		local cy = ScrH()/2

		local mainiconposx = cx/20
		local mainiconposy = cy + (cy/2)

		local GasBack = Material("slashco/ui/gas_back")
		local MilkBase = Material("slashco/ui/milk_base")
		local BloodBase = Material("slashco/ui/blood_base")
		local GasTop = Material("slashco/ui/gas_top")

		local ProgressBarBack = Material("slashco/ui/icons/slasher/progbar_back")
		local ProgressBarBase = Material("slashco/ui/icons/slasher/progbar_base")
		local ProgressBarIcon = Material("slashco/ui/icons/slasher/progbar_icon")
		local ProgressBarIconTop = Material("slashco/ui/icons/slasher/progbar_icon2")

		local MainIcon = Material("slashco/ui/icons/slasher/s_"..SlashID)

		local GenericSlashIcon = Material("slashco/ui/icons/slasher/s_slash")

		local KillIcon = Material("slashco/ui/icons/slasher/s_0")
		local KillDisabledIcon = Material("slashco/ui/icons/slasher/kill_disabled")

		local ChaseIcon = Material("slashco/ui/icons/slasher/s_chase")
		local ChaseDisabledIcon = Material("slashco/ui/icons/slasher/chase_disabled")

		local SurvivorIcon = Material("slashco/ui/icons/slasher/s_survivor")
		local SurvivorDeadIcon = Material("slashco/ui/icons/slasher/s_survivor_dead")

		local willdrawkill = true
		local willdrawchase = true
		local willdrawmain = true

		local pacified = LocalPlayer():GetNWBool("DemonPacified")

		surface.SetDrawColor(255,255,255,255)	

		local g = (GameProgress/10)
		if g_monitor == nil then g_monitor = g end

		if lerper == nil then lerper = 1 end

		if g_monitor < g then

			if g < 10 then
				surface.PlaySound("slashco/slashco_progress.mp3")
			else
				surface.PlaySound("slashco/slashco_progress_full.mp3")
			end

			lerper = 0.02

		end

		if lerper < 1 then lerper = lerper + ( 0.01 + ( 0.005 / lerper ) ) end

		local gp = Lerp( lerper, 0, g )

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
		--Bababooey \/ \/ \/

		if SlashID != 1 then goto sid end
		do

		local invis =  LocalPlayer():GetNWBool("BababooeyInvisibility")

		local BababooeyInvisible = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a1")
		local BababooeyInactiveClone = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a2_1")
		local BababooeyActiveClone = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a2")

		if #ents.FindByClass( "sc_babaclone") > 0 then
			surface.SetMaterial(BababooeyInactiveClone)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			draw.SimpleText( "Clone Set", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			surface.SetMaterial(BababooeyActiveClone)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.33), ScrW()/16, ScrW()/16)
			draw.SimpleText( "F - Set Clone", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end
		

		if invis then 
			surface.SetMaterial(BababooeyInvisible)
			surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
		end

		willdrawmain = not invis

		draw.SimpleText( "R - Toggle Invisibility", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

		end
		--Bababooey /\ /\ /\
		::sid::

		--Sid \/ \/ \/
		if SlashID != 2 then goto trollge end
		do
		local SidGunInactive = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a1_disabled")
		local SidGunUnavailable = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a1_unavailable")
		local SidGun = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a1")

		local SidGunShoot = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a2")
		local SidGunAim = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a3")

		local sid_has_gun = LocalPlayer():GetNWBool("SidGun")
		local sid_equipped_gun = LocalPlayer():GetNWBool("SidGunEquipped")
		local is_aiming_gun =  LocalPlayer():GetNWBool("SidGunAimed")

		if GameProgress < 5 then
			surface.SetMaterial(SidGunInactive)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		elseif not sid_has_gun then
			surface.SetMaterial(SidGunUnavailable)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			draw.SimpleText( "F - Equip Gun", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

			draw.SimpleText( "Uses: "..V1, "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.5), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			surface.SetMaterial(SidGun)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/1.333), ScrW()/16, ScrW()/16)
			if not is_aiming_gun then 
				draw.SimpleText( "F - Unequip Gun", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
			else
				draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/1.33), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT ) 
			end
		end

		willdrawkill = not sid_equipped_gun
		willdrawchase = not sid_equipped_gun

		if sid_equipped_gun then
			--icons for shooting/aiming

			if not is_aiming_gun then
				surface.SetMaterial(SidGunShoot)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M2 - Aim", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

				surface.SetMaterial(SidGunAim)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
				draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
			else
				surface.SetMaterial(SidGunShoot)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M2 - Lower Gun", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )

				surface.SetMaterial(SidGunAim)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M1 - Shoot", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
			end

		end

		if not sid_has_gun then
			draw.SimpleText( "R - Eat Cookie", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

		end
		--Sid /\ /\ /\

		::trollge::
		--Trollge \/ \/ \/
		if SlashID != 3 then goto amogus end
		do
			local TrollgeStage1 = Material("slashco/ui/icons/slasher/s_"..SlashID.."_s1")
			local TrollgeStage2 = Material("slashco/ui/icons/slasher/s_"..SlashID.."_s2")
			local TrollgeClaw = Material("slashco/ui/icons/slasher/s_"..SlashID.."_a1")
			
			willdrawchase = false

			if V1 == 0 then
				willdrawkill = false

				surface.SetMaterial(TrollgeClaw)
				surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/4), ScrW()/16, ScrW()/16)
				draw.SimpleText( "M1 - Claw", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/4), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
			else
				willdrawkill = true
			end

			if V1 == 1 then
				surface.SetMaterial(TrollgeStage1)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
				willdrawmain = false
			elseif V1 == 2 then
				surface.SetMaterial(TrollgeStage2)
				surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW()/8, ScrW()/8) 
				willdrawmain = false
			end

		end

		for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

			local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

			if V1 < 2 then

				ply:SetMaterial( "models/debug/debugwhite" )
				ply:SetColor( Color( 255, 255, 255, ply:GetVelocity():Length() * (1 + (V1*2)) ) ) 
				ply:SetRenderMode( RENDERMODE_TRANSCOLOR )

			else

				ply:SetMaterial( "models/debug/debugwhite" )
				ply:SetColor( Color( 255, 255, 255, 255 ) )
				ply:SetRenderMode( RENDERMODE_TRANSCOLOR )

			end
		end

		--Trollge /\ /\ /\

		::amogus::
		--Amogus \/ \/ \/

		if SlashID != 4 then goto thirsty end
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
		if SlashID != 5 then goto male07 end
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
		if SlashID != 6 then goto tyler end
do

		local MaleSpecter = Material("slashco/ui/icons/slasher/s_"..SlashID.."_s0")
		local MaleMonster = Material("slashco/ui/icons/slasher/s_"..SlashID.."_s2")
					
		if V1 != 0 then
			draw.SimpleText( "R - Unpossess Vessel", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "R - Possess Vessel", "ItemFontTip", mainiconposx+(cx/4), mainiconposy+(mainiconposy/10), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

		if V1 != 1 then
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
		if SlashID != 7 then goto borgmire end
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
	if SlashID != 8 then goto theking end
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

	::theking::

		--Slasher-Shared function \/ \/ \/ 

		--Slasher Main Icon

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

				if ChaseTick > (ChaseDur / 2) then 
					draw.SimpleText( "Look at a Survivor to maintain the chase!", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2.5), Color( 255, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
				end

			end

		else
			surface.SetMaterial(ChaseDisabledIcon)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy/2), ScrW()/16, ScrW()/16)
			draw.SimpleText( "-Unavailable-", "ItemFontTip", mainiconposx+(cx/8), mainiconposy - (cy/2), Color( 100, 0, 0, 255 ), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
		end

		::skipchase::

		local PerceptionReal = Perception

		if inchase then PerceptionReal = 0 end

		local StepNotice = Material("slashco/ui/particle/step_notice")
		if timeSinceLast == nil then timeSinceLast = 0 end
		timeSinceLast = timeSinceLast + FrameTime()/3
		if timeSinceLast > 0.2 then timeSinceLast = 0 end 
		--Survivor Step Notice
		for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

			local survivor = team.GetPlayers(TEAM_SURVIVOR)[i]

			local vel = (survivor:GetVelocity()):Length()

			local range = 3 * vel * PerceptionReal

			local pos = survivor:GetPos()

			local em = ParticleEmitter(pos)
    		local part = em:Add(	StepNotice,	pos	) 

    		if part and timeSinceLast < 0.01 and  (  slasherpos	):Distance(	pos	) < range and survivor:IsOnGround() then 
          		part:SetColor(255,255,255,math.random(255))
          		part:SetVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):GetNormal() * 20)
          		part:SetDieTime(1)
          		part:SetLifeTime(0)
          		part:SetStartSize(25)
          		part:SetEndSize(0)
    		end

			em:Finish()
			

		end

		--Step Decoy Step Notice
		for i = 1, #ents.FindByClass( "sc_stepdecoy" ) do

			local boot = ents.FindByClass( "sc_stepdecoy" )[i]

			local vel = 300

			local range = 3 * vel * PerceptionReal

			local offsetpos = Vector(math.random(-50, 50),math.random(-50, 50),0)

			local pos = boot:GetPos() + offsetpos

			local em = ParticleEmitter(pos)
    		local part = em:Add(	StepNotice,	pos	) 

    		if part and timeSinceLast < 0.01 and  (  slasherpos	):Distance(	pos	) < range then 
          		part:SetColor(255,255,255,math.random(255))
          		part:SetVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):GetNormal() * 20)
          		part:SetDieTime(1)
          		part:SetLifeTime(0)
          		part:SetStartSize(25)
          		part:SetEndSize(0)
    		end
			
			em:Finish()

		end

	end
	
end)

hook.Add( "Think", "Slasher_Vision_Light", function()

	if LocalPlayer():Team() != TEAM_SLASHER then return end

	--Eyesight - an arbitrary range from 1 - 10 which decides how illuminated the Slasher 'vision is client-side. (1 - barely any illumination, 10 - basically fullbright ) 

	local dlight = DynamicLight( LocalPlayer():EntIndex() )
	if ( dlight ) then
		dlight.pos = LocalPlayer():GetShootPos()
		dlight.r = 50 + (Eyesight * 2)
		dlight.g = 50 + (Eyesight * 2)
		dlight.b = 50 + (Eyesight * 2)
		dlight.brightness = Eyesight / 50
		dlight.Decay = 1000
		dlight.Size = 250 * Eyesight
		dlight.DieTime = CurTime() + 1
	end
end )
hook.Add("RenderScreenspaceEffects", "SlasherVision", function()

	if LocalPlayer():Team() != TEAM_SLASHER then return end

	local tab = {
		["$pp_colour_addr"] = 0.01,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0.1,
		["$pp_colour_contrast"] = 1 + Eyesight / 5,
		["$pp_colour_colour"] = Eyesight / 5,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}

	DrawColorModify( tab ) --Draws Color Modify effect
end )