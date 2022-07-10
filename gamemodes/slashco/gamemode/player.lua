include( "globals.lua" )

local SlashCo = SlashCo

function GM:PlayerInitialSpawn(ply, transition)
	if game.GetMap() == "sc_lobby" then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spawn()
	end
end

function GM:PlayerSpawn(player, transition)
	if !IsValid(player) then return end

	if player:Team() == TEAM_SURVIVOR then
		player_manager.SetPlayerClass(player, "player_survivor")
	elseif player:Team() == TEAM_SLASHER then
		player_manager.SetPlayerClass(player, "player_slasher_base")
	elseif player:Team() == TEAM_LOBBY then
		player_manager.SetPlayerClass(player, "player_lobby")
	end

	if ( self.TeamBased and ( player:Team() == TEAM_SPECTATOR or player:Team() == TEAM_UNASSIGNED ) ) then
		self:PlayerSpawnAsSpectator( player )
		return
	end

	-- Stop observer mode
	player:UnSpectate()

	player:SetupHands()

	player_manager.OnPlayerSpawn( player, transiton )
	player_manager.RunClass( player, "Spawn" )

	-- If we are in transition, do not touch player's weapons
	if ( !transiton ) then
		-- Call item loadout function
		hook.Call( "PlayerLoadout", GAMEMODE, player )
	end

	-- Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, player )
end

function GM:PlayerDeathThink(ply)
	if ply:Team() == TEAM_SPECTATOR then
		local pos = ply:GetPos()+Vector(0,0,64)
		local eyeang = ply:EyeAngles()

		ply:Spawn()
		ply:SetPos(pos)
		ply:SetEyeAngles(eyeang)

		return true
	end

	ply:Spawn()
	return true
end

function GM:CanPlayerSuicide(player)
	if player:Team() == TEAM_SPECTATOR or player:Team() == TEAM_SLASHER then
		return false
	end

	return true
end

--Proximity voice chat

hook.Add( "PlayerCanHearPlayersVoice", "Maximum Range", function( listener, talker )
    if listener:GetPos():DistToSqr( talker:GetPos() ) > 1000000 then
		return false
	end

	if talker:Team() == TEAM_SPECTATOR or talker:Team() == TEAM_SLASHER then return false end
end )



--[[

I want to put these here
but they just don't work

SlashCo.PlayerData[pid].Lives for some reason returns nil here, but not in init

i am going insane



function GM:PlayerDeath(victim, inflictor, attacker)

if SERVER then

	print(SlashCo.PlayerData[victim:SteamID64()].Lives)

	if !IsValid(victim) then return end

    if GAMEMODE.State == GAMEMODE.States.IN_GAME and victim:Team() == TEAM_SURVIVOR then
        --local pid = victim:SteamID64()
		local lives = SlashCo.PlayerData[pid].Lives
		SlashCo.PlayerData[pid].Lives = tonumber(lives)-1
        
		if tonumber(lives)-1 <= 0 then
			print("[SlashCo] '"..victim:GetName().."' is out of lives, moving them to the Spectator team.")

			local ragdoll = ents.Create("prop_ragdoll")
			ragdoll:SetModel(victim:GetModel())
			ragdoll:SetPos(victim:GetPos())
			ragdoll:SetAngles(victim:GetAngles())
			ragdoll:SetNoDraw(false)
			local phys = ragdoll:GetPhysicsObject()
			if IsValid(phys) then phys:ApplyForceCenter( victim:GetVelocity() ) end
			ragdoll:Spawn()

			victim:SetTeam( TEAM_SPECTATOR )
			
		end
    end

end

end

hook.Add("PlayerDeath", "SurvivorDying", function(victim, inflictor, attacker) --Deathward

if SERVER then

	if victim:Team() != TEAM_SURVIVOR then return end

	local pid = victim:SteamID64()

	--if SlashCo.GetHeldItem(victim) != 0 or SlashCo.GetHeldItem(victim) != 2 or SlashCo.GetHeldItem(victim) != 99 then
	--	SlashCo.DropItem(victim)
	--end

	victim:SetNWBool("DynamicFlashlight", false)

	if SlashCo.PlayerData[pid] == nil then return end

	if SlashCo.PlayerData[pid].Lives > 1 then
		victim:EmitSound( "slashco/survivor/deathward.mp3")
		victim:EmitSound( "slashco/survivor/deathward_break"..math.random(1,2)..".mp3")

		SlashCo.RespawnPlayer(victim)

		SlashCo.ChangeSurvivorItem(pid, 99)

		return
	end

end
	
end)
]]