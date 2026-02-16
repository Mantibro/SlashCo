SlashCo.AudioSystem.Channels = SlashCo.AudioSystem.Channels or {} -- All IGModAudioChannel instances, use pairs to iterate as it will have holes.
SlashCo.AudioSystem.CreatingChannels = SlashCo.AudioSystem.CreatingChannels or {} -- Sounds that are currently being created.
SlashCo.AudioSystem.PrecacheSounds = SlashCo.AudioSystem.PrecacheSounds or {}
SlashCo.AudioSystem.DeltaSoundCache = SlashCo.AudioSystem.DeltaSoundCache or {}
SlashCo.AudioSystem.BackgroundChannel = SlashCo.AudioSystem.BackgroundChannel or nil
SlashCo.AudioSystem.ChannelIDs = SlashCo.AudioSystem.ChannelIDs or 0 -- Incremental number to assign channel id's
SlashCo.AudioSystem.UpdateFrequency = 0.05 -- How often timers execute to update the volume when fading it to a new value.
SlashCo.AudioSystem.ServerGroupVolumes = SlashCo.AudioSystem.ServerGroupVolumes or {} -- Group volume mulipliers added on top of channel volumes controlled by the server
SlashCo.AudioSystem.ClientGroupVolumes = SlashCo.AudioSystem.ClientGroupVolumes or {} -- Group volume mulipliers added on top of channel volumes controlled by the client
SlashCo.AudioSystem.ModifiedChannelGroups = SlashCo.AudioSystem.ModifiedChannelGroups or {}

-- These intentionally are nuked on autorefresh
local ErrorList = {} -- A table containing all the files we failed to open, if the file is in this list and we fail loading again, then we won't throw another error.
local Fake3DList = {}
local OGGRetryList = {} -- RaphaelIT7: We remapp ogg files from the VFS to a location actually on disk as it seems like things mounted through GMA cause bass to fail?

-- So that we don't depend on the GameData table as this system is meant to also work as a standalone library.
SlashCo.AudioSystem.IsSinglePlayer = SlashCo.AudioSystem.IsSinglePlayer or game.SinglePlayer()
SlashCo.AudioSystem.LocalPlayer = SlashCo.AudioSystem.LocalPlayer or nil
SlashCo.AudioSystem.LocalEntIndex = SlashCo.AudioSystem.LocalEntIndex or -1
SlashCo.AudioSystem.ValidLocalPlayer = IsValid(SlashCo.AudioSystem.LocalPlayer)

--[[local slashco_enable_backgroundmusic = CreateClientConVar("slashco_enable_backgroundmusic", "1", true, false)

function SlashCo.AudioSystem.ShouldPlayBackgroundMusic()
	if not slashco_enable_backgroundmusic:GetBool() then return false end -- Client wants to not hear any music.

	return GetGlobal2Bool("SlashCo:ShouldPlayBackgroundMusic", false)
end]]

local ChannelStates = {
	OK = 1,
	DESTROYING = 2,
}

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

	SlashCo.AudioSystem.CreatingChannels = {}
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
function SlashCo.AudioSystem.CreateChannel(soundFile, mode, callback, errorCallback)
	if not soundFile or soundFile == "" then return end

	local isURL = string.find(soundFile, "://", 1, true)
	soundFile = isURL and soundFile or SlashCo.AudioSystem.ToSound(soundFile)

	if not soundFile:find(".", 1, true) then -- It has no fileName?!? We shall deny this request.
		error("[SlashCo] Tried to use a invalid sound file! (" .. soundFile .. ")")
		return
	end

	local usedOGGRemap = false
	if OGGRetryList[soundFile] then
		soundFile = OGGRetryList[soundFile]
		usedOGGRemap = true
	end

	local soundFunc = isURL and sound.PlayURL or sound.PlayFile
	soundFunc(soundFile, mode, function(channel, errCode, errStr)
		if not IsValid(channel) then
			if errorCallback then
				-- an error callback can return true to cancel us throwing an error
				if errorCallback(errCode, errStr) then return end
			end
			
			if not ErrorList[soundFile] then
				ErrorList[soundFile] = true

				-- RaphaelIT7: This one specific OGG issue >:(
				if string.EndsWith(soundFile, ".ogg") and errStr == "BASS_ERROR_FILEFORM" and OGGRetryList[soundFile] == nil then
					local folderName = soundFile
					local lastSlash = string.find(folderName, "/")
					local currentSlash = lastSlash
					while currentSlash do
						lastSlash = currentSlash
						currentSlash = string.find(folderName, "/", currentSlash + 1)
					end

					if lastSlash then
						folderName = string.sub(folderName, 0, lastSlash)
					end

					-- RaphaelIT7: Let's write the file to disk to avoid VFS issues
					file.CreateDir("slashco_oggcache/" .. folderName)

					local oggRetryName = "slashco_oggcache/" .. soundFile
					file.Write(oggRetryName, file.Read(soundFile, "GAME"))

					oggRetryName = "data/" .. oggRetryName
					OGGRetryList[soundFile] = oggRetryName
					OGGRetryList[oggRetryName] = soundFile
					
					SlashCo.AudioSystem.CreateChannel(soundFile, mode, callback, errorCallback)
					return
				end

				-- RaphaelIT7: Temporary debug stuff for Rubat.
				local size = file.Size(soundFile, "GAME")
				local content = file.Read(soundFile, "GAME")
				ErrorNoHaltWithStack("[SlashCo] Failed to create audio channel! (" .. errCode .. ", " .. errStr .. ", " .. soundFile .. " | Debug Info: BRANCH:" .. tostring(BRANCH) .. " File Size:" .. tostring(size or -1) .. " File Content Size:" .. tostring(content and string.len(content) or -1) .. " File Content Hash:" .. (content and util.CRC(content) or "[no content]") .. "\n")
			end
			return
		else
			if usedOGGRemap and game.IsDedicated() then -- RapahelIT7: Let me find this in the server logs
				local size = file.Size(soundFile, "GAME")
				local content = file.Read(soundFile, "GAME")
				local VFSsize = file.Size(OGGRetryList[soundFile], "GAME")
				local VFScontent = file.Read(OGGRetryList[soundFile], "GAME")
				ErrorNoHaltWithStack(
					"(Debug message - ignore this) Managed to play previously failing OGG file from disk! (" .. soundFile .. ") | Debug Info: "
					.. " Branch:" .. tostring(BRANCH)
					.. "File Size:["
					.. tostring(size or -1) .. "/" .. tostring(VFSsize or -1) ..
					"] File Content Size:"
					.. tostring(content and string.len(content) or -1) .. "/" .. tostring(VFScontent and string.len(VFScontent) or -1) ..
					" File Content Hash:"
					.. (content and util.CRC(content) or "[no content]") .. "/" .. (VFScontent and util.CRC(VFScontent) or "[no content]") .. "\n"
				)
			end
		end

		SlashCo.AudioSystem.CheckChannels()
		SlashCo.AudioSystem.ChannelIDs = SlashCo.AudioSystem.ChannelIDs + 1
		local channelData = {
			ID = SlashCo.AudioSystem.ChannelIDs,
			State = ChannelStates.OK,
			isURL = isURL,
			is3D = channel:Is3D(),
		}
		SlashCo.AudioSystem.Channels[channel] = channelData
		callback(channel, channelData)
	end)
end

function SlashCo.AudioSystem.SetChannelIdentifier(channel, identifier)
	SlashCo.AudioSystem.Channels[channel].identifier = identifier
end

function SlashCo.AudioSystem.GetChannelByIdentifier(identifier, entIndex)
	for channel, channelData in pairs(SlashCo.AudioSystem.Channels) do
		if channelData.identifier == identifier and channelData.State == ChannelStates.OK then
			return channel
		end
	end

	return nil
end

-- Precaches a sound that can then be played using the given identifier
-- ToDo: Switch this function over to use PlaySound instead of implementing the logic itself again.
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

		SlashCo.AudioSystem.SetChannelIdentifier(channel, identifier)
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

function SlashCo.AudioSystem.PlayPrecachedChannel(identifier)
	SlashCo.AudioSystem.GetPrecachedChannel(identifier, function(channel)
		channel:Play()
	end)
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

	local channelData = SlashCo.AudioSystem.Channels[channel]
	channelData.ent = entity
	channelData.entIndex = entityIndex
end

--[[
	BUG: Bass doesn't seem to care about 3DFadeDistance and it seems like it never actually fades out for some weird reason. So we calculate and set the volume ourself.
	Anyways, doing it like this we have more control :3

	How we currently do it:

	Distance →
	0      startDistance   startEndDistance    minDistance        maxDistance       ∞
	|────────────┬─────────────────┬──────────────┬────────────────┬──────────────→
	|  Silent    │    Fade In →    │   Full Vol   │   Fade Out ↓   │     Silent
	|            │ (0 → 100% vol)  │    (100%)    │ (100% → 0)     │

	if no startDistance or no startEndDistance is set, the initial Silent zone won't exist.
	if no minDistance or no maxDistance is set, the final Silent zone won't exist.
]]
local function CalculateChannelFadeVolume(playerPos, channelPos, initialVolume, soundData)
	local distance = channelPos:Distance(playerPos)

	local startDistance = soundData.startDistance
	local startEndDistance = soundData.startEndDistance
	if startDistance and startEndDistance then
		if distance < startDistance then
			return 0
		end

		if distance < startEndDistance then
			return initialVolume * (1 - ((distance - startEndDistance) / (startDistance - startEndDistance)))
		end
	end

	local minDistance = soundData.minDistance
	local maxDistance = soundData.maxDistance
	if minDistance and maxDistance then
		if distance <= minDistance then
			return initialVolume
		end

		if distance < maxDistance then
			return initialVolume * (1 - ((distance - minDistance) / (maxDistance - minDistance)))
		end

		if distance >= maxDistance then
			return 0
		end
	end

	return initialVolume
end

local fallbackPosition = Vector(0, 0, 0)
local function GetLocalPlayerPosition() -- We can get net messages received before the local player is valid, so we fallback to the world origin until them.
	return SlashCo.AudioSystem.ValidLocalPlayer and SlashCo.AudioSystem.LocalPlayer:EyePos() or fallbackPosition
end

local function ReflectRay(incident, normal)
	return incident - 2 * incident:Dot(normal) * normal
end

local function BounceRay(trace, playerPos, debugDraw, inDir, bounces)
	local tr = trace
	local totalBounces = bounces
	for k=1, bounces do -- Time to make some ray's bounce.
		local incidentDir = k == 1 and inDir or (tr.HitPos - tr.StartPos):GetNormalized()
		local bounceDir = ReflectRay(incidentDir, tr.HitNormal)
		bounceDir:Mul(1000)
		tr = util.TraceLine({
			start = tr.HitPos,
			endpos = tr.HitPos + bounceDir,
			filter = filterEnts,
			mask = MASK_VISIBLE_AND_NPCS,
			collisiongroup = COLLISION_GROUP_INTERACTIVE
		})

		--print(tr.StartPos, engine.TickCount(), bounceDir, incidentDir)

		if debugDraw then
			debugoverlay.Line(tr.StartPos, tr.HitPos, 1, Color(255, 0, 0))
			debugoverlay.Axis(tr.HitPos, tr.HitNormal:Angle(), 10)
		end

		local playerTR = util.TraceLine({
			start = tr.HitPos,
			endpos = playerPos,
			filter = filterEnts,
			mask = MASK_VISIBLE_AND_NPCS,
			collisiongroup = COLLISION_GROUP_WORLD
		})

		if not playerTR.Hit then
			if debugDraw then
				debugoverlay.Line(tr.HitPos, playerPos - Vector(0, 0, 20), 1, Color(0, 255, 0)) -- We offset playerPos since else it's difficult to see
				debugoverlay.Axis(tr.HitPos, tr.HitNormal:Angle(), 10, 1)
			end

			return tr, k, playerTR
		end
	end

	return tr, totalBounces
end

local function RotateDirection(direction, angleDegrees, axis)
	local ang = direction:Angle()
	ang:RotateAroundAxis(axis, angleDegrees)
	return ang:Forward()
end

--[[ This doesn't achieve great results :/

local raytraceVectors = {}
local raytraceYawSteps = 8
local raytracePitchSteps = 6
local raytraceBaseDir = Vector(1, 1, 1)
local raytraceVec001 = Vector(0, 0, 1)
for yaw = -60, 60, 120 / raytraceYawSteps do
	for pitch = -30, 30, 60 / raytracePitchSteps do
		local dir = RotateDirection(raytraceBaseDir, yaw, raytraceVec001)
		dir = RotateDirection(dir, pitch, dir:Cross(raytraceVec001))
		table.insert(raytraceVectors, dir)
	end
end]]

local function AverageVectors(vectors)
	local sum = Vector(0, 0, 0)
	if #vectors == 0 then
		return sum
	end

	for _, vec in ipairs(vectors) do
		sum = sum + vec
	end

	return sum / #vectors
end

local nextDebugDraw = 0
local function CalculateRayTracedVolume(channel, channelData, soundData, channelPos, playerPos, initialVolume)
	if not soundData.raytraced or initialVolume <= 0 then
		return initialVolume
	end

	local filterEnts = {channelData.ent, SlashCo.AudioSystem.LocalPlayer}
	local tr = util.TraceLine({
		start = channelPos,
		endpos = playerPos,
		filter = filterEnts,
		mask = MASK_VISIBLE_AND_NPCS,
		collisiongroup = COLLISION_GROUP_INTERACTIVE
	})

	if not tr.Hit then
		return initialVolume
	end

	local debugDraw = nextDebugDraw < CurTime()
	if debugDraw then
		--debugoverlay.Line(tr.StartPos, tr.HitPos, 1)
		--debugoverlay.Axis(tr.HitPos, tr.HitNormal:Angle(), 10)
		nextDebugDraw = CurTime() + 0.1
	end

	local raytraceVectors = {}
	local raytraceYawSteps = 12
	local raytracePitchSteps = 8
	local raytraceBaseDir = (playerPos - channelPos):GetNormalized()
	local raytraceVec001 = Vector(0, 0, 1)
	for yaw = -60, 60, 120 / raytraceYawSteps do
		for pitch = -30, 30, 60 / raytracePitchSteps do
			local dir = RotateDirection(raytraceBaseDir, yaw, raytraceVec001)
			dir = RotateDirection(dir, pitch, dir:Cross(raytraceVec001))
			table.insert(raytraceVectors, dir)
		end
	end

	local hitPos = {} -- We contain all traces that managed to reach the player
	local totalBounces = 8
	local shortestBounce = totalBounces
	tr.HitPos = channelPos
	for _, dir in ipairs(raytraceVectors) do
		local tr = util.TraceLine({
			start = channelPos,
			endpos = channelPos + dir * 1000,
			filter = filterEnts,
			mask = MASK_VISIBLE_AND_NPCS,
			collisiongroup = COLLISION_GROUP_INTERACTIVE
		})

		local tr, totalBounces, playerTR = BounceRay(tr, playerPos, debugDraw, dir, totalBounces)
		if shortestBounce > totalBounces then
			shortestBounce = totalBounces
		end

		if playerTR then
			table.insert(hitPos, playerTR.StartPos)
			--debugoverlay.Sphere(playerTR.StartPos, 10, 1, Color(0, 0, 255), true)
		end
	end

	--print(initialVolume - ((totalBounces - (totalBounces - shortestBounce)) / 10), LerpVector(0.5, channelPos, AverageVectors(hitPos)))
	if #hitPos > 0 then
		channelData.raytracedTarget = LerpVector(0.75, channelPos, AverageVectors(hitPos)) -- We lerp all hit traces into one and change the channel position giving the illusion that the audio source moved.
	end

	channelData.raytracedPos = LerpVector(0.05, channelData.raytracedPos or channelData.pos, channelData.raytracedTarget or channelData.pos)
	channelData.pos = channelData.raytracedPos -- We can't save it in .pos since it's reset every frame

	local vol = CalculateChannelFadeVolume(playerPos, channelData.pos, initialVolume, soundData)
	initialVolume = initialVolume - (initialVolume - vol) -- Not perfect but it helps against stopping it from jumping up in volume since the distance changes

	if debugDraw then
		debugoverlay.Sphere(channelData.pos, 10, 1, Color(0, 0, 255), true)
	end

	return math.max(initialVolume - ((totalBounces - (totalBounces - shortestBounce)) / 10), 0)
end

local function AddModifyChannelGroup(channel, channelData)
	if not channelData.modifyGroups or not channelData.modifyGroupVolumeMult then return end

	for _, name in ipairs(channelData.modifyGroups) do
		local groupTbl = SlashCo.AudioSystem.ModifiedChannelGroups[name]
		if not groupTbl then
			groupTbl = {}
			SlashCo.AudioSystem.ModifiedChannelGroups[name] = groupTbl
		end

		groupTbl[channel] = true
		if (groupTbl.modifyGroupVolumeMult or 99) > channelData.modifyGroupVolumeMult then
			groupTbl.modifyGroupVolumeMult = channelData.modifyGroupVolumeMult
		end
	end
end

local function RemoveModifyChannelGroup(channel, channelData)
	if not channelData.modifyGroups then return end

	for _, name in ipairs(channelData.modifyGroups) do
		local groupTbl = SlashCo.AudioSystem.ModifiedChannelGroups[name]
		if not groupTbl then continue end

		groupTbl[channel] = nil
		if (groupTbl.modifyGroupVolumeMult or 99) == channelData.modifyGroupVolumeMult then
			-- We were the one enforcing, so now we gotta find someone else.
			groupTbl.modifyGroupVolumeMult = 99
			local found = false
			for otherChannel, val in pairs(groupTbl) do
				if not isbool(val) or not IsValid(otherChannel) then continue end

				local otherChannelData = SlashCo.AudioSystem.Channels[otherChannel]
				if not otherChannelData or not otherChannelData.modifyGroupVolumeMult then continue end

				if groupTbl.modifyGroupVolumeMult > otherChannelData.modifyGroupVolumeMult then
					groupTbl.modifyGroupVolumeMult = otherChannelData.modifyGroupVolumeMult
				end
			end

			if not found then
				-- Found no alternative? Nuke group.
				SlashCo.AudioSystem.ModifiedChannelGroups[name] = nil
			end
		end
	end
end

-- Helper function to wrap around CalculateChannelFadeVolume
local function CalculateChannelVolume(channel, targetVol)
	local channelData = SlashCo.AudioSystem.Channels[channel]
	if channelData.group then
		local modifyGroupTbl = SlashCo.AudioSystem.ModifiedChannelGroups[channelData.group]
		if modifyGroupTbl then
			targetVol = targetVol * modifyGroupTbl.modifyGroupVolumeMult
		end
	end

	if channelData.is3D or channelData.pos then
		local soundData = channelData.soundData
		if soundData then
			local playerPos = GetLocalPlayerPosition()
			local channelPos = channelData.pos or channel:GetPos()
			local volume = CalculateChannelFadeVolume(playerPos, channelPos, targetVol, soundData)
			volume = CalculateRayTracedVolume(channel, channelData, soundData, channelPos, playerPos, volume)

			if channelData.group then
				local serverGroupVolume = SlashCo.AudioSystem.ServerGroupVolumes[channelData.group]
				if serverGroupVolume then
					volume = volume * math.Clamp(serverGroupVolume, 0, 5)
				end

				local clientGroupVolume = SlashCo.AudioSystem.ClientGroupVolumes[channelData.group]
				if clientGroupVolume then
					volume = volume * math.Clamp(clientGroupVolume, 0, 5)
				end
			end

			return volume
		end
	end

	return targetVol
end

-- ToDo: Check if we even need this function anymore or if we fixed it unknowingly that it could become nan somehow.
function SlashCo.AudioSystem.EnsureValidVolume(volume)
	if volume == volume then -- if its not nan, we can say its safe
		return volume
	end

	return 0 -- math.Clamp(volume, -10, 10) -- We return 0 as else if it would clamp to 10 it could errape the client.
end

-- Callback called before a channel is gc'd / completely destroyed.
local function OnDestoryChannel(channel, channelData)
	if not channelData then return end -- Should never happen, though you never know.

	RemoveModifyChannelGroup(channel, channelData)
end

--[[
	Fades out and destroys the channel.
	callback = function(channelData) end
]]
function SlashCo.AudioSystem.DestroyChannel(channel, fadeOutTime, callback)
	if IsValid(channel) and channel:GetState() == GMOD_CHANNEL_PLAYING and fadeOutTime and fadeOutTime ~= 0 then
		local vol = channel:GetVolume()
		if vol > 0 then
			local id = SlashCo.AudioSystem.GetChannelID(channel)
			timer.Remove("SlashCo:FadeToVolumeAudioChannel" .. id) -- Remove any fadeIn timer that might exist
			local timerName = "SlashCo:ShutdownAudioChannel" .. id
			local updateFreq = SlashCo.AudioSystem.UpdateFrequency
			local volumeDecrement = vol / math.ceil(fadeOutTime / updateFreq)
			local channelData = SlashCo.AudioSystem.Channels[channel]
			channelData.State = ChannelStates.DESTROYING
			timer.Create(timerName, updateFreq, 0, function() -- Let the sound fade away
				if !IsValid(channel) or vol <= 0 then
					timer.Remove(timerName)
					channelData.volume = nil
					if IsValid(channel) then
						channel:Stop()

						OnDestoryChannel(channel, channelData)
						channel:__gc()
					end
					SlashCo.AudioSystem.CheckChannels()
					SlashCo.AudioSystem.Channels[channel] = nil

					if callback then
						callback(channelData)
					end
					return
				end

				vol = vol - volumeDecrement
				local channelVolume = CalculateChannelVolume(channel, vol)
				if channelVolume == 0 then
					vol = 0 -- makes deletions faster if the channel is already out of range.
				end

				channelData.volume = vol
				channel:SetVolume(SlashCo.AudioSystem.EnsureValidVolume(channelVolume))
			end)

			return
		end
	end

	if IsValid(channel) then
		OnDestoryChannel(channel, SlashCo.AudioSystem.Channels[channel])

		channel:__gc()

		if callback then
			callback(channelData)
		end
	end

	SlashCo.AudioSystem.CheckChannels()
	SlashCo.AudioSystem.Channels[channel] = nil
end

--[[
	Fades the channel's volume to the target volume.
	callback = function(channel, channelData) end

	NOTE: When called multiple times, the callback will only be called when the fade actually finishes, when its overwritten it won't be called.
]]
local function UpdateFadeToVolume(targetVol, vol, volumeIncrement, lowerVol, channelData, callback, timerName, channel, isVolume)
	local reachedTarget = false
	if lowerVol then
		reachedTarget = targetVol >= vol
	else
		reachedTarget = vol >= targetVol
	end

	if !IsValid(channel) or reachedTarget then
		if isVolume then
			channelData.volume = nil
		else
			channelData.playbackRate = nil
		end
		timer.Remove(timerName)
		if callback then
			callback(channel, channelData)
		end
		return targetVol
	end

	if lowerVol then
		vol = vol - volumeIncrement
	else
		vol = vol + volumeIncrement
	end

	if isVolume then
		local channelVolume = CalculateChannelVolume(channel, vol)
		channelData.volume = SlashCo.AudioSystem.EnsureValidVolume(channelVolume)
		channel:SetVolume(channelData.volume)
	else
		channelData.playbackRate = SlashCo.AudioSystem.EnsureValidVolume(vol)
		channel:SetPlaybackRate(channelData.playbackRate)
	end

	return vol
end

function SlashCo.AudioSystem.FadeToVolume(channel, fadeTime, targetVol, callback)
	targetVol = targetVol or 1
	fadeTime = fadeTime or 1

	local vol = SlashCo.AudioSystem.EnsureValidVolume(channel:GetVolume())
	local lowerVol = targetVol < vol
	local id = SlashCo.AudioSystem.GetChannelID(channel)
	local timerName = "SlashCo:FadeToVolumeAudioChannel" .. id
	local updateFreq = SlashCo.AudioSystem.UpdateFrequency
	local volumeIncrement = math.abs(targetVol - vol) / math.ceil(fadeTime / updateFreq)
	local channelData = SlashCo.AudioSystem.Channels[channel]
	timer.Create(timerName, updateFreq, 0, function() -- Let the sound fade away
		vol = UpdateFadeToVolume(targetVol, vol, volumeIncrement, lowerVol, channelData, callback, timerName, channel, true)
	end)

	-- Do one update outside the timer, since if you call this function every frame for some reason, the timer may never execute.
	vol = UpdateFadeToVolume(targetVol, vol, volumeIncrement, lowerVol, channelData, callback, timerName, channel, true)
end

-- Sounds shit if you keep the channel synced like how the background channel does.
function SlashCo.AudioSystem.FadeToPlaybackRate(channel, fadeTime, targetPlaybackRate, callback)
	targetPlaybackRate = targetPlaybackRate or 1
	fadeTime = fadeTime or 3

	local vol = SlashCo.AudioSystem.EnsureValidVolume(channel:GetPlaybackRate())
	local lowerVol = targetPlaybackRate < vol
	local id = SlashCo.AudioSystem.GetChannelID(channel)
	local timerName = "SlashCo:FadeToPlaybackRateAudioChannel" .. id
	local updateFreq = SlashCo.AudioSystem.UpdateFrequency
	local volumeIncrement = math.abs(targetPlaybackRate - vol) / math.ceil(fadeTime / updateFreq)
	local channelData = SlashCo.AudioSystem.Channels[channel]
	timer.Create(timerName, updateFreq, 0, function() -- Let the sound fade away
		vol = UpdateFadeToVolume(targetPlaybackRate, vol, volumeIncrement, lowerVol, channelData, callback, timerName, channel, false)
	end)

	-- Do one update outside the timer, since if you call this function every frame for some reason, the timer may never execute.
	vol = UpdateFadeToVolume(targetPlaybackRate, vol, volumeIncrement, lowerVol, channelData, callback, timerName, channel, false)
end

function SlashCo.AudioSystem.StopBackgroundMusic()
	SlashCo.AudioSystem.DestroyChannel(SlashCo.AudioSystem.BackgroundChannel, 1)
	SlashCo.AudioSystem.BackgroundChannel = nil
end

-- Returns the calculated time a channel is supposed to be at, it accounts for looping sounds
function SlashCo.AudioSystem.CalculateTime(channel, tickCount, looping)
	local calculateTime = ((engine.TickCount() - tickCount) * engine.TickInterval()) * channel:GetPlaybackRate()
	local fileLength = channel:GetLength()
	if not looping then -- If we don't want looping, then we simply return the normal time without any more calculations.
		return math.min(calculateTime, fileLength)
	end

	return calculateTime - (fileLength * math.floor(calculateTime / fileLength))
end

-- Returns the current background music time syncronized with all players.
function SlashCo.AudioSystem.GetBackgroundMusicTime()
	return SlashCo.AudioSystem.CalculateTime(SlashCo.AudioSystem.BackgroundChannel, GetGlobal2Int("SlashCo:StartTimeBackgroundMusic"), true)
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

	SlashCo.AudioSystem.CreateChannel(backgroundMusic, "noplay", function(channel)
		SlashCo.AudioSystem.BackgroundChannel = channel
		SlashCo.AudioSystem.Channels[channel].group = "BackgroundMusic"

		channel:SetVolume(0)
		channel:Play()
		channel:EnableLooping(true)
		channel:SetTime(SlashCo.AudioSystem.GetBackgroundMusicTime())
		channel:SetPlaybackRate(SlashCo.AudioSystem.GetBackgroundMusicPlaybackRate())
		SlashCo.AudioSystem.FadeToVolume(channel, 3, SlashCo.AudioSystem.GetBackgroundMusicVolume())
	end)
end

-- This is a NW2 Proxy function.
local function OnBackgroundMusicChange(ent, name, old, new)
	SlashCo.AudioSystem.PlayBackgroundMusic(new)
end

-- This is another NW2 Proxy function.
local function OnBackgroundMusicStateChange(ent, name, old, new)
	if not new then
		if IsValid(SlashCo.AudioSystem.BackgroundChannel) then
			SlashCo.AudioSystem.StopBackgroundMusic()
		end
	else
		SlashCo.AudioSystem.PlayBackgroundMusic()
	end
end

-- Did you know? This was one too >:3
local function OnBackgroundMusicVolumeChange(ent, name, old, new)
	if IsValid(SlashCo.AudioSystem.BackgroundChannel) then
		SlashCo.AudioSystem.FadeToVolume(SlashCo.AudioSystem.BackgroundChannel, 3, new)
	end
end

-- Guess what? Another one >:3c
local function OnBackgroundMusicPlaybackRateChange(ent, name, old, new)
	if IsValid(SlashCo.AudioSystem.BackgroundChannel) then
		SlashCo.AudioSystem.BackgroundChannel:SetPlaybackRate(new)
	end
end

function SlashCo.AudioSystem.Init()
	local world = game.GetWorld()

	SlashCo.AudioSystem.LocalPlayer = LocalPlayer()
	SlashCo.AudioSystem.LocalEntIndex = SlashCo.AudioSystem.LocalPlayer:EntIndex()
	SlashCo.AudioSystem.ValidLocalPlayer = IsValid(SlashCo.AudioSystem.LocalPlayer)

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

	world:SetNW2VarProxy("SlashCo:BackgroundMusicPlaybackRate", OnBackgroundMusicPlaybackRateChange)
	OnBackgroundMusicPlaybackRateChange(world, "SlashCo:BackgroundMusicPlaybackRate", nil, SlashCo.AudioSystem.GetBackgroundMusicPlaybackRate())
end

hook.Add("InitPostEntity", "SlashCo:AudioSystem", SlashCo.AudioSystem.Init)
if game.GetWorld() ~= NULL then -- Autorefresh time
	SlashCo.AudioSystem.Init()
end

local function UpdateBackgroundMusic()
	if not SlashCo.AudioSystem.ShouldPlayBackgroundMusic() then return end

	if not IsValid(SlashCo.AudioSystem.BackgroundChannel) then
		SlashCo.AudioSystem.PlayBackgroundMusic()
	else
		if SlashCo.AudioSystem.BackgroundChannel:GetState() ~= GMOD_CHANNEL_PLAYING then -- Fk stopsound
			SlashCo.AudioSystem.BackgroundChannel:Play()
		end

		local backgroundMusicTime = SlashCo.AudioSystem.GetBackgroundMusicTime()
		if not math.IsNearlyEqual(SlashCo.AudioSystem.BackgroundChannel:GetTime(), backgroundMusicTime, 1) and not SlashCo.AudioSystem.IsSinglePlayer then -- Allow a tolerance of 1 second difference, if were in single player we don't care.
			SlashCo.AudioSystem.BackgroundChannel:SetTime(backgroundMusicTime)
		end
	end
end

function CalculatePan(ply, channelPos)
	if not SlashCo.AudioSystem.ValidLocalPlayer then
		return 0
	end

	local forward = ply:GetAimVector()
	local right = forward:Angle():Right()
	local toSound = (channelPos - ply:GetPos()):GetNormalized()

	local pan = right:Dot(toSound)
	return math.Clamp(pan, -1, 1)
end

local function UpdateChannelPositionAndVolume(channel, channelData, localPlyPos)
	local soundData = channelData.soundData
	if not soundData then return end

	local newPos = channelData.pos
	if channelData.entIndex then
		local ent = channelData.ent or Entity(channelData.entIndex)
		if IsValid(ent) then
			channelData.ent = ent -- In case for some reason the entity didn't exist yet, could happen on full updates?
			newPos = ent:EyePos()
			if not soundData.noWorldSpace and newPos == ent:GetPos() then -- I don't like that we call GetPos for this again :/
				newPos = ent:WorldSpaceCenter() -- If possible, use the EyePos, but if the EyePos matches the Entity's position, we use the WorldSpaceCenter as a better position.
			end

			if channelData.is3D and not soundData.raytraced then -- We don't need to call it when the position isn't saved anyways as for non-3d channels the position is always Vector(0, 0, 0)
				channel:SetPos(newPos)
			end
			
			channelData.pos = newPos -- Since non-3d channels :GetPos will always be the world origin, we store our position in here instead.
		end
	end

	if newPos and soundData.minDistance and soundData.maxDistance then
		local volume = CalculateChannelVolume(channel, channelData.volume or soundData.volume)
		
		if soundData.dynamicPan then
			channel:SetPan(CalculatePan(SlashCo.AudioSystem.LocalPlayer, newPos))
		end

		channel:SetVolume(volume)
		-- ToDo: Right now we don't do this as else stopsound won't have any effect. I'll add a convar later to allow anyone to adjust the volume for the entire audiosystem, until then we won't force the sounds upon users.
		--[[if not soundData.noplay and channel:GetState() == GMOD_CHANNEL_STOPPED then -- BUG: Why can the sound randomy stop? I know that it isn't this system since in all cases where we stop it, we also delete it.
			local time = channel:GetTime()
			local length = channel:GetLength()
			if not math.IsNearlyEqual(length, time, 1) and time < length then
				channel:Play()
			end
		end]]
		--print("3D", channel, channelData.ID, volume)
	end

	if soundData.raytraced and channelData.pos then -- It may change the channel position
		channel:SetPos(channelData.pos)
	end
end

local function UpdateChannelPositionsAndVolumes()
	local localPlyPos = GetLocalPlayerPosition()
	for channel, channelData in pairs(SlashCo.AudioSystem.Channels) do
		--[[
			Why don't we remove the channel if the parent is gone?
			Because on full updates, the parent might disappear and then reappear.
		]]
		UpdateChannelPositionAndVolume(channel, channelData, localPlyPos)
	end
end

function SlashCo.AudioSystem.Think()
	UpdateBackgroundMusic()
	UpdateChannelPositionsAndVolumes()
end

--[[
	NOTE: We use PreRender as using Think would be after the audiosystem already played the next audio chunks.
	This would cause the audio of parented channels to lag behind and if a sound is playing on the local player, it sounds awful.
	Related Issue: https://github.com/Facepunch/garrysmod-issues/issues/6361
]]
hook.Add("PreRender", "SlashCo:AudioSystem", SlashCo.AudioSystem.Think)

local function RenderPulseEffect(entity, pulse, bumpDelay)
	local originalScale = entity:GetModelScale()
	if not pulse then
		entity._LastPulseScale = Lerp(FrameTime(), (entity._LastPulseScale or originalScale), 1)
		--print(entity._LastPulseScale)
		entity:SetModelScale(entity._LastPulseScale, 0)
	else
		entity:SetModelScale(originalScale * 1.1, 0)
		entity._LastPulseScale = entity:GetModelScale()
	end

	local r, g, b = 255, 0, 0
	render.SetColorModulation(r / 255, g / 255, b / 255)
	render.SetBlend(((entity._LastPulseScale - 1) * 10) - (math.Clamp(bumpDelay - CurTime(), 1, 0)) * 255)
	entity:DrawModel()
	render.SetBlend(1)
	entity:SetModelScale(originalScale, 0)
end

function SlashCo.AudioSystem.EffectThink() -- A WIP effect that can be used at a later point.
	for channel, channelData in pairs(SlashCo.AudioSystem.Channels) do
		local soundData = channelData.soundData
		if not soundData then continue end

		local pulseEffect = soundData.pulseEffect
		if pulseEffect then
			local shouldPulse = false
			local sampleSize = 10
			local threshold = 0.1
			local minDelay = 0.2
			local offset = 25
			local fft = {}
			//debug.setmetatable(fft, meta)
			channel:FFT(fft, FFT_4096)
			if #fft == 0 then continue end
			local sum = 0
			local sumCount = 0
			for i=offset, offset + sampleSize do
				sum = sum + fft[i]
				sumCount = sumCount + 1
			end
			sum = sum / sumCount
			channelData.PreviousPulseSum = Lerp(0.003, channelData.PreviousPulseSum or 0, sum)

			if #fft == 0 then continue end
			cam.Start2D()
			surface.SetDrawColor(0, 0, 0, 255)
			for i=offset, offset + sampleSize do
				surface.DrawRect(0, 2 * i, fft[i] * 8192, 10)
			end
			cam.End2D()

			channelData.bumpDelay = channelData.bumpDelay or CurTime()
			if channelData.bumpDelay < CurTime() and sum > channelData.PreviousPulseSum then
				channelData.PreviousPulseSum = sum
				channelData.bumpDelay = CurTime() + minDelay
				shouldPulse = true
			end

			local pulseEnt = pulseEffect.entity and Entity(pulseEffect.entity) or nil
			if IsValid(pulseEnt) then
				RenderPulseEffect(pulseEnt, shouldPulse, channelData.bumpDelay)
			end

			if pulseEffect.entityClass then
				for _, ent in ipairs(ents.FindByClass(pulseEffect.entityClass)) do
					RenderPulseEffect(ent, shouldPulse, channelData.bumpDelay)
				end
			end
		end
	end
end

hook.Add("PostDrawOpaqueRenderables", "SlashCo:AudioSystem", function(_, drawingSkybox, drawing3D)
	if drawing3D or drawingSkybox then return end

	--SlashCo.AudioSystem.EffectThink()
end)

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
		number startDistance - The distance at which the sound should begin to be hearable, default 0 - close up the sound is fully audiable. This allows you to make sounds only audible at a certain distance, meaning if you're closer than this distance, it cannot be heard.
		number startEndDistance - The distance at which the sound should be fully audiable, default 0.
		Vector position - A position to play the sound from, be aware that if a entity is set it will override this position! BUT if the entity wasn't networked yet this will ensure the sound starts at the right position.
		string modes - Any additional modes to pass to SlashCo.AudioSystem.CreateChannel
		number pan - The sound pan - See https://wiki.facepunch.com/gmod/IGModAudioChannel:SetPan
		number playbackRate - The sound playback rate.
		boolean noplay - Won't automatically play the sound
		string group - If set, a hook is called allowing you to add a hook that is executed when a sound is played like this: hook.Add("SlashCO:AudioSystem:PlaySound:ExampleGroup", "Example", function(soundData, channel))
		boolean deleteWhenDone - If true, the channel is deleted once the sound finished playing (will ignore looping flag and still stop it).
		number fadeIn - How many seconds it takes for the song to fade in at the start of it.
		number fadeOut - How many seconds before the ending it should start to fade out, and when it faded out the channel is destroyed.
		number fadeOutStart - How many seconds after the sound start it should begin to fade out. Use negative number to use a time based off the end of the sound instead of the start.
		boolean forceMono - Forces the sound to play as mono. Perferably use forceStereo since it won't butcher the sound quality.
		boolean forceStereo - Forces the sound to play as sterio. This doesn't really force it to be sterio but rather it removes the mono or 3d flag if they have been set.
		boolean noWorldSpace - If set it will use the entities EyePos instead of falling back to using it's WorldSpaceCenter position.
		boolean dynamicPan - If set it will calculate the pan for the channel giving the sound a 3D effect.
		string fallbackSoundPath - The fallback sound when the bound ConVar is disabled.
		string boundConVar - A ConVar the sound is bound to, when the ConVar is false then it will instead play the set fallbackSoundPath
		boolean disableUniqueToEntity - If set, the entity index is NOT added to the identifier allowing the sound to be played only ONCE and NOT by multiple entities.
		boolean disableAutoRemove - If set, the channel won't be removed after the entity of the channel was removed.
		boolean raytraced - If set, it will use traces to change the volume and position based off the environment. NOTE: This is WIP, Experiental and eats performance like hell rn
		string modifyGroup - A string containing all channel groups that should be modified while this channel is playing
		number modifyGroupVolumeMult - The volume multiplier that should be enforced onto all channels
		number modifyGroupVolumeFadeTime - (NOT IMPLEMENTED) Time in seconds for the volume to fade to the enforced multiplier. Clamped between a minimum of 0 and maximum of 30

		table pulseEffect - A table for the pulse effect. NOTE: This is still WIP and should not be used.
		-> Entity entity - A entity that should pulse
		-> string entityClass - The class of which all entities should pulse like sc_gascan
		-> number frequency - The sound frequency that should be checked for - currently unused.

	Internal fields:
		boolean isServerside - Set if the sound was sent to us by the server.

	Notes:
		When the entity is set to the world, the sound is played as mono and NOT 3d!

		minDistance and maxDistance act as a distance to fadeOut the volume when you get too far away.
		startDistance and startEndDistance act as a distance to fadeOut the volume when you get too close, where startEndDistance is the point when the sound is on full volume while at startDistance it will be completely faded out.
		See the comment above the CalculateFadeVolume for reference.

		all distance fields work regardless of the channel being in 3D or not, so you can use forceStereo and still use minDistance/maxDistance without issues.

		You can combine forceStereo and dynamicPan to give sounds a fake 3D effect while keeping the quality of them being in sterio/using multiple channels instead of the normal 3D that forces them into mono.
]]
function SlashCo.AudioSystem.PlaySound(soundData)
	local soundPath = soundData.soundPath
	if soundData.boundConVar and soundData.fallbackSoundPath then
		local convar = GetConVar(soundData.boundConVar)
		if not convar:GetBool() then
			soundPath = soundData.fallbackSoundPath
		end
	end

	soundData.identifier = soundData.identifier or soundPath
	soundData.startTick = soundData.startTick or engine.TickCount()
	--soundData.entity = soundData.entity or game.GetWorld()
	soundData.volume = soundData.volume or 1
	soundData.looping = soundData.looping or false
	soundData.modes = soundData.modes or ""

	local entIndex = 0
	if isnumber(soundData.entity) then
		entIndex = soundData.entity
	elseif IsValid(soundData.entity) then
		entIndex = soundData.entity:EntIndex() -- ToDo: Should we also support clientside entities? Probably.
	end

	if not soundData.disableUniqueToEntity then
		soundData.identifier = soundData.identifier .. entIndex
	end

	SlashCo.AudioSystem.StopSound(soundData.identifier, 0.5)

	local existingCreationData = SlashCo.AudioSystem.CreatingChannels[soundData.identifier]
	local isAlreadyInCreation = existingCreationData ~= nil
	if existingCreationData and (existingCreationData.creationTimeout or 0) < CurTime() then
		isAlreadyInCreation = false
	end

	SlashCo.AudioSystem.CreatingChannels[soundData.identifier] = soundData
	soundData.creationTimeout = CurTime() + 5 -- if the sound for some reason wasn't created after 5 seconds, we will think it timed out.
	
	-- Required to prevent a race conditions where multiple channels could have been created with the same identifier.
	-- BUG: Look at this later again for a special case: What if soundData.soundPath is different in the second call done and it uses the same identifier?
	if isAlreadyInCreation then
		soundData.identifier = existingCreationData.identifier
		soundData.soundPath = existingCreationData.soundPath
		return
	end

	local useMode = "" -- By default we use sterio since it sounds far better than mono.
	if entIndex > 0 or soundData.position then
		useMode = "3d"

		-- The sound is played in 3D when it isn't mono, so we fake 3D
		if Fake3DList[soundPath] then
			useMode = ""
			soundData.dynamicPan = true
		end
	end

	if soundData.forceMono then
		useMode = "mono"
	end

	-- Useful when it has a position/entity but you still want to play it as sterio.
	if soundData.forceStereo then
		useMode = ""
	end

	SlashCo.AudioSystem.CreateChannel(soundPath, AppendMode(AppendMode(useMode, soundData.modes), "noplay"), function(channel, channelData)
		local soundData = SlashCo.AudioSystem.CreatingChannels[soundData.identifier] or soundData -- Update in case it was updated in the few frames we had originally made our call.
		if soundData.DESTROYCHANNEL then
			channel:SetVolume(0)
			SlashCo.AudioSystem.DestroyChannel(channel)
			SlashCo.AudioSystem.CreatingChannels[soundData.identifier] = nil
			channel:__gc()
			return
		end

		if soundData.fadeIn and soundData.fadeIn ~= 0 then
			channel:SetVolume(0)
			channelData.volume = 0
		else
			channel:SetVolume(soundData.volume)
			channelData.volume = soundData.volume
		end

		channel:EnableLooping(soundData.looping)
		local calcTime = SlashCo.AudioSystem.CalculateTime(channel, soundData.startTick, soundData.looping)
		channel:SetTime(calcTime)
		local totalLength = channel:GetLength()
		local timeLeft = totalLength - calcTime

		if soundData.identifier then
			SlashCo.AudioSystem.SetChannelIdentifier(channel, soundData.identifier)
		end

		if soundData.fadeIn and soundData.fadeIn ~= 0 then
			SlashCo.AudioSystem.FadeToVolume(channel, soundData.fadeIn, soundData.volume)
		end

		if entIndex ~= 0 then
			SlashCo.AudioSystem.ParentChannelToEntity(channel, entIndex)
		end

		if soundData.position then
			if channelData.is3D then
				channel:SetPos(soundData.position)
			else
				channelData.pos = soundData.position
			end
		end

		if soundData.pan then
			channel:SetPan(soundData.pan)
		end

		if soundData.playbackRate then
			channel:SetPlaybackRate(soundData.playbackRate)
		end

		if soundData.soundLevel and soundData.soundLevel ~= 0 then
			soundData.minDistance = soundData.soundLevel ^ 1.25
			soundData.maxDistance = soundData.soundLevel ^ 1.5
		end

		if soundData.minDistance and soundData.maxDistance then
			channel:Set3DFadeDistance(soundData.minDistance, soundData.maxDistance)
		end

		channelData.soundData = soundData -- Save the data that was used to create this channel.
		if IsEntity(soundData.entity) then -- If they gave us an entity, copy it over and use it to support clientside entities since we cannot use the EntIndex for thoes.
			channelData.ent = soundData.entity
		end
		UpdateChannelPositionAndVolume(channel, channelData) -- Update the channel position so that when we play it, there won't be a audio bug for 1 frame where it would play from the world origin.

		if soundData.modifyGroup then
			channelData.modifyGroups = string.Split(soundData.modifyGroup, "|")
			channelData.modifyGroupVolumeMult = math.Clamp(soundData.modifyGroupVolumeMult or 0, 0, 2)
			channelData.modifyGroupVolumeFadeTime = math.Clamp(soundData.modifyGroupVolumeFadeTime or 0, 0, 30)
			channelData.modifyGroupStart = CurTime()

			AddModifyChannelGroup(channel, channelData)
		end

		if not soundData.noplay and (timeLeft > 0 or soundData.looping) then -- We call Play only here since some settings might change how it can be heard.
			channel:Play()
		end

		SlashCo.AudioSystem.CreatingChannels[soundData.identifier] = nil
		if soundData.callback then
			soundData.callback(channel)
		end

		if soundData.group then -- This will be useful later when adding perks that modify the sound of things
			hook.Run("SlashCo:AudioSystem:PlaySound:" .. soundData.group, soundData, channel)
		end

		if soundData.deleteWhenDone and not soundData.looping then
			timer.Simple(timeLeft + 0.1, function()
				if not IsValid(channel) then return end
				SlashCo.AudioSystem.DestroyChannel(channel, 0)
			end)
		end

		if soundData.fadeOut then
			local baseTime = soundData.fadeOut + 0.1 -- We add 0.1 just as a buffer to ensure that it'll go fine.
			local time = timeLeft - baseTime
			local timeOffset = soundData.fadeOutStart or 0
			if timeOffset ~= 0 then
				if timeOffset > 0 then
					time = timeOffset - calcTime
				else
					time = totalLength + timeOffset
				end
			end

			timer.Simple(time, function()
				if not IsValid(channel) then return end
				SlashCo.AudioSystem.DestroyChannel(channel, soundData.fadeOut)
			end)
		end
	end, function(errCode, errStr)
		SlashCo.AudioSystem.CreatingChannels[soundData.identifier] = nil -- Error happened, just clear it out from creation.

		if errStr == "BASS_ERROR_NO3D" and not Fake3DList[soundPath] then
			print("[SlashCo] Sound \"" .. soundPath .. "\" was attempted to be played as 3D when it's not. Falling back to fake 3D!")
			Fake3DList[soundPath] = true
			SlashCo.AudioSystem.PlaySound(soundData)

			return true
		end
	end)
end

-- Returns all channels that were parented to the given entity.
function SlashCo.AudioSystem.GetEntityChannels(entity)
	local entIndex = -1
	if isnumber(entity) then
		entIndex = entity
	elseif isentity(entity) and IsValid(entity) then
		entIndex = entity:EntIndex()
	end

	if entIndex == -1 then
		error("Invalid entity was given to us. It must be a Entity or a Entity Index!")
		return
	end

	local results = {}
	for channel, channelData in pairs(SlashCo.AudioSystem.Channels) do
		if channelData.entIndex ~= entIndex then continue end
		
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

	if not isnumber(entIndex) and IsValid(entIndex) then
		entIndex = entIndex:EntIndex()
	end

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

	-- We use or and do identifier .. entIndex since if a sound didn't use disableUniqueToEntity, it will append the EntIndex to our identifier
	local creationSounData = SlashCo.AudioSystem.CreatingChannels[identifier] or SlashCo.AudioSystem.CreatingChannels[identifier .. (entIndex or "")]
	if creationSounData then -- The channel wasn't created yet, so we cannot stop it. Instead we'll set a flag.
		creationSounData.DESTROYCHANNEL = true
		return
	end

	local channel = SlashCo.AudioSystem.GetChannelByIdentifier(identifier) or SlashCo.AudioSystem.GetChannelByIdentifier(identifier .. (entIndex or ""))
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

local function ReadPulseEffect()
	return {
		entity = ReadSoundField(net.ReadUInt, MAX_EDICT_BITS),
		entityClass = ReadSoundField(net.ReadString),
		frequency = ReadSoundField(net.ReadUInt, 16),
	}
end

local deltaMerge
local function DeltaMerge(deltaTable, baseTable)
	for key, val in pairs(baseTable) do
		local deltaTableVal = deltaTable[key]
		if deltaTableVal then
			if istable(deltaTableVal) then
				deltaMerge(deltaTableVal, baseTable[key])
			else
				baseTable[key] = val -- We inherit from the current deltaTable so that our baseTable is always up to date containing the same data from the last request
			end
			continue -- We got nothing to change :3
		end

		deltaTable[key] = val
	end
end
deltaMerge = DeltaMerge

local function ReadSoundData()
	return {
		soundPath = ReadSoundField(net.ReadString),
		fallbackSoundPath = ReadSoundField(net.ReadString),
		entity = ReadSoundField(net.ReadUInt, MAX_EDICT_BITS),
		soundLevel = ReadSoundField(net.ReadUInt, 14),
		volume = ReadSoundField(net.ReadFloat),
		looping = ReadSoundField(net.ReadBool),
		startTick = ReadSoundField(net.ReadUInt, 32),
		identifier = ReadSoundField(net.ReadString),
		minDistance = ReadSoundField(net.ReadUInt, 16),
		maxDistance = ReadSoundField(net.ReadUInt, 16),
		startDistance = ReadSoundField(net.ReadUInt, 16),
		startEndDistance = ReadSoundField(net.ReadUInt, 16),
		position = ReadSoundField(net.ReadVector),
		modes = ReadSoundField(net.ReadString),
		pan = ReadSoundField(net.ReadFloat),
		playbackRate = ReadSoundField(net.ReadFloat),
		group = ReadSoundField(net.ReadString),
		deleteWhenDone = ReadSoundField(net.ReadBool),
		fadeIn = ReadSoundField(net.ReadFloat),
		fadeOut = ReadSoundField(net.ReadFloat),
		fadeOutStart = ReadSoundField(net.ReadFloat),
		forceMono = ReadSoundField(net.ReadBool),
		forceStereo = ReadSoundField(net.ReadBool),
		noWorldSpace = ReadSoundField(net.ReadBool),
		dynamicPan = ReadSoundField(net.ReadBool),
		boundConVar = ReadSoundField(net.ReadString),
		pulseEffect = ReadSoundField(ReadPulseEffect),
		disableUniqueToEntity = ReadSoundField(net.ReadBool),
		raytraced = ReadSoundField(net.ReadBool),
		modifyGroup = ReadSoundField(net.ReadString),
		modifyGroupVolumeMult = ReadSoundField(net.ReadFloat),
		modifyGroupVolumeFadeTime = ReadSoundField(net.ReadFloat),
	}
end

local function PlayServerReceivedSound(soundData)
	-- NOTE: We intentionally do this only for sounds played by the server since they won't possibly move the channel independantly.
	-- While clientside, the channel could be moved after PlaySound was called so if we forced it into mono we could break things.
	if soundData.entity ~= nil and soundData.entity == SlashCo.AudioSystem.LocalEntIndex then
		soundData.forceStereo = true -- We are playing the sound on the local player, so we switch it to sterio for hopefully better quality & for no 3D audio bugs since the audio source is exacty at the ear position.
	end

	soundData.isServerside = true -- Sound was played by the server.

	SlashCo.AudioSystem.PlaySound(soundData)
end

local nextMissID = 0
local deltaMissRecovery = {}
net.Receive("slashCo_AudioSystem_MissingDelta", function()
	local identifier = net.ReadString()
	local missID = net.ReadUInt(32)

	local soundData = deltaMissRecovery[missID]
	if not soundData then return end -- We failed to get the sound data that we had received on delta miss?!?

	local deltaData = ReadSoundData()
	SlashCo.AudioSystem.DeltaSoundCache[identifier] = table.Copy(deltaData)
	deltaMissRecovery[missID] = nil

	DeltaMerge(soundData, deltaData)

	net.Start("slashCo_AudioSystem_AcknowledgeDelta")
		net.WriteString(identifier)
	net.SendToServer()

	-- print("Received delta recovery")
	PlayServerReceivedSound(soundData)
end)

net.Receive("slashCo_AudioSystem_PlaySound", function()
	local isDelta = net.ReadBool()
	local soundData = ReadSoundData()
	local identifier = soundData.identifier or soundData.soundPath
	if isDelta then
		local baseTable = SlashCo.AudioSystem.DeltaSoundCache[identifier]
		if baseTable then
			DeltaMerge(soundData, baseTable)
		else
			-- Uh oh... Fuck... How did this happen? Normally this CANNOT happen! This is purely for absolute safety!
			local missID = nextMissID
			nextMissID = nextMissID + 1

			deltaMissRecovery[nextMissID] = soundData

			net.Start("slashCo_AudioSystem_MissingDelta")
				net.WriteString(identifier)
				net.WriteUInt(missID, 32)
			net.SendToServer()
			-- print("Triggering delta recovery")
			return -- The server will resend the delta to recover from our failure after which we can play it properly.
		end
	else
		SlashCo.AudioSystem.DeltaSoundCache[identifier] = table.Copy(soundData)
		net.Start("slashCo_AudioSystem_AcknowledgeDelta")
			net.WriteString(identifier)
		net.SendToServer()
	end

	-- PrintTable(soundData)
	PlayServerReceivedSound(soundData)
end)

net.Receive("slashCo_AudioSystem_StopSound", function()
	local identifier = ReadSoundField(net.ReadString)
	local fadeOut = net.ReadFloat()
	local entIndex = ReadSoundField(net.ReadUInt, MAX_EDICT_BITS)

	SlashCo.AudioSystem.StopSound(identifier, fadeOut, entIndex)
end)

net.Receive("slashCo_AudioSystem_FadeSound", function() -- ToDo: Fix this function
	local identifier = net.ReadString()
	local fadeTime = net.ReadFloat()
	local targetVolume = net.ReadFloat()

	local channel = SlashCo.AudioSystem.GetChannelByIdentifier(identifier)
	if not channel then return end

	SlashCo.AudioSystem.FadeToVolume(channel, fadeTime, targetVolume)
end)

net.Receive("slashCo_AudioSystem_EntityRemoved", function()
	local entIndex = net.ReadUInt(MAX_EDICT_BITS)

	SlashCo.AudioSystem.StopSound(nil, 1, entIndex)
end)

net.Receive("slashCo_AudioSystem_SetGroupVolume", function()
	local groupName = net.ReadString()
	local groupVolume = net.ReadFloat()
	local lerpTime = net.ReadFloat() -- ToDo

	SlashCo.AudioSystem.ServerGroupVolumes[groupName] = groupVolume
end)

function SlashCo.AudioSystem.SetGroupVolume(groupName, groupVolume, lerpTime)
	SlashCo.AudioSystem.ClientGroupVolumes[groupName] = groupVolume
end