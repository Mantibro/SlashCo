local PERK = {}

PERK.ID = "FastFuel"
PERK.Name = "faster_fueling"
PERK.Description = "faster_fueling_desc"
PERK.Icon = "slashco/ui/perks/faster_fueling"
PERK.FuelSpeed = 1.25
PERK.FuelWalkSpeed = 0.9 -- ToDo: Implement this
PERK.Team = TEAM_SURVIVOR
PERK.Level = 0
PERK.Price = 100

SlashCo.RegisterPerk(PERK, PERK.ID)