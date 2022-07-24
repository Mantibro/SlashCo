AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.ClassName 		= "sc_helicopter"
ENT.PrintName		= "helicopter"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "Transport of SlashCo workers."
ENT.Instructions	= ""
ENT.AutomaticFrameAdvance = true 

local plyCount = 0


function ENT:Initialize()
	if SERVER then
		self:SetModel( SlashCo.HelicopterModel )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )

		timer.Simple(0.1, function()

			self:ResetSequence( 1 )

			SlashCo.UpdateHelicopterSeek(self:GetPos())

			EnableMovement = true
	
		end)
	end

	self:EmitSound("slashco/helicopter_engine_distant.wav", 90, 150, 1,CHAN_STATIC)
	self:EmitSound("slashco/helicopter_rotors_distant.wav", 150, 100, 1,CHAN_STATIC)

	self:EmitSound("slashco/helicopter_engine_close.wav", 75, 150, 1,CHAN_STATIC)
	self:EmitSound("slashco/helicopter_rotors_close.wav", 100, 100, 1,CHAN_STATIC)

end

function ENT:Use( activator, caller, useType, value )

	if SERVER then

		local availabilityHeli = false

		local userEnteredAlready = false

		local SatPlayers = SlashCo.CurRound.HelicopterRescuedPlayers

		if SatPlayers[4] == nil then availabilityHeli = true end

		if activator:Team() == TEAM_SURVIVOR and availabilityHeli then --The Player is sat down in the helicopter

			if activator:GetNWBool("DynamicFlashlight") then activator:SetNWBool("DynamicFlashlight", false) end

		for _, v in ipairs(SatPlayers) do
			local id = activator:SteamID64()

			if v.steamid == id then
				--If the steamid in this entry matches the one we're looking for, that means the player is already in the copter.
				userEnteredAlready = true
				--return
			end
		end

		if userEnteredAlready == false then 
			table.insert(SlashCo.CurRound.HelicopterRescuedPlayers, {steamid = activator:SteamID64()}) 
		end

		local vehicle = ents.Create("prop_vehicle_prisoner_pod")
		--local t = hook.Run("OnPlayerSit", ply, pos, ang, parent or NULL, parentbone, vehicle)

		--if t == false then
		--	SafeRemoveEntity(vehicle)
		--	return false
		--end


		local ang = Angle(0,0,0)
		local pos = Vector(0,0,0)

		if SatPlayers[1] != nil and SatPlayers[1].steamid == activator:SteamID64() then 
			pos = self:LocalToWorld( Vector(-30 , -17, 40) ) 
			ang = self:LocalToWorldAngles( Angle(0,-90,0) ) 

		elseif SatPlayers[2] != nil and SatPlayers[2].steamid == activator:SteamID64() then 
			pos = self:LocalToWorld( Vector(-30 , 17, 40) ) 
			ang = self:LocalToWorldAngles( Angle(0,-90,0) )

		elseif SatPlayers[3] != nil and SatPlayers[3].steamid == activator:SteamID64() then 
			pos = self:LocalToWorld( Vector(30 , -17, 40) ) 
			ang = self:LocalToWorldAngles( Angle(0,90,0) )

		elseif SatPlayers[4] != nil and SatPlayers[4].steamid == activator:SteamID64() then 
			pos = self:LocalToWorld( Vector(30 , 17, 40) ) 
			ang = self:LocalToWorldAngles( Angle(0,90,0) )	
		end

		vehicle:SetPos(pos)
		vehicle:SetAngles(ang)


		vehicle.playerdynseat = true
		vehicle:SetNWBool("playerdynseat", true)

		vehicle:SetModel("models/nova/airboat_seat.mdl") -- DO NOT CHANGE OR CRASHES WILL HAPPEN

		vehicle:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		vehicle:SetKeyValue("limitview","1")
		vehicle:Spawn()
		vehicle:Activate()

		if not IsValid(vehicle) or not IsValid(vehicle:GetPhysicsObject()) then
			SafeRemoveEntity(vehicle)
			return false
		end

		local phys = vehicle:GetPhysicsObject()
		-- Let's try not to crash
		vehicle:SetMoveType(MOVETYPE_PUSH)
		phys:Sleep()
		vehicle:SetCollisionGroup(COLLISION_GROUP_WORLD)

		vehicle:SetNotSolid(true)
		phys:Sleep()
		phys:EnableGravity(false)
		phys:EnableMotion(false)
		phys:EnableCollisions(false)
		phys:SetMass(1)

		vehicle:CollisionRulesChanged()

		-- Visibles
		vehicle:DrawShadow(false)
		vehicle:SetColor(Color(0,0,0,0))
		vehicle:SetRenderMode(RENDERMODE_TRANSALPHA)
		vehicle:SetNoDraw(true)

		vehicle.VehicleName = "Airboat Seat"
		vehicle.ClassOverride = "prop_vehicle_prisoner_pod"

		vehicle:SetParent(self)

		activator:EnterVehicle(vehicle)

		if #SatPlayers == #team.GetPlayers(TEAM_SURVIVOR) and SlashCo.LobbyData.LOBBYSTATE >= 3 and SlashCo.LobbyData.LOBBYSTATE < 5 and GAMEMODE.State == GAMEMODE.States.LOBBY then 

			lobbyFinish()

		end

		if #team.GetPlayers(TEAM_SURVIVOR) > 0 and #SatPlayers == #team.GetPlayers(TEAM_SURVIVOR) and GAMEMODE.State == GAMEMODE.States.IN_GAME then 

			SlashCo.SurvivorWinFinish()

			SlashCo.HelicopterTakeOff()

		end
		
	end

end

end

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function ENT:Think()

	if SERVER then

	TargetPosition = SlashCo.CurRound.HelicopterTargetPosition

	if EnableMovement and TargetPosition != nil then

		targsmoothx = math.sqrt( math.abs(TargetPosition[1] - self:GetPos()[1]) ) * sign(TargetPosition[1] - self:GetPos()[1])

		targsmoothy = math.sqrt( math.abs(TargetPosition[2] - self:GetPos()[2]) ) * sign(TargetPosition[2] - self:GetPos()[2])

		targsmoothz = math.sqrt( math.abs(TargetPosition[3] - self:GetPos()[3]) ) * sign(TargetPosition[3] - self:GetPos()[3])


		self:SetPos( self:GetPos() +   ((Vector(targsmoothx,targsmoothy,targsmoothz)) / 8 )  )

		local vel = Vector(targsmoothx,targsmoothy,targsmoothz):Length()

		local pitchgo = vel / 8

		if math.abs(targsmoothx) > 2 and math.abs(targsmoothy) > 2 then 

			directional = Vector(targsmoothx,targsmoothy,targsmoothz):Angle()[2] * sign(Vector(targsmoothx,targsmoothy,targsmoothz):Length())

		end

		--Entity(1):ChatPrint(tostring(vel))

		self:SetAngles(	 Angle(pitchgo,directional,0)	)

	end

	self:NextThink( CurTime() ) -- Set the next think to run as soon as possible, i.e. the next frame.

	return true -- Apply NextThink call

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