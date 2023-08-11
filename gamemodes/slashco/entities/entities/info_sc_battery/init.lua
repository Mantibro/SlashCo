ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

function ENT:Initialize()
	timer.Simple(0.25, function()
		if IsValid(self) and not self.Generators then
			local gens = ents.FindByClass("info_sc_generator")

			if table.IsEmpty(gens) then
				return
			end

			self.Generators = gens
			for _, v in ipairs(gens) do
				v.BatterySpawns = v.BatterySpawns or {}
				v.BatterySpawns[self] = true
			end
		end
	end)
end

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

function ENT:OnSpawn()
	local Ent = ents.Create("sc_battery")
	local pos, ang = self:GetPos(), self:GetAngles()

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create a battery at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	return Ent
end