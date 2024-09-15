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
SLASHER.ChaseSpeed = 296
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

SLASHER.OnSpawn = function(slasher)
	slasher:SetViewOffset(Vector(0, 0, 20))
	slasher:SetCurrentViewOffset(Vector(0, 0, 20))
	SlashCo.PlayGlobalSound("slashco/slasher/manspider_idle.wav", 50, slasher)
end

SLASHER.PickUpAttempt = function()
	return false
end

SLASHER.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --Target SteamID
	local v2 = slasher.SlasherValue2 --Leap Cooldown
	local v3 = slasher.SlasherValue3 --Time spend nested
	local v4 = slasher.SlasherValue4 --Aggression

	if v2 > 0 then
		slasher.SlasherValue2 = v2 - FrameTime()
	end

	if not isstring(v1) or v1 == 0 then
		slasher.SlasherValue1 = ""
	end

	if v1 == "" then
		slasher:SetNWBool("CanChase", false)
		slasher:SetNWBool("CanKill", false)

		if team.NumPlayers(TEAM_SURVIVOR) < 2 and team.NumPlayers(TEAM_SURVIVOR) > 0 then
			v1 = team.GetPlayers(TEAM_SURVIVOR)[1]:SteamID64()

			slasher:SetNWBool("CanChase", true)
			slasher:SetNWBool("CanKill", true)
		end
	else
		slasher:SetNWBool("CanChase", true)
		slasher:SetNWBool("CanKill", true)

		if not IsValid(player.GetBySteamID64(v1)) or player.GetBySteamID64(v1):Team() ~= TEAM_SURVIVOR then
			slasher.SlasherValue1 = ""
		end
	end

	for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
		--Switch Target if too close

		local s = team.GetPlayers(TEAM_SURVIVOR)[i]

		local d = s:GetPos():Distance(slasher:GetPos())

		if d < (150) then
			local tr = util.TraceLine({
				start = slasher:EyePos(),
				endpos = s:GetPos() + Vector(0, 0, 40),
				filter = slasher
			})

			if tr.Entity == s then
				if slasher.SlasherValue1 ~= s:SteamID64() then
					slasher.SlasherValue1 = s:SteamID64()
					slasher:EmitSound("slashco/slasher/manspider_scream" .. math.random(1, 4) .. ".mp3")
				end
			end
		end
	end

	if slasher:GetNWBool("ManspiderNested") then
		--Find a survivor
		slasher.SlasherValue3 = v3 + FrameTime()

		for i = 1, team.NumPlayers(TEAM_SURVIVOR) do

			local s = team.GetPlayers(TEAM_SURVIVOR)[i]

			if s:GetPos():Distance(slasher:GetPos()) < (1000 + (v3 * 3) + (SO * 750)) then
				local tr = util.TraceLine({
					start = slasher:EyePos(),
					endpos = s:GetPos() + Vector(0, 0, 40),
					filter = slasher
				})

				if tr.Entity == s then
					slasher:EmitSound("slashco/slasher/manspider_scream" .. math.random(1, 4) .. ".mp3")
					slasher.SlasherValue1 = s:SteamID64()
					slasher:SetNWBool("ManspiderNested", false)

					slasher:SetRunSpeed(SLASHER.ProwlSpeed)
					slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
					slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
				end
			end
		end

		slasher.SlasherValue4 = 0
	else
		--Not nested
		slasher.SlasherValue3 = 0

		if v1 == "" then
			for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
				local s = team.GetPlayers(TEAM_SURVIVOR)[i]

				local d = s:GetPos():Distance(slasher:GetPos())

				if d < (1000) then
					local tr = util.TraceLine({
						start = slasher:EyePos(),
						endpos = s:GetPos() + Vector(0, 0, 40),
						filter = slasher
					})

					if tr.Entity == s then
						slasher.SlasherValue4 = v4 + (FrameTime() + ((1000 - d) / 10000)) + (SO * FrameTime())

						if v4 > 100 then
							slasher.SlasherValue1 = s:SteamID64()
							slasher:EmitSound("slashco/slasher/manspider_scream" .. math.random(1, 4) .. ".mp3")
						end
					end
				end
			end
		else
			slasher.SlasherValue4 = 0
		end
	end

	if slasher:GetNWString("ManspiderTarget") ~= v1 then
		slasher:SetNWString("ManspiderTarget", v1)
	end

	if v3 > 100 then
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
		for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
			local s = team.GetPlayers(TEAM_SURVIVOR)[i]
			if s:GetPos():Distance(slasher:GetPos()) < 1600 then

				slasher:ChatPrint("Cannot Nest here, a Survivor is too close. . .")
				return
			end
		end

		slasher:SetNWBool("ManspiderNested", true)

		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetSlowWalkSpeed(1)
	else
		if slasher.SlasherValue3 > 100 then
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

	slasher.SlasherValue2 = 4

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
	hud:TieControlVisible("F", "InSlasherChaseMode", true, true, true)

	hud.prevTarget = not LocalPlayer():GetNWString("ManspiderTarget")
	hud.prevNested = not LocalPlayer():GetNWBool("ManspiderNested")
	hud.prevLeave = not LocalPlayer():GetNWBool("ManspiderCanLeaveNest")
	function hud.AlsoThink()
		local target = LocalPlayer():GetNWString("ManspiderTarget")
		if target ~= hud.prevTarget then
			if target == "" then
				for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
					if not ply:CanBeSeen() then
						continue
					end

					ply:SetMaterial("")
					ply:SetColor(color_white)
					ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
				end
				hook.Remove("HUDPaint", "SlashCoPreyReal")
			else
				local targetEnt
				for _, ply in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
					if not ply:CanBeSeen() then
						continue
					end

					if ply:SteamID64() == target then
						targetEnt = ply
						ply:SetMaterial("lights/white")
						ply:SetColor(Color(255, 0, 0, 255))
						ply:SetRenderMode(RENDERMODE_TRANSCOLOR)

						continue
					end

					ply:SetMaterial("")
					ply:SetColor(color_white)
					ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
				end

				hook.Add("HUDPaint", "SlashCoPreyReal", function()
					if LocalPlayer():Team() ~= TEAM_SLASHER or not IsValid(targetEnt) then
						hook.Remove("HUDPaint", "SlashCoPreyReal")
					end

					local distColor = math.Clamp(LocalPlayer():GetPos():Distance(targetEnt:GetPos()), 0, 2048) / 16
					draw.SimpleText("Your Prey: " .. targetEnt:Name(), "ItemFontTip",
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
				hud:SetControlEnabled("R", true)
			end

			hud.prevNested = nested
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