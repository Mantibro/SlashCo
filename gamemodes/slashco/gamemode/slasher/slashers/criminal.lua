SlashCoSlasher.Criminal = {}

SlashCoSlasher.Criminal.Name = "Criminal"
SlashCoSlasher.Criminal.ID = 12
SlashCoSlasher.Criminal.Class = 3
SlashCoSlasher.Criminal.DangerLevel = 3
SlashCoSlasher.Criminal.IsSelectable = true
SlashCoSlasher.Criminal.Model = "models/slashco/slashers/criminal/criminal.mdl"
SlashCoSlasher.Criminal.GasCanMod = 0
SlashCoSlasher.Criminal.KillDelay = 10
SlashCoSlasher.Criminal.ProwlSpeed = 200
SlashCoSlasher.Criminal.ChaseSpeed = 310
SlashCoSlasher.Criminal.Perception = 1.0
SlashCoSlasher.Criminal.Eyesight = 3
SlashCoSlasher.Criminal.KillDistance = 110
SlashCoSlasher.Criminal.ChaseRange = 0
SlashCoSlasher.Criminal.ChaseRadius = 1
SlashCoSlasher.Criminal.ChaseDuration = 0.0
SlashCoSlasher.Criminal.ChaseCooldown = 10
SlashCoSlasher.Criminal.JumpscareDuration = 4
SlashCoSlasher.Criminal.ChaseMusic = ""
SlashCoSlasher.Criminal.KillSound = "slashco/slasher/criminal_kill.mp3"
SlashCoSlasher.Criminal.Description = "The Tormented Slasher which relies on confusion and\nentrapment to catch his victims.\n\n-Criminal is only able to attack while standing still.\n-He can summon clones around himself as a tool of confusion.\n"
SlashCoSlasher.Criminal.ProTip = "-This Slasher was seen surrounded by fake copies of itself."
SlashCoSlasher.Criminal.SpeedRating = "★★★★☆"
SlashCoSlasher.Criminal.EyeRating = "★★☆☆☆"
SlashCoSlasher.Criminal.DiffRating = "★★★★★"

SlashCoSlasher.Criminal.OnSpawn = function(slasher)
	local clone = ents.Create("sc_crimclone")

	clone:SetPos(slasher:GetPos())
	clone:SetAngles(slasher:GetAngles())
	clone.AssignedSlasher = slasher:SteamID64()
	clone.IsMain = true
	clone:Spawn()
	clone:Activate()

	slasher:SetColor(Color(0, 0, 0, 0))
	slasher:DrawShadow(false)
	slasher:SetRenderMode(RENDERMODE_TRANSALPHA)
	slasher:SetNoDraw(true)
end

SlashCoSlasher.Criminal.PickUpAttempt = function(ply)
	return false
end

SlashCoSlasher.Criminal.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	v1 = slasher.SlasherValue1 --Cloning Duration

	local final_eyesight = SlashCoSlasher.Criminal.Eyesight
	local final_perception = SlashCoSlasher.Criminal.Perception

	if slasher:GetVelocity():Length() > 5 then
		slasher:SetNWBool("CanKill", false)
	else
		slasher:SetNWBool("CanKill", true)
	end

	if slasher:GetNWBool("CriminalCloning") then
		slasher.SlasherValue1 = v1 + FrameTime()

		if not slasher:GetNWBool("CriminalRage") then
			local speed = SlashCoSlasher.Criminal.ChaseSpeed - (v1 / (4 + SO))

			slasher:SetSlowWalkSpeed(speed)
			slasher:SetWalkSpeed(speed)
			slasher:SetRunSpeed(speed)
		else
			local speed = 25 + SlashCoSlasher.Criminal.ChaseSpeed - (v1 / (5 + SO))

			slasher:SetSlowWalkSpeed(speed)
			slasher:SetWalkSpeed(speed)
			slasher:SetRunSpeed(speed)
		end

		final_perception = 0
		final_eyesight = 3
	else
		slasher:SetSlowWalkSpeed(SlashCoSlasher.Criminal.ProwlSpeed)
		slasher:SetWalkSpeed(SlashCoSlasher.Criminal.ProwlSpeed)
		slasher:SetRunSpeed(SlashCoSlasher.Criminal.ProwlSpeed)
		slasher.SlasherValue1 = 0

		final_perception = 1
		final_eyesight = 6
	end

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

SlashCoSlasher.Criminal.OnPrimaryFire = function(slasher)
	SlashCo.Jumpscare(slasher)
end

SlashCoSlasher.Criminal.OnSecondaryFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if slasher.ChaseActivationCooldown > 0 then
		return
	end
	slasher.ChaseActivationCooldown = SlashCoSlasher.Criminal.ChaseCooldown

	if slasher:GetNWBool("CriminalCloning") then
		for i = 1, #ents.FindByClass("sc_crimclone") do
			local cln = ents.FindByClass("sc_crimclone")[i]

			if cln.IsMain ~= true then
				cln:Remove()
			end
			cln:StopSound("slashco/slasher/criminal_loop.wav")
			cln:StopSound("slashco/slasher/criminal_rage.wav")
		end

		slasher:SetNWBool("CriminalCloning", false)
		slasher:SetNWBool("CriminalRage", false)
	else
		for i = 1, math.random(4 + (SO * 3), 6 + (SO * 3)) do
			local clone = ents.Create("sc_crimclone")

			clone:SetPos(slasher:GetPos())
			clone:SetAngles(slasher:GetAngles())
			clone.AssignedSlasher = slasher:SteamID64()
			clone.IsMain = false
			clone:Spawn()
			clone:Activate()
		end

		slasher:SetNWBool("CriminalCloning", true)
	end
end

SlashCoSlasher.Criminal.OnMainAbilityFire = function(slasher)
end

SlashCoSlasher.Criminal.OnSpecialAbilityFire = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	if not slasher:GetNWBool("CriminalCloning") then
		return
	end
	if slasher:GetNWBool("CriminalRage") then
		return
	end
	if SlashCo.CurRound.GameProgress < 7 then
		return
	end

	for i = 1, math.random(2 + (SO * 2), 4 + (SO * 2)) do
		local clone = ents.Create("sc_crimclone")

		clone:SetPos(slasher:GetPos())
		clone:SetAngles(slasher:GetAngles())
		clone.AssignedSlasher = slasher:SteamID64()
		clone.IsMain = false
		clone:Spawn()
		clone:Activate()
	end

	slasher.SlasherValue1 = 0
	slasher:SetNWBool("CriminalRage", true)
end

SlashCoSlasher.Criminal.Animator = function(ply)
	ply.CalcSeqOverride = 3

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SlashCoSlasher.Criminal.Footstep = function(ply)
	if SERVER then
		if ply.CrimStepTick == nil or ply.CrimStepTick > 2 then
			ply.CrimStepTick = 0
		end

		if ply.CrimStepTick == 0 then
			ply:EmitSound("slashco/slasher/criminal_step" .. math.random(1, 6) .. ".mp3")
		end

		ply.CrimStepTick = ply.CrimStepTick + 1
		return true
	end

	if CLIENT then
		return true
	end
end

if CLIENT then
	hook.Add("HUDPaint", SlashCoSlasher.Criminal.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Criminal") == true then
			if LocalPlayer().crim_f == nil then
				LocalPlayer().crim_f = 0
			end
			LocalPlayer().crim_f = LocalPlayer().crim_f + (FrameTime() * 20)
			if LocalPlayer().crim_f > 59 then
				LocalPlayer().crim_f = 11
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_12")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().crim_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().crim_f = nil
		end
	end)

	local avatarTable = {
		default = Material("slashco/ui/icons/slasher/s_12"),
		rage = Material("slashco/ui/icons/slasher/s_12_1")
	}

	SlashCoSlasher.Criminal.InitHud = function(_, hud)
		hud:SetAvatarTable(avatarTable)
		hud:SetTitle("criminal")

		hud:ChaseAndKill(true)
		hud:AddControl("RMB", "summon clones", Material("slashco/ui/icons/slasher/s_12_a1"))
		hud:TieControlText("RMB", "CriminalCloning", "unsummon clones", "summon clones")
		hud:AddControl("F", "rage", Material("slashco/ui/icons/slasher/s_12_1"))
		hud:SetControlVisible("F", false)

		hud.prevRage = LocalPlayer():GetNWBool("CriminalRage")
		function hud.AlsoThink()
			local rage = LocalPlayer():GetNWBool("CriminalRage")
			if rage ~= hud.prevRage then
				hud:SetAvatar(rage and "rage" or "default")
				hud:SetControlActive(not rage)
				hud.prevRage = rage
			end

			local progress = LocalPlayer():GetNWInt("GameProgressDisplay")
			if not hud.RageEnabled and progress > 6 then
				hud:SetControlVisible("F", true)
				hud:ShakeControl("F")
				hud.RageEnabled = true
			elseif hud.RageEnabled and progress < 7 then
				hud:SetControlVisible("F", false)
				hud.RageEnabled = false
			end
		end
	end

	--[[
	local CrimCloneIcon = Material("slashco/ui/icons/slasher/s_12_a1")
	local CrimRage = Material("slashco/ui/icons/slasher/s_12_1")

	SlashCoSlasher.Criminal.UserInterface = function(cx, cy, mainiconposx, mainiconposy)
		local willdrawkill = true
		local willdrawchase = false
		local willdrawmain = true

		local GameProgress = LocalPlayer():GetNWInt("GameProgressDisplay")

		local clones_active = LocalPlayer():GetNWBool("CriminalCloning")
		local rage_active = LocalPlayer():GetNWBool("CriminalRage")

		surface.SetMaterial(CrimCloneIcon)
		surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy / 2), ScrW() / 16, ScrW() / 16)
		if not clones_active then
			draw.SimpleText("M2 - Summon Clones", "ItemFontTip", mainiconposx + (cx / 8), mainiconposy - (cy / 2),
					Color(255, 0, 0, 255), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT)
		else
			draw.SimpleText("M2 - Unsummon Clones", "ItemFontTip", mainiconposx + (cx / 8), mainiconposy - (cy / 2),
					Color(255, 0, 0, 255), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT)
		end

		if rage_active then
			surface.SetMaterial(CrimRage)
			surface.DrawTexturedRect(mainiconposx, mainiconposy, ScrW() / 8, ScrW() / 8)
			willdrawmain = false
		end

		if not rage_active then
			surface.SetMaterial(CrimRage)
			surface.DrawTexturedRect(mainiconposx, mainiconposy - (cy / 1.333), ScrW() / 16, ScrW() / 16)
			if GameProgress > 6 then
				draw.SimpleText("F - Rage", "ItemFontTip", mainiconposx + (cx / 8), mainiconposy - (cy / 1.33),
						Color(255, 0, 0, 255), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT)
			else
				draw.SimpleText("-Unavailable-", "ItemFontTip", mainiconposx + (cx / 8), mainiconposy - (cy / 1.33),
						Color(100, 0, 0, 255), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT)
			end
		end

		return willdrawkill, willdrawchase, willdrawmain
	end
	--]]

	SlashCoSlasher.Criminal.ClientSideEffect = function()
	end
end