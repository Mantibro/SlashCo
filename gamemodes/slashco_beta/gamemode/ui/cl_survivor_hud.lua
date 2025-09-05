CreateClientConVar("slashco_cl_show_lowhealth", 1, true, false,
		"Whether to display the survivor's hud as blinking yellow when at low health.", 0, 1)
CreateClientConVar("slashco_cl_show_healthvalue", 0, true, false,
		"Whether to display the value of the survivor's health on their hud.", 0, 1)

local SlashCoItems = SlashCoItems
local prevHp, SetTime, ShowDamage, prevHp1, aHp, TimeToFuel, TimeUntilFueled
local FuelingCan, FuelingCanIndex = NULL, -1
local IsFueling
local maxHp = 100
local healthIndicatorShift = 0

local screenMessage

hook.Add("scValue_cantFuel", "CantFuel", function()
	screenMessage = "cant_fuel"
	timer.Create("ScreenMessage", 1.5, 1, function()
		screenMessage = nil
	end)
end)

hook.Add("scValue_cantPower", "CantPower", function()
	screenMessage = "cant_power"
	timer.Create("ScreenMessage", 1.5, 1, function()
		screenMessage = nil
	end)
end)

local function showScreenMessage()
	if not screenMessage then
		return
	end

	local parsedItem = markup.Parse("<font=TVCD>" .. SlashCo.Language(screenMessage) .. "</font>")
	parsedItem:Draw(ScrW() / 2, ScrH() / 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

net.Receive("mantislashco_GasPourProgress", function()
	TimeToFuel = net.ReadUInt(8)
	FuelingCanIndex = net.ReadUInt(MAX_EDICT_BITS)
	IsFueling = net.ReadBool()
	TimeUntilFueled = net.ReadFloat()

	FuelingCan = Entity(FuelingCanIndex)
end)

hook.Add("DrawOverlay", "SlashCoVHS", function()
	if not IsValid(GameData.LocalPlayer) then
		return
	end

	if not GameData.LocalPlayer.Team or GameData.LocalPlayer:Team() ~= TEAM_SURVIVOR then
		return
	end

	local y = (CurTime() % 4) * (ScrH() / 28)
	surface.SetDrawColor(75, 75, 75, 1)
	while y < ScrH() do
		surface.DrawLine(0, y, ScrW(), y)

		y = y + (ScrH() / 7)
	end
end)

local objectives = {}

net.Receive("SlashCoUpdateObjectives", function()
	objectives = {}
	local count = net.ReadUInt(8)
	for i = 1, count do
		local name = net.ReadString()
		if not SlashCo.Objectives[name] then
			continue
		end

		local obj = {}
		obj.name = name
		obj.status = net.ReadUInt(4)

		if SlashCo.Objectives[name].hasCount then
			obj.count = net.ReadUInt(16)
		end

		table.insert(objectives, obj)
	end
end)

local function drawObjectives()
	if table.IsEmpty(objectives) then
		return
	end

	local shift = 0
	for k, v in ipairs(objectives) do
		local count = 1
		if SlashCo.Objectives[v.name].hasCount then
			count = v.count or count
		end

		local langText = SlashCo.Language("objective_" .. v.name .. (count > 1 and "s" or ""), count)

		local complete = " "
		local r, g, b = 255, 255, 255
		if v.status == SlashCo.ObjStatus.FAILED then
			r, g, b = 255, 64, 64
		elseif v.status == SlashCo.ObjStatus.COMPLETE then
			complete = "X"
		end

		local str = string.format("<font=TVCD_small><color=%s,%s,%s>[%s] %s</color></font>", r, g, b, complete, langText)
		local parsedItem = markup.Parse(str)

		parsedItem:Draw(ScrW() * 0.975 - 4, ScrH() * 0.05 + shift, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

		if v.status == SlashCo.ObjStatus.FAILED then
			surface.SetDrawColor(255, 64, 64, 128)
			surface.DrawRect(ScrW() * 0.975 - 8 - parsedItem:GetWidth(), ScrH() * 0.05 + shift + 6, parsedItem:GetWidth() + 8, 2)
		end

		shift = shift + 14 + 8
	end
end

local function drawItemDisplay(item, notUsable, moveUp, shift)
	if not SlashCoItems[item] then
		return false, 0
	end

	shift = shift or 0
	local y = moveUp and 35 or 0

	local dash = notUsable and "vvv" or "---"
	local space = "   "
	local defaultColor = { 0, 0, 128 }

	if SlashCoItems[item].IsSecondary then
		dash = string.sub(dash, 1, 1)
		defaultColor = { 0, 128, 0 }
		space = "  "
	end

	local str = string.format("<font=TVCD>%s%s%s%s%s</font>", dash, space, string.upper(SlashCo.Language(item)), space, dash)
	local parsedItem = markup.Parse(str)
	surface.SetDrawColor(GameData.LocalPlayer:ItemFunction2OrElse("DisplayColor", item, defaultColor))
	surface.DrawRect(ScrW() * 0.975 - parsedItem:GetWidth() - shift - 8, ScrH() * 0.95 - 24 - y, parsedItem:GetWidth() + 8, 27)
	parsedItem:Draw(ScrW() * 0.975 - 4 - shift, ScrH() * 0.95 - y, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

	if notUsable then
		return true, parsedItem:GetWidth() + 48
	end

	local offset = 0
	if SlashCoItems[item].OnUse then
		draw.SimpleText(SlashCo.Language("item_use", "R"), "TVCD", ScrW() * 0.975 - shift - 8, ScrH() * 0.95 - 30 - y,
				color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		offset = 27
	end
	if not GameData.LocalPlayer:ItemFunction2("PreDrop", item) then
		draw.SimpleText(SlashCo.Language("item_drop", "Q"), "TVCD", ScrW() * 0.975 - shift - 8, ScrH() * 0.95 - 30 - offset - y,
				color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	return true, parsedItem:GetWidth() + 48
end

local function selectCrosshair(hitPos)
	for _, v in pairs(ents.FindInSphere(hitPos, 100)) do
		if v.IsSelectable and not (IsFueling and FuelingCan == v) then
			local gasPos = v:WorldSpaceCenter()
			local trace = util.QuickTrace(hitPos, gasPos - hitPos, GameData.LocalPlayer)
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
	if GameData.LocalPlayer:GetVelocity():Length() <= 250 then
		return
	end

	local lookent = GameData.LocalPlayer:GetEyeTrace().Entity
	if not IsValid(lookent) or lookent:GetClass() ~= "prop_door_rotating" or not SlashCo.CheckDoorWL(lookent) then
		return
	end

	if lookent:GetPos():Distance(GameData.LocalPlayer:GetPos()) >= 150 or lookent.IsOpen then
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

	if IsFueling then
		if not IsValid(FuelingCan) and FuelingCanIndex ~= -1 then
			FuelingCan = Entity(FuelingCanIndex)
		end

		if FuelingCan == NULL then return end -- We don't need IsValid since it here can either be NULL or Valid.

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
			FuelingCanIndex = -1
			FuelingCan = NULL
		end
	end
end

local function hpMeter()
	local hp = GameData.LocalPlayer:Health()

	if hp > (prevHp or maxHp) then
		--reset damage indicator upon healing
		prevHp = math.Clamp(hp, 0, maxHp)
		SetTime = 0
	end

	if CurTime() >= (SetTime or 0) then
		if ShowDamage then
			--update prevHp once the indicator time is up
			prevHp = math.Clamp(hp, 0, maxHp)
			ShowDamage = false
		end

		if hp < (prevHp or 100) then
			--start the damage indicator time
			prevHp1 = math.Clamp(hp, 0, maxHp)
			ShowDamage = true
			SetTime = CurTime() + 2
			healthIndicatorShift = CurTime()
		end
	elseif hp < prevHp1 then
		--reset indicator time if more damage is taken
		prevHp1 = math.Clamp(hp, 0, maxHp)
		SetTime = CurTime() + 2
	end

	local prevHpBar = math.Round(math.Clamp(((prevHp or maxHp) - hp) / maxHp, 0, 1) * 26.9)

	aHp = Lerp(FrameTime() * 3, aHp or 100, hp)
	local parsed

	if hp >= 25 or not GetConVar("slashco_cl_show_lowhealth"):GetBool() then
		local hpOver = math.Clamp(hp - maxHp, 0, maxHp)
		local hpAdjust = math.Clamp(hp, 0, maxHp) - hpOver
		local displayHpBar = math.Round(math.Clamp(hpAdjust / maxHp, 0, 1) * 27)
		local displayHpOverBar = math.Round(math.Clamp(hpOver / maxHp, 0, 1) * 27)
		local displayPrevHpBar = ((CurTime() - healthIndicatorShift) % 0.7 < 0.35) and prevHpBar or 0
		parsed = markup.Parse(string.format("<font=TVCD>%s <colour=0,255,255,255>%s</colour>%s<colour=255,0,0,255>%s</colour></font>",
				SlashCo.Language("HP"),
				string.rep("█", displayHpOverBar),
				string.rep("█", displayHpBar),
				string.rep("█", displayPrevHpBar)
		))
	else
		local displayHpBar = (CurTime() % 0.7 > 0.35) and math.Round(math.Clamp(hp / maxHp, 0, 1) * 27) or 0
		local displayPrevHpBar1 = (CurTime() % 0.7 > 0.35) and prevHpBar or 0
		parsed = markup.Parse(string.format("<font=TVCD>%s <colour=255,255,0,255>%s</colour><colour=255,0,0,255>%s</colour></font>",
				SlashCo.Language("HP"),
				string.rep("█", displayHpBar),
				string.rep("█", displayPrevHpBar1)
		))
	end

	surface.SetDrawColor(0, 0, 128, 255)

	local hpLength = markup.Parse("<font=TVCD>" .. SlashCo.Language("HP") .. "</font>"):GetWidth()

	if not GetConVar("slashco_cl_show_healthvalue"):GetBool() then
		surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 376 + hpLength, 27)
	else
		local displayHp = math.Round(aHp)
		local parsedValue = markup.Parse("<font=TVCD>" .. displayHp .. "</font>")
		surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 386 + parsedValue:GetWidth() + hpLength, 27)
		parsedValue:Draw(ScrW() * 0.025 + 384 + hpLength, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

	parsed:Draw(ScrW() * 0.025 + 4, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

local lastDeathSecond = 0
local lastDeathTime = 0
local skull = Material("slashco/ui/slashco_skull", "noclamp")
local deathward = Material("slashco/ui/deathward", "noclamp")
local deathwardBorken = Material("slashco/ui/deathward_broken", "noclamp")
hook.Add("PreRender", "SlashCo:DeathUI", function()
	if not GameData.LocalPlayer:GetNW2Bool("ShowDeathUI", false) then return end

	local curTime = GameData.LocalPlayer:GetNW2Float("DeathUITime", 0)
	if curTime == 0 then return end

	if lastDeathTime ~= curTime then
		lastDeathSecond = 0
		lastDeathTime = curTime
	end

	--GameData.LocalPlayer:EmitSound("slashco/survivor/deathward.mp3")
	--GameData.LocalPlayer:EmitSound("slashco/survivor/deathward_break" .. math.random(1, 2) .. ".mp3")

	local animTime = (CurTime() - curTime) * 2
	local isDeathWard = GameData.LocalPlayer:GetNW2Bool("DeathWardUI", false)
	if lastDeathSecond ~= math.floor(animTime) then
		lastDeathSecond = math.floor(animTime)

		if lastDeathSecond % 2 == 1 and animTime < 8 and animTime > 2 then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/deathbeep.mp3",
				identifier = "DeathBeep",
				volume = 1,
				fadeIn = 0,
			})
		end

		if lastDeathSecond == 16 and isDeathWard then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/survivor/deathward_break" .. math.random(1, 2) .. ".mp3",
				identifier = "DeathWardBreak",
				volume = 1,
				fadeIn = 0,
			})
		end
	end

	local endTime = isDeathWard and 18 or 7
	if endTime + 2 < animTime then return end -- We were supposed to be done already!

	cam.Start2D()
		local scrW, scrH = ScrW(), ScrH()
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, scrW, scrH)

		if animTime > 2 then
			surface.SetDrawColor(color_white)
			if lastDeathSecond % 2 == 1 and animTime < 8 then
				surface.SetMaterial(skull)
				surface.DrawTexturedRect(scrW / 2 - 128, scrH / 2 - 128, 256, 256)
			end

			if isDeathWard and animTime > 10 then
				local shakeStrength = 25
				if animTime < 16 then
					surface.SetMaterial(deathward)

					if animTime > 13 then
						local scale = 1 + ((animTime - 16) / 3)
						local strength = scale * shakeStrength
						surface.DrawTexturedRect(scrW / 2 - 128 + math.random(-strength, strength), scrH / 2 - 128 + math.random(-strength, strength), 256, 256)
					else
						surface.DrawTexturedRect(scrW / 2 - 128, scrH / 2 - 128, 256, 256)
					end
				else
					surface.SetMaterial(deathwardBorken)

					if animTime > 18 then
						surface.DrawTexturedRect(scrW / 2 - 128 + math.random(-shakeStrength, shakeStrength), scrH / 2 - 128 + math.random(-shakeStrength, shakeStrength), 256, 256)
					else
						surface.DrawTexturedRect(scrW / 2 - 128, scrH / 2 - 128, 256, 256)
					end
				end
			end
		end
	cam.End2D()

	return true
end)

hook.Add("HUDPaint", "SurvivorHUD", function()
	local ply = GameData.LocalPlayer
	
	local team = ply:Team()
	if team == TEAM_LOBBY then
		slamIndicator()
		return
	end

	if team ~= TEAM_SURVIVOR then
		return
	end

	local moveUp = drawItemDisplay(ply:GetItem("item"), ply:GetItem("item2") ~= "none")
	drawItemDisplay(ply:GetItem("item2"), nil, moveUp)

	local hitPos = GameData.LocalPlayer:GetShootPos()
	gasFuelMeter(hitPos)
	selectCrosshair(hitPos)

	hpMeter()
	slamIndicator()
	drawObjectives()
	showScreenMessage()
end)

hook.Add("PlayerButtonDown", "slashco_open_voice", function(ply, button)
	if not IsFirstTimePredicted() or ply:Team() ~= TEAM_SURVIVOR then
		return
	end
	if button == KEY_G then
		vgui.Create("sc_voiceselect")
	end
end)

local chaseLightOffset = Vector(0, 0, 20)
hook.Add("Think", "Slasher_Chasing_Light", function()
	local curTime = CurTime()
	for _, clone in ipairs(ents.FindByClass("sc_crimclone")) do
		if clone:GetMainRageClone() then
			local tlight = DynamicLight(clone:EntIndex())
			if tlight then
				tlight.pos = clone:LocalToWorld(chaseLightOffset)
				tlight.r = 255
				tlight.g = 0
				tlight.b = 255
				tlight.brightness = 5
				local size = 250
				tlight.Decay = size * 4
				tlight.Size = size
				tlight.DieTime = curTime + 1
			end
		end
	end

	for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		if slasher:GetNWBool("TrollgeStage2") then
			local tlight = DynamicLight(slasher:EntIndex())
			if tlight then
				tlight.pos = slasher:LocalToWorld(chaseLightOffset)
				tlight.r = 255
				tlight.g = 0
				tlight.b = 0
				tlight.brightness = 5
				tlight.Decay = 1000
				tlight.Size = 2500
				tlight.DieTime = curTime + 1
			end
			continue
		end

		if slasher:GetNWBool("TylerFlash") then
			local dlight = DynamicLight(slasher:EntIndex())
			if dlight then
				dlight.pos = slasher:LocalToWorld(chaseLightOffset)
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.brightness = 10
				local size = 400
				dlight.Decay = size * 3
				dlight.Size = size
				dlight.DieTime = curTime + 1
			end
			continue
		end

		if not slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("SidGunRage") and not slasher:GetNWBool("WatcherRage") then
			continue
		end

		local dlight = DynamicLight(slasher:EntIndex())
		if dlight then
			dlight.pos = slasher:LocalToWorld(chaseLightOffset)
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.brightness = 6
			local size = 250
			dlight.Decay = size * 4
			dlight.Size = size
			dlight.DieTime = curTime + 1
		end
	end
end)

net.Receive("SlashCo:AskToBecomeSlasher", function()
	system.FlashWindow() -- Flash it to notify them if their tabbed out.
	SlashCo.AudioSystem.PrecacheSound("slashco/deathbeep.mp3", "mono", "AskToBecomeSlasher")

	local timeToAsk = net.ReadUInt(8)
	local startTime = CurTime()
	local fadeTime = 0.5 -- in seconds
	local textColor = Color(255, 255, 255)
	local chooseYes = false
	local chooseTime = 0
	hook.Add("PostDrawHUD", "SlashCo:AskToBecomeSlasher", function()
		local curTime = CurTime()
		local difference = curTime - startTime
		local fadeOut = difference > timeToAsk
		if fadeOut then
			difference = difference - timeToAsk
		end

		local alpha = fadeOut and (255 - (math.Clamp(difference / fadeTime, 0, 1) * 255)) or (math.Clamp(difference / fadeTime, 0, 1) * 255)
		cam.Start2D() -- If we don't do this, we get shifted by like 1 pixel for some reason.
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawRect(0, 0, ScrW(), ScrH()) -- Yes, its shifted for some reason.

			textColor.a = alpha
			draw.SimpleText(SlashCo.Language("ask_to_become_slasher"), "TVCD", ScrW() * 0.5, ScrH() * 0.27, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			if fadeOut or difference > 1 then
				local textAlpha = math.Clamp(fadeOut and 1 or ((difference - 1) / fadeTime), 0, 1) * 255
				if (chooseTime > 0 and not chooseYes) then
					textAlpha = (math.Clamp(chooseTime - curTime, 0, 1) * 255)
				end

				textColor.a = (fadeOut and textAlpha > 0) and alpha or textAlpha
				draw.SimpleText(SlashCo.Language("vocal_yes") .. " - [F1]", "TVCD", ScrW() * 0.5, ScrH() * 0.34, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			if fadeOut or difference > 2 then
				local textAlpha = math.Clamp(fadeOut and 1 or ((difference - 2) / fadeTime), 0, 1) * 255
				if (chooseTime > 0 and chooseYes) then
					textAlpha = (math.Clamp(chooseTime - curTime, 0, 1) * 255)
				end

				textColor.a =  (fadeOut and textAlpha > 0) and alpha or textAlpha
				draw.SimpleText(SlashCo.Language("vocal_no") .. " - [F2]", "TVCD", ScrW() * 0.5, ScrH() * 0.38, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			if not fadeOut and chooseTime <= 0 then
				if input.IsButtonDown(KEY_F1) then
					chooseTime = CurTime() + fadeTime
					chooseYes = true
					SlashCo.AudioSystem.PlayPrecachedChannel("AskToBecomeSlasher")
					net.Start("SlashCo:AskToBecomeSlasher")
						net.WriteBool(true)
					net.SendToServer()
				elseif input.IsButtonDown(KEY_F2) then
					chooseTime = CurTime() + fadeTime
					chooseYes = false
					SlashCo.AudioSystem.PlayPrecachedChannel("AskToBecomeSlasher")
					net.Start("SlashCo:AskToBecomeSlasher")
						net.WriteBool(false)
					net.SendToServer()
				end
			end
		cam.End2D()
	end)
end)

net.Receive("SlashCo:Announcement", function()
	system.FlashWindow() -- Flash it to notify them if their tabbed out.

	local timeToDisplay = net.ReadUInt(8)
	local text = net.ReadString()
	local startTime = CurTime()
	local fadeTime = 0.5 -- in seconds
	local textColor = Color(255, 255, 255)
	hook.Add("PostDrawHUD", "SlashCo:AskToBecomeSlasher", function()
		local curTime = CurTime()
		local difference = curTime - startTime
		local fadeOut = difference > timeToDisplay
		if fadeOut then
			difference = difference - timeToDisplay
		end

		local alpha = fadeOut and (255 - (math.Clamp(difference / fadeTime, 0, 1) * 255)) or (math.Clamp(difference / fadeTime, 0, 1) * 255)
		cam.Start2D() -- If we don't do this, we get shifted by like 1 pixel for some reason.
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawRect(0, 0, ScrW(), ScrH()) -- Yes, its shifted for some reason.

			textColor.a = alpha
			draw.SimpleText(SlashCo.Language("server_announcement"), "TVCD", ScrW() * 0.5, ScrH() * 0.27, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			if fadeOut or difference > 1 then
				local textAlpha = math.Clamp(fadeOut and 1 or ((difference - 1) / fadeTime), 0, 1) * 255
				textColor.a = (fadeOut and textAlpha > 0) and alpha or textAlpha
				draw.SimpleText(text, "TVCD", ScrW() * 0.5, ScrH() * 0.34, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		cam.End2D()
	end)
end)