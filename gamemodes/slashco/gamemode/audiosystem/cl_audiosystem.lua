SlashCo.AudioSystem.Channels = SlashCo.AudioSystem.Channels or {} -- All IGModAudioChannel instances, use pairs to iterate as it will have holes.
SlashCo.AudioSystem.ParentedChannels = SlashCo.AudioSystem.ParentedChannels or {}
SlashCo.AudioSystem.PrecacheSounds = SlashCo.AudioSystem.PrecacheSounds or {}
SlashCo.AudioSystem.BackgroundChannel = SlashCo.AudioSystem.BackgroundChannel or nil
SlashCo.AudioSystem.ChannelIDs = SlashCo.AudioSystem.ChannelIDs or 0 -- Incremental number to assign channel id's

--[[local slashco_enable_backgroundmusic = CreateClientConVar("slashco_enable_backgroundmusic", "1", true, false)

function SlashCo.AudioSystem.ShouldPlayBackgroundMusic()
	if not slashco_enable_backgroundmusic:GetBool() then return false end -- Client wants to not hear any music.

	return GetGlobal2Bool("SlashCo:ShouldPlayBackgroundMusic", false)
end]]

-- Strips away any spaces & adds the additional stuff.
local function AppendMode(mode, addition)
	return mode:Trim() .. " " .. addition
end

function SlashCo.AudioSystem.NukeChannels()
	for channel, _ in pairs(SlashCo.AudioSystem.Channels) do
		SlashCo.AudioSystem.DestroyChannel(channel, 1)
	end

	for _, precacheData in pairs(SlashCo.AudioSystem.PrecacheSounds) do
		precacheData.channel:__gc()
	end

	SlashCo.AudioSystem.BackgroundChannel = nil
end

-- Removes any invalid channels in case stop sound was executed.
function SlashCo.AudioSystem.CheckChannels()
	for channel, channelData in pairs(SlashCo.AudioSystem.Channels) do
		if not IsValid(channel) then
			SlashCo.AudioSystem.Channels[channel] = nil
		end
	end
end

function SlashCo.AudioSystem.GetChannelID(channel)
	return SlashCo.AudioSystem.Channels[channel].ID
end

-- NOTE: The callback is not called if the channel wasn't created.
function SlashCo.AudioSystem.CreateChannel(soundFile, mode, callback)
	if not soundFile or soundFile == "" then return end

	soundFile = SlashCo.AudioSystem.ToSound(soundFile)
	if not soundFile:find(".", 1, true) then -- It has no fileName?!? We shall deny this request.
		error("[SlashCo] Tried to use a invalid sound file! (" .. soundFile .. ")")
		return
	end

	sound.PlayFile(soundFile, mode, function(channel, errCode, errStr)
		if not IsValid(channel) then
			error("[SlashCo] Failed to create audio channel! (" .. errCode .. ", " .. errStr .. "," .. soundFile .. ")\n")
			return
		end

		SlashCo.AudioSystem.CheckChannels()
		SlashCo.AudioSystem.ChannelIDs = SlashCo.AudioSystem.ChannelIDs + 1
		SlashCo.AudioSystem.Channels[channel] = { -- ToDo: Actually implement this logic
			deleteWhenFinished = false,
			ID = SlashCo.AudioSystem.ChannelIDs,
		}
		callback(channel)
	end)
end

function SlashCo.AudioSystem.SetChannelIdentifier(channel, identifier)
	SlashCo.AudioSystem.Channels[channel].identifier = identifier
end

function SlashCo.AudioSystem.GetChannelByIdentifier(identifier)
	for channel, channelData in pairs(SlashCo.AudioSystem.Channels) do
		if channelData.identifier == identifier then
			return channel
		end
	end

	return nil
end

-- Precaches a sound that can then be played using the given identifier
function SlashCo.AudioSystem.PrecacheSound(soundFile, mode, identifier, callback)
	local existingPrecacheData = SlashCo.AudioSystem.PrecacheSounds[identifier]
	if existingPrecacheData and IsValid(existingPrecacheData.channel) then
		existingPrecacheData.channel:__gc()
	end

	local precacheData = {
		mode = AppendMode(mode, "noplay"),
		soundFile = SlashCo.AudioSystem.ToSound(soundFile),
		channel = nil,
		creating = true, -- Were creating the channel.
	}
	SlashCo.AudioSystem.PrecacheSounds[identifier] = precacheData

	SlashCo.AudioSystem.CreateChannel(precacheData.soundFile, precacheData.mode, function(channel)
		precacheData.channel = channel
		precacheData.creating = false

		if callback then
			callback(channel)
		end
	end)
end

-- Returns the given precached channel using the identifier, returns nil on failure. If given a callback, it will use that function which will be more reliable.
function SlashCo.AudioSystem.GetPrecachedChannel(identifier, callback, precacheData)
	local precacheData = SlashCo.AudioSystem.PrecacheSounds[identifier]
	if not precacheData then
		if precacheData then
			SlashCo.AudioSystem.PrecacheSound(precacheData.soundFile, precacheData.mode, identifier, function(channel)
				if callback then
					callback(channel)
				end
			end)
		end

		return
	end

	if not IsValid(precacheData.channel) then -- The channel got invalidated somehow, lets recreate it.
		precacheData.creating = true
		SlashCo.AudioSystem.CreateChannel(precacheData.soundFile, precacheData.mode, function(channel)
			precacheData.channel = channel
			precacheData.creating = false

			if callback then
				callback(channel)
			end
		end)
		return
	end

	if callback then
		callback(precacheData.channel)
	else
		return precacheData.channel
	end
end

-- This causes the channel to follow the entities position, BUT the channel WONT be removed if the entity is removed.
function SlashCo.AudioSystem.ParentChannelToEntity(channel, entity)
	local entityIndex = 0
	if isnumber(entity) then
		entityIndex = entity
		entity = nil
	else
		entityIndex = entity:EntIndex()
		if not IsValid(entity) then
			entity = nil
		end
	end

	SlashCo.AudioSystem.ParentedChannels[channel] = {
		ent = entity,
		entIndex = entityIndex,
	}
end

-- Fades out and destroys the channel.
function SlashCo.AudioSystem.DestroyChannel(channel, fadeOutTime)
	if IsValid(channel) and channel:GetState() == GMOD_CHANNEL_PLAYING then
		local vol = channel:GetVolume()
		if vol > 0 then
			local id = SlashCo.AudioSystem.GetChannelID(channel)
			timer.Remove("SlashCo:FadeInAudioChannel" .. id) -- Remove any fadeIn timer that might exist
			local timerName = "SlashCo:ShutdownAudioChannel" .. id
			local updateFreq = 0.05
			local volumeDecrement = vol / math.ceil(fadeOutTime / updateFreq)
			timer.Create(timerName, updateFreq, 0, function() -- Let the sound fade away
				if !IsValid(channel) or vol <= 0 then
					timer.Remove(timerName)
					channel:Stop()
					SlashCo.AudioSystem.CheckChannels()
					SlashCo.AudioSystem.Channels[channel] = nil
					SlashCo.AudioSystem.ParentedChannels[channel] = nil
					return
				end

				vol = channel:GetVolume() - volumeDecrement
				channel:SetVolume(vol)
			end)

			return
		end
	end

	SlashCo.AudioSystem.CheckChannels()
	SlashCo.AudioSystem.Channels[channel] = nil
	SlashCo.AudioSystem.ParentedChannels[channel] = nil
end

function SlashCo.AudioSystem.EnsureValidVolume(volume)
	if volume == volume then -- if its not nan, we can say its safe
		return volume
	end

	return 0 -- math.Clamp(volume, -10, 10) -- We return 0 as else if it would clamp to 10 it could errape the client.
end

-- Fades the channel's volume to the target volume.
function SlashCo.AudioSystem.FadeTo(channel, fadeInTime, targetVol)
	targetVol = targetVol or 1
	fadeInTime = fadeInTime or 1

	local vol = SlashCo.AudioSystem.EnsureValidVolume(channel:GetVolume())
	local lowerVol = targetVol < vol
	local id = SlashCo.AudioSystem.GetChannelID(channel)
	local timerName = "SlashCo:FadeInAudioChannel" .. id
	local updateFreq = 0.05
	local volumeIncrement = math.abs(targetVol - vol) / math.ceil(fadeInTime / updateFreq)
	timer.Create(timerName, updateFreq, 0, function() -- Let the sound fade away
		local reachedTarget = false
		if lowerVol then
			reachedTarget = targetVol >= vol
		else
			reachedTarget = vol >= targetVol
		end

		if !IsValid(channel) or reachedTarget then
			timer.Remove(timerName)
			return
		end

		if lowerVol then
			vol = channel:GetVolume() - volumeIncrement
		else
			vol = channel:GetVolume() + volumeIncrement
		end

		channel:SetVolume(SlashCo.AudioSystem.EnsureValidVolume(vol))
	end)
end

function SlashCo.AudioSystem.StopBackgroundMusic()
	SlashCo.AudioSystem.DestroyChannel(SlashCo.AudioSystem.BackgroundChannel, 1)
	SlashCo.AudioSystem.BackgroundChannel = nil
end

-- Returns the calculated time a channel is supposed to be at, it accounts for looping sounds
function SlashCo.AudioSystem.CalculateTime(channel, tickCount)
	local calculateTime = (engine.TickCount() - tickCount) * engine.TickInterval()
	local fileLength = channel:GetLength()
	return calculateTime - (fileLength * math.floor(calculateTime / fileLength))
end

-- Returns the current background music time syncronized with all players.
function SlashCo.AudioSystem.GetBackgroundMusicTime()
	return SlashCo.AudioSystem.CalculateTime(SlashCo.AudioSystem.BackgroundChannel, GetGlobal2Int("SlashCo:StartTimeBackgroundMusic"))
end

local lastCreation = 0 -- Doesn't need autorefresh so were fine.
function SlashCo.AudioSystem.PlayBackgroundMusic(fileName)
	if not SlashCo.AudioSystem.ShouldPlayBackgroundMusic() then return end
	if fileName == "" then
		fileName = nil
	end

	local backgroundMusic = SlashCo.AudioSystem.ToSound(fileName or SlashCo.AudioSystem.GetBackgroundMusic())
	if IsValid(SlashCo.AudioSystem.BackgroundChannel) then
		if SlashCo.AudioSystem.BackgroundChannel:GetFileName() == backgroundMusic then return end

		SlashCo.AudioSystem.StopBackgroundMusic()
	end

	if not backgroundMusic then return end

	-- Delay creations so that it won't try to create a channel while it already tried and is waiting for the callback.
	if (lastCreation + 5) > CurTime() then return end
	lastCreation = CurTime()

	SlashCo.AudioSystem.CreateChannel(backgroundMusic, "mono noplay", function(channel)
		SlashCo.AudioSystem.BackgroundChannel = channel

		channel:SetVolume(0)
		channel:Play()
		channel:EnableLooping(true)
		SlashCo.AudioSystem.BackgroundChannel:SetTime(SlashCo.AudioSystem.GetBackgroundMusicTime())
		SlashCo.AudioSystem.FadeTo(channel, 5, SlashCo.AudioSystem.GetBackgroundMusicVolume())
	end)
end

-- This is a NW2 Proxy function.
local function OnBackgroundMusicChange(ent, name, old, new)
	SlashCo.AudioSystem.PlayBackgroundMusic(new)
end

-- This is a NW2 Proxy function.
local function OnBackgroundMusicStateChange(ent, name, old, new)
	if not new then
		if IsValid(SlashCo.AudioSystem.BackgroundChannel) then
			SlashCo.AudioSystem.StopBackgroundMusic()
		end
	else
		SlashCo.AudioSystem.PlayBackgroundMusic()
	end
end

local function OnBackgroundMusicVolumeChange(ent, name, old, new)
	if IsValid(SlashCo.AudioSystem.BackgroundChannel) then
		SlashCo.AudioSystem.FadeTo(SlashCo.AudioSystem.BackgroundChannel, 5, new)
	end
end

function SlashCo.AudioSystem.Init()
	local world = game.GetWorld()

	--[[
		Setting up the proxies in case the background music changes.
		then we manually call the var proxy because the NW2Vars at this point were already networked so our proxy won't catch the initial value.
	]]
	world:SetNW2VarProxy("SlashCo:BackgroundMusic", OnBackgroundMusicChange)
	OnBackgroundMusicChange(world, "SlashCo:BackgroundMusic", nil, SlashCo.AudioSystem.GetBackgroundMusic())

	world:SetNW2VarProxy("SlashCo:ShouldPlayBackgroundMusic", OnBackgroundMusicStateChange)
	OnBackgroundMusicStateChange(world, "SlashCo:ShouldPlayBackgroundMusic", nil, SlashCo.AudioSystem.ShouldPlayBackgroundMusic())

	world:SetNW2VarProxy("SlashCo:BackgroundMusicVolume", OnBackgroundMusicVolumeChange)
	OnBackgroundMusicVolumeChange(world, "SlashCo:BackgroundMusicVolume", nil, SlashCo.AudioSystem.GetBackgroundMusicVolume())
end

hook.Add("InitPostEntity", "SlashCo:AudioSystem", SlashCo.AudioSystem.Init)
if game.GetWorld() != NULL then
	SlashCo.AudioSystem.Init()
end

local function UpdateBackgroundMusic()
	if not SlashCo.AudioSystem.ShouldPlayBackgroundMusic() then return end

	if not IsValid(SlashCo.AudioSystem.BackgroundChannel) then
		SlashCo.AudioSystem.PlayBackgroundMusic()
	else
		if SlashCo.AudioSystem.BackgroundChannel:GetState() != GMOD_CHANNEL_PLAYING then -- Fk stopsound
			SlashCo.AudioSystem.BackgroundChannel:Play()
		end

		local backgroundMusicTime = SlashCo.AudioSystem.GetBackgroundMusicTime()
		if not math.IsNearlyEqual(SlashCo.AudioSystem.BackgroundChannel:GetTime(), backgroundMusicTime, 1) and not GameData.IsSinglePlayer then -- Allow a tolerance of 1 second difference, if were in single player we don't care.
			SlashCo.AudioSystem.BackgroundChannel:SetTime(backgroundMusicTime)
		end
	end
end

local function UpdateChannelPositions()
	for channel, entTbl in pairs(SlashCo.AudioSystem.ParentedChannels) do
		--[[
			Why don't we remove the channel if the parent is gone?
			Because on full updates, the parent might disappear and then reappear.
		]]
		local ent = entTbl.ent or Entity(entTbl.entIndex)
		if not IsValid(ent) then continue end

		entTbl.ent = ent -- In case for some reason the entity didn't exist yet, could happen on full updates?
		channel:SetPos(ent:GetPos())
	end
end

function SlashCo.AudioSystem.Think()
	UpdateBackgroundMusic()
	UpdateChannelPositions()
end

hook.Add("Think", "SlashCo:AudioSystem", SlashCo.AudioSystem.Think)

--[[
	The soundData table contains all values to create and configure a channel.
	Required fields:
		string soundPath - the sound path for the sound to play.

	Optional fields:
		number soundLevel - used to calculate a distance for when the sound fades and cannot be heard from.
		string identifier - The identifier of the sound, if nil it will use the soundPath field as the identifier
		number startTick - The tick in which the sound was started, this value is used to syncronize the sound for all players. Defaults to the current tick
		Entity entity - The entity the channel should follow, defaults to the world entity.
		number volume - The volume of the sound, defaults to 1
		boolean looping - If the sound should be looped or not, defaults to false
		function callback - the callback function that is called when the channel was created. The channel is given to the callback as the first argument
		number minDistance - The minimum distance for the sound to start fading
		number maxDistance - The maximum distance after which the sound cannot be heard anymore.
		Vector position - A position to play the sound from, be aware that if a entity is set it will override this position!
		string modes - Any additional modes to pass to SlashCo.AudioSystem.CreateChannel

	Notes:
		When the entity is set to the world, the sound is played as mono and NOT 3d!
]]
function SlashCo.AudioSystem.PlaySound(soundData)
	soundData.identifier = soundData.identifier or soundData.soundPath
	soundData.startTick = soundData.startTick or engine.TickCount()
	soundData.entity = soundData.entity or game.GetWorld()
	soundData.volume = soundData.volume or 1
	soundData.looping = soundData.looping or false
	soundData.modes = soundData.modes or ""

	SlashCo.AudioSystem.StopSound(soundData.identifier, 0.5)

	local entIndex = isnumber(soundData.entity) and soundData.entity or (IsValid(soundData.entity) and soundData.entity:EntIndex() or 0)
	local useMono = entIndex == 0 and not soundData.position
	SlashCo.AudioSystem.CreateChannel(soundData.soundPath, AppendMode(useMono and "mono" or "3d", soundData.modes), function(channel)
		if soundData.fadeIn and soundData.fadeIn != 0 then
			channel:SetVolume(0)
		else
			channel:SetVolume(soundData.volume)
		end

		channel:Play()
		channel:EnableLooping(soundData.looping)
		channel:SetTime(SlashCo.AudioSystem.CalculateTime(channel, soundData.startTick))

		if soundData.identifier then
			SlashCo.AudioSystem.SetChannelIdentifier(channel, soundData.identifier)
		end

		if soundData.fadeIn and soundData.fadeIn != 0 then
			SlashCo.AudioSystem.FadeTo(channel, soundData.fadeIn, soundData.volume)
		end

		if entIndex != 0 then
			SlashCo.AudioSystem.ParentChannelToEntity(channel, entIndex)
		end

		if soundData.position then
			channel:SetPos(soundData.position)
		end

		if soundData.soundLevel and soundData.soundLevel != 0 then
			channel:Set3DFadeDistance(soundData.soundLevel ^ 1.25, soundData.soundLevel ^ 1.5)
		end

		if soundData.minDistance and soundData.maxDistance then
			channel:Set3DFadeDistance(soundData.minDistance, soundData.maxDistance)
		end

		if soundData.callback then
			soundData.callback(channel)
		end
	end)
end

-- Returns all channels that were parented to the given entity.
function SlashCo.AudioSystem.GetEntityChannels(entity)
	local entIndex = -1
	if IsValid(entity) then
		entIndex = entity:EntIndex()
	elseif isnumber(entity) then
		entIndex = entity
	end

	if entIndex == -1 then
		error("Invalid entity was given to us. It must be a Entity or a Entity Index!")
		return
	end

	local results = {}
	for channel, entTbl in pairs(SlashCo.AudioSystem.ParentedChannels) do
		if entTbl.entIndex ~= entIndex then continue end
		
		table.insert(results, channel)
	end

	return results
end

--[[
	Stops the sound by the given identifier.
	If given no identifier and no entity, it will stop all sounds globally.
	If given no identifier and a entity, it will stop all sounds from the entity.
]]
function SlashCo.AudioSystem.StopSound(identifier, fadeOut, entIndex)
	fadeOut = fadeOut or 1

	if not identifier then -- No identifier? then we want to stop all sounds.
		if not entIndex then -- No entitiy? Then we want to stop all sounds globally.
			for channel, _ in pairs(SlashCo.AudioSystem.Channels) do
				if channel == SlashCo.AudioSystem.BackgroundChannel then continue end
				SlashCo.AudioSystem.DestroyChannel(channel, fadeOut)
			end
		else -- We got a valid entity, then we only stop all sounds from that entity.
			for _, channel in ipairs(SlashCo.AudioSystem.GetEntityChannels(entIndex)) do
				SlashCo.AudioSystem.DestroyChannel(channel, fadeOut)
			end
		end
		return
	end

	local channel = SlashCo.AudioSystem.GetChannelByIdentifier(identifier)
	if not channel then return end

	SlashCo.AudioSystem.DestroyChannel(channel, fadeOut)
end

--[[
	Helper function to read fields even if they are nil values.
	Serverside we network a bool and then the value, the bool is true if the field was nil.
]]
local function ReadSoundField(readFunc, ...)
	local isNil = net.ReadBool(isNil)
	if not isNil then
		return readFunc(...)
	end

	return nil
end

net.Receive("slashCo_AudioSystem_PlaySound", function()
	local soundData = {
		soundPath = ReadSoundField(net.ReadString),
		entIndex = ReadSoundField(net.ReadUInt, MAX_EDICT_BITS),
		soundLevel = ReadSoundField(net.ReadUInt, 14),
		volume = ReadSoundField(net.ReadFloat),
		looping = ReadSoundField(net.ReadBool),
		fadeIn = ReadSoundField(net.ReadFloat),
		tickCount = ReadSoundField(net.ReadUInt, 32),
		identifier = ReadSoundField(net.ReadString),
		minDistance = ReadSoundField(net.ReadUInt, 16),
		maxDistance = ReadSoundField(net.ReadUInt, 16),
		modes = ReadSoundField(net.ReadString),
	}

	SlashCo.AudioSystem.PlaySound(soundData)
end)

net.Receive("slashCo_AudioSystem_StopSound", function()
	local stopAllSounds = net.ReadBool()
	local identifier = nil
	if not stopAllSounds then
		identifier = net.ReadString()
	end
	local fadeOut = net.ReadFloat()
	local entIndex = nil
	if net.ReadBool() then
		entIndex = net.ReadUInt(MAX_EDICT_BITS)
	end

	SlashCo.AudioSystem.StopSound(identifier, fadeOut, entIndex)
end)