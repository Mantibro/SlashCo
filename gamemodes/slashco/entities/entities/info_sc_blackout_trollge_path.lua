--[[
	Map entity meant to only be used in the Lobby.
]]

ENT.Type = "point"

if CLIENT then return end

GameData.TrollgePaths = GameData.TrollgePaths or {}
function ENT:Initialize()
	GameData.TrollgePaths[self.PathName] = self
end

function ENT:OnRemove()
	GameData.TrollgePaths[self.PathName] = nil
end

local PATH_TYPE_START = 0
local PATH_TYPE_MOVE = 1
local PATH_TYPE_DOOR = 2
local PATH_TYPE_FINISH = 3

local PATH_AREA_INSIDE = 0
local PATH_AREA_OUTSIDE = 1

function SlashCo.FindNextBlackoutPath(inside, currentPath, backwards)
	if not currentPath then
		for _, path in pairs(GameData.TrollgePaths) do
			if path.PathType == PATH_TYPE_START then
				if inside and path.PathArea == PATH_AREA_INSIDE then
					return path.PathName, path:GetPos()
				end

				if not inside and path.PathArea == PATH_AREA_OUTSIDE then
					return path.PathName, path:GetPos()
				end
			end
		end

		return nil, nil
	end

	local path = GameData.TrollgePaths[currentPath]
	if not IsValid(path) then return nil, nil end
	if backwards then
		for _, prev in pairs(GameData.TrollgePaths) do
			if prev.NextPath == currentPath then
				return prev.PathName, prev:GetPos(), prev.PathType == PATH_TYPE_DOOR
			end
		end

		return nil, nil
	end

	if not path.NextPath then return nil, nil end

	local nextPath = GameData.TrollgePaths[path.NextPath]
	if not IsValid(nextPath) then return nil, nil end

	return nextPath.PathName, nextPath:GetPos(), nextPath.PathType == PATH_TYPE_DOOR
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "path_type" then
		self.PathType = tonumber(value)
		return
	end

	if key == "path_area" then
		self.PathArea = tonumber(value)
		return
	end

	if key == "path_name" then
		self.PathName = value
		return
	end

	if key == "path_next" then
		self.NextPath = value
		return
	end
end