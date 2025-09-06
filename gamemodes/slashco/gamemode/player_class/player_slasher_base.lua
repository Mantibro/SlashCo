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
	local modelname = self.Player:SlasherValue("Model", "models/Humans/Group01/male_07.mdl")
	SlashCo.PrecacheModel(modelname) -- The model should have already been precached by SlashCo.PrecacheSlasher
	self.Player:SetModel(modelname)
	self.Player:SetCanWalk(false)
end

if CLIENT then
	function PLAYER:Init()
		self.Player:RemoveEffects(EF_NOFLASHLIGHT)

		if GameData.LocalPlayer ~= self.Player then
			return
		end

		timer.Simple(FrameTime(), function()
			SlashCo.InitSlasherHud()
		end)
	end

	function PLAYER:ClassChanged()
		if GameData.LocalPlayer ~= self.Player then
			return
		end

		if IsValid(GameData.LocalPlayer.SlasherHud) then
			GameData.LocalPlayer.SlasherHud:Remove()
		end
	end
else
	function PLAYER:Init()
		self.Player:RemoveEffects(EF_NOFLASHLIGHT)
	end
end

player_manager.RegisterClass("player_slasher_base", PLAYER, "player_default")
