local PLAYER = FindMetaTable("Player")

hook.Add("EntityNetworkedVarChanged", "SlashCo:Impervious", function(ent, name, _, new)
	if name ~= "IsImpervious" then return end

	ent.IsImpervious = new
	ent:SetCustomCollisionCheck(new or false)
	ent:CollisionRulesChanged()
end)

hook.Add("ShouldCollide", "SlashCo:Impervious", function(ent1, ent2)
	if not ent1.IsImpervious and not ent2.IsImpervious then
		return
	end

	if (ent1:IsPlayer() or SlashCo.IsValidDoor(ent1)) and (ent2:IsPlayer() or SlashCo.IsValidDoor(ent2)) then
		--i would put a check for if doors were locked here but the locked state of doors could change
		--see the warning in https://wiki.facepunch.com/gmod/GM:ShouldCollide to see why this matters
		return false
	end

	if (ent1:IsPlayer() or ent1:GetClass() == "prop_static") and (ent2:IsPlayer() or ent2:GetClass() == "prop_static") then
		return false
	end
end)

function PLAYER:SetImpervious(state)
	if state then
		if self.IsImpervious then
			return
		end

		self:SetCustomCollisionCheck(true)
		self:SetNW2Bool("IsImpervious", true)

		local userid = self:UserID()
	else
		if not self.IsImpervious then
			return
		end

		self:SetCustomCollisionCheck(false)
		self:SetNW2Bool("IsImpervious", false)
	end
end

--[[
	Nevermind, we do need it.
	Without hands items that are held are not rendered.
	
function PLAYER:SetupHands(spec_ply)
	-- Nothing. We don't need gmod_hands
end]]

hook.Add("PlayerDeath", "SlashCo:RemoveImpervious", function(victim)
	victim:SetImpervious(false)
end)

function GM:PlayerSpawnAsSpectator(ply)
	ply:StripWeapons()

	if ply:Team() == TEAM_UNASSIGNED then
		ply:Spectate(OBS_MODE_FIXED)
		return
	end

	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetMoveType(MOVETYPE_NOCLIP) -- Solves prediction issues as MOVETYPE_OBSERVER doesn't predict well
end

hook.Add("PlayerNoClip", "SlashCo:PreventSpectators", function(ply)
	if g_SlashCoDebug then
		return ply:Team() ~= TEAM_SPECTATOR
	end

	-- RaphaelIT7: If map tools are enabled, the server host is always allowed to noclip to make things easier.
	if ply:IsListenServerHost() and SlashCo.MapTools.IsEnabled(true) then
		return true
	end
	
	if ply:Team() ~= TEAM_SLASHER then
		return false
	end
end)

-- "Outfitter" addon can add/modify slashers which we preferably do not want
-- See https://github.com/Mantibro/SlashCo/pull/81
hook.Add("CanOutfit", "SlashCo:NoSlasherOutfits", function(ply)
	if IsValid(ply) and ply:Team() == TEAM_SLASHER then
		return false
	end
end)

-- This function is VERY expensive, BUT it shouldn't be called too frequent anyways.
function PLAYER:FindPlayersInView(dist, radius, notrace)
	local areWeSlasher = self:Team() == TEAM_SLASHER
	if areWeSlasher and not self:GetCanSeePlayers() then
		return {}
	end

	local pos = self:EyePos()
	local foundEnts = ents.FindInCone(pos, self:GetAimVector(), dist, radius)
	local results = {}
	for _, ent in ipairs(foundEnts) do
		if ent:IsPlayer() and ent:Team() == TEAM_SURVIVOR and ent:CanBeSeen(not areWeSlasher) then
			if not notrace then
				local tr = util.TraceLine({
					start = pos,
					endpos = ent:EyePos(),
					filter = self,
					mask = MASK_OPAQUE_AND_NPCS, -- It's not just and NPCs, it's and ANY entity.
				})

				if tr.Entity != ent then continue end -- Player is not fully visible.
			end

			table.insert(results, ent)
		end
	end

	if areWeSlasher then
		for idx = #results, 1, -1 do
			if self:SlasherFunction("Visibility", results[idx]) == 0 then
				table.remove(results, idx)
			end
		end
	end

	return results
end

function PLAYER:IsStuck(worldOnly)
	if self:Team() == TEAM_SPECTATOR or self:GetMoveType() == MOVETYPE_NOCLIP then
		return false
	end

	local settings = {
		start = self:GetPos(),
		endpos = self:GetPos(),
		filter = self,
		mask = MASK_PLAYERSOLID,
		collisiongroup = COLLISION_GROUP_PLAYER,
	}

	if worldOnly then
		settings.collisiongroup = COLLISION_GROUP_WORLD
		settings.mask = COLLISION_GROUP_NONE
	end

	local tr = util.TraceEntityHull(settings, self)
	return tr.Hit
end

function PLAYER:PlayDamageSound(additionalRange)
	additionalRange = additionalRange or 0

	local rng = math.random(1, 4)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/damage" .. rng .. ".mp3",
		identifier = "TakeDamage" .. rng,
		minDistance = 200 + additionalRange,
		maxDistance = 400 + additionalRange,
		entity = self,
		volume = 0.8,
		fadeIn = 0,
	})
end

-- Currently we use target:EmitSound("slashco/slasher/trollge/trollge_hit.mp3") in a lot of places, this funcion should take it's place.
function PLAYER:TakeDamageWithEffect(damageAmount, attacker, inflictor)
	local additionalRange = math.Clamp(damageAmount, 0, self:Health()) * 2

	self:PlayDamageSound(additionalRange)
	self:TakeDamage(damageAmount, attacker, inflictor)
end

function SlashCo.FindPlayersInRange(origin, range, specificTeam, ignoreEntity)
	local results = {}
	for _, ply in ipairs(specificTeam and team.GetPlayers(specificTeam) or player.GetAll()) do
		if ply:EyePos():Distance(origin) > range then
			continue
		end

		local tr = util.TraceLine({
			start = origin,
			endpos = ply:WorldSpaceCenter(),
			filter = ignoreEntity
		})

		if tr.Entity == ply then
			table.insert(results, ply)
		end
	end

	return results
end

--[[
	Using sv_lan we can use -multirun and join the game with multiple gmod instances,
	but now we have to ensure that they won't use the same steamid's.

	This should probably be made into a gmod request.

	Right now we change these function and we add the userid to allow for multiple multirun instances to work without colliding with each other.
	- PLAYER:SteamID()
	- PLAYER:SteamID64()
	- PLAYER:OwnerSteamID64()
	- PLAYER:UniqueID()
]]
function SlashCo.SetupLanOverrides() -- Called from sh_shared.lua -> GM:InitPostEntity
	PLAYER.OrigSteamID = PLAYER.OrigSteamID or PLAYER.SteamID
	function PLAYER:SteamID()
		local steamID = self:OrigSteamID()
		if steamID == "STEAM_ID_LAN" then
			return "STEAM_ID_LAN_" .. self:UserID()
		end

		return steamID
	end

	PLAYER.OrigSteamID64 = PLAYER.OrigSteamID64 or PLAYER.SteamID64
	function PLAYER:SteamID64()
		local steamID = self:OrigSteamID64()
		if steamID == "0" then
			return tostring(self:UserID())
		end

		return steamID
	end

	PLAYER.OrigOwnerSteamID64 = PLAYER.OrigOwnerSteamID64 or PLAYER.OwnerSteamID64
	function PLAYER:OwnerSteamID64()
		local steamID = self:OrigOwnerSteamID64()
		if steamID == "0" then
			return tostring(self:UserID())
		end

		return steamID
	end

	PLAYER.OrigUniqueID = PLAYER.OrigUniqueID or PLAYER.UniqueID
	function PLAYER:UniqueID()
		if self:OrigSteamID64() == 0 then
			return util.CRC("gm_" .. self:UserID() .. "_gm") -- This is how gmod does it internally.
		end

		return self:OrigUniqueID()
	end
end

function PLAYER:CanPing()
	if self:Team() == TEAM_SPECTATOR and not SlashCo.CanSpectatorsPing() then
		return false
	end

	local ucmd = self:GetCurrentCommand() -- CUserCmd has no IsValid method (IsValid() would always be false), it returns nothing outside of a command
	if not ucmd then return false end

	-- RaphaelIT7: It's important to know that engine.TickCount() on the server would differ from the client!
	-- But since PlayerButtonDown is called when the usercmd was received we can easily match up
	local tickCount = ucmd:TickCount() - self:GetLastPinged()
	return (tickCount * engine.TickInterval()) > SlashCo.GetPlayerPingDelay()
end

local function sayPrompt(ply, input)
	if GameData.IsLobby and SlashCo.LobbyData.LOBBYSTATE == 2 then
		return
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/voice/prompt_" .. input .. math.random(1, 3) .. ".mp3",
		identifier = "Ping",
		minDistance = 200,
		maxDistance = 500,
		entity = ply,
		volume = 1,
		fadeIn = 0,
		deleteWhenDone = true, -- RaphaelIT7: Must be explicitly set since this code runs clientside where deleteWhenDone is NOT default true!
		excludeSendTo = ply, -- RaphaelIT7: We don't send it to the player itself since the sound is played clientside thanks to prediction!
	})
end

local typeCheck = {
	["LOOK HERE"] = "look",
	["LOOK AT THIS"] = "look",
	["HELICOPTER"] = "helicopter",
	["GENERATOR"] = "generator",
	["PLUSH DOG"] = "dogg",
	["BASKETBALL"] = "ballin",
	["DEAD BODY"] = "deadbody",
	["SLASHER"] = "slasher"
}

function PLAYER:SurvivorPing()
	if not self:CanPing() then return end

	local ucmd = self:GetCurrentCommand()
	if not ucmd then return end

	-- RaphaelIT7: Same as in PLAYER:CanPing()
	local tickCount = ucmd:TickCount()
	self:SetLastPinged(tickCount)

	-- We return here since prediction must set SetLastPinged
	if CLIENT and not IsFirstTimePredicted() then return end

	self:LagCompensation(true)
	local trace = self:GetEyeTrace()
	self:LagCompensation(false)

	local pingInfo = {
		ExpiryTime = 0, -- Time in seconds!
		Team = self:Team(), -- Idea: Allow slasher's to ping too
		Player = self,
	}

	if pingInfo.Team == TEAM_SPECTATOR then
		pingInfo.Type = "GHOST"
		pingInfo.Position = trace.HitPos
		pingInfo.ExpiryTime = 5
		pingInfo.Player = nil
	elseif not IsValid(trace.Entity) then
		pingInfo.Position = trace.HitPos
		pingInfo.Type = "LOOK HERE"
		pingInfo.ExpiryTime = 10
	else
		local look = trace.Entity
		if look.PingType then
			pingInfo.Entity = look
			pingInfo.Type = look.PingType
			if look.PingExpiryTime then
				pingInfo.ExpiryTime = look.PingExpiryTime
			end

			if look:GetClass() == "sc_maleclone" then
				pingInfo.Position = trace.HitPos
			end

			if look.OnPing then
				-- RaphaelIT7: ToDo (Idea) - we can give a reward to the first survivor who found a generator
				look:OnPing(self)
			end
		elseif look:GetModel() == "models/ldi/basketball.mdl" then
			pingInfo.Type = "BASKETBALL"
			pingInfo.ExpiryTime = 15
		elseif look:IsPlayer() then
			pingInfo.Position = trace.HitPos
			pingInfo.ExpiryTime = 5
			if look:Team() == TEAM_SURVIVOR then
				pingInfo.Type = "SURVIVOR"
				pingInfo.Name = string.upper(look:Nick())
			elseif look:Team() == TEAM_SLASHER then
				local survivors = team.GetPlayers(TEAM_SURVIVOR)
				local disguiseSurvivor = look:GetAmogusSurvivorDisguise() and survivors[1] and survivors[math.random(#survivors)]
				if not IsValid(disguiseSurvivor) then
					pingInfo.Type = "SLASHER"
				else
					pingInfo.Type = "SURVIVOR"
					pingInfo.Name = string.upper(disguiseSurvivor:Nick())
				end
			else
				pingInfo.Type = "PLAYER"
				pingInfo.Position = trace.HitPos
				pingInfo.Name = string.upper(look:Nick())
			end
		else
			pingInfo.Type = "LOOK AT THIS"
			pingInfo.ExpiryTime = 10
		end
	end

	if pingInfo.ExpiryTime and pingInfo.ExpiryTime == -1 then
		pingInfo.ExpiryTime = nil
		pingInfo.Permanent = true -- Permanent pings always remain!
	end

	if pingInfo.Type == "DEAD BODY" and pingInfo.Entity then
		local deadguy = player.GetBySteamID64(pingInfo.Entity.SurvivorSteamID)
		if IsValid(deadguy) then
			-- RaphaelIT7: NW on purpose as dead players are spectators and may no longer be networked to survivors!
			deadguy:SetNWBool("ConfirmedDead", true)
		end
	end

	if pingInfo.ExpiryTime then
		if pingInfo.ExpiryTime ~= 0 then
			pingInfo.ExpiryTime = CurTime() + pingInfo.ExpiryTime
		else
			pingInfo.ExpiryTime = nil
		end
	end

	local skipSound = hook.Run("SlashCo:OnPing", pingInfo)
	if not skipSound and pingInfo.Team == TEAM_SURVIVOR then
		if typeCheck[pingInfo.Type] then
			sayPrompt(self, typeCheck[pingInfo.Type])
		elseif pingInfo.Type == "ITEM" and pingInfo.Entity then
			local class = pingInfo.Entity:GetClass()
			for _, v in pairs(SlashCoItems) do
				local input = v.EntClass
				if not input then
					continue
				end

				if v.EntClass == class then
					sayPrompt(self, string.sub(input, 4))
					pingInfo.Name = v.Name
					break
				end
			end
		end
	end

	if CLIENT then
		-- RaphaelIT7: Just in case when some workshop addon messes up...
		if self ~= GameData.LocalPlayer then return end

		SlashCo.CreatePredictedPing(pingInfo, tickCount)
	else
		self:SurvivorPing_SV(pingInfo, tickCount)
	end
end

hook.Add("SlashCo:PlayerSwitchFlashlight", "SlashCo:DynamicFlashlight", function(ply, state)
	if ply:Team() ~= TEAM_SURVIVOR and not ply:GetAmogusSurvivorDisguise() then
		if not (GameData.IsLobby and GameData.IsBlackout) then
			return false
		end
	end

	local state = not ply:GetDynamicFlashlight()
	ply:SetDynamicFlashlight(state)
	
	-- Else we sound spam, but prediction expects SetDynamicFlashlight to be called consistenly!
	if CLIENT and not IsFirstTimePredicted() then
		return
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = state and "slashco/survivor/flashlight-switchoff.mp3" or "slashco/survivor/flashlight-switchon.mp3",
		identifier = "Flashlight",
		minDistance = 200,
		maxDistance = 500,
		entity = ply,
		volume = 1,
		fadeIn = 0,
		deleteWhenDone = true, -- RaphaelIT7: Must be explicitly set since this code runs clientside where deleteWhenDone is NOT default true!
		excludeSendTo = ply, -- RaphaelIT7: We don't send it to the player itself since the sound is played clientside thanks to prediction!
	})

	return false
end)

SlashCo.Taunt = {
	None = 0,
	MNR = 1,
	Griddy = 2,
	Cali = 3,
}

local TAUNT_DELAY = 2
local tauntKeys = {
	TAUNT_MN = SlashCo.Taunt.MNR,
	TAUNT_HTG = SlashCo.Taunt.Griddy,
	TAUNT_CG = SlashCo.Taunt.Cali,
}

function PLAYER:SurvivorTaunt(newTaunt)
	local ucmd = self:GetCurrentCommand()
	if not ucmd then return end

	local tickCount = ucmd:TickCount()
	if (tickCount - self:GetLastTaunted()) * engine.TickInterval() < TAUNT_DELAY then return end

	self:SetLastTaunted(tickCount)
	self:SetTaunt(newTaunt)

	if CLIENT and not IsFirstTimePredicted() then return end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/ping_item.mp3",
		identifier = "Taunt",
		entity = 0, -- Play as Mono
		playbackRate = 0.8,
		volume = 0.4,
		fadeIn = 0,
		deleteWhenDone = true,
		excludeSendTo = self,
	})
end

hook.Add("PlayerButtonDown", "SlashCo:SurvivorTaunts", function(ply, button)
	local team = ply:Team()
	if team ~= TEAM_SURVIVOR and team ~= TEAM_LOBBY then return end

	local taunt = ply:GetTaunt()
	if taunt ~= SlashCo.Taunt.None and (taunt == SlashCo.Taunt.MNR or button ~= KEY_W) then
		ply:SetTaunt(SlashCo.Taunt.None)
	end

	for key, newTaunt in pairs(tauntKeys) do
		if SlashCo.IsKeyPressed(key, ply, button) then
			ply:SurvivorTaunt(newTaunt)
			return
		end
	end
end)

--[[
	DTVar Networking

	UPDATE:
	NW2 is basically fine on players BUT it is broken on entities!
	DTVars are more efficient than NW2

	Unlike the whole SetupDataTables shit, our function exist in the metatable and are always available.
	So we don't have to worry about shit like Player:SetSlasher not existing for like 1 tick until SetupDataTables was called
]]

SlashCo_DTNetworking = SlashCo_DTNetworking or {}
local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

local defaultFallbacks = {
	["Int"] = 0,
	["Float"] = 0,
	["String"] = "",
	["Entity"] = NULL,
	["Bool"] = false,
	["Vector"] = Vector(0, 0, 0),
	["Angle"] = Angle(0, 0, 0),
}

local function SetupSlashCoNetworkVar(type, index, name, default, owner)
	if not SlashCo_DTNetworking[type] then
		SlashCo_DTNetworking[type] = {}
	end

	local SetDTFunc = entMeta["SetDT" .. type]
	local defaultFallback = defaultFallbacks[type]
	-- RaphaelIT7: We cannot do "default ~= nil and default or defaultFallbacks[type]" above since if default is false then it would false use the fallback!
	if default ~= nil then
		defaultFallback = default
	end

	plyMeta["Set" .. name] = function(self, value)
		if value == nil then
			value = defaultFallback
		end

		SetDTFunc(self, index, value)
	end

	local GetDTFunc = entMeta["GetDT" .. type]
	plyMeta["Get" .. name] = function(self, fallback)
		local value = GetDTFunc(self, index)
		-- RaphaelIT7: This is so ugly because of the sam reason as above! false is such a weird case to work with
		if value == nil then
			if fallback ~= nil then
				value = fallback
			else
				value = defaultFallback
			end
		end

		return value
	end

	SlashCo_DTNetworking[type][index] = name
	SlashCo_DTNetworking[name] = {
		callbackName = type .. "_" .. index,
		type = type,
		index = index,
		owner = owner,
		get = plyMeta["Get" .. name],
		set = plyMeta["Set" .. name],
	}

	return plyMeta["Get" .. name], plyMeta["Set" .. name]
end
SlashCo.SetupNetworkVar = SetupSlashCoNetworkVar

-- Up to 31 booleans share one Int slot, bit 31 stays unused since the Int is signed
local function SetupSlashCoNetworkFlag(index, shift, name, default, owner)
	local mask = bit.lshift(1, shift)
	local inverse = bit.bnot(mask)
	local getInt = entMeta.GetDTInt
	local setInt = entMeta.SetDTInt
	local defaultState = default or false

	local function get(self)
		return bit.band(getInt(self, index) or 0, mask) ~= 0
	end

	local function set(self, state)
		if state == nil then
			state = defaultState
		end

		local flags = getInt(self, index) or 0
		local newFlags = state and bit.bor(flags, mask) or bit.band(flags, inverse)
		if newFlags ~= flags then
			setInt(self, index, newFlags)
		end
	end

	plyMeta["Get" .. name] = get
	plyMeta["Set" .. name] = set
	SlashCo_DTNetworking[name] = {
		type = "Flag",
		index = index,
		shift = shift,
		owner = owner,
		get = get,
		set = set,
	}

	return get, set
end
SlashCo.SetupNetworkFlag = SetupSlashCoNetworkFlag

-- Reads a registered data table var by its name
function SlashCo.GetNetworkVar(ply, name, fallback, nwType)
	local info = SlashCo_DTNetworking[name]
	if info then
		return info.get(ply)
	end

	return ply["GetNW2" .. nwType](ply, name, fallback)
end

-- RaphaelIT7: I am like 99% that me moving to NW2 will break workshop addons
-- So preferably, let's try to keep them functional for now
entMeta.OrigGetNWString = entMeta.OrigGetNWString or entMeta.GetNWString
local getNWString = entMeta.OrigGetNWString
function plyMeta:GetNWString(key, ...)
	if key ~= "Slasher" then
		return getNWString(self, key, ...)
	end

	if not GameData.warnedSlasherNWUse then
		GameData.warnedSlasherNWUse = true
		ErrorNoHalt("[SlashCo] Player:GetNWString(\"Slasher\") is deprecated, use Player:GetNW2String(\"Slasher\") instead!\n")
	end

	return self:GetNW2String(key, ...)
end

-- RaphaelIT7: There intentionally is no callback function due to the nature of DTs being possibly received more than once! If you really need it tell me - I got that code already done

SetupSlashCoNetworkVar("Int", 0, "Experience")
SetupSlashCoNetworkVar("Int", 1, "Points")
SetupSlashCoNetworkVar("Int", 2, "SurvivorRoundsWon")
SetupSlashCoNetworkVar("Int", 3, "SlasherRoundsWon")
SetupSlashCoNetworkVar("Int", 4, "Perception")
SetupSlashCoNetworkVar("Int", 5, "LastPinged") -- RaphaelIT7: The last tick in which they pinged (Ticks should be less of a mess than CurTime)
SetupSlashCoNetworkVar("Int", 6, "Items")
-- Int 7 holds the flags below
SetupSlashCoNetworkVar("Int", 8, "SurvivorJumpscare") -- The ID of the slasher currently jumpscaring them
SetupSlashCoNetworkVar("Int", 9, "Taunt")
SetupSlashCoNetworkVar("Int", 15, "LastTaunted") -- The last tick in which they taunted, same idea as LastPinged
SetupSlashCoNetworkVar("Int", 11, "ZoneEffect") -- The effect of the limited zone the player is inside of, 0 if none
SetupSlashCoNetworkVar("Int", 12, "KeyedSpeed") -- The strongest speed effect only the server knows about (zone, attacks, ...), see PLAYER:AddSpeedEffect

-- RaphaelIT7: IMPORTANT!
-- Avoid storing CurTime inside a float!
-- This is since CurTime is a double, not float, so you'd always encounter prediction errors!
-- Prefer to store a tick count when working with prediction or you'll have a bad time...

SetupSlashCoNetworkVar("Float", 0, "EyeSight")
SetupSlashCoNetworkVar("Float", 1, "DeafenTime")
SetupSlashCoNetworkVar("Float", 2, "DeathUITime")
SetupSlashCoNetworkVar("Float", 3, "TeslaStunned")
SetupSlashCoNetworkVar("Float", 4, "LastTeslaStun")
SetupSlashCoNetworkVar("Float", 5, "LookingAtHatMan")
SetupSlashCoNetworkVar("Float", 6, "InitialBenadrylTime")
SetupSlashCoNetworkVar("Float", 7, "SlasherAnger")

-- RaphaelIT7: We only support up to 32 flags here before we need to use a second int
-- Doing it this way keeps all the Bool slots free for Slashers
local coreFlags = {
	"InSlasherChaseMode",
	"CanChase",
	"CanKill",
	"SlasherBlinded",
	"NoFootsteps",
	"DemonPacified",
	"SurvivorBeingJumpscared",
	"SurvivorTackled",
	"SurvivorGrabbed",
	"SurvivorDragged",
	"SurvivorSidExecution",
	"SurvivorMining",
	"SurvivorFueled",
	"SurvivorBalkanFull",
	"SurvivorAlert",
	"SurvivorWatcherSurveyed",
	"MarkedBySmiley",
	"MarkedByCloaks",
	"NightVision",
	"CurseOfTheJug",
	"JugCurseActivate",
	"AmogusSurvivorDisguise",
	"ShowDeathUI",
	"DeathWardUI",
	"DeathReviveUI",
	"MerltonBlur",
	"OrangeBlur",
	"SurvivorBalkan",
	"BenadrylHidden",
}

for shift, name in ipairs(coreFlags) do
	SetupSlashCoNetworkFlag(7, shift - 1, name)
end

SetupSlashCoNetworkVar("Bool", 0, "CanSeePlayers")
SetupSlashCoNetworkVar("Bool", 1, "WasSeenBySlasher")
SetupSlashCoNetworkVar("Bool", 2, "Visible", true)
SetupSlashCoNetworkVar("Bool", 3, "CanSeeFlashlights", true) -- RaphaelIT7: Deprecated? Does anyone even use it?
SetupSlashCoNetworkVar("Bool", 4, "DynamicFlashlight")

-- RaphaelIT7: I do not like this... a problem for later me... (Update) I hate myself.
-- ToDo: Rework the entire perk networking, as in the future with more perks we may hit the networking limit of 511 characters!
SetupSlashCoNetworkVar("String", 0, "OwnedPerks")
SetupSlashCoNetworkVar("String", 1, "ActiveEffects")
SetupSlashCoNetworkVar("String", 2, "PickedSlasher") -- RaphaelIT7: Only used to display which slasher they'll be. If we need more string lots this one is easy to remove!

-- No.
function PLAYER:InstallDataTable()
end

function PLAYER:NetworkVar(type, slot, name)
	error("[SlashCo] This is not supported")
end