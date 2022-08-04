include( "globals.lua" )

--local SlashCo = SlashCo

function GM:PlayerInitialSpawn(ply, _)
	if game.GetMap() == "sc_lobby" then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spawn()
	end
end

function GM:PlayerSpawn(player, _)
	if not IsValid(player) then return end

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
	if ( not transiton ) then
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

	if talker:Team() == TEAM_SPECTATOR or talker:Team() == TEAM_SLASHER then return false end

    if listener:GetPos():DistToSqr( talker:GetPos() ) > 1000000 then
		return false
	end

end )

hook.Add( "GetFallDamage", "RealisticDamage", function( _, speed )
    return ( speed / 16 )
end )

hook.Add( "PlayerCanSeePlayersChat", "TeamChat", function( _, _, listener, speaker)

	if listener:Team() == TEAM_SPECTATOR then return true end
	if speaker:Team() == TEAM_SLASHER then return false end
	if speaker:Team() == TEAM_SPECTATOR and listener:Team() ~= TEAM_SPECTATOR then return false end

	if listener:GetPos():DistToSqr( speaker:GetPos() ) > 1000000 then 
		return false 
	else
		if speaker:Team() == TEAM_SURVIVOR then 
			return true 
		end
	end

end )

hook.Add("ShowTeam", "DoNotAllowTeamSwitch", function()
	return false
end)

hook.Add( "PlayerUse", "STOP", function( ply, _ )

	if ply:Team() == TEAM_SPECTATOR then
		return false
	else
		return
	end

end )