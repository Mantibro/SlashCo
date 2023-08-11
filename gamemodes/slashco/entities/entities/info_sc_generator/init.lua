ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

function ENT:OnSpawn()
	local Ent = ents.Create("sc_generator")
	local pos, ang = self:GetPos(), self:GetAngles()

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create a generator at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()

	return Ent
end