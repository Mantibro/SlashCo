AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName = "sc_postalammo"
ENT.PrintName = "Ammo"
ENT.Author = "eno"
ENT.Contact = ""
ENT.Purpose = "Guns don't kill people, I do."
ENT.Instructions = ""
ENT.IsSelectable = false
ENT.PingType = "AMMO"

local function DeagleBulletsAmount(slasher)
	return slasher:GetNW2Float("DeagleBulletsAmount", 0)
end

local function DeagleBulletsControl(slasher, bullets)
	slasher:SetNW2Float("DeagleBulletsAmount", math.Clamp(DeagleBulletsAmount(slasher) + bullets, 0, 6))
end

local function MGBulletsAmount(slasher)
	return slasher:GetNW2Float("MGBulletsAmount", 0)
end

local function MGBulletsControl(slasher, bullets)
	slasher:SetNW2Float("MGBulletsAmount", math.Clamp(MGBulletsAmount(slasher) + bullets, 0, 20))
end

function ENT:Initialize()
	if not CLIENT then return end

	self:SetModel(({
    "models/Items/357ammo.mdl",
    "models/Items/BoxSRounds.mdl",
    "models/Items/BoxMRounds.mdl"
	})[math.random(3)])
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		self:PhysWake()
	end
	
end

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SLASHER then return end
		if activator:GetNWString("Slasher") ~= "PostalDude" then return end

		
		DeagleBulletsControl(activator, 2)
		MGBulletsControl(activator, 5)
		activator:EmitSound("slashco/slasher/postaldude/dude_ammo_pickup.ogg")

		SlashCo.CreateItem("sc_postalammo", SlashCo.RandomPosLocator(), Angle(0, 0, 0))

		self:Remove()
	end
end