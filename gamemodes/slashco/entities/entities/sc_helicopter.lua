AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.ClassName = "sc_helicopter"
ENT.PrintName = "helicopter"
ENT.Author = "Manti"
ENT.Contact = ""
ENT.Purpose = "Transport of SlashCo workers."
ENT.Instructions = ""
ENT.AutomaticFrameAdvance = true
ENT.PingType = "HELICOPTER"

--local plyCount = 0
--local self.switch = false

function ENT:Initialize()
	if SERVER then
		self:SetModel(SlashCo.HelicopterModel)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)

		self.EnableMovement = false
		self.switch = nil

		self.final_dir = self:GetAngles()[2]

		timer.Simple(0.1, function()
			self:ResetSequence(1)
			SlashCo.UpdateHelicopterSeek(self:GetPos())
			self.EnableMovement = true
		end)

		self.pitchgo = self.pitchgo or 0
		self.sway_x = self.sway_x or 0
		self.sway_y = self.sway_y or 0
		self.sway_z = self.sway_z or 0
		self.final_dir = self.final_dir or 0
		self.acceleration = self.acceleration or 0
		self.targsmoothx = self.targsmoothx or 0
		self.targsmoothy = self.targsmoothy or 0
		self.targsmoothz = self.targsmoothz or 0
		self.vel = self.vel or 0
	end

	self:EmitSound("slashco/helicopter_engine_distant.wav", 90, 150, 1, CHAN_STATIC)
	self:EmitSound("slashco/helicopter_rotors_distant.wav", 150, 100, 1, CHAN_STATIC)
	self:EmitSound("slashco/helicopter_engine_close.wav", 75, 150, 1, CHAN_STATIC)
	self:EmitSound("slashco/helicopter_rotors_close.wav", 100, 100, 1, CHAN_STATIC)
end

function sign(number)
	return number > 0 and 1 or (number == 0 and 0 or -1)
end

if SERVER then
	function ENT:Use(activator)
		local availabilityHeli = false
		local userEnteredAlready
		local SatPlayers = SlashCo.CurRound.HelicopterRescuedPlayers

		if game.GetMap() ~= "sc_lobby" and not SlashCo.CurRound.EscapeHelicopterSummoned then
			return
		end

		if SatPlayers[SlashCo.MAXPLAYERS - 1] == nil then
			availabilityHeli = true
		end

		if activator:Team() ~= TEAM_SURVIVOR or not availabilityHeli then
			return
		end
		--The Player is sat down in the helicopter

		if activator:GetNWBool("DynamicFlashlight") then
			activator:SetNWBool("DynamicFlashlight", false)
		end

		for _, v in ipairs(SatPlayers) do
			--local id = activator:SteamID64()

			if v == activator then
				--If the steamid in this entry matches the one we're looking for, that means the player is already in the copter.
				userEnteredAlready = true
				break
			end
		end

		if not userEnteredAlready then
			table.insert(SlashCo.CurRound.HelicopterRescuedPlayers, activator)
		end

		local vehicle = ents.Create("prop_vehicle_prisoner_pod")
		--local t = hook.Run("OnPlayerSit", ply, pos, ang, parent or NULL, parentbone, vehicle)

		--if t == false then
		--	SafeRemoveEntity(vehicle)
		--	return false
		--end


		local ang = Angle(0, 0, 0)
		local pos = Vector(0, 0, 0)
		if SatPlayers[1] == activator then
			pos = self:LocalToWorld(Vector(-34, 24.25, 44.5))
			ang = self:LocalToWorldAngles(Angle(0, -90, 0))
		elseif SatPlayers[2] == activator then
			pos = self:LocalToWorld(Vector(-34, 0, 44.5))
			ang = self:LocalToWorldAngles(Angle(0, -90, 0))
		elseif SatPlayers[3] == activator then
			pos = self:LocalToWorld(Vector(-34, -24.25, 44.5))
			ang = self:LocalToWorldAngles(Angle(0, -90, 0))
		elseif SatPlayers[4] == activator then
			pos = self:LocalToWorld(Vector(24.5, 24.25, 44.5))
			ang = self:LocalToWorldAngles(Angle(0, 90, 0))
		elseif SatPlayers[5] == activator then
			pos = self:LocalToWorld(Vector(24.5, 0, 44.5))
			ang = self:LocalToWorldAngles(Angle(0, 90, 0))
		elseif SatPlayers[6] == activator then
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

		if #SatPlayers == team.NumPlayers(TEAM_SURVIVOR) and SlashCo.LobbyData.LOBBYSTATE >= 3
				and SlashCo.LobbyData.LOBBYSTATE < 5 and GAMEMODE.State == GAMEMODE.States.LOBBY then
			lobbyFinish()
		end
	end

	function ENT:Think()
		self:NextThink(CurTime())

		local SatPlayers = SlashCo.CurRound.HelicopterRescuedPlayers
		local plyCount = #SatPlayers
		local TargetPosition = SlashCo.CurRound.HelicopterTargetPosition

		if self.EnableMovement and TargetPosition ~= nil then
			local IsAirborne = 1

			local ground = util.TraceLine({
				start = self:LocalToWorld(Vector(0, 0, 40)),
				endpos = self:LocalToWorld(Vector(0, 0, 40)) + self:GetUp() * -43,
				filter = self
			})

			if ground.Hit then
				IsAirborne = 0

				local vPoint = self:GetPos()
				local fx = EffectData()
				fx:SetOrigin(vPoint)
				fx:SetScale(math.random(20, 150))
				fx:SetEntity(self)
				util.Effect("ThumperDust", fx)
			end

			self:SetAngles(Angle(self.pitchgo + self.sway_x, self.final_dir + self.sway_y, self.sway_z))
			self:SetPos(self:GetPos() + ((Vector(self.targsmoothx * self.acceleration - self.sway_x,
					self.targsmoothy * self.acceleration - self.sway_y,
					self.targsmoothz * self.acceleration - self.sway_z)) / 8))

			--Calculate it all afterwards

			self.targsmoothx = math.sqrt(math.abs(TargetPosition[1] - self:GetPos()[1])) * sign(TargetPosition[1] - self:GetPos()[1])
			self.targsmoothy = math.sqrt(math.abs(TargetPosition[2] - self:GetPos()[2])) * sign(TargetPosition[2] - self:GetPos()[2])
			self.targsmoothz = math.sqrt(math.abs(TargetPosition[3] - self:GetPos()[3])) * sign(TargetPosition[3] - self:GetPos()[3])

			self.vel = Vector(self.targsmoothx, self.targsmoothy, self.targsmoothz):Length()

			self.sway_x = IsAirborne * math.sin(CurTime() * 0.6) * (2 + (self.pitchgo * 2))
			self.sway_y = IsAirborne * math.sin(CurTime() * 1) * (1.5 + (self.pitchgo * 2))
			self.sway_z = IsAirborne * math.sin(CurTime() * 0.8) * (2 + (self.pitchgo * 2))

			local dir_length = Vector(self.targsmoothx - self.sway_x, self.targsmoothy - self.sway_y,
					self.targsmoothz - self.sway_z):Length()

			local dir_length_sqr = Vector(self.targsmoothx - self.sway_x, self.targsmoothy - self.sway_y, 0):Length()

			if dir_length > 2 then
				local directional = Vector(self.targsmoothx, self.targsmoothy,
						self.targsmoothz):Angle()[2] * sign(Vector(self.targsmoothx,
						self.targsmoothy, self.targsmoothz):Length())

				self.final_dir = self.final_dir + (sign(-self.final_dir + directional) * math.sqrt(self.acceleration * dir_length_sqr / 25) * self.acceleration * (math.abs(-self.final_dir + directional) / 130))

				if self.acceleration == 1.1 then
					self.acceleration = 0
				end

				if self.acceleration < 1 then
					self.acceleration = self.acceleration + (FrameTime() / 3)
				end
			else
				self.acceleration = 1.1
			end

			self.pitchgo = self.acceleration * self.vel / 16
		end

		if team.NumPlayers(TEAM_SURVIVOR) > 0 and plyCount == team.NumPlayers(TEAM_SURVIVOR)
				and GAMEMODE.State == GAMEMODE.States.IN_GAME and self.switch_full == nil then

			SlashCo.UpdateObjective("helicopter", SlashCo.ObjStatus.COMPLETE)
			SlashCo.SendObjectives()

			SlashCo.SurvivorWinFinish()
			SlashCo.HelicopterTakeOff()
			self.switch_full = true
		end

		if team.NumPlayers(TEAM_SURVIVOR) > 0 and plyCount >= (team.NumPlayers(TEAM_SURVIVOR) / 2)
				and GAMEMODE.State == GAMEMODE.States.IN_GAME and self.switch == nil then

			if SlashCo.CurRound.Difficulty ~= 1 then
				return true
			end
			self.switch = true

			local abandon = math.random(80, 220)
			print("[SlashCo] Helicopter set to abandon players in " .. tostring(abandon) .. " seconds.")

			timer.Simple(abandon, function()
				if self.switch_full == true then
					return true
				end

				SlashCo.UpdateObjective("helicopter", SlashCo.ObjStatus.COMPLETE)
				SlashCo.SendObjectives()

				SlashCo.HelicopterTakeOff()
				SlashCo.SurvivorWinFinish()
			end)
		end

		if team.NumPlayers(TEAM_SURVIVOR) > 0 and plyCount > 0 and GAMEMODE.State == GAMEMODE.States.IN_GAME
				and self.switch == nil then

			if SlashCo.CurRound.Difficulty ~= 2 then
				return true
			end
			self.switch = true

			local abandon = math.random(50, 160)
			print("[SlashCo] Helicopter set to abandon players in " .. tostring(abandon) .. " seconds.")

			timer.Simple(abandon, function()
				if self.switch_full == true then
					return true
				end

				SlashCo.UpdateObjective("helicopter", SlashCo.ObjStatus.COMPLETE)
				SlashCo.SendObjectives()

				SlashCo.HelicopterTakeOff()
				SlashCo.SurvivorWinFinish()
			end)
		end

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