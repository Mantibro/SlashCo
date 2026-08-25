local SLASHER = {}

SLASHER.Name = "Umbra Beast"
SLASHER.Aliases = {
	"Island Monster",
	"The Experiment",
	"'Stan'",
	"Test Subject A-█",
	"The Beast",
	"The Starved",
	"The Monster",
	"?̷̨̤̮̭͔̘͒̅͗̐?̴̝͙͈͝?̵̭͉̪̪͂̂͋͛̉͝",
	"The Black Beast with Red Eyes"
}
SLASHER.Class = SlashCo.SlasherClass.Umbra
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/stan/stan.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 2
SLASHER.StalkSpeed = 200
SLASHER.ProwlSpeed = 250
SLASHER.ChaseSpeed = 350
SLASHER.ChaseSpeedFlashed = 300
SLASHER.Perception = 0.5
SLASHER.Eyesight = 6
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 1400
SLASHER.ChaseRadius = 0.82
SLASHER.ChaseDuration = 999.0
SLASHER.ChaseCooldown = 0.5
SLASHER.JumpscareDuration = 2
SLASHER.AgitationIncrease = 0.10
SLASHER.AgitationDecrease = -0.08
SLASHER.ChaseMusic = "slashco/slasher/umbrabeast/stan_chase.ogg"
SLASHER.KillSound = "slashco/slasher/umbrabeast/stan_jumpscare.ogg"
SLASHER.Description = "UmbraBeast_desc"
SLASHER.ProTip = "UmbraBeast_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★★★☆"
SLASHER.DiffRating = "★★★★☆"

local UMBRA_FIRST_STAGE = 1
local UMBRA_SECOND_STAGE = 2
local UMBRA_THIRD_STAGE = 3
local UMBRA_FINAL_STAGE = 4
local UMBRA_STATE_PROWL = 0
local UMBRA_STATE_STALK = 1
local UMBRA_STATE_CHASE = 2
local UMBRA_TERRITORY_RADIUS = 2000 * SlashCo.GetMapSize() / 2 -- Arguably the most important thing here, the balancing on this is very delicate.
local NextTerritorySound = {}
local TerritoryCheckDelay = 0.5
local PaintedTargets = {}
local PaintedItems = {}
local StanPaintableClasses = {
	["sc_gascan"] = true,
	["sc_battery"] = true,
	["sc_custard"] = true,
	["sc_baby"] = true,
	["sc_postalammo"] = true,
}

local function StopUmbraBeastMauling(slasher)
	if not IsValid(slasher) then return end

	-- We need to give the slasher endlag so he can't just instantly M1 after you punish him.
	slasher.SlashCooldown = 3

	-- Naturally, stop the mauling.
	slasher.LeapHit = false

	-- Stop animating the mauling.
	slasher:SetNWBool("UmbraBeastAnimateMauling", false)

	-- Play a shove sound as extra feedback for the survivor(s).
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/umbrabeast/stan_leap_shoved.ogg",
		identifier = "StanShoved",
		minDistance = 600,
		maxDistance = 800,
		entity = slasher,
		volume = 1.1,
		fadeIn = 0,
	})

	-- Stop slasher's movement.
	slasher:SetVelocity(-slasher:GetVelocity())

    -- The code that's ACTUALLY responsible for stopping the mauling.
    timer.Remove("UmbraBeastPounceDamage")	-- Stops the timer that makes the survivor take damage.
    SlashCo.AudioSystem.StopSound("StanMauling", 0.1, slasher)	-- Stops the looping sound.

	for _, survivor in ipairs(player.GetAll()) do -- Self Explanatory I think...
    	if not survivor:GetNWBool("SurvivorPounced") then return end

		survivor:SetNWBool("SurvivorPounced", false) -- Clear the pounced state off of the survivor.
		survivor:Freeze(false)	-- Unfreeze the survivor who was pounced.

		local pushDir = (survivor:GetPos() - slasher:GetPos()):GetNormalized()

		survivor:SetVelocity(pushDir * 250 + Vector(0, 0, 100)) -- Push the survivor a lil bit away from the slasher.
	end

	-- Unfreeze the slasher after a lil bit, don't leave him softlocked...
	timer.Simple(1.5, function()
		slasher:Freeze(false)
	end)
end

-- Holy fucking mother of networking
if SERVER then
	util.AddNetworkString("UmbraBeastTerritorySound")
	util.AddNetworkString("UmbraBeastPaintTarget")
	util.AddNetworkString("UmbraBeastShove")

	-- I deadass have no idea how to optimize this better for the time being, I tried to delay the think so it doesn't happen every frame.
	hook.Add("Think", "UmbraBeastTerritoryCheck", function()
		local gametime = CurTime()
		if gametime < TerritoryCheckDelay then return end
		TerritoryCheckDelay = gametime + 0.5

		for _, slasher in ipairs(player.GetAll()) do
			if slasher:GetNWString("Slasher") ~= "UmbraBeast" then continue end
			if not slasher:GetNWBool("UmbraBeastMarkTerritory") then
				PaintedItems[slasher] = nil
				continue
			end

			local territoryPos = slasher:GetNWVector("UmbraBeastTerritoryPos") -- Position of the Territory
			local radius = slasher:GetNWInt("UmbraBeastTerritoryRadius", UMBRA_TERRITORY_RADIUS) -- Radius of the Territory

			local radiusSqr = radius * radius

			-- Territory detection for Survivors
			for _, survivor in ipairs(player.GetAll()) do
				if survivor:Team() ~= TEAM_SURVIVOR then continue end

				local inside = survivor:GetPos():DistToSqr(territoryPos) <= radiusSqr

				net.Start("UmbraBeastPaintTarget")
					net.WriteEntity(survivor)
					net.WriteBool(inside)
				net.Send(slasher)

				-- Play a "schpooky" sound from Isle with random intervals to let people know that they're in the territory. And to also spook them.
				if inside then
					if not NextTerritorySound[survivor] then
						NextTerritorySound[survivor] = CurTime() + math.Rand(45, 70)
					end

					if CurTime() >= NextTerritorySound[survivor] then
						net.Start("UmbraBeastTerritorySound")
						net.Send(survivor)

						NextTerritorySound[survivor] = CurTime() + math.Rand(45, 70)
					end
				else
					NextTerritorySound[survivor] = nil
				end
			end


			-- Territory detection for items
			PaintedItems[slasher] = PaintedItems[slasher] or {}

			local ItemsInside = {}

			for _, ent in ipairs(ents.FindInSphere(territoryPos, radius)) do
				if not IsValid(ent) then continue end
				if not StanPaintableClasses[ent:GetClass()] then continue end

				ItemsInside[ent] = true

				-- Only show the items to slasher if they're in the radius of the territory.
				if not PaintedItems[slasher][ent] then
					PaintedItems[slasher][ent] = true

					net.Start("UmbraBeastPaintTarget")
						net.WriteEntity(ent)
						net.WriteBool(true)
					net.Send(slasher)
				end
			end


			-- Check if items left the territory.
			for ent in pairs(PaintedItems[slasher]) do
				if not ItemsInside[ent] then
					PaintedItems[slasher][ent] = nil

					if IsValid(ent) then
						net.Start("UmbraBeastPaintTarget")
							net.WriteEntity(ent)
							net.WriteBool(false)
						net.Send(slasher)
					end
				end
			end
		end
	end)
	-- Let players cancel the mauling by pressing EEEEEE.
		hook.Add("KeyPress", "UmbraBeastShove", function(ply, key)
		if key ~= IN_USE then return end
		if not IsValid(ply) then return end
		if ply:Team() ~= TEAM_SURVIVOR then return end
	
		local startPos = ply:GetShootPos()
		local endPos = startPos + ply:GetAimVector() * 100
	
		-- WE LOVE TRACES!!! YEAH!!!
		local tr = util.TraceHull({
			start = startPos,
			endpos = endPos,
			mins = Vector(-20, -20, -20),
			maxs = Vector(20, 20, 20),
			filter = ply
		})
	
		local slasher = tr.Entity
	
		if not IsValid(slasher) then return end
		if not slasher:IsPlayer() then return end
		if slasher:Team() ~= TEAM_SLASHER then return end
		if not slasher.LeapHit then return end

		if slasher.LeapHit then
			StopUmbraBeastMauling(slasher)
		end
	
		-- Freeze the slasher for a bit.
		slasher:Freeze(true)
		slasher:SetNWBool("UmbraBeastShoved", true)
	
		-- Push the slasher away.
		local pushDir = (slasher:GetPos() - ply:GetPos()):GetNormalized()
	
		slasher:SetVelocity(pushDir * 50 + Vector(0, 0, 100))
	
		-- Time until slasher gets unfrozen.
		timer.Simple(1.5, function()
			if not IsValid(slasher) then return end
		
			slasher:Freeze(false)
			slasher:SetNWBool("UmbraBeastShoved", false)
		end)
	end)
end

if CLIENT then

	-- Add scary eyes, they are very important, as they are very scary.
	game.AddParticles("particles/class_fx.pcf")

	-- We have to put the full soundpath, including "sound", since we're playing these sounds to the client through the game itself, not through an entity.
	net.Receive("UmbraBeastTerritorySound", function()
		local IsleSounds = {
			"sound/slashco/slasher/umbrabeast/stan_territory_warn1.ogg",
			"sound/slashco/slasher/umbrabeast/stan_territory_warn2.ogg",
			"sound/slashco/slasher/umbrabeast/stan_territory_warn3.ogg",
			"sound/slashco/slasher/umbrabeast/stan_territory_warn4.ogg",
		}

		local StanSoundPath = table.Random(IsleSounds)

		sound.PlayFile(StanSoundPath, "noplay", function(channel)
		if IsValid(channel) then
				channel:SetVolume(0.5)
				channel:Play()
			end
		end)
	end)

	net.Receive("UmbraBeastPaintTarget", function()
		local survivor = net.ReadEntity()
		local inside = net.ReadBool()

		if not IsValid(survivor) then return end

		if inside then
			PaintedTargets[survivor] = true
		else
			PaintedTargets[survivor] = nil
		end
	end)

	local mat = Material("lights/white")

	hook.Add("PostDrawOpaqueRenderables", "UmbraBeastPaintTargets", function()
		local slasher = GameData.LocalPlayer
			if not IsValid(slasher) then return end
			if slasher:Team() ~= TEAM_SLASHER then return end

		for ply, _ in pairs(PaintedTargets) do
			if not IsValid(ply) then
				PaintedTargets[ply] = nil
				continue
			end

			if not IsValid(slasher) then return end

			render.MaterialOverride(mat)
			render.SetColorModulation(1, 0, 0)

			render.SetBlend(1)

			cam.IgnoreZ(true)
			ply:DrawModel()
			cam.IgnoreZ(false)

			render.SetColorModulation(1, 1, 1)
			render.MaterialOverride()
		end
	end)
end

local function IsFlashlightOnSlasher(slasher)
	for _, ply in ipairs(player.GetAll()) do
		if not IsValid(ply) or not ply:Alive() then return end
		if not ply:GetNW2Bool("DynamicFlashlight", false) then continue end

		local startPos = ply:EyePos()
		local targetPos = slasher:WorldSpaceCenter()

		local direction = ply:GetAimVector()
		local toSlasher = targetPos - startPos
		local distance = toSlasher:Length()

		-- Give it a range limit.
		if distance > 1000 then continue end

		toSlasher:Normalize()

		local dot = direction:Dot(toSlasher)

		-- Wider flashlight cone
		if dot < 0.90 then continue end

		-- See if anything hides the player's flashlight.
		local trace = util.TraceLine({
			start = startPos,
			endpos = targetPos,
			filter = {ply, slasher},
			mask = MASK_SOLID
		})

		if trace.Hit then continue end


		return true, ply
	end

	return false, nil
end

local function StartFlashlightDetection(slasher)
	if not IsValid(slasher) then return end

	local FlashlightAntiSpam = "UmbraBeastFlashlightDetection_" .. slasher:EntIndex()

	-- Prevent duplicate timers
	timer.Remove(FlashlightAntiSpam)

	timer.Create(FlashlightAntiSpam, 0.1, 0, function()
		if not IsValid(slasher) then
			timer.Remove(FlashlightAntiSpam)
			return
		end

		local beingFlashed, flasher = IsFlashlightOnSlasher(slasher)

		slasher:SetNWBool("BeingFlashed", beingFlashed)
	end)
end

local function StanBreathing(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/umbrabeast/stan_breathe_loop.ogg",
		identifier = "StanBreath",
		minDistance = 400,
		maxDistance = 600,
		looping = true,
		entity = slasher,
		volume = 0.8,
		fadeIn = 0,
	})
end

local function StopBreathing(slasher)
	SlashCo.AudioSystem.StopSound("StanBreath", 0.1, slasher)
end

function SLASHER.OnSpawn(slasher)
	StanBreathing(slasher)

	slasher.SlashCooldown = 0
	slasher.ChargeLeapCooldown = 0
	slasher.LeapCooldown = 0
	slasher.ForwardCharge = 0
	slasher.LungeDuration = 0
	slasher.TimeCrouching = 0
	StartFlashlightDetection(slasher)
	slasher:SetNWBool("UmbraBeastEnrage", false)
	slasher:SetNWBool("CanKill", false)
	slasher:SetNWBool("CanChase", false)
end

-- We create these only once since we use them every tick.
local stalking_viewoffset = Vector(0, 0, 20)
local standing_viewoffset = Vector(0, 0, 60)
function SLASHER.OnTickBehaviour(slasher)
	local stage = slasher.UmbraBeastStage --Stage
	local SlashCooldown = slasher.SlashCooldown or 0 --Main Slash Cooldown
	local ChargeLeapCooldown = slasher.ChargeLeapCooldown or 0 --Main Slash Cooldown
	local LeapCooldown = slasher.LeapCooldown or 0 --Main Leap Cooldown
	local UmbraBeastGesture = slasher.UmbraBeastGesture or nil -- Used for animator.

	local eyesight_final = SLASHER.Eyesight
	local perception_final = SLASHER.Perception

	if SlashCooldown > 0 then
		slasher.SlashCooldown = SlashCooldown - FrameTime()
	end

	if LeapCooldown > 0 then
		slasher.LeapCooldown = LeapCooldown - FrameTime()
	end

	if ChargeLeapCooldown > 0 then
		slasher.ChargeLeapCooldown = ChargeLeapCooldown - FrameTime()
	end

	if not SlashCo.CurRound.EscapeHelicopterSummoned then
		-- Check for game progress for Stage 1
		if SlashCo.CurRound.GameProgress < 3 and slasher:GetNWInt("UmbraStage") ~= UMBRA_FIRST_STAGE then
			stage = UMBRA_FIRST_STAGE
			SlashCo.AddFog({
				name = "UmbraStageOne",
				multiplier = 0.75,
				priority = 10,
				fogType = SlashCo.FogType.TEAM,
				team = TEAM_SURVIVOR,
			})
		end
		-- Check for game progress for Stage 2
		if SlashCo.CurRound.GameProgress >= 3 and SlashCo.CurRound.GameProgress < 6 and slasher:GetNWInt("UmbraStage") ~= UMBRA_SECOND_STAGE then
			stage = UMBRA_SECOND_STAGE
			SlashCo.AddFog({
				name = "UmbraStageTwo",
				multiplier = 0.5,
				priority = 10,
				fogType = SlashCo.FogType.TEAM,
				team = TEAM_SURVIVOR,
			})
		end
		-- Check for game progress for Stage 3
		if SlashCo.CurRound.GameProgress >= 6 and SlashCo.CurRound.GameProgress < 10 and slasher:GetNWInt("UmbraStage") ~= UMBRA_THIRD_STAGE then
			stage = UMBRA_THIRD_STAGE
			SlashCo.AddFog({
				name = "UmbraStageThree",
				multiplier = 0.3,
				priority = 10,
				fogType = SlashCo.FogType.TEAM,
				team = TEAM_SURVIVOR,
			})
		end
	end

	if slasher:GetNWBool("UmbraBeastStalk") then
		StopBreathing(slasher)
		if SlashCo.GetSlasherAnger(slasher) >= 100 then
			slasher:SetNWBool("CanChase", true)
		else
			slasher:SetNWBool("CanChase", false)
		end

		if SlashCo.GetSlasherAnger(slasher) == 0 then
			SlashCo.StopChase(slasher)
		end

		slasher:SetSlowWalkSpeed(SLASHER.StalkSpeed)
		slasher:SetWalkSpeed(SLASHER.StalkSpeed)
		slasher:SetRunSpeed(SLASHER.StalkSpeed)

		if slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("BeingFlashed") then
			slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed)
			slasher:SetWalkSpeed(SLASHER.ChaseSpeed)
			slasher:SetRunSpeed(SLASHER.ChaseSpeed)
		elseif slasher:GetNWBool("InSlasherChaseMode") and slasher:GetNWBool("BeingFlashed") then
			slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeedFlashed)
			slasher:SetWalkSpeed(SLASHER.ChaseSpeedFlashed)
			slasher:SetRunSpeed(SLASHER.ChaseSpeedFlashed)
		else
			slasher:SetSlowWalkSpeed(SLASHER.StalkSpeed)
			slasher:SetWalkSpeed(SLASHER.StalkSpeed)
			slasher:SetRunSpeed(SLASHER.StalkSpeed)
		end

		if slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("UmbraBeastAlreadyEnraged") then
			slasher:Freeze(true)
			slasher:SetNWBool("UmbraBeastEnrage", true)
			slasher:SetNWBool("UmbraBeastAlreadyEnraged", true)

			timer.Simple(0.1, function()
				slasher:SetNWBool("UmbraBeastEnrage", false)
			end)

			timer.Simple(1.5, function()
				slasher:Freeze(false)
			end)
		end

		if not slasher:GetNWBool("InSlasherChaseMode") then
			slasher:SetNWBool("UmbraBeastAlreadyEnraged", false)
		end

		slasher:SetViewOffset(stalking_viewoffset)
		slasher:SetCurrentViewOffset(stalking_viewoffset)
	else
		slasher:SetNWBool("CanChase", false)
		slasher:SetViewOffset(standing_viewoffset)
		slasher:SetCurrentViewOffset(standing_viewoffset)
		if not slasher:GetNWBool("InSlasherChaseMode") then
			slasher:SetNWBool("UmbraBeastAlreadyEnraged", false)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		else
			slasher:SetNWBool("UmbraBeastAlreadyEnraged", false)
			slasher:SetSlowWalkSpeed(SLASHER.StalkSpeed)
			slasher:SetWalkSpeed(SLASHER.StalkSpeed)
			slasher:SetRunSpeed(SLASHER.StalkSpeed)
		end
	end

	if SlashCooldown > 0 and slasher:GetNWBool("UmbraBeastCanSlash") then
		slasher:SetNWBool("UmbraBeastCanSlash", false)
	end

	if SlashCooldown <= 0 and not slasher:GetNWBool("UmbraBeastCanSlash") then
		slasher:SetNWBool("UmbraBeastCanSlash", true)
	end

	if ChargeLeapCooldown > 0 and slasher:GetNWBool("UmbraBeastCanChargeLeap") then
		slasher:SetNWBool("UmbraBeastCanChargeLeap", false)
	end

	if ChargeLeapCooldown <= 0 and not slasher:GetNWBool("UmbraBeastCanChargeLeap") then
		slasher:SetNWBool("UmbraBeastCanChargeLeap", true)
	end

	local radius = 500 -- In Hammer Units, naturally

	for _, ply in ipairs(player.GetAll()) do
		if ply ~= slasher and IsValid(ply) and ply:Team() == TEAM_SURVIVOR and ply:IsPlayer() and ply:GetPos():DistToSqr(slasher:GetPos()) <= radius * radius and slasher:GetNWBool("UmbraBeastStalk") and not slasher:GetNWBool("InSlasherChaseMode") then
			SlashCo.AddSlasherAnger(slasher, SLASHER.AgitationIncrease)
		elseif ply:GetPos():DistToSqr(slasher:GetPos()) >= radius * radius or not slasher:GetNWBool("UmbraBeastStalk") or slasher:GetNWBool("InSlasherChaseMode") then
			SlashCo.AddSlasherAnger(slasher, SLASHER.AgitationDecrease)
		end
	end

	local agitation = SlashCo.GetSlasherAnger(slasher)
	if slasher:GetNWInt("UmbraBeastAgitation") ~= math.floor(agitation) then
		slasher:SetNWInt("UmbraBeastAgitation", math.floor(agitation))
	end

	if stage == UMBRA_FIRST_STAGE then
		slasher:SetNWInt("UmbraStage", UMBRA_FIRST_STAGE)
	elseif stage == UMBRA_SECOND_STAGE then
		slasher:SetNWInt("UmbraStage", UMBRA_SECOND_STAGE)
	elseif stage == UMBRA_THIRD_STAGE then
		slasher:SetNWInt("UmbraStage", UMBRA_THIRD_STAGE)
	elseif stage == UMBRA_FINAL_STAGE then
		slasher:SetNWInt("UmbraStage", UMBRA_FINAL_STAGE)

	end

	if slasher:Crouching() then
		slasher:SetNWBool("UmbraBeastCrouching", true)
	else
		slasher:SetNWBool("UmbraBeastCrouching", false)
	end

	slasher:SetEyeSight(eyesight_final)
	slasher:SetPerception(perception_final)

	-- HOW DO YOU GET RID OF THIS IN A BETTER WAY, SOMEBODY HELP MEEEE
	SlashCo.AudioSystem.DisableBackgroundMusic()
	SlashCo.AudioSystem.SetBackgroundMusicVolume(0)

end

function SLASHER.OnPrimaryFire(slasher, target)

	if slasher:GetNWBool("UmbraBeastSlashing") then return end
	if slasher:GetNWBool("UmbraBeastStunned") then return end
	if slasher.LeapHit then return end
	if slasher.SlashCooldown > 0 then return end

	slasher:SetNWBool("UmbraBeastSlashing", true)
	slasher.SlashCooldown = 3

	slasher:SlasherHudFunc("ShakeControl", "LMB")

	local function SlashFinish()
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/umbrabeast/stan_swing.ogg",
			identifier = "StanSwing",
			minDistance = 600,
			maxDistance = 800,
			entity = slasher,
			volume = 1.5,
			fadeIn = 0,
		})

		slasher:LagCompensation(true)
		local tr = util.TraceHull({
			start = slasher:EyePos(),
			endpos = slasher:LocalToWorld(Vector(55, 0, 0)),
			maxs = Vector(60, 60, 60),
			mins = Vector(-60, -60, -60),
			filter = slasher,
			ignoreworld = true,
		})
		slasher:LagCompensation(false)

		local target = tr.Entity
		local damage = 54

		if target:IsValid() and (not target:IsPlayer() or target:Team() == TEAM_SURVIVOR) then
			local dmg = DamageInfo()
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(slasher)
			dmg:SetInflictor(slasher)
			dmg:SetDamage(damage)
			dmg:SetDamageForce(Vector(1, 1, 1))
			dmg:SetDamagePosition(tr.HitPos)
			target:TakeDamageInfo(dmg)
		end

		SlashCo.BustDoor(slasher, target, 20000)

		slasher:SetNWBool("UmbraBeastSlashing", false)

		if target:IsPlayer() then
			if target:Team() ~= TEAM_SURVIVOR then return end

			local isSeen = false
		
			local trace = target:GetEyeTrace()
			local find = ents.FindInCone(target:GetPos(), trace.Normal, 3000, 0.5)
			local slashertarget
		
			-- Yo thanks Watcher, you're a real one bro
			if trace.Entity == slasher then
				slashertarget = slasher
				goto FOUND
			end
		
			do
				for i = 1, #find do
					if find[i] == slasher then
						slashertarget = find[i]
						break
					end
				end
			
				if IsValid(slashertarget) then
					local tr = util.TraceLine({
						start = target:EyePos(),
						endpos = slashertarget:GetPos() + Vector(0, 0, 50),
						filter = target
					})
				
					if tr.Entity ~= slashertarget then
						slashertarget = nil
					end
				end
			end
			:: FOUND ::
		if slasher:GetNWBool("UmbraBeastStalk") then
			if IsValid(slashertarget) and slashertarget == slasher then
				--print("SEEN")
				isSeen = true
			else
				--print("NOT SEEN")
				target:AddEffect("Dazed",SlashCo.GetConsumableEffectDuration(target, 10))
			end
		end
			if SlashCo.GetSlasherAnger(slasher) >= 70 then
				slasher:SetNWBool("CanKill", true)
				SlashCo.Jumpscare(slasher, target)
				target:SetNWBool("SurvivorBeingJumpscared", true)
			else
				slasher:SetNWBool("CanKill", false)
			end

			local vPoint = target:GetPos() + Vector(0, 0, 50)
			local bloodfx = EffectData()
			bloodfx:SetOrigin(vPoint)
			util.Effect("BloodImpact", bloodfx)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/trollge/trollge_hit.mp3",
				identifier = "SurvivorHitStan",
				minDistance = 600,
				maxDistance = 800,
				entity = target,
				volume = 1,
				fadeIn = 0,
			})
		end
	end

	timer.Create(slasher:EntIndex() .. "_UmbraBeastSlash", 0.05, 1, SlashFinish)
end

hook.Add("Think", "StanLeapCharge", function()
	for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		if not IsValid(slasher) then continue end
		if slasher:GetVelocity():Length() > 100 then return end
		if slasher:GetNWBool("UmbraBeastStalk") then return end
		if slasher:GetNWString("Slasher") ~= "UmbraBeast" then return end

		if slasher:Crouching() and (slasher.LeapCooldown or 10) <= 0 then
			if not slasher.LeapChargeStart then
				slasher.LeapChargeStart = CurTime()
				slasher:SetNWBool("UmbraBeastCanLeap", false)

				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/umbrabeast/stan_leap_charge.ogg",
					identifier = "StanLeapCharge",
					minDistance = 600,
					maxDistance = 800,
					entity = slasher,
					volume = 1.0,
					fadeIn = 0,
				})
			elseif CurTime() - slasher.LeapChargeStart >= 2 then
				-- 2 seconds passed? You can leap!
				slasher:SetNWBool("UmbraBeastCanLeap", true)
			end
		else
			-- The slasher isn't crouching or the leap is on cooldown.
			slasher.LeapChargeStart = nil
		end
	end
end)

hook.Add("Think", "UmbraBeastPounce", function()
	for _, slasher in ipairs(player.GetAll()) do
		if not slasher.Leaping then continue end
		if not IsValid(slasher) then continue end
		if slasher:GetNWString("Slasher") ~= "UmbraBeast" then return end

		slasher:SetNWBool("UmbraBeastAnimateLeap", true)

		-- Pounce timed out OR you touched the ground, no valid pounce for you.
		if CurTime() >= slasher.LeapEndTime or slasher:IsOnGround() then
			slasher.Leaping = false
			slasher.LeapHit = false
			slasher:SetNWBool("UmbraBeastAnimateLeap", false)
			continue
		end

		for _, survivor in ipairs(ents.FindInSphere(slasher:GetPos(), 75)) do
			if not IsValid(survivor) then continue end
			if not survivor:IsPlayer() then continue end
			if survivor:Team() ~= TEAM_SURVIVOR then continue end
			if survivor:GetNWBool("SurvivorPounced") then continue end

			-- Pounced a guy.
			slasher:SetNWBool("UmbraBeastAnimateLeap", false)
			slasher.LeapHit = true
			slasher.Leaping = false

			-- Might have to tinker around with these values, the goal is to have the slasher face the survivor when mauling them.
			local targetPos = survivor:WorldSpaceCenter()
			local ang = (targetPos - slasher:GetPos()):Angle()
			ang.y = ang.y - 10

			slasher:SetEyeAngles(ang)
			slasher:SetPos(survivor:GetPos() + survivor:GetForward() * 35 + Vector(0, 0, 20))

			-- Stop the slasher from moving once again.
			slasher:SetVelocity(-slasher:GetVelocity())

			survivor:SetNWBool("SurvivorPounced", true)
			survivor:Freeze(true)
			slasher:Freeze(true)
			slasher.SlashCooldown = 8

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/umbrabeast/stan_leap_loop.ogg",
				identifier = "StanMauling",
				minDistance = 400,
				maxDistance = 600,
				looping = true,
				entity = slasher,
				volume = 0.5,
				fadeIn = 0,
			})

			if survivor:GetNWBool("SurvivorPounced") then
				slasher:SetNWBool("UmbraBeastAnimateMauling", true)
				timer.Create("UmbraBeastPounceDamage", 1, 0, function()
					survivor:TakeDamage(10)
					survivor:SetVelocity(Vector(0, 0, 0))
					survivor:SetVelocity(-survivor:GetVelocity())
					
					local vPoint = survivor:GetPos() + Vector(0, 0, 50)
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/slasher/trollge/trollge_hit.mp3",
						identifier = "SurvivorHitStan",
						minDistance = 600,
						maxDistance = 800,
						entity = survivor,
						volume = 1,
						fadeIn = 0,
					})
				end)
			end

			timer.Simple(6, function()
				if not IsValid(survivor) then return end

				slasher:SetNWBool("UmbraBeastAnimateMauling", false)
				survivor:SetNWBool("SurvivorPounced", false)
				survivor:Freeze(false)
				slasher:Freeze(false)
				survivor:SetCollisionGroup(1)
				slasher:SetCollisionGroup(1)
				timer.Remove("UmbraBeastPounceDamage")
				SlashCo.AudioSystem.StopSound("StanMauling", 0.1, slasher)

				if IsValid(slasher) then
					survivor:SetVelocity(
						slasher:GetForward() * 500 +
						Vector(0, 0, 150)
					)

					slasher.LeapHit = false
				end
				timer.Simple(3, function()
					survivor:SetCollisionGroup(0)
					slasher:SetCollisionGroup(0)
				end)
			end)
			break
		end
	end
end)


-- The function responsible for the initial leap, when you press M2.
local function StanLeap(slasher)
	if not IsValid(slasher) then return end
	if not slasher:Crouching() then return end
	if slasher.LeapCooldown > 0 then return end
	if not slasher.LeapChargeStart then return end
	if CurTime() - slasher.LeapChargeStart < 2 then return end

	slasher.ChargeLeapCooldown = 10
	slasher:SetNWBool("UmbraBeastAnimateLeapStart", true)

	if slasher:GetNWBool("UmbraBeastAnimateLeapStart") then
		slasher:SetNWBool("UmbraBeastAnimateLeapStart", false)
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/umbrabeast/stan_leap_attack.ogg",
		identifier = "StanLeapAttack",
		minDistance = 600,
		maxDistance = 800,
		entity = slasher,
		volume = 1.0,
		fadeIn = 0,
	})

	slasher.LeapCooldown = 10
	slasher.LeapChargeStart = nil
	slasher:SetNWBool("UmbraBeastCanLeap", false)

	slasher.Leaping = true
	slasher.LeapHit = false
	slasher.LeapEndTime = CurTime() + 5

	local direction = slasher:GetAimVector()
	slasher:SetVelocity(direction * 1000 + Vector(0, 0, 150))
end

function SLASHER.OnSecondaryFire(slasher)
	if slasher:GetNWBool("UmbraBeastStalk") then
		SlashCo.StartChaseMode(slasher)
	else
		StanLeap(slasher)
	end
end

function SLASHER.OnMainAbilityFire(slasher)
	-- We need a lot of precautions so we don't break the swapping.
	if slasher:GetNWBool("UmbraBeastStunned") then return end
	if slasher:GetNWBool("InSlasherChaseMode") then return end
	if slasher.Leaping then return end

	if slasher:GetNWBool("UmbraBeastStalk") then
		StanBreathing(slasher)
		slasher:SetNWBool("UmbraBeastStalk", false)
		slasher.ChaseActivationCooldown = SLASHER.ChaseCooldown
		return
	end

	if slasher:GetNWBool("InSlasherChaseMode") then return end
	if slasher:GetNWBool("UmbraBeastSlashing") then return end
	if slasher.ChaseActivationCooldown > 0 then return end

	if not slasher:GetNWBool("UmbraBeastStalk") then
		slasher:SetNWBool("UmbraBeastStalk", true)
	end
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if not IsValid(slasher) then return end
	if slasher:GetNWBool("UmbraBeastMarkTerritory") then return end

	local territoryPos = slasher:GetPos()

	slasher:SetNWBool("UmbraBeastMarkTerritory", true)
	slasher:SetNWVector("UmbraBeastTerritoryPos", territoryPos)
	slasher:SetNWInt("UmbraBeastTerritoryRadius", UMBRA_TERRITORY_RADIUS)
end

-- This is where we spawn our "territory"
if CLIENT then
	hook.Add("PostDrawTranslucentRenderables", "DrawStanTerritory", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
		if isDraw3DSkybox then return end -- Under no circumstances should the sphere, EVER be drawn in the 3D Skybox.
		local slasher = GameData.LocalPlayer

		if not IsValid(slasher) then return end
		if slasher:Team() ~= TEAM_SLASHER then return end
		if not slasher:GetNWBool("UmbraBeastMarkTerritory") then return end

		local territoryPos = slasher:GetNWVector("UmbraBeastTerritoryPos")
		local territoryRadius = slasher:GetNWInt("UmbraBeastTerritoryRadius", UMBRA_TERRITORY_RADIUS)
		local territoryRadiusNoEffect = UMBRA_TERRITORY_RADIUS

		render.SetColorMaterial()
		render.SetBlend(1)

		-- Outer Sphere, what you see when you're outside of its radius.
		render.DrawSphere(territoryPos, territoryRadius, 32, 16, Color(255, 50, 50, 1))

		-- Inner Sphere, what you see when you're inside of its radius.
		render.DrawSphere(territoryPos, -territoryRadiusNoEffect, 32, 16, Color(255, 50, 50, 1))

		render.SetBlend(0.1)
	end)
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("UmbraBeastStunned") or ply:GetNWBool("UmbraBeastEnrage")
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	local stan_mainslash = ply:GetNWBool("UmbraBeastSlashing")
	local stan_stalk = ply:GetNWBool("UmbraBeastStalk")
	local stan_stun = ply:GetNWBool("UmbraBeastStunned")
	local stan_leap_start = ply:GetNWBool("UmbraBeastAnimateLeapStart")
	local stan_leap_loop = ply:GetNWBool("UmbraBeastAnimateLeap")
	local stan_maul_loop = ply:GetNWBool("UmbraBeastAnimateMauling")
	local stan_flashed = ply:GetNWBool("BeingFlashed", false)
	local stan_enrage = ply:GetNWBool("UmbraBeastEnrage")

	if not stan_stun then
		ply.anim_antispam = false
	end

	-- Some of these...were abysmal, but it functions. That's good.
	if not stan_stalk then
		if ply:IsOnGround() then
			if not chase then
				ply.CalcIdeal = ACT_MP_WALK_MELEE
				ply.CalcSeqOverride = ply:LookupSequence("default_walk")
			end
			if ply:Crouching() then
				ply.CalcIdeal = ACT_MP_CROUCHWALK_MELEE
				ply.CalcSeqOverride = ply:LookupSequence("default_crouchwalk")
			end
		else
			ply.CalcSeqOverride = ply:LookupSequence("default_glide")
		end
	else
		if ply:IsOnGround() then
			if not chase then
				ply.CalcIdeal = ACT_MP_WALK_PRIMARY
				ply.CalcSeqOverride = ply:LookupSequence("sneak_walk")
			else
				ply.CalcIdeal = ACT_MP_WALK_SECONDARY
				ply.CalcSeqOverride = ply:LookupSequence("ape_walk")
			end
			if ply:Crouching() then
				ply.CalcIdeal = ACT_MP_CROUCHWALK_PRIMARY
				ply.CalcSeqOverride = ply:LookupSequence("sneak_crouchwalk")
			end
		else
			ply.CalcSeqOverride = ply:LookupSequence("sneak_glide")
		end
	end

	if stan_leap_start then
		ply:AddVCDSequenceToGestureSlot(2, ply:LookupSequence("leap_start"), 0, true)
	end

	if stan_enrage then
		local seq = ply:LookupSequence("enrage")
		if seq >= 0 then
			ply:AddVCDSequenceToGestureSlot(1, seq, 0, true)
		end
	end

	if stan_leap_loop then
		if ply.UmbraBeastGesture ~= "leap" then
			local sequence = ply:LookupSequence("leap_loop_air")

			if sequence >= 0 then
				ply:AddVCDSequenceToGestureSlot(1, sequence, 0, false)
				ply.UmbraBeastGesture = "leap"
			end
		end
	elseif stan_maul_loop then
		if ply.UmbraBeastGesture ~= "maul" then
			local sequence = ply:LookupSequence("leap_loop_ground")

			if sequence >= 0 then
				ply:AddVCDSequenceToGestureSlot(1, sequence, 1, false)
				ply.UmbraBeastGesture = "maul"
			end
		end
	elseif stan_flashed then
		if ply.UmbraBeastGesture ~= "flashed" then
			local sequence = ply:LookupSequence("default_flashed")

			if sequence >= 0 then
				ply:AddVCDSequenceToGestureSlot(1, sequence, 1, false)
				ply.UmbraBeastGesture = "flashed"
			end
		end

	else
		if ply.UmbraBeastGesture ~= nil then
			ply:AnimResetGestureSlot(1)
			ply.UmbraBeastGesture = nil
		end
	end

	if not stan_stalk then
		if stan_mainslash then
			local r = math.random(1, 2)
			if r == 1 then
				AttackAnim = ply:AddVCDSequenceToGestureSlot(2, ply:LookupSequence("default_attack_left_arms"), 0, true)
			else
				AttackAnim = ply:AddVCDSequenceToGestureSlot(2, ply:LookupSequence("default_attack_right_arms"), 0, true)
			end
			ply.CalcSeqOverride = AttackAnim
		end
	else
		if not chase then
			if stan_mainslash then
				ply:AddVCDSequenceToGestureSlot(2, ply:LookupSequence("sneak_attack_arms"), 0, true)
			end
		else
			if stan_mainslash then
				ply:AddVCDSequenceToGestureSlot(2, ply:LookupSequence("ape_attack_arms"), 0, true)
			end
		end
	end

	if stan_stun then
		ply.CalcSeqOverride = ply:LookupSequence("stun")
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	-- FIRST SLASHER WITH SWIMMING ANIMATIONS?? W??
	hook.Add("CalcMainActivity", "UmbraBeastSwim", function(ply, velocity)
		if ply:WaterLevel() >= 2 then
	    	local sequence = ply:LookupSequence("default_swim")
	    	if sequence > 0 then
				return ACT_MP_SWIM_MELEE, sequence
	    	end
		end
	end)

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if ply:GetNWBool("UmbraBeastStalk") then return true end
	if SERVER then
		local chase = ply:GetNWBool("InSlasherChaseMode")

		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/umbrabeast/stan_step" .. idx .. ".ogg",
			identifier = "StanFootstep" .. idx,
			group = "SlasherFootstep",
			minDistance = 200,
			maxDistance = 400,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end

	return true -- This is actually also important because it removes the default ass hl2 footsteps, thanks Thirsty
end

function SLASHER.OnHitByPocketSand(slasher, ply, additionalRage)
	SlashCo.StopChase(slasher)

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/umbrabeast/stan_stunned" .. ".ogg",
		identifier = "StanStunned",
		minDistance = 1000,
		maxDistance = 2000,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	slasher:SetNWBool("UmbraBeastStunned", true)
	slasher:Freeze(true)

	slasher:SetNWBool("UmbraBeastStalk", false)

	timer.Simple(8, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("UmbraBeastStunned", false)
		slasher:Freeze(false)
	end)
end

local controlTable = {
	default = Material("slashco/ui/icons/slasher/slash"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/stan"))

	local case = math.random(1, 4)
	if case == 1 then
		hud:SetTitle("Umbra Beast")
	elseif case == 2 then
		hud:SetTitle("The Experiment")
	elseif case == 3 then
		hud:SetTitle("Test Subject A-█")
	elseif case == 4 then
		hud:SetTitle("?̷̨̤̮̭͔̘͒̅͗̐?̴̝͙͈͝?̵̭͉̪̪͂̂͋͛̉͝")
	end

	hud:AddMeter("agitation", 100, "", nil, true)
	hud:TieMeterInt("agitation", "UmbraBeastAgitation")

	hud:AddControl("CTRL", "charge leap")
	hud:AddControl("R", "stalk")
	hud:AddControl("F", "mark territory")
	hud:TieControlText("R", "UmbraBeastStalk", "prowl", "stalk", true)
	hud:AddControl("LMB", "slash", controlTable)
	hud:AddControl("RMB", "chase")
	hud:SetControlVisible("RMB", false)

	hud:TieControl("CTRL", "UmbraBeastCanChargeLeap")
	hud:TieControl("LMB", "UmbraBeastCanSlash")

	function hud.AlsoThink()
		local stalking = GameData.LocalPlayer:GetNWBool("UmbraBeastStalk")
		local crouching = GameData.LocalPlayer:GetNWBool("UmbraBeastCrouching")
		local chasing = GameData.LocalPlayer:GetNWBool("InSlasherChaseMode")
		local agitation = GameData.LocalPlayer:GetNWInt("UmbraBeastAgitation")
		local territory = GameData.LocalPlayer:GetNWBool("UmbraBeastMarkTerritory")

		if territory then
			hud:RemoveControl("F")
		end

		if agitation >= 70 then
			hud:TieControlText("LMB", "UmbraBeastCanSlash", "kill survivor", "kill survivor", true)
		elseif agitation <= 70 then
			hud:TieControlText("LMB", "UmbraBeastCanSlash", "slash", "slash", true)
		end

		if stalking and not chasing and agitation >= 100 then
			hud:TieControl("RMB", "")
			hud:SetText("Chase")
			hud:SetControlVisible("CTRL", false)
			hud:SetControlVisible("RMB", true)
		elseif stalking and not chasing and agitation <= 100 then
			hud:UntieControl("RMB")
			hud:TieControlText("RMB", "UmbraBeastCanLeap", "chase", "chase", true)
			hud:SetControlVisible("CTRL", false)
			hud:SetControlVisible("RMB", false)
		elseif not stalking and not crouching then
			hud:UntieControl("RMB")
			hud:SetControlVisible("CTRL", true)
			hud:SetControlVisible("LMB", true)
			hud:SetControlVisible("RMB", false)
		elseif not stalking and crouching then
			hud:SetControlVisible("CTRL", false)
			hud:SetControlVisible("RMB", true, controlTable)
			hud:TieControl("RMB", "UmbraBeastCanLeap")
			hud:TieControlText("RMB", "UmbraBeastCanLeap", "leap", "leap", true)
		elseif chasing and agitation >= 70 then
			hud:TieControlText("LMB", "UmbraBeastCanSlash", "kill survivor", "kill survivor", true)
			hud:SetControlVisible("LMB", true)
			hud:SetControlVisible("RMB", false)
		elseif chasing and agitation <= 70 then
			hud:TieControlText("LMB", "UmbraBeastCanSlash", "slash", "slash", true)
			hud:SetControlVisible("LMB", true)
			hud:SetControlVisible("RMB", false)
		elseif not chasing then
			hud:TieControlText("LMB", "UmbraBeastCanSlash", "slash", "slash", true)
		end
	end
end


	hook.Add("SlashCo:DrawHUD", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_UmbraBeast") == true then
			if GameData.LocalPlayer.umbra_f == nil then
				GameData.LocalPlayer.umbra_f = 0
			end
			GameData.LocalPlayer.umbra_f = GameData.LocalPlayer.umbra_f + (FrameTime() * 8)
			if GameData.LocalPlayer.umbra_f > 10 then
				return
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_stan")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.umbra_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.umbra_f = nil
		end
	end)

SlashCo.RegisterSlasher(SLASHER, "UmbraBeast")