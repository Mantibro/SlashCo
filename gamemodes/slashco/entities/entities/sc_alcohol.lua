AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Alcohol"
ENT.ClassName = "sc_alcohol"

function ENT:PostInitialize()
	if SERVER then
		self:SetMaterial("models/shiny")
		self:SetColor(Color(121, 68, 59))
	end
end