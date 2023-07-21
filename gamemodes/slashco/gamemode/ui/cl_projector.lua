local PANEL = {}

local defaultCam = Vector(40, 0, 0)

---this panel displays an in-world entity
---the view angle is identical to the player's angle relative to the entity,
---however the camera moves to make sure the entity is always in place
---it kinda gives this fun slowglobe-like effect
function PANEL:Init()
	self.Entity = nil
	self.ExtraEntities = {}
	self.DirectionalLight = {}

	self:SetDistance(250)
	self:SetFOV(45)
	self:SetRotation(0)
	self:SetCamPos(defaultCam)
	self:SetAmbientLight(Color(50, 50, 50))
	self:SetDirectionalLight(BOX_TOP, color_white)
	self:SetDirectionalLight(BOX_FRONT, color_white)
end

--- setters -->

---entity to project
function PANEL:SetEntity(entity)
	self.Entity = entity
end

---table of extra entities to also draw
function PANEL:ExtraEntities(entities)
	self.ExtraEntities = entities
end

---overall light
function PANEL:SetAmbientLight(color)
	self.colAmbientLight = color
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

---internal: renders an entity and its children recursively
function PANEL:Render(ent)
	if not IsValid(ent) then
		return
	end

	if not ent:GetNoDraw() then
		ent:DrawModel()
	end

	for _, v in pairs(ent:GetChildren()) do
		self:Render(v)
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

	local vec = Vector(self.Distance * self.Entity:GetModelScale(), 0, 0)
	vec:Rotate(EyeAngles())
	local x, y = self:LocalToScreen(0, 0)

	local pos
	if self.Entity:IsPlayer() and self.CamPos == defaultCam then
		pos = LerpVector(0.5, self.Entity:GetPos(), self.Entity:EyePos())
	else
		pos = self.Entity:GetPos() + self.CamPos
	end

	cam.Start3D(pos - vec, EyeAngles() + self.Rotate, self.FOV, x, y, w, h)
	render.SuppressEngineLighting(true)
	render.SetLightingOrigin(pos)

	render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
	for i = 0, 6 do
		local col = self.DirectionalLight[i]
		if (col) then
			render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
		end
	end

	self:Render(self.Entity)
	if self.ExtraEntities then
		for _, v in pairs(self.ExtraEntities) do
			self:Render(v)
		end
	end

	render.SuppressEngineLighting(false)
	cam.End3D()
end

vgui.Register("slashco_projector", PANEL, "Panel")

--[[
hook.Add("HUDPaint", "3d_camera_example", function()
	local vec = Vector(250, 0, 0)
	vec:Rotate(EyeAngles())

	cam.Start3D(LerpVector(0.5, Player(3):GetPos(), Player(3):EyePos()) - vec, nil, 45)
	Player(3):DrawModel()
	for _, v in pairs(Player(3):GetChildren()) do
		if IsValid(v) and not v:GetNoDraw() then
			v:DrawModel()
		end
	end

	if pac then
		pac.RenderOverride(Player(3), "opaque")
		pac.RenderOverride(Player(3), "translucent")
		pac.RenderOverride(Player(3), "update_legacy_bones")
	end
	cam.End3D()
end)
--]]