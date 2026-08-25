local red = Color(255, 64, 64)
local green = Color(64, 255, 64)
local blue = Color(64, 64, 255)
local transp = Color(255, 255, 255, 180)
local pingType = {
	ITEM = function(pingInfo)
		return pingInfo.Name or "Item"
	end,
	SURVIVOR = function(pingInfo)
		return pingInfo.Name, blue
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
local FadeTime = 15 -- After this many seconds the transparency will be reduced

GameData.ActivePings = GameData.ActivePings or {}
hook.Add("SlashCo:ServerEntityRemoved", "SlashCo:Pings", function(entIndex) -- Cleanup :3
	for idx, pingInfo in ipairs(GameData.ActivePings) do
		if (pingInfo.Entity and pingInfo.Entity == entIndex) or (pingInfo.Player and pingInfo.Player == entIndex) then
			table.remove(GameData.ActivePings, idx)
			continue
		end
	end
end)

local function findPos(pingInfo)
	if pingInfo.Entity then
		local ent = Entity(pingInfo.Entity)
		if IsValid(ent) then
			if ent.GetPingPos then
				return ent:GetPingPos()
			end

			return ent:WorldSpaceCenter()
		end
	elseif pingInfo.Position then
		return pingInfo.Position
	end

	return vector_origin
end

local function shouldRemovePing(idx, pingInfo, newPing)
	if not pingInfo.Permanent and pingInfo.Player == newPing.Player then
		return true
	end

	if pingInfo.Entity and pingInfo.Entity == newPing.Entity and pingInfo.Team == newPing.Team then
		return true
	end

	return false
end

local function antiDupePings(newPing)
	if not newPing.Player then
		return
	end

	local idx = 0
	while idx <= #GameData.ActivePings do
		idx = idx + 1
		local pingInfo = GameData.ActivePings[idx]
		if not pingInfo then break end

		if shouldRemovePing(idx, pingInfo, newPing) then
			table.remove(GameData.ActivePings, idx)
			idx = idx - 1 -- table.remove shifted all entries! so we must check the same index again!
		end
	end
end

net.Receive("SlashCo:SurvivorPings", function()
	local fullUpdate = net.ReadBool()
	if fullUpdate then
		GameData.ActivePings = {}
	end

	local count = net.ReadUInt(7)
	for k=1, count do
		local pingInfo = {
			ID = net.ReadUInt(16),
			ExpiryTime = SlashCo.ReadOptional(net.ReadFloat),
			Team = net.ReadUInt(10),
			Type = net.ReadString(),
			Name = SlashCo.ReadOptional(net.ReadString),
			Player = SlashCo.ReadOptional(net.ReadUInt, MAX_EDICT_BITS),
			Entity = SlashCo.ReadOptional(net.ReadUInt, MAX_EDICT_BITS),
			Position = SlashCo.ReadOptional(net.ReadVector),
		}

		if not pingInfo.ExpiryTime then
			pingInfo.Permanent = true
		end

		antiDupePings(pingInfo)
		if not fullUpdate then
			local skipSound = hook.Run("SlashCo:OnPing", pingInfo)
			if not skipSound and pingInfo.Team ~= TEAM_SLASHER then
				if pingInfo.Type == "GENERATOR" then
					GameData.LocalPlayer:EmitSound("slashco/ping_generator.mp3")
				elseif pingInfo.Type ~= "LOOK HERE" and pingInfo.Type ~= "LOOK AT THIS" and pingInfo.Type ~= "GHOST" then
					GameData.LocalPlayer:EmitSound("slashco/ping_item.mp3")
				end
			end
		end

		pingInfo.FadeTime = CurTime() + FadeTime
		table.insert(GameData.ActivePings, pingInfo)
	end
end)

--ping display
-- RaphaelIT7: Why don't we remove pings? Because we can NEVER be certain here, an entity may be outside the PVS, may not have been networked yet and so on
--             and since a round doesn't go that long, we can accept it filling up a bit.
hook.Add("SlashCo:DrawHUD", "SlashCo:PingDisplay", function()
	local curTime = CurTime()
	local renderedEntities = {}
	local plyTeam = GameData.LocalPlayer:Team()
	local idx = 0
	while idx <= #GameData.ActivePings do
		idx = idx + 1
		local pingInfo = GameData.ActivePings[idx]
		if not pingInfo then break end

		if not SlashCo.CanSeePing(plyTeam, pingInfo.Team) then
			continue
		end

		if not pingInfo.Entity and not pingInfo.Position then
			table.remove(GameData.ActivePings, idx)
			idx = idx - 1 -- table.remove shifted all entries! so we must check the same index again!
			continue
		end

		if not pingInfo.Permanent and pingInfo.ExpiryTime and curTime > pingInfo.ExpiryTime then
			table.remove(GameData.ActivePings, idx)
			idx = idx - 1 -- table.remove shifted all entries! so we must check the same index again!
			continue
		end

		if pingInfo.Entity then
			-- If two pings had pinged the same entity, then we don't want to render multiple names on top of each other.
			-- So instead, we render the first entry and block all others, so spectators, for example will only see the first team that pinged a generator.
			-- Like if a survivor pings a generator, and then a slasher, a spectator just sees the survivor ping.
			if renderedEntities[pingInfo.Entity] then
				continue
			end

			if not IsValid(Entity(pingInfo.Entity)) then
				continue
			end

			renderedEntities[pingInfo.Entity] = true
		end

		local ply = pingInfo.Player and Entity(pingInfo.Player) or NULL
		if pingInfo.Type ~= "GHOST" and not IsValid(ply) then
			continue
		end

		local showText, textColor, pos
		if pingType[pingInfo.Type] then
			showText, textColor, pos = pingType[pingInfo.Type](pingInfo)
		end
		showText = showText or pingInfo.Type or "INVALID"
		local nameColor = transp
		if pingInfo.Team == TEAM_SLASHER then
			textColor = red
			nameColor = red
		else
			textColor = textColor or color_white
		end
		pos = pos or findPos(pingInfo):ToScreen()

		surface.SetAlphaMultiplier(Lerp(1 - math.max((pingInfo.FadeTime - CurTime()) / FadeTime, 0), 1, 0.1))

		if IsValid(ply) then
			draw.SimpleText(ply:GetName(), "TVCD_small", pos.x, pos.y - 25, nameColor,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText("[" .. string.upper(SlashCo.Language(showText)) .. "]", "TVCD", pos.x, pos.y, textColor, TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER)

		surface.SetAlphaMultiplier(1)
	end

	for _, v in ipairs(ents.FindByClass("sc_flare")) do
		if not v:GetNWBool("FlareActive") then
			continue
		end

		local fl_pos = v:WorldSpaceCenter():ToScreen()

		draw.SimpleText(v:GetNWString("FlareDropperName"), "TVCD_small", fl_pos.x, fl_pos.y - 25,
				transp,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("[ ☆ ]", "TVCD", fl_pos.x, fl_pos.y, textColor, TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER)
		draw.SimpleText(tostring(math.floor(GameData.LocalPlayer:GetPos():Distance(v:GetPos()) * 0.0254)) .. " m",
				"TVCD_small", fl_pos.x, fl_pos.y + 25, transp,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)