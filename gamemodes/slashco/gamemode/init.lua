AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "player.lua" )
include( "globals.lua" )
include( "master_database.lua" )
include( "lobby.lua" )
include( "ui/data_info.lua" )
include( "items.lua" )
include( "net.lua" )
include( "slasher/slasher_func.lua" )
include( "slasher/slasher_primary.lua" )
include( "slasher/slasher_chasemode.lua" )
include( "slasher/slasher_mainability.lua" )
include( "slasher/slasher_specialability.lua" )
include( "slasher/slasher_ability_handler.lua" )


--[[

SlashCo Credits:

Coding: Octo, Manti

Assets: Manti, warman, Darken

Extra credits: undo, Jim, DarkGrey

]]

local SlashCo = SlashCo
local roundOverToggle = SlashCo.CurRound.roundOverToggle

concommand.Add( "set_team", function( ply, cmd, args )
	local Team = args[1] or 1
	ply:SetTeam( Team )
	ply:Spawn()
end )

--Initialize global variable to hold functions.
if not SlashCo then SlashCo = {} end

function GM:Initialize()
    --If there is no data folder then make one.
    if !file.Exists("slashco", "DATA") then
        print("[SlashCo] The data folder for this gamemode doesn't appear to exist, creating it now.")
        file.CreateDir("slashco/playerdata")

		--Return to the lobby if no game is in progress and we just loaded in.
			if GAMEMODE.State != GAMEMODE.States.IN_GAME and game.GetMap() != "sc_lobby" then
			SlashCo.GoToLobby()
			GAMEMODE.State = GAMEMODE.States.LOBBY
		else
			GAMEMODE.State = GAMEMODE.States.IN_GAME
		end

    end

	if game.GetMap() == "sc_lobby" then

		SlashCo.CreateHelicopter( Vector(-567, 515, 176), Angle(0,45,0))

		SlashCo.CreateItemStash(Vector(-1168, -550, 300), Angle(0,90,90) )

		SlashCo.CreateOfferTable(Vector(-1435, 736, 224), Angle(0,-90,0))

	end

end

hook.Add( "AllowPlayerPickup", "PickupNotSpectator", function( ply, ent )
    return (ply:Team() != TEAM_SPECTATOR)
end )

function GM:PlayerButtonDown(ply, button)

	if ply:Team() == TEAM_SPECTATOR then
		if button == 107 then --Spectator Left Clicks
			if IsValid(ply:GetObserverTarget()) and ply:GetObserverMode() != OBS_MODE_ROAMING then --Stop spectating if already spectating a player.
				local pos = ply:GetPos()
				local eyeang = ply:EyeAngles()

				ply:UnSpectate()
				ply:Spawn()
				ply:SetPos(pos)
				ply:SetEyeAngles(eyeang)
			else --Spectate the player aimed at
				local ent = ply:GetEyeTrace().Entity

				if ent:IsPlayer() then --Only allow spectators to spectate other players.
					ply:SpectateEntity(ent)
					ply:SetObserverMode( OBS_MODE_CHASE )
				end
			end
		end

		if button == 65 then --Spectator presses Space, cycles camera modes.
			if ply:GetObserverMode() == OBS_MODE_CHASE then
				ply:SetObserverMode( OBS_MODE_IN_EYE )
			elseif ply:GetObserverMode() == OBS_MODE_IN_EYE then
				ply:SetObserverMode( OBS_MODE_CHASE )
			end
		end
	end


	if game.GetMap() == "sc_lobby" then --Lobby-Specific binds

		--Ready States
		if SlashCo.LobbyData.LOBBYSTATE == 0 then
			if ply:Team() == TEAM_LOBBY and button == 92 then
				if getReadyState(ply) != 1 then
					ply:ChatPrint( "Now ready as Survivor." )
					lobbyPlayerReadying(ply, 1)
					broadcastLobbyInfo()
				end
			end

			if ply:Team() == TEAM_LOBBY and button == 93 then
				if getReadyState(ply) != 2 then

					--Check if the player has made an offering or agreed to one
					if isPlyOfferor(ply) then ply:ChatPrint( "Cannot ready as Slasher as you have either made or agreed to an Offering." ) return end

					ply:ChatPrint( "Now ready as Slasher." )
					lobbyPlayerReadying(ply, 2)
					broadcastLobbyInfo()
				end
			end

			if ply:Team() == TEAM_LOBBY and button == 95 and SlashCo.LobbyData.VotedOffering > 0 and not isPlyOfferor(ply) then 
				SlashCo.OfferingVote(ply, true)
				SlashCo.EndOfferingVote(ply)
				ply:ChatPrint("You agree to the Offering.")
			end
		end

		--Switching Teams
		if button == 58 and SlashCo.LobbyData.LOBBYSTATE == 0 then
			if ply:Team() == TEAM_SPECTATOR then
				if(#team.GetPlayers(TEAM_LOBBY) < 5) then	--Joining the Lobby team.
				
					ply:SetTeam(TEAM_LOBBY)
					ply:Spawn()
					ply:ChatPrint( "Now joining the Lobby..." )

				else 
					ply:ChatPrint( "The Lobby is currently full." )
				end

			elseif ply:Team() == TEAM_LOBBY then
				if(#team.GetPlayers(TEAM_LOBBY) > 2) then	--Joining the Spectator team.
				
					ply:SetTeam(TEAM_SPECTATOR)
					ply:Spawn()
					ply:ChatPrint( "Now joining Spectators..." )

				else 
					ply:ChatPrint( "Cannot Spectate with less than 3 players." )
				end
			end	
		end

	else

		--Usage of Items

		if ply:Team() == TEAM_SURVIVOR then 

			if button == 28 then SlashCo.UseItem(ply) end --Using their Item
			if button == 27 then SlashCo.DropItem(ply) end --Dropping their Item

		end

		--Slasher General Binds

		if ply:Team() == TEAM_SLASHER then 

			if button == 107 then SlashCo.SlasherPrimaryFire(ply) end --Killing / Damaging
			if button == 108 then SlashCo.SlasherCallForChaseMode(ply) end --Activate Chase Mode
			if button == 28 then SlashCo.SlasherMainAbility(ply) end --Main Ability
			if button == 16 then SlashCo.SlasherSpecialAbility(ply) end --Special

		end

	end

end

function GM:PlayerDeathSound()
    return true
end

function GM:PlayerShouldTakeDamage( ply, attacker )
	if attacker:IsPlayer() or attacker:IsNPC() then
		if attacker:Team() == ply:Team() then return false end
	end
	return ply:Team() == TEAM_SURVIVOR
end

hook.Add("OnPlayerChangedTeam", "octoSlashCoOnPlayerChangedTeam", function( ply, oldteam, newteam )

	-- Here's an immediate respawn thing by default. If you want to
	-- re-create something more like CS or some shit you could probably
	-- change to a spectator or something while dead.
	if ( newteam == TEAM_SPECTATOR ) then

		-- If we changed to spectator mode, respawn where we are
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos( Pos )

	elseif ( oldteam == TEAM_SPECTATOR ) then

		-- If we're changing from spectator, join the game
		ply:Spawn()

	else

		-- If we're straight up changing teams just hang
		-- around until we're ready to respawn onto the
		-- team that we chose

	end

	--PrintMessage( HUD_PRINTTALK, Format( "%s joined '%s'", ply:Nick(), team.GetName( newteam ) ) )


	--Ready Message

	SlashCo.BroadcastGlobalData()

	SlashCo.BroadcastItemData()

end)

hook.Add("InitPostEntity", "octoSlashCoInitPostEntity", function()
	if SERVER then
		print("[SlashCo] InitPostEntity Started.")
		RunConsoleCommand("sv_alltalk", "2")
		
		if game.GetMap() != "sc_lobby" then
			GAMEMODE.State = GAMEMODE.States.IN_GAME

			SlashCo.LoadCurRoundData()
			--SlashCo.LoadCurRoundTeams()

		end
	end

	--if game.GetMap() == "sc_lobby" then EmitSound( "slashco/music/slashco_lobby.wav", Vector(0,0,0), 0, CHAN_STATIC, 1, 100) end

end)

local setupPlayerData = false
local Think = function()

	if SlasherData_Tick == nil then SlasherData_Tick = 0 end
	SlasherData_Tick = SlasherData_Tick + 1

	if GAMEMODE.State == GAMEMODE.States.IN_GAME and SlasherData_Tick > 5 then SlashCo.BroadcastSlasherData() SlasherData_Tick = 0 end
	--I LOVE SENDING A MASSIVE DATA TABLE EVERY (5)TICK!
	--This is the best way to do it I promise!

	if CLIENT then
		for i = 1, #player.GetAll() do
            local target = player.GetAll()[i]
    
            if target:GetNWBool("DynamicFlashlight") then
                if target.DynamicFlashlight then
                    local position = target:GetPos()
    
                    target.DynamicFlashlight:SetPos(Vector(position[1], position[2], position[3] + 40) + target:GetForward() * 20)
                    target.DynamicFlashlight:SetAngles(target:EyeAngles())
                    target.DynamicFlashlight:Update()
                else
                    local light = ProjectedTexture()
                    target.DynamicFlashlight = light
                    target.DynamicFlashlight:SetTexture("effects/flashlight001")
                    target.DynamicFlashlight:SetFarZ(900)
                    target.DynamicFlashlight:SetFOV(70)
                end
            else
                if target.DynamicFlashlight then
                    target.DynamicFlashlight:Remove()
                    target.DynamicFlashlight = nil
                end
            end
        end
	end

	if SERVER then
		local plys = player.GetAll()
		for i=1, #plys do
			if not plys[i]:IsConnected() then
				print("[SlashCo] Not everyone is connected yet.")
				return
			end
		end
		
		--Assign everyone to the data table.
		if not setupPlayerData then
			local plys = player.GetAll()
			for i=1, #plys do
				if IsValid(plys[i]) and plys[i]:Team() == TEAM_SURVIVOR then
					table.insert(SlashCo.CurRound.AlivePlayers, plys[i])
				elseif IsValid(plys[i]) and plys[i]:Team() == TEAM_SLASHER then
					table.insert(SlashCo.CurRound.Slashers, plys[i])
				end
			end
			setupPlayerData = true
		end

		--If a survivor is dead move em over to the dead players list.
		local plys = player.GetAll()
		for i=1, #plys do
			if IsValid(plys[i]) and plys[i]:Team() == TEAM_SPECTATOR and table.HasValue(SlashCo.CurRound.AlivePlayers, plys[i]) then
				table.insert(SlashCo.CurRound.DeadPlayers, plys[i])
				table.RemoveByValue(SlashCo.CurRound.AlivePlayers, plys[i])
			end
		end

		if SlashCo.CurRound != nil and GAMEMODE.State == GAMEMODE.States.IN_GAME and #(table.GetKeys(SlashCo.CurRound.Generators)) > 0 then
			local allRunning = true
			local gens = table.GetKeys(SlashCo.CurRound.Generators)
			for I=1, #gens do

				if not SlashCo.CurRound.Generators[gens[I]].Running then
					allRunning = false
					break
				end

			end

			for I=1, #gens do

				if SlashCo.CurRound.OfferingData.DO then

					if SlashCo.CurRound.Generators[gens[I]].Running then
						allRunning = true
						break
					end

				end

			end

			--DRAINAGE \/ \/ \/

			if SlashCo.CurRound.OfferingData.CurrentOffering == 3 then

				local gn1 = SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[1]:EntIndex()].Remaining
    			local gn2 = SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[2]:EntIndex()].Remaining

				local needed = gn1 + gn2

				if #SlashCo.CurRound.GasCans < (needed + 1) then return end --Prevent draining if there is too few gas cans

				SlashCo.CurRound.OfferingData.DrainageTick = SlashCo.CurRound.OfferingData.DrainageTick + FrameTime()

				if SlashCo.CurRound.OfferingData.DrainageTick > 50 then --Drain the gas
					SlashCo.CurRound.OfferingData.DrainageTick = 0
					local r = math.random(1,2)

					if SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[r]:EntIndex()].Remaining < 4 then
						SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[r]:EntIndex()].Remaining = SlashCo.CurRound.Generators[ents.FindByClass("sc_generator")[r]:EntIndex()].Remaining + 1
					end
				end

			end

			--DRAINAGE /\ /\ /\

			--Open the trailer door here when it's ready. For now it instantly ends the round.
			if allRunning and SlashCo.CurRound.SummonHelicopter == false then
				SlashCo.CurRound.SummonHelicopter = true

				--(SPAWN HELICOPTER)

				SlashCo.SummonEscapeHelicopter()			

			end

			SlashCo.CurRound.SurvivorCount = #(team.GetPlayers(TEAM_SURVIVOR))
			--Go back to lobby if everyone dies.
			if SlashCo.CurRound.SurvivorCount == 0 and SlashCo.CurRound.roundOverToggle then

				--SlashCo.EndRound()

				SlashCo.CurRound.roundOverToggle = false
			end
		end
	end
end

hook.Add("PostGamemodeLoaded", "octoSlashCoPostGamemodeLoaded", function()
	timer.Simple(1, function() hook.Add("Think", "octoSlashCoCoreThink", Think) end)
end)

hook.Add("PlayerInitialSpawn", "octoSlashCoPlayerInitialSpawn", function(ply, transition)

	if SERVER then

	local pid = ply:SteamID64()
	local data = {}

	--Don't load playerdata if it's already loaded
	if SlashCo.PlayerData[ply:SteamID64()] != nil then return end

	--If the player doesn't have a save file then create one for them.
	if !file.Exists("slashco/playerdata/"..tostring(ply:SteamID64())..".json", "DATA") then
		local json = '{ "Stats": { "RoundsWon": { "Survivor": 0, "Slasher": 0 }, "Achievements": [] } }'

		print("[SlashCo] No playerdata file found for '"..ply:GetName().."', making one for them.")

		data = util.JSONToTable(json)
		file.Write("slashco/playerdata/"..tostring(ply:SteamID64())..".json", json)
	else 
		data = util.JSONToTable(file.Read("slashco/playerdata/"..tostring(ply:SteamID64())..".json", "DATA"))
	end

	print("[SlashCo] Loaded playerdata for '"..ply:GetName().."'")

	SlashCo.PlayerData[pid] = {}
	SlashCo.PlayerData[pid].Lives = 1
	SlashCo.PlayerData[pid].RoundsWonSurvivor = data.Stats.RoundsWon.Survivor or 0
	SlashCo.PlayerData[pid].RoundsWonSlasher = data.Stats.RoundsWon.Slasher or 0

	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spawn()
	hook.Run("LobbyInfoText")

	SlashCoDatabase.OnPlayerJoined(pid)

	SlashCo.AwaitExpectedPlayers()

	SlashCo.BroadcastGlobalData()

end

end)

hook.Add("PlayerChangedTeam", "octoSlashCoPlayerChangedTeam", function(ply, old, new)

if SERVER then

	local pid = ply:SteamID64()

	if new == TEAM_SURVIVOR then
		SlashCo.PlayerData[pid].Lives = 1
	end

	if new == TEAM_LOBBY and #team.GetPlayers(TEAM_LOBBY) > 5 then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spawn()
		ply:ChatPrint( "[SlashCo] The Lobby is full. Switching to Spectator..." )
	end

	if old == TEAM_LOBBY  then
		lobbyPlayerReadying(ply, 0)
	end

	if old == TEAM_SURVIVOR then
		ply:SetNWBool("DynamicFlashlight", false)
	end

	if game.GetMap() == "sc_lobby" then
		net.Start("mantislashcoGiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE,3)
		net.Broadcast()
	end

end

end)


function GM:PlayerDeath(victim, inflictor, attacker)
	
		if !IsValid(victim) then return end
	
		if GAMEMODE.State == GAMEMODE.States.IN_GAME and victim:Team() == TEAM_SURVIVOR then
			local pid = victim:SteamID64()
			local lives = SlashCo.PlayerData[pid].Lives
			SlashCo.PlayerData[pid].Lives = tonumber(lives)-1
			
			if tonumber(lives)-1 <= 0 then
				print("[SlashCo] '"..victim:GetName().."' is out of lives, moving them to the Spectator team.")
	
				--Spawn the Ragdoll

				local ragdoll = ents.Create("prop_ragdoll")
				ragdoll:SetModel(victim:GetModel())
				ragdoll:SetPos(victim:GetPos())
				ragdoll:SetAngles(victim:GetAngles())
				ragdoll:SetNoDraw(false)
				ragdoll:Spawn()

				local physCount = ragdoll:GetPhysicsObjectCount()
	
				for i = 0, (physCount - 1) do
					local PhysBone = ragdoll:GetPhysicsObjectNum(i)
		
					if PhysBone:IsValid() then
						PhysBone:SetVelocity(victim:GetVelocity() * 2)
						PhysBone:AddAngleVelocity(-PhysBone:GetAngleVelocity())

						local ragbone = ragdoll:TranslatePhysBoneToBone( i )
						for b = 1, victim:GetBoneCount() do
							local plybone = victim:TranslateBoneToPhysBone( b )

							if plybone == PhysBone then
								PhysBone:AlignAngles( PhysBone:GetAngles(), plybone:GetAngles())
							end

						end
					end
				end

				--...............
	
				victim:SetTeam( TEAM_SPECTATOR )
				victim:Spawn()
				victim:SetPos(ragdoll:GetPos())
				
			end
		end
	
	
end
	
hook.Add("PlayerDeath", "SurvivorDying", function(victim, inflictor, attacker) --Deathward
	
	if SERVER then
	
		if victim:Team() != TEAM_SURVIVOR then return end
	
		local pid = victim:SteamID64()
	
		if SlashCo.GetHeldItem(victim) != 0 or SlashCo.GetHeldItem(victim) != 2 or SlashCo.GetHeldItem(victim) != 99 then
			SlashCo.DropItem(victim)
		end
	
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


--Dynamic Flashlight by RiggsMacKay
--https://github.com/RiggsMackay/Dynamic-Flashlight


if SERVER then
    hook.Add("PlayerSwitchFlashlight", "DynamicFlashlight.Switch", function(ply, state)

        if ply:Team() != TEAM_SURVIVOR then return false end

		if state == false then return false end

        ply:SetNWBool("DynamicFlashlight", not ply:GetNWBool("DynamicFlashlight"))
		if ply:GetNWBool("DynamicFlashlight") then ply:EmitSound("slashco/survivor/flashlight-switchoff.wav", 60, 100) end
		if not ply:GetNWBool("DynamicFlashlight") then ply:EmitSound("slashco/survivor/flashlight-switchon.wav", 60, 100) end

        return false
    end)
end

hook.Add("ShowTeam", "DoNotAllowTeamSwitch", function()
	return false
end)