local PLAYER = FindMetaTable("Player")

SlashCo.SpeedEffects = SlashCo.SpeedEffects or {}

local function getPly(ply)
	SlashCo.SpeedEffects[ply:UserID()] = SlashCo.SpeedEffects[ply:UserID()] or {}
	return SlashCo.SpeedEffects[ply:UserID()]
end

function PLAYER:AddSpeedEffect(key, speed, priority)
	local tbl = getPly(self)
	tbl[key] = { speed, priority }
	self:UpdateSpeed()
end

function PLAYER:RemoveSpeedEffect(key)
	local tbl = getPly(self)
	tbl[key] = nil
	self:UpdateSpeed()
end

local BASE_RUN_SPEED = 300
local BASE_WALK_SPEED = 200
local BASE_SLOW_WALK_SPEED = 100
function PLAYER:UpdateSpeed()
	local highestPriority = -9999
	local highestPrioritySpeed
	for _, v in pairs(getPly(self)) do
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

timer.Create("EnsureCorrectSpeed", 1, 0, function()
	for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		v:UpdateSpeed()
	end
end)

hook.Add("PlayerDeath", "slashCoResetSpeedEffects", function(victim)
	SlashCo.SpeedEffects[victim:UserID()] = {}
end)

hook.Add("PlayerSilentDeath", "slashCoResetSpeedEffectsSilent", function(victim)
	SlashCo.SpeedEffects[victim:UserID()] = {}
end)