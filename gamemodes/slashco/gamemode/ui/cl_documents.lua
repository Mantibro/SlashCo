--[[
	This is the document display code.
	There probably is a far better way but I have never made any menus that are rendered in a 3d environment so this is probably quite bad.

	ToDo:
	- Add translation
	- Use a better ui sound
]]

--[[
	A text cache used to improve rendering performance.
	Structure:
		key - font
		value - texts(table):
			key - callID(number)
			value - data(table):
				mins - vector
				maxs - vector
				width - number
				height - number
				pos - vector
]]
local textCache = {}

local rawScreenPos = Vector(790, 127, -125)
local screenPos = nil -- set on the first render - reading from networking
local screenAngle = nil
local screenUp = nil
local screenSize = 800 -- in world space it's 120 | 800 * 0.15 = 120
local worldScale = 0.15  -- Scale factor to convert from screen pixels to world units
local screenMins = Vector(0, 0, 0)
local screenMaxs = Vector(screenSize * worldScale, -screenSize * worldScale, 1)

local unknownIcon = Material("slashco/ui/icons/slasher/unknown")
local starFilled = Material("slashco/ui/star_filled")
local starUnfilled = Material("slashco/ui/star_unfilled")
GameData.DocumentPointer = GameData.DocumentPointer or 0
local playerShootPos
local playerAimVec

--[[
	This function draws the given text and returns true if the text is currently seletected/being looked/aimed at.

	NOTE: You need to call this funtion consistently or else the callID might get screwd up.
	The callID is used as a incremental value for the cache to allow it to handle duplicate text's.
	But this requires that DrawTextWithHitbox is always called exactly the same way and never out of order.
	if you need to call it out of order nuke the text cache first like this: textCache = {}
]]
local callID = 0
local function DrawTextWithHitbox(text, font, x, y, color, xAlign, yAlign)
	local width, height = draw.SimpleText(text, font, x, y, color, xAlign, yAlign)

	local cacheEntry = textCache[font]
	if not cacheEntry then
		cacheEntry = {}
		textCache[font] = cacheEntry
	end

	cacheEntry = cacheEntry[callID]
	if not cacheEntry then
		cacheEntry = {}
		textCache[font][callID] = cacheEntry

		cacheEntry.width = width
		cacheEntry.height = height
		cacheEntry.mins = Vector(-(width * worldScale / 2), -(height * worldScale / 2), -1)
		cacheEntry.maxs = Vector((width * worldScale) / 2, (height * worldScale) / 2, 0)

		local pos = screenPos * 1
		pos[1] = pos[1] - (x * worldScale)
		pos[3] = pos[3] - (y * worldScale)
		cacheEntry.pos = pos
	end

	local hitPos = util.IntersectRayWithOBB(playerShootPos, playerAimVec, cacheEntry.pos, screenAngle, cacheEntry.mins, cacheEntry.maxs)

	-- Debug to check the text hitboxes
	-- debugoverlay.BoxAngles(cacheEntry.pos, cacheEntry.mins, cacheEntry.maxs, screenAngle, 0.02, Color(0, 255, 0, 10))

	callID = callID + 1
	return hitPos != nil
end

local function DrawTextureWithHitbox(material, x, y, width, height)
	local cacheEntry = textCache.Box
	if not cacheEntry then
		cacheEntry = {}
		textCache.Box = cacheEntry
	end

	cacheEntry = cacheEntry[callID]
	if not cacheEntry then
		cacheEntry = {}
		textCache.Box[callID] = cacheEntry

		cacheEntry.width = width
		cacheEntry.height = height
		cacheEntry.mins = Vector(0, -(height * worldScale), -1)
		cacheEntry.maxs = Vector((width * worldScale), 0, 0)
		cacheEntry.material = Material(material)

		local pos = screenPos * 1
		pos[1] = pos[1] - (x * worldScale)
		pos[3] = pos[3] - (y * worldScale)
		cacheEntry.pos = pos
	end

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(cacheEntry.material)
	surface.DrawTexturedRect(x, y, width, height)

	local hitPos = util.IntersectRayWithOBB(playerShootPos, playerAimVec, cacheEntry.pos, screenAngle, cacheEntry.mins, cacheEntry.maxs)
	
	-- Debug to check the text hitboxes
	-- debugoverlay.BoxAngles(cacheEntry.pos, cacheEntry.mins, cacheEntry.maxs, screenAngle, 0.02, Color(0, 255, 0, 10))

	callID = callID + 1
	return hitPos != nil
end

local fallBackOption = "Selection"
GameData.DocumentOption = GameData.DocumentOption or fallBackOption
local wasLeftMousePressed = false
local wasRightMousePressed = false
if GameData.IsLobby then
	SlashCo.AudioSystem.PrecacheSound("slashco/ui/terminalbutton_1.mp3", "mono", "DocumentRightClick")
	SlashCo.AudioSystem.PrecacheSound("slashco/ui/terminalbutton_2.mp3", "mono", "DocumentLeftClick")

	hook.Add("StartCommand", "SlashCo:LobbyDocumentScreen", function(ply, cmd)
		GameData.DocumentMouseWheelDelta = cmd:GetMouseWheel()
	end)
end
local function SwitchSelection(newSelection, isRightMouse)
	GameData.DocumentOption = newSelection
	GameData.CurrentDocumentScroll = 0
	textCache = {}

	if isRightMouse then
		wasRightMousePressed = true
	else
		wasLeftMousePressed = true
	end

	SlashCo.AudioSystem.PlayPrecachedChannel(isRightMouse and "DocumentRightClick" or "DocumentLeftClick")
end

local function IsPressing(mouse)
	if mouse == MOUSE_RIGHT then
		return not wasRightMousePressed and input.IsButtonDown(mouse)
	end

	return not wasLeftMousePressed and input.IsButtonDown(mouse)
end

-- RaphaelIT7: ToDo - Check if we can just use string.upper on any language without breaking anything...
local function MakeStringUpperIfPossible(value)
	local translated = SlashCo.Language(value)
	if SlashCo.CurrentLang == "en" or SlashCo.CurrentLang == "de" then
		translated = string.upper(translated)
	end

	return translated
end

local selection = {
	["Selection"] = function(w, h)
		if DrawTextWithHitbox(SlashCo.Language("documentSlashers"), "TVCDBig", w / 2, (h / 2) - (h / 4), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
			GameData.DocumentPointer = 0
		end

		if DrawTextWithHitbox(SlashCo.Language("documentLocations"), "TVCDBig", w / 2, (h / 2) - (h / 12), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
			GameData.DocumentPointer = 1
		end

		if DrawTextWithHitbox(SlashCo.Language("documentArchive"), "TVCDBig", w / 2, (h / 2) + (h / 12), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
			GameData.DocumentPointer = 2
		end

		if DrawTextWithHitbox(SlashCo.Language("documentPerks"), "TVCDBig", w / 2, (h / 2) + (h / 4), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
			GameData.DocumentPointer = 3
		end

		local pointerPos = h / 2
		if GameData.DocumentPointer == 0 then
			pointerPos = pointerPos - (h / 4)
		elseif GameData.DocumentPointer == 1 then
			pointerPos = pointerPos - (h / 12)
		elseif GameData.DocumentPointer == 2 then
			pointerPos = pointerPos + (h / 12)
		elseif GameData.DocumentPointer == 3 then
			pointerPos = pointerPos + (h / 4)
		end

		draw.SimpleText("<", "TVCDBig", w - (w / 16), pointerPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if IsPressing(MOUSE_LEFT) then
			if GameData.DocumentPointer == 0 then
				SwitchSelection("Slashers")
			elseif GameData.DocumentPointer == 1 then
				SwitchSelection("Locations")
			elseif GameData.DocumentPointer == 2 then
				SwitchSelection("Archive")
			elseif GameData.DocumentPointer == 3 then
				SwitchSelection("Perks")
			end
		end
	end, 
	["Slashers"] = function(w, h) -- BUG: This will work fine for under 20 slashers. Have more and we'll got a problem as it'll go out of screen. Issue: We currently have exactly 20 slashers... well...
		local count = 0
		local row = 1
		local rowSplit = 10 -- number of rows before it's cut off
		local scrollAmount = GameData.CurrentDocumentScroll
		if scrollAmount > 0 then
			GameData.CurrentDocumentScroll = 0
			scrollAmount = 0
		end

		-- we gotta clear the cache as else collisions won't update
		if GameData.CurrentDocumentScroll != (GameData.LastSlasherDocumentScroll or 0) then
			textCache = {}
			GameData.LastSlasherDocumentScroll = GameData.CurrentDocumentScroll
		end

		local startRow = 0
		while ((h / 18) * startRow + scrollAmount) < 0 do
			startRow = startRow + 1
		end

		local totalRows = math.floor(table.Count(SlashCoDocumentTypes["Slasher"] or {}) / 2) + 1
		if totalRows > 0 and (totalRows - startRow) < rowSplit then -- Scrolled too far down
			startRow = startRow - (rowSplit - (totalRows - startRow))
			scrollAmount = -((h / 18) * startRow)
			GameData.CurrentDocumentScroll = scrollAmount
		end

		GameData.LastSelectedSlasherDocumentHeight = GameData.LastSelectedSlasherDocumentHeight or (h / 18)
		local documents = {}
		for _, document in SortedPairs(SlashCoDocumentTypes["Slasher"] or {}) do
			if ((h / 18) * row + scrollAmount) > 0 and row <= (rowSplit + startRow) then
				local hasDocument = SlashCo.HasDocument(document.Slasher or document.Name)
				if DrawTextWithHitbox("[" .. MakeStringUpperIfPossible(hasDocument and document.Name or " ??? ") .. "]", "TVCDMedium", w / 5 + ((count % 2) * w / 2.1), (h / 18) * row + scrollAmount, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
					GameData.DocumentPointer = count
					GameData.LastSelectedSlasherDocumentHeight = (h / 18) * row
				end
			end

			table.insert(documents, document)

			if count % 2 == 1 then
				row = row + 1
			end
			count = count + 1
		end

		local selectedDocument = documents[GameData.DocumentPointer + 1]
		if not selectedDocument then
			GameData.DocumentPointer = 1 -- In case the GameData.DocumentPointer managed to be invalid?!?
			selectedDocument = documents[GameData.DocumentPointer]
		end

		local pointerRow = math.floor(GameData.DocumentPointer / 2) + 1
		if (GameData.LastSelectedSlasherDocumentHeight + scrollAmount) > 0 and pointerRow <= (rowSplit + startRow) then
			draw.SimpleText("<", "TVCDMedium", w / 2.3 + ((GameData.DocumentPointer % 2) * w / 2.1), GameData.LastSelectedSlasherDocumentHeight + scrollAmount, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- After the code above, we expect selectedDocument to NEVER be nil.
		local hasDocument = SlashCo.HasDocument(selectedDocument.Name)
		local slasher = hasDocument and SlashCoSlashers[selectedDocument.Slasher] or nil

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(slasher and Material("slashco/ui/icons/slasher/" .. slasher.IDName) or (selectedDocument.ID and Material("slashco/ui/icons/slasher/" .. selectedDocument.ID) or unknownIcon))
		surface.DrawTexturedRect(w / 20, h - (h / 2.7), w / 3, h / 3)

		draw.SimpleText("[" .. MakeStringUpperIfPossible(hasDocument and (slasher and slasher.Name or selectedDocument.Name) or "UNKNOWN") .. "]", "TVCDMediumBig", h / 1.45, w / 1.3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if slasher or (selectedDocument.DangerLevel and selectedDocument.Class) then
			draw.SimpleText(MakeStringUpperIfPossible(SlashCo.DangerLevel[slasher and slasher.DangerLevel or selectedDocument.DangerLevel] .. " " .. MakeStringUpperIfPossible(SlashCo.SlasherClass[slasher and slasher.Class or selectedDocument.Class])), "TVCDMedium", h / 1.45, w / 1.17, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(SlashCo.Language("documentEncounter"), "TVCDSmall", h / 1.45, w / 1.17, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if IsPressing(MOUSE_LEFT) and (slasher or selectedDocument.ID) then
			SwitchSelection("Slasher-" .. (selectedDocument.Slasher or selectedDocument.Name))
		end

		if IsPressing(MOUSE_RIGHT) then
			SwitchSelection("Selection", true)
		end
	end,
	["Locations"] = function(w, h)
		draw.SimpleText("WIP", "TVCDBig", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if IsPressing(MOUSE_RIGHT) then
			SwitchSelection("Selection", true)
		end
	end,
	["Archive"] = function(w, h)
		draw.SimpleText("WIP", "TVCDBig", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if IsPressing(MOUSE_RIGHT) then
			SwitchSelection("Selection", true)
		end
	end,
	["Perks"] = function(w, h)
		draw.SimpleText("WIP :3", "TVCDBig", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local sortedPerks = {}
		for _, perk in ipairs(SlashCo.GetPerks()) do
			if not sortedPerks[perk.Level] then
				sortedPerks[perk.Level] = {}
			end

			table.insert(sortedPerks[perk.Level], perk)
		end

		local currentPerk = nil
		local currentOffset = 0
		local currentPlayerLevel = SlashCo.ExperienceToLevel(GameData.LocalPlayer:GetExperience())
		for level, perks in pairs(sortedPerks) do
			currentOffset = currentOffset + (h / 50)
			draw.SimpleText("-- Level " .. level .. " --", "TVCDMedium", w / 2, currentOffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			currentOffset = currentOffset + (h / 30)

			local pos = 0
			local row = 0
			for _, perk in ipairs(perks) do
				local widthPerEntry = w
				widthPerEntry = widthPerEntry - (w / 50) -- Edge padding
				widthPerEntry = widthPerEntry / 10 -- 5 entries per row

				if DrawTextureWithHitbox(perk.Icon, (w / 50) + (widthPerEntry * pos), currentOffset, w / 12, h / 12) then
					surface.SetDrawColor(255, 0, 0, 255)
					surface.DrawOutlinedRect((w / 50) + (widthPerEntry * pos), currentOffset, w / 12, h / 12, 6)
					currentPerk = perk
				end


				if level > currentPlayerLevel or not SlashCo.OwnsPerk(GameData.LocalPlayer, perk.ID) then
					surface.SetDrawColor(0, 0, 0, 200)
					surface.DrawRect((w / 50) + (widthPerEntry * pos), currentOffset, w / 12, h / 12)
				end

				pos = pos + 1
				if pos >= 10 then
					currentOffset = currentOffset + (h / 12) + (h / 50)
					row = row + 1
					pos = 0
				end
			end

			currentOffset = currentOffset + (h / 12)
		end

		if IsPressing(MOUSE_LEFT) and currentPerk then
			SwitchSelection("Perk-" .. currentPerk.ID)
		end

		if IsPressing(MOUSE_RIGHT) then
			SwitchSelection("Selection", true)
		end
	end,
}

local function utf8_chars(str)
	local chars = {}
	for c in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
		chars[#chars + 1] = c
	end
	return chars
end

local function SplitTextIntoRows(text, font, maxRowWidth)
	surface.SetFont(font)

	local rows = {}
	local function push(currentRow)
		if currentRow ~= "" then
			table.insert(rows, currentRow)
		end
	end

	for line in string.gmatch(text or "", "[^\n]+") do
		local currentRow = ""

		local isEnglish = string.find(line, " ")

		if isEnglish then
			for _, word in ipairs(string.Split(line, " ")) do
				if word == "" then continue end

				local test = (currentRow == "" and word) or (currentRow .. " " .. word)

				if surface.GetTextSize(test) > maxRowWidth then
					push(currentRow)
					currentRow = word
				else
					currentRow = test
				end
			end
		else
			for _, char in ipairs(utf8_chars(line)) do
				local test = currentRow .. char

				if surface.GetTextSize(test) > maxRowWidth then
					push(currentRow)
					currentRow = char
				else
					currentRow = test
				end
			end
		end

		push(currentRow)
	end

	return rows
end

local function GenerateDocuments()
	for _, document in pairs(SlashCoDocumentTypes["Slasher"] or {}) do
		local slasher = SlashCoSlashers[document.Slasher]
		local Aliases = document.Aliases or (slasher and slasher.Aliases or {})
		for idx, name in ipairs(Aliases) do
			local translateKey = "Alias_" .. name
			local translated = SlashCo.Language(translateKey)
			if translated ~= translateKey then
				Aliases[idx] = translated
			end
		end

		local Class = MakeStringUpperIfPossible(SlashCo.SlasherClass[document.Class or (slasher and slasher.Class or SlashCo.SlasherClass.Unknown)])
		local DangerLevel = MakeStringUpperIfPossible(SlashCo.DangerLevel[document.DangerLevel or (slasher and slasher.DangerLevel or SlashCo.DangerLevel.Unknown)])
		local Name = SlashCo.Language(slasher and slasher.Name or document.Name)
		local ID = slasher and slasher.IDName or document.ID

		if not Aliases or not Class or not DangerLevel or not ID then continue end -- No slasher and no data? Then something is invalid

		local descriptionRows = SplitTextIntoRows(SlashCo.Language(document.Description), "TVCD", screenSize / 1.01)
		local additionalDescriptionRows = SplitTextIntoRows(SlashCo.Language(document.AdditionalDescription), "TVCD", screenSize / 1.01)

		local icon = Material("slashco/ui/icons/slasher/" .. ID)
		selection["Slasher-" .. (document.Slasher or document.Name)] = function(w, h)
			local row = 1
			local rowSize = w / 32
			draw.SimpleText(SlashCo.Language("documentEntry") .. Name .. "\"", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			row = row + 1
			draw.SimpleText(SlashCo.Language("documentAliases"), "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			for _, name in ipairs(Aliases) do
				row = row + 1
				draw.SimpleText("\"" .. name .. "\"", "TVCD", h / 3.1, rowSize * row, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			row = row + 1
			draw.SimpleText(SlashCo.Language("documentClass"), "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			row = row + 1
			draw.SimpleText("[" .. Class .. "]", "TVCD", h / 3.1, rowSize * row, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			row = row + 1
			draw.SimpleText(SlashCo.Language("documentDanger"), "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			row = row + 1
			draw.SimpleText("[" .. DangerLevel .. "]", "TVCD", h / 3.1, rowSize * row, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if row < 13 then -- Offset to align everything
				row = 13
			end

			draw.SimpleText(SlashCo.Language("documentAttFile"), "TVCD", h / 100, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			local rating = SlashCo.GetDocumentRating(document.Name)
			local star = 0
			for k=1, rating do
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(starFilled)
				surface.DrawTexturedRect(w / 1.275 + (w / 17 * star), rowSize * row - (h / 17.5 / 2), w / 17.5, h / 17.5)
				star = star + 1

				if star > 3 then break end
			end

			if star < 3 then -- Draw remaining stars
				for k=star, 2 do
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(starUnfilled)
					surface.DrawTexturedRect(w / 1.275 + (w / 17 * star), rowSize * row - (h / 17.5 / 2), w / 17.5, h / 17.5)
					star = star + 1
				end
			end

			row = row + 2
			for _, rowText in ipairs(descriptionRows) do
				draw.SimpleText(rowText, "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)
				row = row + 1
			end

			row = row + 1
			if rating != 0 then
				for _, rowText in ipairs(additionalDescriptionRows) do
					draw.SimpleText(rowText, "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)
					row = row + 1
				end
			else
				draw.SimpleText(SlashCo.Language("documentSurvive"), "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)
			end

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(w - (w / 2.8), h - (h / 1.02), w / 3, h / 3)

			if IsPressing(MOUSE_RIGHT) then
				SwitchSelection("Slashers", true)
			end
		end
	end

	for _, perk in ipairs(SlashCo.GetPerks()) do
		local icon = Material(perk.Icon)
		local descriptionRows = SplitTextIntoRows(SlashCo.Language(perk.Description), "TVCD", screenSize / 1.01)
		local buyText = SlashCo.Language("perk_buy")
		local enableText = SlashCo.Language("perk_enable")
		local disableText = SlashCo.Language("perk_disable")
		local wasHit = false -- RaphaelIT7: Will have a 1 tick render delay but who cares
		local allowedColor = Color(100, 255, 100)
		local deniedColor = Color(255, 100, 100)
		local unpressed = true
		selection["Perk-" .. perk.ID] = function(w, h)
			local row = 1
			local rowSize = w / 28
			draw.SimpleText(SlashCo.Language("perk_nameui") .. SlashCo.Language(perk.Name) .. "\"", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			row = row + 1
			draw.SimpleText(SlashCo.Language("perk_priceui") .. perk.Price .. "P", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			row = row + 1
			draw.SimpleText(SlashCo.Language("perk_teamui") .. team.GetName(perk.Team), "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(w - (w / 2.8), h - (h / 1.02), w / 3, h / 3)

			local textColor = color_white
			if wasHit then
				textColor = perk.Price > GameData.LocalPlayer:GetPoints() and deniedColor or allowedColor
			end

			local text = buyText
			if SlashCo.OwnsPerk(GameData.LocalPlayer, perk.ID) then
				text = SlashCo.IsActivePerk(GameData.LocalPlayer, perk.ID) and disableText or enableText
			end

			surface.SetFont("TVCDMedium")
			local width = surface.GetTextSize(text)

			row = row + 2
			wasHit = DrawTextWithHitbox("[" .. text .. "]", "TVCDMedium", (h / 30) + (width / 2), rowSize * row, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			row = row + 5
			draw.SimpleText(SlashCo.Language("perk_descui"), "TVCD", h / 100, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

			row = row + 1
			for _, rowText in ipairs(descriptionRows) do
				draw.SimpleText(rowText, "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)
				row = row + 1
			end

			if wasHit then
				if IsPressing(MOUSE_LEFT) and unpressed then
					unpressed = false

					if text == buyText then
						SlashCo.BuyPerk(perk.ID)
					elseif text == enableText then
						SlashCo.EnablePerk(perk.ID)
					else -- disable
						SlashCo.DisablePerk(perk.ID)
					end
				elseif not IsPressing(MOUSE_LEFT) and not unpressed then
					unpressed = true
				end
			end

			if IsPressing(MOUSE_RIGHT) then
				SwitchSelection("Perks", true)
			end
		end
	end
end
hook.Add("SlashCo:GameContentChanged", "SlashCo:GenerateDocuments", GenerateDocuments)
hook.Add("SlashCo:LanguageChanged", "SlashCo:GenerateDocuments", GenerateDocuments)
GenerateDocuments()

local function GetDocumentScreenPos()
	local pos = GetGlobal2Vector("SlashCo:DocumentUIPos", vector_origin)
	if pos:IsZero() then
		return nil, nil
	end

	local ang = GetGlobal2Angle("SlashCo:DocumentUIAng", angle_zero)
	return pos, ang
end

GameData.CurrentDocumentScroll = GameData.CurrentDocumentScroll or 0
hook.Add("PostDrawOpaqueRenderables", "SlashCo:LobbyDocumentScreen", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
	if not GameData.IsLobby or GameData.LocalPlayer:Team() == TEAM_SPECTATOR then
		return
	end

	if not screenPos or SlashCo.MapTools.IsEnabled(true) then
		local networkPos, networkAng = GetDocumentScreenPos()
		if not networkPos then return end

		screenAngle = networkAng
		screenUp = screenAngle:Up()

		local halfSize = screenSize * worldScale / 2
		local right = screenAngle:Right()
		local forward = screenAngle:Forward()

		screenPos = networkPos - right * halfSize - forward * halfSize
	end

	if not screenPos or not screenAngle or not screenUp then return end

	--debugoverlay.Sphere(rawScreenPos, 10, 1, Color(255, 0, 0), false)
	--debugoverlay.Sphere(screenPos, 10, 1, Color(0, 255, 0), false)

	playerShootPos = GameData.LocalPlayer:GetShootPos()

	playerAimVec = GameData.LocalPlayer:GetAimVector()
	local isFacing = playerAimVec:Dot(screenUp) < -0.3 -- We have to do this before we multiply the vector.
	playerAimVec:Mul(500)

	cam.Start3D2D(screenPos, screenAngle, worldScale)
		local w, h = screenSize, screenSize

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText(SlashCo.Language("documentUI_one"), "TVCD", w, (h / 2), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT)
		draw.SimpleText(SlashCo.Language("documentUI_two"), "TVCD", w, (h / 2) + (h / 20), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT)

		-- Debug to check screen Mins/Maxs values
		-- debugoverlay.BoxAngles( screenPos, screenMins, screenMaxs, screenAngle, 0.02, hitPos != nil and Color(0,255,0) or Color( 255,0, 0, 10) )

		if GameData.LocalPlayer:EyePos():DistToSqr(screenPos) < 50000 and isFacing then
			if wasLeftMousePressed and not input.IsButtonDown(MOUSE_LEFT) then
				wasLeftMousePressed = false
			end

			if wasRightMousePressed and not input.IsButtonDown(MOUSE_RIGHT) then
				wasRightMousePressed = false
			end

			if GameData.DocumentMouseWheelDelta then
				GameData.CurrentDocumentScroll = (GameData.CurrentDocumentScroll or 0) + (GameData.DocumentMouseWheelDelta * 2)
				GameData.DocumentMouseWheelDelta = nil
			end

			local drawFunc = selection[GameData.DocumentOption]
			if not drawFunc then -- Our option was invalid, fall back to the set fallback.
				GameData.DocumentOption = fallBackOption
				drawFunc = selection[GameData.DocumentOption]
			end

			if drawFunc then
				callID = 0
				drawFunc(w, h)
			end

			local hitPos = util.IntersectRayWithOBB(playerShootPos, playerAimVec, screenPos, screenAngle, Vector(0, -(w * worldScale), -1), Vector(w * worldScale, 0, 0))
			if hitPos then
				-- debugoverlay.BoxAngles(screenPos, Vector(0, -(w * worldScale), 0), Vector(w * worldScale, 0, 1), screenAngle, 0.02, Color(0, 255, 0, 10))
				surface.SetDrawColor(255, 255, 255, 255)
				hitPos = WorldToLocal(hitPos, Angle(), screenPos, screenAngle)
				hitPos:Div(worldScale)
				surface.DrawRect(hitPos.x - 2, -(hitPos.y - 2), 4, 4)
			end
		else
			--GameData.DocumentOption = fallBackOption -- Reset.
		end
	cam.End3D2D()
end)