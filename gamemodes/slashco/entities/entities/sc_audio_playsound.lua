ENT.Type = "point"

function ENT:KeyValue(key, value)
	-- Ensure soundData table exists
	local entTbl = self:GetTable()
	local soundData = entTbl.soundData
	if not soundData then
		soundData = {
			deleteWhenDone = true,
		}
		entTbl.soundData = soundData
	end

	if key == "looping" then
		value = tobool(value)
	end

	if key == "soundPath" then
		local soundPath, isRandom = SlashCo.AudioSystem.ResolveSoundPath(value)
		soundData.soundPath = soundPath

		soundData._isRandom = isRandom
		soundData._origSoundPath = value
	end

	-- It's a default! Away you go
	if isnumber(value) and value == 0 then return end

	soundData[key] = value
end

local function PlaySound(ent, soundData)
	-- Not expected to change once set!
	if not soundData.identifier then
		soundData.identifier = ent:GetName()
	end

	-- We don't expect them to follow/move!
	if not soundData.position then
		soundData.position = ent:GetPos()
	end

	if soundData._isRandom then
		soundData.soundPath = SlashCo.AudioSystem.ResolveSoundPath(soundData._origSoundPath)
	end

	if soundData.soundPath then
		SlashCo.AudioSystem.PlaySound(soundData)
	else
		print("[SlashCo] Failed to find any sound from " .. soundData._origSoundPath .. " (Map sc_audio_playsound name: \"" .. ent:GetName() .. "\" - identifier: \"" .. soundData.identifier .. "\")")
	end
end

function ENT:AcceptInput(name, activator, _, value)
	local entTbl = self:GetTable()
	local soundData = entTbl.soundData

	-- No data? No inputs!
	if not soundData then return end

	name = string.lower(name)

	if name == "play" then
		PlaySound(self, soundData)
	end
end