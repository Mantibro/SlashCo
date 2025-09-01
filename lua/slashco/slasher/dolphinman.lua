local SLASHER = {}

SLASHER.Name = "Dolphinman"
SLASHER.Aliases = {
	"Dolfin",
}
SLASHER.ID = 16
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Considerable
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/dolphinman/dolphinman.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 0.5
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 315
SLASHER.Perception = 1.0
SLASHER.Eyesight = 2
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 0.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/dolfin/dolfin_kill.mp3"
SLASHER.Description = "Dolphinman_desc"
SLASHER.ProTip = "Dolphinman_tip"
SLASHER.SpeedRating = "★★☆☆☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★☆"
SLASHER.CannotBeSpectated = true
-- Balancement Vars
SLASHER.HuntPowerDiv = 1 -- Used to divide FrameTime, raising it will make his hunt last longer.
SLASHER.HuntPowerGainDiv = 2 -- Used to divide FrameTime, raising it will make him gain hunt power SLOWER

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	-- math.max so it cannot go below 0.5.
	SLASHER.HuntPowerDiv = math.max(1 + SO + (0.1 * additionalSurvivors), 0.5)
	SLASHER.HuntPowerGainDiv = math.max(2 - (0.5 * SO) - (0.02 * additionalSurvivors), 0.5)

	SLASHER.ProwlSpeed = 150 + (5 * additionalSurvivors)
	SLASHER.ChaseSpeed = 315 + (5 * additionalSurvivors)
	SLASHER.ChaseDuration = 10.0 + (1 * additionalSurvivors)
end

function SLASHER.OnSpawn(slasher)
	slasher.Jump = slasher:GetJumpPower()
end

local function PlayCallSound(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/dolfin/dolfin_call.mp3",
		identifier = "DolfinCall",
		minDistance = 700 * SlashCo.MapSize,
		maxDistance = 1240 * SlashCo.MapSize,
		looping = true,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/dolfin/dolfin_call_far.mp3",
		identifier = "DolfinCallFar",
		minDistance = 1250 * SlashCo.MapSize,
		maxDistance = 2250 * SlashCo.MapSize,
		looping = true,
		entity = slasher,
		volume = 0.8,
		fadeIn = 0,
	})
end

function SLASHER.OnTickBehaviour(slasher)
	local HuntPower = slasher.HuntPower or 0 --Hunt power
	local hunt_boost = 0
	
	if math.random(1, 1000) == 1 then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/dolfin/dolfin_click" .. math.random(1, 2) .. ".ogg",
			identifier = "DolfinClick",
			minDistance = 350,
			maxDistance = 800,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end

	if slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") then
		slasher:SetJumpPower(0)
		slasher:SetRunSpeed(1)
		slasher:SetWalkSpeed(1)
		slasher:SetSlowWalkSpeed(1)
		slasher:EmitSound("slashco/slasher/dolfin/dolfin_breath.wav", 40)

		--get hunt yes.....
		if HuntPower < 100 then
			slasher.HuntPower = HuntPower + (FrameTime() / SLASHER.HuntPowerGainDiv)
		end

		--Survivore finderore

		if SlashCo.CurRound.EscapeHelicopterSummoned then
			slasher:SetNWBool("DolphinFound", true)
			
			slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
			timer.Simple(0.1, function()
				if not IsValid(slasher) then
					return
				end
				slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
			end)

			PlayCallSound(slasher)

			timer.Simple(10, function()
				slasher:SetNWBool("DolphinFound", false)
				slasher:SetNWBool("DolphinInHiding", false)
				slasher:SetNWBool("DolphinHunting", true)
				
				slasher:SetNWBool("CanKill", true)
			end)
		end

		for _, s in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not s:CanBeSeen() then
				continue
			end

			if s:GetPos():Distance(slasher:GetPos()) > 500 then
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

			slasher:SetNWBool("DolphinFound", true)
			
			slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
			timer.Simple(0.1, function()
				if not IsValid(slasher) then
					return
				end
				slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
			end)

			PlayCallSound(slasher)

			timer.Simple(10, function()
				slasher:SetNWBool("DolphinFound", false)
				slasher:SetNWBool("DolphinInHiding", false)
				slasher:SetNWBool("DolphinHunting", true)
			end)
		end
		
		if slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", false)
		end
	elseif not slasher:GetNWBool("DolphinInHiding") then
		if not slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", true)
		end

		slasher:SetJumpPower(slasher.Jump)

		--urgh i can move yes lmao

		if not slasher:GetNWBool("DolphinHunting") then
			--auggh im slow :((

			slasher:SetRunSpeed(SLASHER.ProwlSpeed)
			slasher:SetWalkSpeed(SLASHER.ProwlSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ProwlSpeed)
		else
			--you're fucking dead

			slasher:SetRunSpeed(SLASHER.ChaseSpeed)
			slasher:SetWalkSpeed(SLASHER.ChaseSpeed)
			slasher:SetSlowWalkSpeed(SLASHER.ChaseSpeed)

			hunt_boost = 1

			--oh fuck i'm losing my hunt!!
			slasher.HuntPower = HuntPower - (FrameTime() / SLASHER.HuntPowerDiv)

			--damn shit
			if HuntPower <= 0 then
				slasher:SetNWBool("DolphinHunting", false)
				SlashCo.AudioSystem.StopSound("DolfinCall", 0.5)
				SlashCo.AudioSystem.StopSound("DolfinCallFar", 0.5)
				
				slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
				for i = 1, 8 do
					--WHY THE FUCK DO I HAVE TO DO THIS HOLY SHIT
					timer.Simple(i / 10, function()
						slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
					end)
				end
			end
		end
	end

	if slasher:GetNWInt("DolphinHunt") ~= math.floor(HuntPower) then
		slasher:SetNWInt("DolphinHunt", math.floor(HuntPower))
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight + (hunt_boost * 5))
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception * 1.4 ^ (slasher.DolphinKills or 0) + (hunt_boost * 3))
end

function SLASHER.OnHitByTeslaCoil(slasher)
	-- i'm crying
	slasher:SetNWBool("DolphinFound", false)
	slasher:SetNWBool("DolphinInHiding", false)
	slasher:SetNWBool("DolphinHunting", false)

	timer.Simple(16, function()
		if not slasher:GetNWBool("CanKill") then
			slasher:SetNWBool("CanKill", true)
		end
	end)
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("DolphinInHiding")
end

function SLASHER.CanBeSeen(ply)
	if SERVER then
		return
	end

	if ply:IsVisible() and not ply:GetNWBool("DolphinInHiding") then
		return true
	end
end

function SLASHER.OnPrimaryFire(slasher, target)
	if SlashCo.Jumpscare(slasher, target) then
		if slasher:GetNWBool("DolphinHunting") then
			slasher.HuntPower = math.min(100, slasher.HuntPower + 15)
			slasher.DolphinKills = (slasher.DolphinKills or 0) + 1
		else
			slasher.HuntPower = math.min(100, slasher.HuntPower + 20)
			slasher.DolphinKills = (slasher.DolphinKills or 0) + 1
		end
	end
end

function SLASHER.OnSecondaryFire(slasher)
end

function SLASHER.OnMainAbilityFire(slasher)
	if not slasher:GetNWBool("DolphinHunting") and not slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") then
		if not SlashCo.IsPositionLegalForSlashers(slasher:GetPos()) then
			return
		end
		
		slasher:SetNWBool("DolphinInHiding", true)

		return
	end

	if slasher:GetNWBool("DolphinInHiding") and not slasher:GetNWBool("DolphinFound") and slasher.HuntPower >= 5 then
		slasher:SetNWBool("DolphinInHiding", false)
		
		slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
		timer.Simple(0.1, function()
			if not IsValid(slasher) then
				return
			end
			
			slasher:StopSound("slashco/slasher/dolfin/dolfin_breath.wav")
		end)

		slasher.HuntPower = slasher.HuntPower - math.floor(slasher.HuntPower / 1.5)
	end
end

function SLASHER.OnSpecialAbilityFire(slasher)
end

function SLASHER.Animator(ply)
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

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 5)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/dolfin/dolphin_step" .. idx .. ".mp3",
			identifier = "DolphinFootstep" .. idx,
			minDistance = 250,
			maxDistance = 400,
			entity = ply,
			volume = 1,
			fadeIn = 0,
			unreliable = true,
		})
	end

	return true
end

local hideIcons = {
	["default"] = Material("slashco/ui/icons/slasher/s_16"),
	["unhide"] = Material("slashco/ui/icons/slasher/s_10_a1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_16"))
	hud:SetTitle("Dolphinman")

	hud:AddControl("R", "hide", hideIcons)
	hud:ChaseAndKill(true)
	hud:TieControlVisible("LMB", "DolphinInHiding", true, true)
	hud:TieControlVisible("R", "DolphinHunting", true, true)
	hud:TieControlText("R", "DolphinInHiding", "unhide", "hide", true)

	hud:AddMeter("hunt")
	hud:TieMeterInt("hunt", "DolphinHunt")

	hud.prevHide = -1
	function hud.AlsoThink()
		local hide
		if GameData.LocalPlayer:GetNWBool("DolphinInHiding") then
			hide = not GameData.LocalPlayer:GetNWBool("DolphinFound") and GameData.LocalPlayer:GetNWInt("DolphinHunt") >= 5
		else
			hide = SlashCo.IsPositionLegalForSlashers(GameData.LocalPlayer:GetPos())
		end

		if hud.prevHide ~= hide then
			hud:SetControlEnabled("R", hide)
			hud.prevHide = hide
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Dolphinman") == true then
			if GameData.LocalPlayer.dolf_f == nil then
				GameData.LocalPlayer.dolf_f = 0
			end
			GameData.LocalPlayer.dolf_f = GameData.LocalPlayer.dolf_f + (FrameTime() * 20)
			if GameData.LocalPlayer.dolf_f > 29 then
				GameData.LocalPlayer.dolf_f = 28
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_16")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.dolf_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.dolf_f = nil
		end
	end)
	hook.Add("Tick", "DolphinmanLight", function()
		for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do

			if v == GameData.LocalPlayer then
				return
			end

			if v:GetNWBool("DolphinHunting") then
				local tlight = DynamicLight(MAX_EDICT + v:EntIndex())
				if tlight then
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