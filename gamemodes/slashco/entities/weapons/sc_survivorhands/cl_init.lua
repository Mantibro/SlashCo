include('shared.lua')
include('slashco/gamemode/items/items_init.lua')

function SWEP:Initialize()

    self.heldEntity = ClientsideModel("models/props_junk/metalgascan.mdl", RENDER_GROUP_VIEW_MODEL_OPAQUE)
    if (IsValid(self.heldEntity)) then
        self.heldEntity:SetPos(self:GetPos())
        self.heldEntity:SetAngles(self:GetAngles())
        self.heldEntity:SetParent(self)
        self.heldEntity:SetNoDraw(true)
    end

    self.heldEntityWorld = ClientsideModel("models/props_junk/metalgascan.mdl", RENDER_GROUP_VIEW_MODEL_OPAQUE)
    if (IsValid(self.heldEntityWorld)) then
        self.heldEntityWorld:SetPos(self:GetPos())
        self.heldEntityWorld:SetAngles(self:GetAngles())
        self.heldEntityWorld:SetParent(self)
        self.heldEntityWorld:SetNoDraw(true)
    end
end

function SWEP:ViewModelDrawn()

    local vm = self.Owner:GetViewModel()
    if not IsValid(vm) then
        return
    end

    local item = self.Owner:GetNWString("item2", "none")
    if item == "none" then
        item = self.Owner:GetNWString("item", "none")
    end

    local v
    if SlashCoItems[item] and SlashCoItems[item].ViewModel then
        v = SlashCoItems[item].ViewModel
    end

    if not v then
        self.xPos = Lerp(0.03,self.xPos or 55,55)

        if (self.xPos-55) <= 1 then
            self.lastEquip = nil
        end
    elseif not self.lastEquip or self.lastEquip ~= v then
        self.xPos = Lerp(0.03,self.xPos or v.pos.x,55)

        if (self.xPos-55) <= 1 then
            self.lastEquip = v
        end
    else
        self.xPos = Lerp(0.05,self.xPos or 55,v.pos.x)
    end

    --PrintTable(self.lastEquip)

    if not v and not self.lastEquip then return end
    v = self.lastEquip or v

    local bone = vm:LookupBone("ValveBiped.Bip01_Spine4")
    if not bone then return end
    --assert(bone, "Tried to use a bone that doesn't exist! (viewmodel)")
    local m = vm:GetBoneMatrix(bone)
    local pos, ang = Vector(0,0,0), Angle(0,0,0)
    if m then
        pos, ang = m:GetTranslation(), m:GetAngles()
    end

    if self.ViewModelFlip then
        ang.r = -ang.r -- Fixes mirrored models
    end

    if IsValid(self.heldEntity) then

        self.heldEntity:SetModel(v.model)
        self.heldEntity:SetPos(pos + ang:Forward() * self.xPos + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)

        self.heldEntity:SetAngles(ang)
        local matrix = Matrix()
        matrix:Scale(v.size)
        self.heldEntity:EnableMatrix("RenderMultiply", matrix)

        if (v.material == "") then
            self.heldEntity:SetMaterial("")
        elseif (self.heldEntity:GetMaterial() ~= v.material) then
            self.heldEntity:SetMaterial(v.material)
        end

        if (v.skin and v.skin ~= self.heldEntity:GetSkin()) then
            self.heldEntity:SetSkin(v.skin)
        end

        if (v.bodygroup) then
            for k, v1 in pairs(v.bodygroup) do
                if (self.heldEntity:GetBodygroup(k) ~= v1) then
                    self.heldEntity:SetBodygroup(k, v1)
                end
            end
        end

        if (v.surpresslightning) then
            render.SuppressEngineLighting(true)
        end

        render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
        render.SetBlend(v.color.a / 255)
        self.heldEntity:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)

        if (v.surpresslightning) then
            render.SuppressEngineLighting(false)
        end
    else
        self:Initialize()
    end
end

function SWEP:DrawWorldModel()

    if not IsValid(self.Owner) then
        return
    end

    local item = self.Owner:GetNWString("item2", "none")
    if item == "none" then
        item = self.Owner:GetNWString("item", "none")
    end

    local v
    if SlashCoItems[item] and SlashCoItems[item].WorldModel then
        v = SlashCoItems[item].WorldModel
    end
    if not v then
        self.heldEntityWorld:SetNoDraw(true)
        self:SetHoldType("normal")
        return
    end

    self:SetHoldType(v.holdtype)
    local bone = self.Owner:LookupBone(v.bone)
    if not bone then return end
    --assert(bone, "Tried to use a bone that doesn't exist! (worldmodel)")
    local m = self.Owner:GetBoneMatrix(bone)
    local pos, ang = Vector(0,0,0), Angle(0,0,0)
    if m then
        pos, ang = m:GetTranslation(), m:GetAngles()
    end

    if IsValid(self.heldEntityWorld) then
        self.heldEntityWorld:SetModel(v.model)
        self.heldEntityWorld:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)

        self.heldEntityWorld:SetAngles(ang)
        --model:SetModelScale(v.size)
        local matrix = Matrix()
        matrix:Scale(v.size)
        self.heldEntityWorld:EnableMatrix("RenderMultiply", matrix)

        if (v.material == "") then
            self.heldEntityWorld:SetMaterial("")
        elseif (self.heldEntityWorld:GetMaterial() ~= v.material) then
            self.heldEntityWorld:SetMaterial(v.material)
        end

        if (v.skin and v.skin ~= self.heldEntityWorld:GetSkin()) then
            self.heldEntityWorld:SetSkin(v.skin)
        end

        if (v.bodygroup) then
            for k, v1 in pairs(v.bodygroup) do
                if (self.heldEntityWorld:GetBodygroup(k) ~= v1) then
                    self.heldEntityWorld:SetBodygroup(k, v1)
                end
            end
        end

        if (v.surpresslightning) then
            render.SuppressEngineLighting(true)
        end

        render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
        render.SetBlend(v.color.a / 255)
        self.heldEntityWorld:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)

        if (v.surpresslightning) then
            render.SuppressEngineLighting(false)
        end
    else
        self:Initialize()
    end
end