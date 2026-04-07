ENT.Type = "point"
ENT.Base = "sc_forciblespawnbase"

function ENT:OnSpawn()
	return SlashCo.CreateDocument(self:GetPos(), self:GetAngles())
end