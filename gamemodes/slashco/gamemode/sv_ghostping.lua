hook.Add("PlayerButtonDown", "SpectatorFunctions", function(ply, button)
	if ply:Team() ~= TEAM_SPECTATOR then
		return
	end
	if not GetGlobalBool("SpectatorsCanPing") then
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