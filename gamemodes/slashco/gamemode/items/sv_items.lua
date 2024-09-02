local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

SlashCo.UseItem = function(ply)
	if CLIENT then
		return
	end

	if game.GetMap() == "sc_lobby" then
		return
	end

	if ply:Team() ~= TEAM_SURVIVOR then
		return
	end

	if ply:IsFrozen() then
		return
	end

	local item = ply:GetNWString("item2", "none")
	if item == "none" then
		item = ply:GetNWString("item", "none")
	end

	if SlashCoItems[item] and SlashCoItems[item].OnUse then
		local doNotRemove = SlashCoItems[item].OnUse(ply)
		if not doNotRemove then
			SlashCo.ChangeSurvivorItem(ply, "none")
		end
	end
end

SlashCo.DropAllItems = function(ply, noEffect)
	if not noEffect then
		ply:ClearEffect()
	end

	if ply:GetNWString("item2", "none") ~= "none" then
		SlashCo.DropItem(ply)
	end

	SlashCo.DropItem(ply)
end

SlashCo.DropItem = function(ply)
	if CLIENT then
		return
	end

	if game.GetMap() == "sc_lobby" then
		return
	end

	if ply:Team() ~= TEAM_SURVIVOR then
		return
	end

	if ply:IsFrozen() then
		return
	end

	local item = ply:GetNWString("item2", "none")
	if item == "none" then
		item = ply:GetNWString("item", "none")
	end

	if not SlashCoItems[item] then
		return
	end

	local dontDrop = ply:ItemFunction2("PreDrop", item)
	if dontDrop then
		return
	end

	local time = 0.18
	if SlashCoItems[item].IsSecondary then
		local dontDrop1 = ply:ItemFunction("PreDropSecondary", item)
		if dontDrop1 then
			return
		end

		ply:ViewPunch(Angle(-6, 0, 0))
		ply:SetNWString("item2", "none")
		time = 0.25
	else
		ply:ViewPunch(Angle(-2, 0, 0))
		ply:SetNWString("item", "none")
	end

	timer.Create("SlashCoItemSwitch_" .. ply:UserID(), time, 1, function()
		if not IsValid(ply) then
			return
		end

		local height, dontDrop1, dontPush = ply:ItemFunction2("OnDrop", item)
		if dontDrop1 then
			return
		end

		ply:ItemFunction2("OnSwitchFrom", item)

		local droppeditem = SlashCo.CreateItem(SlashCoItems[item].EntClass,
				ply:LocalToWorld(Vector(0, 0, height or 60)),
				ply:LocalToWorldAngles(Angle(0, 0, 0)))
		local ent = Entity(droppeditem)
		local phys = ent:GetPhysicsObject()

		if not dontPush and IsValid(phys) then
			phys:SetVelocity(ply:GetAimVector() * 250)
			local randomvec = Vector(0, 0, 0)
			randomvec:Random(-1000, 1000)
			phys:SetAngleVelocity(randomvec)
		end

		ply:ItemFunction2("ItemDropped", item, ent, phys)

		if not SlashCoItems[item].IsSecondary then
			SlashCo.CurRound.Items[droppeditem] = true
		end
	end)

	ply.LastDroppedItem = item
	ply.LastDroppedItemTime = CurTime()
end

SlashCo.RemoveItem = function(ply, isSec)
	local slot = isSec and "item2" or "item"
	local item = ply:GetNWString(slot, "none")
	timer.Create("SlashCoItemSwitch_" .. ply:UserID(), isSec and 0.25 or 0.18, 1, function()
		if IsValid(ply) then
			ply:ItemFunction2("OnSwitchFrom", item)
		end
	end)
	ply:SetNWString(slot, "none")
end

SlashCo.ChangeSurvivorItem = function(ply, id)
	if SlashCoItems[id] then
		if SlashCoItems[id].OnPickUp then
			SlashCoItems[id].OnPickUp(ply)
		end

		if SlashCoItems[id].IsSecondary then
			local item = ply:GetNWString("item2", "none")
			ply:ItemFunction2("OnSwitchFrom", item)
			ply:SetNWString("item2", id)
		else
			local item = ply:GetNWString("item", "none")
			ply:ItemFunction2("OnSwitchFrom", item)
			ply:SetNWString("item", id)
		end

		if SlashCoItems[id].EquipSound then
			ply:EmitSound(SlashCoItems[id].EquipSound())
		else
			ply:EmitSound("slashco/survivor/item_equip" .. math.random(1, 2) .. ".mp3")
		end
	elseif id == "none" then
		ply:SetNWString("item", "none")
	end
end

SlashCo.ItemPickUp = function(ply, itemindex, item)
	if SlashCoItems[item].IsSecondary and ply:GetNWString("item2", "none") ~= "none"
			or not SlashCoItems[item].IsSecondary and ply:GetNWString("item", "none") ~= "none" then
		return
	end

	if ply.LastDroppedItem == item and CurTime() - ply.LastDroppedItemTime < 1 then
		return
	end

	if timer.Exists("SlashCoItemSwitch_" .. ply:UserID()) then
		return
	end

	local dontPickup = ply:ItemFunction2("PrePickUp", item)
	if dontPickup then
		return
	end

	local dontPickup1 = ply:SecondaryItemFunction("PrePickUpPrimary", item)
	if dontPickup1 then
		return
	end

	local dontPickup2 = ply:ItemFunction("PrePickUpSecondary", item)
	if dontPickup2 then
		return
	end

	local itemEnt = ents.GetByIndex(itemindex)

	if IsValid(itemEnt.SpawnedAt) then
		itemEnt.SpawnedAt:TriggerOutput("OnPickedUp", ply)
		itemEnt.SpawnedAt.SpawnedEntity = nil
	end

	SlashCo.ChangeSurvivorItem(ply, item)
	itemEnt:Remove()

	return true
end