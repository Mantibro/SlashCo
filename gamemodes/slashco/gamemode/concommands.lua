local SlashCo = SlashCo

concommand.Add( "slashco_run_curconfig", function( _, _, _ )

    SlashCo.LoadCurRoundTeams()

    SlashCo.SpawnCurConfig()

end )

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

end )

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
    SlashCo.CurRound.SurvivorCount = player.GetAll()
    timer.Simple(0.05, function()

        print("[SlashCo] Now proceeding with Spawns...")

        SlashCo.PrepareSlasherForSpawning()

        SlashCo.SpawnPlayers()

        SlashCo.BroadcastItemData()

    end)

    SlashCo.SpawnCurConfig(true)

end )

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
            local slasher1id = SlashCo.LobbyData.FinalSlasherID
            local slasher2id = math.random(1, #SlashCo.SlasherData)

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
end)

concommand.Add( "slashco_debug_datatest_read", function( ply, _, _ )

    if IsValid(ply) then
        if ply:IsPlayer() then
            if not ply:IsAdmin() then
                ply:ChatPrint("Only admins can use debug commands!")
                return
            end
        end
    end

    if SERVER then

        print("basedata: ")
        PrintTable( sql.Query("SELECT * FROM slashco_table_basedata; ") or "nil")
        print("survivordata: ")
        PrintTable( sql.Query("SELECT * FROM slashco_table_survivordata; ") or "nil")
        print("slasherdata: ")
        PrintTable( sql.Query("SELECT * FROM slashco_table_slasherdata; ") or "nil")

    end

end )

concommand.Add( "slashco_debug_datatest_error", function( ply, _, _ )

    if IsValid(ply) then
        if ply:IsPlayer() then
            if not ply:IsAdmin() then
                ply:ChatPrint("Only admins can use debug commands!")
                return
            end
        end
    end

    if SERVER then

        print(sql.LastError())

    end

end )

concommand.Add( "slashco_debug_datatest_delete", function( ply, _, _ )

    if IsValid(ply) then
        if ply:IsPlayer() then
            if not ply:IsAdmin() then
                ply:ChatPrint("Only admins can use debug commands!")
                return
            end
        end
    end

    if SERVER then

        SlashCo.ClearDatabase()

    end

end )

--//items//--

concommand.Add("slashco_give_item", function(ply, _, args)

    if IsValid(ply) then
        if ply:IsPlayer() then
            if not ply:IsAdmin() then
                ply:ChatPrint("Only admins can use debug commands!")
                return
            end
        end
    end

    if SERVER then

        if ply:Team() ~= TEAM_SURVIVOR then
            print("Only survivors can have items")
            return
        end

        if SlashCoItems[args[1]] then
            SlashCo.ChangeSurvivorItem(ply, args[1])
        else
            print("Item doesn't exist, removing current item")
            SlashCo.ChangeSurvivorItem(ply, "none")
        end
    end
end)