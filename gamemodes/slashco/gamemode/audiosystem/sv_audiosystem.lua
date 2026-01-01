--[[
	ToDo: Implemement ambient music system
]]

-- This table contains all tables that were played, this was done to support full updates properly later on. Currently Unused.
SlashCo.AudioSystem.Sounds = SlashCo.AudioSystem.Sounds or {}
SlashCo.AudioSystem.DeltaSoundCache = SlashCo.AudioSystem.DeltaSoundCache or {}
SlashCo.AudioSystem.PlayerDeltaSoundCache = SlashCo.AudioSystem.PlayerDeltaSoundCache or {}

-- Needed since WriteSoundField else wouldn't work.
-- ToDo: Why do we even use the EntIndex and not the Entity handle?
--	   Probably because the Entity handle might not get valid when we call Entity(index) before it was created?
local function WriteEntIndex(entity)
	net.WriteUInt(isnumber(entity) and entity or entity:EntIndex(), MAX_EDICT_BITS)
end

--[[
	Helper function to write fields even if they are nil values.
	We skip any fields that are nil to save some work & to allow it to use the proper fallback value clientside then.
]]
local function WriteSoundField(value, writeFunc, ...)
	local isNil = value == nil
	net.WriteBool(isNil)
	if not isNil then
		writeFunc(value, ...)
	end
end

local function WritePulseEffect(table)
	WriteSoundField(table.entity, WriteEntIndex)
	WriteSoundField(table.entityClass, net.WriteString)
	WriteSoundField(table.frequency, net.ReadUInt, 16)
end

local function WriteDeltaSoundField(value, deltaValue, writeFunc, ...)
	local isNil = value == nil or value == deltaValue
	net.WriteBool(isNil)
	if not isNil then
		-- print("Writing delta value", type(value), value)
		writeFunc(value, ...)
	end
end

local function WriteDeltaPulseEffect(table, deltaTable)
	WriteDeltaSoundField(table.entity, (deltaTable and deltaTable.entity or nil), WriteEntIndex)
	WriteDeltaSoundField(table.entityClass, (deltaTable and deltaTable.entityClass or nil), net.WriteString)
	WriteDeltaSoundField(table.frequency, (deltaTable and deltaTable.frequency or nil), net.ReadUInt, 16)
end

local function SendToPlayersWithDelta(playerList, soundData, deltaList)
	local identifier = soundData.identifier or soundData.soundPath
	net.Start("slashCo_AudioSystem_PlaySound", soundData.unreliable or false)
		net.WriteBool(true)
		if soundData.soundPath == identifier then -- We cannot apply delta to the soundPath if it's the delta identifier!
			WriteSoundField(soundData.soundPath, net.WriteString)
		else
			WriteDeltaSoundField(soundData.soundPath, deltaList.soundPath, net.WriteString)
		end
		WriteDeltaSoundField(soundData.fallbackSoundPath, deltaList.fallbackSoundPath, net.WriteString)
		WriteDeltaSoundField(soundData.entity, deltaList.entity, WriteEntIndex)
		WriteDeltaSoundField(soundData.soundLevel, deltaList.soundLevel, net.WriteUInt, 14)
		WriteDeltaSoundField(soundData.volume, deltaList.volume, net.WriteFloat)
		WriteDeltaSoundField(soundData.looping, deltaList.looping, net.WriteBool)
		WriteDeltaSoundField(soundData.startTick, deltaList.startTick, net.WriteUInt, 32)
		if soundData.identifier == identifier then -- We cannot apply delta to the identifier if it's the delta identifier!
			WriteSoundField(soundData.identifier, net.WriteString)
		else
			WriteDeltaSoundField(soundData.identifier, deltaList.identifier, net.WriteString)
		end
		WriteDeltaSoundField(soundData.minDistance, deltaList.minDistance, net.WriteUInt, 16)
		WriteDeltaSoundField(soundData.maxDistance, deltaList.maxDistance, net.WriteUInt, 16)
		WriteDeltaSoundField(soundData.startDistance, deltaList.startDistance, net.WriteUInt, 16)
		WriteDeltaSoundField(soundData.startEndDistance, deltaList.startEndDistance, net.WriteUInt, 16)
		WriteDeltaSoundField(soundData.position, deltaList.position, net.WriteVector)
		WriteDeltaSoundField(soundData.modes, deltaList.modes, net.WriteString)
		WriteDeltaSoundField(soundData.pan, deltaList.pan, net.WriteFloat)
		WriteDeltaSoundField(soundData.playbackRate, deltaList.playbackRate, net.WriteFloat)
		WriteDeltaSoundField(soundData.group, deltaList.group, net.WriteString)
		WriteDeltaSoundField(soundData.deleteWhenDone, deltaList.deleteWhenDone, net.WriteBool)
		WriteDeltaSoundField(soundData.fadeIn, deltaList.fadeIn, net.WriteFloat)
		WriteDeltaSoundField(soundData.fadeOut, deltaList.fadeOut, net.WriteFloat)
		WriteDeltaSoundField(soundData.fadeOutStart, deltaList.fadeOutStart, net.WriteFloat)
		WriteDeltaSoundField(soundData.forceMono, deltaList.forceMono, net.WriteBool)
		WriteDeltaSoundField(soundData.forceStereo, deltaList.forceStereo, net.WriteBool)
		WriteDeltaSoundField(soundData.noWorldSpace, deltaList.noWorldSpace, net.WriteBool)
		WriteDeltaSoundField(soundData.dynamicPan, deltaList.dynamicPan, net.WriteBool)
		WriteDeltaSoundField(soundData.boundConVar, deltaList.boundConVar, net.WriteString)
		WriteDeltaSoundField(soundData.pulseEffect, deltaList.pulseEffect, WriteDeltaPulseEffect)
		WriteDeltaSoundField(soundData.disableUniqueToEntity, deltaList.disableUniqueToEntity, net.WriteBool)
		WriteDeltaSoundField(soundData.raytraced, deltaList.raytraced, net.WriteBool)
		WriteDeltaSoundField(soundData.modifyGroup, deltaList.modifyGroup, net.WriteString)
		WriteDeltaSoundField(soundData.modifyGroupVolumeMult, deltaList.modifyGroupVolumeMult, net.WriteFloat)
		WriteDeltaSoundField(soundData.modifyGroupVolumeFadeTime, deltaList.modifyGroupVolumeFadeTime, net.WriteFloat)
		-- NOTE: We don't network the field noplay since we expect networked sounds to always play instantly based on how we currently use it.
	if not playerList then
		net.Broadcast()
	else
		net.Send(playerList)
	end
end

local function SendToPlayersWithNoDelta(playerList, soundData, manualSend)
	if not manualSend then -- In case we are calling this for delta recovery
		net.Start("slashCo_AudioSystem_PlaySound", soundData.unreliable or false)
			net.WriteBool(false)
	end

		WriteSoundField(soundData.soundPath, net.WriteString)
		WriteSoundField(soundData.fallbackSoundPath, net.WriteString)
		WriteSoundField(soundData.entity, WriteEntIndex)
		WriteSoundField(soundData.soundLevel, net.WriteUInt, 14)
		WriteSoundField(soundData.volume, net.WriteFloat)
		WriteSoundField(soundData.looping, net.WriteBool)
		WriteSoundField(soundData.startTick, net.WriteUInt, 32)
		WriteSoundField(soundData.identifier, net.WriteString)
		WriteSoundField(soundData.minDistance, net.WriteUInt, 16)
		WriteSoundField(soundData.maxDistance, net.WriteUInt, 16)
		WriteSoundField(soundData.startDistance, net.WriteUInt, 16)
		WriteSoundField(soundData.startEndDistance, net.WriteUInt, 16)
		WriteSoundField(soundData.position, net.WriteVector)
		WriteSoundField(soundData.modes, net.WriteString)
		WriteSoundField(soundData.pan, net.WriteFloat)
		WriteSoundField(soundData.playbackRate, net.WriteFloat)
		WriteSoundField(soundData.group, net.WriteString)
		WriteSoundField(soundData.deleteWhenDone, net.WriteBool)
		WriteSoundField(soundData.fadeIn, net.WriteFloat)
		WriteSoundField(soundData.fadeOut, net.WriteFloat)
		WriteSoundField(soundData.fadeOutStart, net.WriteFloat)
		WriteSoundField(soundData.forceMono, net.WriteBool)
		WriteSoundField(soundData.forceStereo, net.WriteBool)
		WriteSoundField(soundData.noWorldSpace, net.WriteBool)
		WriteSoundField(soundData.dynamicPan, net.WriteBool)
		WriteSoundField(soundData.boundConVar, net.WriteString)
		WriteSoundField(soundData.pulseEffect, WritePulseEffect)
		WriteSoundField(soundData.disableUniqueToEntity, net.WriteBool)
		WriteSoundField(soundData.raytraced, net.WriteBool)
		WriteSoundField(soundData.modifyGroup, net.WriteString)
		WriteSoundField(soundData.modifyGroupVolumeMult, net.WriteFloat)
		WriteSoundField(soundData.modifyGroupVolumeFadeTime, net.WriteFloat)
		-- NOTE: We don't network the field noplay since we expect networked sounds to always play instantly based on how we currently use it.
	if manualSend then return end
	if not playerList then
		net.Broadcast()
	else
		net.Send(playerList)
	end
end

local deltaMerge
local function DeltaMerge(deltaTable, baseTable) -- This one works differently than the clientside version as we always update only the deltaTable.
	for key, val in pairs(baseTable) do
		local deltaTableVal = deltaTable[key]
		if deltaTableVal then
			if istable(deltaTableVal) then
				deltaMerge(deltaTableVal, baseTable[key])
				continue -- We got nothing to change :3
			end
		end

		deltaTable[key] = val
	end
end
deltaMerge = DeltaMerge

util.AddNetworkString("slashCo_AudioSystem_PlaySound")
function SlashCo.AudioSystem.PlaySound(soundData) -- see cl_audiosystem.lua for documentation of the table.
	if not istable(soundData) then
		error("PlaySound: didn't get the table that it wants!")
	end

	if not isstring(soundData.soundPath) then -- the only requirement that exists.
		error("PlaySound: Missing soundPath field!")
	end

	-- Fallback code to ensure that if an entity wasn't networked to a client yet,
	-- the sound would still have the right volume calculated when used with any of the fields that require a position to calculate the volume with.
	if not soundData.position and (soundData.minDistance or soundData.maxDistance or soundData.startDistance or soundData.startEndDistance) and soundData.entity and (isnumber(soundData.entity) or IsValid(soundData.entity)) then
		soundData.position = (isnumber(soundData.entity) and Entity(soundData.entity) or soundData.entity):GetPos()
	end

	if not soundData.looping then
		soundData.deleteWhenDone = true -- For serverside sounds, we force this if their not looping sounds.
	end

	local identifier = soundData.identifier or soundData.soundPath
	local deltaTable = SlashCo.AudioSystem.DeltaSoundCache[identifier]
	if deltaTable then
		local deltaPlayers = {}
		local revDeltaPlayers = {}
		local targetPlayers = {}
		if IsEntity(soundData.sendToEntity) then
			local deltaList = SlashCo.AudioSystem.PlayerDeltaSoundCache[soundData.sendToEntity]
			if deltaList and deltaList[identifier] then
				table.insert(deltaList, soundData.sendToEntity)

				table.insert(deltaPlayers, soundData.sendToEntity)
				revDeltaPlayers[soundData.sendToEntity] = true
			end
		else
			if istable(soundData.sendToEntity) then
				for k, ply in ipairs(soundData.sendToEntity) do
					targetPlayers[ply] = true
					targetPlayers[k] = ply
				end
			else
				for k, ply in player.Iterator() do
					targetPlayers[ply] = true
					targetPlayers[k] = ply
				end
			end

			for ply, deltaList in pairs(SlashCo.AudioSystem.PlayerDeltaSoundCache) do
				if not IsValid(ply) then
					SlashCo.AudioSystem.PlayerDeltaSoundCache[ply] = nil -- Yes, this is how we'll clean it.
					continue
				end

				if targetPlayers[ply] and deltaList[identifier] then
					-- print("Added for delta update " .. ply:Name())
					table.insert(deltaPlayers, ply)
					revDeltaPlayers[ply] = true
				end
			end
		end

		SendToPlayersWithDelta(deltaPlayers, soundData, deltaTable)

		local noDeltaPlayers = {}
		for _, ply in ipairs(targetPlayers) do
			if revDeltaPlayers[ply] then continue end

			table.insert(noDeltaPlayers, ply)
		end

		if #noDeltaPlayers > 0 then
			-- print("We had no delta for " .. #noDeltaPlayers)
			SendToPlayersWithNoDelta(noDeltaPlayers, soundData)
		end
	else
		SendToPlayersWithNoDelta(soundData.sendToEntity, soundData)
		deltaTable = {}
		-- print("We had no delta :sob:")

		-- Yes, this is not the best way, we should probably ALWAYS update the delta though I don't like that idea really as then delta recover gets tricky.
		-- Also really only position & entity fields should change.
		DeltaMerge(deltaTable, soundData)
	
		SlashCo.AudioSystem.DeltaSoundCache[identifier] = deltaTable
	end

	--[[table.insert(SlashCo.AudioSystem.Sounds, {
		filePath = soundPath,
		level = soundLevel,
		ent = ent:EntIndex(),
		volume = vol,
		permanent = permanent,
		startTime = CurTime()
	})]]
end

util.AddNetworkString("slashCo_AudioSystem_StopSound")
function SlashCo.AudioSystem.StopSound(identifier, fadeOut, entity, sendToEntity)
	fadeOut = fadeOut or 0

	local isValid = IsValid(entity)
	net.Start("slashCo_AudioSystem_StopSound")
		WriteSoundField(identifier, net.WriteString) -- if given nil as a identifier we will stop all sounds.
		net.WriteFloat(fadeOut)
		WriteSoundField(entity, WriteEntIndex)
	if not sendToEntity then
		net.Broadcast()
	else
		net.Send(sendToEntity)
	end
end

util.AddNetworkString("slashCo_AudioSystem_FadeSound")
function SlashCo.AudioSystem.FadeSound(identifier, fadeTime, targetVolume) -- ToDo: Fix this function.
	net.Start("slashCo_AudioSystem_FadeSound")
		net.WriteString(identifier)
		net.WriteFloat(fadeTime)
		net.WriteFloat(targetVolume)
	net.Broadcast()
end

util.AddNetworkString("slashCo_AudioSystem_AcknowledgeDelta")
net.Receive("slashCo_AudioSystem_AcknowledgeDelta", function(_, ply)
	local identifier = net.ReadString()
	if SlashCo.AudioSystem.DeltaSoundCache[identifier] then
		local plyTable = SlashCo.AudioSystem.PlayerDeltaSoundCache[ply]
		if not plyTable then
			plyTable = {}
			SlashCo.AudioSystem.PlayerDeltaSoundCache[ply] = plyTable
		end

		plyTable[identifier] = true
		-- print("Player " .. tostring(ply) .. "(" .. ply:Name() .. ")" .. " acknowledged delta!", identifier)
	else
		-- Player tried to acknowledge a sound for delta when we as the server don't even know it?!? How...
	end
end)

util.AddNetworkString("slashCo_AudioSystem_MissingDelta")
net.Receive("slashCo_AudioSystem_MissingDelta", function(_, ply)
	local identifier = net.ReadString()
	local missID = net.ReadUInt(32)
	SlashCo.AudioSystem.PlayerDeltaSoundCache[ply] = nil -- Yeet, since you can't do anything :(

	local deltaTable = SlashCo.AudioSystem.DeltaSoundCache[identifier]
	if not deltaTable then return end -- GG

	net.Start("slashCo_AudioSystem_MissingDelta")
		net.WriteString(identifier)
		net.WriteUInt(missID, 32) -- The client needs this to keep track in case multiple delta misses happen
		SendToPlayersWithNoDelta(ply, deltaTable, true)
	net.Send(ply)
	-- print("Sent delta recovery")
end)

util.AddNetworkString("slashCo_AudioSystem_EntityRemoved")
hook.Add("EntityRemoved", "AudioSystem:EntityRemoved", function(ent)
	net.Start("slashCo_AudioSystem_EntityRemoved")
		net.WriteUInt(ent:EntIndex(), MAX_EDICT_BITS)
	net.Broadcast()
end)

util.AddNetworkString("slashCo_AudioSystem_SetGroupVolume")
function SlashCo.AudioSystem.SetGroupVolume(groupName, groupVolume, lerpTime, sendToEntity)
	net.Start("slashCo_AudioSystem_SetGroupVolume")
		net.WriteString(groupName)
		net.WriteFloat(groupVolume)
		net.WriteFloat(lerpTime)
	if not sendToEntity then
		net.Broadcast()
	else
		net.Send(sendToEntity)
	end
end