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

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
end

function PLAYER:SetupDataTables()
	if SERVER then
		--PLAYER.Achievements = data.Stats.Achievements or {}
	end
end

player_manager.RegisterClass("player_lobby", PLAYER, "player_default")
