local weakMeta = {
	__mode = "k",
}

-- This table contains all tables that were played, this was done to support full updates properly later on. Currently Unused.
SlashCo.AudioSystem.Sounds = SlashCo.AudioSystem.Sounds or {}
SlashCo.AudioSystem.DeltaSoundCache = SlashCo.AudioSystem.DeltaSoundCache or {}
SlashCo.AudioSystem.PlayerDeltaSoundCache = SlashCo.AudioSystem.PlayerDeltaSoundCache or {}
SlashCo.AudioSystem.TransmitData = SlashCo.AudioSystem.TransmitData or {}

setmetatable(SlashCo.AudioSystem.PlayerDeltaSoundCache, weakMeta)
setmetatable(SlashCo.AudioSystem.TransmitData, weakMeta)

local NetworkSettings = { -- This table MUST be the same on the client
	PlaySound = {
		ID = 1,
		ReadFunc = nil, -- only used clientside
		ProcessFunc = nil, -- on the server this is used to SEND data- on the client it's used to process data read by ReadFunc
	},
	StopSound = {
		ID = 2,
		ReadFunc = nil,
		ProcessFunc = nil,
	},
	EntityRemoved = {
		ID = 3,
		ReadFunc = nil,
		ProcessFunc = nil,
	},
	SetGroupVolume = {
		ID = 4,
		ReadFunc = nil,
		ProcessFunc = nil,
	},
	FadeSound = {
		ID = 5,
		ReadFunc = nil,
		ProcessFunc = nil,
	},
	_ID_BITS = 3, -- max 7
	_COUNT_BITS = 9, -- max 511 updates per transmit

	-- Sends out an upate every time containing all updates from the last acknowledged tick
	-- if false it sends the message as reliable once and is done
	-- This makes a noticable difference in higher ping conditions & packet loss
	-- as it can network sounds way faster staying in sync with entity updates.
	_UNRELIABLE = true,
}

local function AddToTransmit(ply, type, data)
	local transmitData = SlashCo.AudioSystem.TransmitData[ply]
	if not transmitData then
		transmitData = {
			pending = {}
		}
		SlashCo.AudioSystem.TransmitData[ply] = transmitData
	end

	table.insert(transmitData.pending, {
		type = type,
		data = data,
		tick = engine.TickCount()
	})
end

local function AddToTransmits(sendToEntity, type, data)
	if not sendToEntity then
		for _, ply in player.Iterator() do
			AddToTransmit(ply, type, data)
		end
	else
		if isnumber(sendToEntity) and team.Valid(sendToEntity) then
			sendToEntity = team.GetPlayers(sendToEntity)
		end

		if istable(sendToEntity) then
			for _, ply in ipairs(sendToEntity) do
				AddToTransmit(ply, type, data)
			end
		elseif IsEntity(sendToEntity) and IsValid(sendToEntity) and sendToEntity:IsPlayer() then
			AddToTransmit(sendToEntity, type, data)
		end
	end
end

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

local function SendToPlayersWithDelta(soundData, deltaList)
	local identifier = soundData.identifier or soundData.soundPath
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
end

local function SendToPlayersWithNoDelta(soundData, manualSend)
	net.WriteBool(false)
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

--[[
	Serverside only fields:
		number sendToTeam - Sends the given sound only to the specific team
		Entity/Table sendToEntity - Sends the given sound only to a specific player/table of players
]]
util.AddNetworkString("slashCo_AudioSystem_PlaySound")
function SlashCo.AudioSystem.PlaySound(soundData) -- see cl_audiosystem.lua for documentation of the table.
	if not istable(soundData) then
		error("PlaySound: didn't get the table that it wants!")
	end

	if not isstring(soundData.soundPath) then -- the only requirement that exists.
		error("PlaySound: Missing soundPath field!")
	end

	if not soundData.entity then -- Falls back onto the world as a global sound!
		soundData.entity = 0
		soundData.disableUniqueToEntity = true

		if not soundData.position then
			soundData.forceStereo = true
		end
	end

	-- Fallback code to ensure that if an entity wasn't networked to a client yet,
	-- the sound would still have the right volume calculated when used with any of the fields that require a position to calculate the volume with.
	if not soundData.position and (soundData.minDistance or soundData.maxDistance or soundData.startDistance or soundData.startEndDistance) and soundData.entity and (isnumber(soundData.entity) or IsValid(soundData.entity)) then
		soundData.position = (isnumber(soundData.entity) and Entity(soundData.entity) or soundData.entity):GetPos()
	end

	if not soundData.looping then
		soundData.deleteWhenDone = true -- For serverside sounds, we force this if their not looping sounds.
	end

	if soundData.sendToTeam then
		if not team.Valid(soundData.sendToTeam) then
			error("PlaySound: Tried to use an invalid Team in soundData.sendToTeam")
		end

		soundData.sendToEntity = team.GetPlayers(sendToEntity)
	end

	local identifier = soundData.identifier or soundData.soundPath
	local deltaTable = SlashCo.AudioSystem.DeltaSoundCache[identifier]

	local data = {
		identifier = identifier,
		deltaTable = deltaTable,
		soundData = soundData,
	}

	AddToTransmits(soundData.sendToEntity, NetworkSettings.PlaySound, data)
end

function NetworkSettings.PlaySound.ProcessFunc(data, ply)
	local identifier = data.identifier
	local soundData = data.soundData
	local deltaTable = data.deltaTable -- if we had no data when PlaySound was called we do not want to check here for delta.
	local plyDeltaTable = SlashCo.AudioSystem.PlayerDeltaSoundCache[ply]
	if deltaTable and plyDeltaTable and plyDeltaTable[identifier] then
		SendToPlayersWithDelta(soundData, deltaTable)
	else
		SendToPlayersWithNoDelta(soundData)
		deltaTable = {}
		-- print("We had no delta :sob:")

		-- Yes, this is not the best way, we should probably ALWAYS update the delta though I don't like that idea really as then delta recover gets tricky.
		-- Also really only position & entity fields should change.
		DeltaMerge(deltaTable, soundData)
	
		SlashCo.AudioSystem.DeltaSoundCache[identifier] = deltaTable
	end
end

-- We use SetupPlayerVisibility as it's called, ONCE per transmit / entity update
-- So every time the engine sends out a packet, we write our update into it
-- if we used Think, then we might write an update more than once, wasting performance and buffer space
util.AddNetworkString("slashCo_AudioSystem_Update")
hook.Add("SetupPlayerVisibility", "SlashCo:AudioSystem", function(ply)
	local transmitData = SlashCo.AudioSystem.TransmitData[ply]
	if not transmitData then return end

	local count = #transmitData.pending
	if count == 0 then return end

	local maxEntries = math.pow(2, NetworkSettings._COUNT_BITS) - 1
	if count > maxEntries then
		count = maxEntries
	end

	net.Start("slashCo_AudioSystem_Update", NetworkSettings._UNRELIABLE)
		net.WriteUInt(engine.TickCount(), 32)
		net.WriteUInt(count, NetworkSettings._COUNT_BITS)
		for idx, transmitEntry in ipairs(transmitData.pending) do
			if idx > maxEntries then break end

			net.WriteUInt(transmitEntry.tick, 32)
			net.WriteUInt(transmitEntry.type.ID, NetworkSettings._ID_BITS)
			local func = transmitEntry.type.ProcessFunc
			if func then
				func(transmitEntry.data, ply)
			else
				net.Abort()
				ErrorNoHaltWithStack("Tried to network an update with no function!")
				table.remove(transmitData.pending, idx) -- Get rid of the invalid entry
				return
			end
		end
	net.Send(ply)

	if not NetworkSettings._UNRELIABLE then
		transmitData.pending = {}
	end
end)

util.AddNetworkString("slashCo_AudioSystem_StopSound")
function SlashCo.AudioSystem.StopSound(identifier, fadeOut, entity, sendToEntity)
	fadeOut = fadeOut or 0

	if not isnumber(fadeOut) then
		error("fadeOut is not a number!")
	end

	if entity ~= nil and not IsEntity(entity) then
		error("entity is not an Entity!")
	end

	local data = {
		identifier = identifier,
		fadeOut = fadeOut,
		entity = entity,
	}

	AddToTransmits(sendToEntity, NetworkSettings.StopSound, data)
end

function NetworkSettings.StopSound.ProcessFunc(data)
	WriteSoundField(data.identifier, net.WriteString) -- if given nil as a identifier we will stop all sounds.
	net.WriteFloat(data.fadeOut)
	WriteSoundField(data.entity, WriteEntIndex)
end

function SlashCo.AudioSystem.FadeSound(identifier, fadeTime, targetVolume) -- ToDo: Fix this function. Update: naah
	fadeTime = fadeTime or 0

	if not isnumber(fadeTime) then
		error("fadeTime is not a number!")
	end

	if not isnumber(targetVolume) then
		error("targetVolume is not a number!")
	end

	local data = {
		identifier = identifier,
		fadeTime = fadeTime,
		targetVolume = targetVolume,
	}

	AddToTransmits(nil, NetworkSettings.FadeSound, data)
end

function NetworkSettings.FadeSound.ProcessFunc(data)
	net.WriteString(data.identifier)
	net.WriteFloat(data.fadeTime)
	net.WriteFloat(data.targetVolume)
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

util.AddNetworkString("slashCo_AudioSystem_Acknowledge")
net.Receive("slashCo_AudioSystem_Acknowledge", function(_, ply)
	local transmitData = SlashCo.AudioSystem.TransmitData[ply]
	if not transmitData then return end

	local tickCount = engine.TickCount()
	transmitData._LAST_ACK = net.ReadUInt(32)
	if transmitData._LAST_ACK > tickCount then
		transmitData._LAST_ACK = tickCount -- In case it somehow screwed up???
	end

	for idx, transmitEntry in ipairs(transmitData.pending) do
		if transmitEntry.tick <= transmitData._LAST_ACK then
			table.remove(transmitData.pending, idx)
		end
	end
end)

hook.Add("EntityRemoved", "AudioSystem:EntityRemoved", function(ent)
	AddToTransmits(nil, NetworkSettings.EntityRemoved, ent:EntIndex())

	if ent:IsPlayer() then
		SlashCo.AudioSystem.TransmitData[ent] = nil
		SlashCo.AudioSystem.PlayerDeltaSoundCache[ent] = nil
	end
end)

function NetworkSettings.EntityRemoved.ProcessFunc(entIndex)
	net.WriteUInt(entIndex, MAX_EDICT_BITS)
end

function SlashCo.AudioSystem.SetGroupVolume(groupName, groupVolume, lerpTime, sendToEntity)
	local data = {
		groupName = groupName,
		groupVolume = groupVolume,
		lerpTime = lerpTime,
	}

	AddToTransmits(sendToEntity, NetworkSettings.SetGroupVolume, data)
end

function NetworkSettings.SetGroupVolume.ProcessFunc(data)
	net.WriteString(data.groupName)
	net.WriteFloat(data.groupVolume)
	net.WriteFloat(data.lerpTime)
end