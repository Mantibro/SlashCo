AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Battery"
ENT.ClassName = "sc_battery"

if CLIENT then return end

function ENT:Think()
	local curTime = CurTime()
	self:NextThink(curTime + 0.5)

	if SlashCo.OverTime > SlashCo.GetRoundTime() then
		return true
	end

	local nearbyBatteries = 0 -- If multiple fuel cans are nearby, we play sounds more likely to play a sound. Why? Because when Tyler for example decides to make a funny pile, we want everyone to know where it is.
	local class = self:GetClass()
	for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 200)) do
		if ent:GetClass() == class then
			nearbyBatteries = nearbyBatteries + 1
		end
	end

	if math.random(1, math.max(50 - math.min(nearbyBatteries * 3, 35), 1)) == 1 then
		nearbyBatteries = math.max(nearbyBatteries, 1) -- Just for the math below to play nice.
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/batteryheavy1.mp3",
			identifier = "BatterySound",
			minDistance = 200 + (200 * SlashCo.MapSize * math.min(nearbyBatteries, 5)), -- It should at best only multiply by 5 fuel cans or else the range can become too big.
			maxDistance = 750 + (500 * SlashCo.MapSize * math.min(nearbyBatteries, 5)),
			entity = self,
			volume = 0.5,
			fadeIn = 0,
		})
	end

	return true
end