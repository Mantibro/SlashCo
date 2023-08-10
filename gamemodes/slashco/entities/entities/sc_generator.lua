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

local DefaultTimeToFuel = 13
local TimeToFuel = DefaultTimeToFuel

function ENT:Initialize()
	if CLIENT then
		return
	end

	self:SetModel(SlashCo.GeneratorModel)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:GetPhysicsObject():EnableMotion(false)
	self:SetUseType(SIMPLE_USE)
end

function ENT:SendData(ply)
	net.Start("mantislashcoGasPourProgress")
	net.WriteUInt(TimeToFuel, 8)
	net.WriteEntity(self.FuelingCan)
	net.WriteBool(self.IsFueling)
	net.WriteFloat(self.TimeUntilFueled)
	net.Send(ply)
end

function ENT:Touch(otherEnt)
	if CLIENT then
		return
	end

	local class = otherEnt:GetClass()
	if not self.MakingItem and not self.FuelingCan and class == "sc_gascan" and (self.CansRemaining or SlashCo.GasCansPerGenerator) > 0 then
		otherEnt:Remove()

		local gasCan = ents.Create("prop_physics")

		gasCan:SetModel(SlashCoItems.GasCan.Model)
		gasCan:SetMoveType(MOVETYPE_NONE)
		gasCan:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		gasCan:SetPos(self:LocalToWorld(Vector(-52.65, 33.475, 51.035)))
		gasCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 25)))
		gasCan:SetParent(self)

		self.FuelingCan = gasCan

		SlashCo.SpawnSlasher()
	elseif not self.MakingItem and not self.HasBattery and class == "sc_battery" and otherEnt:GetPos():Distance(self:LocalToWorld(Vector(-33.59,
			13.2, 53.7))) < 26 then
		otherEnt:Remove()

		local battery = ents.Create("prop_physics")
		self.HasBattery = battery

		battery:SetModel(SlashCoItems.Battery.Model)
		battery:SetMoveType(MOVETYPE_NONE)
		battery:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		battery:SetPos(self:LocalToWorld(Vector(-33.59, 13.2, 53.7)))
		battery:SetAngles(self:LocalToWorldAngles(Angle(0, 90, 0)))
		battery:SetParent(self)
		battery:EmitSound("ambient/machines/zap1.wav", 125, 100, 0.5)
		battery:EmitSound("slashco/battery_insert.wav", 125, 100, 1)

		SlashCo.SpawnSlasher()
	end

	if (self.CansRemaining or SlashCo.GasCansPerGenerator) <= 0 and self.HasBattery and not self.IsRunning then
		self.IsRunning = true
		local delay = 6
		self:EmitSound("slashco/generator_start.wav", 85, 100, 1)

		timer.Simple(delay, function()
			PlayGlobalSound("slashco/generator_loop.wav", 85, self)
		end)
	end
end

function ENT:MakeBattery(model)
	self.MakingItem = nil

	local battery = ents.Create("prop_physics")
	self.HasBattery = IsValid(battery)

	battery:SetModel(model)
	battery:SetMoveType(MOVETYPE_NONE)
	battery:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	battery:SetPos(self:LocalToWorld(Vector(-33.59, 13.2, 53.7)))
	battery:SetAngles(self:LocalToWorldAngles(Angle(0, 90, 0)))
	battery:SetParent(self)
	battery:EmitSound("ambient/machines/zap1.wav", 125, 100, 0.5)
	battery:EmitSound("slashco/battery_insert.wav", 125, 100, 1)

	SlashCo.SpawnSlasher()
end

function ENT:MakeGasCan(model)
	self.MakingItem = nil
	local gasCan = ents.Create("prop_physics")

	gasCan:SetModel(model)
	gasCan:SetMoveType(MOVETYPE_NONE)
	gasCan:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	gasCan:SetPos(self:LocalToWorld(Vector(-52.65, 33.475, 51.035)))
	gasCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 25)))
	gasCan:SetParent(self)

	self.FuelingCan = gasCan

	SlashCo.SpawnSlasher()
end

function ENT:Use(activator, _, _)
	if CLIENT or activator:Team() ~= TEAM_SURVIVOR or activator:GetPos():Distance(self:GetPos()) > 100 then
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
		self:EmitSound("slashco/generator_fill.wav")
	elseif not self.MakingItem then
		self:SlasherHint()
		if activator:ItemValue("IsFuel", false,
				true) and not self.FuelingCan and (self.CansRemaining or SlashCo.GasCansPerGenerator) > 0 then
			self.MakingItem = true
			self.ItemModel = activator:ItemValue("Model", false, true)
			timer.Simple(0.25, function()
				self:MakeGasCan(self.ItemModel)
			end)

			if IsValid(self.SpawnedAt) then
				self.SpawnedAt:TriggerOutput("OnInsertFuel", activator)
			end

			activator:SecondaryItemFunction("OnFuel", self)
			SlashCo.RemoveItem(activator, true)
		elseif activator:ItemValue("IsBattery", false, true) and not self.HasBattery then
			self.MakingItem = true
			self.ItemModel = activator:ItemValue("Model", false, true)
			timer.Simple(0.25, function()
				self:MakeBattery(self.ItemModel)
			end)

			if IsValid(self.SpawnedAt) then
				self.SpawnedAt:TriggerOutput("OnBattery", activator)
			end

			activator:SecondaryItemFunction("OnBattery", self)
			SlashCo.RemoveItem(activator, true)
		end
	end
end

function ENT:SlasherHint()
	for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		timer.Create(self:GetCreationID() .. "_slasherHint_" .. v:UserID(), 20, 0, function()
			SlashCo.SendValue(v, "genHint", self)
		end)
	end
end

function ENT:SlasherObserve()
	local observed
	for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		if v:GetEyeTrace().Entity == self and (not v.GenCooldown or CurTime() - v.GenCooldown > 3) then
			timer.Remove(self:GetCreationID() .. "_slasherHint_" .. v:UserID())
			SlashCo.SendValue(v, "genProg", self, self.HasBattery, self.CansRemaining or SlashCo.GasCansPerGenerator)
			v.GenCooldown = CurTime()

			observed = true
		end
	end

	if observed and IsValid(self.SpawnedAt) then
		self.SpawnedAt:TriggerOutput("OnSlasherObserved", self.CurrentPourer)
	end
end

function ENT:Think()
	if ClIENT then
		return
	end

	if SERVER then
		self:SlasherObserve()
	end

	if not self.IsFueling then
		return
	end

	if not IsValid(self.CurrentPourer) or not IsValid(self.FuelingCan) then
		self:StopSound("slashco/generator_fill.wav")
		self.IsFueling = false
		return
	end

	if self.CurrentPourer:GetPos():Distance(self:GetPos()) > 100 or not self.CurrentPourer:KeyDown(IN_USE) then
		self.IsFueling = false

		self.FuelProgress = self.TimeUntilFueled - CurTime()
		self:SendData(self.CurrentPourer)
		self.TimeUntilFueled = nil
		self.CurrentPourer = nil
		self:StopSound("slashco/generator_fill.wav")
		return
	end
	local fuelprog = math.Clamp(TimeToFuel - (self.TimeUntilFueled - CurTime()), 0, TimeToFuel) / TimeToFuel
	self.FuelingCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 25 + fuelprog * 40)))
	self.FuelingCan:SetPos(self:LocalToWorld(Vector(-52.65, 33.475, 51.035 + fuelprog * 10)))

	if CurTime() >= self.TimeUntilFueled then
		SlashCo.PlayerData[self.CurrentPourer:SteamID64()].PointsTotal = SlashCo.PlayerData[self.CurrentPourer:SteamID64()].PointsTotal + 5

		if SlashCo.CurRound.OfferingData.CurrentOffering == 6 then
			SlashCo.PlayerData[self.CurrentPourer:SteamID64()].PointsTotal = SlashCo.PlayerData[self.CurrentPourer:SteamID64()].PointsTotal + (#team.GetPlayers(TEAM_SLASHER) * 15)
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
		self:StopSound("slashco/generator_fill.wav")

		self.CansRemaining = (self.CansRemaining or SlashCo.GasCansPerGenerator) - 1

		--//discard gas can//--

		self.FuelingCan:PhysicsInit(SOLID_VPHYSICS)
		self.FuelingCan:SetMoveType(MOVETYPE_VPHYSICS)
		self.FuelingCan:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self.FuelingCan:SetParent(nil)

		local FuelingCanPhysics = self.FuelingCan:GetPhysicsObject()
		FuelingCanPhysics:SetVelocity(Vector(math.random(-200, 200), math.random(-200, 200), 200))

		local randomvec = Vector(0, 0, 0)
		randomvec:Random(-1000, 1000)
		FuelingCanPhysics:SetAngleVelocity(randomvec)

		local CanToRemove = self.FuelingCan
		timer.Simple(5, function()
			CanToRemove:Remove()
		end)

		--//start generator if ready//--

		if self.CansRemaining <= 0 and self.HasBattery and not self.IsRunning then
			if IsValid(self.SpawnedAt) then
				self.SpawnedAt:TriggerOutput("OnComplete", self.CurrentPourer)
			end

			self.IsRunning = true
			self:EmitSound("slashco/generator_start.wav", 85, 100, 1)

			timer.Simple(6.4, function()
				PlayGlobalSound("slashco/generator_loop.wav", 85, self, 1)
			end)
		elseif self.HasBattery and self.CansRemaining > 0 then
			self:EmitSound("slashco/generator_failstart.wav", 85, 100, 1)
		end

		self.FuelingCan = nil
	end

	self:NextThink(CurTime()) -- Set the next think to run as soon as possible, i.e. the next frame.
	return true -- Apply NextThink call
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end