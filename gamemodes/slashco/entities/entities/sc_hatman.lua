AddCSLuaFile()

ENT.Type = "nextbot"
ENT.PrintName = "Hat Man"
ENT.ClassName = "sc_hatman"
ENT.Base = "base_nextbot"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Target")
	self:NetworkVar("Bool", 0, "LookedAt")
end

if SERVER then
	GameData.HatMans = GameData.HatMans or {}
end

function ENT:Initialize()
	self:SetModel("models/slashco/shadowman.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetNotSolid(true)

	if SERVER then
		table.insert(GameData.HatMans, self)

		self:StartActivity(ACT_IDLE)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

		self.Path = Path("Follow")
		self:FindRandomSpot()

		local target = self:GetTarget()
		if IsValid(target) then
			target:GiveDocument("Hat Man", 0) -- By default, as soon as the hat man spawns the player receives the initial document.
			target.GotHatMan = true
		end

		local loco = self.loco
		loco:SetAcceleration(500)
		loco:SetDeceleration(1000)
		loco:SetAvoidAllowed(true)
		loco:SetClimbAllowed(true)
		loco:SetDeathDropHeight(100)
		loco:SetDesiredSpeed(800)
		loco:SetJumpHeight(0)
		loco:SetStepHeight(50)
	end
end

if CLIENT then
	local rotationAngle = Angle(0, 0, 0)
	function ENT:Draw()
		if self:GetTarget() ~= GameData.LocalPlayer then return end

		rotationAngle[2] = (GameData.LocalPlayer:GetPos() - self:GetPos()):GetNormalized():Angle()[2]
		self:SetAngles(rotationAngle)
		self:SetupBones() -- Required as else the model might flicker for some reason.

		self:DrawModel()
	end

	hook.Add("PreDrawHalos", "SlashCo:HatMan", function()
		local halos = {}
		for _, hatMan in ipairs(ents.FindByClass("sc_hatman")) do
			if hatMan:GetTarget() == GameData.LocalPlayer and hatMan:GetLookedAt() then
				table.insert(halos, hatMan)
			end
		end

		halo.Add(halos, color_white, 1, 1, 1, true, true)
	end)

	return
end

-- Remove all the things we don't need.
function ENT:BehaveStart()
end

function ENT:BodyUpdate()
end

function ENT:OnKilled()
end

function ENT:MoveToPos()
end

function ENT:PlaySequenceAndWait()
end

function ENT:OnTraceAttack()
end

function ENT:OnRemove()
	for idx, hatMan in ipairs(GameData.HatMans) do
		if hatMan == self then
			table.remove(GameData.HatMans, idx)
		end
	end
end

hook.Add("PostPlayerDeath", "SlashCo:RemoveHatMans", function(ply)
	if ply:Team() ~= TEAM_SPECTATOR then return end -- They survived, let their suffering continue.

	for _, hatMan in ipairs(GameData.HatMans) do
		if hatMan:GetTarget() == ply then
			hatMan:Remove()
		end
	end
end)

local RecursiveFindFuthestArea2
local function RecursiveFindFuthestArea(area, targetPos, depth, maxDepth, lastMaxDistance)
	lastMaxDistance = lastMaxDistance or 0
	depth = depth or 0

	if depth >= maxDepth or not area then
		return nil
	end

	local maxDistant = 0
	local resultArea = nil
	for _, area in ipairs(area:GetAdjacentAreas()) do
		local areaPos = area:GetCenter()
		local dist = areaPos:Distance(targetPos)
		if dist > maxDistant and math.IsNearlyEqual(areaPos[3], targetPos[3], 20) and targetPos:Distance(area:GetCenter()) > 500 then
			resultArea = area
			maxDistant = dist
		end

		local childResult, childDistant = RecursiveFindFuthestArea2(area, targetPos, depth + 1, maxDepth, maxDistant)
		if childResult then
			resultArea = childResult
			maxDistant = childDistant
		end
	end

	if lastMaxDistance > maxDistant then
		return nil
	end

	return resultArea, maxDistant
end
RecursiveFindFuthestArea2 = RecursiveFindFuthestArea

local function RequiresTeleport(path, targetPos, lastPos)
	local segments = path:GetAllSegments()
	if not segments or #segments == 1 then
		return false
	end

	if math.IsNearlyEqual(segments[#segments - 1].pos[3], targetPos[3], 150) or math.IsNearlyEqual(lastPos, path:GetEnd()[3], 20) then
		return false
	end

	return true
end

function ENT:FindRandomSpot()
	local targetPos = self:GetTarget():GetPos()
	local area = RecursiveFindFuthestArea(navmesh.GetNearestNavArea(targetPos), targetPos, 0, math.random(2, 5))
	if not area then return end

	if targetPos:Distance(area:GetCenter()) < 500 then
		return -- We spawned too close!
	end

	--area:Draw()

	self:SetPos(area:GetCenter())
	local path = self.Path
	path:Compute(self, targetPos)
	--path:Draw()
	--path:Update(self)
	self.LastTeleportHeight = self:GetPos()[3]
end

function ENT:BehaveUpdate(interval)
	if SlashCo.State ~= SlashCo.States.IN_GAME then return end -- If the round is over, don't move.

	self.loco:SetGravity(0)
	local path = self.Path
	if not IsValid(path) then
		path = Path("Follow")
		self.Path = path
	end

	local target = self:GetTarget()
	if not IsValid(target) then return end

	if path:GetAge() > 1 then
		local targetPos = target:GetPos()
		path:Compute(self, targetPos)
		--path:Draw()
		local tr = util.TraceLine({
			start = path:GetStart() + Vector(0, 0, 10),
			endpos = path:GetStart() + Vector(0, 0, -2000),
			filter = self,
			collisiongroup = COLLISION_GROUP_WORLD,
		})
		self:SetPos(tr.Hit and tr.HitPos or path:GetStart()) -- May break movement but still he somehow teleports away and this fixes it. So it'll be fine
		--path:Update(self)

		if RequiresTeleport(path, targetPos, self.LastTeleportHeight or -999999) then
			self:FindRandomSpot()
		end
	end

	--path:Update(self)

	local lookingEnts = ents.FindInCone(target:EyePos(), target:GetAimVector(), 300, math.cos(math.rad(target:GetFOV())))
	local beingLookedAt = false
	local freshlyBeingLookedAt = false
	for _, ent in ipairs(lookingEnts) do
		if ent == self then
			beingLookedAt = true

			if self.startBeingLookedAt == -1 then
				self:SetLookedAt(true)
				self.startBeingLookedAt = CurTime()
				freshlyBeingLookedAt = true
				target:SetNW2Float("LookingAtHatMan", CurTime())
			end

			break
		end
	end

	if freshlyBeingLookedAt and ((self.LastLookedAt or 0) + 5) < CurTime() then
		self.LastLookedAt = CurTime()
		self:SetLookedAt(true)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/benadryl/benadryl_high" .. math.random(1, 4) .. ".ogg",
			identifier = "HatManLookedAt",
			entity = 0, -- As Mono
			sendToEntity = target, -- only play it for this specific player
			volume = 1,
			fadeIn = 0,
		})
		target:SetNW2Float("FogMult", 0.5)

		timer.Create("HatManSoundReset", 1, 1, function()
			if not IsValid(target) then return end
			SlashCo.AudioSystem.StopSound("HatManLookedAt", 4, nil, target)
		end)

		timer.Create("HatManFogReset", 6, 1, function()
			if not IsValid(target) then return end
			target:SetNW2Float("FogMult", 1)
		end)
	end

	if beingLookedAt and (self.startBeingLookedAt + 5) < CurTime() then
		path:Invalidate()
		self:FindRandomSpot()
		self.startBeingLookedAt = -1
		target:SetNW2Float("LookingAtHatMan", -1)
		self:SetLookedAt(false)
		return
	end

	if beingLookedAt then return end
	if self.startBeingLookedAt ~= -1 then
		self.startBeingLookedAt = -1
		target:SetNW2Float("LookingAtHatMan", -1)
		self:SetLookedAt(false)
	end

	local goal = path:NextSegment()
	if goal then
		local pos = self:GetPos()
		local segments = path:GetAllSegments()
		for _, segment in ipairs(segments) do
			if segment.pos:Distance(pos) < 250 then
				local nextGoal = segment or nil
				if nextGoal then
					goal = nextGoal
					path:MoveCursorToClosestPosition(goal.pos, 1, 0)
				end
			end
		end

		--self:SetPos(goal.pos)

		local delta = goal.pos - pos
		if goal.pos:IsEqualTol(pos, 50) or goal.pos:Distance2D(pos) < 25 then
			delta = path:GetEnd() - pos
		end

		local dist = delta:Length()
		local moveDist = self.loco:GetDesiredSpeed() * FrameTime()
		local moveVec = delta:GetNormalized() * moveDist
		local newPos = pos + moveVec
		local tr = util.TraceLine({
			start = newPos + Vector(0, 0, 10),
			endpos = newPos + Vector(0, 0, -2000),
			filter = self,
			collisiongroup = COLLISION_GROUP_WORLD,
		})

		if tr.Hit and not newPos:IsEqualTol(tr.HitPos, 10) then
			newPos = tr.HitPos
		end

		self:SetPos(newPos)
	end

	if self:GetPos():Distance(target:GetPos()) < 50 then
		target:Kill() -- Too close. Too Bad.
	end

	--path:Update(self)

	self:FrameAdvance()
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end