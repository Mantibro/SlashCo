AddCSLuaFile()

DEFINE_BASECLASS("player_default")

local PLAYER = {}
local SlashCo = SlashCo

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.DisplayName = "Survivor"

PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 300
PLAYER.StartHealth = 100
PLAYER.MaxHealth = 200
PLAYER.Achievements = {}
PLAYER.Inventory = {}

function PLAYER:GetInventory()
    return PLAYER.Inventory
end

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
end

function PLAYER:SetModel()

	local id = math.random( 1, 9 )

	local modelname = "models/slashco/survivor/male_0"..id..".mdl"

	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

end

player_manager.RegisterClass("player_survivor", PLAYER, "player_default")
