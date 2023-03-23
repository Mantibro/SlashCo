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

--local plyCount = 0
--local self.switch = false

function ENT:Initialize()
	if SERVER then
		self:SetModel( SlashCo.HelicopterModel )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )

		self.EnableMovement = false
		self.switch = nil

		self.final_dir = self:GetAngles()[2]

		timer.Simple(0.1, function()

			self:ResetSequence( 1 )

			SlashCo.UpdateHelicopterSeek(self:GetPos())

			self.EnableMovement = true
	
		end)
	end

	self:EmitSound("slashco/helicopter_engine_distant.wav", 90, 150, 1,CHAN_STATIC)
	self:EmitSound("slashco/helicopter_rotors_distant.wav", 150, 100, 1,CHAN_STATIC)

	self:EmitSound("slashco/helicopter_engine_close.wav", 75, 150, 1,CHAN_STATIC)
	self:EmitSound("slashco/helicopter_rotors_close.wav", 100, 100, 1,CHAN_STATIC)

end

function ENT:Use(activator, _, _, _)
	--activator, caller, useType, value

	if SERVER then

		local availabilityHeli = false

		local userEnteredAlready = false

		local SatPlayers = SlashCo.CurRound.HelicopterRescuedPlayers

		if game.GetMap() ~= "sc_lobby" and not SlashCo.CurRound.EscapeHelicopterSummoned then
			return
		end

		if SatPlayers[SlashCo.MAXPLAYERS - 1] == nil then
			availabilityHeli = true
		end

		if activator:Team() == TEAM_SURVIVOR and availabilityHeli then
			--The Player is sat down in the helicopter

			if activator:GetNWBool("DynamicFlashlight") then
				activator:SetNWBool("DynamicFlashlight", false)
			end

			for _, v in ipairs(SatPlayers) do
				local id = activator:SteamID64()

				if v.steamid == id then
					--If the steamid in this entry matches the one we're looking for, that means the player is already in the copter.
					userEnteredAlready = true
					--return
				end
			end

			if userEnteredAlready == false then
				table.insert(SlashCo.CurRound.HelicopterRescuedPlayers, { steamid = activator:SteamID64() })
			end

			local vehicle = ents.Create("prop_vehicle_prisoner_pod")
			--local t = hook.Run("OnPlayerSit", ply, pos, ang, parent or NULL, parentbone, vehicle)

			--if t == false then
			--	SafeRemoveEntity(vehicle)
			--	return false
			--end


			--local ang = Angle(0,0,0)
			--local pos = Vector(0,0,0)

			if SatPlayers[1] ~= nil and SatPlayers[1].steamid == activator:SteamID64() then
				pos = self:LocalToWorld(Vector(-34, 24.25, 44.5))
				ang = self:LocalToWorldAngles(Angle(0, -90, 0))

			elseif SatPlayers[2] ~= nil and SatPlayers[2].steamid == activator:SteamID64() then
				pos = self:LocalToWorld(Vector(-34, 0, 44.5))
				ang = self:LocalToWorldAngles(Angle(0, -90, 0))

			elseif SatPlayers[3] ~= nil and SatPlayers[3].steamid == activator:SteamID64() then
				pos = self:LocalToWorld(Vector(-34, -24.25, 44.5))
				ang = self:LocalToWorldAngles(Angle(0, -90, 0))

			elseif SatPlayers[4] ~= nil and SatPlayers[4].steamid == activator:SteamID64() then
				pos = self:LocalToWorld(Vector(24.5, 24.25, 44.5))
				ang = self:LocalToWorldAngles(Angle(0, 90, 0))

			elseif SatPlayers[5] ~= nil and SatPlayers[5].steamid == activator:SteamID64() then
				pos = self:LocalToWorld(Vector(24.5, 0, 44.5))
				ang = self:LocalToWorldAngles(Angle(0, 90, 0))

			elseif SatPlayers[6] ~= nil and SatPlayers[6].steamid == activator:SteamID64() then
				pos = self:LocalToWorld(Vector(24.5, -24.25, 44.5))
				ang = self:LocalToWorldAngles(Angle(0, 90, 0))
			end

			vehicle:SetPos(pos)
			vehicle:SetAngles(ang)

			vehicle.playerdynseat = true
			vehicle:SetNWBool("playerdynseat", true)

			vehicle:SetModel("models/nova/airboat_seat.mdl") -- DO NOT CHANGE OR CRASHES WILL HAPPEN

			vehicle:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
			vehicle:SetKeyValue("limitview", "1")
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
			vehicle:SetColor(Color(0, 0, 0, 0))
			vehicle:SetRenderMode(RENDERMODE_TRANSALPHA)
			vehicle:SetNoDraw(true)

			vehicle.VehicleName = "Airboat Seat"
			vehicle.ClassOverride = "prop_vehicle_prisoner_pod"

			vehicle:SetParent(self)

			activator:EnterVehicle(vehicle)

			if #SatPlayers == #team.GetPlayers(TEAM_SURVIVOR) and SlashCo.LobbyData.LOBBYSTATE >= 3 and SlashCo.LobbyData.LOBBYSTATE < 5 and GAMEMODE.State == GAMEMODE.States.LOBBY then

				lobbyFinish()

			end

		end

	end

end

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function ENT:Think()

	if SERVER then

	local SatPlayers = SlashCo.CurRound.HelicopterRescuedPlayers

	TargetPosition = SlashCo.CurRound.HelicopterTargetPosition

	if self.EnableMovement and TargetPosition ~= nil then

		if pitchgo == nil then pitchgo = 0 end

		if sway_x == nil then sway_x = 0 end
		if sway_y == nil then sway_y = 0 end
		if sway_z == nil then sway_z = 0 end

		if self.final_dir == nil then self.final_dir = 0 end

		if acceleration == nil then acceleration = 0 end

		if targsmoothx == nil then targsmoothx = 0 end
		if targsmoothy == nil then targsmoothy = 0 end
		if targsmoothz == nil then targsmoothz = 0 end

		if vel == nil then vel = 0 end

		local IsAirborne = 1

		local ground = util.TraceLine( {
			start = self:LocalToWorld(Vector(0,0,40)),
			endpos = self:LocalToWorld(Vector(0,0,40)) + self:GetUp() * -43,
			filter = self
		} )

		if ground.Hit then

			IsAirborne = 0

			local vPoint = self:GetPos()
        	local fx = EffectData()
        	fx:SetOrigin( vPoint )
			fx:SetScale( math.random(20,150) )
			fx:SetEntity( self )
        	util.Effect( "ThumperDust", fx )

		end

		self:SetAngles(	 Angle(pitchgo+sway_x,self.final_dir+sway_y,sway_z)	)
		self:SetPos( self:GetPos() +   ((Vector(targsmoothx*acceleration-sway_x,targsmoothy*acceleration-sway_y,targsmoothz*acceleration-sway_z)) / 8 )  )

		--Calculate it all afterwards

		targsmoothx = math.sqrt( math.abs(TargetPosition[1] - self:GetPos()[1]) ) * sign(TargetPosition[1] - self:GetPos()[1])

		targsmoothy = math.sqrt( math.abs(TargetPosition[2] - self:GetPos()[2]) ) * sign(TargetPosition[2] - self:GetPos()[2])

		targsmoothz = math.sqrt( math.abs(TargetPosition[3] - self:GetPos()[3]) ) * sign(TargetPosition[3] - self:GetPos()[3])

		vel = Vector(targsmoothx,targsmoothy,targsmoothz):Length()

		sway_x = IsAirborne*math.sin(CurTime()*0.6)*(2+(pitchgo*2))
		sway_y = IsAirborne*math.sin(CurTime()*1)*(1.5+(pitchgo*2))
		sway_z = IsAirborne*math.sin(CurTime()*0.8)*(2+(pitchgo*2))

		local dir_length = Vector(targsmoothx-sway_x,targsmoothy-sway_y,targsmoothz-sway_z):Length()

		local dir_length_sqr = Vector(targsmoothx-sway_x,targsmoothy-sway_y,0):Length()

		if dir_length > 2 then 

			directional = Vector(targsmoothx,targsmoothy,targsmoothz):Angle()[2] * sign(Vector(targsmoothx,targsmoothy,targsmoothz):Length())

			self.final_dir = self.final_dir + (	sign(-self.final_dir+directional)	*math.sqrt(acceleration*dir_length_sqr/25)*acceleration*	(math.abs(-self.final_dir+directional)	/	130)	)

			if acceleration == 1.1 then acceleration = 0 end

			if acceleration < 1 then acceleration = acceleration + (FrameTime()/3) end
		else

			acceleration = 1.1

		end

		pitchgo = acceleration*vel / 16

	end

	if #team.GetPlayers(TEAM_SURVIVOR) > 0 and #SatPlayers == #team.GetPlayers(TEAM_SURVIVOR) and GAMEMODE.State == GAMEMODE.States.IN_GAME and self.switch_full == nil then 

		SlashCo.SurvivorWinFinish()

		SlashCo.HelicopterTakeOff()

		self.switch_full = true 

	end

	if #team.GetPlayers(TEAM_SURVIVOR) > 0 and #SatPlayers >= (#team.GetPlayers(TEAM_SURVIVOR) / 2) and GAMEMODE.State == GAMEMODE.States.IN_GAME and self.switch == nil then 

		if SlashCo.CurRound.Difficulty ~= 1 then return end
		self.switch = true

		local abandon = math.random(80, 220)
		print("[SlashCo] Helicopter set to abandon players in "..tostring(abandon).." seconds.")

    	timer.Simple(abandon, function() 
    
			if self.switch_full == true then return end

        	SlashCo.HelicopterTakeOff()
        	SlashCo.SurvivorWinFinish()

    	end)

	end

	if #team.GetPlayers(TEAM_SURVIVOR) > 0 and #SatPlayers > 0 and GAMEMODE.State == GAMEMODE.States.IN_GAME and self.switch == nil then 

		if SlashCo.CurRound.Difficulty ~= 2 then return end
		self.switch = true 

		local abandon = math.random(50, 160)
		print("[SlashCo] Helicopter set to abandon players in "..tostring(abandon).." seconds.")

    	timer.Simple(abandon, function() 

			if self.switch_full == true then return end
    
        	SlashCo.HelicopterTakeOff()
        	SlashCo.SurvivorWinFinish()

    	end)

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