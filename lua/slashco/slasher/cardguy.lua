local SLASHER = {}

SLASHER.Name = "Cardguy"
SLASHER.Aliases = {
	"Lucky Card",
}
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/cardguy/cardguy.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 4
SLASHER.ProwlSpeed = 180
SLASHER.ChaseSpeed = 295
SLASHER.Perception = 0.8
SLASHER.Eyesight = 4
SLASHER.KillDistance = 137
SLASHER.ChaseRange = 1800
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 2
SLASHER.JumpscareDuration = 4
SLASHER.ChaseMusic = "slashco/slasher/cardguy/cardguy_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Cardguy_desc"
SLASHER.ProTip = "Cardguy_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★★"

local CARD_EMPTY = 0
local CARD_BABA = 1
local CARD_SID = 2
local CARD_SPEED = 3
local CARD_JONKLER = 4

local card = CARD_EMPTY
local function CardChances(slasher)
	local chances = math.random(1, 400)

	if chances < 100 then
		card = CARD_EMPTY
	elseif chances >= 100 and chances < 200 then
		card = CARD_BABA
	elseif chances >= 200 and chances < 300 then
		card = CARD_SID
	elseif chances >= 300 and chances < 350 then
		card = CARD_SPEED
	elseif chances >= 350 then
		card = CARD_JONKLER
	end
end

local function CardSwitch(slasher)
	local oldcard = slasher:GetNW2Float("CardSelection")
	while card == oldcard do
		CardChances(slasher)
	end

	slasher.KillCooldown = 2

	slasher:SetNW2Bool("CardguySwitching", true)
	slasher:SetNW2Float("CardSelection", card)
	slasher.CardCooldown = math.random(60, 75)

	SlashCo.AudioSystem.EmitSound(slasher, "slashco/slasher/cardguy/cardguy_cardswitch.mp3")

	timer.Simple(2, function()
		if not IsValid(slasher) then return end
		slasher:SetNW2Bool("CardguySwitching", false)
	end)

	local cooldown = slasher.CardCooldown
	timer.Simple(cooldown, function()
		if not IsValid(slasher) then return end
		CardSwitch(slasher)
	end)
end

local function BababooeyCard(slasher)
	if slasher.BababooeyCooldown > 0.01 then return end
	if slasher:GetNW2Float("CardSelection") ~= CARD_BABA then return end

	local interval = math.random(10, 15)
	local reset = interval / 2
	timer.Simple(slasher.BababooeyCooldown, function()
		if not IsValid(slasher) then return end
		if slasher:GetNW2Float("CardSelection") ~= CARD_BABA then return end

		slasher:SetVisible(false)
		slasher:DrawShadow(false)
		slasher.KillCooldown = reset

		slasher.BababooeyCooldown = interval

		SlashCo.AudioSystem.EmitSound(slasher, "slashco/slasher/bababooey/baba_hide.mp3")

		timer.Simple(reset, function()
			if not IsValid(slasher) then return end

			slasher:SetVisible(true)
			slasher:DrawShadow(true)

			SlashCo.AudioSystem.EmitSound(slasher, "slashco/slasher/bababooey/baba_reveal.mp3")
		end)
	end)
end

local function JonklerCard(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/jonk.ogg",
		identifier = "CardguyJonkler",
		minDistance = 500 * SlashCo.MapSize,
		maxDistance = 1000 * SlashCo.MapSize,
		looping = true,
		isMusic = true,
		entity = slasher,
		volume = 0.8,
		fadeIn = 1,
	})
end

local function StopJonklerCard(slasher)
	SlashCo.AudioSystem.StopSound("CardguyJonkler", 1, slasher)
end

function SLASHER.GetSpeed(slasher)
	if slasher:GetNW2Float("CardSelection") == CARD_SPEED then
		if slasher:GetInSlasherChaseMode() then
			return slasher:GetNW2Int("SpeedrunnerCardChaseSpeed")
		else
			return slasher:GetNW2Int("SpeedrunnerCardProwlSpeed")
		end
	end

	if slasher:GetNW2Float("CardSelection") == CARD_JONKLER then
		return 400
	end

	if slasher:GetInSlasherChaseMode() then
		return SLASHER.ChaseSpeed
	end

	if slasher:GetNW2Bool("CardguyTeleporting") or slasher:GetNW2Bool("CardguyThrowing") then
		return 1
	end

	return SLASHER.ProwlSpeed
end

function SLASHER.OnSpawn(slasher)
	timer.Simple(60, function()
		if not IsValid(slasher) then return end
		CardSwitch(slasher)
	end)

	slasher:SetCanKill(true)
	slasher:SetCanChase(true)

	slasher.JonklerSound = nil
	slasher.KillCooldown = 0
	slasher.CardCooldown = 60
	slasher.BababooeyCooldown = 0
	slasher.TeleportCooldown = 60
	slasher.MatchaCooldown = 5
	slasher.SpeedProwlCard = 180
	slasher.SpeedChaseCard = 295

	slasher:SetNW2Float("CardSelection", CARD_EMPTY)
	slasher:SetNW2Int("CardguyEffect1", 0)
	slasher:SetNW2Int("CardguyEffect2", 0)
	slasher:SetNW2Int("CardguyEffect3", 0)
end

function SLASHER.OnTickBehaviour(slasher)
	local SwitchCardCD = slasher.CardCooldown or 0 --Cooldown
	local BabaCardCD = slasher.BababooeyCooldown or 0 --Cooldown
	local KillCD = slasher.KillCooldown or 0 --Cooldown
	local TeleportCD = slasher.TeleportCooldown or 0 --Cooldown
	local MatchaCD = slasher.MatchaCooldown or 0 --Cooldown
	local SpeedProwl = slasher.SpeedProwlCard or 0 -- Speedcard
	local SpeedChase = slasher.SpeedChaseCard or 0 -- Speedcard

	if SwitchCardCD > 0 then
		slasher.CardCooldown = SwitchCardCD - FrameTime()
	end

	if BabaCardCD > 0 then
		slasher.BababooeyCooldown = BabaCardCD - FrameTime()
	end

	if KillCD > 0 then
		slasher:SlasherHudFunc("SetControlEnabled", "LMB", false)
		slasher.KillCooldown = KillCD - FrameTime()
	else
		slasher:SlasherHudFunc("SetControlEnabled", "LMB", true)
	end

	if TeleportCD > 0 then
		slasher:SlasherHudFunc("SetControlEnabled", "F", false)
		slasher.TeleportCooldown = TeleportCD - FrameTime()
	else
		slasher:SlasherHudFunc("SetControlEnabled", "F", true)
	end

	if MatchaCD > 0 then
		slasher:SlasherHudFunc("SetControlEnabled", "R", false)
		slasher.MatchaCooldown = MatchaCD - FrameTime()
	else
		slasher:SlasherHudFunc("SetControlEnabled", "R", true)
	end

	if slasher:GetNW2Float("CardSelection") == CARD_BABA then
		BababooeyCard(slasher)
	else
		slasher.BababooeyCooldown = 0
	end

	if slasher:GetNW2Float("CardSelection") == CARD_SPEED then
		local mapSizeMod = (0.5 / SlashCo.MapSize) + 0.5
		slasher.SpeedProwlCard = SpeedProwl + engine.TickInterval() * mapSizeMod * 2 * 0.66
		slasher.SpeedChaseCard = SpeedChase + engine.TickInterval() * mapSizeMod * 2 * 0.66
	else
		slasher.SpeedProwlCard = 180
		slasher.SpeedChaseCard = 295
	end

	if slasher:GetNW2Float("CardSelection") == CARD_JONKLER then
		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:CanBeSeen() then continue end
			if survivor:GetPos():Distance(slasher:GetPos()) > 400 then continue end

			local tr = util.TraceLine({
				start = slasher:EyePos(),
				endpos = survivor:WorldSpaceCenter(),
				filter = slasher
			})
			if tr.Entity ~= survivor then continue end

			local survivorPos = survivor:GetPos()
			local slasherPos = slasher:GetPos()
			local direction = (survivorPos - slasherPos):GetNormalized()
			local ang = direction:Angle()

			survivor:SetEyeAngles(ang)
		end

		slasher:SetCanChase(false)
		if slasher.JonklerSound == nil then
			slasher.JonklerSound = true
			JonklerCard(slasher)
		end
	else
		slasher:SetCanChase(true)
		if slasher.JonklerSound == true then
			slasher.JonklerSound = nil
			StopJonklerCard(slasher)
		end
	end

	slasher:SetNW2Int("SpeedrunnerCardProwlSpeed", math.floor(SpeedProwl))
	slasher:SetNW2Int("SpeedrunnerCardChaseSpeed", math.floor(SpeedChase))
	slasher:SetNW2Int("CardCooldown", math.floor(SwitchCardCD))

	slasher:SetEyeSight(slasher.EyesightOverride or SLASHER.Eyesight)
	slasher:SetPerception(slasher.PerceptionOverride or SLASHER.Perception)
end

hook.Add("PlayerUse", "CardguyItemInteraction", function(ply, ent)
    if ply:Team() ~= TEAM_SLASHER then return end
	if ply:GetNW2String("Slasher") ~= "Cardguy" then return end
	if ply:GetNW2Bool("CardguyExecuting") then return end
	if ply:GetNW2Bool("CardguyStunned") then return end
	if ply:GetNW2Bool("CardguyTeleporting") then return end
	if ply:GetPos():Distance(ent:GetPos()) >= 100 then return end

	if ent:GetClass() == "sc_alcohol" then
		SlashCo.AudioSystem.EmitSound(ply, "slashco/survivor/soda_drink1.mp3")

		ply.PerceptionOverride = 2.0
		ply:SetNW2Int("CardguyEffect1", 1)

		timer.Simple(20, function()
			if not IsValid(ply) then return end
			ply.PerceptionOverride = nil
			ply:SetNW2Int("CardguyEffect1", 0)
		end)
	elseif ent:GetClass() == "sc_brick" then
		SlashCo.AudioSystem.EmitSound(ply, "physics/concrete/boulder_impact_hard1.wav")

		ply:SetVelocity((ent:GetAngles():Up() * 700) + Vector(0, 0, 2400))
	elseif ent:GetClass() == "sc_baby" then
		SlashCo.AudioSystem.EmitSound(ply, "slashco/survivor/baby_use.mp3")

		ply:RandomTeleport()
	elseif ent:GetClass() == "sc_newports" then
		SlashCo.AudioSystem.EmitSound(ply, "slashco/newports_eat.ogg")

		ply.EyesightOverride = 6
		ply:SetNW2Int("CardguyEffect2", 1)

		timer.Simple(20, function()
			if not IsValid(ply) then return end
			ply.EyesightOverride = nil
			ply:SetNW2Int("CardguyEffect2", 0)
		end)
    elseif ent:GetClass() == "sc_porchlight" then
		ent:Stage3()
    elseif ent:GetClass() == "sc_rock" then
		SlashCo.AudioSystem.EmitSound(ply, "physics/concrete/boulder_impact_hard1.wav")

		ply:SetNW2Int("CardguyEffect3", 1)

		timer.Simple(20, function()
			if not IsValid(ply) then return end
			ply:SetNW2Int("CardguyEffect3", 0)
		end)
	else
		return
	end

	if IsValid(ent) then ent:Remove() end
end)

function SLASHER.OnPrimaryFire(slasher, target)
	if slasher:GetNW2Bool("CardguyStunned") then return end
	if slasher:GetNW2Bool("CardguyTeleporting") then return end
	if slasher:GetNW2Bool("CardguyThrowing") then return end
	if slasher:GetNW2Bool("CardguyExecuting") then return end
	if not IsValid(target) then return end

	local dist = SLASHER.KillDistance
	if not target:IsPlayer() then
		local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 0)),
			Vector(-30, -30, -60), Vector(30, 30, 60), 50, DMG_SLASH, 5, false)
		return
	end

	if target:IsPlayer() and slasher:GetNW2Float("CardSelection") == CARD_JONKLER then
		local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 0)),
			Vector(-30, -30, -60), Vector(30, 30, 60), 5, DMG_SLASH, 5, false)

		SlashCo.AudioSystem.EmitSound(slasher, "slashco/slasher/cardguy/cardguy_slap.mp3")
		return
	end

	if target:Team() ~= TEAM_SURVIVOR then return end
	if slasher:GetPos():Distance(target:GetPos()) >= dist * 1.4 or target:GetSurvivorBeingJumpscared() then return end
	if slasher.KillCooldown > 0.01 then return end

	local pick_ang = SlashCo.RadialTester(slasher, 600, target)

	slasher:SetEyeAngles(Angle(0, pick_ang, 0))
	target:SetEyeAngles(Angle(0, pick_ang, 0))
	slasher:Freeze(true)

	slasher.KillDelayTick = SLASHER.KillDelay

	timer.Simple(0.1, function()
		if not IsValid(slasher) or not IsValid(target) then return end

		target:SetPos(slasher:GetPos())
		target:Freeze(true)
		target:SetSurvivorBeingJumpscared(true)

		slasher:SetCanKill(false)
		slasher:SetCanChase(false)
		slasher:SetNW2Bool("CardguyExecuting", true)

		target:SetSurvivorSidExecution(true)

		target:SetPos(slasher:GetPos())
		target:SetEyeAngles(Angle(0, pick_ang, 0))

		timer.Simple(1.35, function()
			if not IsValid(target) then return end

			target:SetEyeAngles(Angle(0, 180 + pick_ang, 0))
		end)

		timer.Simple(1.75, function()
			if not IsValid(target) then return end

			target:SetSurvivorBeingJumpscared(false)
			target:SetSurvivorSidExecution(false)
		
			target:Freeze(false)
			target:SetNotSolid(false)

			if IsValid(slasher) then -- RaphaelIT7: We check it down here to avoid leaving the player wrongly frozen
				SlashCo.AudioSystem.EmitSound(slasher, "slashco/slasher/cardguy/cardguy_slap.mp3")
				target:SetPos(slasher:GetPos() + (slasher:GetForward() * 40))
				target:SetVelocity(slasher:GetForward() * 300)
			end

			timer.Simple(0.05, function()
				if not IsValid(target) then return end

				if IsValid(slasher) then
					target:TakeDamage(99999, slasher, slasher)
				else
					target:Kill()
				end
			end)
		end)

		timer.Simple(2.3, function()
			if not IsValid(slasher) then return end

			slasher:Freeze(false)
			slasher:SetCanKill(true)
			slasher:SetCanChase(true)
			slasher:SetNW2Bool("CardguyExecuting", false)
		end)
	end)
end

function SLASHER.OnSecondaryFire(slasher)
	if slasher:GetNW2Bool("CardguyExecuting") then return end
	if slasher:GetNW2Bool("CardguyThrowing") then return end
	if slasher:GetNW2Bool("CardguyStunned") then return end
	if slasher:GetNW2Float("CardSelection") == CARD_SID then
		SlashCo.StartChaseMode(slasher, true)
		return
	end

	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher:GetNW2Bool("CardguyStunned") then return end
	if slasher:GetNW2Bool("CardguyTeleporting") then return end
	if slasher:GetNW2Bool("CardguyThrowing") then return end
	if slasher:GetNW2Bool("CardguyExecuting") then return end
	if slasher.MatchaCooldown > 0.01 then return end

	if slasher:GetNW2Float("CardSelection") == CARD_SID then
		slasher.MatchaCooldown = 0.5
	else
		slasher.MatchaCooldown = 12
	end

	slasher:SetNW2Bool("CardguyThrowing", true)

	timer.Simple(0.3, function()
		if not IsValid(slasher) then return end

		local vec = slasher:GetPos()
		local ang = slasher:LocalToWorldAngles(Angle(0, 0, 0))
		local pos = vec
		local matcha = ents.Create("sc_matchacoffee")
		if not IsValid(matcha) then return end

		matcha:SetPos(pos + slasher:GetForward() * 7 + Vector(0, 0, 60))
		matcha:SetAngles(ang)
		matcha:Spawn()
		matcha:Activate()
		matcha:SetMatchaVelocity(slasher:GetAimVector() * 1000)
	end)

	timer.Simple(1, function()
		if not IsValid(slasher) then return end

		slasher:SetNW2Bool("CardguyThrowing", false)
	end)
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if slasher:GetNW2Bool("CardguyStunned") then return end
	if slasher:GetNW2Bool("CardguyTeleporting") then return end
	if slasher:GetNW2Bool("CardguyThrowing") then return end
	if slasher:GetNW2Bool("CardguyExecuting") then return end
	if slasher.TeleportCooldown > 0.01 then return end

	local nearestTarget, nearestDist
	for _, target in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if not IsValid(target) then continue end
		if not target:Alive() then continue end

		local dist = slasher:GetPos():Distance(target:GetPos())
		if dist > 2000 then continue end

		if not nearestTarget or dist < nearestDist then
			nearestTarget = target
			nearestDist = dist
		end
	end

	if not IsValid(nearestTarget) then
		slasher:ChatPrint("No survivors found, get closer.")
		return
	end

	local dir = nearestTarget:EyeAngles():Forward()
	dir.z = 0
	dir:Normalize()

	local behindPos = nearestTarget:GetPos() - dir * 70
	local tr = util.TraceHull({
		start = behindPos,
		endpos = behindPos,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		mask = MASK_PLAYERSOLID,
		filter = {slasher, nearestTarget}
	})

	if tr.Hit then
		behindPos = nearestTarget:GetPos() + Vector(math.Rand(-50, 50), math.Rand(-50, 50), 0)
		local tr2 = util.TraceHull({
			start = behindPos,
			endpos = behindPos,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72),
			mask = MASK_PLAYERSOLID,
			filter = {slasher, nearestTarget}
		})
		if tr2.Hit then
			slasher:ChatPrint("Not enough space for teleportation.")
			return
		end
	end

	slasher:ChatPrint("Teleportation in 2 seconds...")
	slasher:SetNW2Bool("CardguyTeleporting", true)
	slasher.TeleportCooldown = 30

	local targetRef = nearestTarget
	timer.Simple(2, function()
		if not IsValid(slasher) or not IsValid(targetRef) then
			if IsValid(slasher) then
				slasher:ChatPrint("Invalid survivor.")
				slasher:SetNW2Bool("CardguyTeleporting", false)
				slasher.TeleportCooldown = 5
			end
			return
		end

		if not slasher:Alive() or not targetRef:Alive() then
			slasher:ChatPrint("Survivor is dead.")
			slasher:SetNW2Bool("CardguyTeleporting", false)
			slasher.TeleportCooldown = 5
			return
		end

		if targetRef:Team() == TEAM_SPECTATOR then
			slasher:ChatPrint("Survivor is dead.")
			slasher:SetNW2Bool("CardguyTeleporting", false)
			slasher.TeleportCooldown = 5
			return
		end

		if slasher:GetNW2Bool("CardguyTeleporting") then
			slasher:SetImpervious(true)
			slasher:SetPos(behindPos)

			local ang = (targetRef:GetPos() - behindPos):Angle()
			slasher:SetEyeAngles(Angle(0, ang.y, 0))

			SlashCo.AudioSystem.EmitSound(slasher, "slashco/survivor/devildie_hurt.mp3")

			local rand = math.random(3, 5)
			SlashCo.AudioSystem.EmitSound(targetRef, "slashco/survivor/voice/prompt_spot" .. rand .. ".mp3")
		end
	end)

	timer.Simple(3.5, function()
		if not IsValid(slasher) then return end
		slasher:SetImpervious(false)
		slasher:SetNW2Bool("CardguyTeleporting", false)
	end)
end

function SLASHER.OnHitByPocketSand(slasher, ply)
	SlashCo.StopChase(slasher)

	slasher:SetNW2Bool("CardguyStunned", true)
	slasher:SetNW2Bool("CardguyTeleporting", false)
	slasher:Freeze(true)

	timer.Simple(2, function()
		if not IsValid(slasher) then return end

		slasher:SetNW2Bool("CardguyStunned", false)
		slasher:Freeze(false)

		slasher:SetSlasherBlinded(false)
		slasher:SetLastTeslaStun(0)
		slasher:SetTeslaStunned(0)
	end)
end
SLASHER.OnHitByBeerKeg = SLASHER.OnHitByPocketSand
SLASHER.OnHitByTeslaCoil = SLASHER.OnHitByPocketSand

function SLASHER.Thirdperson(ply)
	return ply:GetNW2Bool("CardguyStunned") or ply:GetNW2Bool("CardguyTeleporting") or ply:GetNW2Bool("CardguyExecuting")
end

function SLASHER.Animator(ply)
	local chase = ply:GetInSlasherChaseMode() or ply:GetNW2Float("CardSelection") == CARD_JONKLER
	local execution = ply:GetNW2Bool("CardguyExecuting")
	local throwing = ply:GetNW2Bool("CardguyThrowing")
	local teleport = ply:GetNW2Bool("CardguyTeleporting")
	local cardswitch = ply:GetNW2Bool("CardguySwitching")
	local stun = ply:GetNW2Bool("CardguyStunned")

	if not execution and not throwing and not teleport and not cardswitch and not stun then
		ply.anim_antispam = false
	end

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("walk_all")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("run_all_02")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("jump_holding_glide")
	end

	ply:SetPoseParameter("move_x", ply:GetVelocity():Length() / 100)
	if ply:GetVelocity():Length() < 30 then
		ply.CalcIdeal = ACT_IDLE
		ply.CalcSeqOverride = ply:LookupSequence("cg_idle")
	end

	if execution then
		ply.CalcSeqOverride = ply:LookupSequence("cg_kill")

		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if throwing then
		ply.CalcSeqOverride = ply:LookupSequence("cg_throw")

		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	--[[if teleport then
		ply.CalcSeqOverride = ply:LookupSequence("Startle_behind")

		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end]]

	--[[if cardswitch then
		ply.CalcSeqOverride = ply:LookupSequence("Startle_behind")

		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end]]

	if stun then
		ply.CalcSeqOverride = ply:LookupSequence("Startle_behind")

		if not ply.anim_antispam then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	return not ply:GetVisible()
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/cardguy"))
	hud:SetTitle("Cardguy")

	hud:ChaseAndKill()
	hud:AddControl("R", "throw", Material("slashco/ui/icons/slasher/cardguy_matcha"))
	hud:AddControl("F", "teleport", Material("slashco/ui/icons/slasher/cardguy_teleport"))
end

function SLASHER.PreDrawHalos()
	if GameData.LocalPlayer:GetNW2Int("CardguyEffect3") == 1 then
		SlashCo.DrawHalo(team.GetPlayers(TEAM_SURVIVOR), "blue", 2, false)
	end

	SlashCo.DrawHalo(SlashCo.FindByClass("sc_alcohol"), nil, 2, false)
	SlashCo.DrawHalo(SlashCo.FindByClass("sc_brick"), nil, 2, false)
	SlashCo.DrawHalo(SlashCo.FindByClass("sc_baby"), nil, 2, false)
	SlashCo.DrawHalo(SlashCo.FindByClass("sc_newports"), nil, 2, false)
	SlashCo.DrawHalo(SlashCo.FindByClass("sc_porchlight"), nil, 2, false)
	SlashCo.DrawHalo(SlashCo.FindByClass("sc_rock"), nil, 2, false)
end

local card_material = {
	[0] = Material("slashco/ui/icons/slasher/cardguy_empty"),
	[1] = Material("slashco/ui/icons/slasher/cardguy_bababooey"),
	[2] = Material("slashco/ui/icons/slasher/cardguy_sid"),
	[3] = Material("slashco/ui/icons/slasher/cardguy_speedrunner"),
	[4] = Material("slashco/ui/icons/slasher/cardguy_jonkler")
}

local interactList = {
	["sc_alcohol"] = true,
	["sc_brick"] = true,
	["sc_baby"] = true,
	["sc_newports"] = true,
	["sc_porchlight"] = true,
	["sc_rock"] = true
}

function SLASHER.DrawHUD(localPly)
	local screenW, screenH = ScrW(), ScrH()
	local iconsize = screenW / 13
	local yaxis_cards = screenH - iconsize * 2.4
	local card_selection = card_material[localPly:GetNW2Float("CardSelection")]

	surface.SetDrawColor(255, 255, 255, 255)
	if card_selection then
		surface.SetMaterial(card_selection)
		surface.DrawTexturedRect(iconsize * 5.35, yaxis_cards + iconsize * 0, iconsize * 2.3, iconsize * 2.3)
	end

	local ColorRed = Color(255, 0, 0, 255)
	local Cooldown = localPly:GetNW2Int("CardCooldown")
	if Cooldown > 0 then
		draw.SimpleText("CARD SWITCH: " .. math.Round(Cooldown, 1), "TVCD", ScrW() / 2, 695, ColorRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local EffectName1 = (localPly:GetNW2Int("CardguyEffect1") == 1 and "Big Ears") or "None"
	local EffectName2 = (localPly:GetNW2Int("CardguyEffect2") == 1 and "Snake Eyes") or "None"
	local EffectName3 = (localPly:GetNW2Int("CardguyEffect3") == 1 and "Revelation") or "None"

	draw.SimpleText("EFFECTS:", "TVCD", ScrW() / 2.5, 900, ColorRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText(EffectName1, "TVCD", ScrW() / 2.5, 930, ColorRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText(EffectName2, "TVCD", ScrW() / 2.5, 960, ColorRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText(EffectName3, "TVCD", ScrW() / 2.5, 990, ColorRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

if CLIENT then
	hook.Add("CalcView", "CardguyExecution", function(ply, pos, angles, fov)
		if ply:Team() ~= TEAM_SURVIVOR then return end

		if ply:GetSurvivorSidExecution() then
			pos = ply:LocalToWorld(Vector(120, -120, 60))
			angles = ply:LocalToWorldAngles(Angle(0, -135, 0))

			return GAMEMODE:CalcView(ply, pos, angles, fov)
		end
	end)

	-- RaphaelIT7 (ToDo): Once we have a clientside slasher tick hook this should be moved there :)
	hook.Add("Tick", "CardguyJonkler", function()
		for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if SlashCoSlashers[v:GetNW2String("Slasher")] == SLASHER then
				if v:GetNW2Float("CardSelection") == CARD_JONKLER then
					local tlight = DynamicLight(MAX_EDICT + v:EntIndex())
					if tlight then
						tlight.pos = v:LocalToWorld(Vector(0, 0, 20))
						tlight.r = 0
						tlight.g = 255
						tlight.b = 0
						tlight.brightness = 2
						tlight.Decay = 500
						tlight.Size = 1000
						tlight.DieTime = CurTime() + 1
					end
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Cardguy")