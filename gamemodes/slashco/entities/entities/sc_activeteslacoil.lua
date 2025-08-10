AddCSLuaFile()

ENT.Type = "anim"
ENT.ClassName 		= "sc_activeteslacoil"
ENT.PrintName		= "active teslacoil"
ENT.Author			= "RaphaelIT7"
ENT.Contact			= ""
ENT.Purpose			= "Stun."
ENT.Instructions	= ""
ENT.PingType = "TESLACOIL"

local stunTime = 15 -- How long the slashers get stunned

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "NoLight")
	self:NetworkVar("Float", 0, "ChargeBeginning")
	self:NetworkVar("Float", 1, "BrightnessTime")
	self:NetworkVar("Int", 0, "ChargeState")
end

if SERVER then
	hook.Add("SlashCo:Precache", "PrecacheBeacon", function()
		SlashCo.PrecacheSound("slashco/survivor/teslacoil_chargeup.mp3")
		SlashCo.PrecacheSound("slashco/survivor/teslacoil_stun.mp3")
		SlashCo.PrecacheModel("models/props_c17/utilityconnecter006c.mdl")
	end)

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Initialize()
		self:SetModel(SlashCoItems.TeslaCoil.Model)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) --Collide with everything but the player
		self:SetAngles(Angle(0, 0, 0))
		self:DropToFloor()
		self:SetChargeBeginning(CurTime())
		self:SetBrightnessTime(CurTime())
		self:SetNoLight(true)
		self:SetChargeState(0)
	end

	function ENT:Think()
		local startTime = self:GetChargeBeginning()
		local state = self:GetChargeState()
		if state == 0 then
			self:PlayGlobalSound("slashco/survivor/teslacoil_chargeup.mp3", 100)
			self:SetChargeState(1)
		end

		local curTime = CurTime()
		if (curTime - startTime) > 9.5 and state == 1 then
			self:SetChargeState(2)
			self:SetBrightnessTime(curTime)
			self:SetNoLight(false)
		end

		if (curTime - startTime) > 18.5 and state == 2 then
			self:SetChargeState(3)
			self:SetNoLight(true)
		end

		if (curTime - startTime) > 20 and state == 3 then
			self:SetChargeState(4)
			self:SetNoLight(false)
			self:SetBrightnessTime(curTime)
			util.ScreenShake(self:GetPos(), 30, 100, 5, 5000, true)
			SetGlobal2Bool("DisableWorldFog", true)
		end

		if (curTime - startTime) > 25.5 and state == 4 then
			self:SetChargeState(5)
			self:SetBrightnessTime(curTime + 3)
			SetGlobal2Bool("DisableWorldFog", false)
			for _, ply in ipairs(team.GetPlayers(TEAM_SLASHER)) do
				ply:PlayGlobalSound("slashco/survivor/teslacoil_stun.mp3", 100, 5)
			end
		end

		if (curTime - startTime) > 29 and state == 5 then
			self:SetChargeState(6)
			for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
				slasher:SetNW2Float("TeslaStunned", curTime + stunTime)
				slasher:SetNW2Float("LastTeslaStun", curTime)
				slasher:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 0.5, stunTime)
				slasher:SlasherFunction("OnHitByTeslaCoil")
			end
			SetGlobal2Bool("DisableWorldFog", true)
		end

		if (curTime - startTime) > 32 and state == 6 then
			self:SetChargeState(7)
			SetGlobal2Bool("DisableWorldFog", false)
		end
	end
else
	function ENT:Initialize()
		local mins, maxs = self:GetModelBounds()
		self:SetRenderBounds(mins, maxs + Vector(0, 0, 2000))
	end

	local segments = 15
	local segmentsSize = 8
	local segmentOffsets = 100
	local lightningMaterial = Material("sprites/lgtning")
	local fullWhiteCol = Color(255, 255, 255, 255)
	function ENT:Draw()
		local state = self:GetChargeState()
		local noLighting = state > 1 and state < 5 and not self:GetNW2Bool("NoLight")
		if noLighting then
			render.SuppressEngineLighting(true)
		end

		self:DrawModel()

		if noLighting then
			render.SuppressEngineLighting(false)
		end

		if state == 4 then
			local pos = self:GetPos()
			local mins, maxs = self:GetModelBounds()
			local centerPos = pos + maxs + Vector(mins[1], mins[2])
			render.SetColorMaterial()

			local mins, maxs = self:GetModelBounds()
			local centerPos = pos + maxs + Vector(mins[1], mins[2])
			render.StartBeam(segments)
				render.AddBeam(centerPos, 2, 0, fullWhiteCol)
				for k=1, segments - 1 do
					render.AddBeam(centerPos + Vector(0, 0, segmentOffsets * k), segmentsSize * k, 0, Color(255, 255, 255, (segments * 2) - (k * 2) - 2))
				end
			render.EndBeam()

			render.OverrideBlend(true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD)
			render.SetMaterial(lightningMaterial)
			local uv = math.Rand(0, 1)
			local lightningSegments = segments
			local lightningRnd = segmentsSize
			for k=1, 10 do
				render.StartBeam(lightningSegments + 1)
					render.AddBeam(centerPos, segmentsSize, uv, fullWhiteCol)
					local prevEnd = centerPos
					for k=1, lightningSegments do 
						prevEnd = LerpVector(0.5, prevEnd, centerPos + Vector(math.Rand(-lightningRnd * k, lightningRnd * k), math.Rand(-lightningRnd * k, lightningRnd * k), 0))
						prevEnd[3] = centerPos[3] + (segmentOffsets * k)
						render.AddBeam(prevEnd, segmentsSize, uv * k, fullWhiteCol)
					end
				render.EndBeam()
			end
			render.OverrideBlend(false)
		end
	end

	local outerBeamCol = Color(255, 255, 150, 64)
	local innerBeamCol = Color(255, 255, 220, 255)
	local beamTbl = {
		speed = 0,
		spread = 0,
		delay = 0,
		framerate = 2,
		material = "sprites/lgtning.vmt"
	}
	function ENT:Think()
		local state = self:GetChargeState()
		if state >= 1 and not self:GetNW2Bool("NoLight") then
			local intensity = CurTime() - self:GetNW2Float("BrightnessTime")
			if state > 5 then
				intensity = self:GetNW2Float("BrightnessTime") - CurTime()
			end

			if state == 4 then
				intensity = 100
			end

			if state == 2 or state == 4 and CurTime() > (self.NextEffect or 0) then
				local mins, maxs = self:GetModelBounds()
				self.NextEffect = CurTime() + 0.05

				local basePos = self:GetPos() + Vector(0, 0, mins[3])
				effects.BeamRingPoint(basePos + Vector(0, 0, 2), 0.75, 32, 128, 8, 0, Color(255, 255, 150, 8), beamTbl)

				for k=1, 8 do
					if k > intensity then
						continue
					end

					local rev = 8 - k
					local adding = 3
					effects.BeamRingPoint(basePos + Vector(0, 0, 4.2 * k), 0.5, (adding * rev), 32 + (adding * rev), 2, 0, Color(255, 255, 150, 16), beamTbl)
				end

				local centerPos = self:GetPos() + maxs + Vector(mins[1], mins[2])
				--if intensity > 8 then
				if state == 1 then
					local effectdata = EffectData()
					effectdata:SetOrigin(centerPos)
					effectdata:SetScale(5)
					effectdata:SetNormal(Vector(0, 0, intensity / 10))
					util.Effect("ManhackSparks", effectdata)
				end

				if state == 4 then
					local splits = 5
					for k=1, segments * splits do
						effects.BeamRingPoint(centerPos + Vector(0, 0, (segmentOffsets / splits) * k), 1, segmentsSize * k / splits, segmentsSize + (segmentsSize * k / splits * 2), 2, 0, outerBeamCol, beamTbl)
					end

					splits = 2
					for k=1, segments * splits do
						effects.BeamRingPoint(centerPos + Vector(0, 0, (segmentOffsets / splits) * k), 1, segmentsSize * k / splits / 4, segmentsSize + (segmentsSize * k / splits * 2 / 4), 2, 0, innerBeamCol, beamTbl)
					end

					local mins, maxs = self:GetModelBounds()
					local centerPos = self:GetPos() + maxs + Vector(mins[1], mins[2])
					local effectdata = EffectData()
					effectdata:SetOrigin(centerPos)
					effectdata:SetScale(1)
					effectdata:SetNormal(Vector(0, 0, intensity / 10))
					util.Effect("ElectricSpark", effectdata)
				end
			end

			if intensity < 0 then return end

			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				dlight.pos = self:GetPos()
				dlight.r = 255
				dlight.g = 255
				dlight.b = 255
				dlight.brightness = 1
				dlight.Decay = 1000
				dlight.Size = intensity * 1 --250
				dlight.DieTime = CurTime() + 0.1
			end

			if IsValid(self.Light) then
				self.Light:Remove()
				self.Light = nil
			end

			if IsValid(self.Light2) then
				self.Light2:Remove()
				self.Light2 = nil
			end
		end
	end

	local function DrawPlayerStun(ply)
		local stunTime = ply:GetNW2Float("TeslaStunned")
		if stunTime == 0 or CurTime() > stunTime then return end

		if (ply:GetNW2Float("LastTeslaStun") + 2) < CurTime() then return end

		local pos = ply:GetPos()
		local mins, maxs = ply:GetModelBounds()
		local centerPos = ply:GetPos() + Vector(0, 0, mins[3])
		render.SetColorMaterial()

		render.StartBeam(segments)
			render.AddBeam(centerPos, segmentsSize * (segments - 1), 0, fullWhiteCol)
			local segs = segments - 1
			for k=1, segs do
				render.AddBeam(centerPos + Vector(0, 0, segmentOffsets * k), segmentsSize * (segs - k), 0, Color(255, 255, 255, (segments * 2) - (k * 2) - 2))
			end
		render.EndBeam()

		render.OverrideBlend(true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD)
		render.SetMaterial(lightningMaterial)
		local uv = math.Rand(0, 1)
		local lightningSegments = segments
		local lightningRnd = segmentsSize
		for k=1, 10 do
			render.StartBeam(lightningSegments + 1)
				render.AddBeam(centerPos, segmentsSize, uv, fullWhiteCol)
				local prevEnd = centerPos
				for k=1, lightningSegments do 
					prevEnd = LerpVector(0.5, prevEnd, centerPos + Vector(math.Rand(-lightningRnd * k, lightningRnd * k), math.Rand(-lightningRnd * k, lightningRnd * k), 0))
					prevEnd[3] = centerPos[3] + (segmentOffsets * k)
					render.AddBeam(prevEnd, segmentsSize, uv * k, fullWhiteCol)
				end
			render.EndBeam()
		end
		render.OverrideBlend(false)

		local segmentsSize = segmentsSize * 7.5
		local splits = 3
		for k=1, segments * splits do
			effects.BeamRingPoint(centerPos + Vector(0, 0, (segmentOffsets / splits) * k), 1, segmentsSize, segmentsSize * 2, 2, 0, outerBeamCol, beamTbl)
		end
	end

	hook.Add("PreDrawViewModels", "TeslaCoilStun", function()
		for _, ply in ipairs(player.GetAll()) do
			DrawPlayerStun(ply)
		end
	end)
end

hook.Add("StartCommand", "TeslaCoilStun", function(ply, cmd)
	if CurTime() < ply:GetNW2Float("TeslaStunned") then
		cmd:ClearButtons()
		cmd:ClearMovement()
	end
end)