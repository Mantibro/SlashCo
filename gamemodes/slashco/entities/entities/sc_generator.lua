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
        self:SetUseType(SIMPLE_USE)
    end
end

function ENT:SendData(ply)
    --print("sending data")
    net.Start("mantislashcoGasPourProgress")
    net.WriteUInt(TimeToFuel, 8)
    net.WriteEntity(self.FuelingCan)
    net.WriteBool(self.IsFueling)
    net.WriteFloat(self.TimeUntilFueled)
    net.Send(ply)
end

function ENT:Touch(otherEnt)
    if SERVER then
        local index = otherEnt:EntIndex()
        if not self.MakingItem and not self.FuelingCan and SlashCo.CurRound.GasCans[index] and (self.CansRemaining or SlashCo.GasCansPerGenerator) > 0 then
            --print("Gas Touch")

            SlashCo.RemoveSelectableNow(index)
            SlashCo.CurRound.GasCans[index] = nil
            otherEnt:Remove()

            local gasCan = ents.Create("prop_physics")

            gasCan:SetModel( SlashCo.GasCanModel )
            gasCan:SetMoveType(MOVETYPE_NONE)
            gasCan:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            gasCan:SetPos(self:LocalToWorld(Vector(-18, 30, 55)))
            gasCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 45)))
            gasCan:SetParent(self)

            SlashCo.MakeSelectableNow(index)
            self.FuelingCan = gasCan

            SlashCo.SpawnSlasher()
        elseif not self.MakingItem and not self.HasBattery and SlashCo.CurRound.Batteries[index] and otherEnt:GetPos():Distance(self:LocalToWorld(Vector(-7, 25, 50))) < 18 then
            --print("Battery Touch")

            SlashCo.RemoveSelectableNow(index)
            SlashCo.CurRound.Batteries[index] = nil
            otherEnt:Remove()

            local battery = ents.Create("prop_physics")
            self.HasBattery = battery

            battery:SetModel( SlashCo.BatteryModel )
            battery:SetMoveType(MOVETYPE_NONE)
            battery:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            battery:SetPos(self:LocalToWorld(Vector(-7, 25, 50)))
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
end

function ENT:Use(activator, _, _)

    if SERVER then

        if activator:Team() == TEAM_SURVIVOR and activator:GetPos():Distance(self:GetPos()) <= 100 then
            if IsValid(self.FuelingCan) then
                self.IsFueling = true
                self.CurrentPourer = activator
                self.TimeUntilFueled = CurTime() + (self.FuelProgress or TimeToFuel)
                self:SendData(activator)
                self:EmitSound("slashco/generator_fill.wav")
            elseif not self.MakingItem then
                if activator:GetNWString("item2", "none") == "GasCan" and not self.FuelingCan and (self.CansRemaining or SlashCo.GasCansPerGenerator) > 0 then
                    activator:SetNWString("item2", "none")
                    activator:SetRunSpeed(300)

                    self.MakingItem = true
                    timer.Simple(0.25, function()
                        self.MakingItem = nil
                        local gasCan = ents.Create("prop_physics")

                        gasCan:SetModel( SlashCo.GasCanModel )
                        gasCan:SetMoveType(MOVETYPE_NONE)
                        gasCan:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                        gasCan:SetPos(self:LocalToWorld(Vector(-18, 30, 55)))
                        gasCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 45)))
                        gasCan:SetParent(self)

                        SlashCo.MakeSelectableNow(gasCan)
                        self.FuelingCan = gasCan

                        SlashCo.SpawnSlasher()
                    end)
                elseif activator:GetNWString("item2", "none") == "Battery" and not self.HasBattery then
                    activator:SetNWString("item2", "none")

                    self.MakingItem = true
                    timer.Simple(0.25, function()
                        self.MakingItem = nil

                        local battery = ents.Create("prop_physics")
                        self.HasBattery = battery

                        battery:SetModel( SlashCo.BatteryModel )
                        battery:SetMoveType(MOVETYPE_NONE)
                        battery:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                        battery:SetPos(self:LocalToWorld(Vector(-7, 25, 50)))
                        battery:SetAngles(self:LocalToWorldAngles(Angle(0, 90, 0)))
                        battery:SetParent(self)
                        battery:EmitSound("ambient/machines/zap1.wav", 125, 100, 0.5)
                        battery:EmitSound("slashco/battery_insert.wav", 125, 100, 1)

                        SlashCo.SpawnSlasher()
                    end)
                end
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

            if self.CurrentPourer:GetPos():Distance(self:GetPos()) > 100 or not self.CurrentPourer:KeyDown(IN_USE) then
                self.IsFueling = false
                self.FuelProgress = self.TimeUntilFueled - CurTime()
                --print((self.FuelProgress or "nil").." distance")
                self:SendData(self.CurrentPourer)
                self.TimeUntilFueled = nil
                self.CurrentPourer = nil
                self:StopSound("slashco/generator_fill.wav")
                return
            end

            local fuelprog = math.Clamp(TimeToFuel - (self.TimeUntilFueled - CurTime()), 0, TimeToFuel) / TimeToFuel
            self.FuelingCan:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 45 + fuelprog * 80)))
            self.FuelingCan:SetPos(self:LocalToWorld(Vector(-18, 30, 55 + fuelprog * 26)))

            if CurTime() >= self.TimeUntilFueled then
                self.IsFueling = false
                self.FuelProgress = nil
                --print((self.FuelProgress or `nil`).." donefueling")
                self:SendData(self.CurrentPourer)
                self.TimeUntilFueled = nil
                self.CurrentPourer = nil
                self:StopSound("slashco/generator_fill.wav")

                self.CansRemaining = (self.CansRemaining or SlashCo.GasCansPerGenerator) - 1
                self:StopSound("slashco/generator_fill.wav")

                --//discard gas can//--

                self.FuelingCan:PhysicsInit(SOLID_VPHYSICS)
                self.FuelingCan:SetMoveType(MOVETYPE_VPHYSICS)
                self.FuelingCan:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
                self.FuelingCan:SetParent(nil)

                SlashCo.RemoveSelectableNow(self.FuelingCan:EntIndex())

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