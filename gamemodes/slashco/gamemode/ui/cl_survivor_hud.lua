CreateClientConVar("slashcohud_show_lowhealth", 1, true, false,
		"Whether to display the survivor's hud as blinking yellow when at low health.", 0, 1)
CreateClientConVar("slashcohud_show_healthvalue", 0, true, false,
		"Whether to display the value of the survivor's health on their hud.", 0, 1)

local SlashCoItems = SlashCoItems
local prevHp, SetTime, ShowDamage, prevHp1, aHp, TimeToFuel, TimeUntilFueled
local FuelingCan
local IsFueling
local maxHp = 100 --ply:GetMaxHealth() seems to be 200
local global_pings = {}

local red = Color(255, 64, 64)
local green = Color(64, 255, 64)
local blue = Color(64, 64, 255)

local function FindPos(search)
	if type(search) == "Entity" then
		return search:WorldSpaceCenter()
	elseif type(search) == "Vector" then
		return search
	end
end

local pingType = {
	ITEM = function(v)
		return v.Name or "ITEM"
	end,
	SURVIVOR = function(v)
		return v.SurvivorName, blue
	end,
	SLASHER = function()
		return nil, red
	end,
	GENERATOR = function()
		return nil, green
	end
}

net.Receive("mantislashcoGasPourProgress", function()
	TimeToFuel = net.ReadUInt(8)
	FuelingCan = net.ReadEntity()
	IsFueling = net.ReadBool()
	TimeUntilFueled = net.ReadFloat()
end)

local function removePing(key)
	global_pings[key] = nil
	--table.RemoveByValue(global_pings, key)
end

net.Receive("mantislashcoSurvivorPings", function()
	local ping = net.ReadTable()

	for k, v in pairs(global_pings) do
		local pn = v
		if pn.Player == ping.Player then
			removePing(k)
			break
		end
	end

	if ping.Type == "GENERATOR" then
		LocalPlayer():EmitSound("slashco/ping_generator.mp3")
	elseif ping.Type ~= "LOOK HERE" and ping.Type ~= "LOOK AT THIS" then
		LocalPlayer():EmitSound("slashco/ping_item.mp3")
	end

	ping.ID = math.random(2 ^ 31 - 1)
	global_pings[ping.ID] = ping

	if ping.ExpiryTime and ping.ExpiryTime > 0 then
		timer.Simple(ping.ExpiryTime, function()
			removePing(ping.ID)
		end)
	end
end)

hook.Add("DrawOverlay", "SlashCoVHS", function()
	if LocalPlayer():Team() ~= TEAM_SURVIVOR then
		return
	end

	local y = (CurTime() % 4) * (ScrH() / 28)
	surface.SetDrawColor(192, 192, 192, 1)
	while y < ScrH() do
		surface.DrawLine(0, y, ScrW(), y)

		y = y + (ScrH() / 7)
	end
end)

hook.Add("HUDPaint", "SurvivorHUD", function()
	local ply = LocalPlayer()

	if ply:Team() ~= TEAM_SURVIVOR then
		return
	end

	local gas
	if IsFueling then
		gas = (TimeUntilFueled - CurTime()) / TimeToFuel
		if not input.IsButtonDown(KEY_E) then
			IsFueling = false
		elseif CurTime() >= TimeUntilFueled then
			IsFueling = false
		end
	end

	--//item display//--

	local HeldItem = ply:GetNWString("item", "none")
	if SlashCoItems[HeldItem or "none"] then
		local parsedItem = markup.Parse("<font=TVCD>---     " .. string.upper(SlashCoLanguage(HeldItem)) .. "     ---</font>")
		surface.SetDrawColor(ply:ItemFunctionOrElse("DisplayColor", { 0, 0, 128 }))
		surface.DrawRect(ScrW() * 0.975 - parsedItem:GetWidth() - 8, ScrH() * 0.95 - 24, parsedItem:GetWidth() + 8, 27)
		parsedItem:Draw(ScrW() * 0.975 - 4, ScrH() * 0.95, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

		local offset = 0
		if SlashCoItems[HeldItem].OnUse then
			draw.SimpleText(SlashCoLanguage("item_use", "R"), "TVCD", ScrW() * 0.975 - 4, ScrH() * 0.95 - 30,
					color_white, TEXT_ALIGN_RIGHT,
					TEXT_ALIGN_BOTTOM)
			offset = 30
		end
		if SlashCoItems[HeldItem].OnDrop then
			draw.SimpleText(SlashCoLanguage("item_drop", "Q"), "TVCD", ScrW() * 0.975 - 4, ScrH() * 0.95 - 30 - offset,
					color_white,
					TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		end
	end

	--//gas fuel meter//--

	local hitPos = ply:GetShootPos()
	if IsFueling and IsValid(FuelingCan) then
		local genPos = FuelingCan:GetPos()
		local realDistance = hitPos:Distance(genPos)
		if realDistance < 100 then
			genPos = genPos:ToScreen()
			local fade = math.Round((100 - realDistance) * 2.8)
			local parsedTotal = markup.Parse(string.format("<font=TVCD>%s %s %sL</font>",
					SlashCoLanguage("FUEL"),
					string.rep("█", 8),
					math.Round(gas * 10)))
			local width = parsedTotal:GetWidth()
			local xClamp = math.Clamp(genPos.x, ScrW() * 0.025 + width / 2, ScrW() * 0.975 - width / 2)
			local yClamp = math.Clamp(genPos.y, ScrH() * 0.05 + 24, ScrH() * 0.95 - 51)
			local half = math.Clamp((gas * 8), 0, 8) % 1 >= 0.5

			surface.SetDrawColor(0, 128, 0, fade)
			surface.DrawRect(xClamp - width / 2 + 2, yClamp - 13, width, 27)
			draw.SimpleText(math.Round(gas * 10) .. "L", "TVCD", xClamp + width / 2, yClamp,
					Color(255, 255, 255, fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(SlashCoLanguage("FUEL") .. " " .. string.rep("█", gas * 8) .. (half and "▌" or ""),
					"TVCD", xClamp + 2 - width / 2,
					yClamp, Color(255, 255, 255, fade), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			IsFueling = false
		end
	end

	--//prompts for items//--

	if LocalPlayer():GetVelocity():Length() > 250 and game.GetMap() ~= "sc_lobby" then
		local lookent = LocalPlayer():GetEyeTrace().Entity
		if IsValid(lookent) and lookent:GetClass() == "prop_door_rotating" and g_CheckDoorWL(lookent) then
			if lookent:GetPos():Distance(LocalPlayer():GetPos()) < 150 and not lookent.IsOpen then
				draw.SimpleText(SlashCoLanguage("door_slam", "LMB"), "TVCD", ScrW() / 2, ScrH() / 2, color_white,
						TEXT_ALIGN_CENTER,
						TEXT_ALIGN_CENTER)
			end
		end
	end

	--ping display
	for k, v in pairs(global_pings) do
		if v.Entity == nil then
			continue
		end

		if type(v.Entity) ~= "Vector" and not IsValid(v.Entity) then
			removePing(k)
			continue
		end

		if not IsValid(v.Player) then
			removePing(k)
			continue
		end

		local showText, textColor, pos
		if pingType[v.Type] then
			showText, textColor, pos = pingType[v.Type](v)
		end
		showText = showText or v.Type or "INVALID"
		textColor = textColor or color_white
		pos = pos or (FindPos(v.Entity)):ToScreen()

		draw.SimpleText(v.Player:GetName(), "TVCD_small", pos.x, pos.y - 25, Color(255, 255, 255, 180),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("[" .. SlashCoLanguage(showText) .. "]", "TVCD", pos.x, pos.y, textColor, TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER)
	end

	--//item selection crosshair//--

	for _, v in pairs(ents.FindInSphere(hitPos, 100)) do
		if v.IsSelectable and not (IsFueling and FuelingCan == v) then
			local gasPos = v:WorldSpaceCenter()
			local trace = util.QuickTrace(hitPos, gasPos - hitPos, ply)
			if not trace.Hit or trace.Entity == v then
				local realDistance = hitPos:Distance(gasPos)
				gasPos = gasPos:ToScreen()
				local centerDistance = math.Distance(ScrW() / 2, ScrH() / 2, gasPos.x, gasPos.y)
				draw.SimpleText("[", "Indicator", gasPos.x - centerDistance / 2 - 12, gasPos.y,
						Color(255, 255, 255, (100 - realDistance) * (300 - centerDistance) * 0.02), TEXT_ALIGN_CENTER,
						TEXT_ALIGN_CENTER)
				draw.SimpleText("]", "Indicator", gasPos.x + centerDistance / 2 + 12, gasPos.y,
						Color(255, 255, 255, (100 - realDistance) * (300 - centerDistance) * 0.02), TEXT_ALIGN_CENTER,
						TEXT_ALIGN_CENTER)

				if realDistance < 200 and centerDistance < 25 then
					draw.SimpleText(SlashCoLanguage("surv_ping", "MMB"), "TVCD", ScrW() / 2, ScrH() / 2 + 100,
							color_white, TEXT_ALIGN_CENTER,
							TEXT_ALIGN_CENTER)
				end
			end
		end
	end

	--//health//--

	local hp = ply:Health()

	if hp > (prevHp or 100) then
		--reset damage indicator upon healing
		prevHp = math.Clamp(hp, 0, 100)
		SetTime = 0
	end

	if CurTime() >= (SetTime or 0) then
		if ShowDamage then
			--update prevHp once the indicator time is up
			prevHp = math.Clamp(hp, 0, 100)
			ShowDamage = false
		end

		if hp < (prevHp or 100) then
			--start the damage indicator time
			prevHp1 = math.Clamp(hp, 0, 100)
			ShowDamage = true
			SetTime = CurTime() + 2.1
		end
	elseif hp < prevHp1 then
		--reset indicator time if more damage is taken
		prevHp1 = math.Clamp(hp, 0, 100)
		SetTime = CurTime() + 2.1
	end

	aHp = Lerp(FrameTime() * 3, (aHp or 100), hp)
	local displayPrevHpBar = (CurTime() % 0.7 > 0.35) and math.Round(math.Clamp(((prevHp or 100) - hp) / maxHp, 0,
			1) * 26.9) or 0
	local parsed

	if hp >= 25 or not GetConVar("slashcohud_show_lowhealth"):GetBool() then
		local hpOver = math.Clamp(hp - maxHp, 0, 100)
		local hpAdjust = math.Clamp(hp, 0, 100) - hpOver
		local displayHpBar = math.Round(math.Clamp(hpAdjust / maxHp, 0, 1) * 27)
		local displayHpOverBar = math.Round(math.Clamp(hpOver / maxHp, 0, 1) * 27)
		parsed = markup.Parse(string.format("<font=TVCD>%s <colour=0,255,255,255>%s</colour>%s<colour=255,0,0,255>%s</colour></font>",
				SlashCoLanguage("HP"),
				string.rep("█", displayHpOverBar),
				string.rep("█", displayHpBar),
				string.rep("█", displayPrevHpBar)
		))
	else
		local displayHpBar = (CurTime() % 0.7 > 0.35) and math.Round(math.Clamp(hp / maxHp, 0, 1) * 27) or 0
		parsed = markup.Parse(string.format("<font=TVCD>%s <colour=255,255,0,255>%s</colour><colour=255,0,0,255>%s</colour></font>",
				SlashCoLanguage("HP"),
				string.rep("█", displayHpBar),
				string.rep("█", displayPrevHpBar)
		))
	end

	surface.SetDrawColor(0, 0, 128, 255)

	local hpLength = markup.Parse("<font=TVCD>"..SlashCoLanguage("HP").."</font>"):GetWidth()

	if not GetConVar("slashcohud_show_healthvalue"):GetBool() then
		surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 376 + hpLength, 27)
	else
		local displayHp = math.Round(aHp)
		local parsedValue = markup.Parse("<font=TVCD>" .. displayHp .. "</font>")
		surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 386 + parsedValue:GetWidth() + hpLength, 27)
		parsedValue:Draw(ScrW() * 0.025 + 384 + hpLength, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

	parsed:Draw(ScrW() * 0.025 + 4, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end)

hook.Add("PlayerButtonDown", "slashco_open_voice", function(ply, button)
	if not IsFirstTimePredicted() or ply:Team() ~= TEAM_SURVIVOR then
		return
	end
	if button == KEY_G then
		vgui.Create("sc_voiceselect")
	end
end)

hook.Add("Think", "Slasher_Chasing_Light", function()
	for s = 1, #ents.FindByClass("sc_crimclone") do
		local clone = ents.FindByClass("sc_crimclone")[s]
		if clone:GetNWBool("MainRageClone") then
			local tlight = DynamicLight(clone:EntIndex() + 1)
			if (tlight) then
				tlight.pos = clone:LocalToWorld(Vector(0, 0, 20))
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
			local tlight = DynamicLight(slasher:EntIndex() + 1)
			if (tlight) then
				tlight.pos = slasher:LocalToWorld(Vector(0, 0, 20))
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
			local dlight = DynamicLight(slasher:EntIndex())
			if (dlight) then
				dlight.pos = slasher:LocalToWorld(Vector(0, 0, 20))
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.brightness = 8
				dlight.Decay = 1000
				dlight.Size = 300
				dlight.DieTime = CurTime() + 1
			end
		end

		if not slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("SidGunRage") and not slasher:GetNWBool("WatcherRage") then
			return
		end

		local dlight = DynamicLight(slasher:EntIndex())
		if (dlight) then
			dlight.pos = slasher:LocalToWorld(Vector(0, 0, 20))
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.brightness = 6
			dlight.Decay = 1000
			dlight.Size = 250
			dlight.DieTime = CurTime() + 1
		end
	end
end)