AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Document"
ENT.ClassName = "sc_document"
ENT.IsSelectable = true
ENT.PingType = "DOCUMENT"

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/slashco/items/slashcofile.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	else
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/document_shimmer.mp3",
			identifier = "DocumentShimmer",
			minDistance = 50,
			maxDistance = 125,
			entity = self,
			volume = 0.15,
			fadeIn = 1,
			looping = true,
		})
	end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

if CLIENT then return end

function ENT:Think()
	local curTime = CurTime()
	self:NextThink(curTime + 0.5)

	if SlashCo.OverTime > SlashCo.GetRoundTime() then
		return true
	end

	if math.random(1, 15) == 1 then
		SlashCo.AudioSystem.PlaySound({
			deleteWhenDone = true,
			soundPath = "slashco/document_ambient" .. math.random(1, 3) .. ".mp3",
			identifier = "DocumentSound",
			minDistance = 200 + (200 * SlashCo.MapSize),
			maxDistance = 500 + (400 * SlashCo.MapSize),
			entity = self,
			volume = 0.5,
			fadeIn = 0,
		})
	end

	return true
end

function ENT:Use(activator)
	if activator:Team() ~= TEAM_SURVIVOR then
		return
	end

	SlashCo.AudioSystem.PlaySound({
		deleteWhenDone = true,
		soundPath = "slashco/document_pickup" .. math.random(1, 3) .. ".mp3",
		identifier = "DocumentPickup",
		minDistance = 100 + (100 * SlashCo.MapSize),
		maxDistance = 200 + (200 * SlashCo.MapSize),
		pos = self:GetPos(),
		volume = 0.5,
		fadeIn = 0,
	})

	SlashCo.UpdateObjective("page", SlashCo.ObjStatus.PROGRESS, 1)
	SlashCo.SendObjectives()
	self:Remove()
end