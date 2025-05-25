local SLASHER = {}

SLASHER.Name = "Criminal"
SLASHER.ID = 12
SLASHER.Class = 3
SLASHER.DangerLevel = 3
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/criminal/criminal.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 10
SLASHER.ProwlSpeed = 200
SLASHER.ChaseSpeed = 310
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 110
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 1
SLASHER.ChaseDuration = 0.0
SLASHER.ChaseCooldown = 10
SLASHER.JumpscareDuration = 4
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/criminal_kill.mp3"
SLASHER.Description = "Criminal_desc"
SLASHER.ProTip = "Criminal_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★★★"

function SLASHER.OnSpawn(slasher)
	local clone = ents.Create("sc_crimclone")

	clone:SetPos(slasher:GetPos())
	clone:SetAngles(slasher:GetAngles())
	clone.AssignedSlasher = slasher:SteamID64()
	clone.IsMain = true
	clone:Spawn()
	clone:Activate()

	slasher:SetVisible(false)
end

function SLASHER.OnTickBehaviour(slasher)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	v1 = slasher.SlasherValue1 --Cloning Duration

	local final_eyesight = SLASHER.Eyesight
	local final_perception = SLASHER.Perception

	if slasher:GetVelocity():Length() > 5 then
		slasher:SetNWBool("CanKill", false)
		timer.Remove("CriminalStandStill_" .. slasher:UserID())
	elseif not timer.Exists("CriminalStandStill_" .. slasher:UserID()) then
		timer.Create("CriminalStandStill_" .. slasher:UserID(), 0.7, 1, function()
			if IsValid(slasher) then
				slasher:SetNWBool("CanKill", true)
			end
		end)
	end

	if slasher:GetNWBool("CriminalCloning") then
		slasher.SlasherValue1 = v1 + FrameTime()

		if not slasher:GetNWBool("CriminalRage") then
			local speed = SLASHER.ChaseSpeed - (v1 / (4 + SO))

			slasher:SetSlowWalkSpeed(speed)
			slasher:SetWalkSpeed(speed)
			slasher:SetRunSpeed(speed)
		else
			local speed = 25 + SLASHER.ChaseSpeed - (v1 / (5 + SO))

			slasher:SetSlowWalkSpeed(speed)
			slasher:SetWalkSpeed(speed)
			slasher:SetRunSpeed(speed)
		end

		final_perception = 0
		final_eyesight = 3
	else
		slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
		slasher:SetRunSpeed(SLASHER.ProwlSpeed)
		slasher.SlasherValue1 = 0

		final_perception = 1
		final_eyesight = 6
	end

	slasher:SetNWFloat("Slasher_Eyesight", final_eyesight)
	slasher:SetNWInt("Slasher_Perception", final_perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

function SLASHER.OnSecondaryFire(slasher)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	if slasher.ChaseActivationCooldown > 0 then
		return
	end
	slasher.ChaseActivationCooldown = SLASHER.ChaseCooldown

	if slasher:GetNWBool("CriminalCloning") then
		for i = 1, #ents.FindByClass("sc_crimclone") do
			local cln = ents.FindByClass("sc_crimclone")[i]

			if cln.IsMain ~= true then
				cln:Remove()
			end
			cln:StopSound("slashco/slasher/criminal_loop.mp3")
			cln:StopSound("slashco/slasher/criminal_rage.mp3")
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

function SLASHER.OnMainAbilityFire()
end

function SLASHER.OnSpecialAbilityFire(slasher)
	local SO = SlashCo.CurRound.OfferingData.Singularity

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

function SLASHER.Animator(ply)
	ply.CalcSeqOverride = 3

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
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

	return true
end

local avatarTable = {
	default = Material("slashco/ui/icons/slasher/s_12"),
	rage = Material("slashco/ui/icons/slasher/s_12_1")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatarTable(avatarTable)
	hud:SetTitle("Criminal")

	hud:ChaseAndKill(true)
	hud:AddControl("RMB", "summon clones", Material("slashco/ui/icons/slasher/s_12_a1"))
	hud:TieControlText("RMB", "CriminalCloning", "unsummon clones", "summon clones", nil)
	hud:AddControl("F", "rage", Material("slashco/ui/icons/slasher/s_12_1"))
	hud:SetControlVisible("F", false)

	hud.prevRage = GameData.LocalPlayer:GetNWBool("CriminalRage")
	function hud.AlsoThink()
		local rage = GameData.LocalPlayer:GetNWBool("CriminalRage")
		if rage ~= hud.prevRage then
			hud:SetAvatar(rage and "rage" or "default")
			hud:SetControlEnabled("F", not rage)
			hud.prevRage = rage
		end

		local progress = GameData.LocalPlayer:GetNWInt("GameProgressDisplay")
		if progress > 6 then
			if not hud.RageEnabled then
				hud:SetControlVisible("F", true)
				hud:ShakeControl("F")
				hud.RageEnabled = true
			end
		elseif progress < 7 then
			if hud.RageEnabled then
				hud:SetControlVisible("F", false)
				hud.RageEnabled = false
			end
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Criminal") == true then
			if GameData.LocalPlayer.crim_f == nil then
				GameData.LocalPlayer.crim_f = 0
			end
			GameData.LocalPlayer.crim_f = GameData.LocalPlayer.crim_f + (FrameTime() * 20)
			if GameData.LocalPlayer.crim_f > 59 then
				GameData.LocalPlayer.crim_f = 11
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_12")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.crim_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.crim_f = nil
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Criminal")