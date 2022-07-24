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

	if ply:Team() != TEAM_SLASHER then
		return
	end

	if ply:GetNWBool("AmogusDisguised") then return end

	local chase = ply:GetNWBool("InSlasherChaseMode")
	local pac = ply:GetNWBool("DemonPacified")

	local spook = ply:GetNWBool("BababooeySpooking")

	local eating = ply:GetNWBool("SidEating")
	local equipping_gun = ply:GetNWBool("SidGunEquipping")

	local gun_state = ply:GetNWBool("SidGunEquipped")
	local aiming_gun = ply:GetNWBool("SidGunAiming")
	local aimed_gun = ply:GetNWBool("SidGunAimed")
	local gun_shooting = ply:GetNWBool("SidGunShoot")
	local gun_rage = ply:GetNWBool("SidGunRage")
	local trollge_stage1 = ply:GetNWBool("TrollgeStage1")
	local trollge_stage2 = ply:GetNWBool("TrollgeStage2")
	local trollge_slashing = ply:GetNWBool("TrollgeSlashing")
	local male_slashing = ply:GetNWBool("Male07Slashing")
	local male_transforming = ply:GetNWBool("Male07Transforming")

	if gun_state then gun_prefix = "g_" else gun_prefix = "" end

	if ply:GetModel() != "models/slashco/slashers/baba/baba.mdl" then goto sid end --Bababooey's Animator

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

	if ply:GetModel() != "models/slashco/slashers/sid/sid.mdl" then goto trollge end --Sid's Animator

	if not eating and not equipping_gun and not aiming_gun and not gun_shooting then anim_antispam = false end

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

	::trollge::

	if ply:GetModel() != "models/slashco/slashers/trollge/trollge.mdl" then goto amogus end --Trollge's Animator

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

	if ply:GetModel() != "models/slashco/slashers/amogus/amogus.mdl" then goto thirsty end --Amogus' Animator

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

	if ply:GetModel() != "models/slashco/slashers/thirsty/thirsty.mdl" then goto male07 end --Thristy's Animator

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

	if not male_slashing and not male_transforming then anim_antispam = false end

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

		local a1 = -ply:GetVelocity()[2]
		local a2 = -ply:GetVelocity()[1]

		--ply:SetPoseParameter( "move_yaw",-((( math.atan2( a1, a2 )*2/(-2*math.pi) ) 	* 180	) + ply:GetAngles()[2] - 180))

		if ply:GetVelocity():Length() < 30 then 

			ply.CalcIdeal = ACT_IDLE
			ply.CalcSeqOverride = ply:LookupSequence("idle_all")

		end

	elseif ply:GetModel() == "models/slashco/slashers/male_07/male_07_monster.mdl" then
		
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

   	return ply.CalcIdeal, ply.CalcSeqOverride
end)


hook.Add( "PlayerFootstep", "SlasherFootstep", function( ply, pos, foot, sound, volume, rf )

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
		end
		
	end

end )
