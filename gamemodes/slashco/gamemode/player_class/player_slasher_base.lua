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

player_manager.RegisterClass("player_slasher_base", PLAYER, "player_default")

--Slasher Animation Controller
--[[hook.Add("CalcMainActivity", "SlasherAnimator", function(ply, _)

	if ply:Team() ~= TEAM_SLASHER then
		return
	end

	if ply:GetNWBool("AmogusDisguised") then return end

	local chase = ply:GetNWBool("InSlasherChaseMode")
	local pac = ply:GetNWBool("DemonPacified")

	local spook = ply:GetNWBool("BababooeySpooking")

	local eating = ply:GetNWBool("SidEating")
	local equipping_gun = ply:GetNWBool("SidGunEquipping")
	local sid_executing = ply:GetNWBool("SidExecuting")

	local gun_state = ply:GetNWBool("SidGunEquipped")
	local aiming_gun = ply:GetNWBool("SidGunAiming")
	local aimed_gun = ply:GetNWBool("SidGunAimed")
	local gun_shooting = ply:GetNWBool("SidGunShoot")
	--local gun_rage = ply:GetNWBool("SidGunRage")

	local trollge_stage1 = ply:GetNWBool("TrollgeStage1")
	local trollge_stage2 = ply:GetNWBool("TrollgeStage2")
	local trollge_slashing = ply:GetNWBool("TrollgeSlashing")

	local male_slashing = ply:GetNWBool("Male07Slashing")
	local male_transforming = ply:GetNWBool("Male07Transforming")

	local tyler_creator = ply:GetNWBool("TylerTheCreator")
	local tyler_creating = ply:GetNWBool("TylerCreating")

	local borg_punch = ply:GetNWBool("BorgmirePunch")
	local borg_throw = ply:GetNWBool("BorgmireThrow")

	local manspider_nest = ply:GetNWBool("ManspiderNested")

	local abomignat_mainslash = ply:GetNWBool("AbomignatSlashing")
	local abomignat_lunge = ply:GetNWBool("AbomignatLunging")
	local abomignat_lungefinish = ply:GetNWBool("AbomignatLungeFinish")

	local abomignat_crawl = ply:GetNWBool("AbomignatCrawling")

	local smiley_summon = ply:GetNWBool("FreeSmileySummoning")

	if gun_state then gun_prefix = "g_" else gun_prefix = "" end

	
	if ply:GetModel() ~= "models/slashco/slashers/manspider/manspider.mdl" then goto watcher end --Manspider's Animator
do

	if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if manspider_nest then

		ply.CalcSeqOverride = ply:LookupSequence("nest")

	end

end
	::watcher::
	if ply:GetModel() ~= "models/slashco/slashers/watcher/watcher.mdl" then goto abomignat end --Watcher's Animator
do

	if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if manspider_nest then

		ply.CalcSeqOverride = ply:LookupSequence("nest")

	end

end
	::abomignat::

	if ply:GetModel() ~= "models/slashco/slashers/abomignat/abomignat.mdl" then goto criminal end --Abomignat's Animator

	if not abomignat_mainslash and not abomignat_lunge and not abomignat_lungefinish then anim_antispam = false end

	if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_HL2MP_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN 
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

		if abomignat_crawl then
			ply.CalcSeqOverride = ply:LookupSequence("crawl")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if abomignat_mainslash then

		ply.CalcSeqOverride = ply:LookupSequence("slash_charge")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

	if abomignat_lunge then

		ply.CalcSeqOverride = ply:LookupSequence("lunge")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

	if abomignat_lungefinish then

		ply.CalcSeqOverride = ply:LookupSequence("lunge_post")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

	::criminal::

	if ply:GetModel() ~= "models/slashco/slashers/criminal/criminal.mdl" then goto freesmiley end --Criminal's Animator

	ply.CalcSeqOverride = 3

	::freesmiley::

	if ply:GetModel() ~= "models/slashco/slashers/freesmiley/freesmiley.mdl" then goto leuonard end --Smiley's Animator

	if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_HL2MP_WALK 
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN 
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if smiley_summon then

		ply.CalcSeqOverride = ply:LookupSequence("summon")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

	::leuonard::
	if ply:GetModel() ~= "models/slashco/slashers/leuonard/leuonard.mdl" then goto next end --Smiley's Animator

	if not chase then 
		ply.CalcIdeal = ACT_HL2MP_WALK 
		ply.CalcSeqOverride = ply:LookupSequence("walk")
	else
		ply.CalcIdeal = ACT_HL2MP_RUN 
		ply.CalcSeqOverride = ply:LookupSequence("chase")
	end

	if ply:GetNWBool("LeuonardFullRape") then
		ply.CalcIdeal = ACT_HL2MP_RUN 
		ply.CalcSeqOverride = ply:LookupSequence("specialrun")
	end

	if ply:GetVelocity():Length() < 2 then
		ply.CalcIdeal = ACT_HL2MP_IDLE 
		ply.CalcSeqOverride = ply:LookupSequence("ragdoll")
	end

	if ply:GetNWBool("LeuonardRaping") then
		ply.CalcSeqOverride = ply:LookupSequence("mondaynightraw")
	end

	::next::

   	return ply.CalcIdeal, ply.CalcSeqOverride
end)


hook.Add( "PlayerFootstep", "SlasherFootstep", function( ply, _, _, _, _, _ ) --pos, foot, sound, volume, rf

if SERVER then
	if ply:GetNWBool("AmogusSurvivorDisguise") then return false end

	if ply:Team() == TEAM_SLASHER then 

		elseif ply:GetModel() == "models/hunter/plates/plate.mdl" then --Male07Specter (no) Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/tyler/tyler.mdl" then --Tyler (no) Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/borgmire/borgmire.mdl" then --Borgmire Footsteps

			if ply.BorgStepTick == nil or ply.BorgStepTick > 1 then ply.BorgStepTick = 0 end

			if ply.BorgStepTick == 0 then ply:EmitSound( "slashco/slasher/borgmire_step"..math.random(1,4)..".mp3") end

			ply.BorgStepTick = ply.BorgStepTick + 1

			return true 
		elseif ply:GetModel() == "models/slashco/slashers/manspider/manspider.mdl" then --Manspider Footsteps
			ply:EmitSound( "slashco/slasher/manspider_step.mp3")
			return true
		elseif ply:GetModel() == "models/slashco/slashers/watcher/watcher.mdl" then --Watcher Footsteps
			ply:EmitSound( "npc/footsteps/hardboot_generic"..math.random(1,6)..".wav",50,90,0.75)
			return false
		elseif ply:GetModel() == "models/slashco/slashers/abomignat/abomignat.mdl" then --Watcher Footsteps
			ply:EmitSound( "slashco/slasher/abomignat_step"..math.random(1,3)..".mp3")
			return false
		elseif ply:GetModel() == "models/slashco/slashers/criminal/criminal.mdl" then --Criminal Footsteps
			if ply.CrimStepTick == nil or ply.CrimStepTick > 2 then ply.CrimStepTick = 0 end

			if ply.CrimStepTick == 0 then ply:EmitSound( "slashco/slasher/criminal_step"..math.random(1,6)..".mp3") end

			ply.CrimStepTick = ply.CrimStepTick + 1

			return true 
		elseif ply:GetModel() == "models/slashco/slashers/freesmiley/freesmiley.mdl" then --Smiley Footsteps
			if ply.SmileyStepTick == nil or ply.SmileyStepTick > 1 then ply.SmileyStepTick = 0 end

			if ply.SmileyStepTick == 0 then 
				ply:EmitSound( "npc/footsteps/hardboot_generic"..math.random(1,6)..".wav",50,70,0.75) 
				ply.SmileyStepTick = ply.SmileyStepTick + 1
				return false
			end

			ply.SmileyStepTick = ply.SmileyStepTick + 1

			return true 

		elseif ply:GetModel() == "models/slashco/slashers/leuonard/leuonard.mdl" then --Leuonard Footsteps
			ply:EmitSound( "slashco/slasher/leuonard_step"..math.random(1,3)..".mp3")
			return true
		end
		
	end

end

if CLIENT then

	if ply:GetNWBool("AmogusSurvivorDisguise") then return false end

	if ply:Team() == TEAM_SLASHER then 

		elseif ply:GetModel() == "models/hunter/plates/plate.mdl" then --Male07Specter (no) Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/tyler/tyler.mdl" then --Tyler (no) Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/borgmire/borgmire.mdl" then --Borgmire Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/manspider/manspider.mdl" then --Manspider Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/watcher/watcher.mdl" then --Watcher Footsteps
			return false
		elseif ply:GetModel() == "models/slashco/slashers/abomignat/abomignat.mdl" then --Abomignat Footsteps
			return true
		elseif ply:GetModel() == "models/slashco/slashers/criminal/criminal.mdl" then --Criminal Footsteps
			return true
		elseif ply:GetModel() == "models/slashco/slashers/freesmiley/freesmiley.mdl" then --Smiley Footsteps
			if ply.SmileyStepTick == nil or ply.SmileyStepTick > 1 then ply.SmileyStepTick = 0 end

			if ply.SmileyStepTick == 0 then 
				ply.SmileyStepTick = ply.SmileyStepTick + 1
				return false
			end

			ply.SmileyStepTick = ply.SmileyStepTick + 1

			return true 

		elseif ply:GetModel() == "models/slashco/slashers/leuonard/leuonard.mdl" then --Criminal Footsteps
			return true
		end
		
	end

end

end )]]
