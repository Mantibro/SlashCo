local PLAYER = FindMetaTable("Player")

function PLAYER:AddSpeedEffect(key, speed, priority)
	local tbl = self.SpeedEffects
	if not tbl then
		tbl = {}
		self.SpeedEffects = tbl
	end

	tbl[key] = { speed, priority }
	self:UpdateSpeed()
end

function PLAYER:RemoveSpeedEffect(key)
	local tbl = self.SpeedEffects
	if not tbl then
		tbl = {}
		self.SpeedEffects = tbl
	end

	tbl[key] = nil
	self:UpdateSpeed()
end

local BASE_RUN_SPEED = 300
local BASE_WALK_SPEED = 200
local BASE_SLOW_WALK_SPEED = 100
function PLAYER:UpdateSpeed()
	local highestPriority = -9999
	local highestPrioritySpeed
	for _, v in pairs(self.SpeedEffects or {}) do
		if v[2] > highestPriority then
			highestPriority = v[2]
			highestPrioritySpeed = v[1]
		end
	end

	if highestPriority == -9999 then
		self:SetRunSpeed(BASE_RUN_SPEED)
		self:SetWalkSpeed(BASE_WALK_SPEED)
		self:SetSlowWalkSpeed(BASE_SLOW_WALK_SPEED)
	else
		self:SetRunSpeed(highestPrioritySpeed)
		self:SetWalkSpeed(math.min(highestPrioritySpeed, BASE_WALK_SPEED))
		self:SetSlowWalkSpeed(math.min(highestPrioritySpeed, BASE_SLOW_WALK_SPEED))
	end
end

local function ResetSpeed(ply)
	if ply.SpeedEffects then
		ply.SpeedEffects = {}
		ply:UpdateSpeed()
	end
end

hook.Add("PlayerDeath", "SlashCo:ResetSpeedEffects", ResetSpeed)
hook.Add("PlayerSilentDeath", "SlashCo:ResetSpeedEffectsSilent", ResetSpeed)