local EFFECT = SlashCoEffects.Speed or {}
SlashCoEffects.Speed = EFFECT

EFFECT.Name = "Speed"
EFFECT.ChangesSpeed = true
EFFECT.OnApplied = function(ply)
    ply:AddSpeedEffect("speedEffect", 400, 4)
end
EFFECT.OnExpired = function(ply)
    ply:RemoveSpeedEffect("speedEffect")
end