AddCSLuaFile()

ENT.Type = "anim"
ENT.ClassName = "sc_manspidernest"
ENT.PrintName = "manspider nest"
ENT.Author = "Xerk"
ENT.Purpose	= "Slasher Ability."
ENT.PingType = "NEST"

if SERVER then
	hook.Add("SlashCo:Precache", "PrecacheNest", function()
		SlashCo.PrecacheModel("models/slashco/slashers/manspider/Nest.mdl")
		SlashCo.PrecacheSound("slashco/slasher/manspider/manspider_nest.mp3")
	end)

	function ENT:Initialize()
		self:SetModel("models/slashco/slashers/manspider/Nest.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		--self:SetCollisionGroup(COLLISION_GROUP_NONE)

		self:SetHealth(100)
		self.NestAlert = false

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/manspider/manspider_nest.mp3",
			identifier = "MansnestIdle",
			minDistance = 350 * SlashCo.MapSize,
			maxDistance = 1050 * SlashCo.MapSize,
			looping = true,
			entity = self,
			volume = 1,
		})
	end

	function ENT:Think()
		local slasher = self:GetOwner()

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if survivor:GetPos():Distance(self:GetPos()) >= 500 then
				continue
			end

			self.NestAlert = true

			if SlashCo.GetSlasherAnger(slasher) >= 100 then
				slasher.TargetPlayer = survivor
			end
		end

		if self:Health() < 1 then
			self:SetOwner(NULL)
			slasher:SetNWBool("ManspiderNestActive", false)
			self.NestAlert = false

			timer.Simple(0.1, function()
				if not IsValid(self) then return end
				self:Remove()
			end)
		end
	end

	hook.Add("SlashCo:OnAngerTick", "ManspiderNest", function(slasher)
		for _, nest in ipairs(ents.FindByClass("sc_manspidernest")) do
			if not nest.NestAlert then return end

			SlashCo.AddSlasherAnger(slasher, 0.010)
		end
	end)
end