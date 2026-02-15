AddCSLuaFile()

SlashCo = SlashCo or {}
SlashCoSlashers = SlashCoSlashers or {}

---load slashers

function SlashCo.RegisterSlasher(table, name)
	if SC_LOADEDSLASHERS then
		error("Tried to register a slasher illegally", 2)
		return
	end

	name = name or table.Name
	SlashCoSlashers[name] = table

	if SERVER then
		for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
			local slasherTbl = SlashCoSlashers[slasher:GetNWString("Slasher")]
			if slasherTbl.OnBalanceForPlayers then
				slasherTbl.OnBalanceForPlayers(GameData.RoundStartSurvivorCount, GameData.RoundStartSurvivorCount - GameData.BaseMaxSurvivors)
			end
		end
	end
end

function SlashCo.GetSlasherTable(name)
	return SlashCoSlashers[name]
end

SC_LOADEDSLASHERS = nil

local slasher_files = file.Find("slashco/slasher/*.lua", "LUA")
for _, v in ipairs(slasher_files) do
	AddCSLuaFile("slashco/slasher/" .. v)
	include("slashco/slasher/" .. v)
end

SC_LOADEDSLASHERS = true

---remainder of init code

local PLAYER = FindMetaTable("Player")

--this doesn't include a team check because we assume that it's in a slasher-only context
function PLAYER:SlasherValue(value, fallback)
	local slasher = self:GetNWString("Slasher", "none")

	if SlashCoSlashers[slasher] and SlashCoSlashers[slasher][value] then
		return SlashCoSlashers[slasher][value]
	end

	return fallback
end

function PLAYER:SlasherFunction(value, ...)
	local slasher = self:GetNWString("Slasher", "none")

	if SlashCoSlashers[slasher] and SlashCoSlashers[slasher][value] then
		return SlashCoSlashers[slasher][value](self, ...)
	end
end

function PLAYER:SlasherStunDeafen(duration)
	local currentDuration = self:GetDeafenTime() - CurTime()
	if currentDuration < 0 then
		currentDuration = 0
	end

	if currentDuration > duration then return end -- Something already deafened him for longer. So we return to avoid conflicts.
	self:SetDeafenTime(CurTime() + duration)
end

function PLAYER:SlasherIsStunDeaf()
	return self:GetDeafenTime() > CurTime()
end

function TranslateSlasherClass(id)
	return SlashCo.SlasherClass[id]
end

function TranslateDangerLevel(id)
	return SlashCo.DangerLevel[id]
end

function SlashCo.GetRandomSlasher(dangerlevel, slasherClass)
	dangerlevel = dangerlevel or SlashCo.DangerLevel.Unknown
	slasherClass = slasherClass or SlashCo.SlasherClass.Unknown

	local acceptableSlashers = {}
	for id, slasher in pairs(SlashCoSlashers) do
		if not slasher.IsSelectable then continue end
		if slasher.Name == "Leuonard" then continue end

		if dangerlevel ~= SlashCo.DangerLevel.Unknown and dangerlevel ~= slasher.DangerLevel then continue end
		if slasherClass ~= SlashCo.SlasherClass.Unknown and slasherClass ~= slasher.Class then continue end

		table.insert(acceptableSlashers, id)
	end

	return acceptableSlashers[math.random(1, #acceptableSlashers)]
end

-- RaphaelIT7: No AddSlasherAnger for client!

function SlashCo.GetSlasherAnger(slasher)
	return slasher:GetNW2Float("SlasherAnger", 0)
end

function SlashCo.GetGlobalSlasherAnger()
	local slashers = team.GetPlayers(TEAM_SLASHER)
	local count = #slashers
	local totalAnger = 0

	for _, slasher in ipairs(slashers) do
		totalAnger = totalAnger + SlashCo.GetSlasherAnger(slasher)
	end

	return totalAnger / count
end

function SlashCo.GetHighestSlasherAnger()
	local highestAnger = 0
	for _, slasher in ipairs(team.GetPlayers(TEAM_SLASHER)) do
		local anger = SlashCo.GetSlasherAnger(slasher)
		if anger > highestAnger then
			highestAnger = anger
		end
	end

	return highestAnger
end

--Slasher Animation Controller
hook.Add("CalcMainActivity", "SlashCo:SlasherAnimator", function(ply, vel)
	if ply:Team() ~= TEAM_SLASHER then return end
	return ply:SlasherFunction("Animator", vel)
end)

hook.Add("PlayerFootstep", "SlashCo:SlasherFootstep", function(ply)
	if ply:Team() ~= TEAM_SLASHER then return end
	return ply:SlasherFunction("Footstep")
end)

hook.Add("Move", "SlashCo:SlasherMove", function(ply, mv)
	if ply:Team() ~= TEAM_SLASHER then return end
	return ply:SlasherFunction("Move", mv)
end)

hook.Add("FinishMove", "SlashCo:SlasherFinishMove", function(ply, mv)
	if ply:Team() ~= TEAM_SLASHER then return end
	return ply:SlasherFunction("FinishMove", mv)
end)

if CLIENT then
	local StepNotice = Material("slashco/ui/particle/step_notice")
	local timeSinceLast = 0
	local emitter = nil
	hook.Add("Think", "SlashCo:SlasherVisionLight", function()
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			return
		end

		local Eyesight = GameData.LocalPlayer:GetEyeSight(1)

		--Eyesight - an arbitrary range from 1 - 10 which decides how illuminated the Slasher 'vision is client-side. (1 - barely any illumination, 10 - basically fullbright )

		local dlight = DynamicLight(GameData.LocalPlayer:EntIndex())
		if dlight then
			dlight.pos = GameData.LocalPlayer:GetShootPos()
			dlight.r = 50 + (Eyesight * 2)
			dlight.g = 50 + (Eyesight * 2)
			dlight.b = 50 + (Eyesight * 2)
			dlight.brightness = 0.2 + Eyesight / 50
			dlight.Decay = 1000
			dlight.Size = 100 + 250 * Eyesight
			dlight.DieTime = CurTime() + 1
		end

		local slasherpos = GameData.LocalPlayer:GetPos()
		local PerceptionReal = 0
		if not GameData.LocalPlayer:GetNWBool("InSlasherChaseMode") then
			PerceptionReal = GameData.LocalPlayer:GetPerception()
		end

		timeSinceLast = timeSinceLast + FrameTime() / 3
		if timeSinceLast > 0.2 then
			timeSinceLast = 0
		end

		if not IsValid(emitter) then
			emitter = ParticleEmitter(Vector(0, 0, 0))
		end

		GameData.LocalPlayer:SlasherFunction("ClientSideEffect")

		if GameData.LocalPlayer:GetNW2Bool("Slasher:NoFootsteps") or GameData.LocalPlayer:SlasherIsStunDeaf() then
			return
		end

		--Survivor Step Notice
		for _, survivor in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if survivor:ItemFunction("OnFootstep") then
				continue
			end

			local vel = (survivor:GetVelocity()):Length()
			local range = 3 * vel * PerceptionReal
			local pos = survivor:GetPos()
			emitter:SetPos(pos)
			local part = emitter:Add(StepNotice, pos)

			if part and timeSinceLast == 0 and (slasherpos):Distance(pos) < range and survivor:IsOnGround() then
				part:SetColor(255, 255, 255, math.random(255))
				part:SetVelocity(Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)):GetNormal() * 20)
				part:SetDieTime(1)
				part:SetLifeTime(0)
				part:SetStartSize(25)
				part:SetEndSize(0)
			end
		end

		--Step Decoy Step Notice
		for _, boot in ipairs(ents.FindByClass("sc_stepdecoy")) do
			local vel = 300
			local range = 3 * vel * PerceptionReal
			local offsetpos = Vector(math.random(-2, 2), math.random(-2, 2), 0)
			local pos = boot:GetPos() + offsetpos
			emitter:SetPos(pos)
			local part = emitter:Add(StepNotice, pos)

			if part and timeSinceLast == 0 and (slasherpos):Distance(pos) < range then
				part:SetColor(255, 255, 255, math.random(255))
				part:SetVelocity(Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)):GetNormal() * 20)
				part:SetDieTime(1)
				part:SetLifeTime(0)
				part:SetStartSize(25)
				part:SetEndSize(0)
			end
		end
	end)

	hook.Add("RenderScreenspaceEffects", "SlashCo:SlasherVision", function()
		if GameData.LocalPlayer:Team() ~= TEAM_SLASHER then
			return
		end

		local Eyesight = GameData.LocalPlayer:GetEyeSight(1)

		local tab = {
			["$pp_colour_addr"] = 0.01,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1 + Eyesight / 5,
			["$pp_colour_colour"] = Eyesight / 5,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab) --Draws Color Modify effect
	end)
end

---load patch files; these are specifically intended to modify existing addon code
local slasher_patches = file.Find("slashco/patch/slasher/*.lua", "LUA")
for _, v in ipairs(slasher_patches) do
	AddCSLuaFile("slashco/patch/slasher/" .. v)
	include("slashco/patch/slasher/" .. v)
end