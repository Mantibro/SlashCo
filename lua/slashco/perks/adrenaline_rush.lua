local PERK = {}

PERK.ID = "AdrenalineRush"
PERK.Name = "perk_adrenalinerush"
PERK.Description = "perk_adrenalinerush_desc"
PERK.Icon = "slashco/ui/perks/adrenaline_rush"
PERK.Team = TEAM_SURVIVOR
PERK.Level = 2
PERK.Price = 50

SlashCo.RegisterPerk(PERK, PERK.ID)

hook.Add("SlashCo:HelicopterLanded", "SlashCo:AdrenalineRush", function()
	for _, ply in ipairs(team.GetPlayers(PERK.Team)) do
		if not SlashCo.IsActivePerk(ply, PERK.ID) then continue end

		ply:SetHealth(math.min(ply:Health() + 20, ply:GetMaxHealth()))

		ply:AddSpeedEffect("AdrenalineRush", 315, 2)
		timer.Simple(10, function()
			if not IsValid(ply) then return end

			ply:RemoveSpeedEffect("AdrenalineRush")
		end)
	end
end)