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

	SlashCo.AddSlasherAnger(slasher, 0.5) -- Adds 0.5 anger every second.
end)

function ENT:DestroyJonkler()
	self:EmitSound("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav")
	SlashCo.AudioSystem.StopSound("JonklerCart", 5, self)
end

function ENT:Think()
	if not self.IsActiveJonkler then return end
	if CurTime() > self.DeactivationTime then
		self:DestroyJonkler()
		return
	end

	local pos = self:GetPos()
	for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		if slasher:GetPos():Distance(pos) > 300 then continue end -- out of range

		self:DestroyJonkler()
		break
	end
end