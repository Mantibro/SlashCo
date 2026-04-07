ENT.Type = "point"

function ENT:Initialize()
	SetGlobal2Vector("SlashCo:DocumentUIPos", self:GetPos())
	SetGlobal2Angle("SlashCo:DocumentUIAng", self:GetAngles())
end

ENT.OnMapToolRedo = ENT.Initialize
ENT.OnMapToolUndo = ENT.Initialize

-- Call this once you changed the Global2 values above to your new values
concommand.Add("slashco_maptool_applydocumentscreen", function(ply)
	if not ply or (IsValid(ply) and not ply:IsListenServerHost()) then return end

	local ent = ents.FindByClass("info_sc_lobby_documentscreen")[1]
	if not IsValid(ent) then return end

	SlashCo.MapTools.SetEntityPositionAndAngle(ent, GetGlobal2Vector("SlashCo:DocumentUIPos"), GetGlobal2Angle("SlashCo:DocumentUIAng"))
end)

local angRotation = Angle(0, 90, 90)
concommand.Add("slashco_maptool_setdocumentscreen", function(ply)
	if not ply or (IsValid(ply) and not ply:IsListenServerHost()) then return end

	SlashCo.MapTools.IsEnabled()
	local eyeTrace = ply:GetEyeTrace()
	SetGlobal2Vector("SlashCo:DocumentUIPos", eyeTrace.HitPos)

	local traceAngle = eyeTrace.HitNormal:Angle()
	traceAngle:Add(angRotation)
	SetGlobal2Angle("SlashCo:DocumentUIAng", traceAngle)
end)