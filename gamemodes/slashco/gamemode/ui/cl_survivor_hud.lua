CreateClientConVar("slashcohud_show_lowhealth", 1, true, false,
		"Whether to display the survivor's hud as blinking yellow when at low health.", 0, 1)
CreateClientConVar("slashcohud_show_healthvalue", 0, true, false,
		"Whether to display the value of the survivor's health on their hud.", 0, 1)

local SlashCoItems = SlashCoItems
local prevHp, SetTime, ShowDamage, prevHp1, aHp, TimeToFuel, TimeUntilFueled
local FuelingCan
local IsFueling
local maxHp = 100 --ply:GetMaxHealth() seems to be 200
local healthIndicatorShift = 0

net.Receive("mantislashcoGasPourProgress", function()
	TimeToFuel = net.ReadUInt(8)
	FuelingCan = net.ReadEntity()
	IsFueling = net.ReadBool()
	TimeUntilFueled = net.ReadFloat()
end)

hook.Add("DrawOverlay", "SlashCoVHS", function()
	if LocalPlayer():Team() ~= TEAM_SURVIVOR then
		return
	end

	local y = (CurTime() % 4) * (ScrH() / 28)
	surface.SetDrawColor(75, 75, 75, 1)
	while y < ScrH() do
		surface.DrawLine(0, y, ScrW(), y)

		y = y + (ScrH() / 7)
	end
end)

local function drawItemDisplay(item, notUsable, shift)
	if not SlashCoItems[item or "none"] then
		return 0
	end

	local dash = notUsable and "vv" or "--"

	local str = string.format("<font=TVCD>%s   %s   %s</font>", dash, string.upper(SlashCo.Language(item)), dash)
	local parsedItem = markup.Parse(str)
	surface.SetDrawColor(LocalPlayer():ItemFunction2OrElse("DisplayColor", item, { 0, 0, 128 }))
	surface.DrawRect(ScrW() * 0.975 - parsedItem:GetWidth() - shift - 8, ScrH() * 0.95 - 24, parsedItem:GetWidth() + 8, 27)
	parsedItem:Draw(ScrW() * 0.975 - 4 - shift, ScrH() * 0.95, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

	if notUsable then
		return parsedItem:GetWidth() + 48
	end

	local offset = 0
	if SlashCoItems[item].OnUse then
		draw.SimpleText(SlashCo.Language("item_use", "R"), "TVCD", ScrW() * 0.975 - shift - 8, ScrH() * 0.95 - 30,
				color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		offset = 30
	end
	if SlashCoItems[item].OnDrop then
		draw.SimpleText(SlashCo.Language("item_drop", "Q"), "TVCD", ScrW() * 0.975 - shift - 8, ScrH() * 0.95 - 30 - offset,
				color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	return parsedItem:GetWidth() + 48
end

local function selectCrosshair(hitPos)
	for _, v in pairs(ents.FindInSphere(hitPos, 100)) do
		if v.IsSelectable and not (IsFueling and FuelingCan == v) then
			local gasPos = v:WorldSpaceCenter()
			local trace = util.QuickTrace(hitPos, gasPos - hitPos, LocalPlayer())
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
					draw.SimpleText(SlashCo.Language("surv_ping", "MMB"), "TVCD", ScrW() / 2, ScrH() / 2 + 100,
							color_white, TEXT_ALIGN_CENTER,
							TEXT_ALIGN_CENTER)
				end
			end
		end
	end
end

local function slamIndicator()
	if LocalPlayer():GetVelocity():Length() <= 250 then
		return
	end

	local lookent = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(lookent) or lookent:GetClass() ~= "prop_door_rotating" or not SlashCo.CheckDoorWL(lookent) then
		return
	end

	if lookent:GetPos():Distance(LocalPlayer():GetPos()) >= 150 or lookent.IsOpen then
		return
	end

	draw.SimpleText(SlashCo.Language("door_slam", "LMB"), "TVCD", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function gasFuelMeter(hitPos)
	local gas
	if IsFueling then
		gas = (TimeUntilFueled - CurTime()) / TimeToFuel
		if not input.IsButtonDown(KEY_E) then
			IsFueling = false
		elseif CurTime() >= TimeUntilFueled then
			IsFueling = false
		end
	end

	if IsFueling and IsValid(FuelingCan) then
		local genPos = FuelingCan:GetPos()
		local realDistance = hitPos:Distance(genPos)
		if realDistance < 100 then
			genPos = genPos:ToScreen()
			local fade = math.Round((100 - realDistance) * 2.8)
			local parsedTotal = markup.Parse(string.format("<font=TVCD>%s %s %sL</font>",
					SlashCo.Language("FUEL"),
					string.rep("█", 8),
					math.Round(gas * 10)))
			local width = parsedTotal:GetWidth()
			local xClamp = math.Clamp(genPos.x, ScrW() * 0.025 + width / 2, ScrW() * 0.975 - width / 2)
			local yClamp = math.Clamp(genPos.y, ScrH() * 0.05 + 24, ScrH() * 0.95 - 51)
			local half = math.Clamp(gas * 8, 0, 8) % 1 >= 0.5

			surface.SetDrawColor(0, 128, 0, fade)
			surface.DrawRect(xClamp - width / 2 + 2, yClamp - 13, width, 27)
			draw.SimpleText(math.Round(gas * 10) .. "L", "TVCD", xClamp + width / 2, yClamp,
					Color(255, 255, 255, fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(SlashCo.Language("FUEL") .. " " .. string.rep("█", gas * 8) .. (half and "▌" or ""),
					"TVCD", xClamp + 2 - width / 2,
					yClamp, Color(255, 255, 255, fade), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			IsFueling = false
		end
	end
end

local function hpMeter()
	local hp = LocalPlayer():Health()

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
			SetTime = CurTime() + 2
			healthIndicatorShift = CurTime()
		end
	elseif hp < prevHp1 then
		--reset indicator time if more damage is taken
		prevHp1 = math.Clamp(hp, 0, 100)
		SetTime = CurTime() + 2
	end

	aHp = Lerp(FrameTime() * 3, aHp or 100, hp)
	local displayPrevHpBar = ((CurTime() - healthIndicatorShift) % 0.7 < 0.35)
			and math.Round(math.Clamp(((prevHp or 100) - hp) / maxHp, 0, 1) * 26.9) or 0
	local parsed

	if hp >= 25 or not GetConVar("slashcohud_show_lowhealth"):GetBool() then
		local hpOver = math.Clamp(hp - maxHp, 0, 100)
		local hpAdjust = math.Clamp(hp, 0, 100) - hpOver
		local displayHpBar = math.Round(math.Clamp(hpAdjust / maxHp, 0, 1) * 27)
		local displayHpOverBar = math.Round(math.Clamp(hpOver / maxHp, 0, 1) * 27)
		parsed = markup.Parse(string.format("<font=TVCD>%s <colour=0,255,255,255>%s</colour>%s<colour=255,0,0,255>%s</colour></font>",
				SlashCo.Language("HP"),
				string.rep("█", displayHpOverBar),
				string.rep("█", displayHpBar),
				string.rep("█", displayPrevHpBar)
		))
	else
		local displayHpBar = (CurTime() % 0.7 > 0.35) and math.Round(math.Clamp(hp / maxHp, 0, 1) * 27) or 0
		parsed = markup.Parse(string.format("<font=TVCD>%s <colour=255,255,0,255>%s</colour><colour=255,0,0,255>%s</colour></font>",
				SlashCo.Language("HP"),
				string.rep("█", displayHpBar),
				string.rep("█", displayPrevHpBar)
		))
	end

	surface.SetDrawColor(0, 0, 128, 255)

	local hpLength = markup.Parse("<font=TVCD>" .. SlashCo.Language("HP") .. "</font>"):GetWidth()

	if not GetConVar("slashcohud_show_healthvalue"):GetBool() then
		surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 376 + hpLength, 27)
	else
		local displayHp = math.Round(aHp)
		local parsedValue = markup.Parse("<font=TVCD>" .. displayHp .. "</font>")
		surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 386 + parsedValue:GetWidth() + hpLength, 27)
		parsedValue:Draw(ScrW() * 0.025 + 384 + hpLength, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

	parsed:Draw(ScrW() * 0.025 + 4, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

hook.Add("HUDPaint", "SurvivorHUD", function()
	local ply = LocalPlayer()

	if ply:Team() ~= TEAM_SURVIVOR then
		return
	end

	local shift = drawItemDisplay(ply:GetNWString("item", "none"), ply:GetNWString("item2", "none") ~= "none", 0)
	drawItemDisplay(ply:GetNWString("item2", "none"), nil, shift)

	local hitPos = LocalPlayer():GetShootPos()
	gasFuelMeter(hitPos)
	selectCrosshair(hitPos)

	hpMeter()
	slamIndicator()
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
			if tlight then
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
			if tlight then
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
			if dlight then
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
		if dlight then
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