ENT.Type = "point"

SlashCo = SlashCo or {}

function ENT:Initialize()
	--override me!
end

function ENT:KeyValue(key, value)
	if string.sub(key, 1, 2) == "On" then
		self:StoreOutput(key, value)
		return
	end

	local valNum = tonumber(value)
	if valNum and valNum < 0 then
		return
	end

	local key1 = string.lower(key)
	if key1 == "generators_needed" then
		SetGlobal2Int("SlashCoGeneratorsNeeded", valNum)
		return
	end
	if key1 == "generators_spawned" then
		SetGlobal2Int("SlashCoGeneratorsToSpawn", valNum)
		return
	end
	if key1 == "gascans_needed" then
		SetGlobal2Int("SlashCoGasCansPerGenerator", valNum)
		return
	end
	if key1 == "gascans_spawned" then
		SetGlobal2Int("SlashCoGasCansToSpawn", valNum)
		return
	end
end

function ENT:AcceptInput(name, activator, _, value)
	if string.sub(name, 1, 2) == "On" then
		self:TriggerOutput(name, activator)
		return true
	end

	--do not let the entity change anything if the round already started
	if SlashCo and SlashCo.RoundStarted then
		return
	end

	local valNum = tonumber(value)
	if valNum and valNum < 0 then
		return
	end

	local name1 = string.lower(name)
	if name1 == "set_generators_needed" then
		SetGlobal2Int("SlashCoGeneratorsNeeded", valNum)
		return true
	end
	if name1 == "set_generators_spawned" then
		SetGlobal2Int("SlashCoGeneratorsToSpawn", valNum)
		return true
	end
	if name1 == "set_gascans_needed" then
		SetGlobal2Int("SlashCoGasCansPerGenerator", valNum)
		return true
	end
	if name1 == "set_gascans_spawned" then
		SetGlobal2Int("SlashCoGasCansToSpawn", valNum)
		return true
	end
end