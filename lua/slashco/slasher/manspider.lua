local SLASHER = {}

SLASHER.Name = "Manspider"
SLASHER.Aliases = {
	"The Worst",
	"Itsy Bitsy",
}
SLASHER.ID = 9
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/manspider/manspider.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 5
SLASHER.ProwlSpeed = 250
SLASHER.ChaseSpeed = 315
SLASHER.Perception = 1.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 1200
SLASHER.ChaseRadius = 0.9
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 2
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/manspider/manspider_chase.ogg"
SLASHER.KillSound = "slashco/slasher/manspider/manspider_kill.mp3"
SLASHER.Description = "Manspider_desc"
SLASHER.ProTip = "Manspider_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★☆☆"
SLASHER.CannotBeSpectated = true
SLASHER.NestedRange = 1000 -- When nested, this range is used to check for any nearby survivors.
SLASHER.AdditionalAngerMult = 0 -- Used to multiply FrameTime which is then added additionally to the Anger.
SLASHER.JumpStrengthForward = 800 -- forward Velocity used when jumping
SLASHER.JumpStrengthUp = 200 -- up Velocity used when jumping

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.NestedRange = 1000 + (SO * 750) + (50 * additionalSurvivors)
	SLASHER.AdditionalAngerMult = SO + (0.05 * additionalSurvivors)

	SLASHER.JumpStrengthForward = 800 + (SO * 500) + (30 * additionalSurvivors)
	SLASHER.JumpStrengthUp = 200 + (SO * 100)
	if additionalSurvivors > 0 then
		SLASHER.JumpStrengthUp = SLASHER.JumpStrengthUp + (5 * additionalSurvivors)
	end

	SLASHER.ProwlSpeed = 250 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 315 + (7.5 * additionalSurvivors)
	if additionalSurvivors > 0 then -- Only increase the chase duration if we have more than the default survivors.
		SLASHER.ChaseDuration = 9.0 + (1 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	slasher:SetViewOffset(Vector(0, 0, 20))
	slasher:SetCurrentViewOffset(Vector(0, 0, 20))
	slasher.Jump = slasher:GetJumpPower()
	slasher:SetNWBool("ManspiderClimbing", false)

	slasher.TargetPlayer = 0
	slasher.LeapCooldown = 0
	slasher.TimeNested = 0
	slasher.Aggression = 0
end

function SLASHER.OnTickBehaviour(slasher)
	local Target = slasher.TargetPlayer or 0 --Target SteamID
	local LeapCD = slasher.LeapCooldown or 0 --Leap Cooldown
	local TimeNested = slasher.TimeNested or 0 --Time spend nested
	local Aggression = slasher.Aggression or 0 --Aggression

	if LeapCD > 0 then
		slasher.LeapCooldown = LeapCD - FrameTime()
		slasher:SetNWBool("CanLeap", false)
	else
		slasher:SetNWBool("CanLeap", true)
	end

	if not isstring(Target) or Target == 0 then
		slasher.TargetPlayer = ""
	end

	if Target == "" then
		slasher:SetNWBool("CanChase", false)
		slasher:SetNWBool("CanKill", false)

		local survivors = team.GetPlayers(TEAM_SURVIVOR)
		if #survivors == 1 then
			slasher.TargetPlayer = survivors[1]:SteamID64()

			slasher:SetNWBool("CanChase", true)
			slasher:SetNWBool("CanKill", true)
		end
	else
		slasher:SetNWBool("CanChase", true)
		slasher:SetNWBool("CanKill", true)

		local s = player.GetBySteamID64(Target)
		if not IsValid(s) or s:Team() ~= TEAM_SURVIVOR then
			slasher.TargetPlayer = ""
		end
	end

	if slasher:GetNWBool("ManspiderNested") then
		--Find a survivor
		slasher.TimeNested = TimeNested + FrameTime()

		if slasher.NestSound ~= slasher:GetNWBool("ManspiderNested") then
			slasher:StopSound("slashco/slasher/manspider/manspider_idle.mp3")
			slasher:SetJumpPower(0)
			slasher.NestSound = slasher:GetNWBool("ManspiderNested")
		end

		for _, s in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not s:CanBeSeen() then
				continue
			end

			if s:GetPos():Distance(slasher:GetPos()) >= (SLASHER.NestedRange + (TimeNested * 3)) then
				continue
			end

			local tr = util.TraceLine({
				start = slasher:EyePos(),
				endpos = s:WorldSpaceCenter(),
				filter = slasher
			})

			if tr.Entity ~= s then
				continue
			end

			slasher:EmitSound("slashco/slasher/manspider/manspider_scream" .. math.random(1, 4) .. ".mp3")
			slasher.TargetPlayer = s:SteamID64()
			slasher:SetNWBool("ManspiderNested", false)

			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		end

		slasher.Aggression = 0
	else
		--Not nested
		slasher.TimeNested = 0

		if slasher.NestSound ~= slasher:GetNWBool("ManspiderNested") then
			slasher:PlayGlobalSound("slashco/slasher/manspider/manspider_idle.mp3", 50, nil, true)
			slasher:SetJumpPower(slasher.Jump)
			slasher.NestSound = slasher:GetNWBool("ManspiderNested")
		end

		if Target == "" then
			for _, s in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
				if not s:CanBeSeen() then
					continue
				end

				local d = s:GetPos():Distance(slasher:GetPos())

				if d >= 250 then
					continue
				end

				local tr = util.TraceLine({
					start = slasher:EyePos(),
					endpos = s:WorldSpaceCenter(),
					filter = slasher
				})

				if tr.Entity ~= s then
					continue
				end

				slasher.Aggression = Aggression + (FrameTime() * ((250 - d) / 2000)) + (SLASHER.AdditionalAngerMult * FrameTime())

				if Aggression >= 100 then
					slasher.TargetPlayer = s:SteamID64()
					slasher:EmitSound("slashco/slasher/manspider/manspider_scream" .. math.random(1, 4) .. ".mp3")
				end
			end
		else
			slasher.Aggression = 0
		end
	end

	if slasher:GetNWString("ManspiderTarget") ~= Target then
		slasher:SetNWString("ManspiderTarget", Target)
	end

	if TimeNested > 50 then
		if slasher:GetNWBool("ManspiderCanLeaveNest") ~= true then
			slasher:SetNWBool("ManspiderCanLeaveNest", true)
		end
	else
		if slasher:GetNWBool("ManspiderCanLeaveNest") ~= false then
			slasher:SetNWBool("ManspiderCanLeaveNest", false)
		end
	end

	slasher:SetEyeSight(SLASHER.Eyesight)
	slasher:SetPerception(SLASHER.Perception)
end

function SLASHER.OnHitByTeslaCoil(slasher)
	slasher.TargetPlayer = "" -- Reset prey when we got hit by a tesla coil.
end

function SLASHER.OnKillPlayer(slasher, target)
	slasher.TargetPlayer = "" -- We killed our prey, so reset it or else he might persist in case he had multiple lives
end

function SLASHER.OnPrimaryFire(slasher, target)
	if not IsValid(target) or not target:IsPlayer() then
		return
	end

	if target:SteamID64() ~= slasher.TargetPlayer then
		slasher:ChatPrint("You can only kill your Prey.")
		return
	else
		SlashCo.Jumpscare(slasher, target)
	end
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("ManspiderNested")
end

function SLASHER.CanBeSeen(ply)
	if SERVER then
		return
	end

	if ply:IsVisible() and not ply:GetNWBool("ManspiderNested") then
		return true
	end
end

function SLASHER.OnSecondaryFire(slasher)
	local target = slasher:GetEyeTrace().Entity

	if not target:IsPlayer() then
		return
	end

	if target:SteamID64() ~= slasher.TargetPlayer then
		return
	end

	SlashCo.StartChaseMode(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher.TargetPlayer ~= "" then
		return
	end
	
	if not slasher:IsOnGround() then
		return
	end

	if not slasher:GetNWBool("ManspiderNested") then
		if not SlashCo.IsPositionLegalForSlashers(slasher:GetPos()) then
			return
		end

		slasher:SetNWBool("ManspiderNested", true)

		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetSlowWalkSpeed(1)
	else
		if slasher.TimeNested > 30 or not slasher:IsOnGround() then
			slasher:SetNWBool("ManspiderNested", false)

			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		end
	end
end

local function ManspiderClimbCheck(ply, mv)
	local eyeDir = ply:EyeAngles():Forward()
	local traceDist = 50

	local startPos = ply:EyePos()
	local endPos = startPos + eyeDir * traceDist

	local tr = util.TraceLine({
		start = startPos,
		endpos = endPos,
		mask = MASK_VISIBLE,
		filter = ply
	})

	if not tr.Hit then
		for yawOffset = -30, 30, 15 do
			local offsetDir = (ply:EyeAngles() + Angle(0, yawOffset, 0)):Forward()
			tr = util.TraceLine({
				start = startPos,
				endpos = startPos + offsetDir * traceDist,
				mask = MASK_VISIBLE,
				filter = ply
			})
			if tr.Hit then break end
		end
	end

	return tr
end

local function ManspiderKillCheck(ply, mv)
	if not ply:GetNWBool("ManspiderLeaping") then return end

	local velocity = ply:GetVelocity()
	if velocity:Length() < 200 then return nil end

	local speedDir = velocity:GetNormalized()
	local traceDist = 200

	local startPos = ply:GetPos() + ply:OBBCenter()
	local endPos = startPos + speedDir * traceDist

	local trLine = util.TraceLine({
		start = startPos,
		endpos = endPos,
		filter = ply
	})

	if trLine.Hit then
		local mins = Vector(-20, -20, 0)
		local maxs = Vector(20, 20, 32)
		local len = 64
		local endPosition = startPos + speedDir * len

		local trHull = util.TraceHull({
			start = startPos,
			endpos = endPosition,
			mins = mins,
			maxs = maxs,
			filter = ply
		})

		return trHull
	end

	return nil
end

local vectorAddNormal = Vector(0, 0, 0)
local vectorAddHigh = Vector(0, 0, 64)
function SLASHER.Move(ply, mv)
	if ply:GetNWBool("ManspiderClimbing") then
		ply:SetRunSpeed(1)
		ply:SetWalkSpeed(1)
		ply:SetSlowWalkSpeed(1)

		return true
	end

	ply:SetRunSpeed(SLASHER.ProwlSpeed)
	ply:SetWalkSpeed(SLASHER.ProwlSpeed)
	ply:SetSlowWalkSpeed(SLASHER.ProwlSpeed)

	if ply:OnGround() or ply:WaterLevel() > 0 then
		ply:SetNWString("ManspiderClimbEntity", "")
		ply:SetNWBool("ManspiderLeaping", false)
		return
	end

	local tr = ManspiderClimbCheck(ply, mv)
	if !tr.HitSky and tr.Hit and tr.HitWorld and tr.HitNormal.z <= 0 then
		if SERVER then
			if tr.HitNormal.z >= -0.2 then
				local vectoradd = vectorAddNormal
				local trace = {
					start = ply:GetPos(),
					endpos = ply:GetPos() + -tr.HitNormal * 50,
					filter = ply
				}
				local trr = util.TraceEntity(trace, ply)

				if not trr.Hit or not tr.HitWorld then
					local trace = {
						start = ply:GetPos(),
						endpos = ply:GetPos() + vectorAddHigh,
						filter = ply,
						mins = ply:OBBMins(),
						maxs = ply:OBBMaxs(),
					}
					local trr = util.TraceHull(trace)

					if (!trr.Hit) then
						vectoradd = vectorAddHigh
					else
						return
					end
				end

				local newpos = tr.HitPos + -ply:GetViewOffset() + tr.HitNormal * 28
				local trace2 = { start = newpos, endpos = newpos, filter = ply }
				local trr2 = util.TraceEntity(trace2, ply) 
				if (trr2.Hit) then return end

				ply:SetNWString("ManspiderClimbEntity", "wall")
				ply:SetNWBool("ManspiderLeaping", false)
				mv:SetOrigin(vectoradd + tr.HitPos + -ply:GetViewOffset() + tr.HitNormal * 28)
			else
				if ply:GetNWString("ManspiderClimbEntity", "wall") == "ceiling" then
					return
				end

				ply:SetNWString("ManspiderClimbEntity", "ceiling")
				ply:SetNWBool("ManspiderLeaping", false)

				local trace = { start = ply:GetPos(), endpos = ply:GetPos() + Vector(0,0,80), filter = ply }
				local trr = util.TraceEntity(trace, ply)
				if (trr.Hit) then
					mv:SetOrigin(trr.HitPos + trr.HitNormal * 2)
				else
					mv:SetOrigin(tr.HitPos + -ply:GetViewOffset() + tr.HitNormal * 7)
				end
			end
			
			ply:SetNWBool("ManspiderClimbing", true)
		end

		ply:SetMoveType(MOVETYPE_NONE)
		return
	end

	if CLIENT then return end

	local climbEntity = ply:GetNWString("ManspiderClimbEntity")
	if climbEntity ~= "" then return end
	
	local tr = ManspiderKillCheck(ply, mv)
	if !tr then return end

	-- RaphaelIT7: tr.Entity will never be nil - it'll be NULL, and we can use IsPlayer on NULL and if it returns true we can also be sure that it's valid-
	if not tr.Entity:IsPlayer() then return end
	
	local victim = tr.Entity
	victim:TakeDamage(50, ply, ply)

	local edata = EffectData()
	edata:SetOrigin(tr.HitPos)
	edata:SetEntity(victim)
	util.Effect("BloodImpact", edata)

	victim:EmitSound("physics/body/body_medium_break3.wav")
	ply:SetNWString("ManspiderClimbEntity", "")
end

function SLASHER.OnSpecialAbilityFire(slasher)
	if slasher:GetNWBool("ManspiderClimbing") then 
		slasher:SetNWBool("ManspiderClimbing", false)
		slasher:SetNWString("ManspiderClimbEntity", "")
		slasher:SetMoveType(MOVETYPE_WALK)
		slasher:SetVelocity((slasher:EyeAngles():Forward() * 400) + Vector(0, 0, 200))
		slasher:SetNWBool("ManspiderLeaping", true)

		return
	end

	if slasher.LeapCooldown > 0 then
		return
	end

	if not slasher:IsOnGround() then
		return
	end

	if slasher:GetNWBool("ManspiderNested") then
		return
	end

	slasher.LeapCooldown = 15

	slasher:Freeze(true)
	local idx = math.random(1, 4)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/manspider/manspider_scream" .. idx .. ".mp3",
		identifier = "ManspiderScream" .. idx,
		minDistance = 700 * SlashCo.MapSize,
		maxDistance = 1240 * SlashCo.MapSize,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	timer.Simple(1, function()
		if not IsValid(slasher) then
			return
		end
		
		if slasher:GetNWBool("ManspiderNested") then
			return
		end

		slasher:SetNWBool("ManspiderLeaping", true)
		slasher:SetVelocity((slasher:EyeAngles():Forward() * SLASHER.JumpStrengthForward) + Vector(0, 0, SLASHER.JumpStrengthUp))
		slasher:Freeze(false)
	end)
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local manspider_nest = ply:GetNWBool("ManspiderNested")

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_WALK
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	if manspider_nest then
		ply.CalcSeqOverride = ply:LookupSequence("nest")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/manspider/manspider_step.mp3",
			identifier = "ManspiderFootstep",
			group = "SlasherFootstep",
			minDistance = 250,
			maxDistance = 550,
			entity = ply,
			volume = 1,
			fadeIn = 0,
			unreliable = true,
		})
	end

	return true
end

local mat = Material("lights/white")
local function targetPaint(ply)
	if not IsValid(ply) or not ply:CanBeSeen() then
		return
	end

	cam.Start3D()
	render.MaterialOverride(mat)
	render.SetColorModulation(1, 0, 0)

	ply:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride("")
	cam.End3D()
end

local nestTable = {
	default = Material("slashco/ui/icons/slasher/s_9"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_9"))
	hud:SetTitle("Manspider")

	hud:AddControl("R", "nest", nestTable)
	hud:ChaseAndKill()
	hud:UntieControl("LMB")
	hud:UntieControl("RMB")
	hud:TieControlVisible("LMB", "CanKill")
	hud:TieControlVisible("RMB", "CanChase")
	hud:AddControl("F", "leap", Material("slashco/ui/icons/slasher/s_punch"))
	hud:TieControlVisible("F", "ManspiderNested", true, false, false)
	hud:TieControl("F", "CanLeap", false, true)

	hud.prevTarget = -1
	hud.prevNested = -1
	hud.prevLeave = -1
	hud.prevHide = -1
	function hud.AlsoThink()
		local target = GameData.LocalPlayer:GetNWString("ManspiderTarget")
		if target ~= hud.prevTarget then
			if target == "" then
				hook.Remove("SlashCo:DrawHUD", "SlashCo:SlasherHUD")
			else
				local targetEnt
				for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
					if ply:SteamID64() == target then
						targetEnt = ply
						break
					end
				end

				hook.Add("SlashCo:DrawHUD", "SlashCo:SlasherHUD", function()
					if GameData.LocalPlayer:Team() ~= TEAM_SLASHER or not IsValid(targetEnt) then
						hook.Remove("SlashCo:DrawHUD", "SlashCo:SlasherHUD")
						return
					end

					targetPaint(targetEnt)

					local distColor = math.Clamp(GameData.LocalPlayer:GetPos():Distance(targetEnt:GetPos()), 0, 2048) / 16
					draw.SimpleText("Your prey: " .. targetEnt:Name(), "ItemFontTip",
							ScrW() / 2, ScrH() / 2, Color(255 - distColor, 0, 0, 255),
							TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end)
			end
			hud.prevTarget = target
		end

		local nested = GameData.LocalPlayer:GetNWBool("ManspiderNested")
		if nested ~= hud.prevNested then
			hud:ShakeControl("R")
			if nested then
				hud:SetControlText("R", "waiting for prey")
				hud:SetControlEnabled("R", false)
			else
				hud:SetControlText("R", "nest")
			end

			hud.prevNested = nested
		end
		local climbing = GameData.LocalPlayer:GetNWBool("ManspiderClimbing")
		if climbing then
			hud:ShakeControl("F")
		end

		local hide = SlashCo.IsPositionLegalForSlashers(GameData.LocalPlayer:GetPos())
		if hud.prevHide ~= hide then
			if not nested then
				hud:SetControlEnabled("R", hide)
			end

			hud.prevHide = hide
		end

		local canLeave = GameData.LocalPlayer:GetNWBool("ManspiderCanLeaveNest")
		if canLeave ~= hud.prevLeave then
			if nested and canLeave then
				hud:SetControlText("R", "abandon nest")
				hud:SetControlEnabled("R", true)
				hud:ShakeControl("R")
			end

			hud.prevLeave = canLeave
		end
	end
end

if CLIENT then
	hook.Add("SlashCo:DrawHUD", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Manspider") == true then
			if GameData.LocalPlayer.mans_f == nil then
				GameData.LocalPlayer.mans_f = 0
			end
			GameData.LocalPlayer.mans_f = GameData.LocalPlayer.mans_f + (FrameTime() * 20)
			if GameData.LocalPlayer.mans_f > 59 then
				GameData.LocalPlayer.mans_f = 58
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_9")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.mans_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.mans_f = nil
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Manspider")