ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

function ENT:ExtraKeyValue1(key, value)
	local key1 = string.lower(key)
	if key1 == "generator" then
		local gens = ents.FindByName(value)
		local gen
		if not table.IsEmpty(gens) then
			gen = gens[1]
		end
		if not IsValid(gen) then
			return
		end

		self.Generator = gen
		gen.BatterySpawns = gen.BatterySpawns or {}
		gen.BatterySpawns[self] = true
		--table.insert(gen.BatterySpawns, self)
		return
	end
end