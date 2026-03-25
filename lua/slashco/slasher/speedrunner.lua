local SLASHER = {}

SLASHER.Name = "Speedrunner"
SLASHER.Aliases = {
	"The Hunted",
}
SLASHER.ID = 15
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
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
SLASHER.KillSound = "slashco/slasher/speedrunner/speedrunner_kill.mp3"
SLASHER.Description = "Speedrunner_desc"
SLASHER.ProTip = "Speedrunner_tip"
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★★☆☆"
SLASHER.DiffRating = "★★★★★"

function SLASHER.OnSpawn(slasher)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/speedrunner/speedrunner_1.ogg",
		identifier = "Speedrun1",
		minDistance = 750,
		maxDistance = 1400,
		looping = true,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})
	slasher:SetNWBool("CanKill", true)
	
	timer.Simple(1, function()
		if not IsValid(slasher) then return end
		SlashCo.CreateItem("sc_ore", SlashCo.RandomPosLocator(), Angle(0, 0, 0))
	end)

	slasher.Speedrun = 100
	slasher.Speedrunning = 1
	slasher.Speedrunned = 285
end

function SLASHER.OnTickBehaviour(slasher)
	local SO = SlashCo.CurRound.OfferingData.Singularity

	local Speed = slasher.Speedrun or 0 --Speed
	local SpeedGain = slasher.Speedrunning or 0 --Speed Gain multiplier
	local SpeedMax = slasher.Speedrunned or 0 --max speed allowed

	if Speed < SpeedMax then
		local gasMod = SlashCo.IsPositionLegalForSlashers(slasher:GetPos(), true) and 1 or 0.5
		local mapSizeMod = (0.5 / SlashCo.MapSize) + 0.5
		slasher.Speedrun = Speed + engine.TickInterval() * mapSizeMod * SpeedGain * (1 + SO) * 0.66 * gasMod
	end

	slasher:SetRunSpeed(math.floor(slasher.Speedrun))
	slasher:SetWalkSpeed(math.floor(slasher.Speedrun))
	slasher:SetSlowWalkSpeed(math.floor(slasher.Speedrun))

	if slasher:GetNWInt("SpeedrunnerSpeed") ~= math.floor(Speed) then
		slasher:SetNWInt("SpeedrunnerSpeed", math.floor(Speed))
	end

	slasher:SetEyeSight(SLASHER.Eyesight)
	slasher:SetPerception(SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	if SlashCo.Jumpscare(slasher, target) then
		slasher.Speedrun = math.min(slasher.Speedrun + 30, slasher.Speedrunned)
	end
end

-- the great ability
function SLASHER.RandomTPCans()
	for _, ent in ipairs(ents.FindByClass("sc_gascan")) do
		ent:RandomTeleport(Vector(0, 0, 50))
		ent:GetPhysicsObject():ApplyForceCenter(Vector((math.random() - 0.5) * 100,
				(math.random() - 0.5) * 100, (math.random() - 0.5) * 100))
	end
end

function SLASHER.OnMainAbilityFire(slasher)
	if slasher.Speedrun < slasher.Speedrunned or slasher:GetNWBool("SpeedrunnerSacrificeTwo") then return end
	if slasher.SpeedRunnering then return end

	slasher.SpeedRunnering = true

	timer.Simple(0.1, function()
		if not IsValid(slasher) then return end

		SlashCo.AudioSystem.StopSound("Speedrun1", 0.5, slasher)
		SlashCo.AudioSystem.StopSound("Speedrun2", 0.5, slasher)
	end)

	slasher:Freeze(true)

	if not slasher:GetNWBool("SpeedrunnerSacrificeOne") then
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/speedrunner/speedrunner_rng1.mp3",
			identifier = "SpeedrunRNG1",
			minDistance = 400,
			maxDistance = 900,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	else
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/speedrunner/speedrunner_rng2.mp3",
			identifier = "SpeedrunRNG2",
			minDistance = 400,
			maxDistance = 900,
			entity = slasher,
			volume = 1,
			fadeIn = 0,
		})
	end

	timer.Simple(2, function()
		if not IsValid(slasher) then return end

		slasher.Speedrun = 100
		slasher.SpeedRunnering = nil
		slasher:Freeze(false)

		if not slasher:GetNWBool("SpeedrunnerSacrificeOne") then
			slasher:SetNWBool("SpeedrunnerSacrificeOne", true)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/speedrunner/speedrunner_2.ogg",
				identifier = "Speedrun2",
				minDistance = 750,
				maxDistance = 1400,
				looping = true,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})
			slasher.Speedrunning = 2
			slasher.Speedrunned = 325
			SLASHER.RandomTPCans()

			return
		end

		if not slasher:GetNWBool("SpeedrunnerSacrificeTwo") then
			slasher:SetNWBool("SpeedrunnerSacrificeTwo", true)
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/speedrunner/speedrunner_3.ogg",
				identifier = "Speedrun3",
				minDistance = 750,
				maxDistance = 1400,
				looping = true,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})
			slasher.Speedrunning = 4
			slasher.Speedrunned = 500
			slasher:SetBodygroup(1, 1)
			SLASHER.RandomTPCans()

			return
		end
	end)
end

function SLASHER.OnSpecialAbilityFire(slasher, target)
	if not IsValid(target) or target:GetClass() ~= "sc_ore" then return end
	if slasher:GetPos():Distance(target:GetPos()) >= 200 or slasher:GetNWBool("SpeedrunnerMining") then return end
	if slasher:GetNWBool("SpeedrunnerSacrificeTwo") then return end

	slasher:Freeze(true)
	slasher:SetNWBool("SpeedrunnerMining", true)

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/speedrunner/speedrunner_mining.mp3",
		identifier = "SpeedrunMining",
		minDistance = 400,
		maxDistance = 1200,
		entity = slasher,
		volume = 2,
		fadeIn = 0,
	})

	local pos = slasher:LocalToWorld(Vector(5, 0, 3))
	local ang = slasher:LocalToWorldAngles(Angle(80, -70, 0))

	local pickaxe = ents.Create("prop_physics")

	pickaxe:SetMoveType(MOVETYPE_NONE)
	pickaxe:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	pickaxe:SetModel("models/slashco/slashers/dream/pickaxe.mdl")
	pickaxe:SetSkin(4)
	pickaxe:SetPos(pos)
	pickaxe:SetAngles(ang)
	pickaxe:FollowBone(slasher, slasher:LookupBone("HandR"))

	timer.Simple(5, function()
		if not IsValid(slasher) then return end

		slasher:Freeze(false)
		slasher:SetNWBool("SpeedrunnerMining", false)
		SlashCo.AudioSystem.StopSound("SpeedrunMining", 0.1, slasher)

		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/speedrunner/speedrunner_mined.mp3",
			identifier = "SpeedrunMined",
			minDistance = 400,
			maxDistance = 1200,
			entity = slasher,
			volume = 2,
			fadeIn = 0,
		})

		local rand = math.random(5, 20)
		slasher.Speedrun = slasher.Speedrun + rand
		SLASHER.RandomTPCans()

		SlashCo.CreateItem("sc_ore", SlashCo.RandomPosLocator(), Angle(0, 0, 0))

		if IsValid(target) then
			target:Remove()
		end
		if not IsValid(pickaxe) then return end

		pickaxe:Remove()
	end)
end

function SLASHER.OnHitByPocketSand(slasher, ply)
	slasher:SetNWBool("SpeedrunnerStun", true)
	slasher:Freeze(true)
	timer.Simple(9, function()
		if not IsValid(slasher) then return end

		slasher:SetNWBool("SpeedrunnerStun", false)
		slasher:Freeze(false)
	end)
end
SLASHER.OnHitByBeerKeg = function(slasher) SLASHER.OnHitByPocketSand(slasher, nil) end
SLASHER.OnHitByTeslaCoil = function(slasher) SLASHER.OnHitByPocketSand(slasher, nil) end

function SLASHER.Animator(ply, veloc)
	local move_vel = ply:WorldToLocal(veloc + ply:GetPos())
	local anim_vel = veloc:Length()

	local mining = ply:GetNWBool("SpeedrunnerMining")
	local stun = ply:GetNWBool("SpeedrunnerStun")
	local ascended = ply:GetNWBool("SpeedrunnerSacrificeTwo")

	if not mining and not stun then
		ply.anim_antispam = false
	end

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

	if ascended then
		ply.CalcSeqOverride = ply:LookupSequence("ascended")
	end

	if mining then
		ply.CalcSeqOverride = ply:LookupSequence("mining")
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	if stun then
		if ascended then
			ply.CalcSeqOverride = ply:LookupSequence("stun_2")
		else
			ply.CalcSeqOverride = ply:LookupSequence("stun_1")
		end

		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	return ply:GetNWBool("SpeedrunnerSacrificeTwo")
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_15"))
	hud:SetTitle("Speedrunner")

	hud:AddControl("R", "rng sacrifice", "chase")
	hud:AddControl("F", "mine ore", Material("slashco/ui/icons/slasher/s_minethecraft"))
	hud:ChaseAndKill(true)

	hud:AddMeter("speed", 235, "", nil, true)
	hud:TieMeterInt("speed", "SpeedrunnerSpeed")
	
	hook.Add("SlashCo:DrawHUD", "SlashCo:SlasherHUD", function()
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			hook.Remove("SlashCo:DrawHUD", "SlashCo:SlasherHUD")
			return
		end
		
		if GameData.LocalPlayer:GetNWBool("SpeedrunnerMining") then
			draw.SimpleText("MINING ORE . . .", "ItemFontTip", ScrW() / 2, ScrH() / 4,
					Color(255, 0, 0, 255),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end)

	hud.prevSac1 = not GameData.LocalPlayer:GetNWBool("SpeedrunnerSacrificeOne")
	hud.prevSac2 = not GameData.LocalPlayer:GetNWBool("SpeedrunnerSacrificeTwo")
	hud.SpeedGo = true
	function hud.AlsoThink()
		local sac1 = GameData.LocalPlayer:GetNWBool("SpeedrunnerSacrificeOne")
		local sac2 = GameData.LocalPlayer:GetNWBool("SpeedrunnerSacrificeTwo")
		if sac2 ~= hud.prevSac2 or sac1 ~= hud.prevSac1 then
			if sac2 then
				hud:SetMeterMax("speed", 500)
				hud:SetControlVisible("R", false)
				hud:SetControlVisible("F", false)
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

function SLASHER.PreDrawHalos()
	SlashCo.DrawHalo(ents.FindByClass("sc_ore"), "red")
end

if CLIENT then
	hook.Add("SlashCo:DrawHUD", SLASHER.Name .. "_Jumpscare", function()
		if GameData.LocalPlayer:GetNWBool("SurvivorJumpscare_Speedrunner") == true then
			if GameData.LocalPlayer.spd_f == nil then
				GameData.LocalPlayer.spd_f = 0
			end
			GameData.LocalPlayer.spd_f = GameData.LocalPlayer.spd_f + (FrameTime() * 20)
			if GameData.LocalPlayer.spd_f > 25 then
				GameData.LocalPlayer.spd_f = 25
			end

			local Overlay = Material("slashco/ui/overlays/jumpscare_15")
			Overlay:SetInt("$frame", math.floor(GameData.LocalPlayer.spd_f))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			GameData.LocalPlayer.spd_f = nil
		end

		if GameData.LocalPlayer:GetNWBool("SurvivorMining") then
			draw.SimpleText("MINING . . .", "ItemFontTip", ScrW() / 2, ScrH() / 4,
					Color(255, 0, 0, 255),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
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
				local tlight = DynamicLight(MAX_EDICT + v:EntIndex())
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
