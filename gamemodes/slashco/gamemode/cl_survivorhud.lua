--include( "globals.lua" )
include( "ui/fonts.lua" )
--include( "ui/data_info.lua" )

hook.Add("HUDPaint", "SurvivorHUD", function()

	local ply = LocalPlayer()
	
	if ply:Team() == TEAM_SURVIVOR then

		local ITEM0 = Material("slashco/ui/icons/items/item_0")
		local ITEM1 = Material("slashco/ui/icons/items/item_1")
		local ITEM2 = Material("slashco/ui/icons/items/item_2")
		local ITEM3 = Material("slashco/ui/icons/items/item_3")
		local ITEM4 = Material("slashco/ui/icons/items/item_4")
		local ITEM5 = Material("slashco/ui/icons/items/item_5")
		local ITEM6 = Material("slashco/ui/icons/items/item_6")
		local ITEM7 = Material("slashco/ui/icons/items/item_7")
		local ITEM8 = Material("slashco/ui/icons/items/item_8")
		local ITEM9 = Material("slashco/ui/icons/items/item_9")
		local ITEM10 = Material("slashco/ui/icons/items/item_10")
		local ITEM11 = Material("slashco/ui/icons/items/item_11")

		local ITEM2_99 = Material("slashco/ui/icons/items/item_2_99")

		local hp = ply:Health()

		if Gasseous == nil then Gasseous = 0 end
		if IsGassing == nil then IsGassing = false end
		if HeldItem == nil then HeldItem = 0 end

		local showLow = 0

		local HealthBack = Material("slashco/ui/health_back")
		local HealthBase = Material("slashco/ui/health_base")
		local HealthOver = Material("slashco/ui/health_over")
		local HealthTop = Material("slashco/ui/health_top")
		local HealthTopLow = Material("slashco/ui/health_top_low")

		local GasBack = Material("slashco/ui/gas_back")
		local GasBase = Material("slashco/ui/gas_base")
		local GasTop = Material("slashco/ui/gas_top")

		local healthx = ScrW()/25
		local healthy = ScrH() - (ScrH()/3.5)
		local healthsize = ScrH()/4

		local itemx = ScrW() - (ScrW()/7)
		local itemy = ScrH() - (ScrH()/3.5)
		local itemsize = ScrH()/5

		local ints = 1.5 + (1 - (hp / 100) )

		local a = 1 + (CurTime() * ints * 6)

		local hpt = 0.86 - (hp/100)*0.74 --Deadzone: 0.12 , 0.86

		local hptover = 0.86 - ((hp-100)/100)*0.74 --Deadzone: 0.12 , 0.86

		local pouringas = 0

		net.Receive( "mantislashcoGasPourProgress", function( )

			local ReceivedTable = net.ReadTable()

			IsGassing = false

			if ReceivedTable != nil then

				local man = ReceivedTable.id
				local prog = ReceivedTable.prog

				if man == LocalPlayer():SteamID64() then

					if prog <= 0 or prog > 12.98 then 
						IsGassing = false
					else 
						IsGassing = true
					end

				else
					IsGassing = false
				end

				Gasseous = 1 - (prog / 13)
				if Gasseous == 0 or Gasseous > 13 then IsGassing = false end

			else

				IsGassing = false

			end

		end)

		net.Receive( "mantislashcoGasPourEnded", function( )

			local ReceivedTable = net.ReadTable()

			if ReceivedTable != nil then
				if man == LocalPlayer():SteamID64() then
					IsGassing = false
				end
			end

		end)

		local gas = Gasseous

		if IsGassing == true then pouringas = 1 else pouringas = 0 end

		if not input.IsButtonDown( 15 ) then IsGassing = false end

		if hp > 100 then hpt = 0.12 end
		if hp <= 100 then hptover = 0.86 end

		if hp < 40 then showLow = 1 else showLow = 0 end

		surface.SetDrawColor(255,255,255,255)	

		surface.SetMaterial(HealthBack)
		surface.DrawTexturedRect(healthx, healthy, healthsize, healthsize)

		surface.SetMaterial(HealthBase)
		surface.DrawTexturedRectUV( healthx,healthy + healthsize*hpt, healthsize, healthsize * (1-hpt),		 0, hpt, 1, 1 )

		surface.SetMaterial(HealthOver)
		surface.DrawTexturedRectUV(healthx,healthy + healthsize*hptover, healthsize, healthsize * (1-hptover),		 0, hptover, 1, 1 )

		surface.SetMaterial(HealthTop)
		surface.DrawTexturedRect(	healthx - math.sin(a)*ints*3	, 	healthy - math.sin(a)*ints*3	, healthsize + math.sin(a)*ints*6, healthsize + math.sin(a)*ints*6)

		surface.SetMaterial(HealthTopLow)
		surface.DrawTexturedRect(	healthx - math.sin(a)*ints*3	, 	healthy - math.sin(a)*ints*3	,showLow * (healthsize + math.sin(a)*ints*6),showLow * (healthsize + math.sin(a)*ints*6))

		surface.SetMaterial(GasBack)
		surface.DrawTexturedRect((ScrW()/2) - ScrW()/16, (ScrH()/2)  - ScrW()/16, pouringas*ScrW()/8, ScrW()/8)

		surface.SetMaterial(GasBase)
		surface.DrawTexturedRectUV((ScrW()/2) - ScrW()/16	,		(ScrH()/2) - (		(ScrW()/8) * (1-gas) 	)	+	ScrW()/16, 	ScrW()/8	, pouringas*(ScrW()/8 ) * (1-gas)		,0, gas, 1, 1 )

		surface.SetMaterial(GasTop)
		surface.DrawTexturedRect((ScrW()/2) - ScrW()/16, (ScrH()/2)  - ScrW()/16, ScrW()/8, pouringas*ScrW()/8)

		--Item Display

		net.Receive("mantislashcoGiveItemData", function()

			t = net.ReadTable()

			for i = 1, #t do
				if t[i].steamid == LocalPlayer():SteamID64() then
					HeldItem = t[i].itemid
				end
			end 
		
		end)


		net.Receive("mantislashcoSendGlobalInfoTable", function()

			SCInfo = net.ReadTable()
		
		end)

		local item_name = ""
		local item_droppable = false
		local item_usable = false
		local item_mat = ITEM0

		if HeldItem == 0 then
			item_mat = ITEM0
			item_name = ""
			item_droppable = false
			item_usable = false
		elseif HeldItem == 1 then
			item_mat = ITEM1
			item_name = "Fuel Can"
			item_droppable = true
			item_usable = false
		elseif HeldItem == 2 then
			item_mat = ITEM2
			item_name = "The Deathward"
			item_droppable = false
			item_usable = false
		elseif HeldItem == 3 then
			item_mat = ITEM3
			item_name = "Milk Jug"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 4 then
			item_mat = ITEM4
			item_name = "Cookie"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 5 then
			item_mat = ITEM5
			item_name = "Mayonnaise"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 6 then
			item_mat = ITEM6
			item_name = "Step Decoy"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 7 then
			item_mat = ITEM7
			item_name = "The Baby"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 8 then
			item_mat = ITEM8
			item_name = "B-Gone Soda"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 9 then
			item_mat = ITEM9
			item_name = "Distress Beacon"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 10 then
			item_mat = ITEM10
			item_name = "Devil's Gamble"
			item_droppable = true
			item_usable = true
		elseif HeldItem == 11 then
			item_mat = ITEM11
			item_name = "Personal Radio Set"
			item_droppable = false
			item_usable = false
		elseif HeldItem == 99 then
			item_mat = ITEM2_99
			item_name = "The Deathward"
			item_droppable = false
			item_usable = false
		end

		surface.SetMaterial(item_mat)
		surface.DrawTexturedRect(itemx, itemy, itemsize, itemsize)
		draw.SimpleText( item_name, "ItemFont", ScrW()/1.16, ScrH()/1.05, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		if item_droppable then draw.SimpleText( "Q to drop", "ItemFontTip", itemx-15, itemy+(itemsize/5), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP ) end
		if item_usable then draw.SimpleText( "R to use", "ItemFontTip", itemx-15, itemy, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP ) end

	end

	for s = 1, #team.GetPlayers(TEAM_SLASHER) do

		local slasher = team.GetPlayers(TEAM_SLASHER)[s]
		
		hook.Add( "Think", "Slasher_Chasing_Light", function()

			if slasher:GetNWBool("TrollgeStage2") then

				local tlight = DynamicLight( slasher:EntIndex() + 999 )
	       		if ( tlight ) then
		        	tlight.pos = slasher:LocalToWorld( Vector(0,0,20) )
		        	tlight.r = 255
		        	tlight.g = 0
		        	tlight.b = 0
		        	tlight.brightness = 5
		        	tlight.Decay = 1000
		        	tlight.Size = 2500
		        	tlight.DieTime = CurTime() + 1
            	end

			end

			if not slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("SidGunRage") then return end
            
            local dlight = DynamicLight( slasher:EntIndex() + 1 )
	        if ( dlight ) then
		        dlight.pos = slasher:LocalToWorld( Vector(0,0,20) )
		        dlight.r = 255
		        dlight.g = 0
		        dlight.b = 0
		        dlight.brightness = 6
		        dlight.Decay = 1000
		        dlight.Size = 250
		        dlight.DieTime = CurTime() + 1
            end

        end )

	end
	
end)

hook.Add( "HUDShouldDraw", "DisableDefaultHUD", function( name )
	if ( name == "CHudHealth" or name == "CHudBattery" ) then
	return false
	end
end)