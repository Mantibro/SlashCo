local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

local function doPrint(ply, text)
	if IsValid(ply) and ply:IsPlayer() then
		ply:ChatPrint(text)
	else
		print(text)
	end
end

concommand.Add("slashco_become_survivor", function(ply, _, args)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	if game.GetMap() == "sc_lobby" then
		doPrint(ply, "Cannot assign a player as a survivor while in the lobby.")
		return
	end

	local target = ply
	if args[1] then
		target = nil

		if tonumber(args[1]) then
			target = Player(tonumber(args[1]))

			if not IsValid(target) then
				target = player.GetBySteamID64(args[1])
			end
		end

		if not IsValid(target) then
			target = player.GetBySteamID(args[1])
		end

		if not IsValid(target) then
			local targetSelect, tooMany
			for _, v in ipairs(player.GetAll()) do
				if string.find(v:Nick(), args[1]) then
					if targetSelect then
						tooMany = true
						break
					end
					targetSelect = v
				end
			end
			if tooMany then
				doPrint(ply, "There's more than one player your arguments apply to.")
				return
			end
			if targetSelect then
				target = targetSelect
			end
		end

		if not IsValid(target) then
			doPrint(ply, "Not a valid target.")
			return
		end
	end

	local id = target:SteamID64()
	local found
	for _, v in ipairs(SlashCo.CurRound.SlasherData.AllSurvivors) do
		if v.id == id then
			found = true
			break
		end
	end

	if not found then
		table.insert(SlashCo.CurRound.SlasherData.AllSurvivors, { id = id, GameContribution = 0 })
	end

	doPrint(ply, "New Survivor successfully assigned.")
	target:SetTeam(TEAM_SURVIVOR)
	target:Spawn()
end, function(cmd)
	--this is for autocomplete

	return {
		cmd .. " [steamid/userid]"
	}
end)

concommand.Add("slashco_become_slasher", function(ply, _, args)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	if game.GetMap() == "sc_lobby" then
		doPrint(ply, "Cannot assign a player as a slasher while in the lobby.")
		return
	end

	if not SlashCoSlashers[args[1]] then
		doPrint(ply, "That slasher doesn't exist.")
		return
	end

	local target = ply
	if args[2] then
		target = nil

		if tonumber(args[2]) then
			target = Player(tonumber(args[2]))

			if not IsValid(target) then
				target = player.GetBySteamID64(args[2])
			end
		end

		if not IsValid(target) then
			target = player.GetBySteamID(args[2])
		end

		if not IsValid(target) then
			local targetSelect, tooMany
			for _, v in ipairs(player.GetAll()) do
				if string.find(v:Nick(), args[2]) then
					if targetSelect then
						tooMany = true
						break
					end
					targetSelect = v
				end
			end
			if tooMany then
				doPrint(ply, "There's more than one player your arguments apply to.")
				return
			end
			if targetSelect then
				target = targetSelect
			end
		end

		if not IsValid(target) then
			doPrint(ply, "Not a valid target.")
			return
		end
	end

	SlashCo.SelectSlasher(args[1], target:SteamID64())
	SlashCo.ApplySlasherToPlayer(target)
	SlashCo.OnSlasherSpawned(target)

	timer.Simple(0.25, function()
		if not IsValid(target) then
			return
		end
		if IsValid(ply) then
			doPrint(ply, "New Slasher successfully assigned.")
		end
		SlashCo.DropAllItems(target)
		target:StripWeapons()
		target:SetTeam(TEAM_SLASHER)
		target:Spawn()
	end)
end, function(cmd, args)
	--this is for autocomplete
	local preArg = string.Trim(args)
	args = string.lower(preArg)
	local tbl = table.GetKeys(SlashCoSlashers)

	local tbl1 = {}
	local elem
	for _, v in ipairs(tbl) do
		--find every item that matches what's inputted
		if string.find(string.lower(v), args) then
			table.insert(tbl1, cmd .. " " .. v)
			elem = v
		end
	end

	if #tbl1 == 1 and preArg == elem then
		tbl1[1] = tbl1[1] .. " [steamid/userid]"
	end

	return tbl1
end)

concommand.Add("slashco_run_curconfig", function()
	SlashCo.StartRound()
end, nil, "Start a normal round with current configs.", FCVAR_PROTECTED)

concommand.Add("slashco_debug_itempicker", function(ply)
	if not IsValid(ply) or not ply:IsPlayer() then
		return
	end

	if not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	SlashCo.SendValue(ply, "openItemPicker")
end, nil, "Open the item picker", FCVAR_CHEAT + FCVAR_PROTECTED)

concommand.Add("slashco_debug_run_curconfig", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	g_SlashCoDebug = true
	SlashCo.StartRound()
end, nil, "Start a debug round with current configs.", FCVAR_CHEAT + FCVAR_PROTECTED)

concommand.Add("slashco_debug_run_survivor", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	g_SlashCoDebug = true
	timer.Simple(0.5, function()
		for _, k in ipairs(player.GetAll()) do
			k:SetTeam(TEAM_SURVIVOR)
			k:Spawn()
			doPrint(ply, k:Name() .. " is now a survivor")
		end
	end)

	SlashCo.StartRound(true)
end, nil, "Start a debug round where everyone is a survivor.", FCVAR_CHEAT + FCVAR_PROTECTED)

--//datatest//--

concommand.Add("slashco_debug_datatest_makedummy", function(ply)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	if CLIENT then
		return
	end

	if not sql.TableExists("slashco_table_basedata") and not sql.TableExists("slashco_table_survivordata") and not sql.TableExists("slashco_table_slasherdata") then
		--Create the database table

		local diff = SlashCo.LobbyData.SelectedDifficulty
		local offer = SlashCo.LobbyData.Offering
		local survivorgasmod = SlashCo.LobbyData.SurvivorGasMod
		--local slasher1id = GetRandomSlasher()
		local slasher1id = "Abomignat"
		local slasher2id = GetRandomSlasher()

		sql.Query("CREATE TABLE slashco_table_basedata(Difficulty NUMBER , Offering NUMBER , SlasherIDPrimary TEXT , SlasherIDSecondary TEXT , SurviorGasMod NUMBER);")
		sql.Query("CREATE TABLE slashco_table_survivordata(Survivors TEXT, Item TEXT);")
		sql.Query("CREATE TABLE slashco_table_slasherdata(Slashers TEXT);")

		sql.Query("INSERT INTO slashco_table_slasherdata( Slashers ) VALUES( 76561198070087838 );")
		sql.Query("INSERT INTO slashco_table_survivordata( Survivors, Item ) VALUES( 90071996842377216, " .. sql.SQLStr("none") .. " );")
		sql.Query("INSERT INTO slashco_table_basedata( Difficulty, Offering, SlasherIDPrimary, SlasherIDSecondary, SurviorGasMod ) VALUES( " .. diff .. ", " .. offer .. ", '" .. slasher1id .. "', '" .. slasher2id .. "', " .. survivorgasmod .. " );")
		doPrint(ply, "Dummy Database made.")
	else
		doPrint(ply, "Database already exists.")
		local baseTable = sql.TableExists("slashco_table_basedata") and "present" or "nil"
		local survivorTable = sql.TableExists("slashco_table_survivordata") and "present" or "nil"
		local slasherTable = sql.TableExists("slashco_table_slasherdata") and "present" or "nil"
		doPrint(ply, "base table: " .. baseTable)
		doPrint(ply, "survivor table: " .. survivorTable)
		doPrint(ply, "slasher table: " .. slasherTable)
	end

	doPrint(ply, sql.LastError())
end, nil, "Make a bare-minimum data table to be able to run a round.", FCVAR_CHEAT + FCVAR_PROTECTED)

concommand.Add("slashco_debug_datatest_read", function(ply)
	if CLIENT then
		return
	end

	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	doPrint(ply, "basedata: ")
	PrintTable(sql.Query("SELECT * FROM slashco_table_basedata; ") or "nil")
	doPrint(ply, "survivordata: ")
	PrintTable(sql.Query("SELECT * FROM slashco_table_survivordata; ") or "nil")
	doPrint(ply, "slasherdata: ")
	PrintTable(sql.Query("SELECT * FROM slashco_table_slasherdata; ") or "nil")
end, nil, "Read out the current data table.", FCVAR_CHEAT + FCVAR_PROTECTED)

concommand.Add("slashco_debug_datatest_error", function(ply, _, _)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	if SERVER then
		doPrint(ply, sql.LastError())
	end
end, nil, "Print the latest data error.", FCVAR_CHEAT + FCVAR_PROTECTED)

concommand.Add("slashco_debug_datatest_delete", function(_, _, _)
	if SERVER then
		SlashCo.ClearDatabase()
	end
end, nil, "Delete the current data table.", FCVAR_CHEAT + FCVAR_PROTECTED)

--//items//--

concommand.Add("slashco_give_item", function(ply, _, args)
	if CLIENT then
		return
	end

	if ply:Team() ~= TEAM_SURVIVOR then
		doPrint(ply, "Only survivors can have items")
		return
	end

	if SlashCoItems[args[1]] then
		SlashCo.ChangeSurvivorItem(ply, args[1])
	else
		SlashCo.ChangeSurvivorItem(ply, "none")
	end
end, function(cmd, args)
	--this is for autocomplete
	args = string.lower(string.Trim(args))
	local tbl = table.GetKeys(SlashCoItems)
	table.insert(tbl, "none")

	local tbl1 = {}
	for _, v in ipairs(tbl) do
		--find every item that matches what's inputted
		if string.find(string.lower(v), args) then
			table.insert(tbl1, cmd .. " " .. v)
		end
	end
	return tbl1
end, "Give yourself an item", FCVAR_CHEAT)

concommand.Add("slashco_debug_printents", function(ply, _, args)
	if IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin() then
		doPrint(ply, "Only admins can use debug commands!")
		return
	end

	local prefix = args[1] or "sc_"
	local prefLength = string.len(prefix)

	local genCount, gasCanCount, batteryCount, otherCount = 0, 0, 0, 0
	local cansNeeded, batsNeeded = 0, 0
	for k, v in ents.Iterator() do
		local class = v:GetClass()
		if string.Left(class, prefLength) ~= prefix then
			continue
		end

		if class == "sc_generator" then
			genCount = genCount + 1
			cansNeeded = cansNeeded + (v.CansRemaining or GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen))
			if not v.HasBattery then
				batsNeeded = batsNeeded + 1
			end
		elseif class == "sc_gascan" then
			gasCanCount = gasCanCount + 1
		elseif class == "sc_battery" then
			batteryCount = batteryCount + 1
		else
			otherCount = otherCount + 1
		end

		local x, y, z = v:GetPos():Unpack()
		x = math.Round(x, 3)
		y = math.Round(y, 3)
		z = math.Round(z, 3)

		local space = string.rep(" ", 16 - string.len(class))

		doPrint(ply, string.format("%s%s\t%s %s %s", class, space, x, y, z))
	end

	if prefix == "sc_" then
		local totalCount = genCount + gasCanCount + batteryCount + otherCount
		doPrint(ply, string.format("total: %s, gens: %s, cans: %s, bats: %s, other: %s", totalCount, genCount, gasCanCount, batteryCount, otherCount))
		doPrint(ply, string.format("cans needed: %s, bats needed: %s", cansNeeded, batsNeeded))
	else
		doPrint(ply, string.format("total: %s", otherCount))
	end
end, nil, "Print all slashco ents on the map", FCVAR_CHEAT + FCVAR_PROTECTED)