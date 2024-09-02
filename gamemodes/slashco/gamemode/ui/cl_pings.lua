local global_pings = {}

local red = Color(255, 64, 64)
local green = Color(64, 255, 64)
local blue = Color(64, 64, 255)
local transp = Color(255, 255, 255, 180)

local pingType = {
	ITEM = function(v)
		return v.Name or "Item"
	end,
	SURVIVOR = function(v)
		return v.SurvivorName, blue
	end,
	SLASHER = function()
		return nil, red
	end,
	GENERATOR = function()
		return nil, green
	end,
	GHOST = function()
		return "?????", transp
	end
}

local function removePing(key)
	global_pings[key] = nil
end

local function findPos(search)
	if IsEntity(search) then
		return search:WorldSpaceCenter()
	elseif isvector(search) then
		return search
	end

	return vector_origin
end

net.Receive("mantislashcoSurvivorPings", function()
	local ping = net.ReadTable()

	for k, v in pairs(global_pings) do
		if v.Player == ping.Player then
			removePing(k)
			break
		end
	end

	if ping.Type == "GENERATOR" then
		LocalPlayer():EmitSound("slashco/ping_generator.mp3")
	elseif ping.Type ~= "LOOK HERE" and ping.Type ~= "LOOK AT THIS" and ping.Type ~= "GHOST" then
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

--ping display
hook.Add("HUDPaint", "PingDisplay", function()
	if LocalPlayer():Team() == TEAM_SLASHER then
		global_pings = {}
		return
	end

	for k, v in pairs(global_pings) do
		if v.Entity == nil then
			removePing(k)
			continue
		end

		if type(v.Entity) ~= "Vector" and not IsValid(v.Entity) then
			removePing(k)
			continue
		end

		if v.Type ~= "GHOST" and not IsValid(v.Player) then
			removePing(k)
			continue
		end

		local showText, textColor, pos
		if pingType[v.Type] then
			showText, textColor, pos = pingType[v.Type](v)
		end
		showText = showText or v.Type or "INVALID"
		textColor = textColor or color_white
		pos = pos or (findPos(v.Entity)):ToScreen()

		if IsValid(v.Player) then
			draw.SimpleText(v.Player:GetName(), "TVCD_small", pos.x, pos.y - 25, transp,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText("[" .. string.upper(SlashCo.Language(showText)) .. "]", "TVCD", pos.x, pos.y, textColor, TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER)
	end

	for _, v in ipairs(ents.FindByClass("sc_flare")) do
		if not v:GetNWBool("FlareActive") then
			continue
		end

		local fl_pos = v:WorldSpaceCenter():ToScreen()

		draw.SimpleText(v:GetNWString("FlareDropperName"), "TVCD_small", fl_pos.x, fl_pos.y - 25,
				Color(255, 255, 255, 180),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("[ ☆ ]", "TVCD", fl_pos.x, fl_pos.y, textColor, TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER)
		draw.SimpleText(tostring(math.floor(LocalPlayer():GetPos():Distance(v:GetPos()) * 0.0254)) .. " m",
				"TVCD_small", fl_pos.x, fl_pos.y + 25, Color(255, 255, 255, 180),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)