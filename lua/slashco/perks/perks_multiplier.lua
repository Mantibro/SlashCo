function SlashCo.GetFoodHealMultiplier(ply)
	if not IsValid(ply) then return 1 end
	if ply:Team() ~= TEAM_SURVIVOR then return 1 end

	local multiplier = 1

	if SlashCo.IsActivePerk(ply, "Healthy") then
		multiplier = multiplier + 0.5
	end

	if SlashCo.IsActivePerk(ply, "Glutton") then
		multiplier = multiplier - 0.5
	end

	return math.max(multiplier, 0)
end

function SlashCo.GetConsumableEffectDuration(ply, duration)
	if not IsValid(ply) then return duration end
	if ply:Team() ~= TEAM_SURVIVOR then return duration end

	if SlashCo.IsActivePerk(ply, "Glutton") then
		duration = duration * 2
	end

	return duration
end