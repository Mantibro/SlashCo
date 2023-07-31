AddCSLuaFile()

--local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName = "sc_shadowman"
ENT.PrintName = "shadowman"
ENT.Author = "Manti"
ENT.Contact = ""
ENT.Purpose = "shadow person"
ENT.Instructions = ""
ENT.PingType = "SLASHER"

ENT.AutomaticFrameAdvance = true

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:Initialize()
	self:SetModel("models/humans/group01/male_cheaple.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetColor(Color(0, 0, 0, 0))
	self:SetMaterial("lights/white")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	--self:SetNoDraw(true)

	timer.Simple(0.1, function()
		if not IsValid(self) then
			return
		end

		self:ResetSequence("walk_all")
		self:SetPoseParameter("move_x", 1)
		self:SetPlaybackRate(1)
	end)

	self.Speed = 0.5 + math.random() * 1.5
	self.Sound = math.random(1, 2)

	if LocalPlayer().BenadrylIntensity then
		self:EmitSound("slashco/benadryl_shadow" .. self.Sound .. ".mp3", 60 + math.random(1, 80), 100,
				(math.random() * 2) * LocalPlayer().BenadrylIntensity)
	end
end

function ENT:Think()
	if not LocalPlayer().BenadrylIntensity then
		return
	end

	if not self.Speed or not self.Sound then
		self:Remove()
		return
	end

	--remove shadowboys that are way too far away
	if not self:GetPos():WithinAABox(Vector(-6000, -6000, -6000), Vector(6000, 6000, 6000)) then
		self:Remove()
		return
	end

	self:SetColor(Color(0, 0, 0, math.abs(LocalPlayer().BenadrylIntensity) * 255))

	if not IsValid(self.TargetThing) then
		self.TargetThing = ents.FindByClass("sc_gascan")[math.random(1, #ents.FindByClass("sc_gascan"))]
	else
		if not self.Speed then
			self.Speed = 1
		end

		local dir = (self.TargetThing:GetPos() - self:GetPos()):GetNormalized() * self.Speed
		self:SetPos(self:GetPos() + dir)
		self:SetAngles(Angle(0, (self:GetPos() + dir):Angle()[2] + 90, 0))

		local ground = util.TraceLine({
			start = self:LocalToWorld(Vector(0, 0, 80)),
			endpos = self:LocalToWorld(Vector(0, 0, 0)) + self:GetUp() * -200
		})

		if ground.Fraction > 0 then
			self:SetPos(ground.HitPos)
		end

		if self:GetPos():Distance(self.TargetThing:GetPos()) < 25 then
			self:StopSound("slashco/benadryl_shadow" .. self.Sound .. ".mp3")
			self:Remove()
		end
	end

	if not self.Cycle then
		self.Cycle = CurTime()
	end

	if CurTime() - self.Cycle > 0.5 then
		self:SetCycle(math.random())
		self.Cycle = CurTime()
	end

	if not LocalPlayer():GetNWBool("SurvivorBenadryl") then
		self:StopSound("slashco/benadryl_shadow" .. self.Sound .. ".mp3")
		self:Remove()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end