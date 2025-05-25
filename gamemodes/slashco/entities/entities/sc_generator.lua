AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName = "sc_generator"
ENT.PrintName = "generator"
ENT.Author = "Octo"
ENT.Contact = ""
ENT.Purpose = "Combustion engine powered generator unit."
ENT.Instructions = ""
ENT.PingType = "GENERATOR"

hook.Add("SlashCo:Precache", "PrecacheGenerator", function()
	SlashCo.PrecacheSound("slashco/generator_fill.mp3")
	SlashCo.PrecacheSound("slashco/generator_start.mp3")
	SlashCo.PrecacheSound("slashco/generator_loop.mp3")
	SlashCo.PrecacheSound("slashco/generator_failstart.mp3")
	SlashCo.PrecacheSound("ambient/machines/zap1.mp3")
	SlashCo.PrecacheSound("slashco/battery_insert.mp3")
	SlashCo.PrecacheModel("models/props_c17/light_cagelight01_on.mdl")
end)

local DefaultTimeToFuel = 13
local TimeToFuel = DefaultTimeToFuel

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Running")
	self:NetworkVar("Int", 0, "CansRemaining")
end

if CLIENT then
	local lightAng = Angle(0, 0, 180)
	local screenAng = Angle(0, 180, 90)
	local screenPos = Vector(-37, 18.8, 45.75)
	function ENT:Draw()
		if GameData.GeneratorLight and not GameData.GeneratorLight:IsValid() then
			GameData.GeneratorLight = nil
		end
		GameData.GeneratorLight = GameData.GeneratorLight or ClientsideModel("models/props_c17/light_cagelight01_on.mdl", RENDERGROUP_OTHER)

		local cacheData = self.cacheData
		if not cacheData then
			local lightPos = self:GetPos()
			local mins, maxs = self:GetModelBounds()
			lightPos[3] = lightPos[3] + (maxs[3] / 1.55)
			
			local ang = self:GetAngles()
			ang:Add(lightAng)

			cacheData = {
				pos = lightPos,
				ang = ang,
				entindex = self:EntIndex(),
				screenPos = self:LocalToWorld(screenPos),
				screenAng = self:LocalToWorldAngles(screenAng),
			}
			self.cacheData = cacheData
		end

		local running = self:GetRunning()
		GameData.GeneratorLight:SetPos(cacheData.pos)
		GameData.GeneratorLight:SetColor4Part(not running and 255 or 0, running and 255 or 0, 0, 255)
		GameData.GeneratorLight:SetAngles(cacheData.ang)
		GameData.GeneratorLight:DrawModel()

		local curTime = CurTime()
		local dlight = DynamicLight(cacheData.entindex + 99996)
		if dlight then
			dlight.pos = cacheData.pos
			dlight.r = not running and 255 or 0
			dlight.g = running and 255 or 0
			dlight.b = 0
			dlight.brightness = 5
			dlight.Decay = 1000
			--dlight.nomodel = true -- We don't need that.
			dlight.Size = math.abs(math.sin(curTime)) * 200
			dlight.DieTime = curTime + 0.1
		end

		self:DrawModel()

		-- Small fuel UI showing how full a generator is
		local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
		local remaining = self:GetCansRemaining()
		if remaining < 0 then
			remaining = 0
		end

		cam.Start3D2D(cacheData.screenPos, cacheData.screenAng, 0.05)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, 100, 190)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawOutlinedRect(5, 5, 90, 180, 2)

			local spaceSize = 15
			local xOffset = (180 - spaceSize) / gasPerGen
			local segmentSize = math.max(xOffset / 1.5, xOffset - 5)
			for k=0, ((gasPerGen - 1) - remaining) do
				surface.DrawRect(15, 180 - xOffset - (xOffset * k), 70, segmentSize)
			end
		cam.End3D2D()
	end

	return
end

function ENT:Initialize()
	self:SetModel(SlashCo.GeneratorModel)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:GetPhysicsObject():EnableMotion(false)
	self:SetUseType(SIMPLE_USE)
	self.Progress = 0

	local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
	self.CansRemaining = gasPerGen
	self:SetCansRemaining(self.CansRemaining)
end

function ENT:ChangeCanProgress(amount)
	local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
	self.CansRemaining = math.Clamp((self.CansRemaining or gasPerGen) - amount, 0, gasPerGen)
	self:SetCansRemaining(self.CansRemaining)
	self.Progress = math.Clamp((gasPerGen - self.CansRemaining) * (4 / gasPerGen), 0, 4) + (self.HasBattery and 1 or 0)

	if self.CansRemaining == 0 then
		for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			v:RemovePointsKey("slasher_perfect")
		end

		SlashCo.NotPerfect = true
	end

	return self.CansRemaining == 0
end

function ENT:SendData(ply)
	net.Start("mantislashco_GasPourProgress")
		net.WriteUInt(TimeToFuel, 8)
		net.WriteEntity(self.FuelingCan)
		net.WriteBool(self.IsFueling)
		net.WriteFloat(self.TimeUntilFueled)
	net.Send(ply)
end

function ENT:Touch(otherEnt)
	local class = otherEnt:GetClass()
	local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
	if not self.MakingItem and not self.FuelingCan and class == "sc_gascan"
			and (self.CansRemaining or gasPerGen) > 0 then

		self:MakeGasCan(otherEnt:GetModel())
		otherEnt:Remove()
	elseif not self.MakingItem and not self.HasBattery and class == "sc_battery"
			and otherEnt:GetPos():Distance(self:LocalToWorld(Vector(-33.59, 13.2, 53.7))) < 26 then

		self:MakeBattery(otherEnt:GetModel())
		otherEnt:Remove()
	end

	self:CheckProgress(true)
end

function ENT:MakeBattery(model)
	self.MakingItem = nil

	if IsValid(self.SpawnedAt) then
		self.SpawnedAt:TriggerOutput("OnBattery", self)
	end

	local battery = ents.Create("prop_physics")
	self.HasBattery = IsValid(battery)
	self.Progress = self.Progress + 1
	self:CheckProgress()

	battery:SetModel(model)
	battery:SetMoveType(MOVETYPE_NONE)
	battery:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	battery:SetPos(self:LocalToWorld(Vector(-33.59, 13.2, 53.7)))
	battery:SetAngles(self:LocalToWorldAngles(Angle(0, 90, 0)))
	battery:SetParent(self)
	battery:EmitSound("ambient/machines/zap1.wav", 125, 100, 0.5)
	battery:EmitSound("slashco/battery_insert.mp3", 125, 100, 1)

	SlashCo.SpawnSlasher()
end

function ENT:MakeGasCan(model)
	self.MakingItem = nil

	if IsValid(self.SpawnedAt) then
		self.SpawnedAt:TriggerOutput("OnInsertFuel", self)
	end

	local gasCan = ents.Create("prop_physics")
	self.FuelingCan = gasCan

	gasCan:SetModel(model)
	gasCan:SetMoveType(MOVETYPE_NONE)
	gasCan:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	gasCan:SetPos(self:LocalToWorld(Vector(-52.65, 33.475, 51.035)))
	gasCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 25)))
	gasCan:SetParent(self)

	SlashCo.SpawnSlasher()
end

function ENT:CheckProgress(dontFailStart)
	local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
	if (self.CansRemaining or gasPerGen) <= 0 and self.HasBattery and not self.IsRunning then
		if IsValid(self.SpawnedAt) then
			self.SpawnedAt:TriggerOutput("OnComplete", self.CurrentPourer)
		end

		self.IsRunning = true
		self.Progress = 5
		self:SetRunning(true)
		self:EmitSound("slashco/generator_start.mp3", 85, 100, 1)

		timer.Simple(6.4, function()
			self:PlayGlobalSound("slashco/generator_loop.mp3", 85, nil, true)
		end)
	elseif not dontFailStart and self.HasBattery and (self.CansRemaining or gasPerGen) > 0 then
		self:EmitSound("slashco/generator_failstart.mp3", 85, 100, 1)
	end
end

function ENT:Use(activator)
	if activator:Team() ~= TEAM_SURVIVOR or activator:GetPos():Distance(self:GetPos()) > 100 then
		return
	end

	if IsValid(self.FuelingCan) then
		if self.IsFueling then
			--if the can is already being poured, don't override them
			return
		end

		--shift TimeToFuel and TimeUntilFueled
		local unShift = DefaultTimeToFuel / TimeToFuel
		TimeToFuel = DefaultTimeToFuel / activator:ItemValue("FuelSpeed", 1)
		if self.FuelProgress then
			self.FuelProgress = self.FuelProgress * unShift * (TimeToFuel / DefaultTimeToFuel)
		end

		self.IsFueling = true
		self.CurrentPourer = activator
		self.TimeUntilFueled = CurTime() + (self.FuelProgress or TimeToFuel)
		self:SendData(activator)
		self:EmitSound("slashco/generator_fill.mp3")
	elseif not self.MakingItem then
		self:SlasherHint()
		local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
		if activator:ItemValue("IsFuel", false, true) then
			if self.FuelingCan or (self.CansRemaining or gasPerGen) <= 0 then
				SlashCo.SendValue(activator, "cantFuel")
				return
			end

			self.MakingItem = true
			self.ItemModel = activator:ItemValue("Model", false, true)
			timer.Simple(0.25, function()
				self:MakeGasCan(self.ItemModel)
			end)

			activator:SecondaryItemFunction("OnFuel", self)
			SlashCo.RemoveItem(activator, true)
		elseif activator:ItemValue("IsBattery", false, true) then
			if self.HasBattery then
				SlashCo.SendValue(activator, "cantPower")
				return
			end

			self.MakingItem = true
			self.ItemModel = activator:ItemValue("Model", false, true)
			timer.Simple(0.25, function()
				self:MakeBattery(self.ItemModel)
			end)

			activator:SecondaryItemFunction("OnBattery", self)
			SlashCo.RemoveItem(activator, true)
		end
	end
end

function ENT:SlasherHint()
	for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		timer.Create(self:GetCreationID() .. "_slasherHint_" .. v:UserID(), 15, 0, function()
			SlashCo.SendValue(v, "genHint", self)
		end)
	end
end

function ENT:SlasherObserve()
	local observed
	local gasPerGen = GetGlobal2Int("SlashCoGasCansPerGenerator", SlashCo.GasPerGen)
	for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		if v:GetEyeTrace().Entity == self and (not v.GenCooldown or CurTime() - v.GenCooldown > 3) then
			timer.Remove(self:GetCreationID() .. "_slasherHint_" .. v:UserID())
			SlashCo.SendValue(v, "genProg", self, self.HasBattery, self.CansRemaining or gasPerGen)
			v.GenCooldown = CurTime()

			observed = true
		end
	end

	if observed and IsValid(self.SpawnedAt) then
		self.SpawnedAt:TriggerOutput("OnSlasherObserved", self.CurrentPourer)
	end
end

function ENT:Think()
	self:SlasherObserve()

	if not self.IsFueling then
		return
	end

	if not IsValid(self.CurrentPourer) or not IsValid(self.FuelingCan) then
		self:StopSound("slashco/generator_fill.mp3")
		self.IsFueling = false
		return
	end

	if self.CurrentPourer:GetPos():Distance(self:GetPos()) > 100 or not self.CurrentPourer:KeyDown(IN_USE) then
		self.IsFueling = false

		self.FuelProgress = self.TimeUntilFueled - CurTime()
		self:SendData(self.CurrentPourer)
		self.TimeUntilFueled = nil
		self.CurrentPourer = nil
		self:StopSound("slashco/generator_fill.mp3")
		return
	end
	local fuelprog = math.Clamp(TimeToFuel - (self.TimeUntilFueled - CurTime()), 0, TimeToFuel) / TimeToFuel
	self.FuelingCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 25 + fuelprog * 40)))
	self.FuelingCan:SetPos(self:LocalToWorld(Vector(-52.65, 33.475, 51.035 + fuelprog * 10)))

	if CurTime() >= self.TimeUntilFueled then
		if SlashCo.CurRound.OfferingData.CurrentOffering == SCInfo.Offering.Nightmare then
			self.CurrentPourer:AddPoints("working", 5 + (#team.GetPlayers(TEAM_SLASHER) * 15))
		else
			self.CurrentPourer:AddPoints("working")
		end

		if IsValid(self.SpawnedAt) then
			self.SpawnedAt:TriggerOutput("OnFueled", self.CurrentPourer)
		end

		self.IsFueling = false
		self.FuelProgress = nil
		TimeToFuel = DefaultTimeToFuel
		self:SendData(self.CurrentPourer)
		self.TimeUntilFueled = nil
		self.CurrentPourer = nil
		self:StopSound("slashco/generator_fill.mp3")
		self:ChangeCanProgress(1)

		--//discard gas can//--

		self.FuelingCan:PhysicsInit(SOLID_VPHYSICS)
		self.FuelingCan:SetMoveType(MOVETYPE_VPHYSICS)
		self.FuelingCan:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self.FuelingCan:SetParent(nil)

		local FuelingCanPhysics = self.FuelingCan:GetPhysicsObject()
		if IsValid(self.FuelingCan:GetPhysicsObject()) then
			FuelingCanPhysics:SetVelocity(Vector(math.random(-200, 200), math.random(-200, 200), 200))
			FuelingCanPhysics:SetAngleVelocity(VectorRand(-1000, 1000))
		end

		local CanToRemove = self.FuelingCan
		timer.Simple(5, function()
			if IsValid(CanToRemove) then
				CanToRemove:Remove()
			end
		end)

		self:CheckProgress()
		self.FuelingCan = nil
	end

	self:NextThink(CurTime()) -- Set the next think to run as soon as possible, i.e. the next frame.
	return true -- Apply NextThink call
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end