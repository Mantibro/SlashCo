local EFFECT = SlashCoEffects.Speed or {}
SlashCoEffects.Speed = EFFECT

EFFECT.Name = "Speed"
EFFECT.ChangesSpeed = true
EFFECT.OnApplied = function(ply)
    ply:SetRunSpeed(400)
end
EFFECT.OnExpired = function(ply)
    if not ply:ItemValue2("ChangesSpeed", nil, true) then
        ply:SetRunSpeed(300)
    end
end