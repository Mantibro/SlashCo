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

local minBox = Vector(-6000, -6000, -6000)
local maxBox = Vector(6000, 6000, 6000)
local ang = Angle(0, 0, 0)
local traceStartOffset = Vector(0, 0, 80)
function ENT:Think()
	if not GameData.LocalPlayer.BenadrylIntensity then
		return
	end

	if not self.Speed then
		self:Remove()
		return
	end

	--remove shadowboys that are way too far away
	local pos = self:GetPos()
	if not pos:WithinAABox(minBox, maxBox) then
		self:Remove()
		return
	end

	self:SetColor(Color(0, 0, 0, math.abs(GameData.LocalPlayer.BenadrylIntensity) * 255))

	if not IsValid(self.TargetThing) then
		local gasCans = ents.FindByClass("sc_gascan")
		self.TargetThing = gasCans[math.random(1, #gasCans)]
	else
		if not self.Speed then
			self.Speed = 1
		end

		local dir = (self.TargetThing:GetPos() - pos):GetNormalized() * self.Speed
		pos:Add(dir)
		self:SetPos(pos)
		ang[2] = pos:Angle()[2] + 90
		self:SetAngles(ang)
	
		local up = self:GetUp()
		up:Mul(-200)
		local ground = util.TraceLine({
			start = self:LocalToWorld(traceStartOffset),
			endpos = self:LocalToWorld(vector_origin):Add(up)
		})

		if ground.Fraction > 0 then
			self:SetPos(ground.HitPos)
			pos = ground.HitPos
		end

		if pos:Distance(self.TargetThing:GetPos()) < 25 then
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