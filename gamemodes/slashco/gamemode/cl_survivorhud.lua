--include( "globals.lua" )
include( "ui/fonts.lua" )
--include( "ui/data_info.lua" )

local maxHp = 100 --ply:GetMaxHealth() seems to be 200

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


net.Receive("slashcoSelectables", function(_,_)

	Selectables = net.ReadTable()

end)

net.Receive( "mantislashcoGasPourProgress", function( )

	local ReceivedTable = net.ReadTable()

	if ReceivedTable then
		--ply:ChatPrint(table.ToString(ReceivedTable))
		gasCan = ReceivedTable.gasCan
		local progress = ReceivedTable.progress
		gas = 1 - (progress / 13)
		if progress > 0 and progress <= 13 then
			isGassing = true
		else
			isGassing = false
		end
	end
end)

hook.Add("HUDPaint", "SurvivorHUD", function()

	local ply = LocalPlayer()
	
	if ply:Team() == TEAM_SURVIVOR then
		if HeldItem == nil then HeldItem = 0 end

		local itemx = ScrW() - (ScrW()/7)
		local itemy = ScrH() - (ScrH()/3.5)
		local itemsize = ScrH()/5

		if not input.IsButtonDown( 15 ) then isGassing = false end

		--//gas fuel meter//--

		local hitPos = ply:GetShootPos()
		if isGassing and IsValid(Entity(gasCan)) then
			local genPos = Entity(gasCan):GetPos()
			local realDistance = hitPos:Distance(genPos)
			if realDistance < 100 then
				genPos = genPos:ToScreen()
				local fade = math.Round((100 - realDistance) * 2.8)
				local parsedLiters = markup.Parse("<font=TVCD>" .. math.Round(gas * 10) .. "L</font>") --this only exists to find the length lol
				local width = 206 + parsedLiters:GetWidth()
				local xClamp = math.Clamp(genPos.x, ScrW() * 0.025 + width / 2, ScrW() * 0.975 - width / 2)
				local yClamp = math.Clamp(genPos.y, ScrH() * 0.05 + 24, ScrH() * 0.95 - 51)
				local half = math.Clamp((gas * 8), 0, 8) % 1 >= 0.5

				surface.SetDrawColor(0, 128, 0, fade)
				surface.DrawRect(xClamp - width / 2, yClamp - 13, width, 27)
				draw.SimpleText(math.Round(gas * 10) .. "L", "TVCD", xClamp + 205 - width / 2, yClamp, Color(255, 255, 255, fade), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText("FUEL " .. string.rep("█", gas * 8) .. (half and "▌" or ""), "TVCD", xClamp + 2 - width / 2, yClamp, Color(255, 255, 255, fade), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				isGassing = false
			end
		end

		--//item selection crosshair//--

		--draw.SimpleText(#Selectables, "TVCD", ScrW()/2, ScrH()/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		for _, p in pairs(Selectables) do
			local entity = Entity(p)
			if not IsValid(entity) then continue end
			local gasPos = entity:GetPos()
			local realDistance = hitPos:Distance(gasPos)
			if realDistance < 100 and not (isGassing and gasCan == p) then
				local trace = util.QuickTrace(hitPos,gasPos-hitPos,ply)
				if trace.Hit and trace.Entity ~= entity then continue end
				gasPos = gasPos:ToScreen()
				local centerDistance = math.Distance(ScrW()/2,ScrH()/2,gasPos.x,gasPos.y)
				draw.SimpleText("[", "Indicator", gasPos.x-centerDistance/2-12, gasPos.y, Color( 255, 255, 255, (100-realDistance)*(300-centerDistance)*0.02 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("]", "Indicator", gasPos.x+centerDistance/2+12, gasPos.y, Color( 255, 255, 255, (100-realDistance)*(300-centerDistance)*0.02 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		--//health//--

		local hp = ply:Health()

		if hp > (prevHp or 100) then --reset damage indicator upon healing
			prevHp = math.Clamp(hp,0,100)
			SetTime = 0
		end

		if (CurTime() >= (SetTime or 0)) then
			if ShowDamage then --update prevHp once the indicator time is up
				prevHp = math.Clamp(hp,0,100)
				ShowDamage = false
			end

			if hp < (prevHp or 100) then --start the damage indicator time
				prevHp1 = math.Clamp(hp,0,100)
				ShowDamage = true
				SetTime = CurTime() + 2.1
			end
		elseif hp < prevHp1 then --reset indicator time if more damage is taken
			prevHp1 = math.Clamp(hp,0,100)
			SetTime = CurTime() + 2.1
		end

		aHp = Lerp(FrameTime()*3, (aHp or 100), hp)
		local displayHp = math.Round(aHp)
		local displayHpBar = math.floor(math.Clamp(hp/maxHp,0,1)*27)
		local displayPrevHpBar = (CurTime()%0.7 > 0.35) and math.ceil(math.Clamp(((prevHp or 100) - hp)/maxHp,0,1)*27) or 0

		local parsedValue = markup.Parse("<font=TVCD>"..displayHp.."</font>")
		local parsed = markup.Parse("<font=TVCD>HP "..string.rep("█",displayHpBar).."<colour=255,0,0,255>"..string.rep("█",displayPrevHpBar).."</colour></font>")

		surface.SetDrawColor(0,0,128,255)
		surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95-24, 420+parsedValue:GetWidth(), 27)

		parsed:Draw(ScrW() * 0.025+4, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		parsedValue:Draw(ScrW() * 0.025+417, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

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

		if (HeldItem ~= 0) then
			surface.SetMaterial(item_mat)
			surface.DrawTexturedRect(itemx, itemy, itemsize, itemsize)
			draw.SimpleText( item_name, "LobbyFont2", ScrW()/1.04, ScrH()/1.02, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
			if item_droppable then draw.SimpleText( "Q to drop", "ItemFontTip", itemx + itemsize, itemy-(itemsize/3), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP ) end
			if item_usable then draw.SimpleText( "R to use", "ItemFontTip", itemx + itemsize, itemy-(itemsize/6), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP ) end
		end
	end
end)

hook.Add( "Think", "Slasher_Chasing_Light", function()

	for s = 1, #team.GetPlayers(TEAM_SLASHER) do

		local slasher = team.GetPlayers(TEAM_SLASHER)[s]

		if slasher:GetNWBool("TrollgeStage2") then

			local tlight = DynamicLight( slasher:EntIndex() + 1 )
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

		if slasher:GetNWBool("TylerFlash") then

			local dlight = DynamicLight( slasher:EntIndex() )
			   if ( dlight ) then
				dlight.pos = slasher:LocalToWorld( Vector(0,0,20) )
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.brightness = 8
				dlight.Decay = 1000
				dlight.Size = 300
				dlight.DieTime = CurTime() + 1
			end

		end

		if not slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("SidGunRage") then return end
		
		local dlight = DynamicLight( slasher:EntIndex() )
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

	end

end )