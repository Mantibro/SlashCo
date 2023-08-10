ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

function ENT:ExtraKeyValue1(key, value)
	local key1 = string.lower(key)
	if key1 == "gascan" then
		self.IsGasCanSpawn = tonumber(value) == 1
		return
	end
	if key1 == "item" then
		self.Item = value
		return
	end
end