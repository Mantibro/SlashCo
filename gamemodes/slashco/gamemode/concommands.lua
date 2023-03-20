local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

concommand.Add( "slashco_run_curconfig", function( _, _, _ )

    SlashCo.LoadCurRoundTeams()

    SlashCo.SpawnCurConfig()

end, nil, "Start a normal round with current configs.", FCVAR_PROTECTED)

concommand.Add( "slashco_debug_run_curconfig", function( ply, _, _ )

    if IsValid(ply) then
        if ply:IsPlayer() then
            if not ply:IsAdmin() then
                ply:ChatPrint("Only admins can use debug commands!")
                return
            end
        end
    end

    SlashCo.LoadCurRoundTeams()

    SlashCo.SpawnCurConfig(true)

end, nil, "Start a debug round with current configs.", FCVAR_CHEAT+FCVAR_PROTECTED)

concommand.Add( "slashco_debug_run_survivor", function( ply, _, _ )

    if IsValid(ply) then
        if ply:IsPlayer() then
            if not ply:IsAdmin() then
                ply:ChatPrint("Only admins can use debug commands!")
                return
            end
        end
    end

    for _, k in ipairs(player.GetAll()) do
        k:SetTeam(TEAM_SURVIVOR)
        k:Spawn()
        print(k:Name() .. " now Survivor")
    end

    timer.Simple(0.05, function()

        print("[SlashCo] Now proceeding with Spawns...")

        SlashCo.PrepareSlasherForSpawning()

        SlashCo.SpawnPlayers()

    end)

    SlashCo.SpawnCurConfig(true)

end, nil, "Start a debug round where everyone is a survivor.", FCVAR_CHEAT+FCVAR_PROTECTED)

--//datatest//--

concommand.Add("slashco_debug_datatest_makedummy", function(ply, _, _)

    if IsValid(ply) then
        if ply:IsPlayer() then
            if not ply:IsAdmin() then
                ply:ChatPrint("Only admins can use debug commands!")
                return
            end
        end
    end

    if SERVER then
        if not sql.TableExists("slashco_table_basedata") and not sql.TableExists("slashco_table_survivordata") and not sql.TableExists("slashco_table_slasherdata")then
            --Create the database table

            local diff = SlashCo.LobbyData.SelectedDifficulty
            local offer = SlashCo.LobbyData.Offering
            local survivorgasmod = SlashCo.LobbyData.SurvivorGasMod
            local slasher1id = SlashCo.LobbyData.PickedSlasher
            local slasher2id = GetRandomSlasher()

            sql.Query("CREATE TABLE slashco_table_basedata(Difficulty NUMBER , Offering NUMBER , SlasherIDPrimary NUMBER , SlasherIDSecondary NUMBER , SurviorGasMod NUMBER);")
            sql.Query("CREATE TABLE slashco_table_survivordata(Survivors TEXT, Item TEXT);")
            sql.Query("CREATE TABLE slashco_table_slasherdata(Slashers TEXT);")

            sql.Query("INSERT INTO slashco_table_slasherdata( Slashers ) VALUES( 90071996842377216 );")
            sql.Query("INSERT INTO slashco_table_survivordata( Survivors, Item ) VALUES( 90071996842377216, " .. sql.SQLStr("none") .. " );")
            sql.Query("INSERT INTO slashco_table_basedata( Difficulty, Offering, SlasherIDPrimary, SlasherIDSecondary, SurviorGasMod ) VALUES( " .. diff .. ", " .. offer .. ", " .. slasher1id .. ", " .. slasher2id .. ", " .. survivorgasmod .. " );")
            print("Dummy Database made.")
        else
            print("Database already exists.")
            local baseTable = sql.TableExists("slashco_table_basedata") and "present" or "nil"
            local survivorTable = sql.TableExists("slashco_table_survivordata") and "present" or "nil"
            local slasherTable = sql.TableExists("slashco_table_slasherdata") and "present" or "nil"
            print("base table: "..baseTable)
            print("survivor table: "..survivorTable)
            print("slasher table: "..slasherTable)
        end

        print(sql.LastError())
    end
end, nil, "Make a bare-minimum data table to be able to run a round.", FCVAR_CHEAT+FCVAR_PROTECTED)

concommand.Add( "slashco_debug_datatest_read", function( _, _, _ )
    if SERVER then

        print("basedata: ")
        PrintTable( sql.Query("SELECT * FROM slashco_table_basedata; ") or "nil")
        print("survivordata: ")
        PrintTable( sql.Query("SELECT * FROM slashco_table_survivordata; ") or "nil")
        print("slasherdata: ")
        PrintTable( sql.Query("SELECT * FROM slashco_table_slasherdata; ") or "nil")

    end

end, nil, "Read out the current data table.", FCVAR_CHEAT+FCVAR_PROTECTED)

concommand.Add( "slashco_debug_datatest_error", function( _, _, _ )
    if SERVER then

        print(sql.LastError())

    end

end, nil, "Print the latest data error.", FCVAR_CHEAT+FCVAR_PROTECTED)

concommand.Add( "slashco_debug_datatest_delete", function( _, _, _ )

    if SERVER then

        SlashCo.ClearDatabase()

    end

end, nil, "Delete the current data table.", FCVAR_CHEAT+FCVAR_PROTECTED)

--//items//--

concommand.Add("slashco_give_item", function(ply, _, args)
    if SERVER then

        if ply:Team() ~= TEAM_SURVIVOR then
            print("Only survivors can have items")
            return
        end

        if SlashCoItems[args[1]] then
            SlashCo.ChangeSurvivorItem(ply, args[1])
        else
            SlashCo.ChangeSurvivorItem(ply, "none")
        end
    end
end, function (cmd, args) --this is for autocomplete
    args = string.lower(string.Trim(args))
    local tbl = table.GetKeys(SlashCoItems)
    table.insert(tbl,"none")

    local tbl1 = {}
    for _, v in ipairs(tbl) do --find every item that matches what's inputted
        if string.find( string.lower(v), args ) then
            table.insert(tbl1,cmd.." "..v)
        end
    end
    return tbl1
end, "Give yourself an item",  FCVAR_CHEAT)