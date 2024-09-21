AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName = "sc_itemstash"
ENT.PrintName = "itemstash"
ENT.Author = "Manti"
ENT.Contact = ""
ENT.Purpose = "Supplying SlashCo workers with an item."
ENT.Instructions = ""
ENT.PingType = "ITEM STASH"

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/hunter/blocks/cube2x3x025.mdl")
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetUseType(SIMPLE_USE)
        self:SetColor(Color(0, 0, 0, 0))
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    end
    function ENT:Use(activator)
        if activator:Team() == TEAM_SURVIVOR and not activator.CantBuy then
            SlashCo.SendValue(activator, "openItemPicker")
        end
    end
else
    function ENT:Draw()
        self:DrawModel()
    end
end