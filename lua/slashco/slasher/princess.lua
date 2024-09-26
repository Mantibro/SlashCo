local SLASHER = {}

SLASHER.Name = "Princess"
SLASHER.ID = 17
SLASHER.Class = 2
SLASHER.DangerLevel = 1
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/princess/princess.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 280
SLASHER.Perception = 1.0
SLASHER.Eyesight = 2
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.91
SLASHER.ChaseDuration = 10.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = "slashco/slasher/princess_chase.wav"
SLASHER.KillSound = ""
SLASHER.Description = "Princess_desc"
SLASHER.ProTip = "Princess_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★☆☆☆"
SLASHER.ItemToSpawn = "Baby"

SLASHER.OnSpawn = function(slasher)
	slasher:SetViewOffset(Vector(0, 0, 50))
	slasher:SetCurrentViewOffset(Vector(0, 0, 50))

	slasher.SlasherValue2 = 50

	SLASHER.DoSound(slasher)
end

SLASHER.DoSound = function(slasher)
	if not slasher:GetNWBool("PrincessMaulingChild") and not slasher:GetNWBool("PrincessMaulingBase") and not slasher:GetNWBool("PrincessMaulingSurvivor") and not slasher:GetNWBool("PrincessSniffing") then
		if slasher:GetNWBool("InSlasherChaseMode") then
			slasher:EmitSound("slashco/slasher/princess_chase" .. math.random(1, 15) .. ".mp3")
		else
			slasher:EmitSound("slashco/slasher/princess_idle" .. math.random(1, 9) .. ".mp3")
		end
	end

	timer.Simple(2, function()
		if not IsValid(slasher) then
			return
		end

		SLASHER.DoSound(slasher)
	end)
end

SLASHER.OnTickBehaviour = function(slasher)
	local v1 = slasher.SlasherValue1 --aggression
	local v2 = slasher.SlasherValue2 --aggression threshold

	local eyesight = SLASHER.Eyesight
	local perception = SLASHER.Perception

	if not slasher:GetNWBool("DemonPacified") then
		slasher:SetNWBool("CanChase", true)
	else
		slasher:SetNWBool("CanChase", false)
		eyesight = 0
		perception = 0
	end

	--find children to maul
	if slasher:GetNWBool("InSlasherChaseMode") then
		--Get Aggro
		if v1 < v2 then
			slasher.SlasherValue1 = v1 + FrameTime()
		end

		local speed = SLASHER.ChaseSpeed + (v1 / 8)

		slasher:SetRunSpeed(speed)
		slasher:SetWalkSpeed(speed)

		local lookent = slasher:GetEyeTrace().Entity

		if lookent:GetPos():Distance(slasher:GetPos()) < 100 then
			if v1 >= 95 then
				SlashCo.BustDoor(slasher, lookent, 50000)
			elseif v1 >= 50 then
				slasher:SlamDoor(lookent)
			end

			if lookent:GetClass() == "func_breakable" or lookent:GetClass() == "func_breakable_surf" then
				lookent:TakeDamage(10000, slasher, slasher)
			end
		end

		for _, v in ipairs(ents.FindByClass("sc_baby")) do
			if v:GetPos():Distance(slasher:GetPos()) < 100 and not slasher:GetNWBool("PrincessMaulingBase") and not slasher:GetNWBool("PrincessSniffing") and not slasher:GetNWBool("PrincessMaulingChild") and not slasher:GetNWBool("PrincessMaulingSurvivor") then
				--mauling child
				SlashCo.StopChase(slasher)
				slasher:SetNWBool("PrincessMaulingChild", true)
				slasher:Freeze(true)

				slasher:EmitSound("slashco/slasher/princess_maul.mp3")

				--baby in jaw

				v:Remove()

				local pos = slasher:LocalToWorld(Vector(0, 10, -5))
				local ang = slasher:LocalToWorldAngles(Angle(90, 0, 0))

				local mauled_child = ents.Create("prop_physics")

				slasher:EmitSound("slashco/survivor/baby_use.mp3")

				mauled_child:SetMoveType(MOVETYPE_NONE)
				mauled_child:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				mauled_child:SetModel(SlashCoItems.Baby.Model)
				mauled_child:SetPos(pos)
				mauled_child:SetAngles(ang)
				mauled_child:FollowBone(slasher, slasher:LookupBone("head"))

				for i = 1, math.random(9, 12) do
					timer.Simple((i / 3.5) * (0.7 + (math.random() * 0.3)), function()
						local vPoint = mauled_child:GetPos()
						local bloodfx = EffectData()
						bloodfx:SetOrigin(vPoint)
						util.Effect("BloodImpact", bloodfx)

						slasher:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
					end)
				end

				timer.Simple(3.75, function()
					if not IsValid(slasher) then
						return
					end

					local vPoint = mauled_child:GetPos()
					local bloodfx = EffectData()
					bloodfx:SetOrigin(vPoint)
					util.Effect("BloodImpact", bloodfx)

					slasher:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav")

					mauled_child:Remove()

					slasher.SlasherValue2 = slasher.SlasherValue2 + math.random(15, 20)
					slasher.SlasherValue1 = v1 - math.random(25, v1 + 26)
				end)

				---yeah

				timer.Simple(4.5, function()
					if not IsValid(slasher) then
						return
					end

					slasher:Freeze(false)
					slasher:SetNWBool("PrincessMaulingChild", false)
					slasher:SetNWBool("DemonPacified", true)

					timer.Simple(math.random(10, 25), function()
						slasher:SetNWBool("DemonPacified", false)
					end)
				end)
			end
		end
	end

	if v2 > 100 then
		slasher.SlasherValue2 = 100
	end

	if v1 < 0 then
		slasher.SlasherValue1 = 0
	end

	if slasher:GetNWInt("PrincessAggression") ~= math.floor(slasher.SlasherValue1) then
		slasher:SetNWInt("PrincessAggression", math.floor(slasher.SlasherValue1))
	end

	if slasher:GetNWInt("PrincessAggressionThres") ~= math.floor(slasher.SlasherValue2) then
		slasher:SetNWInt("PrincessAggressionThres", math.floor(slasher.SlasherValue2))
	end

	if IsValid(slasher.victimragdoll) and IsValid(slasher.ref_child) then
		local PhysBone = slasher.victimragdoll:GetPhysicsObjectNum(0)

		if IsValid(PhysBone) then
			PhysBone:SetPos(slasher.ref_child:LocalToWorld(Vector(0, 0, 0)))
			PhysBone:SetAngles(slasher.ref_child:LocalToWorldAngles(Angle(0, 0, 0)))
		end
	end

	slasher:SetNWFloat("Slasher_Eyesight", eyesight)
	slasher:SetNWInt("Slasher_Perception", perception)
end

SLASHER.Maul = function(slasher, target)
	timer.Remove("princessMaul_" .. slasher:UserID())
	slasher:EmitSound("slashco/slasher/princess_bite.mp3")

	local vPoint = target:GetPos()
	local bloodfx = EffectData()
	bloodfx:SetOrigin(vPoint)
	util.Effect("BloodImpact", bloodfx)

	if slasher.SlasherValue1 <= 99 then
		return
	end

	SlashCo.StopChase(slasher)
	slasher:SetNWBool("PrincessMaulingBase", false)

	timer.Simple(FrameTime() * 3, function()
		if not IsValid(slasher) or not IsValid(target) then
			return
		end

		slasher:SetNWBool("PrincessMaulingSurvivor", true)
		target:TakeDamage(99999, slasher, slasher)

		timer.Simple(FrameTime() * 3, function()
			if not IsValid(slasher) then
				return
			end

			slasher.victimragdoll = target and (target.DeadBody or NULL)
		end)
	end)

	slasher:EmitSound("slashco/slasher/princess_maul.mp3")

	local pos = slasher:LocalToWorld(Vector(0, 10, -5))
	local ang = slasher:LocalToWorldAngles(Angle(90, 0, 0))

	slasher.ref_child = ents.Create("prop_physics")
	slasher.ref_child:SetMoveType(MOVETYPE_NONE)
	slasher.ref_child:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	slasher.ref_child:SetModel(SlashCoItems.Baby.Model)
	slasher.ref_child:SetPos(pos)
	slasher.ref_child:SetAngles(ang)
	slasher.ref_child:FollowBone(slasher, slasher:LookupBone("head"))

	for i = 1, math.random(9, 10) do
		timer.Simple((i / 8) * (0.7 + (math.random() * 0.3)), function()
			if not IsValid(slasher.victimragdoll) then
				return
			end

			local vPoint1 = slasher.victimragdoll:GetPos()
			local bloodfx1 = EffectData()
			bloodfx:SetOrigin(vPoint1)
			util.Effect("BloodImpact", bloodfx1)

			slasher.victimragdoll:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
			slasher.victimragdoll:EmitSound("slashco/body_medium_impact_hard" .. math.random(1, 5) .. ".wav")
		end)
	end

	timer.Simple(2, function()
		if not IsValid(slasher) then
			return
		end

		slasher:SetNWBool("PrincessMaulingSurvivor", false)
		slasher:SetNWBool("PrincessMaulingBase", false)

		if not IsValid(slasher.victimragdoll) then
			return
		end

		slasher.ref_child:Remove()
		slasher.victimragdoll:Remove()

		local pickedclean = ents.Create("prop_ragdoll")
		pickedclean:SetModel("models/player/skeleton.mdl")
		pickedclean:SetPos(slasher:LocalToWorld(Vector(30, 0, 40)))
		pickedclean:SetNoDraw(false)
		pickedclean:Spawn()
		pickedclean:SetSkin(2)

		pickedclean:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav")

		local physCount = pickedclean:GetPhysicsObjectCount()

		for i = 0, (physCount - 1) do
			local PhysBone = pickedclean:GetPhysicsObjectNum(i)

			if PhysBone:IsValid() then
				PhysBone:SetVelocity(slasher:GetForward() * 600)
				PhysBone:AddAngleVelocity(-PhysBone:GetAngleVelocity())
			end
		end
	end)
end

SLASHER.OnPrimaryFire = function(slasher)
	if slasher:GetNWBool("PrincessMaulingChild") then
		return
	end
	if slasher:GetNWBool("PrincessSniffing") then
		return
	end
	if slasher:GetNWBool("DemonPacified") then
		return
	end
	if slasher:GetNWBool("PrincessMaulingBase") then
		return
	end

	if slasher.MaulTime and CurTime() - slasher.MaulTime < 3 then
		return
	end
	slasher.MaulTime = CurTime()

	slasher:SetNWBool("PrincessMaulingBase", true)
	slasher:EmitSound("slashco/slasher/princess_attack.mp3")

	if slasher:IsOnGround() then
		slasher:SetVelocity(slasher:GetForward() * 800)
	end

	timer.Create("princessMaul_" .. slasher:UserID(), 0.05, 8, function()
		if not IsValid(slasher) then
			return
		end

		local target = slasher:TraceHullAttack(slasher:EyePos(), slasher:LocalToWorld(Vector(45, 0, 30)),
				Vector(-40, -40, -60), Vector(40, 40, 60),
				math.random(15, 30) + math.random(0, math.floor(slasher.SlasherValue1 / 4)), DMG_SLASH, 5, false)

		if target:IsValid() and target:IsPlayer() and target:Team() == TEAM_SURVIVOR then
			SLASHER.Maul(slasher, target)
		end
	end)

	timer.Simple(0.7, function()
		if not IsValid(slasher) then
			return
		end

		if not slasher:GetNWBool("PrincessMaulingSurvivor") then
			slasher:SetNWBool("PrincessMaulingBase", false)
		end
	end)
end

SLASHER.OnSecondaryFire = function(slasher)
	SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
	if slasher:GetNWBool("PrincessMaulingChild") then
		return
	end
	if slasher:GetNWBool("PrincessMaulingSurvivor") then
		return
	end
	if slasher:GetNWBool("PrincessMaulingBase") then
		return
	end
	if slasher:GetNWBool("PrincessSniffing") then
		return
	end
	if slasher:GetNWBool("InSlasherChaseMode") then
		return
	end

	slasher:SetNWBool("PrincessSniffing", true)
	slasher:Freeze(true)
	slasher:EmitSound("slashco/slasher/princess_sniff.mp3")

	timer.Simple(4, function()
		if not IsValid(slasher) then
			return
		end

		slasher:SetNWBool("PrincessSniffing", false)
		slasher:Freeze(false)

		slasher:SlasherHudFunc("Sniff")
	end)
end

SLASHER.OnSpecialAbilityFire = function(slasher)
end

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")
	local maul_child = ply:GetNWBool("PrincessMaulingChild")
	local maul_normal = ply:GetNWBool("PrincessMaulingBase")
	local maul_survivor = ply:GetNWBool("PrincessMaulingSurvivor")
	local sniff = ply:GetNWBool("PrincessSniffing")

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	if maul_child then
		ply.CalcSeqOverride = ply:LookupSequence("maul_child")
		ply:SetPlaybackRate(1)
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif maul_normal then
		ply.CalcSeqOverride = ply:LookupSequence("maul")
		ply:SetPlaybackRate(1)
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif maul_survivor then
		ply.CalcSeqOverride = ply:LookupSequence("maul_survivor")
		ply:SetPlaybackRate(1)
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	elseif sniff then
		ply.CalcSeqOverride = ply:LookupSequence("sniff")
		ply:SetPlaybackRate(1)
		if ply.anim_antispam == nil or ply.anim_antispam == false then
			ply:SetCycle(0)
			ply.anim_antispam = true
		end
	else
		ply.anim_antispam = false
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function(ply)
	if SERVER then
		ply:EmitSound("slashco/slasher/princess_step" .. math.random(1, 3) .. ".mp3")

		timer.Simple(0.15, function()
			ply:EmitSound("slashco/slasher/princess_step" .. math.random(1, 3) .. ".mp3")
		end)

		return true
	end

	if CLIENT then
		return true
	end
end

local maulTable = {
	default = Material("slashco/ui/icons/slasher/s_17_a1"),
	["d/"] = Material("slashco/ui/icons/slasher/kill_disabled")
}

SLASHER.InitHud = function(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_17"))
	hud:SetTitle("Princess")

	hud:AddControl("R", "sniff", Material("slashco/ui/icons/slasher/s_17"))
	hud:AddControl("LMB", "maul", maulTable)
	hud:TieControl("LMB", "DemonPacified", true, false, false)
	hud:ChaseAndKill(nil, true)

	hud:AddMeter("aggro", 50, "%", false, true)
	hud:TieMeterInt("aggro", "PrincessAggression")

	hud.SniffIcon = Material("slashco/ui/particle/sniff_hint")
	function hud:Sniff()
		local survivors = team.GetPlayers(TEAM_SURVIVOR)
		local sniffables = table.Add(survivors, ents.FindByClass("sc_baby"))
		if table.Count(sniffables) <= 0 then
			return
		end

		self.SniffPos = table.Random(sniffables):WorldSpaceCenter()

		local inaccuracy = math.max(self.SniffPos:Distance(LocalPlayer():GetPos()) / 12, 50)
		self.SniffRandom = VectorRand(-inaccuracy, inaccuracy)
		hook.Add("HUDPaint", "SlashCoSniff", function()
			if LocalPlayer():Team() ~= TEAM_SLASHER or self.SniffPos:Distance(LocalPlayer():GetPos()) < 150 then
				hook.Remove("HUDPaint", "SlashCoSniff")
				return
			end

			local screenPos = (self.SniffPos + self.SniffRandom):ToScreen()
			local xClamp = math.Clamp(screenPos.x, 200, ScrW() - 200)
			local yClamp = math.Clamp(screenPos.y, 200, ScrH() - 200)

			surface.SetMaterial(self.SniffIcon)
			surface.DrawTexturedRect(xClamp - ScrW() / 64, yClamp - ScrW() / 64, ScrW() / 32, ScrW() / 32)
		end)
	end

	hud.prevThresh = -1
	function hud.AlsoThink()
		local thresh = LocalPlayer():GetNWInt("PrincessAggressionThres")
		if thresh ~= hud.prevThresh then
			hud:SetMeterMax("aggro", thresh)
			hud.prevThresh = thresh
		end
	end
end

SLASHER.PreDrawHalos = function()
	SlashCo.DrawHalo(ents.FindByClass("sc_baby"), nil, 2, false)

	local plyWithItem = {}
	for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
		if v:HasItem("Baby") then
			table.insert(plyWithItem, v)
		end
	end

	SlashCo.DrawHalo(plyWithItem, nil, 2, false)
end

SlashCo.RegisterSlasher(SLASHER, "Princess")