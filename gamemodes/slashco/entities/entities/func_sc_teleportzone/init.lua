ENT.Type = "brush"
ENT.Base = "sc_spawnbase"

function ENT:ExtraKeyValue(key, value)
	local key1 = string.lower(key)
	if key1 == "exclusive" then
		self.IsExclusive = tonumber(value) == 1
		return
	end
end