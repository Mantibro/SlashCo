AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "items/items_init.lua" )
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
include( "selectables.lua" )

--[[

SlashCo Credits:

Coding: Octo, Manti

Assets: Manti, warman, Darken

Extra credits: undo, Jim, DarkGrey

]]

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems
--local roundOverToggle = SlashCo.CurRound.roundOverToggle

CreateConVar( "slashco_map_default", 0, FCVAR_NONE, "Allow the gamemode to access all conifgured maps.", 0, 1 )
CreateConVar( "slashco_force_difficulty", 0, FCVAR_NONE, "Have the gamemode force a certan difficulty.(0 - random, 1 - EASY, 2 - NOVICE, 3 - INTERMEDIATE, 4 - HARD)", 0, 4 )

concommand.Add( "slashco_add_survivor", function( ply, _, args )
	
	if IsValid(ply) then
		if ply:IsPlayer() then
			if not ply:IsAdmin() then
				ply:ChatPrint("Only admins can use debug commands!")
				return
			end
		end
	end

	if args[1] == nil or args[1] == "" or args[2] == nil or args[2] == "" then
		ply:ChatPrint("Command format: slashco_add_survivor [Player Name]")

		return
	end

	if game.GetMap() == "sc_lobby" then
		ply:ChatPrint("Cannot assign Survivor while in lobby.")

		return
	end

	local theman = ""

	for i = 1, #player.GetAll() do

		local p = player.GetAll()[1]

		if p:GetName() == args[1] then
			theman = p:SteamID64()
			break
		end

	end

	if theman == "" then
		ply:ChatPrint("Player not found.")
		return
	end

	if player.GetBySteamID64(theman):Team() ~= TEAM_SPECTATOR then
		ply:ChatPrint("Player must be Spectator.")
		return
	end

	for s = 1, #SlashCo.CurRound.SlasherData.AllSurvivors do

		if SlashCo.CurRound.SlasherData.AllSurvivors[s].id == theman then
			goto FOUND
		end

	end

	table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = theman, GameContribution = 0})
    table.insert(SlashCo.CurRound.SurvivorData.Items, {steamid = theman, itemid = 0})  

	::FOUND::

	ply:ChatPrint("New Survivor successfully assigned.")

	ply:SetTean( TEAM_SURVIVOR )
	ply:Spawn()
         
end )

concommand.Add( "slashco_add_slasher", function( ply, _, args )
	
	if IsValid(ply) then
		if ply:IsPlayer() then
			if not ply:IsAdmin() then
				ply:ChatPrint("Only admins can use debug commands!")
				return
			end
		end
	end

	if game.GetMap() == "sc_lobby" then
		ply:ChatPrint("Cannot assign Slasher while in lobby.")

		return
	end

	if args[1] == nil or args[1] == "" or args[2] == nil or args[2] == "" then
		ply:ChatPrint("Command format: slashco_add_slasher [Player Name] [Slasher ID]")

		return
	end

	if tonumber(args[2]) > #SlashCo.SlasherData or tonumber(args[2]) < 1 then
		ply:ChatPrint("Incorrect Slasher ID")

		return
	end

	local theman = ""

	for i = 1, #player.GetAll() do

		local p = player.GetAll()[1]

		if p:GetName() == args[1] then
			theman = p:SteamID64()
			break
		end

	end

	if theman == "" then
		ply:ChatPrint("Player not found.")
		return
	end

	if player.GetBySteamID64(theman):Team() ~= TEAM_SPECTATOR then
		ply:ChatPrint("Player must be Spectator.")
		return
	end

	for s = 1, #SlashCo.CurRound.SlasherData do

		if SlashCo.CurRound.SlasherData[theman] ~= nil then
			goto ALREADYIN
		end

	end

	SlashCo.InsertSlasherToTable(theman)

	::ALREADYIN::

	SlashCo.SelectSlasher(tonumber(args[2]), theman)

	ply:ChatPrint("New Slasher successfully assigned.")

	ply:SetTean( TEAM_SLASHER )
	ply:Spawn()
end )

hook.Add( "CanExitVehicle", "PlayerMotion", function( _, _ )
    return false
end )

--Initialize global variable to hold functions.
if not SlashCo then SlashCo = {} end

function GM:Initialize()

	--if CLIENT then

		CreateClientConVar( "cl_slashco_playermodel", "models/slashco/survivor/male_01.mdl", true, true, "SlashCo Survivor Playermodel" )
	
		cvars.AddChangeCallback( "cl_slashco_playermodel", function(_, _, newVal)
	
			if newVal ~= "models/slashco/survivor/male_0*.mdl" then
				--print("[SlashCo] Bad Playermodel. It will be randomized instead.")
			end
		
		end)
	
	--end

    --If there is no data folder then make one.
	if not file.Exists("slashco", "DATA") then
		print("[SlashCo] The data folder for this gamemode doesn't appear to exist, creating it now.")
		file.CreateDir("slashco/playerdata")

		--Return to the lobby if no game is in progress and we just loaded in.
		if GAMEMODE.State ~= GAMEMODE.States.IN_GAME and game.GetMap() ~= "sc_lobby" then
			SlashCo.GoToLobby()
			--print("tried to go to lobby (bad state)")
			GAMEMODE.State = GAMEMODE.States.LOBBY
		else
			GAMEMODE.State = GAMEMODE.States.IN_GAME
		end

	end

	if game.GetMap() == "sc_lobby" then

		SlashCo.CreateHelicopter( Vector(-544, 625, 200), Angle(0,45,0))

		SlashCo.CreateItemStash(Vector(-1168, -550, 300), Angle(0,90,90) )

		SlashCo.CreateOfferTable(Vector(-1435, 736, 224), Angle(0,-90,0))

	end

	if SERVER then
		resource.AddFile( "resource/fonts/ANKLEPAN.tff" )
		resource.AddFile( "resource/fonts/KILOTON1.tff" )
		resource.AddFile( "resource/fonts/forcible.tff" )
		resource.AddFile( "resource/fonts/terminatortwo.tff" )
		resource.AddFile( "resource/fonts/glare.tff" )
		resource.AddFile( "resource/fonts/Comic_Papyrus.tff" )
		resource.AddFile( "resource/fonts/Alternative.tff" )
	end

end

hook.Add( "AllowPlayerPickup", "PickupNotSpectator", function( ply, _ )

	if ply:Team() == TEAM_SLASHER then

		if SlashCo.CurRound.SlasherData[ply:SteamID64()].SlasherID == 6 and SlashCo.CurRound.SlasherData[ply:SteamID64()].SlasherValue1 == 0 then
			return false
		end

		if SlashCo.CurRound.SlasherData[ply:SteamID64()].SlasherID == 7 and SlashCo.CurRound.SlasherData[ply:SteamID64()].SlasherValue1 == 0 then
			return false
		end

	end

    return (ply:Team() ~= TEAM_SPECTATOR)
end )

function GM:PlayerButtonDown(ply, button)

	if ply:Team() == TEAM_SPECTATOR then
		if button == 107 then --Spectator Left Clicks
			if IsValid(ply:GetObserverTarget()) and ply:GetObserverMode() ~= OBS_MODE_ROAMING then --Stop spectating if already spectating a player.
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
				if getReadyState(ply) ~= 1 then
					ply:ChatPrint( "Now ready as Survivor." )
					lobbyPlayerReadying(ply, 1)
					broadcastLobbyInfo()
				else
					ply:ChatPrint( "You are no longer ready." )
					lobbyPlayerReadying(ply, 0)
					broadcastLobbyInfo()
				end
				Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(100, 0)
			end

			if ply:Team() == TEAM_LOBBY and button == 93 then
				if getReadyState(ply) ~= 2 then

					--Check if the player has made an offering or agreed to one
					if isPlyOfferor(ply) then
						ply:ChatPrint( "Cannot ready as Slasher as you have either made or agreed to an Offering." )
						Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
						Sndd:Play()
						Sndd:ChangeVolume(0.5, 0)
						Sndd:ChangePitch(65, 0)
						return
					end

					ply:ChatPrint( "Now ready as Slasher." )
					lobbyPlayerReadying(ply, 2)
					broadcastLobbyInfo()
					Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
					Sndd:Play()
					Sndd:ChangeVolume(0.5, 0)
					Sndd:ChangePitch(100, 0)
				else
					ply:ChatPrint( "You are no longer ready." )
					lobbyPlayerReadying(ply, 0)
					broadcastLobbyInfo()
					Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
					Sndd:Play()
					Sndd:ChangeVolume(0.5, 0)
					Sndd:ChangePitch(100, 0)
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
					Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
					Sndd:Play()
					Sndd:ChangeVolume(0.5, 0)
					Sndd:ChangePitch(80, 0)

				else 
					ply:ChatPrint( "The Lobby is currently full." )
					Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
					Sndd:Play()
					Sndd:ChangeVolume(0.5, 0)
					Sndd:ChangePitch(65, 0)
				end

			elseif ply:Team() == TEAM_LOBBY then
				ply:SetTeam(TEAM_SPECTATOR)
				ply:Spawn()
				ply:ChatPrint( "Now joining Spectators..." )
				Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(80, 0)
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

	if ply:Team() == TEAM_SURVIVOR then --Taunts

		if button == 1 then 

			--ply:SetNWBool("Taunt_Cali", true) --California girls --copyright :(
			return

		elseif button == 2 then 

			ply:SetNWBool("Taunt_MNR", true) --Monday Night
			return

		elseif button == 3 then 

			ply:SetNWBool("Taunt_Griddy", true) --Hittin the griddy
			return

		elseif ply:GetNWBool("Taunt_MNR") or ply:GetNWBool("Taunt_Griddy") then

			ply:SetNWBool("Taunt_MNR", false)
			if button ~= 33 then ply:SetNWBool("Taunt_Griddy", false) end

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

		if game.GetMap() == "rp_deadcity" then Entity(176):Fire("Press") end
		
		if game.GetMap() ~= "sc_lobby" then
			GAMEMODE.State = GAMEMODE.States.IN_GAME

			SlashCo.LoadCurRoundData()
			--SlashCo.LoadCurRoundTeams()

		end
	end

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
		if engine.TickCount()%math.floor(5/engine.TickInterval()) == 0 then
			for _, p in ipairs(plys) do
				if p:Team() == TEAM_SURVIVOR then
					local health = p:Health()
					if health > 100 then
						p:SetHealth(health-1)
					end
				end
			end
		end
		
		--Assign everyone to the data table.
		if not setupPlayerData then
			--local plys = player.GetAll()
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
		--local plys = player.GetAll()
		for i=1, #plys do
			if IsValid(plys[i]) and plys[i]:Team() == TEAM_SPECTATOR and table.HasValue(SlashCo.CurRound.AlivePlayers, plys[i]) then
				table.insert(SlashCo.CurRound.DeadPlayers, plys[i])
				table.RemoveByValue(SlashCo.CurRound.AlivePlayers, plys[i])
			end
		end

		if SlashCo.CurRound ~= nil and GAMEMODE.State == GAMEMODE.States.IN_GAME and #(table.GetKeys(SlashCo.CurRound.Generators)) > 0 then
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

			if allRunning and SlashCo.CurRound.SummonHelicopter == false then
				SlashCo.CurRound.SummonHelicopter = true

				--(SPAWN HELICOPTER)

				SlashCo.SummonEscapeHelicopter()	
				
				SlashCo.CurRound.DistressBeaconUsed = false

			end

			SlashCo.CurRound.SurvivorCount = #(team.GetPlayers(TEAM_SURVIVOR))
			--Go back to lobby if everyone dies.
			if SlashCo.CurRound.SurvivorCount == 0 and SlashCo.CurRound.roundOverToggle then

				SlashCo.EndRound()

				SlashCo.CurRound.roundOverToggle = false
			end
		end
	end
end

hook.Add("PostGamemodeLoaded", "octoSlashCoPostGamemodeLoaded", function()
	timer.Simple(1, function() hook.Add("Think", "octoSlashCoCoreThink", Think) end)
end)

hook.Add("PlayerInitialSpawn", "octoSlashCoPlayerInitialSpawn", function(ply, _)

	if SERVER then

	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spawn()

	local pid = ply:SteamID64()
	local data = {}

	--Don't load playerdata if it's already loaded
	if SlashCo.PlayerData[ply:SteamID64()] ~= nil then return end

	--If the player doesn't have a save file then create one for them.
	if not file.Exists("slashco/playerdata/"..tostring(ply:SteamID64())..".json", "DATA") then
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
	SlashCo.PlayerData[pid].PointsTotal = 0

	hook.Run("LobbyInfoText")

	SlashCoDatabase.OnPlayerJoined(pid)

	SlashCo.AwaitExpectedPlayers()

	SlashCo.BroadcastGlobalData()

	timer.Simple(2, function() 

		SlashCo.BroadcastMasterDatabaseForClient(pid) 
		SlashCo.BroadcastCurrentRoundData()
		SlashCo.BroadcastGlobalData()

	end)

end

end)

hook.Add("PlayerChangedTeam", "octoSlashCoPlayerChangedTeam", function(ply, old, new)

if SERVER then

	local pid = ply:SteamID64()

	SlashCo.BroadcastMasterDatabaseForClient(pid)

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

function GM:PlayerDeath(victim, _, _)

	if not IsValid(victim) then
		return
	end

	if GAMEMODE.State == GAMEMODE.States.IN_GAME and victim:Team() == TEAM_SURVIVOR then

		victim:SetNWBool("DynamicFlashlight", false)

		SlashCo.DropItem(victim)
		local itid = SlashCo.GetHeldItem(victim)
		tickLife = false

		if SlashCoItems[itid] and SlashCoItems[itid].OnDie then
			tickLife = SlashCoItems[itid].OnDie(victim)
		end

		if not tickLife then
			local pid = victim:SteamID64()
			local lives = SlashCo.PlayerData[pid].Lives
			SlashCo.PlayerData[pid].Lives = tonumber(lives) - 1

			if tonumber(lives) - 1 <= 0 then
				print("[SlashCo] '" .. victim:GetName() .. "' is out of lives, moving them to the Spectator team.")

				--Spawn the Ragdoll

				local ragdoll = ents.Create("prop_ragdoll")
				ragdoll:SetModel(victim:GetModel())
				ragdoll:SetPos(victim:GetPos())
				ragdoll:SetNoDraw(false)
				ragdoll:Spawn()

				local ang_offset = 0

				if victim:GetNWBool("SurvivorDecapitate") then

					ragdoll:ManipulateBoneScale(ragdoll:LookupBone("ValveBiped.Bip01_Head1"), Vector(0, 0, 0))

					local vPoint = ragdoll:GetBonePosition(ragdoll:LookupBone("ValveBiped.Bip01_Head1"))

					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					local dripfx = EffectData()
					dripfx:SetOrigin(vPoint)
					dripfx:SetFlags(3)
					dripfx:SetColor(0)
					dripfx:SetScale(6)
					util.Effect("bloodspray", dripfx)

					ang_offset = 180

				end

				ragdoll:SetAngles(Angle(0, victim:EyeAngles()[2] + ang_offset, 0))

				local physCount = ragdoll:GetPhysicsObjectCount()

				for i = 0, (physCount - 1) do
					local PhysBone = ragdoll:GetPhysicsObjectNum(i)

					if PhysBone:IsValid() then
						PhysBone:SetVelocity(victim:GetVelocity() * 2)
						PhysBone:AddAngleVelocity(-PhysBone:GetAngleVelocity())

						ragdoll:TranslatePhysBoneToBone(i) --local ragbone =
						for b = 1, victim:GetBoneCount() do
							local plybone = victim:TranslateBoneToPhysBone(b)

							if plybone == PhysBone then
								PhysBone:SetAngles(PhysBone:GetAngles(), plybone:GetAngles())
							end

						end
					end
				end

				--...............

				victim:SetTeam(TEAM_SPECTATOR)
				victim:Spawn()
				victim:SetPos(ragdoll:GetPos())

			end
		end
	end
end

--Dynamic Flashlight by RiggsMacKay
--https://github.com/RiggsMackay/Dynamic-Flashlight


if SERVER then
    hook.Add("PlayerSwitchFlashlight", "DynamicFlashlight.Switch", function(ply, state)

        if ply:Team() ~= TEAM_SURVIVOR and not ply:GetNWBool("AmogusSurvivorDisguise") then return false end

		if state == false then return false end

        ply:SetNWBool("DynamicFlashlight", not ply:GetNWBool("DynamicFlashlight"))
		if ply:GetNWBool("DynamicFlashlight") then ply:EmitSound("slashco/survivor/flashlight-switchoff.wav", 60, 100) end
		if not ply:GetNWBool("DynamicFlashlight") then ply:EmitSound("slashco/survivor/flashlight-switchon.wav", 60, 100) end

        return false
    end)
end