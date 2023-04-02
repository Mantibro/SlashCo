AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName = "sc_brick"
ENT.PrintName = "brick"
ENT.Author = "textstack"
ENT.Contact = ""
ENT.Purpose = "A fuckin' brick."
ENT.Instructions = ""
ENT.IsSelectable = true
ENT.PingType = "ITEM"

function ENT:Initialize()
    if SERVER then
        self:SetModel(SlashCoItems.Brick.Model)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
        self:SetMoveType(MOVETYPE_VPHYSICS)
    end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator)
    if CLIENT or activator:Team() ~= TEAM_SURVIVOR then
        return
    end
    SlashCo.ItemPickUp(activator, self:EntIndex(), "Brick")

    if self:IsPlayerHolding() then
        return
    end
    activator:PickupObject(self)
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end