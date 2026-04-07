ENT.Type = "brush"

function ENT:Initialize()
	self:SetTrigger(true)

	GameData.PlayersInElevatorZone = GameData.PlayersInElevatorZone or {}
end

function ENT:StartTouch(ent)
	if not ent:IsPlayer() then return end

	-- RaphaelIT7: We reference count to avoid the case that a mapper screwed up if they put zones INTO each other.
	GameData.PlayersInElevatorZone[ent] = (GameData.PlayersInElevatorZone[ent] or 0) + 1
end

function ENT:EndTouch(ent)
	if not ent:IsPlayer() then return end

	GameData.PlayersInElevatorZone[ent] = GameData.PlayersInElevatorZone[ent] - 1
	if GameData.PlayersInElevatorZone[ent] == 0 then
		GameData.PlayersInElevatorZone[ent] = nil
	end
end