local PANEL = {}

local defaultCam = Vector(0, 0, 0)

---this panel displays an in-world entity
---the view angle is identical to the player's angle relative to the entity,
---however the camera moves to make sure the entity is always in place
---it kinda gives this fun slowglobe-like effect
function PANEL:Init()
	self.Entity = nil
	self.ExtraEntities = {}
	self.DirectionalLight = {}

	self:SetDistance(250)
	self:SetFOV(22)
	self:SetRotation(0)
	self:SetCamPos(defaultCam)
	self:SetAmbientLight(Color(50, 50, 50))
	self:SetDirectionalLight(BOX_TOP, color_white)
	self:SetDirectionalLight(BOX_FRONT, color_white)
end

--- setters -->

---entity to project
function PANEL:SetEntity(ent)
	self.Entity = ent
end

---table of extra entities to also draw
function PANEL:ExtraEntities(ents)
	self.ExtraEntities = ents
end

---overall light
function PANEL:SetAmbientLight(color)
	self.colAmbientLight = color
end

---whether to also render the model's children
function PANEL:SetNoKids(value)
	self.NoKids = value
end

---directional light from six positions
---use the BOX constants
function PANEL:SetDirectionalLight(iDirection, color)
	self.DirectionalLight[iDirection] = color
end

---distance to entity
function PANEL:SetDistance(value)
	self.Distance = value
end

---center position of camera
---if not set, the camera position for players is the midpoint between their feet and head
function PANEL:SetCamPos(value)
	self.CamPos = value
end

---set fov of the camera
function PANEL:SetFOV(value)
	self.FOV = value
end

---set the roll of the camera
function PANEL:SetRotation(value)
	self.Rotate = Angle(0, 0, value)
end

--- <--- setters

---add a new extra entity for render
---can also be used to remove
function PANEL:InsertExtraEntity(key, entity)
	self.ExtraEntities[key] = entity
end

function PANEL:OnRender()
	--override this!
end

---Creates a parented copy of a model
function PANEL:ApplyProjectedModel(ent)
	if IsValid(ent.ProjectedModel) then
		ent.ProjectedModel:Remove()
		ent.ProjectedModel = nil
	end

	ent.ProjectedModel = ClientsideModel(ent:GetModel())
	ent.ProjectedModel:SetPos(ent:GetPos())
	ent.ProjectedModel:SetAngles(ent:GetAngles())
	ent.ProjectedModel:SetNoDraw(true)
	ent.ProjectedModel:SetParent(ent)
	ent.ProjectedModel.CreationTime = CurTime()
	if ent:IsPlayer() then
		ent.ProjectedModel:AddEffects(EF_BONEMERGE)
		ent.ProjectedModel:AddEffects(EF_BONEMERGE_FASTCULL)
	end
end

---internal: renders the first entity
function PANEL:RenderTop(ent)
	if not IsValid(ent) then
		return
	end

	if not IsValid(ent.ProjectedModel) then
		self:ApplyProjectedModel(ent)
	end

	if not ent:GetNoDraw() then
		if IsValid(ent.ProjectedModel) and not ent.RenderOverride then
			ent.ProjectedModel:DrawModel()

			if ent:GetModel() ~= ent.ProjectedModel:GetModel() then
				ent:ApplyProjectedModel(ent)
			end
		else
			ent:DrawModel()
		end
	end

	if not self.NoKids then
		for _, v in pairs(ent:GetChildren()) do
			if v ~= ent.ProjectedModel then
				self:Render(v)
			end
		end
	end

	if pac then
		pac.RenderOverride(ent, "opaque")
		pac.RenderOverride(ent, "translucent")
	end
end

---internal: renders an entity and its children recursively
function PANEL:Render(ent)
	if not IsValid(ent) then
		return
	end

	if not ent:GetNoDraw() then
		if IsValid(ent.ProjectedModel) and not ent.RenderOverride then
			ent.ProjectedModel:DrawModel()
		else
			ent:DrawModel()
		end
	end

	if not self.NoKids then
		for _, v in pairs(ent:GetChildren()) do
			if v ~= ent.ProjectedModel then
				self:Render(v)
			end
		end
	end

	if pac then
		pac.RenderOverride(ent, "opaque")
		pac.RenderOverride(ent, "translucent")
	end
end

---internal: paints the model itself
function PANEL:Paint(w, h)
	if not IsValid(self.Entity) then
		return
	end

	local pos
	if self.Entity:IsPlayer() and self.CamPos == defaultCam then
		pos = LerpVector(0.5, self.Entity:GetPos(), self.Entity:EyePos())
	else
		pos = self.Entity:WorldSpaceCenter() + self.CamPos
	end

	local eyeAng = LocalPlayer():LocalEyeAngles() --EyeAngles()
	local vec = Vector(self.Distance * self.Entity:GetModelScale(), 0, 0)
	vec:Rotate(eyeAng)
	local x, y = self:LocalToScreen(0, 0)

	cam.Start3D(pos - vec, eyeAng + self.Rotate, self.FOV, x, y, w, h)
	render.SuppressEngineLighting(true)
	render.SetLightingOrigin(pos)

	self:OnRender()

	render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
	for i = 0, 6 do
		local col = self.DirectionalLight[i]
		if (col) then
			render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
		end
	end

	self:RenderTop(self.Entity)
	if self.ExtraEntities then
		for _, v in pairs(self.ExtraEntities) do
			self:RenderTop(v)
		end
	end

	render.SuppressEngineLighting(false)
	cam.End3D()
end

vgui.Register("slashco_projector", PANEL, "Panel")

--[[
local frame = vgui.Create("DFrame")
frame:SetSize(500, 500)

local project = frame:Add("slashco_projector")
project:SetEntity(LocalPlayer())
project:Dock(FILL)
--]]