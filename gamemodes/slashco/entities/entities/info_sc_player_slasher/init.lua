ENT.Type = "point"
ENT.Base = "sc_spawnbase"
ENT.Team = TEAM_SLASHER

function ENT:OnSpawn()
	timer.Create("SlashCoSpawn_" .. self:GetCreationID(), 5, 1, function()
		self.SpawnedEntity = nil
	end)
end