AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()
	self:SetModel("models/slashco/slashers/trollge/trollge.mdl")

	if CLIENT then return end

	self.IsInside = false
	local startPath, startPos = SlashCo.FindNextBlackoutPath(self.Inside, nil)
	if not startPath then
		print("[SlashCo] Failed to find valid path?")
	end

	startPos = startPos
	self:SetPos(startPos)

	local nextPath, nextPos = SlashCo.FindNextBlackoutPath(self.Inside, startPath)
	self.CurrentPath = nextPath
	self.CurrentGoalPos = nextPos

	SlashCo.AudioSystem.SetBackgroundMusicVolume(0)

	timer.Simple(3, function()
		if not IsValid(self) or self.Inside then return end
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/trollge/troll_blind_1.mp3",
			identifier = "TrollgeMad",
			minDistance = 2000,
			maxDistance = 5000,
			entity = self,
			volume = 1,
			fadeIn = 0,
		})
	end)

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/trollge/trollge_breathing.mp3",
		identifier = "TrollgeBreath",
		minDistance = 350,
		maxDistance = 700,
		looping = true,
		entity = self,
		volume = 1,
		fadeIn = 0,
	})

	self:SetLayerSequence(0, self:LookupSequence("walk"))
	self:ResetSequence(self:LookupSequence("walk"))
	self:ResetSequenceInfo()
	self:SetPlaybackRate(1)
	self:SetCycle(0)
end

function ENT:GoInside()
	self.Inside = true
	self:Initialize()

	for _, ply in player.Iterator() do
		ply:SetNWBool("DisplayTrollgeTransition", true)
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/trollge/trollge_stage1.ogg",
		identifier = "TrollgeStage1",
		minDistance = 550,
		maxDistance = 1100,
		looping = true,
		entity = trollge,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(7, function()
		SlashCo.AudioSystem.StopSound("TrollgeStage1", 0.5)
		for _, ply in player.Iterator() do
			ply:SetNWBool("DisplayTrollgeTransition", false)
		end
	end)
end

function ENT:Think()
	if not self.CurrentGoalPos or (self.WaitTime or 0) > CurTime() then
		return
	end

	local faceDir = self:GetForward()
	local moveDir = (self.CurrentGoalPos - self:GetPos()):GetNormalized()
	local ang = moveDir:Angle()
	self:SetAngles(Angle(0, ang.y, 0))

	local pos = self:GetPos()
	pos[1] = math.Approach(pos[1], self.CurrentGoalPos[1], 10)
	pos[2] = math.Approach(pos[2], self.CurrentGoalPos[2], 10)
	pos[3] = math.Approach(pos[3], self.CurrentGoalPos[3], 10)
	self:SetPos(pos)
		
	if self:GetPos():Distance(self.CurrentGoalPos) < 50 then
		local nextPath, nextPos, isDoor = SlashCo.FindNextBlackoutPath(self.Inside, self.CurrentPath, self.GoingBackwards)
		self.CurrentPath = nextPath
		self.CurrentGoalPos = nextPos

		if isDoor then
			local tr = util.TraceEntity({
				start = self:WorldSpaceCenter(),
				endPos = nextPos,
				filter = self,
				ignoreworld = true
			}, self)
			
			if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "func_door" then
				self.WaitTime = CurTime() + 10

				tr.Entity:Fire("Unlock")
				tr.Entity:Fire("Open")

				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/gateopen.mp3",
					identifier = "TrollgeOpenGate",
					minDistance = 550,
					maxDistance = 1100,
					entity = self,
					volume = 1,
					fadeIn = 0,
				})
			end
		end

		if not nextPath then
			if not self.Inside then
				self:GoInside()
			else
				if self.GoingBackwards then
					self:Remove()
				else
					self:DestroyPower()
				end
			end
		end
	end

	if ((self.LastStepSound or 0) + 0.5) < CurTime() then
		local idx = math.random(1, 5)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/trollge/troll_step" .. idx .. ".mp3",
			identifier = "TrollgeFootstep" .. idx,
			group = "SlasherFootstep",
			minDistance = 150,
			maxDistance = 500,
			entity = self,
			volume = 1,
			fadeIn = 0,
			unreliable = true,
		})

		self.LastStepSound = CurTime()
	end

	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:DestroyPower()
	local idx = 0
	local sparks = ents.FindInSphere(self:GetPos(), 200)
	for _, ent in ipairs(sparks) do
		if ent:GetClass() ~= "sc_effect_sparks" then continue end

		idx = idx + 1
		timer.Simple(idx, function()
			if not IsValid(self) then return end
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/trollge/trollge_swing.mp3",
				identifier = "TrollgeSmash",
				minDistance = 1000,
				maxDistance = 2000,
				entity = self,
				volume = 1,
				fadeIn = 0,
				pitch = math.random(0.8, 1.2),
			})

			timer.Simple(0.3, function()
				if not IsValid(ent) then return end
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/blackout_slam.mp3",
					identifier = "TrollgeSmash",
					minDistance = 1000,
					maxDistance = 2000,
					entity = ent,
					volume = 1,
					fadeIn = 0,
					pitch = math.random(0.7, 1.4),
				})
			end)
		end)
	end

	timer.Simple(idx + 0.4, function()
		SlashCo.EnableAlarmLights()

		if IsValid(self) then
			self:LeaveBrokenPower()
		end
	end)
end

function ENT:LeaveBrokenPower()
	self.GoingBackwards = true

	local nextPath, nextPos, isDoor = SlashCo.FindNextBlackoutPath(nil, self.CurrentPath, self.GoingBackwards)
	self.CurrentPath = nextPath
	self.CurrentGoalPos = nextPos
end