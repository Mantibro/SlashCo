local PANEL = {}

local defaultCam = Vector(40, 0, 0)

function PANEL:Init()
	self.Entity = nil
	self.Distance = 250
	self.CamPos = defaultCam
	self.FOV = 45
	self.Rotate = angle_zero
end

function PANEL:SetEntity(entity)
	self.Entity = entity
end

function PANEL:SetDistance(value)
	self.Distance = value
end

function PANEL:SetCamPos(value)
	self.CamPos = value
end

function PANEL:SetFOV(value)
	self.FOV = value
end

function PANEL:SetRotation(value)
	self.Rotate = Angle(0, 0, value)
end

function PANEL:Paint(w, h)
	if not IsValid(self.Entity) then
		return
	end

	local vec = Vector(self.Distance, 0, 0)
	vec:Rotate(EyeAngles())

	local x, y = self:LocalToScreen(0, 0)

	if self.Entity:IsPlayer() and self.CamPos == defaultCam then
		cam.Start3D(LerpVector(0.5, self.Entity:GetPos(), self.Entity:EyePos()) - vec, EyeAngles() + self.Rotate,
				self.FOV, x, y, w, h)
	else
		cam.Start3D(self.Entity:GetPos() + self.CamPos - vec, EyeAngles() + self.Rotate, self.FOV, x, y, w, h)
	end
	render.SuppressEngineLighting(true)
	render.SetLightingMode(1)

	self.Entity:DrawModel()

	render.SuppressEngineLighting(false)
	render.SetLightingMode(0)
	cam.End3D()
end

vgui.Register("slashco_projector", PANEL, "Panel")

--[[
hook.Add("HUDPaint", "3d_camera_example", function()
	local vec = Vector(250, 0, 0)
	vec:Rotate(EyeAngles())

	cam.Start3D(LerpVector(0.5, Player(6):GetPos(), Player(6):EyePos()) - vec, nil, 45)
	Player(6):DrawModel()
	cam.End3D()
end)
--]]