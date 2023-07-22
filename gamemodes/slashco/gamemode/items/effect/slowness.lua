local EFFECT = SlashCoEffects.Slowness or {}
SlashCoEffects.Slowness = EFFECT

EFFECT.Name = "Slowness"
EFFECT.ChangesSpeed = true
EFFECT.OnApplied = function(ply)
    ply:AddSpeedEffect("slowEffect", 200, 10)
end
EFFECT.OnExpired = function(ply)
    ply:RemoveSpeedEffect("slowEffect")
end