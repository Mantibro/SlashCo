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

	if SlashCoItems[item] and SlashCoItems[item].OnDrop then

		local time = 0.18
		if SlashCoItems[item].IsSecondary then
			ply:ViewPunch(Angle(-6, 0, 0))
			ply:SetNWString("item2", "none")
			time = 0.25
		else
			ply:ViewPunch(Angle(-2, 0, 0))
			ply:SetNWString("item", "none")
		end
		timer.Simple(time, function()
			if not IsValid(ply) then
				return
			end

			ply:ItemFunction2("OnSwitchFrom", item, self)

			local height, dontDrop, dontPush = ply:ItemFunction2("OnDrop", item)
			if dontDrop then
				return
			end

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
	end
end

SlashCo.RemoveItem = function(ply, isSec)
	local slot = isSec and "item2" or "item"
	local item = ply:GetNWString(slot, "none")
	timer.Simple(isSec and 0.25 or 0.18, function()
		if (SlashCoItems[item] and SlashCoItems[item].OnSwitchFrom) then
			SlashCoItems[item].OnSwitchFrom(ply)
		end
	end)
	ply:SetNWString(slot, "none")
end

SlashCo.ChangeSurvivorItem = function(ply, id)
	if CLIENT then
		return
	end

	if SlashCoItems[id] then
		if SlashCoItems[id].OnPickUp then
			SlashCoItems[id].OnPickUp(ply)
		end

		if SlashCoItems[id].IsSecondary then
			local item = ply:GetNWString("item2", "none")
			if (SlashCoItems[item] and SlashCoItems[item].OnSwitchFrom) then
				SlashCoItems[item].OnSwitchFrom(ply)
			end
			ply:SetNWString("item2", id)
		else
			local item = ply:GetNWString("item", "none")
			if (SlashCoItems[item] and SlashCoItems[item].OnSwitchFrom) then
				SlashCoItems[item].OnSwitchFrom(ply)
			end
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

SlashCo.ItemPickUp = function(ply, item, itid)
	if CLIENT then
		return
	end

	if SlashCoItems[itid].IsSecondary and ply:GetNWString("item2", "none") ~= "none"
			or not SlashCoItems[itid].IsSecondary and ply:GetNWString("item", "none") ~= "none" then
		return
	end

	SlashCo.ChangeSurvivorItem(ply, itid)

	ents.GetByIndex(item):Remove()

	return true
end