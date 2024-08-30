hook.Add("PlayerButtonDown", "SpectatorFunctions", function(ply, button)
	if ply:Team() ~= TEAM_SPECTATOR then
		return
	end
	if CurTime() - GetGlobalFloat("SCStartTime", 99999999999999) < SlashCo.GhostPingDelay then
		return
	end
	if button ~= MOUSE_MIDDLE then
		return
	end
	if ply.LastPinged and CurTime() - ply.LastPinged < 30 then
		return
	end

	ply:SurvivorPing()
end)