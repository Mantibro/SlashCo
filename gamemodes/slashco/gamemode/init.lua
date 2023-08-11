AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_shared.lua")

AddCSLuaFile("ui/cl_fonts.lua")
AddCSLuaFile("ui/cl_scoreboard.lua")
AddCSLuaFile("cl_headbob.lua")
AddCSLuaFile("ui/cl_lobbyhud.lua")
AddCSLuaFile("ui/cl_survivor_hud.lua")
AddCSLuaFile("ui/cl_slasher_ui.lua")
AddCSLuaFile("slasher/cl_slasher_picker.lua")
AddCSLuaFile("ui/cl_item_picker.lua")
AddCSLuaFile("ui/cl_offering_picker.lua")
AddCSLuaFile("ui/cl_roundend_hud.lua")
AddCSLuaFile("ui/cl_offervote_hud.lua")
AddCSLuaFile("ui/cl_spectator_hud.lua")
AddCSLuaFile("ui/cl_playermodel_picker.lua")
AddCSLuaFile("ui/cl_gameinfo.lua")
AddCSLuaFile("ui/cl_voiceselect.lua")
AddCSLuaFile("ui/slasher_stock/cl_slasher_stock.lua")
AddCSLuaFile("ui/slasher_stock/cl_slasher_control.lua")
AddCSLuaFile("ui/slasher_stock/cl_slasher_meter.lua")
AddCSLuaFile("ui/slasher_stock/sh_slasher_hudfunctions.lua")
AddCSLuaFile("ui/cl_projector.lua")
AddCSLuaFile("cl_limitedzone.lua")

include("sv_globals.lua")
include("sh_shared.lua")
include("sv_spawning.lua")
include("items/items_init.lua")
include("slasher/slasher_init.lua")
include("sv_player.lua")
include("sv_game_logic.lua")
include("sv_master_database.lua")
include("sv_lobby.lua")
include("items/sv_items.lua")
include("sv_net.lua")
include("slasher/sv_slasher_func.lua")
include("sv_concommands.lua")
include("sv_ply_voicelines.lua")
include("sv_survivor_func.lua")
include("items/sv_playerspeed.lua")
include("ui/slasher_stock/sh_slasher_hudfunctions.lua")
include("sh_values.lua")
include("sh_doors.lua")
include("sh_chattext.lua")

local SlashCo = SlashCo or {}

--[[

SlashCo Credits:

Coding: Octo, Manti, Text

Assets: Manti, warman, Darken, Vee

Extra credits: undo, Jim, DarkGrey

]]

--local roundOverToggle = SlashCo.CurRound.roundOverToggle

CreateConVar("slashco_map_default", 0, FCVAR_NONE, "Allow the gamemode to access all conifgured maps.", 0, 1)
CreateConVar("slashco_force_difficulty", 0, FCVAR_NONE,
		"Have the gamemode force a certan difficulty.(0 - random, 1 - EASY, 2 - NOVICE, 3 - INTERMEDIATE, 4 - HARD)", 0,
		4)

hook.Add("CanExitVehicle", "PlayerMotion", function(veh, ply)
	if ply:Team() == TEAM_SURVIVOR then
		return veh.VehicleName ~= "Airboat Seat"
	end
end)

--Initialize global variable to hold functions.
if not SlashCo then
	SlashCo = {}
end

function GM:Initialize()
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
		SlashCo.CreateHelicopter(Vector(644.594, -423.175, 40.004), Angle(0, 45, 0))
		SlashCo.CreateItemStash(Vector(-483.500, -260.000, 88.000), Angle(90, 180, 180))
		SlashCo.CreateOfferTable(Vector(940.838, 890.909, -191.853), Angle(0, -90, 0))
	end

	if SERVER then
		resource.AddFile("resource/fonts/ANKLEPAN.tff")
		resource.AddFile("resource/fonts/KILOTON1.tff")
		resource.AddFile("resource/fonts/forcible.tff")
		resource.AddFile("resource/fonts/terminatortwo.tff")
		resource.AddFile("resource/fonts/glare.tff")
		resource.AddFile("resource/fonts/Comic_Papyrus.tff")
		resource.AddFile("resource/fonts/Alternative.tff")
	end
end

hook.Add("AllowPlayerPickup", "PickupNotSpectator", function(ply, ent)
	if ply:Team() == TEAM_SLASHER then
		return ply:SlasherFunction("PickUpAttempt", ent)
	end

	return (ply:Team() ~= TEAM_SPECTATOR)
end)

--lag-compensated eye trace for use in slasher functions
local function lagTrace(ply)
	ply:LagCompensation(true)
	local tr = ply:GetEyeTrace()
	ply:LagCompensation(false)

	return tr.Entity, tr
end

local function lobbyButtons(ply, button)
	if SlashCo.LobbyData.LOBBYSTATE == 0 then
		if ply:Team() == TEAM_LOBBY and button == 92 then
			if getReadyState(ply) ~= 1 then
				lobbyPlayerReadying(ply, 1)
				broadcastLobbyInfo()
			else
				lobbyPlayerReadying(ply, 0)
				broadcastLobbyInfo()
			end
			local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
			Sndd:Play()
			Sndd:ChangeVolume(0.5, 0)
			Sndd:ChangePitch(100, 0)
		end

		if ply:Team() == TEAM_LOBBY and button == 93 then
			if getReadyState(ply) ~= 2 then
				--Check if the player has made an offering or agreed to one
				if isPlyOfferer(ply) then
					ply:ChatPrint("Cannot ready as Slasher as you have either made or agreed to an Offering.")
					local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
					Sndd:Play()
					Sndd:ChangeVolume(0.5, 0)
					Sndd:ChangePitch(65, 0)
					return
				end

				lobbyPlayerReadying(ply, 2)
				broadcastLobbyInfo()
				local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(100, 0)
			else
				lobbyPlayerReadying(ply, 0)
				broadcastLobbyInfo()
				local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(100, 0)
			end
		end

		if ply:Team() == TEAM_LOBBY and button == 95 and SlashCo.LobbyData.VotedOffering > 0 and not isPlyOfferer(ply) then
			SlashCo.OfferingVote(ply, true)
			SlashCo.EndOfferingVote(ply)
		end
	end

	--Switching Teams
	if button == 58 and SlashCo.LobbyData.LOBBYSTATE == 0 then
		if ply:Team() == TEAM_SPECTATOR then
			if (#team.GetPlayers(TEAM_LOBBY) < SlashCo.MAXPLAYERS) then
				ply:SetTeam(TEAM_LOBBY)
				ply:Spawn()
				local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(80, 0)
			else
				ply:ChatPrint("The Lobby is currently full.")
				local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(65, 0)
			end
		elseif ply:Team() == TEAM_LOBBY then
			ply:SetTeam(TEAM_SPECTATOR)
			ply:Spawn()
			local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
			Sndd:Play()
			Sndd:ChangeVolume(0.5, 0)
			Sndd:ChangePitch(80, 0)
		end
	end
end
local function spectatorButtons(ply, button)
	if button == 107 then
		--Spectator Left Clicks
		if IsValid(ply:GetObserverTarget()) and ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			--Stop spectating if already spectating a player.
			local pos = ply:GetPos()
			local eyeang = ply:EyeAngles()

			ply:UnSpectate()
			ply:Spawn()
			ply:SetPos(pos)
			ply:SetEyeAngles(eyeang)
		else
			--Spectate the player aimed at
			local ent = ply:GetEyeTrace().Entity

			if ent:IsPlayer() then
				--Only allow spectators to spectate other players.
				ply:SpectateEntity(ent)
				ply:SetObserverMode(OBS_MODE_CHASE)
			end
		end

		return
	end

	if button == 108 then
		--Spectator Right Clicks
		if IsValid(ply:GetObserverTarget()) and ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			local ent = ply:GetObserverTarget()
			for k, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
				if ply:GetObserverTarget() == v then
					if (k + 1) >= team.NumPlayers(TEAM_SURVIVOR) then
						ent = team.GetPlayers(TEAM_SURVIVOR)[1]
					else
						ent = team.GetPlayers(TEAM_SURVIVOR)[k + 1]
					end
				end
			end

			if ent:IsPlayer() then
				ply:SpectateEntity(ent)
				--ply:SetObserverMode( OBS_MODE_CHASE )
			end
		else
			if IsValid(team.GetPlayers(TEAM_SURVIVOR)[1]) then
				ply:SpectateEntity(team.GetPlayers(TEAM_SURVIVOR)[1])
				ply:SetObserverMode(OBS_MODE_CHASE)
			end
		end

		return
	end

	if button == 65 then
		--Spectator presses Space, cycles camera modes.
		if ply:GetObserverMode() == OBS_MODE_CHASE then
			ply:SetObserverMode(OBS_MODE_IN_EYE)
		elseif ply:GetObserverMode() == OBS_MODE_IN_EYE then
			ply:SetObserverMode(OBS_MODE_CHASE)
		end

		return
	end
end
local function slasherButtons(ply, button)
	if button == 107 then
		ply:SlasherFunction("OnPrimaryFire", lagTrace(ply))
		return
	end --Killing / Damaging
	if button == 108 then
		ply:SlasherFunction("OnSecondaryFire", lagTrace(ply))
		return
	end --Activate Chase Mode
	if button == 28 then
		ply:SlasherFunction("OnMainAbilityFire", lagTrace(ply))
		return
	end --Main Ability
	if button == 16 then
		ply:SlasherFunction("OnSpecialAbilityFire", lagTrace(ply))
		return
	end --Special
end
function GM:PlayerButtonDown(ply, button)
	if game.GetMap() == "sc_lobby" then
		lobbyButtons(ply, button)
	end

	if ply:Team() == TEAM_SPECTATOR then
		spectatorButtons(ply, button)
		return
	end

	if ply:Team() == TEAM_SLASHER then
		slasherButtons(ply, button)
		return
	end
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if attacker:IsPlayer() or attacker:IsNPC() then
		if attacker:Team() == ply:Team() then
			return false
		end
	end
	return ply:Team() == TEAM_SURVIVOR
end

hook.Add("OnPlayerChangedTeam", "octoSlashCoOnPlayerChangedTeam", function(ply, oldteam, newteam)
	-- Here's an immediate respawn thing by default. If you want to
	-- re-create something more like CS or some shit you could probably
	-- change to a spectator or something while dead.
	if (newteam == TEAM_SPECTATOR) then

		-- If we changed to spectator mode, respawn where we are
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos(Pos)

	elseif (oldteam == TEAM_SPECTATOR) then

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
end)

hook.Add("InitPostEntity", "octoSlashCoInitPostEntity", function()
	print("[SlashCo] InitPostEntity Started.")
	RunConsoleCommand("sv_alltalk", "2")

	if game.GetMap() ~= "sc_lobby" then
		GAMEMODE.State = GAMEMODE.States.IN_GAME

		SlashCo.LoadCurRoundData()
		SlashCo.CurRound.GameProgress = -1
	end
end)

--local setupPlayerData = false
local Think = function()
	local plys = player.GetAll()
	if engine.TickCount() % math.floor(5 / engine.TickInterval()) == 0 then
		for _, p in ipairs(plys) do
			if p:Team() == TEAM_SURVIVOR then
				local health = p:Health()
				if health > 100 then
					p:SetHealth(health - 1)
				end
			end
		end
	end

	if SlashCo.CurRound.GameProgress == -1 then
		for _, v in ipairs(team.GetPlayers(TEAM_SPECTATOR)) do
			if SlashCo.CurRound.Slashers[v:SteamID64()] ~= nil and v:GetNWString("Slasher") ~= SlashCo.CurRound.Slashers[v:SteamID64()].SlasherID then
				SlashCo.ApplySlasherToPlayer(v)
			end
		end
	end

	if SlashCo.CurRound.GameProgress >= 0 then
		for _, ply in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if ply:GetNWInt("GameProgressDisplay") ~= SlashCo.CurRound.GameProgress then
				ply:SetNWInt("GameProgressDisplay", SlashCo.CurRound.GameProgress)
			end
		end
	end

	local gens = ents.FindByClass("sc_generator")
	if SlashCo.CurRound and GAMEMODE.State == GAMEMODE.States.IN_GAME and #gens > 0 then
		local runningCount = 0
		for _, v in ipairs(gens) do
			if v.IsRunning then
				runningCount = runningCount + 1
			end
		end

		local allRunning = true
		if runningCount < 2 then
			allRunning = false
		end

		--//drainage//--

		if SlashCo.CurRound.OfferingData.CurrentOffering == 3 then
			local totalCansRemaining = 0
			local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
			for _, v in ipairs(gens) do
				totalCansRemaining = totalCansRemaining + (v.CansRemaining or gasPerGen)
			end

			if #ents.FindByClass("sc_gascan") <= totalCansRemaining then
				return
			end --Prevent draining if there is too few gas cans

			if engine.TickCount() % math.floor(240 / engine.TickInterval()) == 0 then
				local random = math.random(#gens)
				gens[random].CansRemaining = math.Clamp((gens[random].CansRemaining or gasPerGen) + 1,
						0, gasperGen)
			end
		end

		--//helicopters//--

		if allRunning and not SlashCo.CurRound.EscapeHelicopterSummoned then
			--(SPAWN HELICOPTER)

			local failed = SlashCo.SummonEscapeHelicopter()

			if not failed then
				SlashCo.CurRound.DistressBeaconUsed = false
			end
		end

		--//duality condition//--
		if SlashCo.CurRound.OfferingData.CurrentOffering == 4 then
			if runningCount > 0 and not SlashCo.CurRound.EscapeHelicopterSummoned then
				--(SPAWN HELICOPTER)

				local failed = SlashCo.SummonEscapeHelicopter()

				if not failed then
					SlashCo.CurRound.DistressBeaconUsed = false
				end
			end
		end

		--Go back to lobby if everyone dies.
		if team.NumPlayers(TEAM_SURVIVOR) <= 0 and SlashCo.CurRound.roundOverToggle then
			SlashCo.EndRound()

			SlashCo.CurRound.roundOverToggle = false
		end

		--Benadryl
		for _, plr in ipairs(player.GetAll()) do
			if plr:Team() ~= TEAM_SURVIVOR then
				if plr:GetNWBool("SurvivorBenadryl") then
					plr:SetNWBool("SurvivorBenadryl", false)
				end

				if plr:GetNWBool("SurvivorBenadrylFull") then
					plr:SetNWBool("SurvivorBenadrylFull", false)
				end
			end
		end
	end
end

hook.Add("PostGamemodeLoaded", "octoSlashCoPostGamemodeLoaded", function()
	timer.Simple(1, function()
		hook.Add("Think", "octoSlashCoCoreThink", Think)
	end)
end)

hook.Add("PlayerInitialSpawn", "octoSlashCoPlayerInitialSpawn", function(ply, _)
	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spawn()

	local pid = ply:SteamID64()
	local data = {}

	--Don't load playerdata if it's already loaded
	if SlashCo.PlayerData[ply:SteamID64()] ~= nil then
		return
	end

	--If the player doesn't have a save file then create one for them.
	if not file.Exists("slashco/playerdata/" .. tostring(ply:SteamID64()) .. ".json", "DATA") then
		local json = '{ "Stats": { "RoundsWon": { "Survivor": 0, "Slasher": 0 }, "Achievements": [] } }'

		print("[SlashCo] No playerdata file found for '" .. ply:GetName() .. "', making one for them.")

		data = util.JSONToTable(json)
		file.Write("slashco/playerdata/" .. tostring(ply:SteamID64()) .. ".json", json)
	else
		data = util.JSONToTable(file.Read("slashco/playerdata/" .. tostring(ply:SteamID64()) .. ".json", "DATA"))
	end

	print("[SlashCo] Loaded playerdata for '" .. ply:GetName() .. "'")

	SlashCo.PlayerData[pid] = {}
	ply.Lives = 1
	--SlashCo.PlayerData[pid].Lives = 1
	SlashCo.PlayerData[pid].RoundsWonSurvivor = data.Stats.RoundsWon.Survivor or 0
	SlashCo.PlayerData[pid].RoundsWonSlasher = data.Stats.RoundsWon.Slasher or 0
	SlashCo.PlayerData[pid].PointsTotal = 0

	hook.Run("LobbyInfoText")

	SlashCoDatabase.OnPlayerJoined(pid)

	SlashCo.AwaitExpectedPlayers()

	SlashCo.BroadcastGlobalData()

	timer.Simple(2, function()
		if IsValid(ply) then
			SlashCo.BroadcastMasterDatabaseForClient(ply)
		end
		SlashCo.BroadcastCurrentRoundData(false)
		SlashCo.BroadcastGlobalData()
	end)
end)

hook.Add("PlayerChangedTeam", "octoSlashCoPlayerChangedTeam", function(ply, old, new)
	if CLIENT then
		return
	end

	local pid = ply:SteamID64()

	SlashCo.BroadcastMasterDatabaseForClient(ply)

	if new == TEAM_SURVIVOR and SlashCo.PlayerData then
		ply.Lives = 1
		--SlashCo.PlayerData[pid].Lives = 1
	end

	if new == TEAM_LOBBY and #team.GetPlayers(TEAM_LOBBY) > 5 then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spawn()
	end

	if old == TEAM_LOBBY then
		lobbyPlayerReadying(ply, 0)
	end

	if old == TEAM_SURVIVOR then
		ply:SetNWBool("DynamicFlashlight", false)
	end

	if game.GetMap() == "sc_lobby" then
		net.Start("mantislashcoGiveLobbyStatus")
		net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE, 3)
		net.Broadcast()
	end
end)

function GM:PlayerDeath(victim)
	if not IsValid(victim) then
		return
	end

	if GAMEMODE.State ~= GAMEMODE.States.IN_GAME or victim:Team() ~= TEAM_SURVIVOR then
		return
	end

	victim:SetNWBool("DynamicFlashlight", false)

	local dontTickLife = victim:ItemFunction("OnDie")
	if dontTickLife then
		return
	end

	SlashCo.DropAllItems(victim)
	--local pid = victim:SteamID64()
	--local lives = SlashCo.PlayerData[pid].Lives
	--SlashCo.PlayerData[pid].Lives = tonumber(lives) - 1
	victim.Lives = victim.Lives or 1
	victim.Lives = victim.Lives - 1

	if victim.Lives <= 0 then
		print("[SlashCo] '" .. victim:GetName() .. "' is out of lives, moving them to the Spectator team.")

		--Spawn the Ragdoll
		local ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetModel(victim:GetModel())
		ragdoll.PingType = "DEAD BODY"
		ragdoll.SurvivorSteamID = victim:SteamID64()

		victim.DeadBody = ragdoll
		if victim.Devastate then
			ragdoll:SetModel("models/player/corpse1.mdl")
		end

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

--Dynamic Flashlight by RiggsMacKay
--https://github.com/RiggsMackay/Dynamic-Flashlight

hook.Add("PlayerSwitchFlashlight", "DynamicFlashlight.Switch", function(ply, state)
	if ply:Team() ~= TEAM_SURVIVOR and not ply:GetNWBool("AmogusSurvivorDisguise") then
		return false
	end

	if state == false then
		return false
	end

	ply:SetNWBool("DynamicFlashlight", not ply:GetNWBool("DynamicFlashlight"))
	if ply:GetNWBool("DynamicFlashlight") then
		ply:EmitSound("slashco/survivor/flashlight-switchoff.wav", 60, 100)
	end
	if not ply:GetNWBool("DynamicFlashlight") then
		ply:EmitSound("slashco/survivor/flashlight-switchon.wav", 60, 100)
	end

	return false
end)

SC_SERVER_LOADED = true

---load patch files; these are specifically intended to modify existing addon code

local shared_patches = file.Find("slashco/patch/shared/*.lua", "LUA")
for _, v in ipairs(shared_patches) do
	AddCSLuaFile("slashco/patch/shared/" .. v)
	include("slashco/patch/shared/" .. v)
end

local server_patches = file.Find("slashco/patch/server/*.lua", "LUA")
for _, v in ipairs(server_patches) do
	include("slashco/patch/server/" .. v)
end

local client_patches = file.Find("slashco/patch/client/*.lua", "LUA")
for _, v in ipairs(client_patches) do
	AddCSLuaFile("slashco/patch/client/" .. v)
end