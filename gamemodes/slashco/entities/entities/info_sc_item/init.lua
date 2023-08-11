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

function ENT:OnSpawn()
	local item
	if self.Item and SlashCoItems[self.Item] then
		item = self.Item
	else
		item = SlashCo.SpawnableItems[math.random(1, #SlashCo.SpawnableItems)]
	end
	self.Item = nil

	local id = SlashCo.CreateItem(SlashCoItems[item].EntClass, self:GetPos(), self:GetAngles())
	SlashCo.CurRound.Items[id] = true
	return Entity(id)
end