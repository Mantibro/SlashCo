AddCSLuaFile()

ENT.Type = "nextbot"
ENT.PrintName = "Hat Man"
ENT.ClassName = "sc_hatman"
ENT.Base = "base_nextbot"
ENT.PingExpiryTime = 5


function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Target")
	self:NetworkVar("Bool", 0, "LookedAt")
	self:NetworkVar("Int", 0, "Teleports")
end

local MAX_NOISE_DISTANCE = 3000
local function GetNoiseStrength(dist)
	return math.Clamp(1 - dist / MAX_NOISE_DISTANCE, 0.15, 1)
end

if SERVER then
	GameData.HatMans = GameData.HatMans or {}
end

function ENT:Initialize()
	self:SetModel("models/slashco/hatman.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetNotSolid(true)

	if SERVER then
		table.insert(GameData.HatMans, self)

		self:StartActivity(ACT_IDLE)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

		self.Path = Path("Follow")
		self.startBeingLookedAt = -1
		self:FindRandomSpot(true)

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

	local staticMaterial = Material("slashco/ui/overlays/tyler_static")
	local staticTime = 0.8
	local staticEnd = 0
	local staticStrength = 0
	hook.Add("HUDPaint", "SlashCo:HatManStatic", function()
		for _, hatMan in ipairs(ents.FindByClass("sc_hatman")) do
			if hatMan:GetTarget() ~= GameData.LocalPlayer then continue end

			local teleports = hatMan:GetTeleports()
			if hatMan.LastTeleports and hatMan.LastTeleports ~= teleports and not GetConVar("slashco_cl_disable_effects"):GetBool() then
				staticEnd = CurTime() + staticTime
				staticStrength = GetNoiseStrength(hatMan:GetPos():Distance(GameData.LocalPlayer:GetPos()))
			end

			hatMan.LastTeleports = teleports
		end

		local left = (staticEnd - CurTime()) / staticTime
		if left <= 0 then return end

		staticMaterial:SetFloat("$alpha", math.Rand(0.3, 0.5) * left * staticStrength)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(staticMaterial)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
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
			break
		end
	end

	local target = self:GetTarget()
	if IsValid(target) then
		SlashCo.AudioSystem.StopSound("HatManLookedAt", 0.1, nil, target)
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

local RecursiveFindFurthestArea2
local function RecursiveFindFurthestArea(area, targetPos, depth, maxDepth, lastMaxDistance)
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

		local childResult, childDistant = RecursiveFindFurthestArea2(area, targetPos, depth + 1, maxDepth, maxDistant)
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
RecursiveFindFurthestArea2 = RecursiveFindFurthestArea

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

local MIN_TELEPORT_DISTANCE = 500
local MAX_TELEPORT_DISTANCE = 3000
local OBJECTIVE_CHANCE = 0.5
local SPOT_COUNT = 50
local SPAWN_SAFE_DISTANCE = 1500
local LOOKED_AT_SLOWDOWN = 0.25

local function RandomOrNil(tbl)
	if #tbl > 0 then
		return tbl[math.random(#tbl)]
	end
end

local function IsAwayFromSpawns(pos, spawns)
	for _, spawn in ipairs(spawns) do
		if spawn:GetPos():DistToSqr(pos) < SPAWN_SAFE_DISTANCE ^ 2 then
			return false
		end
	end

	return true
end

local function GetHatManSpots()
	local round = SlashCo.CurRound
	if round.HatManSpots then
		return round.HatManSpots
	end

	local spawns = ents.FindByClass("info_sc_player_employee")
	table.Add(spawns, ents.FindByClass("info_sc_player_survivor"))

	local spots = {}
	local areas = navmesh.GetAllNavAreas()
	for _ = 1, SPOT_COUNT * 10 do
		if #spots >= SPOT_COUNT or #areas == 0 then break end

		local area = areas[math.random(#areas)]
		if area:IsUnderwater() then continue end

		local pos = area:GetRandomPoint()
		if IsAwayFromSpawns(pos, spawns) then
			table.insert(spots, pos)
		end
	end

	round.HatManSpots = spots
	return spots
end

local function FindSharedSpot(targetPos)
	local candidates = {}
	for _, spot in ipairs(GetHatManSpots()) do
		local dist = spot:Distance(targetPos)
		if dist > MIN_TELEPORT_DISTANCE and dist < MAX_TELEPORT_DISTANCE then
			table.insert(candidates, spot)
		end
	end

	return RandomOrNil(candidates)
end

local function FindObjectiveSpot(target)
	local targetPos = target:GetPos()
	local aim = target:GetAimVector()
	aim.z = 0
	aim:Normalize()

	local carriesFuel = target:ItemValue("IsFuel", false, true)
	local candidates = {}
	for _, ent in ipairs(ents.FindByClass(carriesFuel and "sc_generator" or "sc_gascan")) do
		if carriesFuel and ent:GetCansRemaining() <= 0 then continue end

		local dir = ent:GetPos() - targetPos
		local dist = dir:Length()
		dir.z = 0
		dir:Normalize()

		if dist > MIN_TELEPORT_DISTANCE and dist < MAX_TELEPORT_DISTANCE and dir:Dot(aim) > 0.3 then
			table.insert(candidates, ent:GetPos())
		end
	end

	return RandomOrNil(candidates)
end

local function FindFurthestSpot(targetPos)
	local area = RecursiveFindFurthestArea(navmesh.GetNearestNavArea(targetPos), targetPos, 0, math.random(2, 5))
	if not area then return end

	local pos = area:GetCenter()
	if targetPos:Distance(pos) < MIN_TELEPORT_DISTANCE then
		return -- We spawned too close!
	end

	return pos
end

function ENT:TeleportTo(pos, targetPos, silent)
	self:SetPos(pos)
	self.Path:Compute(self, targetPos)
	self.LastTeleportHeight = pos[3]
	if silent then return end

	self:SetTeleports(self:GetTeleports() + 1)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/benadryl/benadryl_low" .. math.random(1, 2) .. ".ogg",
		identifier = "HatManTeleport",
		forceStereo = true,
		entity = 0,
		sendToEntity = self:GetTarget(),
		volume = GetNoiseStrength(pos:Distance(targetPos)),
		fadeIn = 0,
		deleteWhenDone = true,
	})
end

function ENT:FindRandomSpot(silent)
	local target = self:GetTarget()
	local targetPos = target:GetPos()

	local pos = math.random() < OBJECTIVE_CHANCE and FindObjectiveSpot(target) or nil
	pos = pos or FindSharedSpot(targetPos) or FindFurthestSpot(targetPos)
	if not pos then return end

	self:TeleportTo(pos, targetPos, silent)
end

function ENT:IsOtherLookedAt(target)
	for _, hatMan in ipairs(GameData.HatMans) do
		if hatMan ~= self and hatMan:GetTarget() == target and hatMan:GetLookedAt() then
			return true
		end
	end

	return false
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

	if (self.NextTransmitUpdate or 0) < CurTime() then
		self.NextTransmitUpdate = CurTime() + 2
		for _, ply in player.Iterator() do
			self:SetPreventTransmit(ply, ply ~= target)
		end
	end

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
				target:SetLookingAtHatMan(CurTime())
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
			forceStereo = true, -- Better quality :3
			entity = 0,
			sendToEntity = target, -- only play it for this specific player
			volume = 1,
			fadeIn = 0,
		})

		SlashCo.AddFog({
			name = "HatMan",
			multiplier = 0.5,
			priority = 10,
			fogType = SlashCo.FogType.PLAYER,
			entity = target,
		})

		timer.Create("HatManSoundReset" .. target:EntIndex(), 1, 1, function()
			if not IsValid(target) then return end
			SlashCo.AudioSystem.StopSound("HatManLookedAt", 4, nil, target)
		end)

		timer.Create("HatManFogReset" .. target:EntIndex(), 6, 1, function()
			if not IsValid(target) then return end
			SlashCo.RemoveFog("HatMan", target)
		end)
	end

	if beingLookedAt and (self.startBeingLookedAt + 5) < CurTime() then
		path:Invalidate()
		self:FindRandomSpot()
		self.startBeingLookedAt = -1
		target:SetLookingAtHatMan(-1)
		self:SetLookedAt(false)
		return
	end

	if beingLookedAt then return end
	if self.startBeingLookedAt ~= -1 then
		self.startBeingLookedAt = -1
		target:SetLookingAtHatMan(-1)
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
		local moveDist = self.loco:GetDesiredSpeed() * FrameTime() * (self:IsOtherLookedAt(target) and LOOKED_AT_SLOWDOWN or 1)
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