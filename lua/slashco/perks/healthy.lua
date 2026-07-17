local PERK = {}

PERK.ID = "Healthy"
PERK.Name = "perk_healthy"
PERK.Description = "perk_healthy_desc"
PERK.Icon = "slashco/ui/perks/healthy"
PERK.Team = TEAM_SURVIVOR
PERK.Level = 0
PERK.Price = 50
--PERK.Conflicts = {"Glutton"}

SlashCo.RegisterPerk(PERK, PERK.ID)

function SlashCo.CanEatPizza(ply)
	if not IsValid(ply) then return false end
	if ply:Team() ~= PERK.Team then return false end

	return SlashCo.IsActivePerk(ply, PERK.ID)
end
