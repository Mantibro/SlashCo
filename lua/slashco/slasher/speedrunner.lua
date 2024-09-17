local SLASHER = {}

SLASHER.Name = "Speedrunner"
SLASHER.ID = 15
SLASHER.Class = 1
SLASHER.DangerLevel = 3
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/dream/dream.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 8
SLASHER.ProwlSpeed = 50
SLASHER.ChaseSpeed = 50
SLASHER.Perception = 2.0
SLASHER.Eyesight = 5
SLASHER.KillDistance = 125
SLASHER.ChaseRange = 0
SLASHER.ChaseRadius = 1
SLASHER.ChaseDuration = 0.0
SLASHER.ChaseCooldown = 1
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = "slashco/slasher/speedrunner_kill.mp3"
SLASHER.Description = "Speedrunner_desc"
SLASHER.ProTip = "Speedrunner_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★★"

SLASHER.OnSpawn = function(slasher)
	slasher:PlayGlobalSound("slashco/slasher/speedrunner_1.wav", 100)
	slasher:SetNWBool("CanKill", true)
	slasher.SlasherValue1 = 100
	slasher.SlasherValue2 = 1
	slasher.SlasherValue3 = 285
end

SLASHER.OnTickBehaviour = function(slasher)
	local SO = SlashCo.CurRound.OfferingData.SO

	local v1 = slasher.SlasherValue1 --Speed
	local v2 = slasher.SlasherValue2 --Speed Gain multiplier
	local v3 = slasher.SlasherValue3 --max speed allowed

	if v1 < v3 then
		local mapSizeMod = (0.5 / SlashCo.MapSize) + 0.5
		slasher.SlasherValue1 = v1 + FrameTime() * mapSizeMod * v2 * (1 + SO)
	end

	slasher:SetRunSpeed(slasher.SlasherValue1)
	slasher:SetWalkSpeed(slasher.SlasherValue1)
	slasher:SetSlowWalkSpeed(slasher.SlasherValue1)

	if slasher:GetNWInt("SpeedrunnerSpeed") ~= math.floor(v1) then
		slasher:SetNWInt("SpeedrunnerSpeed", math.floor(v1))
	end

	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	if SlashCo.Jumpscare(slasher, target) then
		slasher.SlasherValue1 = math.min(slasher.SlasherValue1 + 30, slasher.SlasherValue3)
	end
end

-- the great ability
SLASHER.RandomTPCans = function()
	for _, ent in ipairs(ents.FindByClass("sc_gascan")) do
		ent:RandomTeleport(Vector(0, 0, 50))
		ent:GetPhysicsObject():ApplyForceCenter(Vector((math.random() - 0.5) * 100,
				(math.random() - 0.5) * 100, (math.random() - 0.5) * 100))
	end
end

SLASHER.OnMainAbilityFire = function(slasher)
	if slasher.SlasherValue1 < slasher.SlasherValue3 or slasher:GetNWBool("SpeedrunnerSacrificeTwo") then
		return
	end

	if slasher.SpeedRunnering then
		return
	end
	slasher.SpeedRunnering = true

	slasher:StopSound("slashco/slasher/speedrunner_1.wav")
	slasher:StopSound("slashco/slasher/speedrunner_2.wav")
	timer.Simple(0.1, function()
		if not IsValid(slasher) then
			return
		end

		slasher:StopSound("slashco/slasher/speedrunner_1.wav")
		slasher:StopSound("slashco/slasher/speedrunner_2.wav")
	end)

	slasher:Freeze(true)

	if not slasher:GetNWBool("SpeedrunnerSacrificeOne") then
		slasher:EmitSound("slashco/slasher/speedrunner_rng1.mp3", 85, 100)
	else
		slasher:EmitSound("slashco/slasher/speedrunner_rng2.mp3", 85, 100)
	end

	timer.Simple(2, function()
		if not IsValid(slasher) then
			return
		end

		slasher.SlasherValue1 = 100
		slasher.SpeedRunnering = nil
		slasher:Freeze(false)

		if not slasher:GetNWBool("SpeedrunnerSacrificeOne") then
			slasher:SetNWBool("SpeedrunnerSacrificeOne", true)
			slasher:PlayGlobalSound("slashco/slasher/speedrunner_2.wav", 100)
			slasher.SlasherValue2 = 2
			slasher.SlasherValue3 = 325
			SLASHER.RandomTPCans()

			return
		end

		if not slasher:GetNWBool("SpeedrunnerSacrificeTwo") then
			slasher:SetNWBool("SpeedrunnerSacrificeTwo", true)
			slasher:PlayGlobalSound("slashco/slasher/speedrunner_3.wav", 100)
			slasher.SlasherValue2 = 4
			slasher.SlasherValue3 = 500
			slasher:SetBodygroup(1, 1)
			SLASHER.RandomTPCans()

			return
		end
	end)
end

SLASHER.Animator = function(ply, veloc)
	local move_vel = ply:WorldToLocal(veloc + ply:GetPos())
	local anim_vel = veloc:Length()

	if ply:IsOnGround() then
		if anim_vel > 1 then
			if anim_vel < 150 then
				ply.CalcSeqOverride = ply:LookupSequence("slow")
				ply:SetPoseParameter("runner_speed", move_vel[1] / 200)
			elseif anim_vel < 300 then
				ply.CalcSeqOverride = ply:LookupSequence("fast")
				ply:SetPoseParameter("runner_speed", move_vel[1] / 250)
			else
				ply.CalcSeqOverride = ply:LookupSequence("fastest")
				ply:SetPoseParameter("runner_speed", move_vel[1] / 100)
			end
		else
			ply.CalcSeqOverride = ply:LookupSequence("idle")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	if ply:GetNWBool("SpeedrunnerSacrificeTwo") then
		ply.CalcSeqOverride = ply:LookupSequence("ascended")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	return ply:GetNWBool("SpeedrunnerSacrificeTwo")
end

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_15"))
	hud:SetTitle("Speedrunner")

	hud:AddControl("R", "rng sacrifice", "chase")
	hud:ChaseAndKill(true)

	hud:AddMeter("speed", 235, "", nil, true)
	hud:TieMeterInt("speed", "SpeedrunnerSpeed")

	hud.prevSac1 = not LocalPlayer():GetNWBool("SpeedrunnerSacrificeOne")
	hud.prevSac2 = not LocalPlayer():GetNWBool("SpeedrunnerSacrificeTwo")
	hud.SpeedGo = true
	function hud.AlsoThink()
		local sac1 = LocalPlayer():GetNWBool("SpeedrunnerSacrificeOne")
		local sac2 = LocalPlayer():GetNWBool("SpeedrunnerSacrificeTwo")
		if sac2 ~= hud.prevSac2 or sac1 ~= hud.prevSac1 then
			if sac2 then
				hud:SetMeterMax("speed", 500)
				hud:SetControlVisible("R", false)
			elseif sac1 then
				hud:SetMeterMax("speed", 325)
			else
				hud:SetMeterMax("speed", 285)
			end

			hud.prevSac1 = sac1
			hud.prevSac2 = sac2
		end

		local meter = hud:GetMeter("speed")
		if meter.Max == meter.Current then
			if not hud.SpeedGo then
				hud:SetControlEnabled("R", true)
				hud.SpeedGo = true
			end
		else
			if hud.SpeedGo then
				hud:SetControlEnabled("R", false)
				hud.SpeedGo = false
			end
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", SLASHER.Name .. "_Jumpscare", function()
		if LocalPlayer():GetNWBool("SurvivorJumpscare_Speedrunner") == true then
			if LocalPlayer().spd_f == nil then
				LocalPlayer().spd_f = 0
			end
			LocalPlayer().spd_f = LocalPlayer().spd_f + (FrameTime() * 20)
			if LocalPlayer().spd_f > 25 then
				LocalPlayer().spd_f = 25
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_15")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().spd_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			LocalPlayer().spd_f = nil
		end
	end)

	hook.Add("Tick", "SpeedrunnerBones", function()
		for _, v in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			if v:GetNWString("Slasher") == "Speedrunner" then
				if v.AllBones == nil then
					v.AllBones = {}

					for b = 1, v:GetBoneCount() - 1 do
						table.insert(v.AllBones, { Bone = v:GetBoneName(b), Offset = Vector(0, 0, 0) })
					end

					return
				end

				local r_bone = math.random(1, v:GetBoneCount() - 1)
				--local cur_off = v.AllBones[r_bone].Offset

				v.AllBones[r_bone].Offset = v.AllBones[r_bone].Offset + Vector(math.random() - 0.5,
						math.random() - 0.5, math.random() - 0.5)
				if v.AllBones[r_bone].Offset:Length() > 3 then
					v.AllBones[r_bone].Offset = Vector(math.random() - 0.5, math.random() - 0.5,
							math.random() - 0.5)
				end

				local intensity = 0

				if v:GetNWBool("SpeedrunnerSacrificeOne") then
					intensity = 0.5
				end
				if v:GetNWBool("SpeedrunnerSacrificeTwo") then
					intensity = 1.5
				end

				for b = 1, v:GetBoneCount() - 1 do
					if b == 5 then
						v:ManipulateBoneAngles(b, Angle(0, 0, intensity * v.AllBones[r_bone].Offset:Length() * 20))
						continue
					end

					if b == 6 then
						v:ManipulateBoneAngles(b, Angle(0, 0, -intensity * v.AllBones[r_bone].Offset:Length() * 20))
						continue
					end

					if b == 21 then
						v:ManipulateBoneAngles(b,
								Angle(v.AllBones[r_bone].Offset.x * 20, v.AllBones[r_bone].Offset.y * 20,
										v.AllBones[r_bone].Offset.z * 2))
						continue
					end

					if b == 25 then
						v:ManipulateBoneAngles(b,
								Angle(v.AllBones[r_bone].Offset.x * 20, v.AllBones[r_bone].Offset.y * 20,
										v.AllBones[r_bone].Offset.z * 2))
						continue
					end

					if b == 30 then
						v:ManipulateBoneAngles(b,
								Angle(v.AllBones[r_bone].Offset.x * 20, v.AllBones[r_bone].Offset.y * 20,
										v.AllBones[r_bone].Offset.z * 2))
						continue
					end

					if v.AllBones[b] and v.AllBones[b].Offset then
						v:ManipulateBonePosition(b, v.AllBones[b].Offset * 2 * intensity)
					end
				end
			end

			if v:GetNWBool("SpeedrunnerSacrificeTwo") then
				local tlight = DynamicLight(v:EntIndex() + 965)
				if tlight then
					tlight.pos = v:LocalToWorld(Vector(0, 0, 20))
					tlight.r = 80
					tlight.g = 255
					tlight.b = 80
					tlight.brightness = 5
					tlight.Decay = 1000
					tlight.Size = 500
					tlight.DieTime = CurTime() + 1
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Speedrunner")
