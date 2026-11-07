--[[
]]

GameData.FogData = GameData.FogData or {}
SlashCo.FogType = {
	PLAYER = 1,
	TEAM = 2,
	GLOBAL = 3
}

--[[SlashCo.FogHandleType = {
	SET, -- Sets the fog multiplier
	ADD -- Adds the multiplier on top of existing ones
}]]

local skyBoxVec = Vector(0, 0, 100000)
local matchingFogs = {}

local function SortFogByPriority(fogInfo1, fogInfo2)
	if fogInfo1.priority ~= fogInfo2.priority then
		return fogInfo1.priority < fogInfo2.priority
	end

	return (fogInfo1.name or "") < (fogInfo2.name or "")
end

function SlashCo.GetCurrentFogMultiplier(ply, infoTbl)
	-- RaphaelIT7: Spectators use the Fog settings of the player their spectating
	local plyTeam = ply:Team()
	local plyIndex = ply:EntIndex()
	if plyTeam == TEAM_SPECTATOR then
		local spectateEnt = ply:GetObserverTarget()
		if IsValid(spectateEnt) and spectateEnt:IsPlayer() then
			plyTeam = spectateEnt:Team()
			plyIndex = spectateEnt:EntIndex()
		else
			-- RaphaelIT7: Player is a spectator yet spectating no one - so they should have basically no fog.
			return 100
		end
	end

	table.Empty(matchingFogs)
	for _, fogInfo in pairs(GameData.FogData) do
		if fogInfo.fogType == SlashCo.FogType.PLAYER and fogInfo.entIndex ~= plyIndex then continue end
		if fogInfo.fogType == SlashCo.FogType.TEAM and fogInfo.team ~= plyTeam then continue end

		matchingFogs[#matchingFogs + 1] = fogInfo
	end

	table.sort(matchingFogs, SortFogByPriority)

	local multiplier
	for _, fogInfo in ipairs(matchingFogs) do
		multiplier = fogInfo.multiplier or multiplier

		-- Merge info info
		-- The info is built upon all existing infos
		if infoTbl then
			infoTbl.multiplier = fogInfo.multiplier or infoTbl.multiplier
			infoTbl.worldColorR = fogInfo.worldColorR or infoTbl.worldColorR
			infoTbl.worldColorG = fogInfo.worldColorG or infoTbl.worldColorG
			infoTbl.worldColorB = fogInfo.worldColorB or infoTbl.worldColorB
			infoTbl.worldColorScaleR = fogInfo.worldColorScaleR or infoTbl.worldColorScaleR
			infoTbl.worldColorScaleG = fogInfo.worldColorScaleG or infoTbl.worldColorScaleG
			infoTbl.worldColorScaleB = fogInfo.worldColorScaleB or infoTbl.worldColorScaleB
		end
	end

	return multiplier or 1, matchingFogs[#matchingFogs]
end

function SlashCo.FillTableWithFogInfo(infoTbl, ply)
	local r, g, b = SlashCo.GetGlobalFogColor(2)

	infoTbl.multiplier = 1
	infoTbl.worldColorScaleR = 1
	infoTbl.worldColorScaleG = 1
	infoTbl.worldColorScaleB = 1
	infoTbl.worldColorR = r
	infoTbl.worldColorG = g
	infoTbl.worldColorB = b

	SlashCo.GetCurrentFogMultiplier(ply, infoTbl)

	infoTbl.worldColorScaledR = infoTbl.worldColorR * infoTbl.worldColorScaleR
	infoTbl.worldColorScaledG = infoTbl.worldColorG * infoTbl.worldColorScaleG
	infoTbl.worldColorScaledB = infoTbl.worldColorB * infoTbl.worldColorScaleB

	--PrintTable(infoTbl)
end

--[[
	Clientside part
]]

if SERVER then
	goto serverside
end

GameData.WorldFogInfo = GameData.WorldFogInfo or {}
function GM:SetupWorldFog() -- A basic world fog that dynamicly changes depending on the environment
	if GameData.IsLobby then return end

	local lerpTime = RealFrameTime() / 2
	local worldInfo =  GameData.WorldFogInfo

	-- Update fog info
	SlashCo.FillTableWithFogInfo(worldInfo, GameData.LocalPlayer)
	local worldR, worldG, worldB = worldInfo.worldColorScaledR, worldInfo.worldColorScaledG, worldInfo.worldColorScaledB

	GameData.LastFogColorR = Lerp(lerpTime, GameData.LastFogColorR or worldR, worldR)
	GameData.LastFogColorG = Lerp(lerpTime, GameData.LastFogColorG or worldG, worldG)
	GameData.LastFogColorB = Lerp(lerpTime, GameData.LastFogColorB or worldB, worldB)

	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogColor(GameData.LastFogColorR, GameData.LastFogColorG, GameData.LastFogColorB)
	render.FogMaxDensity(1)

	local targetFogStart = 200
	local pos = GameData.LocalPlayer:GetPos()
	local isVisible = util.IsSkyboxVisibleFromPoint(pos)
	local targetFogEnd = 3000

	if not isVisible then
		targetFogEnd = 1000 -- Were somewere hidden, like in a basement.
	else
		targetFogEnd = 2000 -- Were somewere like in a building but outside light still reaches the player
	end

	local tr = util.TraceLine({
		start = pos,
		endpos = pos + skyBoxVec,
		collisiongroup = COLLISION_GROUP_WORLD,
		mask = MASK_VISIBLE,
	})

	if tr.HitSky then
		targetFogEnd = 3000
	end

	if SlashCo.IsGlobalFogDisabled() then
		targetFogStart = 9000
		targetFogEnd = 10000
	end

	local col = render.GetLightColor(pos)
	local brighness = (0.299 * col[1] + 0.587 * col[2] + 0.114 * col[3]) * 50
	brighness = math.min(brighness, 1) - 0.5

	targetFogEnd = targetFogEnd + (targetFogEnd * brighness)

	if (targetFogStart * 1.5) >= targetFogEnd then
		targetFogEnd = targetFogStart * 1.5
	end

	local fogMult = worldInfo.multiplier
	GameData.LastFogStart = Lerp(lerpTime, GameData.LastFogStart or 3000, targetFogStart * fogMult)
	GameData.LastFogEnd = Lerp(lerpTime, GameData.LastFogEnd or 3000, targetFogEnd * fogMult)

	render.FogStart(GameData.LastFogStart)
	render.FogEnd(GameData.LastFogEnd)

	return true
end

function SlashCo.ReadFogInfo(name)
	local fogInfo = {
		name = name,
		fogType = net.ReadUInt(2),
		priority = net.ReadInt(32),
		multiplier = SlashCo.ReadOptional(net.ReadFloat),
		worldColorR = SlashCo.ReadOptional(net.ReadFloat),
		worldColorG = SlashCo.ReadOptional(net.ReadFloat),
		worldColorB = SlashCo.ReadOptional(net.ReadFloat),
		worldColorScaleR = SlashCo.ReadOptional(net.ReadFloat),
		worldColorScaleG = SlashCo.ReadOptional(net.ReadFloat),
		worldColorScaleB = SlashCo.ReadOptional(net.ReadFloat),
	}

	if fogInfo.fogType == SlashCo.FogType.PLAYER then
		fogInfo.entIndex = net.ReadUInt(13)
	elseif fogInfo.fogType == SlashCo.FogType.TEAM then
		fogInfo.team = net.ReadUInt(10)
	end

	return fogInfo
end

net.Receive("SlashCo:UpdateFog", function()
	local isRemoval = net.ReadBool()
	local name = net.ReadString()
	if isRemoval then
		GameData.FogData[name] = nil
		return
	end

	GameData.FogData[name] = SlashCo.ReadFogInfo(name)
end)

net.Receive("SlashCo:InitialFog", function()
	GameData.FogData = {}
	local infoCount = net.ReadUInt(9)
	for k=1, infoCount do
		local name = net.ReadString()

		GameData.FogData[name] = SlashCo.ReadFogInfo(name)
	end
end)

if CLIENT then return end

::serverside::

local function IsNearlyEqualOptional(value1, value2)
	if value1 == nil or value2 == nil then
		return value1 == value2
	end

	return math.IsNearlyEqual(value1, value2, 0.05)
end

-- RaphaelIT7: Checks the needed fields for a change
local function CompareFogInfo(fogInfo1, fogInfo2)
	if not IsNearlyEqualOptional(fogInfo1.multiplier, fogInfo2.multiplier) then
		return false
	end

	if not IsNearlyEqualOptional(fogInfo1.worldColorR, fogInfo2.worldColorR) then
		return false
	end

	if not IsNearlyEqualOptional(fogInfo1.worldColorG, fogInfo2.worldColorG) then
		return false
	end

	if not IsNearlyEqualOptional(fogInfo1.worldColorB, fogInfo2.worldColorB) then
		return false
	end

	if not IsNearlyEqualOptional(fogInfo1.worldColorScaleR, fogInfo2.worldColorScaleR) then
		return false
	end

	if not IsNearlyEqualOptional(fogInfo1.worldColorScaleG, fogInfo2.worldColorScaleG) then
		return false
	end

	if not IsNearlyEqualOptional(fogInfo1.worldColorScaleB, fogInfo2.worldColorScaleB) then
		return false
	end

	if fogInfo1.fogType ~= fogInfo2.fogType then
		return false
	end

	if fogInfo1.priority ~= fogInfo2.priority then
		return false
	end

	if (fogInfo1.entIndex or -1) ~= (fogInfo2.entIndex or -1) then
		return false
	end

	if (fogInfo1.team or -1) ~= (fogInfo2.team or -1) then
		return false
	end

	return true
end

local function WriteFogInfo(fogInfo)
	net.WriteUInt(fogInfo.fogType, 2)
	net.WriteInt(fogInfo.priority, 32)
	SlashCo.WriteOptional(fogInfo.multiplier, net.WriteFloat)
	SlashCo.WriteOptional(fogInfo.worldColorR, net.WriteFloat)
	SlashCo.WriteOptional(fogInfo.worldColorG, net.WriteFloat)
	SlashCo.WriteOptional(fogInfo.worldColorB, net.WriteFloat)
	SlashCo.WriteOptional(fogInfo.worldColorScaleR, net.WriteFloat)
	SlashCo.WriteOptional(fogInfo.worldColorScaleG, net.WriteFloat)
	SlashCo.WriteOptional(fogInfo.worldColorScaleB, net.WriteFloat)
	if fogInfo.fogType == SlashCo.FogType.PLAYER then
		net.WriteUInt(fogInfo.entIndex, 13)
	elseif fogInfo.fogType == SlashCo.FogType.TEAM then
		net.WriteUInt(fogInfo.team, 10) -- RaphaelIT7: Teams only need to go up to 1024 due to TEAM_SPECTATOR being 1002
	end
end

util.AddNetworkString("SlashCo:UpdateFog")
util.AddNetworkString("SlashCo:InitialFog")
function SlashCo.AddFog(info)
	--fogHandleType = fogHandleType or SlashCo.FogHandleType.SET

	local fogInfo = {
		name = info.name,
		baseName = info.name,
		fogType = info.fogType,
		priority = info.priority or 0,
		multiplier = info.multiplier,
		worldColorR = info.worldColorR,
		worldColorG = info.worldColorG,
		worldColorB = info.worldColorB,
		worldColorScaleR = info.worldColorScaleR,
		worldColorScaleG = info.worldColorScaleG,
		worldColorScaleB = info.worldColorScaleB,
	}

	if fogInfo.fogType == SlashCo.FogType.PLAYER then
		if not info.entity or not IsValid(info.entity) then
			error("Tried to use a NULL entity as target!")
		end

		fogInfo.entIndex = info.entity:EntIndex()
		fogInfo.name = fogInfo.name .. "_P" .. fogInfo.entIndex
	elseif fogInfo.fogType == SlashCo.FogType.TEAM then
		if not team.Valid(info.team) then
			error("Tried to use a invalid team!")
		end

		fogInfo.team = info.team
		fogInfo.name = fogInfo.name .. "_T" .. info.team
	end

	local existingFog = GameData.FogData[fogInfo.name]
	if GameData.FogData[fogInfo.name] then
		-- RaphaelIT7: If you pass 1:1 the info of the existing fog we can save work & networking.
		if CompareFogInfo(fogInfo, existingFog) then return end
	end

	GameData.FogData[fogInfo.name] = fogInfo

	net.Start("SlashCo:UpdateFog")
		net.WriteBool(false)
		net.WriteString(fogInfo.name)
		WriteFogInfo(fogInfo)
	net.Broadcast()
end

local function RemoveFogByName(name)
	if not GameData.FogData[name] then return end

	GameData.FogData[name] = nil
	net.Start("SlashCo:UpdateFog")
		net.WriteBool(true)
		net.WriteString(name)
	net.Broadcast()
end

function SlashCo.RemoveFog(name, value)
	if isnumber(value) and team.Valid(value) then
		name = name .. "_T" .. value
	elseif IsEntity(value) then
		name = name .. "_P" .. value:EntIndex()
	end

	RemoveFogByName(name)
end

function SlashCo.ClearFog(baseName)
	for name, fogInfo in pairs(GameData.FogData) do
		if fogInfo.baseName == baseName then
			RemoveFogByName(name)
		end
	end
end

local generatorFogProgress = 0
local generatorFogClear = false
function SlashCo.UpdateGeneratorFog(progress)
	generatorFogProgress = progress or generatorFogProgress

	SlashCo.AddFog({
		name = "GeneratorFog",
		fogType = SlashCo.FogType.GLOBAL,
		priority = -1,
		multiplier = generatorFogClear and 1 or 1 - generatorFogProgress * 0.04,
	})
end

hook.Add("SlashCo:HelicopterLanded", "SlashCo:GeneratorFogClear", function()
	generatorFogClear = true
	SlashCo.UpdateGeneratorFog()

	timer.Create("SlashCo:GeneratorFogClear", 15, 1, function()
		generatorFogClear = false
		SlashCo.UpdateGeneratorFog()
	end)
end)

function SlashCo.RemoveAllPlayerFog(ply)
	local entIndex = ply:EntIndex()
	for name, fogInfo in pairs(GameData.FogData) do
		if fogInfo.fogType == SlashCo.FogType.PLAYER and fogInfo.entIndex == entIndex then
			RemoveFogByName(name)
		end
	end
end

hook.Add("PlayerDisconnected", "SlashCo:RemovePlayerFog", SlashCo.RemoveAllPlayerFog)
hook.Add("SlashCo:PlayerDeath", "SlashCo:RemovePlayerFog", SlashCo.RemoveAllPlayerFog)

-- Only the joining player needs the current fogs
hook.Add("PlayerInitialSpawn", "SlashCo:NetworkFog", function(ply)
	local fogCount = 0
	for _, _2 in pairs(GameData.FogData) do
		fogCount = fogCount + 1
	end

	net.Start("SlashCo:InitialFog")
		net.WriteUInt(fogCount, 9)
		for name, fogInfo in pairs(GameData.FogData) do
			net.WriteString(name)
			WriteFogInfo(fogInfo)
		end
	net.Send(ply)
end)


local function ParseNumbers(value)
	local numbers = {}
	for part in string.gmatch(value, "%S+") do
		numbers[#numbers + 1] = tonumber(part) or 0
	end

	return numbers
end

function SlashCo.ParseFogKeyValue(ent, key, value)
	local key1 = string.lower(key)
	if key1 == "priority" then
		ent.FogPriority = math.floor(tonumber(value) or 0)
		return true
	end

	if key1 == "multiplier" then
		local multiplier = tonumber(value) or 0
		ent.FogMultiplier = multiplier > 0 and multiplier or nil
		return true
	end

	if key1 == "override_color" then
		ent.FogOverrideColor = tonumber(value) == 1
		return true
	end

	if key1 == "color" then
		local color = ParseNumbers(value)
		ent.FogColorValue = {
			math.Clamp(color[1] or 0, 0, 255),
			math.Clamp(color[2] or 0, 0, 255),
			math.Clamp(color[3] or 0, 0, 255),
		}
		return true
	end

	if key1 == "color_scale" then
		local scale = ParseNumbers(value)
		ent.FogColorScaleValue = {
			math.max(scale[1] or 1, 0),
			math.max(scale[2] or 1, 0),
			math.max(scale[3] or 1, 0),
		}
		return true
	end

	return false
end

function SlashCo.BuildMapFogInfo(ent)
	local info = {
		priority = ent.FogPriority or 5,
		multiplier = ent.FogMultiplier,
	}

	local color = ent.FogColorValue
	if ent.FogOverrideColor and color then
		info.worldColorR, info.worldColorG, info.worldColorB = color[1], color[2], color[3]
	end

	local scale = ent.FogColorScaleValue
	if scale and (scale[1] ~= 1 or scale[2] ~= 1 or scale[3] ~= 1) then
		info.worldColorScaleR, info.worldColorScaleG, info.worldColorScaleB = scale[1], scale[2], scale[3]
	end

	return info
end

function SlashCo.GetMapFogName(targetName)
	return "MapFog_" .. targetName
end
