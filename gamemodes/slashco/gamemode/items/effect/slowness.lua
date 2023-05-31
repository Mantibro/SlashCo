local EFFECT = SlashCoEffects.Slowness or {}
SlashCoEffects.Slowness = EFFECT

EFFECT.Name = "Slowness"
EFFECT.ChangesSpeed = true
EFFECT.OnApplied = function(ply)
    ply:SetRunSpeed(200)
end
EFFECT.OnExpired = function(ply)
    if not ply:ItemValue2("ChangesSpeed", nil, true) then
        ply:SetRunSpeed(300)
    end
end