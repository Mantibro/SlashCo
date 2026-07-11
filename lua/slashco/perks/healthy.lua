local PERK = {}

PERK.ID = "Healthy"
PERK.Name = "perk_healthy"
PERK.Description = "perk_healthy_desc"
PERK.Icon = "slashco/ui/perks/healthy"
PERK.Team = TEAM_SURVIVOR
PERK.Level = 1
PERK.Price = 50

SlashCo.RegisterPerk(PERK, PERK.ID)

function SlashCo.GetFoodHealMultiplier(ply)
	if not IsValid(ply) then return 1 end
	if ply:Team() ~= PERK.Team then return 1 end

	if not SlashCo.IsActivePerk(ply, PERK.ID) then
		return 1
	end

	return 1.5
end

function SlashCo.CanEatPizza(ply)
	if not IsValid(ply) then return false end
	if ply:Team() ~= PERK.Team then return false end

	return SlashCo.IsActivePerk(ply, PERK.ID)
end
