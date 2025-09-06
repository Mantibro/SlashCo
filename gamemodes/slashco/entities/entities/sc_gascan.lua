AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "GasCan"
ENT.ClassName = "sc_gascan"

--[[
if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

		local index = self:EntIndex()
		SlashCo.ItemPickUp(activator, index, "GasCan")
	end
end
--]]

if CLIENT then return end

function ENT:Think()
	local curTime = CurTime()
	self:NextThink(curTime + 0.5)

	if SlashCo.OverTime > SlashCo.GetRoundTime() then
		return true
	end

	local nearbyFuelCans = 0 -- If multiple fuel cans are nearby, we play sounds more likely to play a sound. Why? Because when Tyler for example decides to make a funny pile, we want everyone to know where it is.
	local class = self:GetClass()
	for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 200)) do
		if ent:GetClass() == class then
			nearbyFuelCans = nearbyFuelCans + 1
		end
	end

	if math.random(1, math.max(50 - math.min(nearbyFuelCans * 3, 35), 1)) == 1 then
		nearbyFuelCans = math.max(nearbyFuelCans, 1) -- Just for the math below to play nice.
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/canisterheavyimpact" .. math.random(1, 3) .. ".mp3",
			identifier = "FuelCanSound",
			minDistance = 100 + (150 * SlashCo.MapSize * math.min(nearbyFuelCans, 5)), -- It should at best only multiply by 5 fuel cans or else the range can become too big.
			maxDistance = 500 + (400 * SlashCo.MapSize * math.min(nearbyFuelCans, 5)),
			entity = self,
			volume = 0.5,
			fadeIn = 0,
		})
	end

	return true
end