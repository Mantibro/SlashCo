local SlashCoOfferings = SlashCoOfferings

SlashCoOfferings.Drainage = {
    Name = "Drainage",
    Description = "Gas cans will be plentiful,\nBut\nGenerators will leak fuel over time.",
    Rarity = 2,
    Model = "models/slashco/other/offerings/o_3.mdl",
    CamPos = Vector(60,0,0),
    OnThink = function()
        local totalCansRemaining = 0
        for _, v in ipairs(gens) do
            totalCansRemaining = totalCansRemaining + (v.CansRemaining or SlashCo.GasCansPerGenerator)
        end

        if #ents.FindByClass( "sc_gascan") <= totalCansRemaining then return end --Prevent draining if there is too few gas cans

        if engine.TickCount()%math.floor(240/engine.TickInterval()) == 0 then
            local random = math.random(#gens)
            gens[random].CansRemaining = math.Clamp((gens[random].CansRemaining or SlashCo.GasCansPerGenerator)+1,0,SlashCo.GasCansPerGenerator)
        end
    end,
    GasCanMod = function(count)
        return count+6
    end
}