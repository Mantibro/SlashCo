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
	if ply:Team() == TEAM_SPECTATOR then
		return false
	end
end)

function PLAYER:MarkAsSeenBySlasher()
	self:SetNW2Bool("WasSeenBySlasher", true)
end

function PLAYER:WasSeenBySlasher()
	return self:GetNW2Bool("WasSeenBySlasher", false)
end

function PLAYER:SetFogMult(mult)
	self:SetNW2Float("FogMult", mult)
end

function PLAYER:GetFogMult()
	return self:GetNW2Float("FogMult", 1)
end

-- This function is VERY expensive, BUT it shouldn't be called too frequent anyways.
function PLAYER:FindPlayersInView(dist, radius, notrace)
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

	if self:Team() == TEAM_SLASHER then
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