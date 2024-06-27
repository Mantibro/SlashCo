ENT.Type = "point"
ENT.Base = "sc_spawnbase"
ENT.Team = TEAM_SLASHER

function ENT:Initialize()
	self.TimerIndex = math.random(1000000000)
end

function ENT:OnSpawn()
	timer.Create("SlashCoSpawn_" .. self.TimerIndex, 5, 1, function()
		self.SpawnedEntity = nil
	end)
end