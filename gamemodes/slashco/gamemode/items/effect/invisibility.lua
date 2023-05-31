local EFFECT = SlashCoEffects.Invisibility or {}
SlashCoEffects.Invisibility = EFFECT

EFFECT.Name = "Invisibility"
EFFECT.OnFootstep = function()
    return true
end
EFFECT.OnApplied = function(ply)
    ply:SetMaterial("Models/effects/vol_light001")
    ply:SetColor(Color(0,0,0,0))
end
EFFECT.OnExpired = function(ply)
    ply:SetMaterial("")
    ply:SetColor(color_white)
end