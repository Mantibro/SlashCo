ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

SlashCo.BatterySpawns = SlashCo.BatterySpawns or {
	_noname = {}
}

function ENT:Initialize()
	if self.Legacy then return end

	if self.GenToFind then
		local tbl = SlashCo.BatterySpawns[self.GenToFind]
		if not tbl then
			tbl = {}
			SlashCo.BatterySpawns[self.GenToFind] = tbl
		end

		table.insert(tbl, self)
	else
		table.insert(SlashCo.BatterySpawns._noname, self)
	end
end

function ENT:ExtraKeyValue1(key, value)
	local key1 = string.lower(key)
	if key1 == "generator" then
		self.GenToFind = value
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
	Ent:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

	return Ent
end