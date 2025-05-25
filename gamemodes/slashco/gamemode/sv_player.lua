--local SlashCo = SlashCo

function GM:PlayerSwitchWeapon()
	return false
end

function GM:PlayerInitialSpawn(ply)
	if GameData.IsLobby then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spawn()
	end
end

function GM:PlayerSpawn(ply, transition)
	if not IsValid(ply) then
		return
	end

	ply:StopAllGlobalSounds()
	ply:CrosshairDisable()

	if self.TeamBased then
		local tm = ply:Team()

		if tm == TEAM_SPECTATOR or tm == TEAM_UNASSIGNED then
			self:PlayerSpawnAsSpectator(ply)
			return
		end

		if tm == TEAM_SURVIVOR then
			player_manager.SetPlayerClass(ply, "player_survivor")
		elseif tm == TEAM_SLASHER then
			player_manager.SetPlayerClass(ply, "player_slasher_base")
		elseif tm == TEAM_LOBBY then
			player_manager.SetPlayerClass(ply, "player_lobby")
		end
	end

	-- Stop observer mode
	ply:UnSpectate()
	ply:SetupHands()

	player_manager.OnPlayerSpawn(ply, transition)
	player_manager.RunClass(ply, "Spawn")

	-- If we are in transition, do not touch player's weapons
	if not transition then
		-- Call item loadout function
		hook.Call("PlayerLoadout", GAMEMODE, ply)
	end

	-- Set player model
	hook.Call("PlayerSetModel", GAMEMODE, ply)
end

function GM:PlayerDeathThink(ply)
	if ply:Team() == TEAM_SPECTATOR then
		local pos = ply:EyePos()
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
	if player:Team() == TEAM_SPECTATOR or player:Team() == TEAM_SLASHER or GetGlobal2Bool("IsLobbyStarting") then
		return false
	end

	return true
end

--Proximity voice chat

local proximity_chat = CreateConVar("slashco_proximity_chat", "1", FCVAR_ARCHIVE, "Enables proximity chat")
local proximity_voice = CreateConVar("slashco_proximity_voice", "1", FCVAR_ARCHIVE, "Enables proximity voicechat")
local proximity_range = CreateConVar("slashco_proximity_range", "1000", FCVAR_ARCHIVE, "Sets the proximity range")

hook.Add("PlayerCanHearPlayersVoice", "Maximum Range", function(listener, talker)
	if not proximity_voice:GetBool() then
		return true
	end

	local talkerTeam = talker:Team()
	if talkerTeam == TEAM_SPECTATOR or talkerTeam == TEAM_SLASHER then
		return false
	end

	local range = proximity_range:GetInt()
	if listener:GetPos():DistToSqr(talker:GetPos()) > (range * range) then
		return false
	end
end)

hook.Add("GetFallDamage", "RealisticDamage", function(_, speed)
	return speed / 16
end)

hook.Add("PlayerCanSeePlayersChat", "TeamChat", function(_, _, listener, speaker)
	if not proximity_chat:GetBool() then
		return true
	end

	local listenerTeam = listener:Team()
	if listenerTeam == TEAM_SPECTATOR then
		return true
	end

	local speakerTeam = speaker:Team()
	if speakerTeam == TEAM_SLASHER then
		return false
	end

	if listenerTeam == TEAM_SLASHER then
		return false
	end

	if speakerTeam == TEAM_SPECTATOR and listenerTeam ~= TEAM_SPECTATOR then
		return false
	end

	local range = proximity_range:GetInt()
	if listener:GetPos():DistToSqr(speaker:GetPos()) > (range * range) then
		return false
	end

	if speakerTeam == TEAM_SURVIVOR then
		return true
	end
end)

hook.Add("ShowTeam", "DoNotAllowTeamSwitch", function()
	return false
end)

hook.Add("PlayerUse", "STOP", function(ply, _)
	if ply:Team() == TEAM_SPECTATOR then
		return false
	end
end)