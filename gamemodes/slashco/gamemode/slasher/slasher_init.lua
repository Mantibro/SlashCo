AddCSLuaFile()

SlashCo = SlashCo or {}
SlashCoSlashers = SlashCoSlashers or {}

---load slashers

function SlashCo.RegisterSlasher(table, name)
	if SC_LOADEDSLASHERS then
		error("Tried to register a slasher illegally", 2)
		return
	end

	SlashCoSlashers[name] = table
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

function TranslateSlasherClass(id)
	if id == 0 then
		return "Unknown"
	end
	if id == 1 then
		return "Cryptid"
	end
	if id == 2 then
		return "Demon"
	end
	if id == 3 then
		return "Umbra"
	end
end

function TranslateDangerLevel(id)
	if id == 0 then
		return "Unknown"
	end
	if id == 1 then
		return "Moderate"
	end
	if id == 2 then
		return "Considerable"
	end
	if id == 3 then
		return "Devastating"
	end
end

function GetRandomSlasher()
	local keys = table.GetKeys(SlashCoSlashers)
	local rand, rand_name
	repeat
		rand = math.random(1, #keys)
		rand_name = keys[rand] --random id for this roll
	until SlashCoSlashers[rand_name].IsSelectable and rand_name ~= "Leuonard"

	return rand_name
end

--Slasher Animation Controller
hook.Add("CalcMainActivity", "SlasherAnimator", function(ply, vel)
	if ply:Team() ~= TEAM_SLASHER then
		return
	end

	return ply:SlasherFunction("Animator", vel)
end)

hook.Add("PlayerFootstep", "SlasherFootstep", function(ply)
	if ply:Team() ~= TEAM_SLASHER then
		return
	end

	return ply:SlasherFunction("Footstep")
end)

if CLIENT then
	local StepNotice = Material("slashco/ui/particle/step_notice")
	local timeSinceLast = 0
	hook.Add("Think", "Slasher_Vision_Light", function()
		if LocalPlayer():Team() ~= TEAM_SLASHER then
			return
		end

		local Eyesight = LocalPlayer():GetNWInt("Slasher_Eyesight")

		--Eyesight - an arbitrary range from 1 - 10 which decides how illuminated the Slasher 'vision is client-side. (1 - barely any illumination, 10 - basically fullbright )

		local dlight = DynamicLight(LocalPlayer():EntIndex())
		if dlight then
			dlight.pos = LocalPlayer():GetShootPos()
			dlight.r = 50 + (Eyesight * 2)
			dlight.g = 50 + (Eyesight * 2)
			dlight.b = 50 + (Eyesight * 2)
			dlight.brightness = 0.1 + Eyesight / 50
			dlight.Decay = 1000
			dlight.Size = 70 + 250 * Eyesight
			dlight.DieTime = CurTime() + 1
		end

		local slasherpos = LocalPlayer():GetPos()
		local PerceptionReal = 0
		if not LocalPlayer():GetNWBool("InSlasherChaseMode") then
			PerceptionReal = LocalPlayer():GetNWInt("Slasher_Perception")
		end

		timeSinceLast = timeSinceLast + FrameTime() / 3
		if timeSinceLast > 0.2 then
			timeSinceLast = 0
		end

		--Survivor Step Notice
		for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			local survivor = v

			if survivor:ItemFunction("OnFootstep") then
				continue
			end

			local vel = (survivor:GetVelocity()):Length()
			local range = 3 * vel * PerceptionReal
			local pos = survivor:GetPos()
			local em = ParticleEmitter(pos)
			local part = em:Add(StepNotice, pos)

			if part and timeSinceLast == 0 and (slasherpos):Distance(pos) < range and survivor:IsOnGround() then
				part:SetColor(255, 255, 255, math.random(255))
				part:SetVelocity(Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)):GetNormal() * 20)
				part:SetDieTime(1)
				part:SetLifeTime(0)
				part:SetStartSize(25)
				part:SetEndSize(0)
			end

			em:Finish()
		end

		--Step Decoy Step Notice
		for i = 1, #ents.FindByClass("sc_stepdecoy") do
			local boot = ents.FindByClass("sc_stepdecoy")[i]
			local vel = 300
			local range = 3 * vel * PerceptionReal
			local offsetpos = Vector(math.random(-2, 2), math.random(-2, 2), 0)
			local pos = boot:GetPos() + offsetpos
			local em = ParticleEmitter(pos)
			local part = em:Add(StepNotice, pos)

			if part and timeSinceLast == 0 and (slasherpos):Distance(pos) < range then
				part:SetColor(255, 255, 255, math.random(255))
				part:SetVelocity(Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)):GetNormal() * 20)
				part:SetDieTime(1)
				part:SetLifeTime(0)
				part:SetStartSize(25)
				part:SetEndSize(0)
			end

			em:Finish()
		end

		LocalPlayer():SlasherFunction("ClientSideEffect")
	end)

	hook.Add("RenderScreenspaceEffects", "SlasherVision", function()
		if LocalPlayer():Team() ~= TEAM_SLASHER then
			return
		end

		local Eyesight = LocalPlayer():GetNWInt("Slasher_Eyesight")

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