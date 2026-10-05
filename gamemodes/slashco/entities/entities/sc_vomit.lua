AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "HotdogmanVomit"
ENT.ClassName = "sc_vomit"

local offset = Vector(0, 0, 3.7)
function ENT:GetVomitOffset()
	local worldSpace = self:WorldSpaceCenter()
	worldSpace:Add(offset)
	return worldSpace
end

function ENT:Initialize()
	self.DONTPICKUP = true
	self:SetModel("models/alyx_emptool_prop.mdl")
	self:SetMaterial("models/effects/vol_light001")
	self:PhysicsInitSphere(10)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self:GetPhysicsObject():EnableGravity(true)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	if SERVER then
		local vomitPos = self:GetVomitOffset()
		local vomit = ents.Create("env_steam")
		if IsValid(vomit) then
			vomit:SetKeyValue( "angles", "-90 0 0" )
			vomit:SetKeyValue( "endsize", "25" )
			vomit:SetKeyValue( "InitialState", "1" )
			vomit:SetKeyValue( "JetLength", "30" )
			vomit:SetKeyValue( "Rate", "16" )
			vomit:SetKeyValue( "renderamt", "155" )
			vomit:SetKeyValue( "rendercolor", "0 255 0" )
			vomit:SetKeyValue( "rollspeed", "8" )
			vomit:SetKeyValue( "spawnflags", "0" )
			vomit:SetKeyValue( "Speed", "5" )
			vomit:SetKeyValue( "SpreadSpeed", "5" )
			vomit:SetKeyValue( "startsize", "15" )
			vomit:SetKeyValue( "type", "0" )
			vomit:Spawn()
			vomit:Activate()
			vomit:SetPos(vomitPos)
		end

		SafeRemoveEntityDelayed(vomit, 30)
	end
end

function ENT:PhysicsCollide(data, physobj)
	ParticleEffect("slime_splash_01_droplets", data.HitPos, data.HitNormal:Angle())
end

if CLIENT then
	function ENT:Draw() self:DrawModel() end
	function ENT:IsTranslucent() return true end
else -- SERVER
	function ENT:Think()
		local vomitPos = self:GetVomitOffset()

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if survivor:GetPos():Distance(vomitPos) > 150 then continue end

			survivor:AddEffect("Slowness", 7)
		end
	end
end