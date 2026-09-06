AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"
ENT.ClassName = "sc_americanbottle"
ENT.PrintName = "AmericanBottle"
ENT.Author = "Xerk"
ENT.Contact = ""
ENT.Purpose = "Slasher Ability!"
ENT.Instructions = ""
ENT.IsSelectable = true
ENT.PingType = "BOTTLE"

if SERVER then
	hook.Add("SlashCo:Precache", "PrecacheBottle", function()
		SlashCo.PrecacheSound("physics/glass/glass_largesheet_break1.wav")
		SlashCo.PrecacheSound("physics/glass/glass_largesheet_break2.wav")
		SlashCo.PrecacheSound("physics/glass/glass_largesheet_break3.wav")
		SlashCo.PrecacheModel("models/slashco/items/Bottle.mdl")
	end)

	function ENT:Initialize()
		self:SetModel("models/slashco/items/Bottle.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		self.BottleActive = false
	end

	function ENT:SetBottleVelocity(velocity)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(10)
			phys:SetVelocity(velocity)
			phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
		end
	end

	function ENT:BreakBottle()
		if self.BottleActive then return end

		self.BottleActive = true

		self:SetModel("models/alyx_emptool_prop.mdl")
		self:SetMaterial("models/effects/vol_light001")
		self:DrawShadow(false)

		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetCustomCollisionCheck(true)
		self:CollisionRulesChanged()

		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "physics/glass/glass_largesheet_break" .. idx .. ".wav",
			identifier = "AmericanpoBottle" .. idx,
			minDistance = 200,
			maxDistance = 800,
			entity = self,
			volume = 1,
			fadeIn = 0,
		})

		local pos = self:GetPos()
		for _, ply in ipairs(SlashCo.FindPlayersInRange(pos, 300, nil, self)) do
			local team = ply:Team()
			if team == TEAM_SURVIVOR then
				ply:SetNWBool("SurvivorFueled", true)
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/americanpo/negative_effect.mp3",
					identifier = "SurvivorFueled",
					minDistance = 200,
					maxDistance = 500,
					entity = ply,
					volume = 1,
					fadeIn = 0,
				})

				timer.Simple(8, function()
					if not IsValid(ply) then return end

					ply:SetNWBool("SurvivorFueled", false)

					if not IsValid(self) then return end

					self:Remove()
				end)
			end
		end
	end

	function ENT:PhysicsCollide(data)
		self:BreakBottle()

		if IsValid(data.HitEntity) and (data.HitEntity:IsPlayer() and data.HitEntity:Team() == TEAM_SURVIVOR) then
			self:BreakBottle()
		end
	end
end

hook.Add("RenderScreenspaceEffects", "SlashCo:AmericanBottle", function()
	if GameData.LocalPlayer:GetNWBool("SurvivorFueled") then
		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0.01,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 0,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
	end
end)