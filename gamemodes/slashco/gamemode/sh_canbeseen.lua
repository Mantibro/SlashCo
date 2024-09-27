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

		if CLIENT and LocalPlayer():Team() == TEAM_SPECTATOR and self:SlasherValue("CannotBeSpectated") then
			return false
		end
	elseif _team == TEAM_SPECTATOR then
		return false
	end

	return self:GetNWBool("SlashCoVisible", true)
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

	return self:GetNWBool("SlashCoSeeFlashlights", true)
end

if CLIENT then
	hook.Add("Think", "hidePlayersIfCannotSee", function()
		for _, ply in player.Iterator() do
			local seeable = ply:CanBeSeen()
			if ply.Seeable ~= seeable then
				if pac then pac.TogglePartDrawing(ply, seeable) end
				ply:SetColor(seeable and color_white or color_transparent)

				ply.Seeable = seeable
			end
		end
	end)

	hook.Add("PrePlayerDraw", "hidePlayersIfCannotSee", function(ply)
		if not ply:CanBeSeen() then
			return true
		end
	end)

	return
end

function PLAYER:SetVisible(state)
	self:SetNWBool("SlashCoVisible", state)
end

function PLAYER:SetCanSeeFlashlights(state)
	self:SetNWBool("SlashCoSeeFlashlights", state)
end

hook.Add("Think", "hidePlayersIfCannotSee", function()
	for _, ply in player.Iterator() do
		local seeable = ply:CanBeSeen()
		if ply.Seeable ~= seeable then
			ply:SetColor(seeable and color_white or invis)
			ply:SetNoDraw(not seeable)
			ply.Seeable = seeable
		end
	end
end)