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

	key = string.lower(key)
	if key == "generators_needed" then
		SlashCo.SetGeneratorsNeeded(valNum)
		return
	end

	if key == "generators_spawned" then
		SlashCo.SetGeneratorsToSpawn(valNum)
		return
	end

	if key == "gascans_needed" then
		SlashCo.GasCansPerGenerator(valNum)
		return
	end

	if key == "gascans_spawned" then
		SlashCo.SetGasCansToSpawn(valNum)
		return
	end

	if key == "islobby" and tobool(value) then
		GameData.IsLobby = true -- NOTE: This value is networked for clients inside GM:InitPostEntity() -> sh_shared.lua
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

	name = string.lower(name)
	if name == "set_generators_needed" then
		SlashCo.SetGeneratorsNeeded(valNum)
		return true
	end

	if name == "set_generators_spawned" then
		SlashCo.SetGeneratorsToSpawn(valNum)
		return true
	end

	if name == "set_gascans_needed" then
		SlashCo.GasCansPerGenerator(valNum)
		return true
	end

	if name == "set_gascans_spawned" then
		SlashCo.SetGasCansToSpawn(valNum)
		return true
	end
end