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
ENT.IsSelectable 	= true
ENT.PingType = "ITEM"

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

            if activator:GetNWBool("CurseOfTheJug") and self:GetNWBool("JugCursed") then
                self:SetPos(SlashCo.TraceHullLocator() + Vector(0,0,50))
                self:SetNWBool("JugCursed", false)

                activator:SetNWBool("JugCurseActivate", true)

                timer.Simple(6, function()
                    if IsValid( activator ) then
                        activator:SetNWBool("JugCurseActivate", false)
                    end
                end)

                return

            end

            local index = self:EntIndex()
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