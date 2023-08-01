AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Flare"
ENT.ClassName = "sc_flare"

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

        if not self:GetNWBool("FlareActive") then
			SlashCo.ItemPickUp(activator, self:EntIndex(), "Flare")
		end

		if self:IsPlayerHolding() then
			return
		end

		activator:PickupObject(self)
	end

	return
end

if CLIENT then
    function ENT:Draw()
		self:DrawModel()

	end

	function ENT:Think()

		if self:GetNWBool("FlareActive") then

            local intensity = intensity or 0

			intensity = intensity + (FrameTime()*300)

			local dlight = DynamicLight( self:EntIndex() + 999968)
			if ( dlight ) then
				dlight.pos = self:GetPos()
				dlight.r = 180
				dlight.g = 100
				dlight.b = 20
				dlight.brightness = 1
				dlight.Decay = 1000
				dlight.Size = 180 + math.sin( intensity ) * 20
				dlight.DieTime = CurTime() + 0.1
			end

		end

	end
end