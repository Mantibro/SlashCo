ENT.Type = "point"
ENT.Base = "sc_spawnbase"
ENT.Team = TEAM_SURVIVOR

function ENT:OnSpawn()
	timer.Create("SlashCoSpawn_" .. self:GetCreationID(), 5, 1, function()
		self.SpawnedEntity = nil
	end)
end