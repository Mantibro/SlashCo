ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

function ENT:OnSpawn()
	return SlashCo.CreateGasCan(self:GetPos(), self:GetAngles())
end