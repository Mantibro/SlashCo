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

	local rand = math.random( 1, 5 )

	local id = 1

	if rand < 3 then id = rand elseif rand == 3 then id = 5 elseif rand == 4 then id = 7 end

	local modelname = "models/slashco/survivor/male_0"..id..".mdl"
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

end

player_manager.RegisterClass("player_survivor", PLAYER, "player_default")
