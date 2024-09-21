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

if SERVER then
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
    end

    function ENT:Think()
        if SlashCo.LobbyData.Offering > 0 then
            self.Offer:SetModel("models/slashco/other/offerings/o_" .. SlashCo.LobbyData.Offering .. ".mdl")
            self.Offer:SetColor(Color(255, 255, 255, 255))
        else
            self.Offer:SetModel("")
            self.Offer:SetColor(Color(0, 0, 0, 0))
            self.Offer:SetRenderMode(RENDERMODE_TRANSCOLOR)
        end
    end

    function ENT:Use(activator)
        if activator:Team() == TEAM_LOBBY then
            if #SlashCo.LobbyData.Offerors > 0 or SlashCo.LobbyData.Offering ~= 0 then
                activator:ChatText("offer_made_already")
                return
            end

            if SlashCo.LobbyData.ReadyTimerStarted then
                activator:ChatText("offer_too_late")
                return
            end

            if getReadyState(activator) < 1 then
                SlashCo.BroadcastGlobalData()
                SlashCo.SendValue(activator, "openOfferingPicker")
            else
                activator:ChatText("offer_not_ready")
            end
        end
    end
else
    function ENT:Draw()
        self:DrawModel()
    end
end