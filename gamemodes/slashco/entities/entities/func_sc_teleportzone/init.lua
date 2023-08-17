ENT.Type = "brush"
ENT.Base = "sc_spawnbase"

function ENT:ExtraKeyValue(key, value)
	local key1 = string.lower(key)
	if key1 == "exclusive" then
		self.IsExclusive = tonumber(value) == 1
		return
	end
end

function ENT:Initialize()
	self.TimerIndex = math.random(1000000000)
end

function ENT:OnSpawn()
	timer.Create("SlashCoSpawn_" .. self.TimerIndex, 1, 1, function()
		self.SpawnedEntity = nil
	end)
end