AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base 			= "base_nextbot"
ENT.Type			= "nextbot"
ENT.ClassName 		= "sc_crimclone"
ENT.Spawnable		= true

hook.Add("SlashCo:Precache", "PrecacheClone", function()
	SlashCo.PrecacheModel("models/slashco/slashers/criminal/criminal.mdl")
	SlashCo.PrecacheSound("slashco/slasher/criminal/criminal_rage.mp3")
	SlashCo.PrecacheSound("slashco/slasher/criminal/criminal_loop.mp3")
end)

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "MainRageClone")
end

function ENT:Initialize()
	self:SetModel("models/slashco/slashers/criminal/criminal.mdl")
	self:SetNotSolid(true)
	self.RandPos = 0.12

	if not self.AssignedSlasher then
		error("Expected self.AssignedSlasher to be valid!")
	end

	self.SlasherPlayer = player.GetBySteamID64(self.AssignedSlasher)
end

function ENT:OnTakeDamage()
	return 0
end

function ENT:RunBehaviour()
	while true do
		if not IsValid(self.SlasherPlayer) then return end

		local rage_switch = slasher:GetNWBool("CriminalRage")
		self:StartActivity(ACT_IDLE)
		if self.IsMain ~= true then
			if rage_switch then
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/criminal/criminal_rage.mp3",
					identifier = "CriminalRage",
					minDistance = 850 * SlashCo.MapSize,
					maxDistance = 1550 * SlashCo.MapSize,
					looping = true,
					entity = self,
					volume = 1,
					fadeIn = 0,
				})
			else
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/criminal/criminal_loop.mp3",
					identifier = "CriminalLoop",
					minDistance = 700 * SlashCo.MapSize,
					maxDistance = 1240 * SlashCo.MapSize,
					looping = true,
					entity = self,
					volume = 1,
					fadeIn = 0,
				}) 
			end
		end
		coroutine.wait(10)
		SlashCo.AudioSystem.StopSound("CriminalLoop", 0.5)
		SlashCo.AudioSystem.StopSound("CriminalRage", 0.5)

		coroutine.yield()
	end
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Think()
		if not IsValid(self.SlasherPlayer) then return end
			self:Remove()
			return
		end

		local rage_switch = self.SlasherPlayer:GetNWBool("CriminalRage")

		if not self.IsMain then
			if rage_switch then
				self:SetColor(color_black)
			else
				self:SetColor(color_white)
			end

			self.RandPos = self.RandPos - FrameTime()

			if self.RandPos < 0.01 or self.SlasherPlayer:GetPos():Distance(self:GetPos()) > 1200 then
				local n_pos = SlashCo.LocalizedTraceHullLocator(self.SlasherPlayer, 1000)

				if n_pos then
					self:SetPos(n_pos)
				end
				self:SetAngles(Angle(0, math.random(0, 359), 0))

				self.RandPos = math.random(1, 15)
			end
		else
			local c_pos = self.SlasherPlayer:GetPos()
			local c_ang = self.SlasherPlayer:GetAngles()

			if self.SlasherPlayer:GetVelocity():Length() < 5 then
				self:SetPos(c_pos)
				self:SetAngles(c_ang)
			end

			if rage_switch then
				self:SetBodygroup(0, 1)
				self:SetSkin(1)
				if not self:GetMainRageClone() then self:SetMainRageClone(true) end
			else
				self:SetBodygroup(0, 0)
				self:SetSkin(0)
				if self:GetMainRageClone() then self:SetMainRageClone(false) end
			end
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end