AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sc_baseitem"
ENT.PrintName = "PorchLight"
ENT.ClassName = "sc_porchlight"

function ENT:SetupDataTables()
	self:NetworkVar("Float", "LightStartTime")
	self:NetworkVar("Int", "State")
end

function ENT:BecomeTheSun()
	self.DONTPICKUP = true
	self.Active = CurTime()
	self:Stage0()
end

function ENT:GetCoilMaterialSlot()
	if self.CoilIndex then
		return self.CoilIndex
	end

	local materials = self:GetMaterials()
	local index = -1
	for idx, material in ipairs(materials) do
		if string.find(material, "coiloff") then
			index = idx - 1
			break
		end
	end

	self.CoilIndex = index
	return index
end

local offset = Vector(0, 0, 3.7)
function ENT:GetCoilOffset()
	local worldSpace = self:WorldSpaceCenter()
	worldSpace:Add(offset)
	return worldSpace
end

function ENT:DoSpark()
	local effect = EffectData()
	effect:SetOrigin(self:GetCoilOffset())
	util.Effect("StunstickImpact", effect)

	local rng = math.random(1, 9)
	if rng == 4 then rng = 5 end -- The sound zap4 doesn't exist
	SlashCo.AudioSystem.PlaySound({
		soundPath = "ambient/energy/zap" .. rng .. ".wav",
		identifier = "PorchLightSpark" .. rng,
		minDistance = 250,
		maxDistance = 1000,
		entity = self,
		volume = 1,
	})
end

function ENT:Stage0() -- Activating
	self:SetState(0)
	self.nextSpark = CurTime() + (math.random(15, 50) / 15)
end

function ENT:Stage1() -- Becoming the SUN
	self:SetState(1)

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/porchlight_hum.mp3",
		identifier = "PorchLightHum",
		minDistance = 400,
		maxDistance = 750,
		entity = self,
		volume = 1,
		fadeIn = 0,
		looping = true,
	})

	self:SetSubMaterial(self:GetCoilMaterialSlot(), "models/slashco/porchlight/porchlight_coilon")
	self:SetLightStartTime(CurTime())
	self.Active = CurTime()
end

function ENT:CreateExplosion()
	local ent = ents.Create("env_explosion")
	if IsValid(ent) then
		ent:Spawn()
		ent:Activate()
		ent:SetPos(self:GetCoilOffset())
		ent:SetSaveValue("iMagnitude", 0)
		ent:AddSpawnFlags(1) -- 0x00000001 - SF_ENVEXPLOSION_NODAMAGE
		ent:AddSpawnFlags(16) -- 0x00000010 - SF_ENVEXPLOSION_NODECAL
		ent:AddSpawnFlags(64) -- 0x00000040 - SF_ENVEXPLOSION_NOSOUND
		ent:Fire("Explode")
		ent:Remove()
	end

	-- Time to apply knockback >:3
	local plys = {}
	local coilPos = self:GetCoilOffset()
	for _, ply in ipairs(player.GetAll()) do
		local plyPos = ply:GetPos()
		if plyPos:Distance(coilPos) < 350 then
			ply:SetVelocity((plyPos - coilPos):GetNormalized() * 750)
		end
	end
end

function ENT:Stage2() -- Breaking
	self:SetState(2)

	self.Active = CurTime()
	SlashCo.AudioSystem.StopSound("PorchLightHum", 5, self)
	self:SetSubMaterial(self:GetCoilMaterialSlot(), "models/slashco/porchlight/porchlight_coiloff")

	SlashCo.AudioSystem.PlaySound({
		soundPath = "weapons/physcannon/energy_sing_explosion2.wav",
		identifier = "PorchLightExplode",
		minDistance = 500,
		maxDistance = 1250,
		entity = self,
		volume = 0.8,
		forceStereo = true, -- This sound is sterio, we cannot play it as 3d so we need to fake it
		dynamicPan = true,
	})
	util.ScreenShake(self:GetCoilOffset(), 20, 150, 3, 750, true)
	self:Ignite(5, 50)
	self:CreateExplosion()
end

function ENT:Stage3() -- Broke
	self:SetState(3)

	self.Active = CurTime()

	SlashCo.AudioSystem.PlaySound({
		soundPath = "weapons/physcannon/energy_sing_explosion2.wav",
		identifier = "PorchLightExplode",
		minDistance = 500,
		maxDistance = 1250,
		entity = self,
		volume = 0.8,
		forceStereo = true, -- This sound is sterio, we cannot play it as 3d so we need to fake it
		dynamicPan = true,
	})
	util.ScreenShake(self:GetCoilOffset(), 20, 150, 1, 1000, true)
	self:Extinguish()
	self:CreateExplosion()

	local ent = ents.Create("sc_brokenporchlight")
	if IsValid(ent) then
		ent:Spawn()
		ent:SetMoveType(MOVETYPE_NONE)
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
	end
	self:Remove()
end

if SERVER then
	function ENT:Think()
		local activeTime = self.Active
		if not activeTime then return end

		activeTime = CurTime() - activeTime

		local stage = self:GetState()
		if stage == 0 then
			local nextSpark = self.nextSpark or 0
			if CurTime() > nextSpark then
				self:DoSpark()

				self.nextSpark = CurTime() + (math.random(math.max(15 - activeTime, 1), math.max(50 - activeTime, 1)) / 10)

				if math.random(1, 10) == 1 then
					self:Stage1()
				end
			end
			return
		end

		if stage == 1 then
			if activeTime > 1 and math.random(1, 3) == 1 then
				local lightTime = self:GetLightStartTime()
				local time = CurTime() - lightTime

				local range = math.pow(time, 1.3) -- should match client's range.
				local coilPos = self:GetCoilOffset()
				for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
					if slasher:GetPos():Distance(coilPos) > range then continue end

					local rng = math.random(1, 9)
					if rng == 4 then rng = 5 end -- The sound zap4 doesn't exist
					SlashCo.AudioSystem.PlaySound({
						soundPath = "ambient/energy/zap" .. rng .. ".wav",
						identifier = "PorchLightZapSlasher" .. rng,
						minDistance = 250,
						maxDistance = 500,
						entity = slasher,
						volume = 1,
					})

					slasher:Freeze(true)

					timer.Create(slasher:EntIndex() .. "PorchLightZap", 1, 1, function()
						if not IsValid(slasher) then return end

						slasher:Freeze(false)
					end)
				end
			end

			if activeTime > 118 then
				self:DoSpark()
			end

			if activeTime > 120 then
				if math.random(1, 10) == 1 then
					self:Stage2()
				end
			end
			return
		end

		if stage == 2 then
			local data = EffectData()
			data:SetOrigin(self:GetCoilOffset())
			util.Effect("cball_explode",data)

			if activeTime > 3 then
				self:Stage3()
			end
			return
		end
	end
else
	local porchLights = {}
	function ENT:Think()
		local state = self:GetState()
		if state != 1 then return end

		local lightTime = self:GetLightStartTime()
		local time = CurTime() - lightTime

		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.pos = self:GetCoilOffset()
			dlight.r = 255
			dlight.g = 255
			dlight.b = 240
			dlight.brightness = time / 5
			dlight.decay = 1000
			dlight.size = math.pow(time, 1.3)
			dlight.dietime = CurTime() + 1
		end

		if not porchLights[self] then
			porchLights[self] = true
		end
	end

	hook.Add("PreDrawOpaqueRenderables", "PorchLight", function()
		render.OverrideDepthEnable(true, true)
		for porchLight, _ in pairs(porchLights) do
			if not IsValid(porchLight) then
				porchLights[porchLight] = nil
				continue
			end

			local state = porchLight:GetState()
			if state != 1 then continue end

			local lightTime = porchLight:GetLightStartTime()
			local time = CurTime() - lightTime

			render.SetMaterial(Material("vgui/white"))
			for k=30, 1, -1 do
				local size = math.max(math.pow(time, 1.05) - math.pow(k, 1.7), 1)
				local sphereSize = math.Clamp(size / 5, 10, 20)
				render.DrawSphere(porchLight:GetCoilOffset(), size, sphereSize, sphereSize, Color(255, 255, 255, (time / 20 * k / 2)))
			end
		end
		render.OverrideDepthEnable(false, false)
	end)

	hook.Add("RenderScreenspaceEffects", "PorchLight", function()
		local hasProchLight = false
		local nearestDistance = 1000000000000
		for porchLight, _ in pairs(porchLights) do
			if not IsValid(porchLight) then
				porchLights[porchLight] = nil
				continue
			end

			local state = porchLight:GetState()
			if state != 1 then continue end

			local dist = GameData.LocalPlayer:GetPos():Distance(porchLight:GetPos())
			if dist < nearestDistance then
				nearestDistance = dist
			end
		end

		local passes = 8 - math.floor(nearestDistance / 200)		
		for k=1, passes do
			DrawBloom(0.65, 5, 5, 5, 2, 1, 1, 1, 1)
		end
	end)
end