--[[
	ToDo: Implemement ambient music system
]]

-- This table contains all tables that were played, this was done to support full updates properly later on. Currently Unused.
SlashCo.AudioSystem.Sounds = SlashCo.AudioSystem.Sounds or {}

-- Needed since WriteSoundField else wouldn't work.
-- ToDo: Why do we even use the EntIndex and not the Entity handle?
--       Probably because the Entity handle might not get valid when we call Entity(index) before it was created?
local function WriteEntIndex(entity)
	net.WriteUInt(entity:EntIndex(), MAX_EDICT_BITS)
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

util.AddNetworkString("slashCo_AudioSystem_PlaySound")
function SlashCo.AudioSystem.PlaySound(soundData) -- see cl_audiosystem.lua for documentation of the table.
	if not istable(soundData) then
		error("PlaySound: didn't get the table that it wants!")
	end

	if not isstring(soundData.soundPath) then -- the only requirement that exists.
		error("PlaySound: Missing soundPath field!")
	end

	net.Start("slashCo_AudioSystem_PlaySound")
		WriteSoundField(soundData.soundPath, net.WriteString)
		WriteSoundField(soundData.entity, WriteEntIndex)
		WriteSoundField(soundData.soundLevel, net.WriteUInt, 14)
		WriteSoundField(soundData.volume, net.WriteFloat)
		WriteSoundField(soundData.looping, net.WriteBool)
		WriteSoundField(soundData.fadeIn, net.WriteFloat)
		WriteSoundField(soundData.startTick, net.WriteUInt, 32)
		WriteSoundField(soundData.identifier, net.WriteString)
		WriteSoundField(soundData.minDistance, net.WriteUInt, 16)
		WriteSoundField(soundData.maxDistance, net.WriteUInt, 16)
		WriteSoundField(soundData.position, net.WriteVector)
		WriteSoundField(soundData.modes, net.WriteString)
	net.Broadcast()

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
function SlashCo.AudioSystem.StopSound(identifier, fadeOut, entity)
	fadeOut = fadeOut or 0

	local isValid = IsValid(entity)
	net.Start("slashCo_AudioSystem_StopSound")
		net.WriteBool(identifier == nil) -- if given nil as a identifier we will stop all sounds.
		if identifier then
			net.WriteString(identifier)
		end
		net.WriteFloat(fadeOut)
		net.WriteBool(isValid)
		if isValid then
			net.WriteUInt(entity:EntIndex(), MAX_EDICT_BITS)
		end
	net.Broadcast()
end