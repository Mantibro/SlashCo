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

--[[ doesn't seem to function, since this would have errored
function PLAYER:SetModel()
	local modelname = SlashCoSlashers[self.Player:GetNWBool("Slasher")].Model
	util.PrecacheModel(modelname)
	self.Player:SetModel(modelname)
	self.Player:SetCanWalk(false)
end
--]]

if CLIENT then
	function PLAYER:Init()
		self.Player:RemoveEffects(EF_NOFLASHLIGHT)

		if LocalPlayer() ~= self.Player then
			return
		end

		timer.Simple(FrameTime(), function()
			SlashCo.InitSlasherHud()
		end)
	end

	function PLAYER:ClassChanged()
		if LocalPlayer() ~= self.Player then
			return
		end

		if IsValid(LocalPlayer().SlasherHud) then
			LocalPlayer().SlasherHud:Remove()
		end
	end
else
	function PLAYER:Init()
		self.Player:RemoveEffects(EF_NOFLASHLIGHT)
	end
end

player_manager.RegisterClass("player_slasher_base", PLAYER, "player_default")
