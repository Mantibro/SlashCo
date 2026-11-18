hook.Add("CanOutfit", "SlashCoBlockSlasherOutfitterModelChange", function(ply)
    if IsValid(ply) and (ply:Team() == TEAM_SLASHER or ply:Team() == TEAM_SPECTATOR ) then
        ply:ChatPrint("YOU CAN'T USE CUSTOM MODEL WITH OUTFITTER FOR SLASHER/SPECTATOR TEAM!")
        return false
    end
end)