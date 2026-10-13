AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Flare"
ENT.ClassName = "sc_flare"
ENT.PredictPickUp = false

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "FlareActive")
	self:NetworkVar("String", 0, "FlareDropperName")
end

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then
			return
		end

		if not self:GetFlareActive() and SlashCo.ItemPickUp(activator, self:EntIndex(), "Flare") then
			return
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
		if self:GetFlareActive() then
			self.Intensity = (self.Intensity or 0) + (FrameTime() * 300)

			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.pos = self:GetPos()
				dlight.r = 180
				dlight.g = 100
				dlight.b = 20
				dlight.brightness = 1
				dlight.Decay = 1000
				dlight.Size = 180 + math.sin(self.Intensity) * 20
				dlight.DieTime = CurTime() + 0.1
			end
		end
	end
end