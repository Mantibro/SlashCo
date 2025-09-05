AddCSLuaFile()

DEFINE_BASECLASS("player_default")

local PLAYER = {}
--local SlashCo = SlashCo

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.DisplayName = "Survivor"

PLAYER.SlowWalkSpeed = 100
PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 300
PLAYER.StartHealth = 100
PLAYER.MaxHealth = 100
PLAYER.Achievements = {}
PLAYER.Inventory = {}

function PLAYER:GetInventory()
	return PLAYER.Inventory
end

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("sc_survivorhands")
	self.Player:SetCanWalk(true)
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
	local cl_modelname = self.Player:GetInfo("slashco_cl_playermodel")
	local allow = SlashCo.SurvivorModels[cl_modelname] ~= nil

	local modelname
	if allow then
		modelname = cl_modelname
	else
		modelname = SlashCo.SurvivorModels[math.random(1, #SlashCo.SurvivorModels)]
	end

	self.Player:SetModel(modelname)
end

function PLAYER:Init()
	self.Player:AddEffects(EF_NOFLASHLIGHT)
end

player_manager.RegisterClass("player_survivor", PLAYER, "player_default")

hook.Add("CalcMainActivity", "SurvivorAnimator", function(ply, _)
	if ply:Team() ~= TEAM_SURVIVOR then
		return
	end

	if ply:GetNWBool("SurvivorTackled") then
		ply.CalcIdeal = ACT_DIESIMPLE
		ply.CalcSeqOverride = ply:LookupSequence("zombie_slump_idle_01")

		return ply.CalcIdeal, ply.CalcSeqOverride
	end

	if not ply:GetNWBool("SurvivorSidExecution") and not ply:GetNWBool("Taunt_MNR") then
		ply.surv_anim_antispam = false
	end

	if ply:GetNWBool("SurvivorSidExecution") then
		ply.CalcIdeal = ACT_DIESIMPLE
		ply.CalcSeqOverride = ply:LookupSequence("sid_execution")
		if ply.surv_anim_antispam == nil or ply.surv_anim_antispam == false then
			ply:SetCycle(0)
			ply.surv_anim_antispam = true
		end

		return ply.CalcIdeal, ply.CalcSeqOverride
	elseif ply:GetNWBool("Taunt_Cali") then
		ply.CalcIdeal = ACT_DIESIMPLE
		ply.CalcSeqOverride = ply:LookupSequence("taunt_cali")

		return ply.CalcIdeal, ply.CalcSeqOverride
	elseif ply:GetNWBool("Taunt_MNR") then
		ply.CalcIdeal = ACT_DIESIMPLE
		ply.CalcSeqOverride = ply:LookupSequence("taunt_mnr")
		if ply.surv_anim_antispam == nil or ply.surv_anim_antispam == false then
			ply:SetCycle(0)
			ply.surv_anim_antispam = true
		end

		return ply.CalcIdeal, ply.CalcSeqOverride
	elseif ply:GetNWBool("Taunt_Griddy") then
		ply.CalcIdeal = ACT_DIESIMPLE
		ply.CalcSeqOverride = ply:LookupSequence("taunt_griddy")

		return ply.CalcIdeal, ply.CalcSeqOverride
	else
		return
	end
end)

hook.Add("PlayerFootstep", "SurvivorFootstep", function(ply)
	--pos, foot, sound, volume, rf
	if ply:Team() == TEAM_SURVIVOR and ply:ItemFunction("OnFootstep") then
		return true
	end
end)
