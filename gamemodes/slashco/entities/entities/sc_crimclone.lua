AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base 			= "base_nextbot"
ENT.Type			= "nextbot"
ENT.ClassName 		= "sc_crimclone"
ENT.Spawnable		= true

function ENT:Initialize()
	self:SetModel("models/slashco/slashers/criminal/criminal.mdl")

	self.RandPos = 0.12

	self:SetNotSolid(true)
end

function ENT:OnTakeDamage()
	return 0
end

function ENT:RunBehaviour()
	while true do							-- Here is the loop, it will run forever
		if self.AssignedSlasher == nil or not IsValid(player.GetBySteamID64(self.AssignedSlasher)) then return end

		local rage_switch = player.GetBySteamID64(self.AssignedSlasher):GetNWBool("CriminalRage")

		self:StartActivity(ACT_IDLE)
		if self.IsMain ~= true then
			if rage_switch then self:EmitSound("slashco/slasher/criminal_rage.wav")
			else self:EmitSound("slashco/slasher/criminal_loop.wav") end
		end
		coroutine.wait(10)
		self:StopSound("slashco/slasher/criminal_loop.wav")
		self:StopSound("slashco/slasher/criminal_rage.wav")

		coroutine.yield()
	end
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Think()
		if self.AssignedSlasher == nil or not IsValid(player.GetBySteamID64(self.AssignedSlasher)) then
			self:Remove()
			return
		end

		local rage_switch = player.GetBySteamID64(self.AssignedSlasher):GetNWBool("CriminalRage")

		if not self.IsMain then
			if rage_switch then
				self:SetColor(color_black)
			else
				self:SetColor(color_white)
			end

			self.RandPos = self.RandPos - FrameTime()

			if self.RandPos < 0.01 or player.GetBySteamID64(self.AssignedSlasher):GetPos():Distance(self:GetPos()) > 1200 then
				local n_pos = SlashCo.LocalizedTraceHullLocator(player.GetBySteamID64(self.AssignedSlasher), 1000)

				self:SetPos(n_pos)
				self:SetAngles(Angle(0, math.random(0, 359), 0))

				self.RandPos = math.random(1, 15)
			end
		else
			local c_pos = player.GetBySteamID64(self.AssignedSlasher):GetPos()
			local c_ang = player.GetBySteamID64(self.AssignedSlasher):GetAngles()

			if player.GetBySteamID64(self.AssignedSlasher):GetVelocity():Length() < 5 then
				self:SetPos(c_pos)
				self:SetAngles(c_ang)
			end

			if rage_switch then
				self:SetBodygroup(0, 1)
				self:SetSkin(1)
				if not self:GetNWBool("MainRageClone") then self:SetNWBool("MainRageClone", true) end
			else
				self:SetBodygroup(0, 0)
				self:SetSkin(0)
				if self:GetNWBool("MainRageClone") then self:SetNWBool("MainRageClone", false) end
			end
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end