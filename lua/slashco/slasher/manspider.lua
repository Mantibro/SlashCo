local SLASHER = {}

SLASHER.Name = "Manspider"
SLASHER.ID = 9
SLASHER.Class = 1
SLASHER.DangerLevel = 2
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/manspider/manspider.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 5
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 290
SLASHER.Perception = 1.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 1200
SLASHER.ChaseRadius = 0.9
SLASHER.ChaseDuration = 9.0
SLASHER.ChaseCooldown = 2
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/manspider_chase.wav"
SLASHER.KillSound = "slashco/slasher/manspider_kill.mp3"
SLASHER.Description = "Manspider_desc"
SLASHER.ProTip = "Manspider_tip"
SLASHER.SpeedRating = "★★★☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★☆☆☆☆"
SLASHER.CannotBeSpectated = true

SLASHER.OnSpawn = function(slasher)
	slasher:SetViewOffset(Vector(0, 0, 20))
	slasher:SetCurrentViewOffset(Vector(0, 0, 20))
	slasher.Jump = slasher:GetJumpPower()
end

SLASHER.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --Target SteamID
	local v2 = slasher.SlasherValue2 --Leap Cooldown
	local v3 = slasher.SlasherValue3 --Time spend nested
	local v4 = slasher.SlasherValue4 --Aggression

	if v2 > 0 then
		slasher.SlasherValue2 = v2 - FrameTime()
		slasher:SetNWBool("CanLeap", false)
	else
		slasher:SetNWBool("CanLeap", true)
	end

	if not isstring(v1) or v1 == 0 then
		slasher.SlasherValue1 = ""
	end

	if v1 == "" then
		slasher:SetNWBool("CanChase", false)
		slasher:SetNWBool("CanKill", false)

		local numP = team.NumPlayers(TEAM_SURVIVOR)
		if numP < 2 and numP > 0 then
			v1 = team.GetPlayers(TEAM_SURVIVOR)[1]:SteamID64()

			slasher:SetNWBool("CanChase", true)
			slasher:SetNWBool("CanKill", true)
		end
	else
		slasher:SetNWBool("CanChase", true)
		slasher:SetNWBool("CanKill", true)

		local s = player.GetBySteamID64(v1)
		if not IsValid(s) or s:Team() ~= TEAM_SURVIVOR then
			slasher.SlasherValue1 = ""
		end
	end

	if slasher:GetNWBool("ManspiderNested") then
		--Find a survivor
		slasher.SlasherValue3 = v3 + FrameTime()

		if slasher.NestSound ~= slasher:GetNWBool("ManspiderNested") then
			slasher:StopSound("slashco/slasher/manspider_idle.wav")
			slasher:SetJumpPower(0)
			slasher.NestSound = slasher:GetNWBool("ManspiderNested")
		end

		for _, s in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not s:CanBeSeen() then
				continue
			end

			if s:GetPos():Distance(slasher:GetPos()) >= (1000 + (v3 * 3) + (SO * 750)) then
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

			slasher:EmitSound("slashco/slasher/manspider_scream" .. math.random(1, 4) .. ".mp3")
			slasher.SlasherValue1 = s:SteamID64()
			slasher:SetNWBool("ManspiderNested", false)

			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		end

		slasher.SlasherValue4 = 0
	else
		--Not nested
		slasher.SlasherValue3 = 0

		if slasher.NestSound ~= slasher:GetNWBool("ManspiderNested") then
			slasher:PlayGlobalSound("slashco/slasher/manspider_idle.wav", 50)
			slasher:SetJumpPower(slasher.Jump)
			slasher.NestSound = slasher:GetNWBool("ManspiderNested")
		end

		if v1 == "" then
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

				slasher.SlasherValue4 = v4 + (FrameTime() * ((250 - d) / 2000)) + (SO * FrameTime())

				if v4 > 100 then
					slasher.SlasherValue1 = s:SteamID64()
					slasher:EmitSound("slashco/slasher/manspider_scream" .. math.random(1, 4) .. ".mp3")
				end
			end
		else
			slasher.SlasherValue4 = 0
		end
	end

	if slasher:GetNWString("ManspiderTarget") ~= v1 then
		slasher:SetNWString("ManspiderTarget", v1)
	end

	if v3 > 50 then
		if slasher:GetNWBool("ManspiderCanLeaveNest") ~= true then
			slasher:SetNWBool("ManspiderCanLeaveNest", true)
		end
	else
		if slasher:GetNWBool("ManspiderCanLeaveNest") ~= false then
			slasher:SetNWBool("ManspiderCanLeaveNest", false)
		end
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if not IsValid(target) or not target:IsPlayer() then
		return
	end

	if target:SteamID64() ~= slasher.SlasherValue1 then
		slasher:ChatPrint("You can only kill your Prey.")
		return
	else
		SlashCo.Jumpscare(slasher, target)
	end
end

SLASHER.Thirdperson = function(ply)
	return ply:GetNWBool("ManspiderNested")
end

SLASHER.CanBeSeen = function(ply)
	if SERVER then
		return
	end

	if ply:GetNWBool("SlashCoVisible", true) and not ply:GetNWBool("ManspiderNested") then
		return true
	end
end

SLASHER.OnSecondaryFire = function(slasher)
	local target = slasher:GetEyeTrace().Entity

	if not target:IsPlayer() then
		return
	end

	if target:SteamID64() ~= slasher.SlasherValue1 then
		return
	end

	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
	if slasher.SlasherValue1 ~= "" then
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
		if slasher.SlasherValue3 > 50 then
			slasher:SetNWBool("ManspiderNested", false)

			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		end
	end
end

SLASHER.OnSpecialAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher.SlasherValue2 > 0 then
		return
	end

	if not slasher:IsOnGround() then
		return
	end

	if not slasher:GetNWBool("InSlasherChaseMode") then
		return
	end

	slasher.SlasherValue2 = 15

	slasher:Freeze(true)
	slasher:EmitSound("slashco/slasher/manspider_scream" .. math.random(1, 4) .. ".mp3")

	timer.Simple(1, function()
		if not IsValid(slasher) then
			return
		end

		local strength_forward = 800 + (SO * 500)
		local strength_up = 200 + (SO * 100)

		slasher:SetVelocity((slasher:EyeAngles():Forward() * strength_forward) + Vector(0, 0, strength_up))
		slasher:Freeze(false)
	end)
end

SLASHER.Animator = function(ply)
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

SLASHER.Footstep = function(ply)
	if SERVER then
		ply:EmitSound("slashco/slasher/manspider_step.mp3")
		return true
	end

	if CLIENT then
		return true
	end
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
	cam.End3D()
end

local nestTable = {
	default = Material("slashco/ui/icons/slasher/s_9"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_9"))
	hud:SetTitle("Manspider")

	hud:AddControl("R", "nest", nestTable)
	hud:ChaseAndKill()
	hud:UntieControl("LMB")
	hud:UntieControl("RMB")
	hud:TieControlVisible("LMB", "CanKill")
	hud:TieControlVisible("RMB", "CanChase")
	hud:AddControl("F", "leap", Material("slashco/ui/icons/slasher/s_punch"))
	hud:TieControlVisible("F", "InSlasherChaseMode", true, false, true)
	hud:TieControl("F", "CanLeap", false, true)

	hud.prevTarget = -1
	hud.prevNested = -1
	hud.prevLeave = -1
	hud.prevHide = -1
	function hud.AlsoThink()
		local target = LocalPlayer():GetNWString("ManspiderTarget")
		if target ~= hud.prevTarget then
			if target == "" then
				hook.Remove("HUDPaint", "SlashCoPreyReal")
			else
				local targetEnt
				for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
					if ply:SteamID64() == target then
						targetEnt = ply
						break
					end
				end

				hook.Add("HUDPaint", "SlashCoPreyReal", function()
					if LocalPlayer():Team() ~= TEAM_SLASHER or not IsValid(targetEnt) then
						hook.Remove("HUDPaint", "SlashCoPreyReal")
					end

					targetPaint(targetEnt)

					local distColor = math.Clamp(LocalPlayer():GetPos():Distance(targetEnt:GetPos()), 0, 2048) / 16
					draw.SimpleText("Your prey: " .. targetEnt:Name(), "ItemFontTip",
							ScrW() / 2, ScrH() / 2, Color(255 - distColor, 0, 0, 255),
							TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end)
			end
			hud.prevTarget = target
		end

		local nested = LocalPlayer():GetNWBool("ManspiderNested")
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

		local hide = SlashCo.IsPositionLegalForSlashers(LocalPlayer():GetPos())
		if hud.prevHide ~= hide then
			if not nested then
				hud:SetControlEnabled("R", hide)
			end

			hud.prevHide = hide
		end

		local canLeave = LocalPlayer():GetNWBool("ManspiderCanLeaveNest")
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
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Manspider") == true then
			if LocalPlayer().mans_f == nil then
				LocalPlayer().mans_f = 0
			end
			LocalPlayer().mans_f = LocalPlayer().mans_f + (FrameTime() * 20)
			if LocalPlayer().mans_f > 59 then
				LocalPlayer().mans_f = 58
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_9")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().mans_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().mans_f = nil
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Manspider")