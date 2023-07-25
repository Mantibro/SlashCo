AddCSLuaFile()

DEFINE_BASECLASS("player_default")

local PLAYER = {}
--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.SlowWalkSpeed = 150
PLAYER.WalkSpeed = 150
PLAYER.RunSpeed = 150

--local SlashCo = SlashCo

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
end

function PLAYER:SetModel()

	local modelname = SlashCoSlasher[self.Player:GetNWBool("Slasher")].Model
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname ) 
	self.Player:SetCanWalk( false )

end

function PLAYER:Init()
	self.SlasherHud = GetHUDPanel():Add("slashco_slasher_stockhud")
	self:SlasherFunction("InitHud")
end

function PLAYER:ClassChanged()
	if IsValid(self.SlasherHud) then
		self.SlasherHud:Remove()
	end
end

player_manager.RegisterClass("player_slasher_base", PLAYER, "player_default")
