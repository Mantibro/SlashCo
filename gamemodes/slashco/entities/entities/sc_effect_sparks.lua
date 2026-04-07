--[[
	Map entity meant to only be used in the Lobby.
]]

ENT.Type = "point"

if CLIENT then return end

GameData.SparkNames = GameData.SparkNames or {}
function ENT:Initialize()
	if self.SparkName then
		local SparkName = self.SparkName
		local groupSparks = GameData.SparkNames[SparkName]
		if not groupSparks then
			groupSparks = {}
			GameData.SparkNames[SparkName] = groupSparks
		end

		groupSparks[self] = true
	end
end

function ENT:OnRemove()
	local groupSparks = GameData.SparkNames[self.SparkName]
	if not groupSparks or not groupSparks[self] then return end

	groupSparks[self] = nil
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "spark_name" then
		self.SparkName = key
		return
	end
end

function ENT:DoSpark()

end