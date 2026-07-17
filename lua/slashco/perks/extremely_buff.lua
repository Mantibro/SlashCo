local PERK = {}

PERK.ID = "extremelybuff"
PERK.Name = "perk_extremely_buff"
PERK.Description = "perk_extremely_buff_desc"
PERK.Icon = "slashco/ui/perks/extremely_buff"
PERK.Team = TEAM_SURVIVOR
PERK.Level = 4
PERK.Price = 100

SlashCo.RegisterPerk(PERK, PERK.ID)

-- Take 50% more damage
hook.Add("EntityTakeDamage", "SlashCo:ExtremelyBuff", function(target, dmginfo)
	if not IsValid(target) then return end
	if not target:IsPlayer() then return end
	if target:Team() ~= PERK.Team then return end

	if not SlashCo.IsActivePerk(target, PERK.ID) then
		return
	end

	dmginfo:SetDamage(dmginfo:GetDamage() * 1.5)
end)