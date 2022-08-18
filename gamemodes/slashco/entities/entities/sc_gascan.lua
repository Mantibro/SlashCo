AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName 		= "sc_gascan"
ENT.PrintName		= "gascan"
ENT.Author			= "textstack"
ENT.Contact			= ""
ENT.Purpose			= "Something I don't remember."
ENT.Instructions	= ""

function ENT:Initialize()
    if SERVER then
        self:SetModel( SlashCoItems.GasCan.Model)
        self:SetSolid( SOLID_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
        self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR ) --Collide with everything but the player
        self:SetMoveType( MOVETYPE_VPHYSICS)
    end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then phys:Wake() end
end

function ENT:Use( activator )

    if SERVER then

        if activator:Team() == TEAM_SURVIVOR then

            local index = self:EntIndex()
            SlashCo.CurRound.GasCans[index] = nil
            SlashCo.ItemPickUp(activator, index, "GasCan")

        end

    end

end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end