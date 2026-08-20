AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName = "sc_offertable"
ENT.PrintName = "offertable"
ENT.Author = "Manti"
ENT.Contact = ""
ENT.Purpose = "A table for offerings."
ENT.Instructions = ""
ENT.PingType = "OFFERING TABLE"

if CLIENT then
	function ENT:Draw()
		--if GetConVar("r_radiosity"):GetInt() == 4 then
		render.SuppressEngineLighting(true)
		local r, g, b = render.ComputeLighting(self:GetPos(), vector_up):Unpack()
		local lr, lg, lb = render.GetAmbientLightColor(self:GetPos()):Unpack()
		lr = lr * (0.5 - r)
		lg = lg * (0.5 - g)
		lb = lb * (0.5 - b)
		for k=BOX_FRONT, BOX_BOTTOM do
			render.SetModelLighting(k, lr, lg, lb)
		end
	
		self:DrawModel()
		render.SuppressEngineLighting(false)
		--else
		--	self:DrawModel()
		--end
	end

	return
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Initialize()
	self:SetModel("models/slashco/other/lobby/offertable.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetUseType(SIMPLE_USE)

	local offer = ents.Create("prop_physics")
	self.Offer = offer

	offer:SetMoveType(MOVETYPE_NONE)
	offer:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	offer:SetModel("models/slashco/other/offerings/o_1.mdl")
	offer:SetPos(self:LocalToWorld(Vector(50, 0, 48)))
	offer:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 0)))
	offer:SetParent(self)
	offer:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
	offer:SetNoDraw(true)
end

function ENT:Think()
	if SlashCo.LobbyData.Offering > 0 then
		self.Offer:SetModel("models/slashco/other/offerings/o_" .. SlashCo.LobbyData.Offering .. ".mdl")
		self.Offer:SetColor(color_white)
		self.Offer:SetNoDraw(false)
	else
		self.Offer:SetModel("")
		self.Offer:SetNoDraw(true)
	end
end

function ENT:Use(activator)
	if activator:Team() ~= TEAM_LOBBY then return end
		
	if #SlashCo.LobbyData.Offerors > 0 or SlashCo.LobbyData.Offering ~= 0 then
		activator:ChatText("offer_made_already")
		return
	end

	if SlashCo.LobbyData.ReadyTimerStarted then
		activator:ChatText("offer_too_late")
		return
	end

	-- RaphaelIT7: I mean... why even check? I am sure we can just allow it at any time... right?
	if SlashCo.GetLobbyPlayerReadyState(activator) == SlashCo.ReadyState.NotReady then
		SlashCo.BroadcastGlobalData()
		SlashCo.SendValue(activator, "openOfferingPicker")
	else
		activator:ChatText("offer_not_ready")
	end
end