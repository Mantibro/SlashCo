local SLASHER = {}

SLASHER.Name = "Postal Dude"
SLASHER.Aliases = {
	"The Dude",
	"Clark",
	"The Demon"
}
SLASHER.Class = SlashCo.SlasherClass.Umbra
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/postaldude/redux_dude.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 2
SLASHER.ProwlSpeed = 305
SLASHER.ChaseSpeed = 305
SLASHER.Perception = 1.0
SLASHER.Eyesight = 6
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.75
SLASHER.ChaseDuration = 15.0
SLASHER.ChaseCooldown = 1
SLASHER.PatienceDecrease = -5	-- How fast Patience should decrease by damaging
SLASHER.PatienceChaseIncrease = 0.01	-- How fast Patience should increase out of chase
SLASHER.PatienceChaseDecrease = -0.01	-- How fast Patience should decrease in chase
SLASHER.FuelAmount = 30		-- Max amount of fuel
SLASHER.FuelRegen = 0.005	-- How fast fuel should passively regen
SLASHER.GunShotDecay = 0.120 -- How long he'll be in the shooting animation.
SLASHER.ChaseMusic = ""
SLASHER.KillSound = ""
SLASHER.Description = "PostalDude_desc"
SLASHER.ProTip = "PostalDude_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★★☆"
SLASHER.DiffRating = "★★★★☆"
SLASHER.DisableHelicopterMusic = true
SLASHER.CustomBackgroundMusic = true

-- Stages, at stage 1 he only has a shovel, at stage 2 he unlocks the deagle, etc.
local POSTAL_SHOVEL_STAGE = 1
local POSTAL_DEAGLE_STAGE = 2
local POSTAL_MG_STAGE = 3
local POSTAL_RAGE_STAGE = 4

-- Checking what state he's currently in
local POSTAL_SHOVEL_EQUIPPED = 0
local POSTAL_DEAGLE_UNEQUIPPED = 1
local POSTAL_DEAGLE_EQUIPPED = 2
local POSTAL_MG_EQUIPPED = 3
local POSTAL_GAS_EQUIPPED = 5
local POSTAL_BABY_EQUIPPED = 666

-- If you thought Sid's code was ass, then get ready for some serious bullshit right here, by yours truly, eno

-- Anger is already used for the Patience Meter, so we have to make a new function for the fuel meter
local function PostalDudeFuelAmount(slasher)
	return slasher:GetNW2Float("PostalDudeFuelAmount", 0)
end

local function PostalDudeFuelControl(slasher, fuel)
	slasher:SetNW2Float("PostalDudeFuelAmount", math.Clamp(PostalDudeFuelAmount(slasher) + fuel, 0, 30))
end

local function DeagleBulletsAmount(slasher)
	return slasher:GetNW2Float("DeagleBulletsAmount", 0)
end

local function DeagleBulletsControl(slasher, bullets)
	slasher:SetNW2Float("DeagleBulletsAmount", math.Clamp(DeagleBulletsAmount(slasher) + bullets, 0, 6))
end

local function MGBulletsAmount(slasher)
	return slasher:GetNW2Float("MGBulletsAmount", 0)
end

local function MGBulletsControl(slasher, bullets)
	slasher:SetNW2Float("MGBulletsAmount", math.Clamp(MGBulletsAmount(slasher) + bullets, 0, 20))
end

local function PrincessBestDog()
    for _, s in ipairs(team.GetPlayers(TEAM_SLASHER)) do
        if s:GetNWString("Slasher") == "Princess" then return true end
    end
    return false
end

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.ChaseDuration = 7.0 + (1 * additionalSurvivors)

	if additionalSurvivors > 0 then
		SLASHER.ProwlSpeed = 305 + (3 * additionalSurvivors)
		SLASHER.ChaseSpeed = 305 + (0.5 * additionalSurvivors)
		SLASHER.KillDistance = 150 + (2 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	timer.Create("CreateBullets" .. slasher:UserID(), 2, 3, function()
		if not IsValid(slasher) then return end

		SlashCo.CreateItem("sc_postalammo", SlashCo.RandomPosLocator(), Angle(0, 0, 0))
	end)

	slasher:SetBodygroup(1, 1)		-- Set the proper bodygroups
	slasher:SetBodygroup(2, 0)
	slasher:SetBodygroup(3, 0)
	slasher:SetBodygroup(4, 0)

	slasher:SetNWBool("CanChase", true)
	slasher:SetNWBool("SwitchToShovel", true)
	slasher:SetNWBool("SwitchToDeagle", false)
	slasher:SetNWBool("SwitchToMG", false)
	slasher:SetNWBool("SwitchToGas", false)
	slasher:SetNWBool("SwitchToBaby", false)
	slasher:SetNWInt("PostalStage", POSTAL_SHOVEL_STAGE)
	slasher:SetNWBool("DeagleUnlocked", false)
	slasher:SetNWBool("MGUnlocked", false)

	DeagleBulletsControl(slasher, 6)
	MGBulletsControl(slasher, 20)

	SLASHER.ChaseMusic = "slashco/slasher/postaldude/dude_phase1.ogg"

	slasher.PostalState = -1		-- This state is important so we display HUD information accurately to the slasher
	slasher.DeagleAmmo = 6
	slasher.FuelAmount = 30			-- Default fuel amount
	slasher.GunSpread = 0
	slasher.SlashCooldown = 0
	slasher.M4Cooldown = 0
	slasher.GasCooldown = 0
	slasher.KickCooldown = 0
end

function SLASHER.OnHelicopterSummon(slasher)
	if slasher.PostalDudeStage ~= POSTAL_RAGE_STAGE then
		slasher.PostalDudeStage = POSTAL_RAGE_STAGE
		DeagleBulletsControl(slasher, 3)
		MGBulletsControl(slasher, 10)

		timer.Simple(0.3, function()
			if not IsValid(slasher) then return end

			local idx = math.random(1, 3)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_ragestart" .. idx .. ".ogg",
				identifier = "PostalRage" .. idx,
				minDistance = 15000,
				maxDistance = 20000,
				entity = slasher,
				volume = 1.0,
				fadeIn = 0,
			})
		end)

		timer.Simple(1, function()
			if not IsValid(slasher) then return end

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_phase4.ogg",
				identifier = "PostalRageTheme",
				minDistance = 15000,
				maxDistance = 20000,
				looping = true,
				entity = slasher,
				volume = 1.25,
				fadeIn = 0,
			})
		end)
	end
end

function SLASHER.OnTickBehaviour(slasher)
	local stage = slasher.PostalDudeStage --Stage
	local SlashCooldown = slasher.SlashCooldown or 0 -- Main Slash Cooldown
	local KickCooldown = slasher.KickCooldown or 0 -- Kick Cooldown
	local PostalState = slasher.PostalState or 0 -- Postal State
	local GunSpread = slasher.GunSpread or 0

	local eyesight_final = SLASHER.Eyesight
	local perception_final = SLASHER.Perception

	if SlashCooldown > 0 then
		slasher.SlashCooldown = SlashCooldown - FrameTime()
	end

	if SlashCooldown > 0 and slasher:GetNWBool("PostalDudeCanMainSlash") then
		slasher:SetNWBool("PostalDudeCanMainSlash", false)
	end

	if SlashCooldown <= 0 and not slasher:GetNWBool("PostalDudeCanMainSlash") then
		slasher:SetNWBool("PostalDudeCanMainSlash", true)
	end

	if KickCooldown > 0 then
		slasher.KickCooldown = KickCooldown - FrameTime()
	end

	if KickCooldown > 0 and slasher:GetNWBool("PostalDudeCanMainKick") then
		slasher:SetNWBool("PostalDudeCanMainKick", false)
	end

	if KickCooldown <= 0 and not slasher:GetNWBool("PostalDudeCanMainKick") then
		slasher:SetNWBool("PostalDudeCanMainKick", true)
	end

	--Clear chase music if chase ends on its own and not via player input
	if not slasher:GetNWBool("InSlasherChaseMode") then
		-- Passive Ambience emitting from Postal Dude if he's not in chase
		if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then	
			if not slasher:GetNWBool("PostalAmbience") then
				slasher:SetNWBool("PostalAmbience", true)
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/postaldude/dude_ambience.ogg",
					identifier = "PostalAmbience",
					minDistance = 500 * SlashCo.MapSize,
					maxDistance = 1000 * SlashCo.MapSize,
					looping = true,
					entity = slasher,
					volume = 0.2,
					fadeIn = 1,
					sendToEntity = team.GetPlayers(TEAM_SURVIVOR)
				})
			end
		end
	else
		slasher:SetNWBool("PostalAmbience", false)
		SlashCo.AudioSystem.StopSound("PostalAmbience", 1, slasher)
	end

	if not SlashCo.CurRound.EscapeHelicopterSummoned then
		-- Check for game progress for Stage 1
		if SlashCo.CurRound.GameProgress < 3 and slasher:GetNWInt("PostalStage") ~= POSTAL_SHOVEL_STAGE then
			stage = POSTAL_SHOVEL_STAGE
		end
		-- Check for game progress for Stage 2
		if SlashCo.CurRound.GameProgress >= 3 and SlashCo.CurRound.GameProgress < 6 and slasher:GetNWInt("PostalStage") ~= POSTAL_DEAGLE_STAGE then
			SLASHER.PatienceChaseIncrease = 0.02
			if not slasher:GetNWBool("SwitchToGas") and not slasher:GetNWBool("SwitchToBaby") and slasher.PostalState ~= POSTAL_SHOVEL_EQUIPPED then
				slasher.PostalState = POSTAL_SHOVEL_EQUIPPED -- Update HUD to show the deagle
				slasher:SetBodygroup(1, 1)
				slasher:SetBodygroup(2, 0)
				slasher:SetBodygroup(3, 0)
				slasher:SetBodygroup(4, 0)
			end
			stage = POSTAL_DEAGLE_STAGE
			-- Play a sound to let people know that they unlocked a new weapon
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_deagle1.ogg",
				identifier = "PostalDeagleIntro",
				minDistance = 500,
				maxDistance = 750,
				entity = slasher,
				volume = 0.8,
				fadeIn = 0,
			})
		end
		-- Check for game progress for Stage 3
		if SlashCo.CurRound.GameProgress >= 6 and SlashCo.CurRound.GameProgress < 10 and slasher:GetNWInt("PostalStage") ~= POSTAL_MG_STAGE then
			-- This is to switch the player to a "new" deagle state that has the updated hud for the M4, so it isn't buggy, and it's smooth
			SLASHER.PatienceChaseIncrease = 0.03
			if slasher.PostalState == POSTAL_DEAGLE_UNEQUIPPED and not slasher:GetNWBool("SwitchToGas") then
				slasher.PostalState = POSTAL_DEAGLE_EQUIPPED
				slasher:SetBodygroup(1, 0)
				slasher:SetBodygroup(2, 1)
				slasher:SetBodygroup(3, 0)
				slasher:SetBodygroup(4, 0)
			end
			stage = POSTAL_MG_STAGE
			-- Once again play a sound to inform the player of a new weapon being unlocked
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_machinegun1.ogg",
				identifier = "PostalM4Intro",
				minDistance = 500,
				maxDistance = 750,
				entity = slasher,
				volume = 0.8,
				fadeIn = 0,
			})
		end
	end

	-- Basically functions almost the same as Trollge's stages, code-wise
	if stage == POSTAL_SHOVEL_STAGE then
		slasher:SetNWInt("PostalStage", POSTAL_SHOVEL_STAGE)
		SLASHER.ChaseMusic = "slashco/slasher/postaldude/dude_phase1.ogg"
		perception_final = 1.5
	elseif stage == POSTAL_DEAGLE_STAGE then
		slasher:SetNWBool("DeagleUnlocked", true)
		slasher:SetNWInt("PostalStage", POSTAL_DEAGLE_STAGE)
		SLASHER.ChaseMusic = "slashco/slasher/postaldude/dude_phase2.ogg"
		perception_final = 2.0
	elseif stage == POSTAL_MG_STAGE then
		slasher:SetNWBool("MGUnlocked", true)
		slasher:SetNWInt("PostalStage", POSTAL_MG_STAGE)
		SLASHER.ChaseMusic = "slashco/slasher/postaldude/dude_phase3.ogg"
		perception_final = 3.0
	elseif stage == POSTAL_RAGE_STAGE then
		slasher:SetNWInt("PostalStage", POSTAL_RAGE_STAGE)
		slasher:SetNWBool("CanChase", false)
		if slasher:GetNWBool("InSlasherChaseMode") then
			SlashCo.StopChase(slasher)
		end

		SlashCo.AddSlasherAnger(slasher, 100)
		perception_final = 5.0
	end

	-- Mainly used for HUD control
	if PostalState == POSTAL_SHOVEL_EQUIPPED then -- Is In Shovel State
		slasher:SetNWBool("SwitchToShovel", true)
		slasher:SetNWBool("SwitchToDeagle", false)
		slasher:SetNWBool("SwitchToMG", false)
	elseif PostalState == POSTAL_DEAGLE_UNEQUIPPED or PostalState == POSTAL_DEAGLE_EQUIPPED then -- Is In Deagle State
		slasher:SetNWBool("SwitchToDeagle", true)
		slasher:SetNWBool("SwitchToShovel", false)
		slasher:SetNWBool("SwitchToMG", false)
	elseif PostalState == POSTAL_MG_EQUIPPED then -- Is In MG State
		slasher:SetNWBool("SwitchToShovel", false)
		slasher:SetNWBool("SwitchToDeagle", false)
		slasher:SetNWBool("SwitchToMG", true)
	end

	-- Passively regenerate fuel
	PostalDudeFuelControl(slasher, SLASHER.FuelRegen)

	-- Postal Dude loses his patience during chase, which slows him down, tl;dr, longer chase = less patience || less patience = slower movement speed
	local PostalMinSpeed = 0.9
	local PostalMaxSpeed = 1.0

	if slasher:GetNWBool("SwitchToGas") then
		if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then
			slasher:SetRunSpeed(SLASHER.ChaseSpeed - 100)	-- Nerf his speed a bit when carrying a gas can
			slasher:SetWalkSpeed(SLASHER.ChaseSpeed - 100)
		end
	else
		if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then
			slasher:SetRunSpeed(310)
			slasher:SetWalkSpeed(310)
		end

		local PostalPatience = Lerp(SlashCo.GetSlasherAnger(slasher) / 100, PostalMinSpeed,	PostalMaxSpeed)

		if slasher:GetNWBool("InSlasherChaseMode") then
			if SlashCo.GetSlasherAnger(slasher) == 0 and not slasher:GetNWBool("BoredAlready") then
				slasher:SetNWBool("BoredAlready", true)

				local idx = math.random(1, 2)
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/postaldude/dude_patienceempty" .. idx .. ".ogg",
					identifier = "PostalPatienceEmpty" .. idx,
					minDistance = 500,
					maxDistance = 750,
					entity = slasher,
					volume = 0.9,
					fadeIn = 0,
				})
			elseif SlashCo.GetSlasherAnger(slasher) > 0 then
				slasher:SetNWBool("BoredAlready", false)
			end
			SlashCo.AddSlasherAnger(slasher, SLASHER.PatienceChaseDecrease)
			slasher:SetRunSpeed(SLASHER.ChaseSpeed * PostalPatience)
			slasher:SetWalkSpeed(SLASHER.ChaseSpeed * PostalPatience)
		else
			SlashCo.AddSlasherAnger(slasher, SLASHER.PatienceChaseIncrease)
			slasher:SetRunSpeed(SLASHER.ProwlSpeed * PostalPatience)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed * PostalPatience)
		end
	end

	-- patience stuff
	local patience = SlashCo.GetSlasherAnger(slasher)
	if slasher:GetNWInt("PostalDudePatience") ~= math.floor(patience) then
		slasher:SetNWInt("PostalDudePatience", math.floor(patience))
	end

	-- fuel stuff
	local fuelamount = PostalDudeFuelAmount(slasher)
	if slasher:GetNWInt("PostalDudeFuelAmount") ~= math.floor(fuelamount) then
		slasher:SetNWInt("PostalDudeFuelAmount", math.floor(fuelamount))
	end

	-- We use this to keep a track of the player's Deagle ammo
	local DeagleAmmo = DeagleBulletsAmount(slasher)
	if slasher:GetNWInt("DeagleBulletsAmount") ~= math.floor(DeagleAmmo) then
		slasher:SetNWInt("DeagleBulletsAmount", math.floor(DeagleAmmo))
	end

	-- We use this to keep a track of the player's M4 ammo
	local MGAmmo = MGBulletsAmount(slasher)
	if slasher:GetNWInt("MGBulletsAmount") ~= math.floor(MGAmmo) then
		slasher:SetNWInt("MGBulletsAmount", math.floor(MGAmmo))
	end

	-- Very important otherwise everything shits the bed
	if slasher:GetNWInt("PostalState") ~= PostalState then
		slasher:SetNWInt("PostalState", PostalState)
	end

	slasher:SetEyeSight(eyesight_final)
	slasher:SetPerception(perception_final)
end

hook.Add("PlayerDeath", "PostalDudeCountKills", function(victim, _, attacker)
	timer.Remove("PostalDudeHit_" .. victim:UserID())
	if not IsValid(attacker) then return end

	if victim:Team() ~= TEAM_SLASHER and attacker:GetNWString("Slasher") == "PostalDude" then
		local idx = math.random(1, 7)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_kill" .. idx .. ".ogg",
			identifier = "PostalKill" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = attacker,
			volume = 1,
			fadeIn = 0,
		})
	end
end)

-- The code responsible for doing a fake Gas Can pick up for Postal Dude
hook.Add("PlayerUse", "PostalGasCanPickUp", function(ply, ent)
    if ply:Team() ~= TEAM_SLASHER then return end -- If client isn't a slasher, don't do it
	if ply:GetNWString("Slasher") ~= "PostalDude" then return end
    if ent:GetClass() ~= "sc_gascan" then return end -- If entity isn't a gas can, don't do it
	if ply:GetPos():Distance(ent:GetPos()) >= 100 then return end -- If the distance isn't (X), don't do it
	if ply:GetNWBool("SwitchToGas") then return end -- If Postal Dude is already carrying a Gas Can, don't delete another one
	if ply:GetNWBool("SwitchToBaby") then return end

	SlashCo.StopChase(ply)	-- Stop chase if we pick up a Gas Can

	if IsValid(ent) then
		ent:Remove()	-- Deletes the Gas Can that the Postal Dude is trying to grab
	end

	-- Play default gas can pickup sound
	local idxGas = math.random(1, 3)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/gascan_pickup" .. idxGas .. ".mp3",
		identifier = "DefaultGasCanPickUp" .. idxGas,
		minDistance = 500,
		maxDistance = 750,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	-- Play Postal Dude voiceline
	local idx = math.random(1, 4)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/postaldude/dude_gas" .. idx .. ".ogg",
		identifier = "PostalGasCanPickUp" .. idx,
		minDistance = 500,
		maxDistance = 750,
		entity = ply,
		volume = 0.8,
		fadeIn = 0,
	})

	-- Self-explanatory I think
	ply:SetNWBool("SwitchToShovel", false)
	ply:SetNWBool("SwitchToDeagle", false)
	ply:SetNWBool("SwitchToMG", false)
	ply:SetNWBool("SwitchToBaby", false)
	ply:SetNWBool("SwitchToGas", true)

	ply:SetBodygroup(1, 0)
	ply:SetBodygroup(2, 0)
	ply:SetBodygroup(3, 0)
	ply:SetBodygroup(4, 1)	-- Clear every bodygroup and use the right one

	ply.PostalState = POSTAL_GAS_EQUIPPED -- Switch to Gas Can state
end)

----hook.Add("PlayerUse", "PostalBabyPickUp", function(ply, ent)
----    if ply:Team() ~= TEAM_SLASHER then return end
----    if ent:GetClass() ~= "sc_baby" then return end
----	if ply:GetPos():Distance(ent:GetPos()) >= 100 then return end
----	if ply:GetNWBool("SwitchToGas") then return end
----	if not PrincessBestDog() then return end
----
----	if IsValid(ent) then
----		ent:Remove()
----	end
----
----	-- Play default gas can pickup sound
----	SlashCo.AudioSystem.PlaySound({
----		soundPath = "ambient/creatures/teddy" .. ".wav",
----		identifier = "PostalBabyPickUp",
----		minDistance = 500,
----		maxDistance = 750,
----		entity = ply,
----		volume = 1,
----		fadeIn = 0,
----	})
----
----	-- Self-explanatory I think
----	ply:SetNWBool("SwitchToShovel", false)
----	ply:SetNWBool("SwitchToDeagle", false)
----	ply:SetNWBool("SwitchToMG", false)
----	ply:SetNWBool("SwitchToGas", false)
----	ply:SetNWBool("SwitchToBaby", true)
----
----
----	ply:SetBodygroup(1, 0)
----	ply:SetBodygroup(2, 0)
----	ply:SetBodygroup(3, 0)
----	ply:SetBodygroup(4, 0)	-- Clear every bodygroup and use the right one
----
----	ply.PostalState = POSTAL_BABY_EQUIPPED -- Switch to Gas Can state
----
----end)

-- Has to be server otherwise CreateGasCan will never work
if SERVER then
	-- Hook player input to detect them dropping it, should be Q because it's Q for survivors as well
	hook.Add("PlayerButtonDown", "PostalGasCanDrop", function(ply, button)
		-- Same stuff as above in the previous hook
		if not SlashCo.IsKeyPressed("DROP_ITEM", ply, button) then return end
	    if ply:Team() ~= TEAM_SLASHER then return end
		if ply:GetNWString("Slasher") ~= "PostalDude" then return end
		if not ply:GetNWBool("SwitchToGas") then return end

		local startPos = ply:WorldSpaceCenter()
		local goodPos = startPos + (ply:GetAimVector() * 1)
	   	local DropGasCan = SlashCo.CreateGasCan(goodPos, Angle(0, 0, 0)) -- Create Gas Can when dropping the fake one, since we deleted an actual Gas Can
		local phys = DropGasCan:GetPhysicsObject()

		if IsValid(phys) then	-- Have to be very careful here, we don't want the Gas Can to be thrown outside of the world
			phys:SetVelocity(ply:GetAimVector() * 250)

			local randomvec = Vector(0, 0, 0)
			randomvec:Random(-1000, 1000)
			phys:SetAngleVelocity(randomvec)
		end

		ply:SetNWBool("SwitchToGas", false)
		ply:SetNWBool("SwitchToShovel", true)

		ply:SetBodygroup(1, 1)
		ply:SetBodygroup(2, 0)
		ply:SetBodygroup(3, 0)
		ply:SetBodygroup(4, 0)	-- Clear every bodygroup and use the right one

		if ply:GetNWInt("PostalStage") == POSTAL_RAGE_STAGE then
			ply:SetRunSpeed(310)
			ply:SetWalkSpeed(310)
		else
			ply:SetRunSpeed(SLASHER.ChaseSpeed)
			ply:SetWalkSpeed(SLASHER.ChaseSpeed)
		end

		-- More hud stuff
		if ply:GetNWBool("DeagleUnlocked") then 
			ply.PostalState = POSTAL_SHOVEL_EQUIPPED
		else
			ply.PostalState = -1
		end
	end)
end

function SLASHER.OnPrimaryFire(slasher)
	if slasher:GetNWBool("PostalDudeStunned") then return end
	if slasher.SlashCooldown > 0 then return end

	-- In hindsight this could've been done cleaner but...it's readable for me, so it works good enough
	if slasher:GetNWBool("SwitchToShovel") then
		slasher.SlashCooldown = 1
		slasher:SetNWBool("PostalDudeSlashing", true)
	end

	if slasher:GetNWBool("SwitchToDeagle") then
		slasher.SlashCooldown = 0.5
	end

	if slasher:GetNWBool("SwitchToMG") then
		slasher.SlashCooldown = 0
	end

	local function SlashFinish()
		if not IsValid(slasher) then return end
		if slasher:GetNWBool("SwitchToDeagle") then return end
		if slasher:GetNWBool("SwitchToMG") then return end
		if slasher:GetNWBool("SwitchToGas") then return end
		if slasher:GetNWBool("SwitchToBaby") then return end

		slasher:SlasherHudFunc("ShakeControl", "LMB")

		local idx = math.random(1, 2)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_shovelswing" .. idx .. ".ogg",
			identifier = "PostalShovelSwing" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = slasher,
			volume = 0.7,
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
		local damage = 33

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

		slasher:SetNWBool("PostalDudeSlashing", false)

		if target:IsPlayer() then
			if target:Team() ~= TEAM_SURVIVOR then return end

			if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then
				if not slasher:GetNWBool("InSlasherChaseMode") then
					SlashCo.StartChaseMode(slasher, true)
					slasher:SetNWBool("InSlasherChaseMode", true)
				end
			end

			local vPoint = target:GetPos() + Vector(0, 0, 50)
			local bloodfx = EffectData()
			bloodfx:SetOrigin(vPoint)
			util.Effect("BloodImpact", bloodfx)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_shovelhit.ogg",
				identifier = "SurvivorHitDude",
				minDistance = 600,
				maxDistance = 800,
				entity = target,
				volume = 1,
				fadeIn = 0,
			})
			
			if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then
				if target:IsPlayer() then
					SlashCo.AddSlasherAnger(slasher, SLASHER.PatienceDecrease)
				end
			end
		end
	end

	timer.Create(slasher:EntIndex() .. "_PostalDudeSlash", 0.1, 1, SlashFinish)

	if slasher:GetNWBool("SwitchToDeagle") then
		if slasher:GetNWBool("SwitchToGas") then return end
		if slasher:GetNWBool("SwitchToBaby") then return end
		if slasher:GetNWInt("DeagleBulletsAmount") > 0 then -- Allows the players to fire their gun if they have enough bullets
			slasher:SlasherHudFunc("ShakeControl", "LMB")

			local spread = slasher.GunSpread
			local dist = SLASHER.KillDistance
			timer.Simple(0.05, function()
				if not IsValid(slasher) then return end

				slasher:SetNWFloat("PostalDeagleShoot", CurTime())

				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/postaldude/dude_deagleshoot.ogg",
					identifier = "PostalDeagleShoot",
					minDistance = 750,
					maxDistance = 1250,
					entity = slasher,
					volume = 0.8,
					fadeIn = 0,
				})

				slasher:FireBullets({
					Callback = function(attacker, tr, dmginfo)
						local target = tr.Entity
						if not IsValid(target) or not target:IsPlayer() then return end
						if slasher:GetNWInt("PostalStage") == POSTAL_RAGE_STAGE then return end

						SlashCo.AddSlasherAnger(slasher, SLASHER.PatienceDecrease)
						if not slasher:GetNWBool("InSlasherChaseMode") then
							SlashCo.StartChaseMode(slasher, true)
						end

						-- Hitting someone is already hard enough, let Postal deal full damage
						if tr.HitGroup == HITGROUP_LEFTLEG or tr.HitGroup == HITGROUP_RIGHTLEG or tr.HitGroup == HITGROUP_LEFTARM or tr.HitGroup == HITGROUP_RIGHTARM then
							dmginfo:ScaleDamage(4)
						elseif tr.HitGroup == HITGROUP_HEAD then
							dmginfo:ScaleDamage(1)
						end
					end,

					Damage = 20,
					TracerName = "AirboatGunHeavyTracer",
					Dir = slasher:GetAimVector(),
					Src = slasher:GetPos() + Vector(0, 0, 60),
					IgnoreEntity = slasher,
					Spread = Vector(
						math.Rand(-1 - (spread * 5), 1 + (spread * 5)) * 0.006,
						math.Rand(-1 - (spread * 5), 1 + (spread * 5)) * 0.006,
						0
					)
				}, false)

				local vec, ang = slasher:GetBonePosition(slasher:LookupBone("ValveBiped.Bip01_R_Finger1"))
				local vPoint = vec
				local muzzle = EffectData()
				muzzle:SetOrigin(vPoint + slasher:GetForward() * 8 + Vector(0, 0, 2))
				muzzle:SetStart(Vector(255, 0, 0))
				muzzle:SetAttachment(0)
				muzzle:SetEntity(slasher)
				util.Effect("sid_muzzle", muzzle)

				local shell = EffectData()
				shell:SetOrigin(vPoint)
				shell:SetAngles(ang)
				util.Effect("ShellEject", shell)
				DeagleBulletsControl(slasher, -1)
			end)
		else
			-- Don't have bullets? Play sound
			SlashCo.AudioSystem.PlaySound({
				soundPath = "weapons/shotgun/shotgun_empty.wav",
				identifier = "PostalDeagleEmpty",
				minDistance = 750,
				maxDistance = 1250,
				entity = slasher,
				volume = 0.7,
				fadeIn = 0,
			})
		end
	end

	-- The only way to make weapons automatic is by hooking a think function to them and setting their cooldown here
	hook.Add("Think", "MGShoot", function()
		if slasher:KeyDown(IN_ATTACK) then
			if slasher.M4Cooldown > CurTime() then return end

			slasher.M4Cooldown = CurTime() + 0.1

			if slasher:GetNWBool("SwitchToMG") then
				if slasher:GetNWBool("SwitchToGas") then return end
				if slasher:GetNWBool("SwitchToBaby") then return end

				if slasher:GetNWInt("MGBulletsAmount") > 0 then -- Same thing as the Deagle
					slasher:SlasherHudFunc("ShakeControl", "LMB")

					local spread = slasher.GunSpread
					local dist = SLASHER.KillDistance
					timer.Simple(0.05, function()
						if not IsValid(slasher) then return end

						slasher:SetNWFloat("PostalMGShoot", CurTime())
						SlashCo.AudioSystem.PlaySound({
							soundPath = "slashco/slasher/postaldude/dude_m4shoot.ogg",
							identifier = "PostalM4",
							minDistance = 750,
							maxDistance = 1250,
							entity = slasher,
							volume = 0.7,
							fadeIn = 0,
						})

						slasher:FireBullets({
							Callback = function(attacker, tr, dmginfo)
								local target = tr.Entity
								if not IsValid(target) or not target:IsPlayer() then return end
								if slasher:GetNWInt("PostalStage") == POSTAL_RAGE_STAGE then return end

								SlashCo.AddSlasherAnger(slasher, SLASHER.PatienceDecrease)
								if not slasher:GetNWBool("InSlasherChaseMode") then
									SlashCo.StartChaseMode(slasher, true)
								end

								if tr.HitGroup == HITGROUP_LEFTLEG or tr.HitGroup == HITGROUP_RIGHTLEG or tr.HitGroup == HITGROUP_LEFTARM or tr.HitGroup == HITGROUP_RIGHTARM then
									dmginfo:ScaleDamage(4)
								elseif tr.HitGroup == HITGROUP_HEAD then
									dmginfo:ScaleDamage(1)
								end
							end,

							Damage = 10,
							TracerName = "AirboatGunHeavyTracer",
							Dir = slasher:GetAimVector(),
							Src = slasher:GetPos() + Vector(0, 0, 60),
							IgnoreEntity = slasher,
							Spread = Vector(
								math.Rand(-1 - (spread * 5), 1 + (spread * 5)) * 0.006,
								math.Rand(-1 - (spread * 5), 1 + (spread * 5)) * 0.006,
								0
							)
						}, false)

						local vec, ang = slasher:GetBonePosition(slasher:LookupBone("ValveBiped.Bip01_R_Finger1"))
						local vPoint = vec
						local muzzle = EffectData()
						muzzle:SetOrigin(vPoint + slasher:GetForward() * 8 + Vector(0, 0, 2))
						muzzle:SetStart(Vector(255, 0, 0))
						muzzle:SetAttachment(0)
						muzzle:SetEntity(slasher)

						local shell = EffectData()
						shell:SetOrigin(vPoint)
						shell:SetAngles(ang)
						util.Effect("ShellEject", shell)
						MGBulletsControl(slasher, -1)
						slasher.GunSpread = 3
					end)
				else
					SlashCo.AudioSystem.PlaySound({
						soundPath = "weapons/shotgun/shotgun_empty.wav",
						identifier = "PostalM4Empty",
						minDistance = 750,
						maxDistance = 1250,
						entity = slasher,
						volume = 0.7,
						fadeIn = 0,
					})
				end
			end
		end
	end)

	-- All of this is just that code from that one gas can swep, god bless whoever made that
	-- We also make the gas can automatic, we don't want players to get frustrated over spamming m1
	hook.Add("Think", "GasPour", function()
		if slasher:KeyDown(IN_ATTACK) then
			if slasher.GasCooldown > CurTime() then return end

			slasher.GasCooldown = CurTime() + 0.08

			if slasher:GetNWBool("SwitchToGas") then
				if slasher:GetNWInt("PostalDudeFuelAmount") > 0 then -- Same thing as the guns
					local fire, tr
						tr = util.TraceLine{
					  start = slasher:GetShootPos(),
					  endpos = slasher:GetShootPos() + slasher:GetAimVector() * 160,
					  filter = slasher
					}
 					if not tr.Hit then return end

					local idx = math.random(1, 3)
					SlashCo.AudioSystem.PlaySound({
						soundPath = "ambient/water/water_spray" .. idx .. ".wav",
						identifier = "PostalUseGas" .. idx,
						minDistance = 500,
						maxDistance = 750,
						entity = slasher,
						volume = 0.9,
						fadeIn = 0,
					})

					slasher:SlasherHudFunc("ShakeControl", "LMB")
 					util.Decal("BeerSplash", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
					ParticleEffect("water_splash_01_surface1", tr.HitPos, tr.HitNormal:Angle())

					if CLIENT then return end

					fire = ents.Create("env_fire")
					fire:SetNWBool("PostalFire", true) -- Do this so we can separate map fire from Postal's fire
					fire:SetKeyValue("health", 20)
					fire:SetKeyValue("firesize", 36)
					fire:SetKeyValue("fireattack", .01)
					fire:SetKeyValue("ignitionpoint", 6)
					fire:SetKeyValue("damagescale", 25)
					fire:Fire("AddOutput", "OnExtinguished !self,Kill", 0)
					fire:SetKeyValue("spawnflags", (IsValid(tr.Entity) and 16 or 0) + 34 + 256)
					fire:SetPos(tr.HitPos)
					fire:Spawn()
					fire:SetPhysicsAttacker(slasher)
 					if IsValid(tr.Entity) then
					  fire:SetParent(tr.Entity)
					end

 					--SafeRemoveEntity(fire)
					SafeRemoveEntityDelayed(fire, 30)
					PostalDudeFuelControl(slasher, -1)
				end
			end
		end
	end)

	-- Ignite players who step into the fire
	hook.Add("EntityTakeDamage", "PlayerIgnite", function(target, dmginfo)
		if not target:IsPlayer() then return end
		if target:Team() == TEAM_SLASHER then return end

		local attacker = dmginfo:GetAttacker()
		if not IsValid(attacker) then return end

		if attacker:GetClass() == "env_fire" and attacker:GetNWBool("PostalFire") then
			if not target:IsOnFire() then
				target:Ignite(3.5) -- Don't make it too long, fire damage is crayzee
			end
		end
	end)
end

function SLASHER.OnSecondaryFire(slasher)
	-- We have to do the Gas Can first
	if slasher:GetNWBool("SwitchToGas") then
		local match = ents.Create("prop_physics")
		local heat = ents.Create("env_firesource")
		local att = slasher.Hand or slasher:LookupAttachment("anim_attachment_lh")
		local phys = match:GetPhysicsObject()
		local particle = ents.Create("info_particle_system")
		local tr = util.TraceLine{
			start = slasher:GetShootPos(),
			endpos = slasher:GetShootPos() + slasher:GetAimVector() * 512,
			filter = {match, heat, slasher, particle},
		}

		slasher:SlasherHudFunc("ShakeControl", "RMB")

		if CLIENT then return end

		SlashCo.AudioSystem.PlaySound({
			soundPath = "weapons/slam/throw.wav",
			identifier = "ThrowMatch",
			minDistance = 250,
			maxDistance = 500,
			entity = slasher,
			volume = 1.0,
			fadeIn = 0,
		})

		match = ents.Create("prop_physics")
		match:SetModel("models/props_debris/wood_splinters01a.mdl")
		match:SetOwner(slasher)
		match:SetSolid(SOLID_NONE)

		if slasher.Hand == -1 then
			att = slasher:GetAttachment(slasher.Hand)
			match:SetPos(att.Pos)
		else
			match:SetPos(slasher:GetShootPos())
		end

		match:Spawn()
		heat:SetPos(match:GetPos())
		heat:SetParent(match)
		heat:SetLocalPos(Vector(-.012, -.163, 3.065))
		heat:SetKeyValue("fireradius", 36)
		heat:SetKeyValue("firedamage", 50)
		heat:Spawn()
		heat:Input("Enable")
		phys = match:GetPhysicsObject()

		tr = util.TraceLine{
			start = slasher:GetShootPos(),
			endpos = slasher:GetShootPos() + slasher:GetAimVector() * 512,
			filter = {match, heat, slasher, particle},
		}

		particle = ents.Create("info_particle_system")
		particle:SetKeyValue("start_active", 1)
		particle:SetKeyValue("effect_name", "fire_verysmall_01")
		particle:Spawn()
		particle:SetPos(match:GetPos())
		particle:SetParent(match)
		particle:SetLocalPos(Vector(-.012, -.163, 3.065))
		particle:Activate()

		if IsValid(phys) then
			phys:SetVelocity((tr.HitPos - match:GetPos()):GetNormal() * 128 * phys:GetMass())
		end

		SafeRemoveEntityDelayed(match, 2.5)

		return
	end

	if slasher:GetNWBool("InSlasherChaseMode") then
		SlashCo.StopChase(slasher)
		return
	end

	SlashCo.StartChaseMode(slasher)
end

local function KickFinish(slasher)
	if not IsValid(slasher) then return end

	slasher:SlasherHudFunc("ShakeControl", "R")

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/postaldude/dude_foot_fire.ogg",
		identifier = "PostalKick",
		minDistance = 500,
		maxDistance = 750,
		entity = slasher,
		volume = 1.0,
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
	local damage = 10

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

	local lookent = slasher:GetEyeTrace().Entity
	if slasher:GetNWInt("PostalStage") == POSTAL_RAGE_STAGE then
		SlashCo.BustDoor(slasher, lookent, 50000)
	else
		slasher:SlamDoor(lookent)

		if lookent:IsPlayer() then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/foot_kickbody.ogg",
				identifier = "SurvivorKickDude",
				minDistance = 600,
				maxDistance = 800,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})
		elseif IsValid(lookent) then
			if lookent:GetClass() ~= "prop_door_rotating" then return end

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_foot_kickdoor.ogg",
				identifier = "PostalKickDoor",
				minDistance = 500,
				maxDistance = 750,
				entity = slasher,
				volume = 1.0,
				fadeIn = 0,
			})
		end
	end

	slasher:SetNWBool("PostalDudeKicking", false)

	if target:IsPlayer() then
		if target:Team() ~= TEAM_SURVIVOR then return end

		if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then
			if not slasher:GetNWBool("InSlasherChaseMode") then
				if not slasher:GetNWBool("SwitchToGas") then
					SlashCo.StartChaseMode(slasher, true)
					slasher:SetNWBool("InSlasherChaseMode", true)
				end
			end
		end

		local vPoint = target:GetPos() + Vector(0, 0, 50)
		local bloodfx = EffectData()
		bloodfx:SetOrigin(vPoint)
		util.Effect("BloodImpact", bloodfx)

		if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then
			if target:IsPlayer() then
				SlashCo.AddSlasherAnger(slasher, SLASHER.PatienceDecrease)
			end
		end
	end
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher:GetNWBool("PostalDudeStunned") then return end
	if slasher:GetNWBool("PostalDudeSlashing") then return end
	if slasher.KickCooldown > 0 then return end

	slasher:SetNWBool("PostalDudeKicking", true)

	if slasher:GetNWInt("PostalStage") ~= POSTAL_RAGE_STAGE then
		slasher.KickCooldown = 5
	else
		slasher.KickCooldown = 2.5
	end

	timer.Create(slasher:EntIndex() .. "PostalDudeKick", 0.1, 1, function()
		KickFinish(slasher)
	end)
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if slasher:GetNWBool("PostalDudeStunned") then return end
	if slasher:GetNWBool("PostalDudeSlashing") then return end
	if slasher:GetNWBool("SwitchToGas") then return end
	if slasher:GetNWBool("SwitchToBaby") then return end

	if slasher:GetNWBool("SwitchToShovel") then
		if not slasher:GetNWBool("DeagleUnlocked") then return end
		slasher:SetNWBool("SwitchToShovel", false)
		slasher:SetNWBool("SwitchToDeagle", true)
		slasher.PostalState = POSTAL_SHOVEL_EQUIPPED

		if slasher:GetNWBool("SwitchToDeagle") then
			slasher:SetBodygroup(1, 0)
			slasher:SetBodygroup(2, 1)
			slasher:SetBodygroup(3, 0)
			slasher:SetBodygroup(4, 0)

			if not slasher:GetNWBool("MGUnlocked") then
				slasher.PostalState = POSTAL_DEAGLE_UNEQUIPPED
			elseif slasher:GetNWBool("MGUnlocked") then
				slasher.PostalState = POSTAL_DEAGLE_EQUIPPED
			end

			local idx = math.random(1, 3)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_deagle" .. idx .. ".ogg",
				identifier = "PostalDeagleEquip" .. idx,
				minDistance = 500,
				maxDistance = 750,
				entity = slasher,
				volume = 0.8,
				fadeIn = 0,
			})
			return
		end
	end

	if slasher:GetNWBool("SwitchToDeagle") then
		if not slasher:GetNWBool("DeagleUnlocked") then return end
		slasher:SetNWBool("SwitchToDeagle", false)
		slasher:SetNWBool("SwitchToShovel", false)
		if not slasher:GetNWBool("MGUnlocked") then
			slasher.PostalState = POSTAL_DEAGLE_UNEQUIPPED
		elseif slasher:GetNWBool("MGUnlocked") then
			slasher.PostalState = POSTAL_DEAGLE_EQUIPPED
		end
		if slasher:GetNWBool("MGUnlocked") then
			slasher:SetNWBool("SwitchToMG", true)

			local idx = math.random(1, 3)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/postaldude/dude_machinegun" .. idx .. ".ogg",
				identifier = "PostalM4Equip" .. idx,
				minDistance = 500,
				maxDistance = 750,
				entity = slasher,
				volume = 0.8,
				fadeIn = 0,
			})
		else
			slasher:SetNWBool("SwitchToShovel", true)
			slasher.PostalState = POSTAL_SHOVEL_EQUIPPED
			slasher:SetBodygroup(1, 1)
			slasher:SetBodygroup(2, 0)
			slasher:SetBodygroup(3, 0)
			slasher:SetBodygroup(4, 0)
		end

		if slasher:GetNWBool("SwitchToMG") then
			slasher.PostalState = POSTAL_MG_EQUIPPED
			slasher:SetBodygroup(1, 0)
			slasher:SetBodygroup(2, 0)
			slasher:SetBodygroup(3, 1)
			slasher:SetBodygroup(4, 0)

			return
		end
	end

	if slasher:GetNWBool("SwitchToMG") then
		slasher:SetNWBool("SwitchToDeagle", false)
		slasher:SetNWBool("SwitchToMG", false)
		slasher:SetNWBool("SwitchToShovel", true)
		slasher.PostalState = POSTAL_MG_EQUIPPED

		if slasher:GetNWBool("SwitchToShovel") then
			slasher.PostalState = POSTAL_SHOVEL_EQUIPPED
			slasher:SetBodygroup(1, 1)
			slasher:SetBodygroup(2, 0)
			slasher:SetBodygroup(3, 0)
			slasher:SetBodygroup(4, 0)
			return
		end
	end
end

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 5)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_footstep" .. idx .. ".ogg",
			identifier = "PostalFootstep" .. idx,
			group = "SlasherFootstep",
			minDistance = 150,
			maxDistance = 500,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end

	return true
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("PostalDudeStunned")
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local PostalDude_swing = ply:GetNWBool("PostalDudeSlashing")
	local PostalDude_kick = ply:GetNWBool("PostalDudeKicking")
	local PostalDude_crouch = ply:GetNWBool("PostalDudeCrouch")
	local PostalDude_stun = ply:GetNWBool("PostalDudeStunned")
	local PostalDude_finger = ply:GetNWBool("PostalFinger")
	local PostalDude_deagleshooting = (CurTime() - ply:GetNWFloat("PostalDeagleShoot", 0)) < SLASHER.GunShotDecay
	local PostalDude_machinegunshooting = (CurTime() - ply:GetNWFloat("PostalMGShoot", 0)) < SLASHER.GunShotDecay

	if not PostalDude_swing and not PostalDude_crouch and not PostalDude_stun and not PostalDude_deagleshooting and not PostalDude_kick and not PostalDude_finger then
		ply.anim_antispam = false
	end

	local ang = ply:EyeAngles()
	local yaw = math.AngleDifference(ang.yaw, ply:GetAngles().yaw)

	ply:SetPoseParameter("body_pitch", -ang.pitch)
	ply:SetPoseParameter("body_yaw", yaw)
	ply:SetPoseParameter("move_x", ply:GetVelocity().X / SLASHER.ProwlSpeed)
	ply:SetPoseParameter("move_y", ply:GetVelocity().Y / SLASHER.ProwlSpeed)

	if ply:IsOnGround() then
		if not chase then
			if ply:GetNWBool("SwitchToShovel") then
				ply.CalcIdeal = ACT_HL2MP_WALK_MELEE
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			elseif ply:GetNWBool("SwitchToDeagle") then
				ply.CalcIdeal = ACT_HL2MP_WALK_PISTOL
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			elseif ply:GetNWBool("SwitchToMG") then
				ply.CalcIdeal = ACT_HL2MP_WALK_SMG1
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			elseif ply:GetNWBool("SwitchToGas") then
				ply.CalcIdeal = ACT_HL2MP_WALK_SLAM
				ply.CalcSeqOverride = ply:LookupSequence("prowl")
			end
		else
			if ply:GetNWBool("SwitchToShovel") then
				ply.CalcIdeal = ACT_HL2MP_RUN_MELEE
				ply.CalcSeqOverride = ply:LookupSequence("chase")
			elseif ply:GetNWBool("SwitchToDeagle") then
				ply.CalcIdeal = ACT_HL2MP_RUN_PISTOL
				ply.CalcSeqOverride = ply:LookupSequence("chase")
			elseif ply:GetNWBool("SwitchToMG") then
				ply.CalcIdeal = ACT_HL2MP_RUN_SMG1
				ply.CalcSeqOverride = ply:LookupSequence("chase")
			elseif ply:GetNWBool("SwitchToGas") then
				ply.CalcIdeal = ACT_HL2MP_RUN_SLAM
				ply.CalcSeqOverride = ply:LookupSequence("chase")
			end
		end
	else
		if ply:GetNWBool("SwitchToShovel") then
			ply.CalcSeqOverride = ply:LookupSequence("shovel_glide")
		elseif ply:GetNWBool("SwitchToDeagle") then
			ply.CalcSeqOverride = ply:LookupSequence("deagle_glide")
		elseif ply:GetNWBool("SwitchToMG") then
			ply.CalcSeqOverride = ply:LookupSequence("m4_airwalk_MELEE")
		elseif ply:GetNWBool("SwitchToGas") then
			ply.CalcSeqOverride = ply:LookupSequence("gas_glide")
		end
	end

	if ply:GetNWBool("SwitchToShovel") then
		if PostalDude_swing then
			local randomswing = math.random(1, 2)
			if randomswing == 1 then
				ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("shovel_swing_1"), 0, true)
			else
				ply:AddVCDSequenceToGestureSlot(2, ply:LookupSequence("shovel_swing_2"), 0, true)
			end
		end
	end

	if ply:GetNWBool("SwitchToDeagle") then
		if PostalDude_deagleshooting then
			ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("deagle_attack"), 0, true)
		end
	end

	if ply:GetNWBool("SwitchToMG") then
		if PostalDude_machinegunshooting then
			ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("m4_attack"), 0, true)
		end
	end

	-- Secret Emote, the code has to be like this...for some reason, I don't know why, but if it works, it works
	if ply:GetNWBool("PostalFinger") then
		timer.Simple(0.01, function()
			if not IsValid(ply) then return end

			if ply:GetNWBool("SwitchToShovel") then
				ply.CalcSeqOverride = ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("fuckyou_1"), 0, true)
			elseif ply:GetNWBool("SwitchToDeagle") then
				ply.CalcSeqOverride = ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("fuckyou_2"), 0, true)
			elseif ply:GetNWBool("SwitchToMG") then
				ply.CalcSeqOverride = ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("fuckyou_3"), 0, true)
			elseif ply:GetNWBool("SwitchToGas") then
				ply.CalcSeqOverride = ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("fuckyou_4"), 0, true)
			end
		end)

		timer.Simple(0.05, function()
			if not IsValid(ply) then return end

			ply:SetNWBool("PostalFinger", false)
		end)
	end

	if PostalDude_crouch then
		local CrouchAnim = "shovel_crouch"
		ply.CalcSeqOverride = ply:LookupSequence(CrouchAnim)

		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if PostalDude_stun then
		ply.CalcSeqOverride = ply:LookupSequence("stun")

		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if PostalDude_kick then
		ply:AddVCDSequenceToGestureSlot(1, ply:LookupSequence("kick"), 0, true)
	end

	-- Postal Dude's Emote
	-- We can't actually play the animations through this hook, otherwise only Postal Dude will be able to see it, and no one else
	hook.Add("PlayerButtonDown", "PostalBird", function(ply, button)
		if button ~= KEY_1 then return end
		if CLIENT then return end

		if not IsFirstTimePredicted() or ply:Team() ~= TEAM_SLASHER then return end
		if ply:GetNWString("Slasher") ~= "PostalDude" then return end

		timer.Simple(0.01, function()
			if not IsValid(ply) then return end

			ply:SetNWBool("PostalFinger", true)
		end)

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/ping_item.mp3",
			identifier = "EmotePing",
			minDistance = 100,
			maxDistance = 110,
			entity = ply,
			volume = 0.4,
			fadeIn = 0,
		})

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_finger.ogg",
			identifier = "PostalBird",
			minDistance = 1000,
			maxDistance = 1200,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end)

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.OnHitByPocketSand(slasher, ply, additionalRage)
	SlashCo.StopChase(slasher)
	slasher:SetBodygroup(1, 0)		-- Disable bodygroups
	slasher:SetBodygroup(2, 0)
	slasher:SetBodygroup(3, 0)
	slasher:SetBodygroup(4, 0)

	local idx = math.random(1, 3)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/postaldude/dude_stunned" .. idx .. ".ogg",
		identifier = "PostalDudeBlinded" .. idx,
		minDistance = 1000,
		maxDistance = 2000,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	slasher:SetNWBool("PostalDudeStunned", true)
	slasher:Freeze(true)

	SlashCo.AddSlasherAnger(slasher, 5) -- We did not like that
	timer.Simple(8, function()
		if not IsValid(slasher) then return end

		-- Re-enable the respective bodygroups
		if slasher:GetNWBool("SwitchToShovel") then
			slasher:SetBodygroup(1, 1)
		elseif slasher:GetNWBool("SwitchToDeagle") then
			slasher:SetBodygroup(2, 1)
		elseif slasher:GetNWBool("SwitchToMG") then
			slasher:SetBodygroup(3, 1)
		elseif slasher:GetNWBool("SwitchToGas") then
			slasher:SetBodygroup(4, 1)
		end
		slasher:SetNWBool("PostalDudeStunned", false)
		slasher:Freeze(false)
	end)
end
SLASHER.OnHitByBeerKeg = function(slasher) SLASHER.OnHitByPocketSand(slasher, nil, 5) end -- +5 additioal anger just because it deafened us.
SLASHER.OnHitByTeslaCoil = function(slasher) SLASHER.OnHitByPocketSand(slasher, nil, 10) end

-- This is cancer
function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/postaldude"))
	hud:SetTitle("Postal Dude")
	hud:SetCrosshairEnabled(true)
	hud:SetCrosshairAlpha(255)
	hud:SetCrosshairSpin(0)
	hud:SetCrosshairTighten(0)
	hud:SetCrosshairProngs(15)

	hud:ChaseAndKill(nil, true)

	hud:AddMeter("patience", 100, "", nil, true)
	hud:TieMeterInt("patience", "PostalDudePatience")

	GameData.LocalPlayer:GetNWInt("PostalState", -1) -- Raphael my goat once again

	hud.prevState = not GameData.LocalPlayer:GetNWInt("PostalState")
	function hud.AlsoThink()
		local curState = GameData.LocalPlayer:GetNWInt("PostalState")

		if curState == hud.prevState then return end

		if curState == -1 then
			hud:RemoveControls()
			hud:SetMeterVisible("fuel", false)
			hud:AddControl("LMB", "shovel bash", Material("slashco/ui/icons/slasher/postaldude_shovel"))
			hud:ChaseAndKill(nil, true)
			hud:TieControl("LMB", "PostalDudeCanMainSlash")
			hud:TieControlText("LMB", "SwitchToShovel", "shovel bash", "shoot", true)
		end

		if curState == POSTAL_SHOVEL_EQUIPPED then
			hud:RemoveControls()
			hud:SetMeterVisible("fuel", false)
			hud:SetMeterVisible("deagle ammo", false)
			hud:SetMeterVisible("m4 ammo", false)
			hud:AddControl("F", "shovel", Material("slashco/ui/icons/slasher/postaldude_deagle"))
			hud:AddControl("LMB", "shovel bash", Material("slashco/ui/icons/slasher/postaldude_shovel"))
			hud:TieControlText("LMB", "SwitchToShovel", "shovel bash", "shoot", true)
			hud:TieControlText("F", "SwitchToDeagle", "shovel", "deagle", true)
			hud:TieControl("LMB", "PostalDudeCanMainSlash")
			hud:ChaseAndKill(nil, true)
		elseif curState == POSTAL_DEAGLE_UNEQUIPPED then
			hud:RemoveControls()
			hud:AddControl("F", "shovel", Material("slashco/ui/icons/slasher/postaldude_shovel"))
			hud:AddControl("LMB", "shoot", Material("slashco/ui/icons/slasher/sid_a3"))
			hud:AddMeter("deagle ammo", 6, "", nil, true)
			hud:SetMeterVisible("deagle ammo", true)
			hud:SetMeterVisible("fuel", false)
			hud:TieMeterInt("deagle ammo", "DeagleBulletsAmount")
			hud:TieControl("LMB", "PostalDudeCanMainSlash")
			hud:ChaseAndKill(nil, true)
		elseif curState == POSTAL_DEAGLE_EQUIPPED then
			hud:RemoveControls()
			hud:AddControl("F", "m4", Material("slashco/ui/icons/slasher/postaldude_m4"))
			hud:AddControl("LMB", "shoot", Material("slashco/ui/icons/slasher/sid_a3"))
			hud:SetMeterVisible("fuel", false)
			hud:SetMeterVisible("deagle ammo", false)
			hud:SetMeterVisible("m4 ammo", false)
			hud:AddMeter("deagle ammo", 6, "", nil, true)
			hud:TieMeterInt("deagle ammo", "DeagleBulletsAmount")
			hud:TieControl("LMB", "PostalDudeCanMainSlash")
			hud:ChaseAndKill(nil, true)
		elseif curState == POSTAL_MG_EQUIPPED then
			hud:RemoveControls()
			hud:SetMeterVisible("fuel", false)
			hud:AddControl("F", "shovel", Material("slashco/ui/icons/slasher/postaldude_shovel"))
			hud:AddControl("LMB", "shoot", Material("slashco/ui/icons/slasher/sid_a3"))
			hud:SetMeterVisible("deagle ammo", false)
			hud:AddMeter("m4 ammo", 20, "", nil, true)
			hud:TieMeterInt("m4 ammo", "MGBulletsAmount")
			hud:SetMeterVisible("m4 ammo", true)
			hud:ChaseAndKill(nil, true)
		elseif curState == POSTAL_GAS_EQUIPPED then
			hud:RemoveControls()
			hud:AddMeter("fuel", 30, "", nil, true)
			hud:TieMeterInt("fuel", "PostalDudeFuelAmount")
			hud:AddControl("RMB", " ignite", Material("slashco/ui/icons/slasher/postaldude_ignite"))
			hud:AddControl("LMB", "pour", Material("slashco/ui/icons/slasher/postaldude_gas"))

			hud:SetMeterVisible("deagle ammo", false)
			hud:SetMeterVisible("m4 ammo", false)
		end

		hud:AddControl("R", "kick", Material("slashco/ui/icons/slasher/kick"))
		hud:TieControl("R", "PostalDudeCanMainKick")
		hud:TieControl("LMB", "PostalDudeCanMainSlash")

		hud.prevState = curState
	end
end

-- Stage 4 "chase" light since the slasher isn't actually chasing
if CLIENT then
	hook.Add("Tick", "SlasherChaseLight", function()
		for _, dude in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if dude == GameData.LocalPlayer then return end

			if SlashCoSlashers[dude:GetNWString("Slasher")] == SLASHER then
				if dude:GetNWInt("PostalStage") == POSTAL_RAGE_STAGE then
					local tlight = DynamicLight(MAX_EDICT + dude:EntIndex())
					if tlight then
						tlight.pos = dude:LocalToWorld(Vector(0, 0, 20))
						tlight.r = 255
						tlight.g = 0
						tlight.b = 0
						tlight.brightness = 6
						tlight.Decay = 1000
						tlight.Size = 500
						tlight.DieTime = CurTime() + 1
					end
				end
			end
		end
	end)
end

-- Postal Dude's ammo should be outlined, he relies on it
function SLASHER.PreDrawHalos()
	SlashCo.DrawHalo(ents.FindByClass("sc_postalammo"), nil)
end

-- Fun stuff
-- This is the CLIENT example (Thank you Raphael)
hook.Add("SlashCo:OnPing", "PostalDudeSayStuff", function(pingInfo)
	if pingInfo.Team ~= TEAM_SLASHER then return end
	if not pingInfo.Player then return end -- it can be nil!
	if CLIENT then return end

	-- pingInfo.Player is the entIndex since when a player may not always be known to a client.
	-- Had to update the code a little bit because ping handling got changed a bit - eno
	local ply = pingInfo.Player

	-- Check isnumber for validity
	if isnumber(ply) then
		ply = Entity(ply)
	end

	-- Nope, go away
	if not IsValid(ply) then return end

	-- Can be any slasher ID
	if ply:GetNWString("Slasher") ~= "PostalDude" then return end

	--It's our slasher so play a sound
	if pingInfo.Type == "GENERATOR" or pingInfo.Type == "ITEM" or pingInfo.Type == "AMMO" then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_pingitemorgen" .. idx .. ".ogg",
			identifier = "PostalPingMisc" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = ply,
			volume = 1.5,
			fadeIn = 0,
		})
	elseif pingInfo.Type == "SURVIVOR" then
		local idx = math.random(1, 4)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_pingsurvivor" .. idx .. ".ogg",
			identifier = "PostalPingSurvivor" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = ply,
			volume = 1.5,
			fadeIn = 0,
		})
	elseif pingInfo.Type == "LOOK HERE" then
		local idx = math.random(1, 4)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_pinghere" .. idx .. ".ogg",
			identifier = "PostalPingHere" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = ply,
			volume = 1.5,
			fadeIn = 0,
		})
	elseif pingInfo.Type == "SLASHER" then
		local idx = math.random(1, 2)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_pingslasher" .. idx .. ".ogg",
			identifier = "PostalPingSlasher" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = ply,
			volume = 1.5,
			fadeIn = 0,
		})
	elseif pingInfo.Type == "DEAD BODY" then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_pingbody" .. idx .. ".ogg",
			identifier = "PostalPingDeadBody" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = ply,
			volume = 1.5,
			fadeIn = 0,
		})
	elseif pingInfo.Type == "HELICOPTER" then
		local idx = math.random(1, 4)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/postaldude/dude_pingchopper" .. idx .. ".ogg",
			identifier = "PostalPingChopper" .. idx,
			minDistance = 500,
			maxDistance = 750,
			entity = ply,
			volume = 1.5,
			fadeIn = 0,
		})
	end

	return true -- true so that the gamemode doesn't try to also play any sounds
end)

SlashCo.RegisterSlasher(SLASHER, "PostalDude")