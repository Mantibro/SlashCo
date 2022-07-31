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

	local cl_modelname = self.Player:GetInfo( "cl_slashco_playermodel" )

	local allow = false

	for i = 1, 9 do
		if cl_modelname == "models/slashco/survivor/male_0"..i..".mdl" then allow = true end
	end

	if allow then
		modelname = cl_modelname
	else
		modelname = "models/slashco/survivor/male_0"..math.random( 1, 9 )..".mdl"
	end

	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

end

player_manager.RegisterClass("player_survivor", PLAYER, "player_default")

hook.Add("CalcMainActivity", "SurvivorAnimator", function(ply, _)

	if ply:Team() == TEAM_SURVIVOR then

		if not ply:GetNWBool("SurvivorSidExecution") and not ply:GetNWBool("Taunt_MNR") then ply.surv_anim_antispam = false end

		if ply:GetNWBool("SurvivorSidExecution") then

			ply.CalcIdeal = ACT_DIESIMPLE
			ply.CalcSeqOverride = ply:LookupSequence("sid_execution")
			if ply.surv_anim_antispam == nil or ply.surv_anim_antispam == false then ply:SetCycle( 0 ) ply.surv_anim_antispam = true end

			return ply.CalcIdeal, ply.CalcSeqOverride

		elseif ply:GetNWBool("Taunt_Cali") then

			ply.CalcIdeal = ACT_DIESIMPLE
			ply.CalcSeqOverride = ply:LookupSequence("taunt_cali")

			return ply.CalcIdeal, ply.CalcSeqOverride

		elseif ply:GetNWBool("Taunt_MNR") then

			ply.CalcIdeal = ACT_DIESIMPLE
			ply.CalcSeqOverride = ply:LookupSequence("taunt_mnr")
			if ply.surv_anim_antispam == nil or ply.surv_anim_antispam == false then ply:SetCycle( 0 ) ply.surv_anim_antispam = true end

			return ply.CalcIdeal, ply.CalcSeqOverride

		else
			return
		end

	end

end)
