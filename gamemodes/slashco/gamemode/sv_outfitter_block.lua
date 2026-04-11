hook.Add("CanOutfit", "SlashCoBlockSlasherOutfitterModelChange", function(ply)
    if IsValid(ply) and ply:Team() == TEAM_SLASHER then
        ply:ChatPrint("YOU CAN'T USE CUSTOM MODEL WITH OUTFITTER FOR SLASHER TEAM!")
        return false
    end
end)