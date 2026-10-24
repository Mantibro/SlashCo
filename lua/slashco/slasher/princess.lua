local SLASHER = {}

SLASHER.Name = "Princess"
SLASHER.Aliases = {
	"Cupcake",
	"Satan Death Destroyer",
}
SLASHER.Class = SlashCo.SlasherClass.Demon
SLASHER.DangerLevel = SlashCo.DangerLevel.Moderate
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/princess/princess.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 280
SLASHER.Perception = 1.0
SLASHER.Eyesight = 2
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 1400
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = "slashco/slasher/princess/princess_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Princess_desc"
SLASHER.ProTip = "Princess_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★☆☆☆"
SLASHER.ItemToSpawn = "Baby"
SLASHER.MaulForward = 800 -- Force to apply forward when Princess maul.
SLASHER.MaulingSpeed = 30 -- Speed when dragging a survivor.
SLASHER.AngerIncrease = 5
SLASHER.AngerPassiveGain = 0.04
SLASHER.AngerChaseGain = 0

local function PlayChase(slasher)
	local idx = math.random(1, 15)

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/princess/princess_chase" .. idx .. ".mp3",
		identifier = "PrincessChase" .. idx,
		minDistance = 200,
		maxDistance = 1200,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
end

local function PlayIdle(slasher)
	local idx = math.random(1, 9)

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/princess/princess_idle" .. idx .. ".mp3",
		identifier = "PrincessIdle" .. idx,
		minDistance = 200,
		maxDistance = 1200,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
end

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	SLASHER.ChaseDuration = 10.0 + (1 * additionalSurvivors)

	if additionalSurvivors > 0 then -- Only increase these if we have more than the default survivors.
		SLASHER.MaulingSpeed = 30 + (5 * additionalSurvivors)
		SLASHER.MaulForward = 800 + (5 * additionalSurvivors)
		SLASHER.ChaseSpeed = 280 + (2 * additionalSurvivors)
		SLASHER.ProwlSpeed = 150 + (3 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	slasher:SetViewOffset(Vector(0, 0, 50))
	slasher:SetCurrentViewOffset(Vector(0, 0, 50))

	slasher.AggressionThreshold = 50
	slasher.Aggression = 0
	slasher.PrincessCanMaul = true
	slasher.MaulBonus = 0
	slasher:SetNW2Float("PrincessAggressionChase", 0)

	SLASHER.DoSound(slasher)
end

function SLASHER.GetSpeed(slasher)
	if slasher:GetNW2Bool("PrincessDraggingSurvivor") then
		return SLASHER.MaulingSpeed
	end

	if slasher:GetInSlasherChaseMode() then
		return SLASHER.ChaseSpeed + (slasher:GetNW2Float("PrincessAggressionChase") / 5)
	end
end

function SLASHER.OnPredictedTick(slasher)
	local AggressionFloat = slasher:GetNW2Float("PrincessAggressionChase") --chase speed increase
	local AggressionAmount = slasher:GetNW2Int("PrincessAggression")
	slasher:SetNW2Float("PrincessAggressionChase", AggressionFloat + (1 * AggressionAmount))
end

function SLASHER.DoSound(slasher)
	if SlashCo.State ~= SlashCo.States.IN_GAME then return end -- RaphaelIT7: Before/After a game you should shut up! >:(
	if not slasher:GetNW2Bool("PrincessMaulingChild") and not slasher:GetNW2Bool("PrincessMaulingBase") and not slasher:GetNW2Bool("PrincessMaulingSurvivor") and not slasher:GetNW2Bool("PrincessSniffing") then
		if slasher:GetInSlasherChaseMode() then
			PlayChase(slasher)
		else
			PlayIdle(slasher)
		end
	end

	timer.Create("PrincessSound", 2, 1, function()
		if not IsValid(slasher) or slasher:GetNW2String("Slasher") ~= "Princess" then
			timer.Remove("PrincessSound")
			return
		end

		SLASHER.DoSound(slasher)
	end)
end

function SLASHER.OnTickBehaviour(slasher)
	local Aggression = slasher.Aggression or 0 --aggression
	local AggressionTH = slasher.AggressionThreshold or 0 --aggression threshold

	local eyesight = SLASHER.Eyesight
	local perception = SLASHER.Perception

	if not slasher:GetDemonPacified() then
		slasher:SetCanChase(true)
	else
		slasher:SetCanChase(false)
		eyesight = 0
		perception = 0
	end

	--find children to maul
	for _, v in ipairs(ents.FindByClass("sc_baby")) do
		if v:GetPos():Distance(slasher:GetPos()) < 100 and not slasher:GetNW2Bool("PrincessMaulingBase") and not slasher:GetNW2Bool("PrincessSniffing") and not slasher:GetNW2Bool("PrincessMaulingChild") and not slasher:GetNW2Bool("PrincessMaulingSurvivor") and not slasher:GetDemonPacified() then
			--mauling child
			SlashCo.StopChase(slasher)
			slasher:SetNW2Bool("PrincessMaulingChild", true)
			slasher:Freeze(true)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/princess/princess_maul.mp3",
				identifier = "PrincessMaul",
				minDistance = 200,
				maxDistance = 700,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})

			--baby in jaw

			v:Remove()

			local pos = slasher:LocalToWorld(Vector(0, 10, -5))
			local ang = slasher:LocalToWorldAngles(Angle(90, 0, 0))

			local mauled_child = ents.Create("prop_physics")

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/survivor/baby_use.mp3",
				identifier = "PrincessBabyMaul1",
				minDistance = 200,
				maxDistance = 700,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})

			mauled_child:SetMoveType(MOVETYPE_NONE)
			mauled_child:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			mauled_child:SetModel(SlashCoItems.Baby.Model)
			mauled_child:SetPos(pos)
			mauled_child:SetAngles(ang)
			mauled_child:FollowBone(slasher, slasher:LookupBone("head"))

			for i = 1, math.random(9, 12) do
				timer.Simple((i / 3.5) * (0.7 + (math.random() * 0.3)), function()
					if not IsValid(slasher) or not IsValid(mauled_child) then return end

					local vPoint = mauled_child:GetPos()
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					local idx = math.random(2, 4)
					SlashCo.AudioSystem.PlaySound({
						soundPath = "physics/flesh/flesh_squishy_impact_hard" .. idx .. ".wav",
						identifier = "PrincessBabyMaul2" .. idx,
						minDistance = 200,
						maxDistance = 700,
						entity = slasher,
						volume = 1,
						fadeIn = 0,
					})
				end)
			end

			timer.Simple(3.75, function()
				if not IsValid(slasher) then return end

				local vPoint = mauled_child:GetPos()
				local bloodfx = EffectData()
				bloodfx:SetOrigin(vPoint)
				util.Effect("BloodImpact", bloodfx)

				local idx = math.random(2, 4)
				SlashCo.AudioSystem.PlaySound({
					soundPath = "physics/body/body_medium_break" .. idx .. ".wav",
					identifier = "PrincessBabyMaul3" .. idx,
					minDistance = 200,
					maxDistance = 700,
					entity = slasher,
					volume = 1,
					fadeIn = 0,
				})

				mauled_child:Remove()

				slasher.AggressionThreshold = slasher.AggressionThreshold + math.random(15, 20)
				slasher.Aggression = Aggression - math.random(25, Aggression + 26)
			end)

			---yeah

			timer.Simple(4.5, function()
				if not IsValid(slasher) then return end

				slasher:Freeze(false)
				slasher:SetNW2Bool("PrincessMaulingChild", false)
				slasher:SetDemonPacified(true)

				timer.Simple(math.random(10, 25), function()
					if not IsValid(slasher) then return end

					slasher:SetDemonPacified(false)
				end)
			end)
		end
	end

	if slasher:GetInSlasherChaseMode() then
		--Get Aggro
		if Aggression < AggressionTH then
			slasher.Aggression = Aggression + FrameTime()
		end

		local lookent = slasher:GetEyeTrace().Entity

		if lookent:GetPos():Distance(slasher:GetPos()) < 100 then
			if Aggression >= 95 then
				SlashCo.BustDoor(slasher, lookent, 50000)
			elseif Aggression >= 50 then
				slasher:SlamDoor(lookent)
			end

			if lookent:GetClass() == "func_breakable" or lookent:GetClass() == "func_breakable_surf" then
				lookent:TakeDamage(10000, slasher, slasher)
			end
		end
	end

	if AggressionTH > 100 then
		slasher.AggressionThreshold = 100
	end

	if Aggression < 0 then
		slasher.Aggression = 0
	end

	if slasher:GetNW2Int("PrincessAggression") ~= math.floor(slasher.Aggression) then
		slasher:SetNW2Int("PrincessAggression", math.floor(slasher.Aggression))
	end

	if slasher:GetNW2Int("PrincessAggressionThres") ~= math.floor(slasher.AggressionThreshold) then
		slasher:SetNW2Int("PrincessAggressionThres", math.floor(slasher.AggressionThreshold))
	end

	if IsValid(slasher.victimragdoll) and IsValid(slasher.ref_child) then
		local PhysBone = slasher.victimragdoll:GetPhysicsObjectNum(0)

		if IsValid(PhysBone) then
			PhysBone:SetPos(slasher.ref_child:LocalToWorld(Vector(0, 0, 0)))
			PhysBone:SetAngles(slasher.ref_child:LocalToWorldAngles(Angle(0, 0, 0)))
		end
	end

	if IsValid(slasher.SurvivorDragged) then
		slasher:SetCollisionBounds(Vector(-70, 0 , 0), Vector(70, 0 , 0))

		slasher.SurvivorDragged:SetPos(slasher:LocalToWorld(Vector(60, 0, 0)))

		if slasher.SurvivorDragged.DragStruggle ~= nil and slasher.SurvivorDragged.DragStruggle > 50 then
			slasher.SurvivorDragged:RemoveSpeedEffect("princessmaul")
			slasher.SurvivorDragged.DragStruggle = 0
			slasher.SurvivorDragged:SetSurvivorDragged(false)
			slasher.SurvivorDragged = nil

			slasher:SetNW2Bool("PrincessDraggingSurvivor", false)

			timer.Simple(5, function()
				if not IsValid(slasher) then return end
				slasher.PrincessCanMaul = true
			end)
		end

		slasher.DragEnd = slasher.DragEnd or CurTime() + 10
		if IsValid(slasher.SurvivorDragged) and CurTime() >= slasher.DragEnd then
			slasher:SetCanChase(true)
			slasher:SetNW2Bool("PrincessDraggingSurvivor", false)

			timer.Simple(5, function()
				if not IsValid(slasher) then return end
				slasher.PrincessCanMaul = true
			end)

			slasher.SurvivorDragged:RemoveSpeedEffect("princessmaul")
			slasher.SurvivorDragged.DragStruggle = 0
			slasher.SurvivorDragged:SetSurvivorDragged(false)
			slasher.SurvivorDragged = nil
		end
	else
		slasher.DragEnd = nil
		slasher:SetNW2Bool("PrincessDraggingSurvivor", false)
		slasher:SetCanChase(true)
		slasher.SurvivorDragged = nil
	end

	slasher:SetEyeSight(eyesight)
	slasher:SetPerception(perception)
end

local function IsPlayerHoldingBaby(target, removeBaby)
	if target:ItemValue("EntClass", false, true) == "sc_baby" then -- eat the baby >:3
		if removeBaby then
			SlashCo.RemoveItem(target, true)
		end

		return true
	end

	if target:ItemValue("EntClass", false, false) == "sc_baby" then -- eat the baby >:3
		if removeBaby then
			SlashCo.RemoveItem(target, false)
		end

		return true
	end

	return false
end

function SLASHER.Maul(slasher, target)
	timer.Remove("princessMaul_" .. slasher:UserID())
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/princess/princess_bite.mp3",
		identifier = "PrincessBite",
		minDistance = 200,
		maxDistance = 700,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	local vPoint = target:GetPos()
	local bloodfx = EffectData()
	bloodfx:SetOrigin(vPoint)
	util.Effect("BloodImpact", bloodfx)

	local eatBabyFromPlayer = IsPlayerHoldingBaby(target, true) -- true if were eating a baby that a player was holding.
	if slasher.Aggression <= 99 and not eatBabyFromPlayer then return end

	SlashCo.StopChase(slasher)
	slasher:SetNW2Bool("PrincessMaulingBase", false)

	slasher:Freeze(true)

	if not eatBabyFromPlayer then
		timer.Simple(0, function() -- ToDo: Why do we even need a timer? Verify.
			if not IsValid(slasher) or not IsValid(target) then return end

			slasher:SetNW2Bool("PrincessMaulingSurvivor", true)
			target:TakeDamage(99999, slasher, slasher)

			timer.Simple(FrameTime() * 3, function()
				if not IsValid(slasher) then return end

				slasher.victimragdoll = target and (target.DeadBody or NULL)
				if not IsValid(slasher.victimragdoll) then return end

				local phys = slasher.victimragdoll:GetPhysicsObject()
				phys:Wake()
				slasher.victimragdoll:FollowBone(slasher, slasher:LookupBone("head"))
			end)
		end)
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/princess/princess_maul.mp3",
		identifier = "PrincessMaul",
		minDistance = 200,
		maxDistance = 700,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	local pos = slasher:LocalToWorld(Vector(0, 10, -5))
	local ang = slasher:LocalToWorldAngles(Angle(90, 0, 0))

	if eatBabyFromPlayer or not IsValid(target) then
		slasher.ref_child = ents.Create("prop_physics")
		slasher.ref_child:SetMoveType(MOVETYPE_NONE)
		slasher.ref_child:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		slasher.ref_child:SetModel(SlashCoItems.Baby.Model)
		slasher.ref_child:SetPos(pos)
		slasher.ref_child:SetAngles(ang)
		slasher.ref_child:FollowBone(slasher, slasher:LookupBone("head"))
		slasher:SetNW2Bool("PrincessMaulingChild", true)
	end

	for i = 1, math.random(9, 10) do
		timer.Simple((i / 8) * (0.7 + (math.random() * 0.3)), function()
			if not IsValid(slasher.victimragdoll) then return end

			local vPoint1 = slasher.victimragdoll:GetPos()
			local bloodfx1 = EffectData()
			bloodfx1:SetOrigin(vPoint1)
			util.Effect("BloodImpact", bloodfx1)

			local idx = math.random(2, 4)
			local idx2 = math.random(1, 5)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/body_medium_impact_hard" .. idx .. ".mp3",
				identifier = "PrincessRagdollMaul1" .. idx,
				minDistance = 200,
				maxDistance = 700,
				entity = slasher.victimragdoll,
				volume = 1,
				fadeIn = 0,
			})
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/body_medium_impact_hard" .. idx2 .. ".mp3",
				identifier = "PrincessRagdollMaul2" .. idx2,
				minDistance = 200,
				maxDistance = 700,
				entity = slasher.victimragdoll,
				volume = 1,
				fadeIn = 0,
			})
		end)
	end

	timer.Simple(2, function()
		if not IsValid(slasher) then return end

		slasher:Freeze(false)

		slasher:SetNW2Bool("PrincessMaulingSurvivor", false)
		slasher:SetNW2Bool("PrincessMaulingBase", false)

		SlashCo.AddSlasherAnger(slasher, SLASHER.AngerIncrease)
		slasher.MaulBonus = slasher.MaulBonus + SlashCo.GetSlasherAnger(slasher)

		if IsValid(slasher.ref_child) then
			slasher.AggressionThreshold = slasher.AggressionThreshold + math.random(15, 20)
			slasher.Aggression = slasher.Aggression - math.random(25, slasher.Aggression + 26)

			slasher.ref_child:Remove()
		end
		slasher:SetNW2Bool("PrincessMaulingChild", false) -- Just to be sure

		if not IsValid(slasher.victimragdoll) then return end

		slasher.victimragdoll:Remove()

		local pickedclean = ents.Create("prop_ragdoll")
		pickedclean:SetModel("models/player/skeleton.mdl")
		pickedclean:SetPos(slasher:LocalToWorld(Vector(30, 0, 40)))
		pickedclean:SetNoDraw(false)
		pickedclean:Spawn()
		pickedclean:SetSkin(2)

		local idx = math.random(2, 4)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "physics/body/body_medium_break" .. idx .. ".wav",
			identifier = "PrincessSkeletonMaul" .. idx,
			minDistance = 200,
			maxDistance = 700,
			entity = pickedclean,
			volume = 1,
			fadeIn = 0,
		})

		local physCount = pickedclean:GetPhysicsObjectCount()

		for i = 0, (physCount - 1) do
			local PhysBone = pickedclean:GetPhysicsObjectNum(i)

			if PhysBone:IsValid() then
				PhysBone:SetVelocity(slasher:GetForward() * 600)
				PhysBone:AddAngleVelocity(-PhysBone:GetAngleVelocity())
			end
		end
	end)
end

function SLASHER.OnKillPlayer(slasher, target)
	if target == slasher.SurvivorDragged then
		slasher.SurvivorDragged = nil
		slasher.PrincessCanMaul = true
	end
end

function SLASHER.OnPrimaryFire(slasher)
	if slasher:GetNW2Bool("PrincessMaulingChild") then return end
	if slasher:GetNW2Bool("PrincessSniffing") then return end
	if slasher:GetDemonPacified() then return end
	if slasher:GetNW2Bool("PrincessMaulingBase") then return end
	if slasher:GetNW2Bool("PrincessStunned") then return end
	if slasher:GetNW2Bool("PrincessDraggingSurvivor") then return end
	if not slasher.PrincessCanMaul then return end
	if slasher.MaulTime and CurTime() - slasher.MaulTime < 3 then return end

	slasher.MaulTime = CurTime()

	slasher:SetNW2Bool("PrincessMaulingBase", true)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/princess/princess_attack.mp3",
		identifier = "PrincessAttack",
		minDistance = 200,
		maxDistance = 700,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	if slasher:IsOnGround() then
		slasher:SetVelocity(slasher:GetForward() * (SLASHER.MaulForward + slasher.MaulBonus))
	end

	timer.Create("princessMaul_" .. slasher:UserID(), 0.05, 8, function()
		if not IsValid(slasher) then return end

		slasher:LagCompensation(true)
		local tr = util.TraceHull({
			start = slasher:EyePos(),
			endpos = slasher:LocalToWorld(Vector(45, 0, 30)),
			maxs = Vector(60, 60, 60),
			mins = Vector(-60, -60, -60),
			filter = slasher,
			ignoreworld = true,
		})
		slasher:LagCompensation(false)

		local target = tr.Entity
		local damage = math.random(20, 35) + math.random(0, math.floor(slasher.Aggression / 4))

		if target:IsValid() and (not target:IsPlayer() or (target:Team() == TEAM_SURVIVOR and not IsPlayerHoldingBaby(target, false))) then
			local dmg = DamageInfo()
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(slasher)
			dmg:SetInflictor(slasher)
			dmg:SetDamage(damage)
			dmg:SetDamageForce(Vector(1, 1, 1)) -- required or else warnings are spammed
			dmg:SetDamagePosition(tr.HitPos) -- required or else warnings are spammed
			target:TakeDamageInfo(dmg)
		end

		if target:IsValid() and target:IsPlayer() and target:Team() == TEAM_SURVIVOR then
			if slasher.Aggression >= 30 and slasher.Aggression <= 99 then
				if math.random(1, 100) > 59 then -- 40% chance to grab a surv
					SlashCo.StopChase(slasher)

					slasher.SurvivorDragged = target
					slasher.SurvivorDragged:SetSurvivorDragged(true)
					slasher.SurvivorDragged:AddSpeedEffect("princessmaul", 50, 2)

					for i = 1, 100 do
						timer.Simple(1 + (i / 10), function()
							if not IsValid(slasher.SurvivorDragged) or not IsValid(slasher) then return end

							slasher.SurvivorDragged:TakeDamage(0.3, slasher, slasher)
						end)
					end

					slasher:SetCanChase(false)
					slasher.PrincessCanMaul = false
					slasher:SetNW2Bool("PrincessDraggingSurvivor", true)
				end
			end

			SLASHER.Maul(slasher, target)
		end
	end)

	timer.Simple(0.7, function()
		if not IsValid(slasher) then return end

		if not slasher:GetNW2Bool("PrincessMaulingSurvivor") then
			slasher:SetNW2Bool("PrincessMaulingBase", false)
		end
	end)
end

function SLASHER.OnSecondaryFire(slasher)
	if slasher:GetNW2Bool("PrincessStunned") then return end
	if slasher:GetNW2Bool("PrincessDraggingSurvivor") then return end

	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher:GetNW2Bool("PrincessMaulingChild") then return end
	if slasher:GetNW2Bool("PrincessMaulingSurvivor") then return end
	if slasher:GetNW2Bool("PrincessMaulingBase") then return end
	if slasher:GetNW2Bool("PrincessSniffing") then return end
	if slasher:GetNW2Bool("PrincessStunned") then return end
	if slasher:GetNW2Bool("PrincessDraggingSurvivor") then return end
	if slasher:GetInSlasherChaseMode() then return end

	slasher:SetNW2Bool("PrincessSniffing", true)
	slasher:Freeze(true)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/princess/princess_sniff.mp3",
		identifier = "PrincessSniff",
		minDistance = 200,
		maxDistance = 700,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(4, function()
		if not IsValid(slasher) then return end

		slasher:SetNW2Bool("PrincessSniffing", false)
		slasher:Freeze(false)

		slasher:SlasherHudFunc("Sniff")
	end)
end

function SLASHER.OnSpecialAbilityFire(slasher)
end

function SLASHER.OnHitByBeerKeg(slasher, ply)
	SlashCo.StopChase(slasher)

	slasher:SetNW2Bool("PrincessStunned", true)
	slasher:Freeze(true)
	timer.Simple(11, function()
		if not IsValid(slasher) then return end

		slasher:SetNW2Bool("PrincessStunned", false)
		slasher:Freeze(false)
	end)
end
SLASHER.OnHitByTeslaCoil = SLASHER.OnHitByBeerKeg
SLASHER.OnHitByPocketSand = SLASHER.OnHitByBeerKeg

function SLASHER.Thirdperson(ply)
	return ply:GetNW2Bool("PrincessMaulingChild") or ply:GetNW2Bool("PrincessMaulingSurvivor") or ply:GetNW2Bool("PrincessSniffing")
end

function SLASHER.Animator(ply)
	local chase = ply:GetInSlasherChaseMode()
	local maul_child = ply:GetNW2Bool("PrincessMaulingChild")
	local maul_normal = ply:GetNW2Bool("PrincessMaulingBase")
	local maul_survivor = ply:GetNW2Bool("PrincessMaulingSurvivor")
	local maul_grab = ply:GetNW2Bool("PrincessDraggingSurvivor")
	local sniff = ply:GetNW2Bool("PrincessSniffing")
	local stun = ply:GetNW2Bool("PrincessStunned")

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	if maul_child then
		ply.CalcSeqOverride = ply:LookupSequence("maul_child")
		ply:SetPlaybackRate(1)
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif maul_normal then
		ply.CalcSeqOverride = ply:LookupSequence("maul")
		ply:SetPlaybackRate(1)
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif maul_survivor then
		ply.CalcSeqOverride = ply:LookupSequence("maul_survivor")
		ply:SetPlaybackRate(1)
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif sniff then
		ply.CalcSeqOverride = ply:LookupSequence("sniff")
		ply:SetPlaybackRate(1)
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif stun then
		ply.CalcSeqOverride = ply:LookupSequence("stun")
		ply:SetPlaybackRate(1)
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif maul_grab then
		ply.CalcSeqOverride = ply:LookupSequence("grab_attack")
		ply:SetPlaybackRate(1)
		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	else
		ply.anim_antispam = false
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/princess/prinstep_" .. math.random(1, 10) .. ".ogg",
		identifier = "PrincessFootstep1",
		group = "SlasherFootstep",
		minDistance = 300,
		maxDistance = 700,
		entity = ply,
		volume = 1,
		fadeIn = 0,
		excludeSendTo = ply,
	})

	timer.Simple(0.15, function()
		if not IsValid(ply) then
			return
		end

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/princess/prinstep_" .. math.random(1, 10) .. ".ogg",
			identifier = "PrincessFootstep2",
			group = "SlasherFootstep",
			minDistance = 300,
			maxDistance = 700,
			entity = ply,
			volume = 1,
			fadeIn = 0,
			excludeSendTo = ply,
		})
	end)

	return true
end

local maulTable = {
	default = Material("slashco/ui/icons/slasher/princess_a1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/princess"))
	hud:SetTitle("Princess")

	hud:AddControl("R", "sniff", Material("slashco/ui/icons/slasher/princess"))
	hud:AddControl("LMB", "maul", maulTable)
	hud:TieControl("LMB", "DemonPacified", true)
	hud:ChaseAndKill(nil, true)

	hud:AddMeter("aggro", 50, "%", false, true)
	hud:TieMeterInt("aggro", "PrincessAggression")

	hud.SniffIcon = Material("slashco/ui/particle/sniff_hint")
	function hud:Sniff()
		local survivors = team.GetPlayers(TEAM_SURVIVOR)
		local sniffables = table.Add(survivors, ents.FindByClass("sc_baby"))

		if table.Count(sniffables) <= 0 then return end

		self.SniffPos = table.Random(sniffables):WorldSpaceCenter()

		local inaccuracy = math.max(self.SniffPos:Distance(GameData.LocalPlayer:GetPos()) / 12, 50)
		self.SniffRandom = VectorRand(-inaccuracy, inaccuracy)
	end

	hud.prevThresh = -1
	function hud.AlsoThink()
		local thresh = GameData.LocalPlayer:GetNW2Int("PrincessAggressionThres")
		if thresh ~= hud.prevThresh then
			hud:SetMeterMax("aggro", thresh)
			hud.prevThresh = thresh
		end
	end
end

function SLASHER.DrawHUD(localPly, hud)
	if not hud.SniffPos or hud.SniffPos:Distance(localPly:GetPos()) < 150 then
		return
	end

	local screenPos = (hud.SniffPos + hud.SniffRandom):ToScreen()
	local xClamp = math.Clamp(screenPos.x, 200, ScrW() - 200)
	local yClamp = math.Clamp(screenPos.y, 200, ScrH() - 200)
	local scrW = ScrW()

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(hud.SniffIcon)
	surface.DrawTexturedRect(xClamp - scrW / 64, yClamp - scrW / 64, scrW / 32, scrW / 32)
end

function SLASHER.PreDrawHalos()
	SlashCo.DrawHalo(SlashCo.FindByClass("sc_baby"), nil, 2, false)

	local plyWithItem = {}
	for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if v:HasItem("Baby") then
			table.insert(plyWithItem, v)
		end
	end

	SlashCo.DrawHalo(plyWithItem, nil, 2, false)
end

SlashCo.RegisterSlasher(SLASHER, "Princess")