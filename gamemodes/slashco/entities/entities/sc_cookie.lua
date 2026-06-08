AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "Cookie"
ENT.ClassName = "sc_cookie"

if CLIENT then return end

function ENT:BeingEaten()
	self.DONTPICKUP = true -- don't pick up while sid is eating it
end