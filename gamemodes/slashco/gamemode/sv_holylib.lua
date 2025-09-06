if not HolyLib or not pvs then
	return
end

--[[
	This file contains anything related to HolyLib -> https://holylib.raphaelit7.com/
]]

hook.Add("HolyLib:PreCheckTransmit", "NetworkPlayers", function(ply)
	pvs.AddEntityToTransmit(team.GetPlayers(TEAM_SURVIVOR)) -- Always network all survivors
	pvs.AddEntityToTransmit(team.GetPlayers(TEAM_SLASHER)) -- Always network all slashers
	-- Gmod only has AddOriginToPVS which is shit.
end)