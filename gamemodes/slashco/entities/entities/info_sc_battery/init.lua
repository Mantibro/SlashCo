ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

function ENT:ExtraKeyValue1(key, value)
	local key1 = string.lower(key)
	if key1 == "generator" then
		local gens = ents.FindByName(value)
		if table.IsEmpty(gens) then
			gens = ents.FindByClass("info_sc_generator")

			if table.IsEmpty(gens) then
				return
			end
		end

		self.Generators = gens
		for _, v in ipairs(gens) do
			v.BatterySpawns = v.BatterySpawns or {}
			v.BatterySpawns[self] = true
		end

		return
	end
end