AddCSLuaFile()

DEFINE_BASECLASS("player_default")

local PLAYER = {}

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.DisplayName = "Lobby"

PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 350
PLAYER.StartHealth = 100
PLAYER.MaxHealth = 100
PLAYER.AvoidPlayers = false -- Stops players from being pushed out of each other.

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
end

SlashCo.SurvivorModels = file.Find("models/slashco/survivor/male_*.mdl", "GAME")
for idx, fileName in ipairs(SlashCo.SurvivorModels) do
	SlashCo.SurvivorModels[idx] = "models/slashco/survivor/" .. fileName
	SlashCo.SurvivorModels[SlashCo.SurvivorModels[idx]] = idx
end

hook.Add("SlashCo:Precache", "PrecacheSurvivorModels", function()
	for _, modelName in ipairs(SlashCo.SurvivorModels) do
		SlashCo.PrecacheModel(modelName)
	end
end)

function PLAYER:SetModel()
	local modelname
	local cl_modelname = self.Player:GetInfo("slashco_cl_playermodel")
	if SlashCo.SurvivorModels[cl_modelname] then
		modelname = cl_modelname
	else
		modelname = SlashCo.SurvivorModels[math.random(1, #SlashCo.SurvivorModels)]
	end

	self.Player:SetModel(modelname)
end

function PLAYER:SetupDataTables()
	if SERVER then
		--PLAYER.Achievements = data.Stats.Achievements or {}
	end
end

player_manager.RegisterClass("player_lobby", PLAYER, "player_default")
