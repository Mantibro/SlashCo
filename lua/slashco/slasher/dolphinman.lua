local SLASHER = {}

SLASHER.Name = "Dolphinman"
SLASHER.ID = 16
SLASHER.Class = 1
SLASHER.DangerLevel = 2
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/dolphinman/dolphinman.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 0.25
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 315
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 0.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/dolfin_kill.mp3"
SLASHER.Description = "Dolphinman_desc"
SLASHER.ProTip = "Dolphinman_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★☆"

SLASHER.OnTickBehaviour = function(slasher)
	local v1 = slasher.SlasherValue1 --Hunt power

	local hunt_boost = 0

	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher:GetNWBool("DolphinInHiding") then
		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetSlowWalkSpeed(1)

		--get hunt yes.....
		if v1 < 100 then
			slasher.SlasherValue1 = v1 + (FrameTime() / (2 - ((SO - 1) / 2)))
		end

		--Survivore finderore

		if SlashCo.CurRound.EscapeHelicopterSummoned then
			slasher:SetNWBool("DolphinFound", true)

			SlashCo.PlayGlobalSound("slashco/slasher/dolfin_call.wav", 85, slasher)
			SlashCo.PlayGlobalSound("slashco/slasher/dolfin_call_far.wav", 145, slasher)

			timer.Simple(10, function()
				slasher:SetNWBool("DolphinFound", false)
				slasher:SetNWBool("DolphinInHiding", false)
				slasher:SetNWBool("DolphinHunting", true)
			end)
		end

		for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
			local s = team.GetPlayers(TEAM_SURVIVOR)[i]

			if s:GetPos():Distance(slasher:GetPos()) < 500 then
				local tr = util.TraceLine({
					start = slasher:EyePos(),
					endpos = s:GetPos() + Vector(0, 0, 40),
					filter = slasher,
					mask = MASK_VISIBLE
				})

				if tr.Entity == s then
					slasher:SetNWBool("DolphinFound", true)

					SlashCo.PlayGlobalSound("slashco/slasher/dolfin_call.wav", 85, slasher)
					SlashCo.PlayGlobalSound("slashco/slasher/dolfin_call_far.wav", 145, slasher)

					timer.Simple(10, function()
						slasher:SetNWBool("DolphinFound", false)
						slasher:SetNWBool("DolphinInHiding", false)

						slasher:SetNWBool("DolphinHunting", true)
					end)
				end
			end
		end

		if slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", false)
		end
	else
		if not slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", true)
		end

		--urgh i can move yes lmao

		if not slasher:GetNWBool("DolphinHunting") then
			--auggh im slow :((

			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
		else
			--you're fucking dead

			slasher:SetRunSpeed(SLASHER.ChaseSpeed)
			slasher:SetWalkSpeed(SLASHER.ChaseSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed)
			slasher:SetNWInt("Slasher_Perception", SLASHER.Perception * 1.5 ^ (slasher.DolphinKills or 0))

			hunt_boost = 1

			--oh fuck i'm losing my hunt!!
			slasher.SlasherValue1 = v1 - (FrameTime() / 1 + SO)

			--damn shit
			if v1 <= 0 then
				slasher:SetNWBool("DolphinHunting", false)

				slasher:StopSound("slashco/slasher/dolfin_call.wav")
				slasher:StopSound("slashco/slasher/dolfin_call_far.wav")
				for i = 1, 8 do
					--WHY THE FUCK DO I HAVE TO DO THIS HOLY SHIT
					timer.Simple(i / 10, function()
						slasher:StopSound("slashco/slasher/dolfin_call.wav")
						slasher:StopSound("slashco/slasher/dolfin_call_far.wav")
					end)
				end
			end
		end
	end

	if slasher:GetNWInt("DolphinHunt") ~= math.floor(v1) then
		slasher:SetNWInt("DolphinHunt", math.floor(v1))
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight + (hunt_boost * 5))
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception + (hunt_boost * 3))
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if SlashCo.Jumpscare(slasher, target) then
		slasher.SlasherValue1 = math.min(100, slasher.SlasherValue1 + 25)
		slasher.DolphinKills = (slasher.DolphinKills or 0) + 1
	end
end

SLASHER.OnSecondaryFire = function(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
	if not slasher:GetNWBool("DolphinHunting") and not slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") then
		if not SlashCo.IsPositionLegalForSlashers(slasher:GetPos()) then
			return
		end

		slasher:SetNWBool("DolphinInHiding", true)

		return
	end

	if slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") and slasher.SlasherValue1 >= 5 then
		slasher:SetNWBool("DolphinInHiding", false)

		slasher.SlasherValue1 = slasher.SlasherValue1 - math.floor(slasher.SlasherValue1 / 2)
	end
end

SLASHER.OnSpecialAbilityFire = function(slasher)
end

SLASHER.Animator = function(ply)
	local hunt = ply:GetNWBool("DolphinHunting")
	local hide = ply:GetNWBool("DolphinInHiding")
	local found = ply:GetNWBool("DolphinFound")

	if ply:IsOnGround() then
		if not hunt then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("hunt")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	if hide then
		ply.CalcSeqOverride = ply:LookupSequence("hide")
	end

	if found then
		ply.CalcSeqOverride = ply:LookupSequence("found")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		ply:EmitSound("slashco/slasher/amogus_step" .. math.random(1, 3) .. ".wav", 75, 130)
		return true
	end

	if CLIENT then
		return true
	end
end

local hideIcons = {
	["default"] = Material("slashco/ui/icons/slasher/s_16"),
	["unhide"] = Material("slashco/ui/icons/slasher/s_10_a1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_16"))
	hud:SetTitle("Dolphinman")

	hud:AddControl("R", "hide", hideIcons)
	hud:ChaseAndKill(true)
	hud:TieControlVisible("LMB", "DolphinInHiding", true, true, false)
	hud:TieControlVisible("R", "DolphinHunting", true, true, false)
	hud:TieControlText("R", "DolphinInHiding", "unhide", "hide", true, false)

	hud:AddMeter("hunt")
	hud:TieMeterInt("hunt", "DolphinHunt")

	hud.prevHide = -1
	function hud.AlsoThink()
		local hide = not LocalPlayer():GetNWBool("DolphinInHiding") or (not LocalPlayer():GetNWBool("DolphinFound") and LocalPlayer():GetNWInt("DolphinHunt") >= 5)
		hide = SlashCo.IsPositionLegalForSlashers(LocalPlayer():GetPos()) and hide

		if hud.prevHide ~= hide then
			hud:SetControlEnabled("R", hide)
			hud.prevHide = hide
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Dolphinman") == true then
			if LocalPlayer().dolf_f == nil then
				LocalPlayer().dolf_f = 0
			end
			LocalPlayer().dolf_f = LocalPlayer().dolf_f + (FrameTime() * 20)
			if LocalPlayer().dolf_f > 29 then
				LocalPlayer().dolf_f = 28
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_16")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().dolf_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().dolf_f = nil
		end
	end)
	hook.Add("Tick", "DolphinmanLight", function()
		for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do

			if v == LocalPlayer() then
				return
			end

			if v:GetNWBool("DolphinHunting") then
				local tlight = DynamicLight(v:EntIndex() + 915)
				if (tlight) then
					tlight.pos = v:LocalToWorld(Vector(0, 0, 20))
					tlight.r = 249
					tlight.g = 215
					tlight.b = 10
					tlight.brightness = 5
					tlight.Decay = 1000
					tlight.Size = 500
					tlight.DieTime = CurTime() + 1
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Dolphinman")