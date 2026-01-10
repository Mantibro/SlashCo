local PLAYER = FindMetaTable("Player")

hook.Add("EntityNetworkedVarChanged", "SlashCoImpervious", function(ent, name, _, new)
	if name ~= "IsImpervious" then return end

	ent.IsImpervious = new
	ent:SetCustomCollisionCheck(new or false)
	ent:CollisionRulesChanged()
end)

hook.Add("ShouldCollide", "SlashCo:Impervious", function(ent1, ent2)
	if not ent1.IsImpervious and not ent2.IsImpervious then
		return
	end

	if (ent1:IsPlayer() or ent1:GetClass() == "prop_door_rotating") and (ent2:IsPlayer() or ent2:GetClass() == "prop_door_rotating") then
		--i would put a check for if doors were locked here but the locked state of doors could change
		--see the warning in https://wiki.facepunch.com/gmod/GM:ShouldCollide to see why this matters
		return false
	end
	
	if (ent1:IsPlayer() or ent1:GetClass() == "func_door_rotating") and (ent2:IsPlayer() or ent2:GetClass() == "func_door_rotating") then
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

hook.Add("PlayerDeath", "slashCoRemoveImpervious", function(victim)
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
	-- RaphaelIT7: If map tools are enabled, the server host is always allowed to noclip to make things easier.
	if ply:IsListenServerHost() and SlashCo.MapTools.IsEnabled(true) then
		return true
	end
	
	if ply:Team() ~= TEAM_SLASHER then
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
		if ent:IsPlayer() and ent:Team() == TEAM_SURVIVOR and ent:CanBeSeen() then
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
		for idx, ply in ipairs(results) do
			if self:SlasherFunction("Visibility", ply) == 0 then
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
		unreliable = true,
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


--[[
	DTVar Networking (Since NW2 is broken / hasn't been fixed yet)

	Unlike the whole SetupDataTables shit, our function exist in the metatable and are always available.
	So we don't have to worry about shit like Player:SetSlasher not existing for like 1 tick until SetupDataTables was called
]]

SlashCo_DTNetworking = SlashCo_DTNetworking or {}
local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")
local function SetupSlashCoNetworkVar(type, index, name) -- Same order as :NetworkVar
	if not SlashCo_DTNetworking[type] then
		SlashCo_DTNetworking[type] = {}
	end

	local defaultFallbacks = {
		["Int"] = 0,
		["Float"] = 0,
		["String"] = "",
		["Entity"] = nil,
		["Bool"] = false,
		["Vector"] = Vector(0, 0, 0),
		["Angle"] = Angle(0, 0, 0),
	}

	local SetDTFunc = entMeta["SetDT" .. type]
	local defaultFallback = defaultFallbacks[type]
	plyMeta["Set" .. name] = function(self, value)
		SetDTFunc(self, index, value or defaultFallback)
	end

	local GetDTFunc = entMeta["GetDT" .. type]
	plyMeta["Get" .. name] = function(self, fallback)
		return GetDTFunc(self, index) or (fallback or defaultFallback)
	end

	SlashCo_DTNetworking[type][index] = name
	SlashCo_DTNetworking[name] = {
		callbackName = type .. "_" .. index,
		type = type,
		index = index,
		get = plyMeta["Get" .. name],
		set = plyMeta["Set" .. name],
	}
end

-- RaphaelIT7: There intentionally is no callback function due to the nature of DTs being possibly received more than once! If you really need it tell me - I got that code already done

SetupSlashCoNetworkVar("Int", 0, "Experience")
SetupSlashCoNetworkVar("Int", 1, "Points")
SetupSlashCoNetworkVar("Int", 2, "SurvivorRoundsWon")
SetupSlashCoNetworkVar("Int", 3, "SlasherRoundsWon")
SetupSlashCoNetworkVar("Int", 4, "Perception")

SetupSlashCoNetworkVar("Float", 0, "FogMult")
SetupSlashCoNetworkVar("Float", 1, "EyeSight")
SetupSlashCoNetworkVar("Float", 2, "DeafenTime")

SetupSlashCoNetworkVar("Bool", 0, "CanSeePlayers")
SetupSlashCoNetworkVar("Bool", 1, "WasSeenBySlasher")

SetupSlashCoNetworkVar("String", 0, "PickedSlasher") -- RaphaelIT7: Only used to display which slasher they'll be.
SetupSlashCoNetworkVar("String", 1, "ActivePerks")
SetupSlashCoNetworkVar("String", 2, "OwnedPerks") -- RaphaelIT7: I do not like this... a problem for later me
SetupSlashCoNetworkVar("String", 3, "ActiveEffects")