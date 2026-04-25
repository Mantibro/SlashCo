SlashCo.Perks = SlashCo.Perks or {}

function SlashCo.RegisterPerk(table, perkID)
	if SC_LOADEDPERKS then
		error("Tried to register a perk illegally", 2)
		return
	end

	if not SlashCo.Perks[table.Team] then
		SlashCo.Perks[table.Team] = {}
	end

	SlashCo.Perks[perkID] = table
	SlashCo.Perks[table.Team][perkID] = table
end

function SlashCo.GetPerk(perkID)
	return SlashCo.Perks[perkID]
end

function SlashCo.GetPerks()
	local perks = {}
	for _, perk in pairs(SlashCo.Perks) do
		if not perk.ID then continue end

		table.insert(perks, perk)
	end

	return perks
end

local function GetPerks(team, perks)
	local results = {}
	local perks = string.Explode(perks, ",")
	if team ~= TEAM_SURVIVOR and team ~= TEAM_SLASHER then return {} end -- No valid team - GG

	for _, perk in ipairs(perks) do
		local perkTbl = SlashCo.Perks[team][perk]
		if perkTbl then
			table.insert(results, perk)
			results[perk] = perkTbl
		end
	end

	return results
end

function SlashCo.GetActivePerks(ply)
	return GetPerks(ply:Team(), ply:GetActivePerks())
end

function SlashCo.GetOwnedPerks(ply)
	return GetPerks(ply:Team(), ply:GetOwnedPerks())
end

function SlashCo.OwnsPerk(ply, perkID)
	return string.find(ply:GetOwnedPerks(), perkID) ~= nil
end

function SlashCo.IsActivePerk(ply, perkID)
	return string.find(ply:GetActivePerks(), perkID) ~= nil
end

local plyMeta = FindMetaTable("Player")
function plyMeta:PerkValue(valueName, fallback)
	local activePerks = SlashCo.GetActivePerks(self)
	for _, perk in ipairs(activePerks) do
		local perkValue = activePerks[perk][valueName]
		if perkValue ~= nil then
			return perkValue
		end
	end

	return fallback
end

if SERVER then
	-- RaphaelIT7: Hacky but functional, somehow empty entires can end up inside - so we EXTERMINATE them >:3
	local function RemoveEmptyEntires(perkTable)
		for id, entry in ipairs(perkTable) do
			if entry == "" or entry == "," then
				table.remove(perkTable, id)
			end
		end
	end

	local function BuyPerk(ply, perkID)
		if SlashCo.OwnsPerk(ply, perkID) then return end

		local price = SlashCo.GetPerk(perkID).Price
		if price > ply:GetPoints() then return end

		SlashCoDatabase.UpdateStats(ply:SteamID64(), "Points", -price)

		local perks = string.Explode(ply:GetOwnedPerks(), ",")
		table.insert(perks, perkID)
		RemoveEmptyEntires(perks)

		SlashCoDatabase.UpdateStats(ply:SteamID64(), "OwnedPerks", table.concat(perks, ","))
	end

	local function EnablePerk(ply, perkID)
		if SlashCo.IsActivePerk(ply, perkID) then return end
		if not SlashCo.OwnsPerk(ply, perkID) then return end

		local perks = string.Explode(ply:GetActivePerks(), ",")
		table.insert(perks, perkID)
		RemoveEmptyEntires(perks)

		SlashCoDatabase.UpdateStats(ply:SteamID64(), "ActivePerks", table.concat(perks, ","))
	end

	local function DisablePerk(ply, perkID)
		if not SlashCo.IsActivePerk(ply, perkID) then return end

		local perks = string.Explode(ply:GetActivePerks(), ",")
		for id, perk in ipairs(perks) do
			if perk.ID == perkID then
				table.remove(perk, id)
				break
			end
		end
		RemoveEmptyEntires(perks)

		SlashCoDatabase.UpdateStats(ply:SteamID64(), "ActivePerks", table.concat(perks, ","))
	end

	util.AddNetworkString("SlashCo:UpdatePerks")
	net.Receive("SlashCo:UpdatePerks", function(_, ply)
		local type = net.ReadUInt(2)
		local perkID = net.ReadString()
		
		if type == 0 then
			BuyPerk(ply, perkID)
		elseif type == 1 then
			EnablePerk(ply, perkID)
		elseif type == 2 then
			DisablePerk(ply, perkID)
		end
	end)
else
	function SlashCo.BuyPerk(perkID)
		net.Start("SlashCo:UpdatePerks")
			net.WriteUInt(0, 2)
			net.WriteString(perkID)
		net.SendToServer()
	end

	function SlashCo.EnablePerk(perkID)
		net.Start("SlashCo:UpdatePerks")
			net.WriteUInt(1, 2)
			net.WriteString(perkID)
		net.SendToServer()
	end

	function SlashCo.DisablePerk(perkID)
		net.Start("SlashCo:UpdatePerks")
			net.WriteUInt(2, 2)
			net.WriteString(perkID)
		net.SendToServer()
	end
end

function SlashCo.LoadPerks()
	SC_LOADEDPERKS = nil
	for _, v in ipairs(file.Find("slashco/perks/*.lua", "LUA")) do
		AddCSLuaFile("slashco/perks/" .. v)
		include("slashco/perks/" .. v)
	end
	SC_LOADEDPERKS = true
end
hook.Add("SlashCo:GameContentChanged", "SlashCo:RefreshPerks", SlashCo.LoadPerks)
SlashCo.LoadPerks()