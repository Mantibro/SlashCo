--include( "globals.lua" )
include( "ui/fonts.lua" )
--include( "ui/data_info.lua" )

CreateClientConVar( "slashcohud_show_lowhealth", 1, true, false, "Whether to display the survivor's hud as blinking yellow when at low health.", 0, 1 )
CreateClientConVar( "slashcohud_show_healthvalue", 0, true, false, "Whether to display the value of the survivor's health on their hud.", 0, 1 )

local SlashCoItems = SlashCoItems
local prevHp, SetTime, ShowDamage, prevHp1, aHp, TimeToFuel, TimeUntilFueled
local FuelingCan
local IsFueling
local maxHp = 100 --ply:GetMaxHealth() seems to be 200
local prompt = 0
local ref_eyeang = Angle(0,0,0)
local voice_cooldown = 0
local global_pings = {}
local last_pinged = 0

local GeneratorIcon = Material("slashco/ui/icons/slasher/progbar_icon")

local function FindPos(search)

	if type( search ) == "Entity" then
		return search:GetPos()
	elseif type( search ) == "Vector" then
		return search
	end

end

net.Receive( "mantislashcoGasPourProgress", function( )

	TimeToFuel = net.ReadUInt(8)
	FuelingCan = net.ReadEntity()
	IsFueling = net.ReadBool()
	TimeUntilFueled = net.ReadFloat()

end)

net.Receive( "mantislashcoSurvivorPings", function( )

	local ping = net.ReadTable()

	for i = 1, #global_pings do

		local pn = global_pings[i]

		if pn.Player == ping.Player then
			global_pings[i] = nil
		end

	end

	if ping.Type == "Generator" then
		LocalPlayer():EmitSound("slashco/ping_generator.mp3")
	elseif ping.Type ~= "LOOK HERE" and ping.Type ~= "LOOK AT THIS" then
		LocalPlayer():EmitSound("slashco/ping_item.mp3")
	end

	table.insert(global_pings, ping)

	if ping.ExpiryTime > 0 then
		timer.Simple(ping.ExpiryTime, function() 
			table.RemoveByValue( global_pings, ping )
		end)
	end

end)

hook.Add("HUDPaint", "SurvivorHUD", function()

	local ply = LocalPlayer()

	if ply:Team() == TEAM_SURVIVOR then

		local gas
		if IsFueling then
			gas = (TimeUntilFueled - CurTime())/TimeToFuel
			if not input.IsButtonDown(KEY_E) then
				--print("not e")
				IsFueling = false
			elseif CurTime() >= TimeUntilFueled then
				--print("not fuel")
				IsFueling = false
			end
		end

		--//item display//--

		local HeldItem = ply:GetNWString("item", "none")
		if SlashCoItems[HeldItem or "none"] then
			local parsedItem = markup.Parse("<font=TVCD>---     "..string.upper(SlashCoItems[HeldItem].Name).."     ---</font>")
			if SlashCoItems[HeldItem].DisplayColor then
				surface.SetDrawColor(SlashCoItems[HeldItem].DisplayColor(ply))
			else
				surface.SetDrawColor(0,0,128,255)
			end
			surface.DrawRect(ScrW() * 0.975-parsedItem:GetWidth()-8, ScrH() * 0.95-24, parsedItem:GetWidth()+8, 27)
			parsedItem:Draw(ScrW() * 0.975-4, ScrH() * 0.95, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

			local offset = 0
			if SlashCoItems[HeldItem].OnUse then
				draw.SimpleText("[R] USE", "TVCD", ScrW() * 0.975-4, ScrH() * 0.95-30, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
				offset = 30
			end
			if SlashCoItems[HeldItem].OnDrop then
				draw.SimpleText("[Q] DROP", "TVCD", ScrW() * 0.975-4, ScrH() * 0.95-30-offset, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			end

			--surface.SetDrawColor(255, 255, 255, 255)
			--surface.SetMaterial(Material(SlashCoItems[HeldItem].Icon))
			--surface.DrawTexturedRect(ScrW() * 0.975-100, ScrH() * 0.95-130, 100, 100)
		end

		--//gas fuel meter//--

		local hitPos = ply:GetShootPos()
		if IsFueling and IsValid(FuelingCan) then
			local genPos = FuelingCan:GetPos()
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
				IsFueling = false
			end
		end

		--//voice prompts//--

		if input.IsKeyDown( KEY_T ) then

			draw.SimpleText("[SAY]", "TVCD", ScrW()/2, ScrH()/2 - 35, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local ht = (ref_eyeang[1] - LocalPlayer():EyeAngles()[1])*10
			local xt = (ref_eyeang[2] - LocalPlayer():EyeAngles()[2])*10

			local selected = false
			local yes_select = false
			local no_select = false
			local follow_select = false
			local spot_select = false
			local help_select = false
			local run_select = false

			if math.abs((-250) - xt) < 50 and math.abs((0) - ht) < 50 then
				yes_select = true
				selected = true
			end

			if math.abs((250) - xt) < 50 and math.abs((0) - ht) < 50 then
				no_select = true
				selected = true
			end

			if math.abs((-150) - xt) < 50 and math.abs((-100) - ht) < 50 then
				follow_select = true
				selected = true
			end

			if math.abs((150) - xt) < 50 and math.abs((-100) - ht) < 50 then
				spot_select = true
				selected = true
			end

			if math.abs((-150) - xt) < 50 and math.abs((100) - ht) < 50 then
				help_select = true
				selected = true
			end

			if math.abs((150) - xt) < 50 and math.abs((100) - ht) < 50 then
				run_select = true
				selected = true
			end

			if yes_select then
				draw.SimpleText("[ \"YES\" ]", "TVCD", ScrW()/2 - 250, ScrH()/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				prompt = 1
			else
				draw.SimpleText("  \"YES\"  ", "TVCD", ScrW()/2 - 250, ScrH()/2, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if no_select then
				draw.SimpleText("[ \"NO\" ]", "TVCD", ScrW()/2 + 250, ScrH()/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				prompt = 2
			else
				draw.SimpleText("  \"NO\"  ", "TVCD", ScrW()/2 + 250, ScrH()/2, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if follow_select then
				draw.SimpleText("[ \"FOLLOW ME\" ]", "TVCD", ScrW()/2 - 150, ScrH()/2 + 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				prompt = 3
			else
				draw.SimpleText("  \"FOLLOW ME\"  ", "TVCD", ScrW()/2 - 150, ScrH()/2 + 100, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if spot_select then
				draw.SimpleText("[ \"SLASHER HERE\" ]", "TVCD", ScrW()/2 + 150, ScrH()/2 + 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				prompt = 4
			else
				draw.SimpleText("  \"SLASHER HERE\"  ", "TVCD", ScrW()/2 + 150, ScrH()/2 + 100, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if help_select then
				draw.SimpleText("[ \"HELP ME\" ]", "TVCD", ScrW()/2 - 150, ScrH()/2 - 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				prompt = 5
			else
				draw.SimpleText("  \"HELP ME\"  ", "TVCD", ScrW()/2 - 150, ScrH()/2 - 100, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if run_select then
				draw.SimpleText("[ \"RUN\" ]", "TVCD", ScrW()/2 + 150, ScrH()/2 - 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				prompt = 6
			else
				draw.SimpleText("  \"RUN\"  ", "TVCD", ScrW()/2 + 150, ScrH()/2 - 100, Color( 255, 255, 255, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if not selected then
				draw.SimpleText("[]", "TVCD", ScrW()/2 + xt, ScrH()/2 - ht, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

		else

			ref_eyeang = LocalPlayer():EyeAngles()

			if prompt > 0 and voice_cooldown <= 0 then

				net.Start("mantislashcoSurvivorVoicePrompt")
				net.WriteEntity(LocalPlayer())
				net.WriteUInt(prompt, 3)
				net.SendToServer()

				voice_cooldown = 2

				prompt = 0
			end

		end

		if voice_cooldown > 0 then voice_cooldown = voice_cooldown - RealFrameTime() end

		--//prompts for items//--

		local lookent = LocalPlayer():GetEyeTrace().Entity 

		if LocalPlayer():GetVelocity():Length() > 250 then

			if lookent:GetClass() == "prop_door_rotating" or lookent:GetClass() == "func_door_rotating" then
				if lookent:GetPos():Distance( LocalPlayer():GetPos() ) < 150 then
					draw.SimpleText("[M1 TO SLAM OPEN!]", "TVCD", ScrW()/2, ScrH()/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

		end

		if last_pinged <= 0 and input.IsKeyDown(KEY_G ) then

			last_pinged = 3

			local ping_info = {}

			ping_info.Player = LocalPlayer()

			local lookfinal = lookent

			ping_info.ExpiryTime = 0

			if lookfinal:EntIndex() ~= 0 then
				if lookfinal:GetClass() == "sc_generator" then
					ping_info.Type = "Generator"
				elseif lookfinal:GetClass() == "sc_gascan" then
					ping_info.Type = "Fuel Can"
				elseif lookfinal:GetClass() == "sc_baby" then
					ping_info.Type = "The Baby"
				elseif lookfinal:GetClass() == "sc_battery" then
					ping_info.Type = "Battery"
				elseif lookfinal:GetClass() == "sc_soda" then
					ping_info.Type = "B-Gone Soda"
				elseif lookfinal:GetClass() == "sc_beacon" then
					ping_info.Type = "Distress Beacon"
				elseif lookfinal:GetClass() == "sc_cookie" then
					ping_info.Type = "Cookie"
				elseif lookfinal:GetClass() == "sc_deathward" then
					ping_info.Type = "Deathward"
				elseif lookfinal:GetClass() == "sc_devildie" then
					ping_info.Type = "Devil's Gamble"
				elseif lookfinal:GetClass() == "sc_helicopter" then
					ping_info.Type = "Helicopter"
				elseif lookfinal:GetClass() == "sc_mayo" then
					ping_info.Type = "Mayonnaise"
				elseif lookfinal:GetClass() == "sc_milkjug" then
					ping_info.Type = "Milk Jug"
				elseif lookfinal:GetClass() == "sc_rock" then
					ping_info.Type = "The Rock"
				elseif lookfinal:GetClass() == "sc_pocketsand" then
					ping_info.Type = "Pocket Sand"
				elseif lookfinal:GetClass() == "sc_stepdecoy" then
					ping_info.Type = "Step Decoy"
				elseif lookfinal:GetClass() == "sc_dogg" then
					ping_info.Type = "Plush Dog"
				elseif lookfinal:GetModel() == "models/ldi/basketball.mdl" then
					ping_info.Type = "Basketball"
					ping_info.ExpiryTime = 15
				elseif lookfinal:IsPlayer() then
					if lookfinal:Team() == TEAM_SURVIVOR then
						ping_info.Type = "SURVIVOR"
					end

					if lookfinal:Team() == TEAM_SLASHER then
						ping_info.Type = "SLASHER"
						lookfinal = LocalPlayer():GetEyeTrace().HitPos
						ping_info.ExpiryTime = 5
					end
				else

					ping_info.Type = "LOOK AT THIS"

					ping_info.ExpiryTime = 10

				end

			else
				lookfinal = LocalPlayer():GetEyeTrace().HitPos

				ping_info.Type = "LOOK HERE"

				ping_info.ExpiryTime = 10
			end


			ping_info.Entity = lookfinal

			net.Start("mantislashcoSurvivorPreparePing")
			net.WriteTable(ping_info)
			net.SendToServer()

		end

		if last_pinged > 0 then last_pinged = last_pinged - RealFrameTime() end

		--(displaying them)

		for i = 1, #global_pings do

			if type(global_pings[i].Entity) ~= "Vector" and not IsValid( global_pings[i].Entity ) then
				table.RemoveByValue( global_pings, global_pings[i] )
				continue
			end

			if not IsValid( global_pings[i].Player ) then
				table.RemoveByValue( global_pings, global_pings[i] )
				continue
			end

			local pos = ( FindPos( global_pings[i].Entity ) ):ToScreen()

			local showtext = global_pings[i].Type 

			local showname = true

			local textcolor = Color( 255, 255, 255, 255 )

			if global_pings[i].Type == "LOOK HERE" then 
				showname = true
			elseif global_pings[i].Type == "SURVIVOR" then 
					showname = true
					showtext = global_pings[i].Entity:GetName()
					textcolor = Color(50,50,255,255)
			elseif global_pings[i].Type == "SLASHER" then 
					showname = true
					textcolor = Color(255,50,50,255)
			elseif global_pings[i].Type == "Generator" then
				showname = false
				surface.SetMaterial(GeneratorIcon)
				surface.DrawTexturedRectRotated(pos.x, pos.y, ScrW()/32, ScrW()/32, 0)
				showtext = "     "
			end

			if showname then
				draw.SimpleText(global_pings[i].Player:GetName(), "TVCD", pos.x, pos.y - 25, Color( 255, 255, 255, 180 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText("["..showtext.."]", "TVCD", pos.x, pos.y, textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		end

		--//item selection crosshair//--

		for _, v in pairs(ents.FindInSphere(hitPos, 100)) do
			if v.IsSelectable and not (IsFueling and FuelingCan == v) then
				local gasPos = v:GetPos()
				local trace = util.QuickTrace(hitPos,gasPos-hitPos,ply)
				if not trace.Hit or trace.Entity == v then
					local realDistance = hitPos:Distance(gasPos)
					gasPos = gasPos:ToScreen()
					local centerDistance = math.Distance(ScrW()/2,ScrH()/2,gasPos.x,gasPos.y)
					draw.SimpleText("[", "Indicator", gasPos.x-centerDistance/2-12, gasPos.y, Color( 255, 255, 255, (100-realDistance)*(300-centerDistance)*0.02 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					draw.SimpleText("]", "Indicator", gasPos.x+centerDistance/2+12, gasPos.y, Color( 255, 255, 255, (100-realDistance)*(300-centerDistance)*0.02 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					if realDistance < 200 and centerDistance < 25 then
						draw.SimpleText("['G' TO PING]", "TVCD", ScrW()/2, ScrH()/2 + 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				end
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
		local displayPrevHpBar = (CurTime()%0.7 > 0.35) and math.Round(math.Clamp(((prevHp or 100) - hp)/maxHp,0,1)*26.9) or 0
		local parsed

		if hp >= 25 or not GetConVar("slashcohud_show_lowhealth"):GetBool() then
			local hpOver = math.Clamp(hp-maxHp,0,100)
			local hpAdjust = math.Clamp(hp,0,100)-hpOver
			local displayHpBar = math.Round(math.Clamp(hpAdjust/maxHp,0,1)*27)
			local displayHpOverBar = math.Round(math.Clamp(hpOver/maxHp,0,1)*27)
			parsed = markup.Parse("<font=TVCD>HP <colour=0,255,255,255>"..string.rep("█",displayHpOverBar).."</colour>" --overheal
					..string.rep("█",displayHpBar) --hp
					.."<colour=255,0,0,255>"..string.rep("█",displayPrevHpBar).."</colour></font>") --indicator
		else
			local displayHpBar = (CurTime()%0.7 > 0.35) and math.Round(math.Clamp(hp/maxHp,0,1)*27) or 0
			parsed = markup.Parse("<font=TVCD>HP <colour=255,255,0,255>"..string.rep("█",displayHpBar).."</colour><colour=255,0,0,255>" --hp
					..string.rep("█",displayPrevHpBar).."</colour></font>") --indicator
		end

		surface.SetDrawColor(0,0,128,255)

		if not GetConVar("slashcohud_show_healthvalue"):GetBool() then
			surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95-24, 410, 27)
		else
			local displayHp = math.Round(aHp)
			local parsedValue = markup.Parse("<font=TVCD>"..displayHp.."</font>")
			surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95-24, 420+parsedValue:GetWidth(), 27)
			parsedValue:Draw(ScrW() * 0.025+417, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end

		parsed:Draw(ScrW() * 0.025+4, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end
end)

hook.Add( "Think", "Slasher_Chasing_Light", function()

	for s = 1, #ents.FindByClass("sc_crimclone") do

		local clone = ents.FindByClass("sc_crimclone")[s]

		if clone:GetNWBool("MainRageClone") then 

			local tlight = DynamicLight( clone:EntIndex() + 1 )
			if ( tlight ) then
			tlight.pos = clone:LocalToWorld( Vector(0,0,20) )
			tlight.r = 255
			tlight.g = 0
			tlight.b = 255
			tlight.brightness = 5
			tlight.Decay = 1000
			tlight.Size = 250
			tlight.DieTime = CurTime() + 1
		end
		
		end

	end

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

		if not slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("SidGunRage") and not slasher:GetNWBool("WatcherRage") then return end
		
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