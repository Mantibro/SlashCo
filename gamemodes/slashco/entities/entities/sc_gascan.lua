AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "GasCan"
ENT.ClassName = "sc_gascan"

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

		if activator:GetNWBool("CurseOfTheJug") and self:GetNWBool("JugCursed") then
			self:RandomTeleport(Vector(0, 0, 50))
			self:SetNWBool("JugCursed", false)

			activator:SetNWBool("JugCurseActivate", true)

			timer.Simple(6, function()
				if IsValid(activator) then
					activator:SetNWBool("JugCurseActivate", false)
				end
			end)

			return
		end

		local index = self:EntIndex()
		SlashCo.ItemPickUp(activator, index, "GasCan")
	end
end
