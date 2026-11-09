AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"
ENT.ClassName = "sc_matchacoffee"
ENT.PrintName = "MatchaCoffee"
ENT.Author = "Xerk"
ENT.Contact = ""
ENT.Purpose = "Slasher Ability!"
ENT.Instructions = ""
ENT.IsSelectable = true
ENT.PingType = "MATCHA"

if SERVER then
	hook.Add("SlashCo:Precache", "PrecacheMatcha", function()
		SlashCo.PrecacheSound("slashco/survivor/eat_mayo.mp3")
		SlashCo.PrecacheModel("models/slashco/items/matcha.mdl")
	end)

	function ENT:Initialize()
		self:SetModel("models/slashco/items/matcha.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	end

	function ENT:SetMatchaVelocity(velocity)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(10)
			phys:SetVelocity(velocity)
			phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
		end
	end

	function ENT:MatchaHit()
		SlashCo.AudioSystem.EmitSound(self, "slashco/survivor/eat_mayo.mp3")

		local pos = self:GetPos()
		for _, ply in ipairs(SlashCo.FindPlayersInRange(pos, 130, nil, self)) do
			local team = ply:Team()
			if team == TEAM_SURVIVOR then
				SlashCo.AudioSystem.EmitSound(ply, "slashco/slasher/americanpo/negative_effect.mp3")
				ply:SetNW2Bool("SurvivorMatcha", true)
			end

			timer.Simple(7.0, function()
				if not IsValid(ply) then return end
				ply:SetNW2Bool("SurvivorMatcha", false)
			end)
		end

		SafeRemoveEntityDelayed(self, 0.1)
	end

	function ENT:PhysicsCollide(data)
		self:MatchaHit()
		util.Decal("Splash.Large", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)

		if IsValid(data.HitEntity) and (data.HitEntity:IsPlayer() and data.HitEntity:Team() == TEAM_SURVIVOR) then
			self:MatchaHit()
		end
	end
end

hook.Add("SlashCo:DrawHUD", "SlashCo:MatchaCoffee", function()
	if GameData.LocalPlayer:GetNW2Bool("SurvivorMatcha") then
		local Overlay = Material("slashco/ui/overlays/cardguy_matcha_overlay")
		Overlay:SetFloat("$alpha", 1)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end
end)