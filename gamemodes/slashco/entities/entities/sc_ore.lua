AddCSLuaFile()

local SlashCo = SlashCo
local SlashCoItems = SlashCoItems

ENT.Type = "anim"

ENT.ClassName = "sc_ore"
ENT.PrintName = "Minecraft Ore"
ENT.Author = "Xerk"
ENT.Contact = ""
ENT.Purpose = "fortnite battlepass"
ENT.Instructions = ""
ENT.IsSelectable = true
ENT.PingType = "ORE"

function ENT:Initialize()
	if SERVER then
		self.DONTPICKUP = true
		self:SetModel("models/slashco/slashers/dream/ore.mdl")
		self:SetSkin(1)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end
end

if SERVER then
	function ENT:Use(activator)
		if activator:Team() ~= TEAM_SURVIVOR then return end
		if activator:GetNWBool("SurvivorMining") then return end
		if IsValid(self.MiningPlayer) and self.MiningPlayer == TEAM_SURVIVOR then return end

		activator:SetNWBool("SurvivorMining", true)
	    activator:Freeze(true)
	    activator.MiningOre = self
	    self.MiningPlayer = activator

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/speedrunner/speedrunner_mining.mp3",
			identifier = "SurvivorMining",
			minDistance = 400,
			maxDistance = 800,
			entity = activator,
			volume = 2,
			fadeIn = 0,
		})

		timer.Create("Mining-" .. activator:UserID(), 10, 1, function()
			if not IsValid(activator) then return end

			activator:SetNWBool("SurvivorMining", false)
			activator:Freeze(false)
			activator:AddEffect("Speed", 10)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/speedrunner/speedrunner_mined.mp3",
				identifier = "SurvivorMined",
				minDistance = 400,
				maxDistance = 800,
				entity = activator,
				volume = 2,
				fadeIn = 0,
			})

			if not IsValid(self) then return end

			SlashCo.CreateItem("sc_ore", SlashCo.RandomPosLocator(), Angle(0, 0, 0))
			self:Remove()
		end)
	end

	local function CancelMining(activator)
		if not activator:GetNWBool("SurvivorMining") then return end

		timer.Remove("Mining-" .. activator:UserID())
		activator:Freeze(false)
		activator:SetNWBool("SurvivorMining", false)

		if IsValid(activator.MiningOre) then
			activator.MiningOre.MiningPlayer = nil
			activator.MiningOre = nil
		end
	end

	hook.Add("SlashCo:PlayerDeath", "SlashCo:CancelMining", CancelMining)
else
	function ENT:Draw()
	    local curTime = CurTime()
	    local tr = self:GetPos()
		local dlight = DynamicLight(963001)
		if dlight then
		    dlight.pos = tr
			dlight.r = 0
			dlight.g = 255
			dlight.b = 0
			dlight.brightness = 3
			dlight.Decay = 1000
			dlight.Size = math.abs(math.sin(curTime)) * 200
			dlight.DieTime = curTime + 0.1
		end

		self:DrawModel()
	end
end