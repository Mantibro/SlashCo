local mat = Material("cable/blue_elec")
function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.HitPos = data:GetOrigin()
	self.fDelta = 3
	self.Entity:SetRenderBoundsWS(self.StartPos, self.HitPos)
	self.BeamSize = 16
	self.DieTime = CurTime() + math.Rand(0.5,1.0)
end

function EFFECT:Think()
	return not (CurTime() > self.DieTime)
end

function EFFECT:Render()
	self.fDelta = math.Max(self.fDelta - 0.5, 0)
	self.BeamSize = math.Max(self.BeamSize - 0.05, 0)
	render.SetMaterial(mat)

	local start_pos = self.StartPos
	local end_pos = self.HitPos
	local dir = (end_pos - start_pos)
	local increment = dir:Length() / 12
	dir:Normalize()

	// set material
	render.SetMaterial(mat)

	// start the beam with 14 points
	render.StartBeam(14)

	// add start
	render.AddBeam(
		start_pos,				// Start position
		self.BeamSize,					// Width
		CurTime(),				// Texture coordinate
		Color(143, 167, 240, 255)		// Color
	)
	
	for i = 1, 12 do
		// get point
		local point = (start_pos + dir * (i * increment)) + VectorRand() * math.random(1, 8)

		// texture coords
		local tcoord = CurTime() + (1 / 12) * i

		// add point
		render.AddBeam(
			point,
			self.BeamSize,
			tcoord,
			Color(143, 167, 240, 255)
		)
	end

	// add the last point
	render.AddBeam(
		end_pos,
		self.BeamSize,
		CurTime() + 1,
		Color(143, 167, 240, 255)
	)

	// finish up the beam
	render.EndBeam()
end
