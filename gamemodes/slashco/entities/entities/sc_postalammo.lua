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

local modelList = {
	"models/Items/357ammo.mdl",
	"models/Items/BoxSRounds.mdl",
	"models/Items/BoxMRounds.mdl",
}

function ENT:Initialize()
	if CLIENT then return end

	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
	self:SetModel(modelList[math.random(#modelList)])
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysWake()
end

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SLASHER then return end
		if activator:GetNWString("Slasher") ~= "PostalDude" then return end

		DeagleBulletsControl(activator, 2)
		MGBulletsControl(activator, 5)

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_ammo_pickup.ogg",
			identifier = "PostalAmmoPickUp",
			minDistance = 200,
			maxDistance = 400,
			entity = activator,
			volume = 1.0,
		})

		SlashCo.CreateItem("sc_postalammo", SlashCo.RandomPosLocator(), Angle(0, 0, 0))
		self:Remove()
	end
end