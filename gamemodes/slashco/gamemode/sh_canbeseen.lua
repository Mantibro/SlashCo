local PLAYER = FindMetaTable("Player")

function PLAYER:CanBeSeen()
	local _team = self:Team()
	if _team == TEAM_SURVIVOR then
		local override = self:ItemFunction("CanBeSeen")
		if override ~= nil then
			return override
		end
	elseif _team == TEAM_SLASHER then
		local override = self:SlasherFunction("CanBeSeen")
		if override ~= nil then
			return override
		end

		if CLIENT and GameData.LocalPlayer:Team() == TEAM_SPECTATOR and self:SlasherValue("CannotBeSpectated") then
			return false
		end
	elseif _team == TEAM_SPECTATOR then
		return false
	end

	return self:GetVisible()
end

function PLAYER:CanSeeFlashlights()
	local _team = self:Team()
	if _team == TEAM_SURVIVOR then
		local override = self:ItemFunction("CanSeeFlashlights")
		if override ~= nil then
			return override
		end
	elseif _team == TEAM_SLASHER then
		local override = self:SlasherFunction("CanSeeFlashlights")
		if override ~= nil then
			return override
		end
	end

	-- RaphaelIT7: Deprecated? We can probably just return true here once we remove CanSeeFlashlights
	return self:GetCanSeeFlashlights()
end

--[[
	Returns whether the player is visible (NOT accounting for item or slasher effects! Use CanBeSeen if you need to account for those)
	
	RaphaelIT7:
	SetVisible is created by SetupSlashCoNetworkVar!
]]
PLAYER.IsVisible = PLAYER.GetVisible

if CLIENT then
	hook.Add("Think", "SlashCo:HidePlayers", function()
		for _, ply in player.Iterator() do
			local seeable = ply:CanBeSeen()
			if ply.Seeable ~= seeable then
				if pac then
					pac.TogglePartDrawing(ply, seeable)
				end

				-- RaphaelIT7: We do not call SetColor as we already use PrePlayerDraw
				ply:DrawShadow(seeable)
				ply.Seeable = seeable
			end
		end
	end)

	hook.Add("PrePlayerDraw", "SlashCo:HidePlayers", function(ply)
		if not ply:CanBeSeen() then
			return true
		end
	end)

	return
end

hook.Add("Think", "SlashCo:HidePlayers", function()
	for _, ply in player.Iterator() do
		local seeable = ply:CanBeSeen()
		if ply.Seeable ~= seeable then
			ply:SetNoDraw(not seeable)
			ply:DrawShadow(seeable)
			ply.Seeable = seeable
		end
	end
end)