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
AddCSLuaFile("ui/cl_documents.lua")
AddCSLuaFile("ui/cl_keyboard_ui.lua")
AddCSLuaFile("cl_limitedzone.lua")
AddCSLuaFile("sh_bhop.lua")
AddCSLuaFile("ui/cl_pings.lua")
AddCSLuaFile("sh_roundpoints.lua")
AddCSLuaFile("sh_experience.lua")
AddCSLuaFile("sh_perks.lua")
AddCSLuaFile("sh_canbeseen.lua")
AddCSLuaFile("sh_content.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_fog.lua")
AddCSLuaFile("sh_keyboard.lua")

include("sh_content.lua")
include("sh_shared.lua")
include("sv_globals.lua")
include("sv_spawning.lua")
include("sv_teleporting.lua")
include("items/items_init.lua")
include("slasher/slasher_init.lua")
include("documents/sv_documents.lua")
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
include("sh_bhop.lua")
include("sv_objectives.lua")
include("sh_roundpoints.lua")
include("sh_experience.lua")
include("sh_perks.lua")
include("sh_canbeseen.lua")
include("sh_player.lua")
include("sh_fog.lua")
include("sv_holylib.lua")
include("sv_maptools.lua")
include("sh_keyboard.lua")

--Initialize global variable to hold functions.
SlashCo = SlashCo or {}

--[[

SlashCo Credits:

Coding: Octo, Manti, textstack

Assets: Manti, warman, Darken, Vee

Extra credits: undo, Jim, DarkGrey

]]

--local roundOverToggle = SlashCo.CurRound.roundOverToggle

CreateConVar("slashco_force_difficulty", -1, FCVAR_NONE,
		"Have the gamemode force a certan difficulty. (-1 - random, 0 - EASY, 1 - NOVICE, 2 - INTERMEDIATE, 3 - HARD)", -1, #SlashCo.DifficultyLevel)

hook.Add("CanExitVehicle", "PlayerMotion", function(veh, ply)
	if ply:Team() == TEAM_SURVIVOR then
		return veh.VehicleName ~= "Airboat Seat"
	end
end)

function GM:Initialize()
	resource.AddFile("resource/fonts/ANKLEPAN.tff")
	resource.AddFile("resource/fonts/KILOTON1.tff")
	resource.AddFile("resource/fonts/forcible.tff")
	resource.AddFile("resource/fonts/terminatortwo.tff")
	resource.AddFile("resource/fonts/glare.tff")
	resource.AddFile("resource/fonts/Comic_Papyrus.tff")
	resource.AddFile("resource/fonts/Alternative.tff")
end

hook.Add("AllowPlayerPickup", "PickupNotSpectator", function(ply, ent)
	if ply:Team() == TEAM_SLASHER then
		local override = ply:SlasherFunction("PickUpAttempt", ent)
		if override ~= nil then
			return override
		end

		return false
	end

	return ply:Team() ~= TEAM_SPECTATOR
end)

--lag-compensated eye trace for use in slasher functions
local function lagTrace(ply)
	ply:LagCompensation(true)
	local tr = ply:GetEyeTrace()
	ply:LagCompensation(false)

	return tr.Entity, tr
end

local function lobbyButtons(ply, button)
	local plyTeam = ply:Team()
	if SlashCo.LobbyData.LOBBYSTATE == 0 and plyTeam == TEAM_LOBBY  then
		if SlashCo.IsKeyPressed("READY_SURVIVOR", ply, button) then
			if SlashCo.GetLobbyPlayerReadyState(ply) ~= 1 then
				SlashCo.SetLobbyPlayerReadyState(ply, 1)
				SlashCo.LobbyBroadcastInfo()
			else
				SlashCo.SetLobbyPlayerReadyState(ply, 0)
				SlashCo.LobbyBroadcastInfo()
			end
			local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
			Sndd:Play()
			Sndd:ChangeVolume(0.5, 0)
			Sndd:ChangePitch(100, 0)
		end

		if SlashCo.IsKeyPressed("READY_SLASHER", ply, button) then
			if SlashCo.GetLobbyPlayerReadyState(ply) ~= 2 then
				--Check if the player has made an offering or agreed to one
				--[[if isPlyOfferer(ply) then
					ply:ChatPrint("Cannot ready as Slasher as you have either made or agreed to an Offering.")
					local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
					Sndd:Play()
					Sndd:ChangeVolume(0.5, 0)
					Sndd:ChangePitch(65, 0)
					return
				end]]

				SlashCo.SetLobbyPlayerReadyState(ply, 2)
				SlashCo.LobbyBroadcastInfo()
				local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(100, 0)
			else
				SlashCo.SetLobbyPlayerReadyState(ply, 0)
				SlashCo.LobbyBroadcastInfo()
				local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(100, 0)
			end
		end

		if SlashCo.IsKeyPressed("OFFERING_VOTE", ply, button) and SlashCo.LobbyData.VotedOffering > 0 and not SlashCo.IsLobbyPlyOfferer(ply) then
			SlashCo.OfferingVote(ply, true)
			SlashCo.EndOfferingVote(ply)
		end
	end

	--Switching Teams
	-- NOTE: We check both KEY_COMMA and KEY_R since previously the key was set to be COMMA but was changed to be R.
	if SlashCo.IsKeyPressed("TOGGLE_SPECTATOR", ply, button) and SlashCo.LobbyData.LOBBYSTATE == 0 then
		if plyTeam == TEAM_SPECTATOR then
			if (#team.GetPlayers(TEAM_LOBBY) < GameData.MaxPlayers) then
				ply:SetTeam(TEAM_LOBBY)
				ply:Spawn()
				local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(80, 0)
			else
				ply:ChatPrint("The Lobby is currently full.")
				local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
				Sndd:Play()
				Sndd:ChangeVolume(0.5, 0)
				Sndd:ChangePitch(65, 0)
			end
		elseif plyTeam == TEAM_LOBBY then
			ply:SetTeam(TEAM_SPECTATOR)
			ply:Spawn()
			local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
			Sndd:Play()
			Sndd:ChangeVolume(0.5, 0)
			Sndd:ChangePitch(80, 0)
		end
	end
end

local function spectatorButtons(ply, button)
	if button == MOUSE_LEFT then
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

			if not IsValid(ent) then
				return
			end

			if ent:IsPlayer() then
				if ent:Team() == TEAM_SLASHER and ent:SlasherValue("CannotBeSpectated") then
					return
				end
			elseif not ent.IsSelectable and not ent.SurvivorSteamID then
				return
			end

			ply:SpectateEntity(ent)
			ply:SetObserverMode(OBS_MODE_CHASE)
		end

		return
	end

	if button == MOUSE_RIGHT then
		--Spectator Right Clicks
		if IsValid(ply:GetObserverTarget()) and ply:GetObserverMode() ~= OBS_MODE_ROAMING then
			local ent = ply:GetObserverTarget()
			local targets = SlashCo.GetSpectatableSet()
			for k, v in ipairs(targets) do
				if ply:GetObserverTarget() ~= v then
					continue
				end

				if (k + 1) > #targets then
					ent = targets[1]
				else
					ent = targets[k + 1]
				end
			end

			if IsValid(ent) then
				ply:SpectateEntity(ent)
			end
		else
			local first = SlashCo.GetSpectatableSet()[1]
			if IsValid(first) then
				ply:SpectateEntity(first)
				ply:SetObserverMode(OBS_MODE_CHASE)
			end
		end

		return
	end

	if SlashCo.IsKeyPressed("SPECTATE_PLAYER", ply, button) and IsValid(ply:GetObserverTarget()) then
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
	if button == MOUSE_LEFT then
		ply:SlasherFunction("OnPrimaryFire", lagTrace(ply))
		return
	end --Killing / Damaging

	if button == MOUSE_RIGHT then
		ply:SlasherFunction("OnSecondaryFire", lagTrace(ply))
		return
	end --Activate Chase Mode

	if SlashCo.IsKeyPressed("MAIN_ABILITY", ply, button) then
		ply:SlasherFunction("OnMainAbilityFire", lagTrace(ply))
		return
	end --Main Ability

	if SlashCo.IsKeyPressed("SPECIAL_ABILITY", ply, button) then
		ply:SlasherFunction("OnSpecialAbilityFire", lagTrace(ply))
		return
	end --Special
end

function SlashCo.GetSpectatableSet()
	local targets = team.GetPlayers(TEAM_SURVIVOR)
	table.Add(targets, SlashCo.DeadBodies)

	for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		if not v:SlasherValue("CannotBeSpectated") then
			table.insert(targets, v)
		end
	end

	return targets
end

function GM:PlayerButtonDown(ply, button)
	if GameData.IsLobby then
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
	if (attacker:IsPlayer() or attacker:IsNPC()) and attacker:Team() == ply:Team() then
		return false
	end

	return ply:Team() == TEAM_SURVIVOR
end

hook.Add("OnPlayerChangedTeam", "SlashCo:OnPlayerChangedTeam", function(ply, oldTeam, newTeam)
	-- Here's an immediate respawn thing by default. If you want to
	-- re-create something more like CS or some shit you could probably
	-- change to a spectator or something while dead.
	if newTeam == TEAM_SPECTATOR then
		-- If we changed to spectator mode, respawn where we are
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos(Pos)
	elseif oldTeam == TEAM_SPECTATOR then
		-- If we're changing from spectator, join the game
		ply:Spawn()
	end

	if g_SlashCoDebug then
		PrintMessage(HUD_PRINTTALK, Format("%s joined '%s'", ply:Nick(), team.GetName(newTeam)))
	end

	--Ready Message
	SlashCo.BroadcastGlobalData()
end)

--[[
	ToDo

	We use PlayerChangedTeam here because OnPlayerChangedTeam is deprecated.
	BUT the issue with PlayerChangedTeam is that we might be calling Player:SetTeam when we call ply:Spawn so we could enter a infinite loop.
	Additionally as mentioned, PlayerChangedTeam is called when Player:SetTeam is used, and the logic might not like that.
]]
hook.Add("PlayerChangedTeam", "SlashCo:PlayerChangedTeam", function(ply, oldTeam, newTeam)
	if newTeam == TEAM_SURVIVOR then
		ply.WasSurvivor = true -- At some point this player was a survivor.
	end
end)

hook.Add("InitPostEntity", "SlashCo:InitPostEntity", function()
	print("[SlashCo] InitPostEntity Started.")
	RunConsoleCommand("sv_alltalk", "2")
	RunConsoleCommand("sv_noclipspeed", "2")

	if not GameData.IsLobby then
		SlashCo.State = SlashCo.States.STARTING

		SlashCo.LoadCurRoundData()
		SlashCo.CurRound.GameProgress = -1
	end
end)

local function Think()
	if engine.TickCount() % math.floor(5 / engine.TickInterval()) == 0 then
		for _, p in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			local health = p:Health()
			if health > 100 then
				p:SetHealth(health - 1)
			end
		end
	end

	if SlashCo.CurRound.GameProgress == -1 then
		for _, v in ipairs(team.GetPlayers(TEAM_SPECTATOR)) do
			if SlashCo.CurRound.Slashers[v:SteamID64()] and v:GetNWString("Slasher") ~= SlashCo.CurRound.Slashers[v:SteamID64()].SlasherID then
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
	if SlashCo.CurRound and SlashCo.State == SlashCo.States.IN_GAME and #gens > 0 then
		local runningCount = 0
		for _, v in ipairs(gens) do
			if v.IsRunning then
				runningCount = runningCount + 1
			end
		end

		--//drainage//--
		if SlashCo.CurRound.OfferingData.CurrentOffering == SCInfo.Offering.Drainage then
			local totalCansRemaining = 0
			local gasPerGen = SlashCo.GetGasCansPerGenerator()
			for _, v in ipairs(gens) do
				totalCansRemaining = totalCansRemaining + (v.CansRemaining or gasPerGen)
			end

			if #gens <= totalCansRemaining then
				return
			end --Prevent draining if there is too few gas cans

			if engine.TickCount() % math.floor(240 / engine.TickInterval()) == 0 then
				local random = math.random(#gens)
				gens[random]:ChangeCanProgress(-1)
				--gens[random].CansRemaining = math.Clamp((gens[random].CansRemaining or gasPerGen) + 1, 0, gasPerGen)
			end
		end

		--//helicopters//--
		local allRunning = runningCount >= SlashCo.GetGeneratorsNeeded()
		if allRunning and not SlashCo.CurRound.EscapeHelicopterSummoned then
			--(SPAWN HELICOPTER)

			local failed = SlashCo.SummonEscapeHelicopter()
			if not failed then
				local settingsEnt = SlashCo.SettingsEntity()
				if settingsEnt then
					settingsEnt:TriggerOutput("OnAllGeneratorsComplete", settingsEnt)
				end

				SlashCo.CurRound.DistressBeaconUsed = false
			end
		end

		-- having two slashers its not that big of a deal, specially if there's like 14 survivors
		-- one generator can be speedrunned instanly in most maps

		--//duality condition//--
		--[[if SlashCo.CurRound.OfferingData.CurrentOffering == SCInfo.Offering.Duality and runningCount > 0 and not SlashCo.CurRound.EscapeHelicopterSummoned then
			--(SPAWN HELICOPTER)

			local failed = SlashCo.SummonEscapeHelicopter()

			if not failed then
				local settingsEnt = SlashCo.SettingsEntity()
				if settingsEnt then
					settingsEnt:TriggerOutput("OnAllGeneratorsComplete", settingsEnt)
				end

				SlashCo.CurRound.DistressBeaconUsed = false
			end
		end]]

		--Go back to lobby if everyone dies.
		if team.NumPlayers(TEAM_SURVIVOR) <= 0 and SlashCo.CurRound.roundOverToggle then
			SlashCo.EndRound()

			SlashCo.CurRound.roundOverToggle = false
		end
	end
end

hook.Add("PostGamemodeLoaded", "SlashCo:PostGamemodeLoaded", function()
	timer.Simple(1, function()
		hook.Add("Think", "SlashCo:CoreThink", Think)
	end)
end)

hook.Add("PlayerInitialSpawn", "SlashCo:PlayerInitialSpawn", function(ply)
	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spawn()

	hook.Run("LobbyInfoText")

	SlashCoDatabase.OnPlayerJoined(ply:SteamID64())
	SlashCo.LoadPlayerFromDatabase(ply)

	SlashCo.AwaitExpectedPlayers()
	SlashCo.BroadcastGlobalData(ply)
	
	if SlashCo.CurRound then
		SlashCo.CurRound.DisconnectedPlayers[ply:SteamID64()] = nil -- cleanup :^
	end

	timer.Simple(2, function()
		SlashCo.BroadcastCurrentRoundData(false)

		if not IsValid(ply) then return end
		if GameData.IsLobby or not SlashCo.RoundStarted or SlashCo.GetRoundTime() > SlashCo.MaximumLateJoinTime then return end
		local steamID = ply:SteamID64()
		for _, data in ipairs(SlashCo.CurRound.ExpectedPlayers) do
			if data.steamid ~= steamID then continue end
					
			ply:SetTeam(TEAM_SURVIVOR)
			ply:Spawn()

			if not GameData.SurvivorData then break end
					
			local itemEntry = GameData.SurvivorData[steamID]
			if not itemEntry then break end

			SlashCo.DropAllItems(ply)
			SlashCo.ChangeSurvivorItem(ply, "item", itemEntry.Item, true)
			SlashCo.ChangeSurvivorItem(ply, "item2", itemEntry.Item2, true)
		end
	end)
end)

hook.Add("PlayerChangedTeam", "SlashCo:PlayerChangedTeam", function(ply, old, new)
	if CLIENT then
		return
	end

	SlashCo.LoadPlayerFromDatabase(ply)

	if new == TEAM_SURVIVOR then
		ply.Lives = 1
	end

	if new == TEAM_LOBBY and team.NumPlayers(TEAM_LOBBY) > 5 then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spawn()
	end

	if old == TEAM_LOBBY then
		SlashCo.SetLobbyPlayerReadyState(ply, 0)
	end

	if old == TEAM_SURVIVOR then
		ply:SetNW2Bool("DynamicFlashlight", false)
	end

	if GameData.IsLobby then
		net.Start("SlashCo:GiveLobbyStatus")
			net.WriteUInt(SlashCo.LobbyData.LOBBYSTATE, 3)
		net.Broadcast()
	end
end)

SlashCo.DeadBodies = SlashCo.DeadBodies or {}

function GM:PlayerDeath(victim)
	if not IsValid(victim) then
		return
	end

	if SlashCo.State ~= SlashCo.States.IN_GAME or victim:Team() ~= TEAM_SURVIVOR then
		return
	end

	victim:SetNW2Bool("DynamicFlashlight", false)

	local dontTickLife = victim:ItemFunction("OnDie")
	if dontTickLife then
		return
	end

	SlashCo.DropAllItems(victim)
	victim.Lives = victim.Lives or 1
	victim.Lives = victim.Lives - 1

	if victim.Lives <= 0 then
		print("[SlashCo] '" .. victim:GetName() .. "' is out of lives, moving them to the Spectator team.")

		--Spawn the Ragdoll
		local ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetModel(victim:GetModel())
		ragdoll.PingType = "DEAD BODY"
		ragdoll.SurvivorSteamID = victim:SteamID64()
		ragdoll:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

		victim.DeadBody = ragdoll
		if victim.Devastate then
			ragdoll:SetModel("models/player/corpse1.mdl")
		end

		ragdoll:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		ragdoll:SetPos(victim:GetPos())
		ragdoll:SetNoDraw(false)
		ragdoll:Spawn()
		ragdoll:Activate()

		local vel = victim:GetVelocity()
		for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			local phys = ragdoll:GetPhysicsObjectNum(i)
			if not IsValid(phys) then continue end

			local boneid = ragdoll:TranslatePhysBoneToBone(i)
			if boneid < 0 then continue end

			local matrix = victim:GetBoneMatrix(boneid)
			if not matrix then continue end

			phys:SetPos(matrix:GetTranslation())
			phys:SetAngles(matrix:GetAngles())
			phys:AddVelocity(vel)
		end

		table.insert(SlashCo.DeadBodies, ragdoll)

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

		if team.NumPlayers(TEAM_SURVIVOR) == 1 and #SlashCo.CurRound.SlasherData.AllSurvivors > 1 then
			team.GetPlayers(TEAM_SURVIVOR)[1]:SetRoundPoints("last_survive")
		end

		victim:SetTeam(TEAM_SPECTATOR)
		timer.Simple(0, function()
			if IsValid(victim) and IsValid(ragdoll) then
				victim:Spawn()
				victim:SetPos(ragdoll:GetPos())
				victim:SpectateEntity(ragdoll)
				victim:SetObserverMode(OBS_MODE_CHASE)
			end
		end)
	end
end

function GM:PlayerSpray(ply)
	if ply:Team() == TEAM_SPECTATOR then
		return true
	end
end

function GM:EntityTakeDamage(target, dmg)
	if target:IsPlayer() then
		local result = target:ItemFunction("OnOwnerTakeDamage", dmg)
		if result != nil then
			return result
		end
	end
end

--Dynamic Flashlight by RiggsMacKay
--https://github.com/RiggsMackay/Dynamic-Flashlight

hook.Add("PlayerSwitchFlashlight", "DynamicFlashlight.Switch", function(ply, state)
	if ply:Team() ~= TEAM_SURVIVOR and not ply:GetNWBool("AmogusSurvivorDisguise") then
		if not (GameData.IsLobby and GameData.IsBlackout) then
			return false
		end
	end

	if state == false then
		return false
	end

	ply:SetNW2Bool("DynamicFlashlight", not ply:GetNW2Bool("DynamicFlashlight"))
	if ply:GetNW2Bool("DynamicFlashlight") then
		ply:EmitSound("slashco/survivor/flashlight-switchoff.mp3", 60, 100)
	end

	if not ply:GetNW2Bool("DynamicFlashlight") then
		ply:EmitSound("slashco/survivor/flashlight-switchon.mp3", 60, 100)
	end

	return false
end)

util.AddNetworkString("SlashCo:FlashWindows")
function SlashCo.FlashWindows(players)
	net.Start("SlashCo:FlashWindows")

	if players then
		net.Send(players)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerButtonDown", "SlashCo:SpectatorFunctions", function(ply, button)
	if ply:Team() ~= TEAM_SPECTATOR then return end
	if not SlashCo.CanSpectatorsPing() then return end
	if button ~= MOUSE_MIDDLE then return end
	if ply.LastPinged and (CurTime() - ply.LastPinged) < SlashCo.GetPlayerPingDelay() then return end

	ply:SurvivorPing()
end)

util.AddNetworkString("SlashCo:UpdateLightMap")
function SlashCo.SetLightStyle(lightStyle, lightPattern)
	engine.LightStyle(lightStyle, lightPattern)

	net.Start("SlashCo:UpdateLightMap")
	net.Broadcast()
end

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