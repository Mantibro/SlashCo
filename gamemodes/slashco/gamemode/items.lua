local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

SlashCo.GetHeldItem = function(ply)
	local id = ply:SteamID64()

	if not SlashCo.CurRound.SurvivorData.Items[id] then
		return "none"
	end

	return SlashCo.CurRound.SurvivorData.Items[id]
end

SlashCo.UseItem = function(ply)

	if SERVER then

		if game.GetMap() == "sc_lobby" then
			return
		end

		if ply:Team() ~= TEAM_SURVIVOR then
			return
		end

		if ply:IsFrozen() then
			return
		end

		local itid = SlashCo.GetHeldItem(ply)

		if SlashCoItems[itid] and SlashCoItems[itid].OnUse then
			local doNotRemove = SlashCoItems[itid].OnUse(ply)
			if not doNotRemove then SlashCo.ChangeSurvivorItem(ply, "none") end
		end

	end

end

SlashCo.DropItem = function(ply)

	if SERVER then

		if game.GetMap() == "sc_lobby" then
			return
		end

		if ply:Team() ~= TEAM_SURVIVOR then
			return
		end

		if ply:IsFrozen() then
			return
		end

		local itid = SlashCo.GetHeldItem(ply)

		if SlashCoItems[itid] and SlashCoItems[itid].OnDrop then
			SlashCoItems[itid].OnDrop(ply)
			SlashCo.BroadcastSelectables()
			SlashCo.ChangeSurvivorItem(ply, "none")
		end

	end

end

SlashCo.ChangeSurvivorItem = function(ply, id)

	if SERVER then

		local plyid = ply:SteamID64()

		if SlashCoItems[id] then
			SlashCo.CurRound.SurvivorData.Items[plyid] = id

			if (SlashCoItems[id].OnPickUp) and game.GetMap() ~= "sc_lobby" then
				SlashCoItems[id].OnPickUp(ply)
			end

			if id ~= 0 then
				ply:EmitSound("slashco/survivor/item_equip" .. math.random(1, 2) .. ".mp3")
			end
		elseif id == "none" then
			SlashCo.CurRound.SurvivorData.Items[plyid] = id
		end

		SlashCo.BroadcastItemData()
	end

end

SlashCo.ItemPickUp = function(ply, item, itid)

	if SERVER then

		--local ply = player.GetBySteamID64(plyid)

		if SlashCo.GetHeldItem(ply) ~= "none" then
			return
		end

		SlashCo.ChangeSurvivorItem(ply, itid)

		SlashCo.RemoveSelectableNow(item)

		ents.GetByIndex(item):Remove()

	end

end