local ITEM = {}

ITEM.Model = "models/slashco/items/benadryl.mdl"
ITEM.Name = "Benadryl"
ITEM.EntClass = "sc_benadryl"
ITEM.Price = 30
ITEM.Description = "Benadryl_desc"
ITEM.CamPos = Vector(50, 0, 0)
function ITEM.DisplayColor()
	return 128, 48, 0, 255
end
function ITEM.OnUse(ply)
	ply:AddPoints("benadryl")
	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/benadryl/benadryl_cornstarch.ogg",
		identifier = "BenadrylEat",
		minDistance = 250,
		maxDistance = 550,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	if ply:GetNW2Float("InitialBenadrylTime", 0) == 0 then
		ply:SetNW2Float("InitialBenadrylTime", CurTime())
		timer.Simple(60, function()
			GameData.TestHatMan = ents.Create("sc_hatman")
			GameData.TestHatMan:SetTarget(ply)
			GameData.TestHatMan:Spawn()
		end)
	else
		GameData.TestHatMan = ents.Create("sc_hatman")
		GameData.TestHatMan:SetTarget(ply)
		GameData.TestHatMan:Spawn()
	end
end
ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(180, 20, 90),
	size = Vector(0.5, 0.5, 0.5),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModelHolstered = {
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_Pelvis",
	pos = Vector(10, 2, 5),
	angle = Angle(110, -80, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "slam",
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(1, 4.5, -1),
	angle = Angle(180, 0, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "Benadryl")

if SERVER then
	hook.Add("PostPlayerDeath", "SlashCo:RemoveBenadrylEffect", function(ply)
		if ply:Team() ~= TEAM_SPECTATOR then return end -- They survived, let their suffering continue.

		ply:SetNW2Float("InitialBenadrylTime", 0) -- Reset the benadryl time for its effects to stop.
	end)

	function TestHatMan()
		if IsValid(GameData.TestHatMan) then
			GameData.TestHatMan:Remove()
		end

		GameData.TestHatMan = ents.Create("sc_hatman")
		GameData.TestHatMan:SetTarget(Entity(1))
		GameData.TestHatMan:Spawn()
	end

	return
end

local fullBenadrylTime = 60 -- Time in seconds after which the benadryl is in full effect.
local function GetBenadrylTime(ply)
	return ply:GetNW2Float("InitialBenadrylTime", 0) -- if 0 benadryl isn't active.
end

local rand = 0
hook.Add("RenderScreenspaceEffects", "Benadryl", function()
	local benadrylTime = GetBenadrylTime(GameData.LocalPlayer)
	if benadrylTime == 0 then
		return
	end

	GameData.LocalPlayer.BenadrylIntensity = (GameData.LocalPlayer.BenadrylIntensity or RealFrameTime()) + (RealFrameTime() / 277)
	if GameData.LocalPlayer.BenadrylIntensity > 1 then
		GameData.LocalPlayer.BenadrylIntensity = -1
	end

	local freaker = math.min(math.abs(GameData.LocalPlayer.BenadrylIntensity) * 2, 1)
	rand = rand + (math.random() / 3)
	local contrast = 3.5 + math.sin((CurTime() + rand) / 10) * 3
	local bloom = 3 + math.sin((CurTime() + rand) / 2) * 1
	local bloom2 = 3 + math.sin((CurTime() + rand) / 4) * 1
	local bokeh = -3 + math.sin((CurTime() + rand) / 20) * 4

	local lookingTime = GameData.LocalPlayer:GetNW2Float("LookingAtHatMan", 0)
	if lookingTime > 0 then
		lookingTime = 1 + CurTime() - lookingTime
	else
		lookingTime = 1
	end

	DrawBloom(0.5, freaker * bloom * 1.5, freaker * bloom2 * 9, freaker * bloom2 * 9, 1, 8, 2, 2, 2)
	DrawBokehDOF(2 * freaker * lookingTime, freaker, 4 * freaker)

	local tab = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1 + (freaker * contrast) * lookingTime,
		["$pp_colour_colour"] = 1 - freaker,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}

	DrawColorModify(tab)
	DrawMotionBlur(freaker * 0.75 + (contrast * 0.08), freaker * 0.008, freaker * 0.0007)
	DrawSharpen(freaker * bloom, freaker * bloom)
end)

local function CreateShadowPerson(pos, ang)
	local benadrylTime = GetBenadrylTime(GameData.LocalPlayer)
	if benadrylTime == 0 or benadrylTime < fullBenadrylTime then
		return
	end

	local ent = ents.CreateClientside("sc_shadowman")
	if not IsValid(ent) then
		MsgC(Color(255, 50, 50), "[SlashCo] Something went wrong when trying to create a " .. class .. " at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()

	return ent:EntIndex()
end

GameData.BenadrylSoundID = GameData.BenadrylSoundID or math.random(1, 3)
hook.Add("Think", "Benadryl", function()
	local benadrylTime = GetBenadrylTime(GameData.LocalPlayer)
	if benadrylTime ~= 0 then
		if not IsValid(GameData.BenadrylSound) then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/benadryl/benadryl_mid" .. GameData.BenadrylSoundID .. ".ogg",
				identifier = "Benadryl",
				entity = 0, -- Play as Mono
				volume = 0,
				fadeIn = 0,
				callback = function(channel)
					GameData.BenadrylSound = channel
				end,
			})
		else
			local vol = 0
			if GameData.LocalPlayer.BenadrylIntensity then
				vol = math.abs(GameData.LocalPlayer.BenadrylIntensity)
			end
			GameData.BenadrylSound:SetVolume(vol)
		end

		if not GameData.LocalPlayer.ShadowManTick then
			GameData.LocalPlayer.ShadowManTick = CurTime()
		end

		local frequency = 0

		if GameData.LocalPlayer.BenadrylIntensity then
			frequency = math.abs(GameData.LocalPlayer.BenadrylIntensity)
		end

		if (CurTime() - GameData.LocalPlayer.ShadowManTick) > (3 - (frequency * 2)) then
			CreateShadowPerson(GameData.LocalPlayer:GetPos() + Vector(math.random(-750, 750), math.random(-750, 750),
					math.random(50, 50)), Angle(0, math.random(1, 360), 0))
			GameData.LocalPlayer.ShadowManTick = CurTime()
		end
	elseif IsValid(GameData.BenadrylSound) then
		SlashCo.AudioSystem.DestroyChannel(GameData.BenadrylSound, 0)
		GameData.BenadrylSound = nil
	end
end)