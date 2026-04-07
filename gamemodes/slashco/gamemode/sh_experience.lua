SlashCo.FirstLevelBase = 200 -- For the first level
SlashCo.LevelPowMultiplier = 1.5  -- For every level you'll need 1.5x the experience of the previous one
SlashCo.StartPP = 1 -- Start perk points
SlashCo.PPsPerLevel = 0.5 -- perk points per level 0.5 = every two level 1

function SlashCo.ExperienceToLevel(experience)
	local level = 0
	local nextLevel = SlashCo.FirstLevelBase
	while experience >= nextLevel do
		level = level + 1
		experience = experience - nextLevel
		nextLevel = math.floor(nextLevel * SlashCo.LevelPowMultiplier)
	end

	return level, experience, nextLevel
end

function SlashCo.LevelToPPs(level)
	return SlashCo.StartPP + (level * SlashCo.PPsPerLevel)
end