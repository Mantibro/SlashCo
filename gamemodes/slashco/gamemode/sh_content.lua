SlashCo = SlashCo or {}
SlashCo.Content = SlashCo.Content or {}
SlashCo.Content.AddedMapToWorkshop = SlashCo.Content.AddedMapToWorkshop or false

--[[
	These precache tables store every single precached thing.
	This is to keep better track of things AND to reduce the performance impact of autorefreshs.
]]
SlashCo.Content.PrecacheModels = SlashCo.Content.PrecacheModels or {}
SlashCo.Content.PrecacheSounds = SlashCo.Content.PrecacheSounds or {}
SlashCo.Content.PrecacheItems = SlashCo.Content.PrecacheItems or {}
SlashCo.Content.PrecacheSlashers = SlashCo.Content.PrecacheSlashers or {}
SlashCo.Content.DebugPrint = SlashCo.Content.DebugPrint or false -- For debugging

-- NOTE: Errors aren't put behind DebugPrint as something clearly went wrong.
local function DebugPrint(msg)
	if SlashCo.Content.DebugPrint then
		print(msg)
	end
end

function SlashCo.FindWorkshopID(mapName)
	if not string.EndsWith(mapName, ".bsp") then
		mapName = mapName .. ".bsp"
	end

	local mapPath = "maps/" .. mapName
	for _, addon in ipairs(engine.GetAddons()) do
		if file.Exists(mapPath, addon.title) then
			return addon.wsid, addon.title
		end
	end

	return nil, nil
end

if SERVER and not SlashCo.Content.AddedMapToWorkshop then
	local wsid, title = SlashCo.FindWorkshopID(game.GetMap())
	if wsid then
		print("[Content] Current map is from Addon " .. title)
		resource.AddWorkshop(wsid) -- Adds the current map to the server download.
		SlashCo.Content.AddedMapToWorkshop = true
	end
end

if CLIENT then
	net.Receive("slashco_PrecacheMap", function() -- Goal is to reduce loading time by starting the map download in the lobby already.
		local wsid = net.ReadString()
		local title = net.ReadString()

		DebugPrint("[Content] Received precache signal")
		steamworks.FileInfo(wsid, function(result)
			if result.installed and not result.disabled then  -- The map is already installed :3
				DebugPrint("[Content] The next map is already installed\n")
				return
			end

			steamworks.DownloadUGC(wsid, function(path, file)
				if path then
					DebugPrint("[Content] Successfully precached \"" .. title .. "\" (" .. wsid .. ") for the next round")
				else
					print("[Content] Failed to precache \"" .. title .. "\" (" .. wsid .. ")")
				end
			end)
		end)
	end)
else
	util.AddNetworkString("slashco_PrecacheMap")
	function SlashCo.PrecacheNextMap()
		local mapName = SlashCo.LobbyData.SelectedMap
		local wsid, title = SlashCo.FindWorkshopID(mapName)
		if not wsid then -- Could happen if a server uses fastdl
			print("[Content] Failed to precache next map as it wasn't found in any addon! (" .. mapName .. ")")
			return
		else
			DebugPrint("[Content] Sent out precache signal for map \"" .. mapName .. "\" (\"" .. title .. "\" - " .. wsid .. ")")
		end

		net.Start("slashco_PrecacheMap")
			net.WriteString(wsid)
			net.WriteString(title)
		net.Broadcast()
	end
end

function SlashCo.PrecacheModel(modelName)
	if SlashCo.Content.PrecacheModels[modelName] then
		return
	end

	SlashCo.Content.PrecacheModels[modelName] = true
	util.PrecacheModel(modelName)

	DebugPrint("[Content] Precached model \"" .. modelName .. "\"")
end

function SlashCo.PrecacheSound(soundName)
	if SlashCo.Content.PrecacheSounds[soundName] then
		return
	end

	SlashCo.Content.PrecacheSounds[soundName] = true
	util.PrecacheModel(soundName)

	DebugPrint("[Content] Precached sound \"" .. soundName .. "\"")
end

function SlashCo.PrecacheSlasher(slasherName)
	local slasherTbl = SlashCoSlashers[slasherName]
	
	if slasherTbl.Model then
		SlashCo.PrecacheModel(slasherTbl.Model)
	end

	if slasherTbl.ChaseMusic then
		SlashCo.PrecacheSound(slasherTbl.ChaseMusic)
	end

	if slasherTbl.KillSound then
		SlashCo.PrecacheSound(slasherTbl.KillSound)
	end

	if slasherTbl.Precache then
		slasherTbl.Precache()
	end

	if not SlashCo.Content.PrecacheSlashers[slasherName] then
		DebugPrint("[Content] Precached Slasher \"" .. slasherName .. "\"")
		SlashCo.Content.PrecacheSlashers[slasherName] = true
	end
end

function SlashCo.PrecacheItem(itemName)
	local itemTbl = SlashCoItems[itemName]

	if itemTbl.Model then
		SlashCo.PrecacheModel(itemTbl.Model)
	end

	if itemTbl.Precache then
		itemTbl.Precache()
	end

	if itemTbl.ViewModel and itemTbl.ViewModel.model then
		SlashCo.PrecacheModel(itemTbl.ViewModel.model)
	end

	if itemTbl.WorldModelHolstered and itemTbl.WorldModelHolstered.model then
		SlashCo.PrecacheModel(itemTbl.WorldModelHolstered.model)
	end

	if itemTbl.WorldModel and itemTbl.WorldModel.model then
		SlashCo.PrecacheModel(itemTbl.WorldModel.model)
	end

	if not SlashCo.Content.PrecacheItems[itemName] then
		DebugPrint("[Content] Precached Item \"" .. itemName .. "\"")
		SlashCo.Content.PrecacheItems[itemName] = true
	end
end

if SERVER then
	hook.Add("InitPostEntity", "SlashCo:CallPrecache", function()
		hook.Run("SlashCo:Precache")
	end)

	if game.GetWorld() != NULL then -- Autorefresh support
		hook.Run("SlashCo:Precache")
	end
end