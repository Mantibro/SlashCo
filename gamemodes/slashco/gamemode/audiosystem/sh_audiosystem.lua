SlashCo = SlashCo or {} -- We load VERY early.
SlashCo.AudioSystem = SlashCo.AudioSystem or {}
SlashCo.AudioSystem.RegisteredSounds = SlashCo.AudioSystem.RegisteredSounds or {}
SlashCo.AudioSystem.ResolveCache = SlashCo.AudioSystem.ResolveCache or {}

--[[
	The Background music is networked & syncronized.
	Later there will be a helper function to do this with other sounds too.
	This whole audio system is meant to efficiently syncronize and play sounds for players
]]


-- Simple function. Adds sound/ to the given fileName to properly work with sound.PlayFile
function SlashCo.AudioSystem.ToSound(fileName)
	if fileName == "" then
		return nil
	end

	if fileName:StartsWith("sound/") then
		return fileName
	end
	
	return "sound/" .. fileName
end

function SlashCo.AudioSystem.ShouldPlayBackgroundMusic()
	return GetGlobal2Bool("SlashCo:ShouldPlayBackgroundMusic", false)
end

function SlashCo.AudioSystem.EnableBackgroundMusic(forced)
	if forced then
		SlashCo.AudioSystem.ForcedDisable = false
	end

	if SlashCo.AudioSystem.ForcedDisable then return end
	SetGlobal2Bool("SlashCo:ShouldPlayBackgroundMusic", true)
end

function SlashCo.AudioSystem.DisableBackgroundMusic(forced)
	SetGlobal2Bool("SlashCo:ShouldPlayBackgroundMusic", false)
	SlashCo.AudioSystem.ForcedDisable = forced or false
end

function SlashCo.AudioSystem.SetBackgroundMusic(soundFile, volume)
	SetGlobal2String("SlashCo:BackgroundMusic", soundFile)
	SetGlobal2Float("SlashCo:BackgroundMusicVolume", volume or 1)
	SetGlobal2Int("SlashCo:StartTimeBackgroundMusic", engine.TickCount()) -- Timestamp to syncronize the music for everyone

	if SlashCo.DisableSoundScapes then
		--SlashCo.DisableSoundScapes() -- disable sound scapes.
	end
end

function SlashCo.AudioSystem.GetBackgroundMusic(fallBack)
	return GetGlobal2String("SlashCo:BackgroundMusic", fallBack or "")
end

function SlashCo.AudioSystem.SetBackgroundMusicVolume(volume)
	SetGlobal2Float("SlashCo:BackgroundMusicVolume", volume or 1)
end

function SlashCo.AudioSystem.GetBackgroundMusicVolume(fallBack)
	return GetGlobal2Float("SlashCo:BackgroundMusicVolume", fallBack or 1)
end

function SlashCo.AudioSystem.SetBackgroundMusicPlaybackRate(playbackrate)
	SetGlobal2Float("SlashCo:BackgroundMusicPlaybackRate", playbackrate or 1)
end

function SlashCo.AudioSystem.GetBackgroundMusicPlaybackRate(fallBack)
	return GetGlobal2Float("SlashCo:BackgroundMusicPlaybackRate", playbackrate or 1)
end

function SlashCo.AudioSystem.RegisterSound(registerName, soundTable)
	SlashCo.AudioSystem.RegisteredSounds[registerName] = soundTable
end

-- Creates a copy of the given table.
-- We don't care about any userdata since our soundTable should have none at all.
local function CopyTable(input, references)
	local output = {}
	references = references or {} -- to prevent loops
	if references[input] then
		print("CopyTable was called with looping references!")
		return output
	end
	references[input] = true

	for key, value in pairs(input) do
		if type(value) == "table" then
			output[key] = CopyTable(value, references)
		else
			output[key] = value
		end
	end

	return output
end

-- Returns a copy of the soundTable that can freely be modified and used, or returns nil if no sound was registered with the given name
function SlashCo.AudioSystem.GetRegisteredSound(registerName)
	local soundTable = SlashCo.AudioSystem.RegisteredSounds[registerName]
	if not soundTable then
		return nil -- There is no song registered with this name
	end

	return CopyTable(soundTable)
end

function SlashCo.AudioSystem.PrecacheSound(soundFile)
	-- ToDo
end

--[[
	Helper function calculating the tickcount for when you're using the startTick field on PlaySound.
	If given no baseTick it will result in it using the current tickcount.
	give it a baseTick of 0 to just get the calculation of the time as ticks.
	The input time should be a timepoint in the song like 10 for 10 seconds into the song.
]]
function SlashCo.AudioSystem.TimeToTick(time, baseTick)
	local tickTime = time > 0 and (time / engine.TickInterval()) or 0
	baseTick = baseTick or engine.TickCount()
	if baseTick == 0 then
		return tickTime
	end

	return baseTick - tickTime
end

-- Looks up a sound by name registered using sound.Add and select one of its sound files randomly
function SlashCo.AudioSystem.GetSoundFileFromSource(name)
	local info = sound.GetProperties(name)
	if not info then return end
	if not info.sound then return end

	local soundFile = nil
	if isstring(info.sound) then
		soundFile = info.sound
	end

	if istable(info.sound) then
		soundFile = info.sound[math.random(1, #info.sound)]
	end
	
	if soundFile then
		return (soundFile:StartsWith("(") or soundFile:StartsWith(")")) and soundFile:sub(2) or soundFile
	end
end

--[[
	This will try to guess what the soundPath is
	It could be a Sound from sound.Add
	or a wildcard to a folder
	But this is expensive!

	returns string, bool

	if bool == true then it means it expects a random result due to it being a wildcard!
]]
function SlashCo.AudioSystem.ResolveSoundPath(soundPath)
	soundPath = SlashCo.AudioSystem.ToSound(soundPath)
	local resolveCache = SlashCo.AudioSystem.ResolveCache[soundPath]
	if resolveCache == nil then
		local found = string.find(soundPath, "*")
		local info = sound.GetProperties(soundPath)
		if info then
			resolveCache = info.sound or {}
			goto done
		end

		if found then
			local files, folders = file.Find(soundPath, "GAME")
			local lastSlash = string.find(soundPath, "/")
			local dir = string.match(soundPath, "^(.*)/[^/]*$") or ""
			for idx, fileName in pairs(files) do
				files[idx] = dir ~= "" and (dir .. "/" .. fileName) or fileName
			end

			resolveCache = files
		else
			resolveCache = file.Exists(soundPath, "GAME")
		end

		::done::

		SlashCo.AudioSystem.ResolveCache[soundPath] = resolveCache
	end

	if resolveCache == false then
		return nil, false
	end

	if resolveCache == true then
		return soundPath, false
	end

	if istable(resolveCache) and #resolveCache > 0 then
		if #resolveCache == 1 then
			return resolveCache[1], false
		end

		return resolveCache[math.random(1, #resolveCache)], true
	end

	return nil, false
end

-- Server & client files are loaded at last
if SERVER then
	include("sv_audiosystem.lua")
	AddCSLuaFile("cl_audiosystem.lua")
	AddCSLuaFile()
else
	include("cl_audiosystem.lua")
end