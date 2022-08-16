AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName    = "sc_generator"
ENT.PrintName    = "generator"
ENT.Author       = "Octo"
ENT.Contact      = ""
ENT.Purpose      = "Combustion engine powered generator unit."
ENT.Instructions = ""

local TimeToFuel = 13

function ENT:Initialize()
    if SERVER then
        self:SetModel(SlashCo.GeneratorModel)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:GetPhysicsObject():EnableMotion(false)
        self:SetUseType(ONOFF_USE)
    end
end

function ENT:Touch(otherEnt)
    if SERVER then
        if not self.FuelingCan and otherEnt:GetModel() == SlashCo.GasCanModel and otherEnt:IsPlayerHolding() and (self.CansRemaining or SlashCo.GasCansPerGenerator) > 0 then
            --print("Gas Touch")

            table.RemoveByValue(SlashCo.CurRound.GasCans, otherEnt:EntIndex())

            DropEntityIfHeld(otherEnt)
            otherEnt:SetMoveType(MOVETYPE_NONE)
            otherEnt:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            otherEnt:SetPos(self:LocalToWorld(Vector(-18, 30, 55)))
            otherEnt:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 45)))
            otherEnt:SetParent(self)

            self.FuelingCan = otherEnt

            SlashCo.CancelSlasherSpawnDelay()
        end

        if not self.HasBattery and otherEnt:GetModel() == SlashCo.BatteryModel and otherEnt:IsPlayerHolding() and otherEnt:GetPos():Distance(self:LocalToWorld(Vector(-7, 25, 50))) < 18 then
            --print("Battery Touch")
            self.HasBattery = true
            DropEntityIfHeld(otherEnt)
            otherEnt:SetMoveType(MOVETYPE_NONE)
            otherEnt:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            otherEnt:SetPos(self:LocalToWorld(Vector(-7, 25, 50)))
            otherEnt:SetAngles(self:LocalToWorldAngles(Angle(0, 90, 0)))
            otherEnt:SetParent(self)
            otherEnt:EmitSound("ambient/machines/zap1.wav", 125, 100, 0.5)
            otherEnt:EmitSound("slashco/battery_insert.wav", 125, 100, 1)
            SlashCo.RemoveSelectableNow(otherEnt:EntIndex())

            SlashCo.CancelSlasherSpawnDelay()
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
end

function ENT:Use(activator, _, usetype)

    if SERVER then

        if activator:Team() == TEAM_SURVIVOR and IsValid(self.FuelingCan) and activator:GetPos():Distance(self:GetPos()) <= 100 then

            if usetype == USE_ON then
                --print((self.FuelProgress or "nil").." do e")
                self.IsFueling = true
                self.CurrentPourer = activator
                self.AntiSpam = false
                self.TimeUntilFueled = CurTime() + (self.FuelProgress or TimeToFuel)
                net.Start("mantislashcoGasPourProgress")
                net.WriteUInt(TimeToFuel, 8)
                net.WriteEntity(self.FuelingCan)
                net.WriteBool(self.IsFueling)
                net.WriteFloat(self.TimeUntilFueled)
                net.Send(activator)
                self:EmitSound("slashco/generator_fill.wav")
            elseif usetype == USE_OFF then
                --print((self.FuelProgress or "nil").." done e")
                if not self.TimeUntilFueled then
                    self.TimeUntilFueled = CurTime() + (self.FuelProgress or TimeToFuel)
                end
                self.IsFueling = false
                self.AntiSpam = false
                self.FuelProgress = self.TimeUntilFueled - CurTime()
                net.Start("mantislashcoGasPourProgress")
                net.WriteUInt(TimeToFuel, 8)
                net.WriteEntity(self.FuelingCan)
                net.WriteBool(self.IsFueling)
                net.WriteFloat(self.TimeUntilFueled)
                net.Send(activator)
                self.CurrentPourer = nil
                self:StopSound("slashco/generator_fill.wav")
            end

        end

    end

end

function ENT:Think()

    if SERVER then
        if not IsValid(self.CurrentPourer) then
            self:StopSound("slashco/generator_fill.wav")
            return
        end

        if IsValid(self.FuelingCan) and self.IsFueling then

            if self.CurrentPourer:GetPos():Distance(self:GetPos()) > 100 then
                self.IsFueling = false
                self.AntiSpam = false
                self.FuelProgress = self.TimeUntilFueled - CurTime()
                --print((self.FuelProgress or "nil").." distance")
                net.Start("mantislashcoGasPourProgress")
                net.WriteUInt(TimeToFuel, 8)
                net.WriteEntity(self.FuelingCan)
                net.WriteBool(self.IsFueling)
                net.WriteFloat(self.TimeUntilFueled)
                net.Send(self.CurrentPourer)
                self.CurrentPourer = nil
                self:StopSound("slashco/generator_fill.wav")
            end

            if self.AntiSpam == false then
                --self:EmitSound("slashco/generator_fill.wav")
                self.AntiSpam = true
            end

            local fuelprog = math.Clamp(TimeToFuel - (self.TimeUntilFueled - CurTime()), 0, TimeToFuel) / TimeToFuel
            self.FuelingCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 45 + fuelprog * 80)))
            self.FuelingCan:SetPos(self:LocalToWorld(Vector(-18, 30, 55 + fuelprog * 26)))

            if CurTime() >= self.TimeUntilFueled then
                self.IsFueling = false
                self.AntiSpam = false
                self.FuelProgress = nil
                --print((self.FuelProgress or `nil`).." donefueling")
                net.Start("mantislashcoGasPourProgress")
                net.WriteUInt(TimeToFuel, 8)
                net.WriteEntity(self.FuelingCan)
                net.WriteBool(self.IsFueling)
                net.WriteFloat(self.TimeUntilFueled)
                net.Send(self.CurrentPourer)
                self.TimeUntilFueled = nil
                self.CurrentPourer = nil
                self:StopSound("slashco/generator_fill.wav")

                self.CansRemaining = (self.CansRemaining or SlashCo.GasCansPerGenerator) - 1
                self.AntiSpam = false
                self:StopSound("slashco/generator_fill.wav")

                --//discard gas can//--

                self.FuelingCan:PhysicsInit(SOLID_VPHYSICS)
                self.FuelingCan:SetMoveType(MOVETYPE_VPHYSICS)
                self.FuelingCan:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
                self.FuelingCan:SetParent(nil)

                SlashCo.RemoveSelectableNow(self.FuelingCan:EntIndex())

                SlashCo.CurRound.DiscardedCans[self.FuelingCan:EntIndex()] = true

                local FuelingCanPhysics = self.FuelingCan:GetPhysicsObject()
                FuelingCanPhysics:SetVelocity(Vector(math.random(-200, 200), math.random(-200, 200), 200))

                local randomvec = Vector(0, 0, 0)
                randomvec:Random(-1000, 1000)
                FuelingCanPhysics:SetAngleVelocity(randomvec)

                local CanToRemove = self.FuelingCan
                timer.Simple(5, function()
                    SlashCo.CurRound.DiscardedCans[CanToRemove:EntIndex()] = nil
                    CanToRemove:Remove()
                end)

                --//start generator if ready//--

                if self.CansRemaining <= 0 and self.HasBattery and not self.IsRunning then
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