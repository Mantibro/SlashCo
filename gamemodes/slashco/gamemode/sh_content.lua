SlashCo = SlashCo or {}
SlashCo.Content = SlashCo.Content or {}
SlashCo.Content.AddedMapToWorkshop = SlashCo.Content.AddedMapToWorkshop or false
SlashCo.Content.AddedGamemodeToWorkshop = SlashCo.Content.AddedGamemodeToWorkshop or false
SlashCo.Content.AddedSlashersToWorkshop = SlashCo.Content.AddedSlashersToWorkshop or {}
SlashCo.Content.SlashCoWorkshopAddons = SlashCo.Content.SlashCoWorkshopAddons or {}

-- List if NON SlashCo addons used to skip some expensive filesystem operations
SlashCo.Content.NonSlashCoWorkshopAddons = SlashCo.Content.NonSlashCoWorkshopAddons or {}

--[[
	These precache tables store every single precached thing.
	This is to keep better track of things AND to reduce the performance impact of autorefreshs.
]]
SlashCo.Content.PrecacheModels = SlashCo.Content.PrecacheModels or {}
SlashCo.Content.PrecacheSounds = SlashCo.Content.PrecacheSounds or {}
SlashCo.Content.PrecacheItems = SlashCo.Content.PrecacheItems or {}
SlashCo.Content.PrecacheSlashers = SlashCo.Content.PrecacheSlashers or {}
SlashCo.Content.DebugPrint = SlashCo.Content.DebugPrint or false -- For debugging

local GamemodeInfo = util.KeyValuesToTable(file.Read((GAMEMODE or GM).Folder .. "/" .. (GAMEMODE or GM).FolderName .. ".txt", "GAME") or "")
SlashCo.Content.WorkshopID = GamemodeInfo.workshopid or "2844428843" -- Fallback ID! Currently the Main Addon!

-- NOTE: Errors aren't put behind DebugPrint as something clearly went wrong.
local function DebugPrint(msg)
	if SlashCo.Content.DebugPrint then
		print(msg)
	end
end

function SlashCo.FindWorkshopID(fileName)
	for _, addon in ipairs(engine.GetAddons()) do
		if addon.mounted and file.Exists(fileName, addon.title) then
			return addon.wsid, addon.title
		end
	end

	return nil, nil
end

function SlashCo.FindMapWorkshopID(mapName)
	if not string.EndsWith(mapName, ".bsp") then
		mapName = mapName .. ".bsp"
	end

	return SlashCo.FindWorkshopID("maps/" .. mapName)
end

function SlashCo.FindSlasherWorkshopID(slasherFile)
	if not string.EndsWith(slasherFile, ".lua") then
		slasherFile = slasherFile .. ".lua"
	end

	return SlashCo.FindWorkshopID("lua/" .. slasherFile)
end

function SlashCo.GetAddons()
	return SlashCo.Content.SlashCoWorkshopAddons
end

local function OpenFile(fileName, mode, addonTitle)
	return addonTitle:StartsWith("addons/") and file.Open(addonTitle .. fileName, mode, "MOD") or file.Open(fileName, mode, addonTitle)
end

local function CodeName(fileName, addonTitle)
	return addonTitle:StartsWith("addons/") and (addonTitle .. fileName) or (fileName .. " - " .. addonTitle)
end

-- Loads a lua file from all addons that contain one with the same name
function SlashCo.LoadFileFromAddons(fileName)
	local addons = SlashCo.GetAddons()
	for _, addonTitle in pairs(addons) do
		local fh = OpenFile(fileName, "rb", addonTitle)
		if not fh then continue end
		
		local code = fh:Read()
		fh:Close()

		local codeName = CodeName(fileName, addonTitle)
		local errMsg = RunString(code, codeName, false) 
		if errMsg then
			ErrorNoHaltWithStack("Failed to load " .. codeName .. " (" .. errMsg .. ")")
		end
	end
end

local function InternalRegisterAddon(wsid, title)
	if wsid == SlashCo.Content.WorkshopID or SlashCo.Content.SlashCoWorkshopAddons[wsid] then return end

	if SERVER then
		resource.AddWorkshop(wsid)
	end

	SlashCo.Content.SlashCoWorkshopAddons[wsid] = title
	SlashCo.Content.NonSlashCoWorkshopAddons[wsid] = nil
end

-- Registers a SlashCo addon, normally we won't require this as any addon that registers a slasher is also registered!
function SlashCo.RegisterAddon(workshopid)
	if SlashCo.Content.SlashCoWorkshopAddons[workshopid] then return true end

	for _, addon in ipairs(engine.GetAddons()) do
		if addon.mounted and addon.wsid == workshopid then
			InternalRegisterAddon(workshopid, addon.title)
			return true
		end
	end

	return false
end

function SlashCo.FindSlashCoAddons()
	SlashCo.Content.SlashCoWorkshopAddons = {} -- Empty our list
	for _, addon in ipairs(engine.GetAddons()) do
		if not addon.mounted or SlashCo.Content.NonSlashCoWorkshopAddons[addon.wsid] then continue end

		-- GMod Bug! file.IsDir does not work on workshop addons! (ToDo: Report this!)
		local _, folders = file.Find("lua/*", addon.title)
		local isValid = false
		for _, folder in ipairs(folders) do
			if folder == "slashco" then
				isValid = true
				break
			end
		end

		if isValid then
			InternalRegisterAddon(addon.wsid, addon.title)
		else
			SlashCo.Content.NonSlashCoWorkshopAddons[addon.wsid] = true
		end
	end

	-- We also check for legacy addons to not make development harder for addon developers :)
	local _, folders = file.Find("addons/*", "MOD")
	for _, folder in ipairs(folders) do
		if not file.IsDir("addons/" .. folder .. "/lua/slashco", "MOD") then continue end

		-- Let's make sure were not registering the main gamemode (No custom addon should be touching that!)
		-- if not file.IsDir("addons/" .. folder .. "/gamemodes/slashco", "MOD") then continue end

		local nextFreeID = -1
		while SlashCo.Content.SlashCoWorkshopAddons[tostring(nextFreeID)] do
			nextFreeID = nextFreeID - 1
		end

		SlashCo.Content.SlashCoWorkshopAddons[tostring(nextFreeID)] = "addons/" .. folder .. "/"
	end

	-- Any SlashCo addon can use this hook to register themselves using SlashCo.RegisterAddon(workshopID)
	hook.Run("SlashCo:RegisterAddons")
end
SlashCo.FindSlashCoAddons()

function SlashCo.GameContentChanged()
	SlashCo.FindSlashCoAddons()

	hook.Run("SlashCo:GameContentChanged")
end

hook.Add("GameContentChanged", "SlashCo:Content", SlashCo.GameContentChanged)

if CLIENT then
	net.Receive("SlashCo:PrecacheAddon", function() -- Goal is to reduce loading time by starting the map download in the lobby already.
		local wsid = net.ReadUInt64()
		local title = net.ReadString()

		DebugPrint("[Content] Received precache signal for addon")
		steamworks.FileInfo(wsid, function(result)
			if result.installed and not result.disabled then  -- The map is already installed :3
				DebugPrint("[Content] The addon is already installed (\"" .. title .. "\", \"".. wsid .. "\")\n")
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
	util.AddNetworkString("SlashCo:PrecacheAddon")
	function SlashCo.PrecacheNextMap()
		local mapName = SlashCo.LobbyData.SelectedMap
		local wsid, title = SlashCo.FindWorkshopID(mapName)
		if not wsid then -- Could happen if a server uses fastdl
			print("[Content] Failed to precache next map as it wasn't found in any addon! (" .. mapName .. ")")
			return
		else
			DebugPrint("[Content] Sent out precache signal for map \"" .. mapName .. "\" (\"" .. title .. "\" - " .. wsid .. ")")
		end

		net.Start("SlashCo:PrecacheAddon")
			net.WriteUInt64(wsid)
			net.WriteString(title)
		net.Broadcast()
	end

	function SlashCo.PrecacheSlasherAddon(slasherFile)
		if SlashCo.Content.AddedSlashersToWorkshop[slasherFile] then return end

		local wsid, title = SlashCo.FindSlasherWorkshopID(slasherFile)
		if wsid and wsid ~= SlashCo.Content.WorkshopID then
			print("[Content] Slasher found from Addon \"" .. title .. "\"")

			SlashCo.Content.AddedSlashersToWorkshop[slasherFile] = true
			InternalRegisterAddon(wsid, title)

			net.Start("SlashCo:PrecacheAddon")
				net.WriteUInt64(wsid)
				net.WriteString(title)
			net.Broadcast()
		end
	end

	if not SlashCo.Content.AddedMapToWorkshop then
		local wsid, title = SlashCo.FindMapWorkshopID(game.GetMap())
		if wsid then
			if wsid ~= SlashCo.Content.WorkshopID then
				print("[Content] Current map is from Addon \"" .. title .. "\"")
			end

			InternalRegisterAddon(wsid, title) -- Adds the current map to the server download.
			SlashCo.Content.AddedMapToWorkshop = true
		end
	end

	if not SlashCo.Content.AddedGamemodeToWorkshop then
		-- Add the gamemode itself, just to be sure that it was added since somehow people still miss content.
		resource.AddWorkshop(SlashCo.Content.WorkshopID)
		SlashCo.Content.AddedGamemodeToWorkshop = true
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