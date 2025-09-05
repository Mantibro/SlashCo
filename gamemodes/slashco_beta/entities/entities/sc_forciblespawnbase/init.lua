ENT.Type = "point"
ENT.Base = "sc_spawnbase"

function ENT:ExtraKeyValue1()
	--override me!
end

function ENT:ExtraKeyValue(key, value)
	local key1 = string.lower(key)
	if key1 == "forced" then
		self.Forced = tonumber(value) == 1
		return
	end

	self:ExtraKeyValue1(key, value)
end