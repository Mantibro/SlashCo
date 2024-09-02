AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "GasCan"
ENT.ClassName = "sc_gascan"

--[[
if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

		local index = self:EntIndex()
		SlashCo.ItemPickUp(activator, index, "GasCan")
	end
end
--]]