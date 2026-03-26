local SLASHER = {}

SLASHER.PlayersToBecomePartOfCovenant = {}

SLASHER.Name = "The Covenant"
SLASHER.Aliases = {
	"Low Tier God",
}
SLASHER.ID = 18
SLASHER.Class = SlashCo.SlasherClass.Cryptid
SLASHER.DangerLevel = SlashCo.DangerLevel.Devastating
SLASHER.IsSelectable = true
SLASHER.Model = "models/slashco/slashers/covenant/covenant.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 297
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 137
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.7
SLASHER.ChaseDuration = 15.0
SLASHER.ChaseCooldown = 3
SLASHER.JumpscareDuration = 2.0
SLASHER.ChaseMusic = "slashco/slasher/covenant/covenant_chase.ogg"
SLASHER.KillSound = ""
SLASHER.Description = "Covenant_desc"
SLASHER.ProTip = "Covenant_tip"
SLASHER.SpeedRating = "★★★★☆"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★☆☆"

function SLASHER.OnBalanceForPlayers(totalSurvivors, additionalSurvivors)
	SLASHER.ChaseDuration = 15.0 + (2 * additionalSurvivors)

	if additionalSurvivors > 0 then
		SLASHER.ProwlSpeed = 150 + (3 * additionalSurvivors)
		SLASHER.ChaseSpeed = 297 + (0.5 * additionalSurvivors)
	end
end

function SLASHER.OnSpawn(slasher)
	local idx = math.random(1, 6)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/slasher/covenant/covenant_ritual" .. idx .. ".mp3",
		identifier = "CovenantRitual" .. idx,
		minDistance = 1200 * SlashCo.MapSize,
		maxDistance = 2400 * SlashCo.MapSize,
		entity = slasher,
		volume = 1,
		fadeIn = 0,
	})

	slasher:SetNWBool("CanChase", true)
	slasher.RockSummoned = false
end

function SLASHER.SummonCovenantMembers(target)
	-- Now accepts an argument for the converted player
	local clk = target
	if IsValid(clk) then
		SlashCo.SelectSlasher("CovenantCloak", clk:SteamID64())
		SlashCo.ApplySlasherToPlayer(clk)
		clk:SetTeam(TEAM_SLASHER)
		clk:Spawn()
		SlashCo.OnSlasherSpawned(clk)
		SlashCo.BroadcastCurrentRoundData(false)

		-- Add player to table in case we need it
		SLASHER.PlayersToBecomePartOfCovenant[clk:SteamID64()] = true
	end
end

function SLASHER.SummonRocks(vic)
	SlashCo.SelectSlasher("CovenantRocks", vic:SteamID64())
	SlashCo.ApplySlasherToPlayer(vic)
	vic:SetTeam(TEAM_SLASHER)
	vic:Spawn()
	SlashCo.OnSlasherSpawned(vic)
	SlashCo.BroadcastCurrentRoundData(false)
end

function SLASHER.OnTickBehaviour(slasher, cloak)
	for _, cloak in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		--Sync the chase for every slasher, meaning every covenant member

		if slasher:GetNWBool("InSlasherChaseMode") then
			if not cloak:GetNWBool("InSlasherChaseMode") then
				SlashCo.StartChaseMode(cloak)
			end

			cloak.CurrentChaseTick = 0
		else
			if cloak:GetNWBool("InSlasherChaseMode") then
				SlashCo.StopChase(cloak)
			end
		end
	end

	if slasher.RockSummoned then
		SLASHER.ProwlSpeed = 175
		SLASHER.ChaseSpeed = 275
	end

	slasher:SetEyeSight(SLASHER.Eyesight)
	slasher:SetPerception(SLASHER.Perception)
end

function SLASHER.OnPrimaryFire(slasher, target)
	if not IsValid(target) or not target:IsPlayer() then return end
	if target:Team() ~= TEAM_SURVIVOR then return end
	if slasher:GetPos():Distance(target:GetPos()) > SLASHER.KillDistance then return end

	if not slasher:GetNWBool("CovenantSummoning") then
		target:Kill()
		timer.Simple(FrameTime(), function()
			local ragdoll = target.DeadBody

			local physCount = ragdoll:GetPhysicsObjectCount()

			timer.Simple(2, function()
				for i = 0, (physCount - 1) do
					local PhysBone = ragdoll:GetPhysicsObjectNum(i)

					if PhysBone:IsValid() then
						PhysBone:EnableGravity(false)
					end
				end
			end)

			if not slasher.RockSummoned then
				timer.Simple(4, function() -- First victim becomes Rocks
					SLASHER.SummonRocks(target)
					target:Freeze(true)

					timer.Simple(3, function()
						target:Freeze(false)
						target:SetNWBool("RocksBeingSummoned", false)
					end)
				end)

				slasher.PlayerToBecomeRocks = target
				target:SetNWBool("RocksBeingSummoned", true)
				slasher.RockSummoned = true
			else
				local slashPlys = team.GetPlayers(TEAM_SLASHER)
				if slashPlys == 6 then
					return
				else
					timer.Simple(4, function() -- Next victims becomes Cloaks
						SLASHER.SummonCovenantMembers(target)
						target:Freeze(true)

						timer.Simple(3, function()
							target:Freeze(false)
							target:SetNWBool("CloaksBeingSummoned", false)
						end)
					end)

					target:SetNWBool("CloaksBeingSummoned", true)
				end
			end

			timer.Simple(6, function()
				local Dissolver = ents.Create("env_entity_dissolver")
				timer.Simple(1, function()
					if IsValid(Dissolver) then
						Dissolver:Remove() -- backup edict save on error
					end
				end)

				Dissolver.Target = "dissolve" .. ragdoll:EntIndex()
				Dissolver:SetKeyValue("dissolvetype", 0)
				Dissolver:SetKeyValue("magnitude", 0)
				Dissolver:SetPos(ragdoll:GetPos())
				Dissolver:SetPhysicsAttacker(slasher)
				Dissolver:Spawn()

				ragdoll:SetName(Dissolver.Target)

				Dissolver:Fire("Dissolve", Dissolver.Target, 0)
				Dissolver:Fire("Kill", "", 0.1)

				slasher:SetNWBool("CovenantSummoning", false)
				slasher:Freeze(false)
			end)

			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/slasher/covenant/covenant_summoning.mp3",
				identifier = "CovenantSummoning",
				minDistance = 400 * SlashCo.MapSize,
				maxDistance = 800 * SlashCo.MapSize,
				entity = slasher,
				volume = 1,
				fadeIn = 0,
			})

			slasher:SetNWBool("CovenantSummoning", true)
			slasher:Freeze(true)
		end)
	end
end

function SLASHER.OnSecondaryFire(slasher)
	SlashCo.StartChaseMode(slasher)
end

function SLASHER.Animator(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

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

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function SLASHER.Footstep(ply)
	if SERVER then
		local idx = math.random(1, 3)
		SlashCo.AudioSystem.PlaySound({
			soundPath = "slashco/slasher/bababooey/babastep_0" .. idx .. ".mp3",
			identifier = "CovenantFootstep" .. idx,
			minDistance = 200,
			maxDistance = 500,
			entity = ply,
			volume = 1,
			fadeIn = 0,
		})
	end

	return true
end

function SLASHER.InitHud(_, hud)
	hud:SetAvatar(Material("slashco/ui/icons/slasher/s_18"))
	hud:SetTitle("Covenant")

	hud:AddControl("LMB", "covenant_member", Material("slashco/ui/icons/slasher/s_covenantcloak"))
	hud:AddControl("RMB", "chase", Material("slashco/ui/icons/slasher/s_chase"))

	local surveyNoticeIcon = Material("slashco/ui/particle/icon_survey")
	hook.Add("SlashCo:DrawHUD", "SlashCo:SlasherHUD", function()
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			hook.Remove("SlashCo:DrawHUD", "SlashCo:SlasherHUD")
		end

		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if not survivor:CanBeSeen() then
				continue
			end

			if survivor:GetNWBool("MarkedByCloaks") then
				local pos = survivor:WorldSpaceCenter():ToScreen()

				if pos.visible then
					surface.SetMaterial(surveyNoticeIcon)
					surface.DrawTexturedRect(pos.x - ScrW() / 32, pos.y - ScrW() / 32, ScrW() / 16, ScrW() / 16)
				end
			end
		end
	end)
end

SlashCo.RegisterSlasher(SLASHER, "Covenant")