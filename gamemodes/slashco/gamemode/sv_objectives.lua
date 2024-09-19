util.AddNetworkString("SlashCoUpdateObjectives")

local objectives = {}

---send the objectives table to everyone
function SlashCo.SendObjectives()
	net.Start("SlashCoUpdateObjectives")
	net.WriteUInt(#objectives, 8)
	for k, v in ipairs(objectives) do
		net.WriteString(v.name)
		net.WriteUInt(v.status, 4)

		if SlashCo.Objectives[v.name].hasCount then
			net.WriteUInt(v.count, 16)
		end
	end

	net.Send(team.GetPlayers(TEAM_SURVIVOR))
end

---add or update an objective
function SlashCo.UpdateObjective(name, status, count, dontOverrideComplete)
	if not SlashCo.Objectives[name] then
		return
	end

	local item
	for k, v in ipairs(objectives) do
		if v.name == name then
			item = v
			break
		end
	end

	if not item then
		if SlashCo.Objectives[name].hasCount and not count then
			return
		end

		item = {}
		table.insert(objectives, item)
	end

	item.name = name
	item.count = count or item.count

	if dontOverrideComplete and item.status == SlashCo.ObjStatus.COMPLETE then
		return
	end

	item.status = status or item.status
end

---remove all objectives with a particular name
function SlashCo.RemoveObjective(name)
	for k, v in ipairs(objectives) do
		if v.name == name then
			table.remove(objectives, k)
			break
		end
	end
end

---set every unpassed optional objective to failed
function SlashCo.FailOptionalObjectives()
	for _, v in ipairs(objectives) do
		if v.status == SlashCo.ObjStatus.INCOMPLETE and SlashCo.Objectives[v.name].optional then
			v.status = SlashCo.ObjStatus.FAILED
		end
	end

	SlashCo.CannotCompleteOptionalObjectives = true
end