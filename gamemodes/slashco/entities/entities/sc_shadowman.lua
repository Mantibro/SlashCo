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
	self:SetColor(color_transparent)
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

	GameData.ShadowManIndex = (GameData.ShadowManIndex or 0) + 1
	self.ShadowIndex = GameData.ShadowManIndex

	if GameData.LocalPlayer.BenadrylIntensity then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/benadryl/shadowman/Shadow_Voice_" .. math.random(1, 113) .. ".ogg",
			identifier = "ShadowMan" .. GameData.ShadowManIndex,
			minDistance = 100,
			maxDistance = 500,
			entity = self,
			volume = 0.25,
			fadeIn = 0,
		})
	end
end

function ENT:OnRemove()
	local entIndex = self.ShadowIndex
	timer.Simple(10, function()
		SlashCo.AudioSystem.StopSound("ShadowMan" .. entIndex, 1, entIndex)
	end)
end

function ENT:Think()
	if not GameData.LocalPlayer.BenadrylIntensity then
		return
	end

	if not self.Speed then
		self:Remove()
		return
	end

	--remove shadowboys that are way too far away
	if not self:GetPos():WithinAABox(Vector(-6000, -6000, -6000), Vector(6000, 6000, 6000)) then
		self:Remove()
		return
	end

	self:SetColor(Color(0, 0, 0, math.abs(GameData.LocalPlayer.BenadrylIntensity) * 255))

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

	if GameData.LocalPlayer:GetNW2Float("InitialBenadrylTime", 0) == 0 then
		self:Remove()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end