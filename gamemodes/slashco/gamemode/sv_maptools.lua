SlashCo.MapTools = SlashCo.MapTools or {}
SlashCo.MapTools.MapVersion = SlashCo.MapTools.MapVersion or game.GetMapVersion()
SlashCo.MapTools.UndoHistory = SlashCo.MapTools.UndoHistory or {}
SlashCo.MapTools.LastUndo = SlashCo.MapTools.LastUndo or nil -- Last undo, saved for redo BUT if you do any changes without reapplying this/calling redo this is deleted!
SlashCo.MapTools.HadError = SlashCo.MapTools.HadError or false

local slashco_enablemaptools = GetConVar("slashco_enablemaptools")
function SlashCo.MapTools.IsEnabled(hideWarning) -- Used by all exposed functions
	if not (slashco_enablemaptools and slashco_enablemaptools:GetBool()) then
		if not hideWarning then
			ErrorNoHaltWithStack("[SlashCo] Tried to use map tools while slashco_enablemaptools is disabled!\n")
		end
		return false
	end

	return true
end

local function HadHammerError()
	return SlashCo.MapTools.HadError
end

local function ClearHammerError()
	SlashCo.MapTools.HadError = false
end

local function ExecuteHammerCommand(cmd)
	local result = hammer.SendCommand(cmd)
	if result ~= "ok" then
		SlashCo.MapTools.HadError = true
	end

	return result
end

local function StartSession()
	for k=0, 200 do
		if ExecuteHammerCommand("session_begin " .. game.GetMap() .. " " .. (SlashCo.MapTools.MapVersion + k)) == "ok" then
			SlashCo.MapTools.MapVersion = SlashCo.MapTools.MapVersion + k
			ClearHammerError()
			return "ok"
		end
	end

	ErrorNoHalt("[SlashCo] Hammer failed to start a session!\n")
	return "invalid_session"
end

local function EndSession()
	local result = ExecuteHammerCommand("session_end")
	if result ~= "ok" then
		ErrorNoHalt("[SlashCo] Hammer failed to finish a session!\n")
	end

	return result
end

local function ThreeFloatsToString(obj)
	return string.format("%.3f %.3f %.3f", obj[1], obj[2], obj[3])
end

local function TryToApplyUndoInfo(undoInfo)
	ClearHammerError()
	undoInfo:redoFunc()

	if not HadHammerError() then
		table.insert(SlashCo.MapTools.UndoHistory, undoInfo)
		SlashCo.MapTools.LastUndo = nil
	else
		undoInfo:undoFunc() -- In case it was partially applied
	end
end

--[[
	Below here we have the exposed API!
	Every function always calls first SlashCo.MapTools.IsEnabled

	And Every action is built to be a undoInfo allowing one to easily apply/revert changes
	due to us basically focing changes in hammer with no way to revert them normally as these do not count into the edit history of a map.
]]

function SlashCo.MapTools.SetEntityPosition(ent, newPos)
	if not SlashCo.MapTools.IsEnabled() then return end

	TryToApplyUndoInfo({
		action = "SetEntityPosition",
		oldPos = ent:GetPos(),
		newPos = Vector(newPos), -- Copy so that if the calling code modifies it we won't have out undo history destoryed
		entity = ent,
		entClass = ent:GetClass(),
		undoFunc = function(undo)
			StartSession()

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.newPos) .. " \"origin\" \"" .. ThreeFloatsToString(undo.oldPos) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to revert origin keyvalue! (" .. result .. ")\n")
			end

			if IsValid(undo.entity) then
				undo.entity:SetPos(undo.oldPos)
				if undo.entity.OnMapToolUndo then
					undo.entity:OnMapToolUndo()
				end
			end

			EndSession()
		end,
		redoFunc = function(undo)
			StartSession()

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.oldPos) .. " \"origin\" \"" .. ThreeFloatsToString(undo.newPos) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to revert origin keyvalue! (" .. result .. ")\n")
			end

			if IsValid(undo.entity) then
				undo.entity:SetPos(undo.newPos)
				if undo.entity.OnMapToolRedo then
					undo.entity:OnMapToolRedo()
				end
			end

			EndSession()
		end
	})
end

function SlashCo.MapTools.SetEntityAngle(ent, newAng)
	if not SlashCo.MapTools.IsEnabled() then return end

	TryToApplyUndoInfo({
		action = "SetEntityAngle",
		entPos = ent:GetPos(),
		oldAngle = ent:GetAngles(),
		newAngle = Angle(newAng), -- Copy so that if the calling code modifies it we won't have out undo history destoryed
		entity = ent,
		entClass = ent:GetClass(),
		undoFunc = function(undo)
			StartSession()

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.entPos) .. " \"angles\" \"" .. ThreeFloatsToString(undo.oldAngle) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to revert angles keyvalue! (" .. result .. ")\n")
			end

			if IsValid(undo.entity) then
				undo.entity:SetAngles(undo.oldAngle)
				if undo.entity.OnMapToolUndo then
					undo.entity:OnMapToolUndo()
				end
			end

			EndSession()
		end,
		redoFunc = function(undo)
			StartSession()

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.entPos) .. " \"angles\" \"" .. ThreeFloatsToString(undo.newAngle) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to revert angles keyvalue! (" .. result .. ")\n")
			end

			if IsValid(undo.entity) then
				undo.entity:SetAngles(undo.newAngle)
				if undo.entity.OnMapToolRedo then
					undo.entity:OnMapToolRedo()
				end
			end

			EndSession()
		end
	})
end

function SlashCo.MapTools.SetEntityPositionAndAngle(ent, newPos, newAng)
	if not SlashCo.MapTools.IsEnabled() then return end

	TryToApplyUndoInfo({
		action = "SetEntityPositionAndAngle",
		oldPos = ent:GetPos(),
		newPos = Vector(newPos), -- Copy so that if the calling code modifies it we won't have out undo history destoryed
		oldAngle = ent:GetAngles(),
		newAngle = Angle(newAng),
		entity = ent,
		entClass = ent:GetClass(),
		undoFunc = function(undo)
			StartSession()

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.newPos) .. " \"origin\" \"" .. ThreeFloatsToString(undo.oldPos) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to revert origin keyvalue! (" .. result .. ")\n")
			end

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.oldPos) .. " \"angles\" \"" .. ThreeFloatsToString(undo.oldAngle) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to revert angles keyvalue! (" .. result .. ")\n")
			end

			if IsValid(undo.entity) then
				undo.entity:SetPos(undo.oldPos)
				undo.entity:SetAngles(undo.oldAngle)
				if undo.entity.OnMapToolUndo then
					undo.entity:OnMapToolUndo()
				end
			end

			EndSession()
		end,
		redoFunc = function(undo)
			StartSession()

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.oldPos) .. " \"origin\" \"" .. ThreeFloatsToString(undo.newPos) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to apply origin keyvalue! (" .. result .. ")\n")
			end

			local result = ExecuteHammerCommand("entity_set_keyvalue " .. undo.entClass .. " " .. ThreeFloatsToString(undo.newPos) .. " \"angles\" \"" .. ThreeFloatsToString(undo.newAngle) .. "\"")
			if result ~= "ok" then
				ErrorNoHalt("[SlashCo] Hammer failed to apply angles keyvalue! (" .. result .. ")\n")
			end

			if IsValid(undo.entity) then
				undo.entity:SetPos(undo.newPos)
				undo.entity:SetAngles(undo.newAngle)
				if undo.entity.OnMapToolRedo then
					undo.entity:OnMapToolRedo()
				end
			end

			EndSession()
		end
	})
end

function SlashCo.MapTools.Undo()
	if not SlashCo.MapTools.IsEnabled() then return end

	local top = SlashCo.MapTools.UndoHistory[#SlashCo.MapTools.UndoHistory]
	if not top then
		ErrorNoHalt("[SlashCo] Nothing to undo!\n")
		return
	end

	ClearHammerError()
	top:undoFunc()

	if not HadHammerError() then
		SlashCo.MapTools.LastUndo = top
		table.remove(SlashCo.MapTools.UndoHistory, #SlashCo.MapTools.UndoHistory)
	else
		print("[SlashCo] Undo Info as an error occured! Use this to manually undo your change")
		PrintTable(top)
	end
end

function SlashCo.MapTools.Redo()
	if not SlashCo.MapTools.IsEnabled() then return end

	if not SlashCo.MapTools.LastUndo then
		ErrorNoHalt("[SlashCo] Nothing to redo!\n")
		return
	end

	ClearHammerError()
	SlashCo.MapTools.LastUndo:redoFunc()

	if not HadHammerError() then
		SlashCo.MapTools.LastUndo = nil
		table.insert(SlashCo.MapTools.UndoHistory, SlashCo.MapTools.LastUndo)
	else
		print("[SlashCo] Redo Info as an error occured! Use this to manually redo your change")
		PrintTable(SlashCo.MapTools.LastUndo)
	end
end

concommand.Add("slashco_maptool_undo", function(ply)
	if not ply or (IsValid(ply) and not ply:IsListenServerHost()) then return end

	SlashCo.MapTools.Undo()
end, nil, "Reverts the last change done in hammer as changes applied from GMod cannot be reverted normally in Hammer.")

concommand.Add("slashco_maptool_redo", function(ply)
	if not ply or (IsValid(ply) and not ply:IsListenServerHost()) then return end

	SlashCo.MapTools.Redo()
end, nil, "Applies the last reverted change again")