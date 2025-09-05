--[[
	ToDo: Implemement ambient music system
]]

-- This table contains all tables that were played, this was done to support full updates properly later on. Currently Unused.
SlashCo.AudioSystem.Sounds = SlashCo.AudioSystem.Sounds or {}

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

	-- using soundData.unreliable can allow sounds to be played with lower delays though they'll be unreliable and could be lost.
	-- This can be useful if you play only a short sound like a footstep where having a smaller delay can affect gameplay.
	net.Start("slashCo_AudioSystem_PlaySound", soundData.unreliable or false)
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
		WriteSoundField(soundData.forceSterio, net.WriteBool)
		WriteSoundField(soundData.noWorldSpace, net.WriteBool)
		WriteSoundField(soundData.dynamicPan, net.WriteBool)
		WriteSoundField(soundData.boundConVar, net.WriteString)
		WriteSoundField(soundData.pulseEffect, WritePulseEffect)
		WriteSoundField(soundData.makeUniqueToEntity, net.WriteBool)
		-- NOTE: We don't network the field noplay since we expect networked sounds to always play instantly based on how we currently use it.

	if not soundData.sendToEntity then -- serverside only, its networked only to the player its being played od
		net.Broadcast()
	else
		net.Send(soundData.sendToEntity)
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