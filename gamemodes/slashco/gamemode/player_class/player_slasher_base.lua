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

	local modelname = SlashCo.CurRound.SlasherData[self.Player:SteamID64()].Model
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname ) 
	self.Player:SetCanWalk( false )

end

player_manager.RegisterClass("player_slasher_base", PLAYER, "player_default")

--Slasher Animation Controller
hook.Add("CalcMainActivity", "SlasherAnimator", function(ply, _)

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

	if ply:GetModel() ~= "models/slashco/slashers/baba/baba.mdl" then goto sid end --Bababooey's Animator

	if ply:IsOnGround() then

		if not spook then

			if not chase then 
				ply.CalcIdeal = ACT_HL2MP_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			else
				ply.CalcIdeal = ACT_HL2MP_RUN 
				ply.CalcSeqOverride = ply:LookupSequence("chase")
			end

		else
			ply.CalcSeqOverride = ply:LookupSequence("spook")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	::sid::

	if ply:GetModel() ~= "models/slashco/slashers/sid/sid.mdl" then goto trollge end --Sid's Animator

	if not eating and not equipping_gun and not aiming_gun and not gun_shooting and not sid_executing then anim_antispam = false end

	if not equipping_gun then

		if not aiming_gun and not aimed_gun then

			if not eating then

				if ply:IsOnGround() then

					if ply:GetVelocity():Length() < 200 then 
						ply.CalcIdeal = ACT_HL2MP_WALK 
						ply.CalcSeqOverride = ply:LookupSequence(gun_prefix.."prowl")
					else
						ply.CalcIdeal = ACT_HL2MP_RUN 
						ply.CalcSeqOverride = ply:LookupSequence(gun_prefix.."chase")
					end

				else

					ply.CalcSeqOverride = ply:LookupSequence(gun_prefix.."float")

				end
			else

				ply.CalcSeqOverride = ply:LookupSequence("eat")
				if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

			end

		end

	else
		ply.CalcSeqOverride = ply:LookupSequence("arm")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end
	end

	if aiming_gun then

		ply.CalcSeqOverride = ply:LookupSequence("readygun")
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

	if aimed_gun then

		if not gun_shooting then

			ply.CalcSeqOverride = ply:LookupSequence("readyidle")

		else

			ply.CalcSeqOverride = ply:LookupSequence("shoot")
			if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

		end

	end

	if sid_executing then

		ply.CalcSeqOverride = ply:LookupSequence("execution")
		ply:SetPlaybackRate( 1 )
		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

	end

	::trollge::

	if ply:GetModel() ~= "models/slashco/slashers/trollge/trollge.mdl" then goto amogus end --Trollge's Animator

	if not trollge_slashing then anim_antispam = false end

	if not trollge_stage1 and not trollge_stage2 then

		if ply:IsOnGround() then
		
			if not trollge_slashing then

				ply.CalcIdeal = ACT_HL2MP_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("walk")

			else

				ply.CalcSeqOverride = ply:LookupSequence("walk")

				if anim_antispam == nil or anim_antispam == false then
					ply:AddVCDSequenceToGestureSlot( 1, 2, 0, true )
					anim_antispam = true 
				end

			end

		else

			--ply.CalcSeqOverride = ply:LookupSequence("float")

		end

	elseif trollge_stage2 then

		ply.CalcSeqOverride = ply:LookupSequence("fly")

	else

		ply.CalcSeqOverride = ply:LookupSequence("glide")

	end

	::amogus::

	if ply:GetModel() ~= "models/slashco/slashers/amogus/amogus.mdl" then goto thirsty end --Amogus' Animator

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

	::thirsty::

	if ply:GetModel() ~= "models/slashco/slashers/thirsty/thirsty.mdl" then goto male07 end --Thristy's Animator

	if not ply:GetNWBool("ThirstyDrinking") then anim_antispam = false end
	
	if ply:IsOnGround() then

		if not chase then 

			if not ply:GetNWBool("ThirstyBigMlik") then

				ply.CalcIdeal = ACT_HL2MP_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("prowl")

			else

				if not pac then

					ply.CalcIdeal = ACT_HL2MP_RUN 
					ply.CalcSeqOverride = ply:LookupSequence("chase2")

				else

					ply.CalcIdeal = ACT_HL2MP_WALK 
					ply.CalcSeqOverride = ply:LookupSequence("prowl")

				end

			end

		else
			ply.CalcIdeal = ACT_HL2MP_RUN 
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("float")

	end

	if ply:GetNWBool("ThirstyDrinking") then 
		
		ply.CalcSeqOverride = ply:LookupSequence("drink") 

		if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end
	
	end

	::male07::
	--Male_07's animator

	if ply:GetModel() == "models/humans/group01/male_07.mdl" then 
	
		if ply:IsOnGround() then

			if not chase then 
				ply.CalcIdeal = ACT_WALK 
				ply.CalcSeqOverride = ply:LookupSequence("walk_all")
			else
				ply.CalcIdeal = ACT_RUN_SCARED
				ply.CalcSeqOverride = ply:LookupSequence("run_all_panicked")
			end
	
		else
	
			ply.CalcIdeal = ACT_JUMP
			ply.CalcSeqOverride = ply:LookupSequence("jump_holding_jump")
	
		end

		ply:SetPoseParameter( "move_x", ply:GetVelocity():Length()/100 )

		--local a1 = -ply:GetVelocity()[2]
		--local a2 = -ply:GetVelocity()[1]

		--ply:SetPoseParameter( "move_yaw",-((( math.atan2( a1, a2 )*2/(-2*math.pi) ) 	* 180	) + ply:GetAngles()[2] - 180))

		if ply:GetVelocity():Length() < 30 then 

			ply.CalcIdeal = ACT_IDLE
			ply.CalcSeqOverride = ply:LookupSequence("idle_all")

		end

	elseif ply:GetModel() == "models/slashco/slashers/male_07/male_07_monster.mdl" then

		if not male_slashing and not male_transforming then anim_antispam = false end
		
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

		if male_slashing and anim_antispam == nil or anim_antispam == false then
			ply:AddVCDSequenceToGestureSlot( 1, ply:LookupSequence("slash"), 0, true )
			anim_antispam = true 
		end

		if male_transforming then 
		
			ply.CalcSeqOverride = ply:LookupSequence("transform") 
	
			if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end
		
		end
	
	
	end

	--TYLER

	if ply:GetModel() ~= "models/slashco/slashers/tyler/tyler.mdl" then goto borgmire end --Tyler's Animator

	if tyler_creator then

		if not tyler_creating then

			--ply.CalcIdeal = ACT_HL2MP_IDLE 
			ply.CalcSeqOverride = ply:LookupSequence("creator idle")

			anim_antispam = false

		else

			ply.CalcSeqOverride = ply:LookupSequence("create") 
			if anim_antispam == nil or anim_antispam == false then ply:SetCycle( 0 ) anim_antispam = true end

		end

	else

		if ply:GetVelocity():LengthSqr() > 5 then

			--ply.CalcIdeal = ACT_HL2MP_IDLE 
			ply.CalcSeqOverride = ply:LookupSequence("destroyer walk")

		else

			--ply.CalcIdeal = ACT_HL2MP_IDLE 
			ply.CalcSeqOverride = ply:LookupSequence("destroyer activated")

		end

	end

	::borgmire::

	if ply:GetModel() ~= "models/slashco/slashers/borgmire/borgmire.mdl" then goto manspider end --Borgmire's Animator
do

	if not borg_punch and not borg_throw then anim_antispam = false end

	if ply:IsOnGround() then

		if not chase then 
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("walk_all")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN 
			ply.CalcSeqOverride = ply:LookupSequence("run_all")
		end

	else

		ply.CalcSeqOverride = ply:LookupSequence("jump")

	end


	if borg_punch and (anim_antispam == nil or anim_antispam == false) then

		local r = math.random(1,2)
		local PunchAnim = ""
		if r == 1 then PunchAnim = "Attack_FIST" else PunchAnim = "Attack_MELEE" end

		ply:AddVCDSequenceToGestureSlot( 1, ply:LookupSequence(PunchAnim), 0, true )
		anim_antispam = true 
	end

	if borg_throw and (anim_antispam == nil or anim_antispam == false) then
		ply:AddVCDSequenceToGestureSlot( 1, ply:LookupSequence("attack_throw"), 0, true )
		anim_antispam = true 
	end
end
	::manspider::
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

		if ply:GetModel() == "models/slashco/slashers/baba/baba.mdl" then --Bababooey Footsteps
			if ply:GetNWBool("BababooeyInvisibility") then return true end
			ply:EmitSound( "slashco/slasher/babastep_0"..math.random(1,3)..".mp3") 
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/sid/sid.mdl" then --Sid Footsteps
			ply:EmitSound( "slashco/slasher/sid_step"..math.random(1,2)..".mp3") 
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/trollge/trollge.mdl" then --Trollge (no) Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/amogus/amogus.mdl" then --Amogus Footsteps
			if ply:GetNWBool("AmogusFuelDisguise") then return true end

			ply:EmitSound( "slashco/slasher/amogus_step"..math.random(1,3)..".wav") 
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/thirsty/thirsty.mdl" then --Thirsty (no) Footsteps
			return true 
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

		if ply:GetModel() == "models/slashco/slashers/baba/baba.mdl" then --Bababooey Footsteps
			if ply:GetNWBool("BababooeyInvisibility") then return true end
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/sid/sid.mdl" then --Sid Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/trollge/trollge.mdl" then --Trollge (no) Footsteps
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/amogus/amogus.mdl" then --Amogus Footsteps
			if ply:GetNWBool("AmogusFuelDisguise") then return true end
			return true 
		elseif ply:GetModel() == "models/slashco/slashers/thirsty/thirsty.mdl" then --Thirsty (no) Footsteps
			return true 
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

end )
