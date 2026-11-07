local PERK = {}

PERK.ID = "SecondChance"
PERK.Name = "perk_secondchance"
PERK.Description = "perk_secondchance_desc"
PERK.Icon = "slashco/ui/perks/secondchance"
PERK.Team = TEAM_SURVIVOR
PERK.Level = 2
PERK.Price = 50

SlashCo.RegisterPerk(PERK, PERK.ID)

-- RaphaelIT7: Perks suck rn as we got no bindings like Items

hook.Add("SlashCo:PrePlayerDeath", "SlashCo:SecondChance", function(ply)
	if not SlashCo.IsActivePerk(ply, PERK.ID) or ply:Team() ~= PERK.Team then return end
	if math.random(1, 100) > 2 then return end -- You got a 2% chance

	SlashCo.DropAllItems(ply)

	ply:ClearEffects()
	ply:SetVisible(false)
	ply:SetImpervious(true)
	ply:GodEnable()
	ply:Freeze(true)

	ply:SetShowDeathUI(true)
	ply:SetDeathReviveUI(true)
	ply:SetDeathUITime(CurTime())

	timer.Simple(10, function()
		if not IsValid(ply) then return end

		ply:SetShowDeathUI(false)
		ply:SetDeathReviveUI(false)

		ply:SetVisible(true)
		ply:SetImpervious(false)
		ply:GodDisable()
		ply:Freeze(false)
	end)

	return true
end)