local SLASHER = {}

SLASHER.Name = "Leuonard"
SLASHER.Aliases = {
	"MONDAY NIGHT RAW",
}
SLASHER.ID = 14
SLASHER.Class = SlashCo.SlasherClass.Demon
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
SLASHER.IsSelectable = false
SLASHER.Model = "models/slashco/slashers/leuonard/leuonard.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 2
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 290
SLASHER.Perception = 1.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 150
SLASHER.ChaseRange = 900
SLASHER.ChaseRadius = 0.86
SLASHER.ChaseDuration = 5.0
SLASHER.ChaseCooldown = 4
SLASHER.JumpscareDuration = 2
SLASHER.ChaseMusic = "slashco/slasher/leuonard/leuonard_chase.ogg"
SLASHER.KillSound = "slashco/slasher/leuonard/leuonard_yell1.mp3"
SLASHER.Description = "Leuonard_desc"
SLASHER.ProTip = "Leuonard_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★☆"
SLASHER.RoidMult = 0.3 -- Roid multiplier used to multiply FrameTime by. Higher means more Roid is gained.

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	SLASHER.RoidMult = 0.3 + (SO * 0.3)
end

function SLASHER.OnSpawn(slasher)
	SlashCo.CreateItem("sc_dogg", SlashCo.RandomPosLocator(), Angle(0, 0, 0))
	slasher.soundon = 0
	slasher:SetNWBool("CanKill", true)
	slasher:SetNWBool("CanChase", true)

	slasher.LeuonardRoid = 0
	slasher.MouseDriftTick = 0
end

function SLASHER.OnTickBehaviour(slasher)
	local Roid = slasher.LeuonardRoid or 0 --Roid
	local MouseTick = slasher.MouseDriftTick or 0 --Tick to change mouse drift

	if slasher.MouseDrift == nil then
		slasher.MouseDrift = Vector(0, 0, 0)
	end

	if Roid < 100 then
		if slasher.MoveHooks then
			slasher:SlasherHudFunc("Degoblinize")
			slasher.MoveHooks = false
		end

		if not slasher:GetNWBool("LeuonardRoiding") then
			slasher.LeuonardRoid = Roid + (FrameTime() * SLASHER.RoidMult)

			--sound

			if math.floor(slasher.LeuonardRoid) == 25 and slasher.soundon == 0 then
				slasher:EmitSound("slashco/slasher/leuonard/leuonard_25_" .. math.random(1, 3) .. ".mp3", 95)
				slasher.soundon = 1
				slasher:SlasherHudFunc("FlashMeter", "r**e")
			end

			if math.floor(slasher.LeuonardRoid) == 50 and slasher.soundon == 1 then
				slasher:EmitSound("slashco/slasher/leuonard/leuonard_50_" .. math.random(1, 3) .. ".mp3", 95)
				slasher.soundon = 2
				slasher:SlasherHudFunc("FlashMeter", "r**e")
			end

			if math.floor(slasher.LeuonardRoid) == 90 and slasher.soundon == 2 then
				slasher:EmitSound("slashco/slasher/leuonard/leuonard_90_" .. math.random(1, 3) .. ".mp3", 95)
				slasher.soundon = 3
				slasher:SlasherHudFunc("FlashMeter", "r**e")
			end

			--LOCATE THE DOG..........

			local find = ents.FindInSphere(slasher:GetPos(), 120)

			for f = 1, #find do
				local ent = find[f]

				if ent:GetClass() == "sc_dogg" then
					--I FOUND YOU........
					slasher.soundon = 0
					ent:Remove()
					slasher:SetNWBool("LeuonardRoiding", true)
					slasher:EmitSound("slashco/slasher/leuonard/leuonard_yell1.mp3")
					slasher:Freeze(true)
					timer.Simple(4, function()
						if not IsValid(slasher) or not slasher:GetNWBool("LeuonardRoiding", false) then
							return
						end
						slasher:EmitSound("slashco/slasher/leuonard/leuonard_grunt_loop.mp3")
					end)
				end
			end
		else
			if Roid > 0 then
				slasher.LeuonardRoid = Roid - (FrameTime() * 2)
				slasher:SetBodygroup(1, 1)
				SlashCo.StopChase(slasher)
			else
				slasher:SetNWBool("LeuonardRoiding", false)
				slasher:SetBodygroup(1, 0)
				slasher:Freeze(false)

				SlashCo.CreateItem("sc_dogg", SlashCo.RandomPosLocator(), Angle(0, 0, 0))

				slasher:StopSound("slashco/slasher/leuonard/leuonard_grunt_loop.mp3")
				slasher:EmitSound("slashco/slasher/leuonard/leuonard_grunt_finish.mp3")
			end
		end
	else
		slasher.LeuonardRoid = 100.25
		slasher:SetNWBool("LeuonardFullRoid", true)

		SlashCo.StopChase(slasher)

		slasher:SetNWBool("CanKill", false)
		slasher:SetNWBool("CanChase", false)
	end

	if Roid == 100.25 then
		--100% bad word n stuff

		--LOCATE THE DOG..........

		local findd = ents.FindInSphere(slasher:GetPos(), 120)

		for f = 1, #findd do
			local ent = findd[f]

			if ent:GetClass() == "sc_dogg" then
				--I FOUND YOU........
				ent:Remove()
				slasher:SetNWBool("LeuonardRoiding", true)
				slasher:EmitSound("slashco/slasher/leuonard/leuonard_grunt_loop.mp3")
				slasher:Freeze(true)
				slasher:SetBodygroup(1, 1)

				timer.Simple(math.random(15, 30), function()
					if not IsValid(slasher) then
						return
					end

					slasher:StopSound("slashco/slasher/leuonard/leuonard_grunt_loop.mp3")
					slasher:Freeze(false)
					slasher:SetNWBool("LeuonardRoiding", false)
					slasher:SetBodygroup(1, 0)
				end)
			end
		end

		if not slasher.soundon == 0 then
			slasher:PlayGlobalSound("slashco/slasher/leuonard/leuonard_yell7.mp3", 100)
			slasher:PlayGlobalSound("slashco/slasher/leuonard/leuonard_full_close.mp3", 80)
			slasher:PlayGlobalSound("slashco/slasher/leuonard/leuonard_full_far.mp3", 125)
			slasher.soundon = 0
		end

		slasher:SetWalkSpeed(450)
		slasher:SetRunSpeed(450)

		if not slasher:GetNWBool("LeuonardRoiding") then
			if not slasher.MoveHooks then
				slasher:SlasherHudFunc("Goblinize")

				slasher.MoveHooks = true
			end

			if MouseTick < 0 then
				slasher.MouseDriftTick = 2 + (math.random() * 2)
				slasher:SlasherHudFunc("GoblinShift")
				slasher:EmitSound("slashco/slasher/leuonard/leuonard_yell" .. math.random(1, 7) .. ".mp3")
			end
			slasher.MouseDriftTick = slasher.MouseDriftTick - FrameTime()

			local find = ents.FindInSphere(slasher:GetPos(), 80)
			for i = 1, #find do
				local ent = find[i]

				if ent:GetClass() == "prop_door_rotating" then
					SlashCo.BustDoor(slasher, ent, 25000)
				end

				if ent:IsPlayer() and ent ~= slasher and ent:Team() == TEAM_SURVIVOR and ent.Devastate ~= true then
					ent:SetVelocity(slasher:GetForward() * 500)
					ent.Devastate = true
					ent:EmitSound("slashco/body_medium_impact_hard" .. math.random(1, 5) .. ".mp3")
					for a = 1, 10 do
						timer.Simple(a * 0.005, function()
							local vPoint = ent:GetPos() + Vector(math.random(-25, 25), math.random(-25, 25),
									50 + math.random(-25, 25))
							local bloodfx = EffectData()
							bloodfx:SetOrigin(vPoint)
							util.Effect("BloodImpact", bloodfx)
						end)
					end

					timer.Simple(0.1, function()
						if not IsValid(ent) then
							return
						end

						if IsValid(slasher) then
							ent:TakeDamage(99999, slasher, slasher)
						else
							ent:Kill()
						end
					end)

					timer.Simple(0.25, function()
						if not IsValid(ent) then
							return
						end

						ent.Devastate = false
					end)
				end
			end
		end
	end

	slasher:SetNWInt("LeuonardRoid", math.floor(Roid))
	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	SlashCo.Jumpscare(slasher, target)
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.Thirdperson(ply)
	return ply:GetNWBool("LeuonardRoiding")
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if not chase then
		ply.CalcIdeal = ACT_HL2MP_WALK
		ply.CalcSeqOverride = ply:LookupSequence("walk")
	else
		ply.CalcIdeal = ACT_HL2MP_RUN
		ply.CalcSeqOverride = ply:LookupSequence("chase")
	end

	if ply:GetNWBool("LeuonardFullRoid") then
		ply.CalcIdeal = ACT_HL2MP_RUN
		ply.CalcSeqOverride = ply:LookupSequence("specialrun")
	end

	if ply:GetVelocity():Length() < 2 then
		ply.CalcIdeal = ACT_HL2MP_IDLE
		ply.CalcSeqOverride = ply:LookupSequence("ragdoll")
	end

	if ply:GetNWBool("LeuonardRoiding") then
		ply.CalcSeqOverride = ply:LookupSequence("mondaynightraw")
		ply.CalcIdeal = 0

		if not ply:GetNWBool("LeuonardFullRoid") then
			ply:SetPlaybackRate(2)
		else
			ply:SetPlaybackRate(8)
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/leuonard/leuonard_step" .. idx .. ".mp3",
			identifier = "LeuonardFootstep" .. idx,
			minDistance = 200,
			maxDistance = 500,
			entity = ply,
			volume = 1,
			fadeIn = 0,
			unreliable = true,
		})
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_14"))
	hud:SetTitle("Leuonard")

	hud:ChaseAndKill()
	hud:TieControlVisible("LMB", "LeuonardFullRoid", true, false)
	hud:TieControlVisible("RMB", "LeuonardFullRoid", true, false)

	hud:AddMeter("r**e")
	hud:TieMeterInt("r**e", "LeuonardRoid")

	hud.MouseDrift = Angle(math.random() - 0.5, (math.random() - 0.5) * 2, 0)
	function hud:Goblinize()
		hook.Add("CreateMove", "SlashCoDisorient", function(cmd)
			local curtime = CurTime()
			local frametime = FrameTime()
			local power = 1

			local ang = cmd:GetViewAngles()
			ang = ang + self.MouseDrift
			ang = ang + Angle(math.random() - 0.5, math.random() - 0.5, 0)
			ang.pitch = math.Clamp(ang.pitch + math.sin(curtime) * 40 * frametime * power, -89, 89)
			ang.yaw = math.NormalizeAngle(ang.yaw + math.cos(curtime + 7) * 50 * frametime * power)

			cmd:SetViewAngles(ang)
			cmd:SetUpMove(self.MouseDrift.pitch * 450)
			cmd:SetSideMove(self.MouseDrift.yaw * 225)
		end)
	end

	function hud:GoblinShift()
		self.MouseDrift = Angle(math.random() - 0.5, (math.random() - 0.5) * 2, 0)
	end

	function hud:Degoblinize()
		hook.Remove("CreateMove", "SlashCoDisorient")
	end
end

function SLASHER.PreDrawHalos()
	SlashCo.DrawHalo(ents.FindByClass("sc_dogg"), nil, 2, false)
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Leuonard") == true then
			if GameData.LocalPlayer.leuo_f == nil then
				GameData.LocalPlayer.leuo_f = 0
			end
			GameData.LocalPlayer.leuo_f = GameData.LocalPlayer.leuo_f + (FrameTime() * 20)
			if GameData.LocalPlayer.leuo_f > 10 then
				GameData.LocalPlayer.leuo_f = 0
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_14")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.leuo_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.leuo_f = nil
		end
	end)

	hook.Add("Think", "LeuonardLight", function()
		for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if slasher:GetNWBool("LeuonardFullRoid") then
				local tlight = DynamicLight(MAX_EDICT + slasher:EntIndex())
				if (tlight) then
					tlight.pos = slasher:LocalToWorld(Vector(0, 0, 20))
					tlight.r = 255
					tlight.g = 0
					tlight.b = 0
					tlight.brightness = 5
					tlight.Decay = 1000
					tlight.Size = 5000
					tlight.DieTime = CurTime() + 1
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Leuonard")