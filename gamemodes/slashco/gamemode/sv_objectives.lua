util.AddNetworkString("SlashCo:UpdateObjectives")

GameData.Objectives = GameData.Objectives or {}

---send the objectives table to everyone
function SlashCo.SendObjectives()
	net.Start("SlashCo:UpdateObjectives")
	net.WriteUInt(#GameData.Objectives, 8)
	for k, v in ipairs(GameData.Objectives) do
		net.WriteString(v.name)
		net.WriteUInt(v.status, 4)

		if SlashCo.Objectives[v.name].hasCount then
			net.WriteUInt(v.totalCount, 8)
			net.WriteUInt(v.doneCount, 8)
		end
	end

	local plys = {}
	for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		table.insert(plys, ply)
	end

	for _, ply in ipairs(team.GetPlayers(TEAM_SPECTATOR)) do
		table.insert(plys, ply)
	end

	net.Send(plys)
end

---add or update an objective
function SlashCo.UpdateObjective(name, status, count, dontOverrideComplete)
	if not SlashCo.Objectives[name] then
		return
	end

	local item
	for k, v in ipairs(GameData.Objectives) do
		if v.name == name then
			item = v
			break
		end
	end

	if not item then
		item = {}
		if SlashCo.Objectives[name].hasCount then
			if not count then
				ErrorNoHaltWithStack("[SlashCo] Tried to start Objective \"" .. name .. "\" when the count was missing!")
				return
			end

			item.totalCount = count
			item.doneCount = 0
		end

		table.insert(GameData.Objectives, item)
	end

	item.name = name
	if status == SlashCo.ObjStatus.PROGRESS and item.totalCount then
		count = count or 1

		if count then
			item.doneCount = math.min(item.doneCount + count, item.totalCount)

			if item.doneCount == item.totalCount then
				status = SlashCo.ObjStatus.COMPLETE
			end
		else
			status = SlashCo.ObjStatus.COMPLETE
		end
	end

	if dontOverrideComplete and item.status == SlashCo.ObjStatus.COMPLETE then
		return
	end

	if status == SlashCo.ObjStatus.COMPLETE and item.status ~= SlashCo.ObjStatus.COMPLETE then
		hook.Run("SlashCo:OnObjectiveComplete", name)
	end

	item.status = status or item.status
end

---remove all GameData.Objectives with a particular name
function SlashCo.RemoveObjective(name)
	for k, v in ipairs(GameData.Objectives) do
		if v.name == name then
			table.remove(GameData.Objectives, k)
			break
		end
	end
end

---set every unpassed optional objective to failed
function SlashCo.FailOptionalObjectives()
	for _, v in ipairs(GameData.Objectives) do
		if v.status == SlashCo.ObjStatus.INCOMPLETE and SlashCo.Objectives[v.name].optional then
			v.status = SlashCo.ObjStatus.FAILED
		end
	end

	SlashCo.CannotCompleteOptionalObjectives = true
end