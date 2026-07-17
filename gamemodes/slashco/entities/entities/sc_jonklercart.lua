AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "JonklerCart"
ENT.ClassName = "sc_jonklercart"

if CLIENT then return end

function ENT:EnableJonkler()
	self:DropToFloor()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsActiveJonkler = true
	self.DeactivationTime = CurTime() + 200

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/jonk.ogg",
		identifier = "JonklerCart",
		minDistance = 500,
		maxDistance = 1000,
		entity = self,
		volume = 0.9,
		fadeIn = 0,
	})
end

hook.Add("SlashCo:OnAngerTick", "JonklerCart", function(slasher)
	local isActive = false
	for _, jonkler in ipairs(ents.FindByClass("sc_jonklercart")) do
		if jonkler.IsActiveJonkler then
			isActive = true
			break
		end
	end

	if not isActive then return end

	SlashCo.AddSlasherAnger(slasher, 0.5) -- Adds 0.5 anger every second while a jonkler cart is active.
end)

function ENT:DestroyJonkler()
	local idx = math.random(2, 3)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "physics/concrete/concrete_break" .. idx .. ".wav",
		identifier = "JonklerBreak" .. idx,
		minDistance = 400,
		maxDistance = 800,
		entity = self,
		volume = 1,
		fadeIn = 0,
	})

	SlashCo.AudioSystem.StopSound("JonklerCart", 5, self)
	self:Remove()
end

function ENT:Think()
	if not self.IsActiveJonkler then return end
	if CurTime() > self.DeactivationTime then
		self:DestroyJonkler()
		return
	end

	local pos = self:GetPos()
	for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		if slasher:GetPos():Distance(pos) > 200 then continue end -- out of range

		self:DestroyJonkler()
		break
	end
end

if CLIENT then
	function ENT:Think()
		local pos = self:GetPos()
		for _, slashers in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if slashers:GetPos():Distance(pos) > 700 then continue end

			local lookAngle = (pos - slashers:GetPos()):Angle()
			slashers:SetEyeAngles(lookAngle)
		end
	end
end