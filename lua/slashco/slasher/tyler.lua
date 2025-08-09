local SLASHER = {}

SLASHER.Name = "Tyler"
SLASHER.Aliases = {
	"Tyler The Creator",
	"Tyler The Destroyer",
}
SLASHER.ID = 7
SLASHER.Class = SlashCo.SlasherClass.Demon
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/tyler/tyler.mdl"
SLASHER.GasCanMod = -6
SLASHER.KillDelay = 4
SLASHER.ProwlSpeed = 300
SLASHER.ChaseSpeed = 580
SLASHER.Perception = 0.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 200
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 1
SLASHER.MinEffectRadius = 500 -- Mimimum distance for HUD effects
SLASHER.MaxEffectRadius = 1500 -- Maximum distance for HUD effects
SLASHER.ChaseDuration = 0.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/tyler/tyler_kill.mp3"
SLASHER.Description = "Tyler_desc"
SLASHER.ProTip = "Tyler_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★☆☆☆☆"
SLASHER.DiffRating = "★★★★☆"
SLASHER.CannotBeSpectated = true
SLASHER.AngerIncrease = 10 -- Anger increase of objectives being completed & every time he gives out a fuel can.
SLASHER.AngerPassiveGain = 0
SLASHER.AngerChaseGain = 0
SLASHER.MinChase = 20 -- Number of seconds that are the minimum for a chase
SLASHER.MinTylerTime = 5 -- Number of seconds he has to be at minimum as tyler the creator.
SLASHER.AllowEndlessChase = false -- If true, tyler will enter a endless chase once a round has reached the slow escape mark.
SLASHER.CustomBackgroundMusic = true -- Tyler has his own background music.
SLASHER.DisableHelicopterMusic = true
SLASHER.HelicopterArriveTime = 30 -- We don't want Tyler to be able to kill everyone while they have to wait 2 minutes just for the Helicopter to arrive.
SLASHER.SpawnDelay = 10 -- We don't need to let Tyler wait much, why? because players depend on Tyler.
SLASHER.AudioRangeDecreasePerGasCan = 0.1 -- For every gas can he created, the range of his audio is decreased by this much. (This value is used for multiplication!)
SLASHER.MinimumAudioRange = 250 -- The minimum range that he is required to have.
SLASHER.TimeAsSpecter = 30 -- How long he can stay as specter
SLASHER.TimeAddedForPlayerKill = 180 -- if he kills a player, we add this amount of time to his TimeAsTylerForm
SLASHER.ItemPriceDivisionMultiplier = 2 -- We use this multiplier when converting the item price to the time that is added to TimeAsTylerForm

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	SLASHER.ProwlSpeed = 300 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 580 + (7.5 * additionalSurvivors)
	SLASHER.TimeAsSpecter = 30 + additionalSurvivors
	SLASHER.ItemPriceDivisionMultiplier = 2 + math.Clamp(additionalSurvivors / 10, 0, 3)
	SLASHER.TimeAddedForPlayerKill = 180 - (10 * additionalSurvivors)

	SLASHER.MinTylerTime = math.Clamp(5 + (-0.5 * additionalSurvivors), 2, 30)
end

local function EndlessChase()
	return (SLASHER.AllowEndlessChase and SlashCo.IsSlowEscape()) or SlashCo.CurRound.EscapeHelicopterSummoned -- When the time for a slow escape is reached or the helicopter was summoned, we enter a endless chase
end

-- Enums to use making the code more readable.
local TYLER_SPECTER = 0
local TYLER_CREATOR = 1
local TYLER_PRE_DESTROYER = 2
local TYLER_DESTROYER = 3
local function SwitchForm(slasher, newForm)
	local anger = SlashCo.GetSlasherAnger(slasher)
	if newForm == TYLER_CREATOR and anger > 50 and math.random(1, 200 - anger) == 1 then
		newForm = TYLER_PRE_DESTROYER -- When becoming Creator, he has a random chance to become a destroyer instead if his anger is already above 20.
	end

	if slasher.TylerState == TYLER_DESTROYER then
		SlashCo.AudioSystem.StopSound("TylerTheme", 1)
		SlashCo.AudioSystem.StopSound("TylerWhisper", 1)

		slasher:SetVisible(false)
		slasher:SetNWBool("TylerFlash", false)
		slasher.TimeAsTylerSpecter = 0

		SetGlobal2Bool("DisplayTylerTheDestroyerEffects", false)
	end

	slasher.TylerState = newForm

	slasher.TimeAsTylerSpecter = 0
	slasher.TimeAsTylerForm = 0
	slasher.TylerBlink = 0
	slasher.tyler_destroyer_entrance_antispam = nil

	if newForm == TYLER_CREATOR or newForm == TYLER_SPECTER then
		SLASHER.HideTime(slasher)
		if not SlashCo.AudioSystem.ShouldPlayBackgroundMusic() and slasher.WasDestroyerOnce then -- If its already playing, we don't need to start it again.
			SlashCo.AudioSystem.EnableBackgroundMusic()
			SlashCo.AudioSystem.SetBackgroundMusic("slashco/slasher/tyler/tyler_ambience.ogg", math.Clamp(100 - anger, 0, 100) / 100) -- Make the background music getting more silent the more anger he has.
		end

		slasher:SetNW2Bool("Slasher:NoFootsteps", false)
	else
		slasher.WasDestroyerOnce = true
		SlashCo.AudioSystem.DisableBackgroundMusic()
		if EndlessChase() then
			slasher:SetNW2Bool("Slasher:NoFootsteps", true)
		end
	end
end

function SLASHER.OnSpawn(slasher)
	slasher:SetVisible(false)

	slasher.GasCanCreated = 0
	slasher.TylerState = 0
	slasher.TimeAsTylerForm = 0
	slasher.TimeAsTylerSpecter = 0
	slasher.TylerBlink = 0
	SwitchForm(slasher, TYLER_SPECTER)
end

function SLASHER.Precache()
end

function SLASHER.HideTime(slasher)
	slasher.TylerTime = math.max((25 + SlashCo.MapSize * 25) - ((SlashCo.GetSlasherAnger(slasher) / 3) / SlashCo.MapSize) - team.NumPlayers(TEAM_SURVIVOR), SLASHER.MinTylerTime)
	-- print("Tyler transformation time: " .. slasher.TylerTime)
end

--[[
	Force him to enter pre-destroyer.
	Even if he was already destroyer.
	This causes the right song to play & the survivors get a few more seconds since he goes through the whole pre-destroyer state again.
]]
function SLASHER.OnHelicopterSummon(slasher)
	SlashCo.AudioSystem.StopSound("TylerAlarm", 0.5)
	SlashCo.AudioSystem.StopSound("TylerTheme", 1)
	SlashCo.AudioSystem.StopSound("TylerWhisper", 1)
	SlashCo.AudioSystem.StopSound("TylerSong", 0)
	SwitchForm(slasher, TYLER_PRE_DESTROYER)
end

if CLIENT then
	CreateClientConVar("slashco_tyler_endless_chase_music", "1", true, false, "When 0 the endless chase music is changed to be the normal one", 0, 1)
end

function SLASHER.OnTickBehaviour(slasher)
	local TylerState = slasher.TylerState or 0 --State
	local TimeAsTylerForm = slasher.TimeAsTylerForm or 0 --Time Spent as Creator or destroyer
	local TylerBlink = slasher.TylerBlink or 0 --Destoyer Blink
	local anger = SlashCo.GetSlasherAnger(slasher)
	local endlessChase = EndlessChase()

	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception

	if (TylerState == 0 or TylerState == 1) and endlessChase then
		SwitchForm(slasher, TYLER_PRE_DESTROYER)
		SlashCo.AudioSystem.StopSound("TylerSong", 0)
		slasher.TylerSongPickedID = nil
		SlashCo.AddSlasherAnger(slasher, 100) -- Max it out
		anger = SlashCo.GetSlasherAnger(slasher)
	end

	if TylerState == TYLER_SPECTER then
		--Specter

		slasher.TylerSongPickedID = nil
		slasher:SetNWBool("TylerFlash", false)
		slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
		slasher:SetNWBool("TylerTheCreator", false)
		slasher:SetBodygroup(0, 0)
		slasher.TimeAsTylerForm = 0
		slasher:SetNWBool("CanKill", false)
		slasher:SetImpervious(true)
		slasher.TimeAsTylerSpecter = (slasher.TimeAsTylerSpecter or 0) + FrameTime()
		final_perception = 6.0

		if slasher:IsVisible() then
			slasher:SetVisible(false) -- Just in case he somehow ends up still being visible
		end

		if slasher.TimeAsTylerSpecter > SLASHER.TimeAsSpecter then
			SwitchForm(slasher, TYLER_CREATOR)
			slasher:SetVisible(true)
		end

		slasher.tyler_destroyer_entrance_antispam = nil
	elseif TylerState == TYLER_CREATOR then
		--Creator

		if not slasher:IsVisible() then
			slasher:SetVisible(true) -- Just in case he somehow ends up invisible
		end

		slasher:SetImpervious(false)
		slasher:SetNWBool("TylerFlash", false)
		slasher:SetSlowWalkSpeed(1)
		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:Freeze(true)
		slasher:SetNWBool("TylerTheCreator", true)
		slasher:SetBodygroup(0, 0)
		slasher.TimeAsTylerForm = TimeAsTylerForm + FrameTime()
		slasher:SetNWBool("CanKill", false)
		final_perception = 0.0

		if not slasher:GetNWBool("TylerCreating") and slasher.TylerSongPickedID == nil then
			local rnd = math.random(1, 9)
			slasher.TylerSongPickedID = "slashco/slasher/tyler/tyler_song_" .. rnd .. (rnd <= 6 and ".mp3" or ".ogg")
			SlashCo.AudioSystem.PlaySound({
				soundPath = slasher.TylerSongPickedID,
				identifier = "TylerSong",
				minDistance = math.max((500 + (500 * SlashCo.MapSize)) * (1 - (SLASHER.AudioRangeDecreasePerGasCan * slasher.GasCanCreated)), SLASHER.MinimumAudioRange),
				maxDistance = math.max((1500 + (1000 * SlashCo.MapSize)) * (1 - (SLASHER.AudioRangeDecreasePerGasCan * slasher.GasCanCreated)), SLASHER.MinimumAudioRange * 2),
				looping = true,
				entity = slasher,
				volume = math.max(0.7 - (slasher.GasCanCreated * 0.1), 0.1),
				fadeIn = 1,
			})
			SLASHER.HideTime(slasher)
		end

		if not slasher.TylerTime then
			SLASHER.HideTime(slasher)
		end

		-- We let the background music fade out, this way players know, Tyler is somewhere as the creator, and the players know if he's close to entering destroyer.
		SlashCo.AudioSystem.SetBackgroundMusicVolume(math.Round((math.Clamp(100 - anger, 0, 100) / 100) * math.Clamp(1 - (TimeAsTylerForm / slasher.TylerTime), 0, 1), 3))

		--Time ran out
		if (SLASHER.AllowEndlessChase == false and SlashCo.CurRound.EscapeHelicopterSummoned and TimeAsTylerForm > (slasher.TylerTime / 2.5)) or TimeAsTylerForm > slasher.TylerTime then
			slasher.TylerSongPickedID = nil
			SwitchForm(slasher, TYLER_PRE_DESTROYER)
			SlashCo.AudioSystem.StopSound("TylerSong", 0)
			return
		end

		for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
			--Survivor found tyler

			local surv = team.GetPlayers(TEAM_SURVIVOR)[i]

			if not slasher:GetNWBool("TylerCreating") and surv:GetPos():Distance(slasher:GetPos()) < 400 and surv:GetEyeTrace().Entity == slasher then
				slasher:SetNWBool("TylerCreating", true)
				slasher.TimeAsTylerForm = 0
				slasher.TimeAsTylerSpecter = 0
				slasher.TylerSongPickedID = nil
				timer.Simple(0.5, function()
					if not IsValid(slasher) then
						return
					end
					SlashCo.AudioSystem.StopSound("TylerSong", 0)
				end)
			end
		end

		if slasher:GetNWBool("TylerCreating") and slasher.TylerBlink ~= 1.8 then
			slasher.TylerBlink = 1.8
			slasher.TimeAsTylerForm = 0
			slasher.TimeAsTylerSpecter = 0

			slasher:EmitSound("slashco/slasher/tyler/tyler_create.mp3")

			timer.Simple(3, function()
				if not IsValid(slasher) then
					return
				end

				-- NOTE: We use WorldSpaceCenter so that the gas cans spawn a bit in the air, this stops them from somehow bugging and falling through the floor.
				local startPos = slasher:WorldSpaceCenter()
				local goodPos = startPos + (slasher:GetAimVector() * 50)
				local tr = util.TraceLine({
					start = startPos,
					endpos = goodPos,
					mask = MASK_PLAYERSOLID,
					collisiongroup = COLLISION_GROUP_PLAYER,
					filter = slasher
				})

				if tr.Hit then -- Something is in the way, so we'll change pos
					goodPos = startPos
				end

				SlashCo.CreateGasCan(goodPos, Angle(0, 0, 0)) -- Gasolina en el Pie :eyes:
				SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)
			end)

			timer.Simple(4, function()
				if not IsValid(slasher) then
					return
				end

				slasher:SetNWBool("TylerCreating", false)
				SwitchForm(slasher, TYLER_SPECTER)
				slasher.GasCanCreated = slasher.GasCanCreated + 1
				slasher.TylerBlink = 0
				slasher:Freeze(false)
				slasher:SetVisible(false)
			end)
		end

		slasher.tyler_destroyer_entrance_antispam = nil
	elseif TylerState == TYLER_PRE_DESTROYER then
		--Pre-Destroyer

		slasher.TylerSongPickedID = nil
		slasher:Freeze(true)

		if slasher.tyler_destroyer_entrance_antispam == nil then
			SlashCo.AudioSystem.StopSound("TylerSong", 0)
			SlashCo.AudioSystem.PlaySound({
				soundPath = endlessChase and "slashco/slasher/tyler/tyler_whatsgood_intro.ogg" or "slashco/slasher/tyler/tyler_alarm.ogg",
				fallbackSoundPath = endlessChase and "slashco/slasher/tyler/tyler_alarm.ogg" or nil,
				boundConVar = endlessChase and "slashco_tyler_endless_chase_music" or nil,
				identifier = "TylerAlarm",
				minDistance = 15000,
				maxDistance = 20000,
				looping = true,
				entity = slasher,
				volume = 0.8,
				fadeIn = 1,
			})
			SlashCo.AddSlasherAnger(slasher, 5) -- Add some anger just because he got mad.
			slasher.tyler_destroyer_entrance_antispam = 0
		end

		local decay = anger / 8 -- At longest 12.5 sec
		if slasher.tyler_destroyer_entrance_antispam < (endlessChase and 15.5 or (18 - decay)) then
			slasher.tyler_destroyer_entrance_antispam = slasher.tyler_destroyer_entrance_antispam + FrameTime()
		else
			SlashCo.AudioSystem.StopSound("TylerAlarm", 0.5)

			if anger < 50 then -- switch up songs if his anger is below 50.
				SlashCo.AudioSystem.PlaySound({
					soundPath = "slashco/slasher/tyler/tyler_destroyer_low.ogg",
					identifier = "TylerTheme",
					minDistance = 15000,
					maxDistance = 20000,
					looping = true,
					entity = slasher,
					volume = 0.9,
					fadeIn = 1,
				})
			else
				if endlessChase then
					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/slasher/tyler/tyler_whatsgood.ogg",
						fallbackSoundPath = "slashco/slasher/tyler/tyler_destroyer_theme.mp3",
						boundConVar = "slashco_tyler_endless_chase_music",
						identifier = "TylerTheme",
						minDistance = 15000,
						maxDistance = 20000,
						looping = true,
						entity = slasher,
						volume = 0.6,
						fadeIn = 1,
					})
				else
					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/slasher/tyler/tyler_destroyer_theme.mp3",
						identifier = "TylerTheme",
						minDistance = 15000,
						maxDistance = 20000,
						looping = true,
						entity = slasher,
						volume = 0.8,
						fadeIn = 1,
					})

					SlashCo.AudioSystem.PlaySound({
						soundPath = "slashco/slasher/tyler/tyler_destroyer_whisper.mp3",
						identifier = "TylerWhisper",
						minDistance = 850,
						maxDistance = 1500,
						looping = true,
						entity = slasher,
						volume = 0.8,
						fadeIn = 1,
					})
				end
			end

			slasher:Freeze(false)
			SwitchForm(slasher, TYLER_DESTROYER)

			SetGlobal2Bool("DisplayTylerTheDestroyerEffects", true)
		end

		slasher:SetSlowWalkSpeed(1)
		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetNWBool("TylerTheCreator", false)
		slasher:SetBodygroup(0, 1)
		slasher.TimeAsTylerForm = 0
		slasher:SetNWBool("CanKill", false)
		final_perception = 0.0
	elseif TylerState == TYLER_DESTROYER then
		--Destroyer

		slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed)
		slasher:SetRunSpeed(SLASHER.ChaseSpeed)
		slasher:SetWalkSpeed(SLASHER.ChaseSpeed)
		slasher:SetNWBool("TylerTheCreator", false)
		slasher:SetBodygroup(0, 1)
		slasher.TimeAsTylerForm = TimeAsTylerForm + FrameTime()
		slasher:SetNWBool("CanKill", true)
		final_perception = 2.0

		if TimeAsTylerForm > math.max((((3 + SlashCo.MapSize) / 4) * anger), SLASHER.MinChase) and not endlessChase then
			SwitchForm(slasher, TYLER_SPECTER)
		end
	end

	if TylerState == TYLER_PRE_DESTROYER or TylerState == TYLER_DESTROYER then
		slasher.TylerBlink = TylerBlink + FrameTime()

		if TylerBlink > 0.85 then
			slasher.TylerBlink = 0
		end

		if TylerBlink <= 0.5 then
			slasher:SetVisible(false)
			slasher:SetNWBool("TylerFlash", false)
		else
			slasher:SetVisible(true)
			slasher:SetNWBool("TylerFlash", true)
		end
	end

	if slasher:GetNWInt("TylerState") ~= TylerState then
		slasher:SetNWInt("TylerState", TylerState)
	end

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

local function DestroyItem(slasher, target)
	SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)
	if not IsValid(target) then
		return
	end

	local item = SlashCo.GetItemByEntity(target:GetClass())
	if item and slasher.TylerState == TYLER_DESTROYER then
		local itemTbl = SlashCoItems[item]
		if itemTbl.Price then
			slasher.TimeAsTylerForm = slasher.TimeAsTylerForm + (itemTbl.Price / SLASHER.ItemPriceDivisionMultiplier) -- Half of the item price is added to his time, more expensive items will shorten his time immensely as destroyer.
		end
	end

	local corpse
	if target:IsPlayer() then
		corpse = target.DeadBody
	else
		corpse = target
	end

	if not IsValid(corpse) then
		return
	end

	local dissolver = ents.Create("env_entity_dissolver")
	timer.Simple(2, function()
		if IsValid(dissolver) then
			dissolver:Remove() -- backup edict save on error
		end
	end)

	dissolver.Target = "dissolve" .. corpse:EntIndex()
	dissolver:SetKeyValue("dissolvetype", 0)
	dissolver:SetKeyValue("magnitude", 1)
	dissolver:SetPos(corpse:GetPos())
	dissolver:SetPhysicsAttacker(slasher)
	dissolver:Spawn()

	corpse:SetName(dissolver.Target)
	dissolver:Fire("Dissolve", dissolver.Target, 0)
	dissolver:Fire("Kill", "", 1)
end

local function StopTyperChase(slasher, switchForm)
	if IsValid(slasher) then
		slasher:Freeze(false)
		if not EndlessChase() and switchForm then
			SetGlobal2Bool("DisplayTylerTheDestroyerEffects", false)
			SwitchForm(slasher, TYLER_SPECTER)
		end
	end
end

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher.TylerState ~= TYLER_DESTROYER then
		return
	end

	if slasher:GetNWBool("CanKill") == false then
		return
	end

	if slasher.KillDelayTick > 0 then
		return
	end

	if not IsValid(target) then
		return
	end

	local class = target:GetClass()
	if (not target:IsPlayer() and target.PingType ~= "ITEM") or class == "sc_beacon" or class == "sc_battery" then
		return
	end

	if slasher:GetPos():Distance(target:GetPos()) >= SLASHER.KillDistance or target:GetNWBool("SurvivorBeingJumpscared") then
		return
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = SLASHER.KillSound,
		identifier = "TylerDestroy",
		minDistance = 1500,
		maxDistance = 2000,
		entity = slasher,
		volume = 0.5,
	})

	slasher:Freeze(true)
	slasher.KillDelayTick = SLASHER.KillDelay

	if target:IsPlayer() then
		if target:ItemValue("IsFuel", false, true) then
			SlashCo.DropItem(target, function(_, _, droppedItem)
				if IsValid(droppedItem) then
					droppedItem.DONTPICKUP = true
					DestroyItem(slasher, droppedItem)
				end
				StopTyperChase(slasher, true)
			end, "Unbreakable")
			return
		end

		if target:ItemValue("Price", false, false) then
			SlashCo.DropItem(target, function(_, _, droppedItem)
				if IsValid(droppedItem) then
					droppedItem.DONTPICKUP = true
					DestroyItem(slasher, droppedItem)
				end
				StopTyperChase(slasher, false)
			end, "Unbreakable")
			return
		end
	end

	target:SetNWBool("SurvivorBeingJumpscared", true)
	target:SetNWBool("SurvivorJumpscare_Tyler", true)

	if target:IsPlayer() then
		target:Freeze(true)
	end

	timer.Simple(SLASHER.JumpscareDuration, function()
		StopTyperChase(slasher, IsValid(target) and target:GetClass() == "sc_gascan") -- Only stop instantly, if he destoryed a fuelcan

		if IsValid(target) then
			target:SetNWBool("SurvivorBeingJumpscared", false)
			target:SetNWBool("SurvivorJumpscare_Tyler", false)

			if target:IsPlayer() then
				target:Freeze(false)
				target:TakeDamage(99999, slasher, slasher)

				slasher.TimeAsTylerForm = slasher.TimeAsTylerForm + SLASHER.TimeAddedForPlayerKill
			end

			timer.Simple(FrameTime(), function()
				DestroyItem(slasher, target)
			end)
		end
	end)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher.TylerState ~= 0 then
		return
	end

	if slasher:WaterLevel() > 1 then
		return
	end

	SwitchForm(slasher, TYLER_CREATOR)
	slasher:SetVisible(true)
end

function SLASHER.Animator(ply)
	local tyler_creator = ply:GetNWBool("TylerTheCreator")
	local tyler_creating = ply:GetNWBool("TylerCreating")

	if tyler_creator then
		if not tyler_creating then
			ply.CalcSeqOverride = ply:LookupSequence("creator idle")

			ply.anim_antispam = false
		else
			ply.CalcSeqOverride = ply:LookupSequence("create")
			if ply.anim_antispam == nil or ply.anim_antispam == false then
				ply:SetCycle(0)
				ply.anim_antispam = true
			end
		end
	else
		if ply:GetVelocity():LengthSqr() > 5 then
			ply.CalcSeqOverride = ply:LookupSequence("destroyer walk")
		else
			ply.CalcSeqOverride = ply:LookupSequence("destroyer activated")
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWInt("TylerState") == 1
end

function SLASHER.Footstep()
	return true
end

function SLASHER.CanBeSeen(ply)
	if SERVER then
		return
	end

	if ply:IsVisible() and ply:GetNWInt("TylerState") ~= 1 then
		return true
	end
end

local avatarTable = {
	creator = Material("slashco/ui/icons/slasher/s_7"),
	destroyer = Material("slashco/ui/icons/slasher/s_7_s1")
}

local manifestTable = {
	default = Material("slashco/ui/icons/slasher/s_7_s1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Tyler_creator")

	hud:AddControl("R", "manifest", manifestTable)

	hud:AddControl("LMB", "destroy", manifestTable)
	hud:TieControlVisible("LMB", "CanKill")

	hud.prevState = -1
	hud.destroyEnabled = true
	hud.prevWater = -1
	function hud.AlsoThink()
		local state = GameData.LocalPlayer:GetNWInt("TylerState")
		if state == 0 then
			local isInWater = GameData.LocalPlayer:WaterLevel() > 1
			if hud.prevWater ~= isInWater then
				if isInWater then
					hud:SetControlEnabled("R", false)
				else
					hud:SetControlEnabled("R", true)
				end
			end
		end

		if state ~= hud.prevState then
			if state == 0 then
				hud:SetControlVisible("R", true)
				hud:SetControlText("R", "manifest")
			elseif state == 1 then
				hud:SetControlVisible("R", true)
				hud:SetControlEnabled("R", false)
				hud:SetControlText("R", "(hiding)")
				hud:ShakeControl("R")
			else
				hud:SetControlVisible("R", false)
			end

			if state <= 1 then
				hud:SetTitle("Tyler_creator")
				hud:SetAvatar("creator")
			else
				hud:SetTitle("Tyler_destroyer")
				hud:SetAvatar("destroyer")
			end

			if state == 3 then
				hud:SetCrosshairEnabled(true)
			else
				hud:SetCrosshairAlpha(0)
				timer.Simple(1, function()
					if not IsValid(hud) then return end
					hud:SetCrosshairEnabled(false)
				end)
			end

			hud.prevState = state
		end

		local target = GameData.LocalPlayer:GetEyeTrace().Entity
		local class = IsValid(target) and target:GetClass()
		if IsValid(target) and target:IsPlayer() or (target.PingType == "ITEM" and class ~= "sc_beacon")
				and class ~= "sc_battery" and not target:GetNWBool("SurvivorBeingJumpscared") and
				GameData.LocalPlayer:GetPos():Distance(target:GetPos()) < SLASHER.KillDistance then

			if not hud.destroyEnabled then
				hud:SetControlEnabled("LMB", true)
				hud:ShakeControl("LMB")
				hud:SetCrosshairSpin(50)
				hud:SetCrosshairTighten(4)
				hud:SetCrosshairProngs(5)
				hud:SetCrosshairAlpha(255)
				hud.destroyEnabled = true
			end
		else
			if hud.destroyEnabled then
				hud:SetControlEnabled("LMB", false)
				hud:ShakeControl("LMB")
				hud:SetCrosshairSpin(0)
				hud:SetCrosshairTighten(0)
				hud:SetCrosshairProngs(3)
				hud:SetCrosshairAlpha(0)
				hud.destroyEnabled = nil
			end
		end
	end
end

if CLIENT then
	local eyeball = Material("slashco/ui/particle/eyeball.png")
	local drawIcon
	local iconT = 0
	local iconTL = 0

	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Tyler") == true then
			if GameData.LocalPlayer.tyl_f == nil then
				GameData.LocalPlayer.tyl_f = 0
			end
			GameData.LocalPlayer.tyl_f = GameData.LocalPlayer.tyl_f + (FrameTime() * 20)
			if GameData.LocalPlayer.tyl_f > 39 then
				GameData.LocalPlayer.tyl_f = 25
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_7")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.tyl_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.tyl_f = nil
		end

		if GameData.LocalPlayer:Team() == TEAM_SLASHER then
			return
		end

		if drawIcon and GameData.LocalPlayer:Team() == TEAM_SURVIVOR then
			iconTL = SlashCo.Dampen(7, iconTL, iconT)

			surface.SetMaterial(eyeball)
			surface.SetDrawColor(255, 255 - iconTL / 2, 255 - iconTL / 2, iconTL)
			surface.DrawTexturedRect(ScrW() / 32, ScrW() / 32, ScrW() / 16, ScrW() / 16)
		end

		if GetGlobal2Bool("DisplayTylerTheDestroyerEffects", false) then
			local effectScale = 0
			local localPos = GameData.LocalPlayer:GetPos()
			for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
				if slasher:GetNWString("Slasher") == SLASHER.Name then
					local pos = slasher:GetPos()
					local dist = pos:Distance(localPos)
					if dist > SLASHER.MaxEffectRadius then continue end

					local scale = 1 - (dist - SLASHER.MinEffectRadius) / (SLASHER.MaxEffectRadius - SLASHER.MinEffectRadius)
					if scale > effectScale then
						effectScale = scale
					end

					if not slasher:IsDormant() then -- Play the shake every time he's visible.
						util.ScreenShake(slasher:GetPos(), 10 * scale, 40, 1, SLASHER.MaxEffectRadius, true)
					end
				end
			end

			local Overlay = Material("slashco/ui/overlays/tyler_static")
			local DestroyerFace = Material("slashco/ui/overlays/tyler_destroyer_face")

			Overlay:SetFloat("$alpha", math.Rand(0.1, 0.12) * effectScale)
			DestroyerFace:SetFloat("$alpha", math.Rand(0, 0.07) * effectScale)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(DestroyerFace)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Tyler")