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

local screenAngle = Angle(0, -180, 90)
local screenPos = Vector(850, 127, -65)
local screenSize = 800
local worldScale = 0.15  -- Scale factor to convert from screen pixels to world units
local screenMins = Vector(0, 0, 0)
local screenMaxs = Vector(screenSize * worldScale, -screenSize * worldScale, 1)

local unknownIcon = Material("slashco/ui/icons/slasher/s_0")
local starFilled = Material("slashco/ui/star_filled")
local starUnfilled = Material("slashco/ui/star_unfilled")
local pointer = 0
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
		cacheEntry.mins = Vector(-(width * worldScale / 2), -(height * worldScale / 2), 0)
		cacheEntry.maxs = Vector((width * worldScale) / 2, (height * worldScale) / 2, 1)

		local pos = screenPos * 1
		pos[1] = pos[1] - (x * worldScale)
		pos[3] = pos[3] - (y * worldScale)
		cacheEntry.pos = pos
	end

	local hitPos = util.IntersectRayWithOBB(playerShootPos, playerAimVec, cacheEntry.pos, screenAngle, cacheEntry.mins, cacheEntry.maxs)

	-- Debug to check the text hitboxes
	-- debugoverlay.BoxAngles(cacheEntry.pos, cacheEntry.mins, cacheEntry.maxs, screenAngle, 0.02, Color(0, 255, 0))

	callID = callID + 1
	return hitPos != nil
end

local fallBackOption = "Selection"
GameData.DocumentOption = GameData.DocumentOption or fallBackOption
local wasLeftMousePressed = false
local wasRightMousePressed = false
SlashCo.AudioSystem.PrecacheSound("slashco/ui/terminalbutton_1.mp3", "mono", "DocumentRightClick")
SlashCo.AudioSystem.PrecacheSound("slashco/ui/terminalbutton_2.mp3", "mono", "DocumentLeftClick")
local function SwitchSelection(newSelection, isRightMouse)
	GameData.DocumentOption = newSelection

	if isRightMouse then
		wasRightMousePressed = true
	else
		wasLeftMousePressed = true
	end

	SlashCo.AudioSystem.GetPrecachedChannel(isRightMouse and "DocumentRightClick" or "DocumentLeftClick", function(channel)
		channel:Play()
	end)
end

local function IsPressing(mouse)
	if mouse == MOUSE_RIGHT then
		return not wasRightMousePressed and input.IsButtonDown(mouse)
	end

	return not wasLeftMousePressed and input.IsButtonDown(mouse)
end

local selection = {
	["Selection"] = function(w, h)
		if DrawTextWithHitbox("[SLASHERS]", "TVCDBig", w / 2, (h / 2) - (h / 6), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
			pointer = 0
		end

		if DrawTextWithHitbox("[LOCATIONS]", "TVCDBig", w / 2, (h / 2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
			pointer = 1
		end

		if DrawTextWithHitbox("[ARCHIVE]", "TVCDBig", w / 2, (h / 2) + (h / 6), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
			pointer = 2
		end

		local pointerPos = h / 2
		if pointer == 0 then
			pointerPos = pointerPos - (h / 6)
		elseif pointer == 2 then
			pointerPos = pointerPos + (h / 6)
		end

		draw.SimpleText("<", "TVCDBig", w - (w / 16), pointerPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if IsPressing(MOUSE_LEFT) then
			if pointer == 0 then
				SwitchSelection("Slashers")
			elseif pointer == 1 then
				SwitchSelection("Locations")
			elseif pointer == 2 then
				SwitchSelection("Archive")
			end
		end
	end, 
	["Slashers"] = function(w, h) -- BUG: This will work fine for under 20 slashers. Have more and we'll got a problem as it'll go out of screen. Issue: We currently have exactly 20 slashers... well...
		local row = 0
		local count = 1
		local rowSplit = 10 -- number of rows before it's split into a new one
		local documents = {}
		for _, document in SortedPairs(SlashCoDocumentTypes["Slasher"] or {}) do
			local hasDocument = SlashCo.HasDocument(document.Name)
			if DrawTextWithHitbox("[" .. string.upper(hasDocument and document.Name or " ??? ") .. "]", "TVCDMedium", w / 5 + (row * w / 2.1), (h / 18) * count, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) then
				pointer = count + (row * rowSplit) -- if we changed rows, we need to 
			end

			table.insert(documents, document)
			count = count + 1
			if count > rowSplit then
				count = 1
				row = row + 1
			end
		end

		local selectedDocument = documents[pointer]
		if not selectedDocument then
			pointer = 1 -- In case the pointer managed to be invalid?!?
			selectedDocument = documents[pointer]
		end

		local pointerRow = math.floor(pointer / rowSplit)
		local pointerCount = pointer - (pointerRow * rowSplit) -- minimum value is 1
		if pointerCount == 0 and pointerRow > 0 then
			pointerRow = pointerRow - 1
			pointerCount = rowSplit
		end

		draw.SimpleText("<", "TVCDMedium", w / 2.3 + (pointerRow * w / 2.1), (h / 18) * pointerCount, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- After the code above, we expect selectedDocument to NEVER be nil.
		local slasher = SlashCo.HasDocument(selectedDocument.Name) and SlashCoSlashers[selectedDocument.Slasher] or nil

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(slasher and Material("slashco/ui/icons/slasher/s_" .. slasher.ID) or unknownIcon)
		surface.DrawTexturedRect(w / 20, h - (h / 2.7), w / 3, h / 3)

		draw.SimpleText("[" .. string.upper(slasher and slasher.Name or "UNKNOWN") .. "]", "TVCDMediumBig", h / 1.45, w / 1.3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if slasher then
			draw.SimpleText(string.upper(SlashCo.DangerLevel[slasher.DangerLevel] .. " " .. SlashCo.SlasherClass[slasher.Class]), "TVCDMedium", h / 1.45, w / 1.17, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("ENCOUNTER SLASHER TO UNLOCK ENTRY", "TVCDSmall", h / 1.45, w / 1.17, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if IsPressing(MOUSE_LEFT) and slasher then
			SwitchSelection("Slasher-" .. selectedDocument.Name)
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
}

local function SplitTextIntoRows(text, font, maxRowWidth)
	surface.SetFont(font)
	local splitDescription = string.Split(text, " ")
	local descriptionRows = {}
	local currentRow = ""
	for _, word in ipairs(splitDescription) do
		local prevText = currentRow
		currentRow = currentRow .. " " .. word

		local width, _ = surface.GetTextSize(currentRow)
		if width > maxRowWidth then
			table.insert(descriptionRows, prevText:Trim())
			currentRow = word
		end
	end

	table.insert(descriptionRows, currentRow:Trim())

	return descriptionRows
end

for _, document in pairs(SlashCoDocumentTypes["Slasher"] or {}) do
	local slasher = SlashCoSlashers[document.Slasher]
	if not slasher then continue end -- No slasher? Then something is invalid

	local descriptionRows = SplitTextIntoRows(document.Description, "TVCD", screenSize / 1.01)
	local additionalDescriptionRows = SplitTextIntoRows(document.AdditionalDescription, "TVCD", screenSize / 1.01)

	local icon = Material("slashco/ui/icons/slasher/s_" .. slasher.ID)
	selection["Slasher-" .. document.Name] = function(w, h)
		local row = 1
		local rowSize = w / 32
		draw.SimpleText("ENTRY: \"" .. slasher.Name .. "\"", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

		row = row + 1
		draw.SimpleText("ALIASES:", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

		for _, name in ipairs(slasher.Aliases or {}) do
			row = row + 1
			draw.SimpleText("\"" .. name .. "\"", "TVCD", h / 3.1, rowSize * row, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		row = row + 1
		draw.SimpleText("CLASS:", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

		row = row + 1
		draw.SimpleText("[" .. string.upper(SlashCo.SlasherClass[slasher.Class]) .. "]", "TVCD", h / 3.1, rowSize * row, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		row = row + 1
		draw.SimpleText("DANGER LVL:", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

		row = row + 1
		draw.SimpleText("[" .. string.upper(SlashCo.DangerLevel[slasher.DangerLevel]) .. "]", "TVCD", h / 3.1, rowSize * row, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if row < 13 then -- Offset to align everything
			row = 13
		end

		draw.SimpleText("[VIEW ATTACHED FILE]", "TVCD", h / 100, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)

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
			draw.SimpleText("[SURVIVE SLASHER FOR MORE INFO]", "TVCD", h / 75, rowSize * row, color_white, 0, TEXT_ALIGN_CENTER)
		end

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(w - (w / 2.8), h - (h / 1.02), w / 3, h / 3)

		if IsPressing(MOUSE_RIGHT) then
			SwitchSelection("Slashers", true)
		end
	end
end

hook.Add("PostDrawOpaqueRenderables", "LobbyDocumentScreen", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
	if not GameData.IsLobby then
		return
	end

	playerShootPos = GameData.LocalPlayer:GetShootPos()
	playerAimVec = GameData.LocalPlayer:GetAimVector() * 500

	cam.Start3D2D(screenPos, screenAngle, worldScale)
		local w, h = screenSize, screenSize

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText("[Left Click] = Enter Page", "TVCD", w * 1.55, (h / 2), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
		draw.SimpleText("[Right Click] = Exit Page", "TVCD", w * 1.55, (h / 2) + (h / 20), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)

		-- Debug to check screen Mins/Maxs values
		-- debugoverlay.BoxAngles( screenPos, screenMins, screenMaxs, screenAngle, 0.02, hitPos != nil and Color(0,255,0) or Color( 255,0, 0, 10) )

		if GameData.LocalPlayer:EyePos():DistToSqr(screenPos) < 50000 then
			if wasLeftMousePressed and not input.IsButtonDown(MOUSE_LEFT) then
				wasLeftMousePressed = false
			end

			if wasRightMousePressed and not input.IsButtonDown(MOUSE_RIGHT) then
				wasRightMousePressed = false
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
		else
			GameData.DocumentOption = fallBackOption -- Reset.
		end
	cam.End3D2D()
end)