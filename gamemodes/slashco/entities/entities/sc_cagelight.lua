AddCSLuaFile()

--[[
	Map entity mainly used in the Lobby.
	This is due to static props being unable to change models, so we instead have them as entities.
	But since it's meant to only be used in the Lobby it's fine.
]]

ENT.Type = "anim"
ENT.ClassName = "sc_cagelight"

local offModel = "models/props_c17/light_cagelight02_on.mdl"
local onModel = "models/props_c17/light_cagelight01_on.mdl"

function ENT:Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(offModel)

	if SERVER and self.IsAlarmLight and self.AlarmLightName then
		local AlarmLightName = self.AlarmLightName
		local groupLights = GameData.AlarmLights[AlarmLightName]
		if not groupLights then
			groupLights = {}
			GameData.AlarmLights[AlarmLightName] = groupLights
		end

		groupLights[self] = true
	end
end

if CLIENT then return end

function ENT:OnRemove()
	local groupLights = GameData.AlarmLights[self.AlarmLightName]
	if not groupLights or not groupLights[self] then return end

	groupLights[self] = nil
end

GameData.AlarmLights = GameData.AlarmLights or {}
GameData.NonAlarmLightsName = GameData.NonAlarmLightsName or "" -- Maps can set it in the info_sc_settings entity!
function SlashCo.EnableAlarmLights(noEffect)
	for lightName, alarms in pairs(GameData.AlarmLights) do
		for alarm, _ in pairs(alarms) do
			alarm:TurnOn()
		end

		local lights = ents.FindByName(lightName)
		if IsValid(lights[1]) then
			-- RaphaelIT7: Since the engine gives all lights that use the same name the same light map - turning one of them on is the same as turning all of them on.
			lights[1]:Fire("TurnOn")
		end
	end

	if GameData.NonAlarmLightsName == "" then return end
	for _, lightName in ipairs(string.Split(GameData.NonAlarmLightsName, ";")) do
		local lights = ents.FindByName(lightName)
		local toggledLights = false
		for _, light in ipairs(lights) do
			if light:GetClass() == "point_spotlight" then
				light:Fire("LightOff") -- For point_spotlight we must call it for all of them.
			else
				if not toggledLights then
					light:Fire("TurnOff")
					toggledLights = true
				end
			end
		end
	end

	if not noEffect then
		for _, ply in player.Iterator() do
			ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0), 3, 1)
		end

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/blackout.mp3",
			identifier = "PowerLoss",
			volume = 1,
			fadeIn = 0,
		})
	end

	SlashCo.SetLightStyle(0, "b")
end

function SlashCo.DisableAlarmLights()
	for lightName, alarms in pairs(GameData.AlarmLights) do
		for alarm, _ in pairs(alarms) do
			alarm:TurnOff()
		end

		local lights = ents.FindByName(lightName)
		if IsValid(lights[1]) then
			lights[1]:Fire("TurnOff")
		end
	end

	if GameData.NonAlarmLightsName == "" then return end
	for _, lightName in ipairs(string.Split(GameData.NonAlarmLightsName, ";")) do
		local lights = ents.FindByName(lightName)
		local toggledLights = false
		for _, light in ipairs(lights) do
			if light:GetClass() == "point_spotlight" then
				light:Fire("LightOn")
			else
				if not toggledLights then
					light:Fire("TurnOn")
					toggledLights = true
				end
			end
		end
	end

	SlashCo.SetLightStyle(0, "m")
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "is_alarm_light" then
		self.IsAlarmLight = tobool(value)
		return
	end

	if key == "always_on" then
		self.AlwaysOn = tobool(value)
		return
	end

	if key == "alarm_mode" then
		self.AlarmMode = tonumber(value)
		return
	end

	if key == "alarm_light_name" and value ~= "" then
		self.AlarmLightName = value
		return
	end
end

function ENT:TurnOn()
	self:SetModel(onModel)
end

function ENT:TurnOff()
	self:SetModel(offModel)
end