--set up language

SlashCo = SlashCo or {}

SlashCo.LangTable = {}
include("slashco/lang/en.lua")
SlashCo.LangTableFallback = table.Copy(SlashCo.LangTable)

local lang_files, _ = file.Find("slashco/lang/*.lua", "LUA")
for _, v in ipairs(lang_files) do
	if string.lower(language.GetPhrase("slashco.language")) == string.lower(string.Replace(v, ".lua", "")) then
		include("slashco/lang/" .. v)
		if file.Exists("slashco/patch/lang/" .. v, "LUA") then
			include("slashco/patch/lang/" .. v)
		end
		break
	end
end

function SlashCo.Language(key, ...)
	local vars = {}
	for _, v in ipairs({ ... }) do
		if type(v) == "string" then
			table.insert(vars, SlashCo.Language(v))
		else
			table.insert(vars, v)
		end
	end

	if SlashCo.LangTable[key] then
		return string.format(SlashCo.LangTable[key], unpack(vars))
	elseif SlashCo.LangTableFallback[key] then
		return string.format(SlashCo.LangTableFallback[key], unpack(vars))
	else
		return string.format(Localize("slashco." .. string.gsub(key, " ", "_"), key), unpack(vars))
	end
end

net.Receive("mantislashcoGiveMasterDatabase", function(_, _)
	local t = net.ReadTable()
	data_load = t

	if data_load then
		CL_srvwin_count = data_load[1].SurvivorRoundsWon
		CL_slswin_count = data_load[1].SlasherRoundsWon
		CL_points = data_load[1].Points
	end
end)

include("sh_shared.lua")
include("ui/cl_scoreboard.lua")
include("cl_headbob.lua")
include("ui/cl_fonts.lua")

include("items/items_init.lua")
include("slasher/slasher_init.lua")

include("ui/cl_lobbyhud.lua")
include("ui/cl_survivor_hud.lua")
include("ui/cl_roundend_hud.lua")
include("ui/cl_slasher_ui.lua")
include("slasher/cl_slasher_picker.lua")
include("ui/cl_item_picker.lua")
include("ui/cl_offering_picker.lua")
include("ui/cl_offervote_hud.lua")
include("ui/cl_spectator_hud.lua")
include("ui/cl_playermodel_picker.lua")
include("ui/cl_gameinfo.lua")
include("sh_values.lua")
include("sh_doors.lua")
include("sh_chattext.lua")
include("sh_bhop.lua")

include("ui/cl_projector.lua")
include("ui/cl_voiceselect.lua")
include("ui/slasher_stock/cl_slasher_control.lua")
include("ui/slasher_stock/cl_slasher_meter.lua")
include("ui/slasher_stock/cl_slasher_stock.lua")
include("ui/slasher_stock/sh_slasher_hudfunctions.lua")
include("cl_limitedzone.lua")

CreateClientConVar("slashcohud_disable_pp", 0, true, false, "Disable post processing effects for survivors.", 0, 1)
CreateClientConVar("cl_slashco_playermodel", "models/slashco/survivor/male_01.mdl", true, true,
		"SlashCo Survivor Playermodel")

--[[
cvars.AddChangeCallback("cl_slashco_playermodel", function(_, _, newVal)
	if newVal ~= "models/slashco/survivor/male_0*.mdl" then
		--print("[SlashCo] Bad Playermodel. It will be randomized instead.")
	end
end)
--]]

function GM:HUDDrawTargetID()
	return false
end

SlashCoTestConfig = false

local disable = {
	CHudHealth = true,
	CHudBattery = true,
	CHudWeaponSelection = true
}

hook.Add("HUDShouldDraw", "DisableDefaultHUD", function(name)
	return not disable[name]
end)

function GM:DrawDeathNotice(_, _)
	return false
end

local fx_t = 0

local rand = 0
hook.Add("RenderScreenspaceEffects", "BloomEffect", function()
	if LocalPlayer():Team() ~= TEAM_SURVIVOR then
		return
	end

	--Benadryl

	if LocalPlayer():GetNWBool("SurvivorBenadryl") then
		if not LocalPlayer().BenadrylIntensity then
			LocalPlayer().BenadrylIntensity = RealFrameTime()
		end

		LocalPlayer().BenadrylIntensity = LocalPlayer().BenadrylIntensity + (RealFrameTime() / 277)
		if LocalPlayer().BenadrylIntensity > 1 then
			LocalPlayer().BenadrylIntensity = -1
		end

		local fuck = math.min(math.abs(LocalPlayer().BenadrylIntensity) * 2, 1)
		rand = rand + (math.random() / 3)
		local contrast = 3.5 + math.sin((CurTime() + rand) / 10) * 3
		local bloom = 3 + math.cos((CurTime() + rand) / 2) * 1
		local bloom2 = 3 + math.cos((CurTime() + rand) / 4) * 1
		local bokeh = -3 + math.cos((CurTime() + rand) / 20) * 4

		DrawBloom(0.5, fuck * bloom * 1.5, fuck * bloom2 * 9, fuck * bloom2 * 9, 1, 8, 2, 2, 2)
		DrawBokehDOF(12 * fuck, fuck * bokeh, 4 * fuck)

		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1 + (fuck * contrast),
			["$pp_colour_colour"] = 1 - fuck,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
		DrawMotionBlur(fuck * 0.75 + (contrast * 0.08), fuck * 0.8, fuck * 0.07)
		DrawSharpen(fuck * bloom, fuck * bloom)
	else
		LocalPlayer().BenadrylIntensity = 0
	end

	if GetConVar("slashcohud_disable_pp"):GetBool() then
		return
	end

	LocalPlayer():ItemFunction("Screenspace")
	DrawBokehDOF(0.35, 1, 12)
	DrawSharpen(5, 0.15)
	DrawBloom(0.85, 2, 9, 9, 1, 1, 1, 1, 1)

	local hp = LocalPlayer():Health()
	if hp < 30 then
		fx_t = fx_t + RealFrameTime() * 0.25
		DrawBokehDOF(12, 0.4, 4 - math.sin(fx_t) * (3 - (hp / 10)))
		DrawColorModify({
			["$pp_colour_addr"] = math.sin(fx_t) * 0.05 * (1 - (hp / 30)),
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		})
	end
end)

hook.Add("KeyPress", "PlayerSelect", function(ply, key)
	if ply ~= LocalPlayer() or ply:Team() ~= TEAM_LOBBY then
		return
	end

	if key == 8192 then
		DrawThePlayermodelSelectorBox()
	end
end)

net.Receive("octoSlashCoTestConfigHalos", function()
	hook.Add("PreDrawHalos", "octoSlashCoTestConfigPreDrawHalos", function()
		halo.Add(ents.FindByClass("prop_physics"), Color(255, 0, 0), 2, 2, 8, true, true)
		halo.Add(ents.FindByClass("sc_*"), Color(0, 255, 255), 2, 2, 4, true, true)
	end)
	SlashCoTestConfig = true
end)

showHalos = true
showGasCanHalos = false

local colors = {
	red = Color(255, 0, 0),
	blue = Color(0, 0, 255),
	yellow = Color(255, 255, 0),
	gray = Color(200, 200, 200)
}

---draw halos; can only be used in the below function
function SlashCo.DrawHalo(_ents, color, passes, noZ)
	if not g_SlashCoDrawingHalos then
		error("Using SlashCo.DrawHalo illegally", 2)
		return
	end

	local haloColor = colors.red
	if colors[color] then
		haloColor = colors[color]
	elseif type(colors) == "Color" then
		haloColor = color
	end

	if noZ == nil then
		noZ = true
	end
	halo.Add(_ents, haloColor, math.abs(math.sin(CurTime())) * 2, math.abs(math.sin(CurTime())) * 2, passes or 1, nil,
			noZ)
end

hook.Add("PreDrawHalos", "octoSlashCoClientPreDrawHalos", function()
	g_SlashCoDrawingHalos = true

	if LocalPlayer():Team() == TEAM_SLASHER then
		SlashCo.DrawHalo(ents.FindByClass("sc_generator"), "yellow")
		SlashCo.DrawHalo(ents.FindByClass("sc_babaclone"))
		SlashCo.DrawHalo(ents.FindByClass("sc_maleclone"))
		LocalPlayer():SlasherFunction("PreDrawHalos")

		g_SlashCoDrawingHalos = false
		return
	end

	if LocalPlayer():Team() == TEAM_SPECTATOR then
		if showHalos then
			SlashCo.DrawHalo(ents.FindByClass("sc_generator"), "yellow")
			SlashCo.DrawHalo(team.GetPlayers(TEAM_SURVIVOR), "blue")
			SlashCo.DrawHalo(team.GetPlayers(TEAM_SLASHER))
			if showGasCanHalos then
				SlashCo.DrawHalo(ents.FindByClass("sc_gascan"), "gray")
			end
		end

		g_SlashCoDrawingHalos = false
		return
	end

	if LocalPlayer():Team() == TEAM_SURVIVOR then
		LocalPlayer():ItemFunction("PreDrawHalos")

		g_SlashCoDrawingHalos = false
		return
	end

	g_SlashCoDrawingHalos = false
end)

g_FlashlightCache = g_FlashlightCache or {}
local cache = g_FlashlightCache

local function UpdateCache(entity, state)
	if not entity:IsPlayer() then
		return
	end

	if state then
		table.insert(cache, entity)
	else
		for i = 1, #cache do
			if cache[i] == entity then
				table.remove(cache, i)
			end
		end
	end
end

hook.Add("NotifyShouldTransmit", "DynamicFlashlight.PVS_Cache", function(entity, state)
	UpdateCache(entity, state)
end)

hook.Add("EntityRemoved", "DynamicFlashlight.PVS_Cache", function(entity)
	UpdateCache(entity, false)
end)

hook.Add("Think", "DynamicFlashlight.Rendering", function()
	for _, target in ipairs(cache) do
		if target:GetNWBool("DynamicFlashlight") then
			if target.DynamicFlashlight then
				local position = target:GetPos()
				local newposition = Vector(position[1], position[2], position[3] + 40) + target:GetForward() * 20

				target.DynamicFlashlight:SetPos(newposition)
				target.DynamicFlashlight:SetAngles(target:EyeAngles())
				target.DynamicFlashlight:Update()
			else
				target.DynamicFlashlight = ProjectedTexture()
				target.DynamicFlashlight:SetTexture("effects/flashlight001")
				target.DynamicFlashlight:SetFarZ(900)
				target.DynamicFlashlight:SetFOV(70)
			end
		else
			if target.DynamicFlashlight then
				target.DynamicFlashlight:Remove()
				target.DynamicFlashlight = nil
			end
		end
	end
end)

net.Receive("mantislashcoGiveSlasherData", function()
	local SlasherTable = net.ReadTable()
	if not LocalPlayer():IsValid() then
		return
	end

	GameProgress = SlasherTable.GameProgress
	SurvivorTeam = SlasherTable.AllSurvivors
	SlasherTeam = SlasherTable.AllSlashers
	GameReady = SlasherTable.GameReadyToBegin

	if LocalPlayer():Team() == TEAM_SLASHER then
		hook.Run("BaseSlasherHUD")
	end
end)

net.Receive("mantislashcoGlobalSound", function()
	local t = net.ReadTable()

	EmitSound(t.SoundPath, LocalPlayer():GetPos(), t.Entity:EntIndex(), CHAN_AUTO, t.Volume, t.SndLevel)
end)

local KillIcon = Material("slashco/ui/icons/slasher/s_0")
local KillDisabledIcon = Material("slashco/ui/icons/slasher/kill_disabled")

local SurvivorIcon = Material("slashco/ui/icons/slasher/s_survivor")
local SurvivorDeadIcon = Material("slashco/ui/icons/slasher/s_survivor_dead")

hook.Add("HUDPaint", "AwaitingPlayersHUD", function()
	if game.GetMap() == "sc_lobby" then
		return
	end

	if LocalPlayer():Team() ~= TEAM_SPECTATOR then
		return
	end

	if GameProgress ~= -1 then
		return
	end

	surface.SetDrawColor(255, 255, 255, 255)

	local xoffset = (#SurvivorTeam + #SlasherTeam) * -50 - 25
	--local xoffset = -250

	for i = 1, #SurvivorTeam do
		--Survivor team visualization before game start

		for x = 1, #team.GetPlayers(TEAM_SPECTATOR) do
			if team.GetPlayers(TEAM_SPECTATOR)[x]:SteamID64() == SurvivorTeam[i].id then
				surface.SetMaterial(SurvivorIcon)
				surface.DrawTexturedRect(ScrW() / 2 + xoffset, ScrH() / 2 + ScrH() / 18, ScrW() / 20, ScrW() / 20)

				goto SKIP
			end
		end

		if LocalPlayer():SteamID64() == SurvivorTeam[i].id then
			draw.SimpleText(SCInfo.Survivor, "LobbyFont2", ScrW() * 0.5, (ScrH() * 0.7),
					Color(255, 0, 0, slashershow_tick), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		surface.SetMaterial(SurvivorDeadIcon)
		surface.DrawTexturedRect(ScrW() / 2 + xoffset, ScrH() / 2 + ScrH() / 18, ScrW() / 20, ScrW() / 20)

		:: SKIP ::

		xoffset = xoffset + 100
	end

	for i = 1, #SlasherTeam do
		--Slashers visualization before game start

		for x = 1, #team.GetPlayers(TEAM_SPECTATOR) do
			if team.GetPlayers(TEAM_SPECTATOR)[x]:SteamID64() == SlasherTeam[i].s_id then
				surface.SetMaterial(KillIcon)
				surface.DrawTexturedRect(ScrW() / 2 + xoffset + 50, ScrH() / 2 + ScrH() / 18, ScrW() / 20, ScrW() / 20)

				goto SKIP
			end
		end

		surface.SetMaterial(KillDisabledIcon)
		surface.DrawTexturedRect(ScrW() / 2 + xoffset + 50, ScrH() / 2 + ScrH() / 18, ScrW() / 20, ScrW() / 20)

		:: SKIP ::

		xoffset = xoffset + 100
	end

	if GameReady == true then
		draw.SimpleText(SlashCo.Language("player_ready"), "ItemFont", ScrW() / 2, ScrH() / 2, color_white,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(SlashCo.Language("player_await"), "ItemFont", ScrW() / 2, ScrH() / 2, color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER)

	end
end)

net.Receive("mantislashcoSendGlobalInfoTable", function()
	SCInfo = net.ReadTable()
end)

net.Receive("mantislashcoBriefing", function()
	BriefingTable = net.ReadTable()
end)

local b_tick = -500
hook.Add("PostDrawOpaqueRenderables", "LobbyScreens", function()
	if game.GetMap() ~= "sc_lobby" then
		return
	end

	do
		local ent = table.Random(ents.FindByClass("sc_offertable"))
		local angle = ent:LocalToWorldAngles(Angle(0, 90, 90))
		local pos = ent:LocalToWorld(Vector(5, 0, 110))

		cam.Start3D2D(pos, angle, 0.15)
		-- Get the size of the text we are about to draw

		local text = SlashCo.Language("offering_idle")

		if offering_name ~= nil then
			text = SlashCo.Language("Offering_name", offering_name)
		end

		surface.SetFont("LobbyFont1")
		local tW, tH = surface.GetTextSize(text)

		local pad = 5

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(-tW / 2 - pad, -pad, tW + pad * 2, tH + pad * 2)

		-- Draw some text
		draw.SimpleText(text, "LobbyFont1", -tW / 2, 0, color_white)
		cam.End3D2D()
	end

	do
		local angle = Angle(0, -90, 90)
		local pos = Vector(-133, 400, 80)

		if BriefingTable == nil then
			return
		end

		b_tick = b_tick + 0.5

		local s_id = BriefingTable.ID
		local s_cls = BriefingTable.CLS
		local s_dng = BriefingTable.DNG
		local s_n = BriefingTable.NAME
		local pro_tip = BriefingTable.TIP

		cam.Start3D2D(pos, angle, 0.09)

		local monitorsize = 1300
		local txtcolor = color_white
		local s_cls_t = SlashCo.Language(TranslateSlasherClass(s_cls))
		local s_dng_t = SlashCo.Language(TranslateDangerLevel(s_dng))

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(-monitorsize / 2, -monitorsize / 2, monitorsize, monitorsize)

		surface.SetDrawColor(0, 0, 0, 255)
		draw.SimpleText(SlashCo.Language("briefing"), "BriefingFont", 25 - monitorsize / 2, 25 - monitorsize / 2,
				color_white)

		draw.SimpleText(SlashCo.Language("Name", ""), "BriefingFont", 25 - monitorsize / 2, 250 - monitorsize / 2,
				color_white)
		if s_n == "Unknown" then
			txtcolor = Color(200, 0, 0, (b_tick - 0))
		else
			txtcolor = Color(255, 255, 255, (b_tick - 0))
		end

		draw.SimpleText(SlashCo.Language(s_n), "BriefingFont", 900 - monitorsize / 2, 250 - monitorsize / 2, txtcolor,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_TOP)

		draw.SimpleText(SlashCo.Language("Class", ""), "BriefingFont", 25 - monitorsize / 2, 350 - monitorsize / 2,
				color_white)
		if s_cls == 0 then
			txtcolor = Color(200, 0, 0, (b_tick - 255))
		else
			txtcolor = Color(255, 255, 255, (b_tick - 255))
		end

		draw.SimpleText(s_cls_t, "BriefingFont", 900 - monitorsize / 2, 350 - monitorsize / 2, txtcolor,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		draw.SimpleText(SlashCo.Language("DangerLevel", ""), "BriefingFont", 25 - monitorsize / 2,
				450 - monitorsize / 2, color_white)

		if s_dng == 1 then
			txtcolor = Color(255, 255, 0, (b_tick - (255 * 2)))
		elseif s_dng == 2 then
			txtcolor = Color(255, 155, 155, (b_tick - (255 * 2)))
		elseif s_dng == 3 then
			txtcolor = Color(255, 0, 0, (b_tick - (255 * 2)))
		else
			txtcolor = Color(200, 0, 0, (b_tick - (255 * 2)))
		end

		draw.SimpleText(s_dng_t, "BriefingFont", 900 - monitorsize / 2, 450 - monitorsize / 2, txtcolor,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		draw.SimpleText(SlashCo.Language("Notes") .. ":", "BriefingFont", 25 - monitorsize / 2, 700 - monitorsize / 2,
				color_white)

		local icondrawid = 0

		if b_tick > 200 then
			draw.SimpleText(SlashCo.Language(pro_tip), "BriefingNoteFont", 25 - monitorsize / 2, 800 - monitorsize / 2,
					color_white)

			if s_id ~= nil and s_id ~= 0 then
				icondrawid = s_id
			end
		else
			draw.SimpleText("...", "BriefingNoteFont", 25 - monitorsize / 2, 800 - monitorsize / 2, color_white)
			icondrawid = 0
		end

		local MainIcon = Material("slashco/ui/icons/slasher/s_" .. icondrawid)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MainIcon)
		surface.DrawTexturedRect(150, 90, monitorsize / 3, monitorsize / 3)
		cam.End3D2D()
	end
end)

net.Receive("mantislashcoHelicopterVoice", function()
	local t = net.ReadUInt(4)

	if t == 1 then
		LocalPlayer():EmitSound("slashco/helipilot/helipilot_intro" .. math.random(1, 8) .. ".mp3", 100)
		return
	end

	if t == 2 then
		LocalPlayer():EmitSound("slashco/helipilot/helipilot_approach" .. math.random(1, 5) .. ".mp3", 100)
		return
	end

	if t == 3 then
		LocalPlayer():EmitSound("slashco/helipilot/helipilot_land" .. math.random(1, 5) .. ".mp3", 100)
		return
	end

	if t == 4 then
		LocalPlayer():EmitSound("slashco/helipilot/helipilot_beacon" .. math.random(1, 5) .. ".mp3", 100)
		return
	end
end)

local AmbientMusic
local AmbientLength
local AmbientVol = 1

net.Receive("mantislashcoMapAmbientPlay", function()
	timer.Simple(math.random(1, 8), function()
		SlashCoMapAmbience()
	end)
end)

function SlashCoMapAmbience()
	if LocalPlayer():Team() == TEAM_SLASHER then
		return
	end

	local snd = "sound/slashco/maps/" .. game.GetMap() .. ".mp3"
	if not file.Exists(snd, "GAME") then
		return
	end

	sound.PlayFile(snd, "noplay", function(music, errCode, errStr)
		if IsValid(music) then
			AmbientMusic = music
			AmbientMusic:Play()

			AmbientLength = AmbientMusic:GetLength()

			timer.Simple(AmbientLength + math.random(15, 100), function()
				SlashCoMapAmbience()
			end)
		else
			print("[SlashCo] Error playing map ambient!", errCode, errStr)
		end
	end)
end

local BenadrylSound
local CreateShadowPerson = function(pos, ang)
	if not LocalPlayer():GetNWBool("SurvivorBenadrylFull") then
		return
	end

	local Ent = ents.CreateClientside("sc_shadowman")

	if not IsValid(Ent) then
		MsgC(Color(255, 50, 50),
				"[SlashCo] Something went wrong when trying to create a " .. class .. " at (" .. tostring(pos) .. "), entity was NULL.\n")
		return nil
	end

	Ent:SetPos(pos)
	Ent:SetAngles(ang)
	Ent:Spawn()
	Ent:Activate()

	local id = Ent:EntIndex()

	return id
end

hook.Add("Think", "amb_vol", function()
	if g_AmbientStop then
		AmbientVol = 0
	end

	if IsValid(AmbientMusic) then
		AmbientMusic:SetVolume(AmbientVol)
	end

	if LocalPlayer():GetNWBool("SurvivorChased") then
		if AmbientVol > 0 then
			AmbientVol = AmbientVol - RealFrameTime()
		end
	else
		if AmbientVol < 1 then
			AmbientVol = AmbientVol + (RealFrameTime() / 100)
		end
	end

	--Benadryl

	if LocalPlayer():GetNWBool("SurvivorBenadryl") then
		if not BenadrylSound then
			sound.PlayFile("sound/slashco/benadryl_base.mp3", "noplay", function(music, errCode, errStr)
				if IsValid(music) then
					BenadrylSound = music

					timer.Simple(0.01, function()
						BenadrylSound:Play()
					end)

				end
			end)
		else
			local vol = 0
			if LocalPlayer().BenadrylIntensity then
				vol = math.abs(LocalPlayer().BenadrylIntensity)
			end
			BenadrylSound:SetVolume(vol)
		end

		if not LocalPlayer().ShadowManTick then
			LocalPlayer().ShadowManTick = CurTime()
		end

		local frequency = 0

		if LocalPlayer().BenadrylIntensity then
			frequency = math.abs(LocalPlayer().BenadrylIntensity)
		end

		if CurTime() - LocalPlayer().ShadowManTick > 3 - (frequency * 2) then
			CreateShadowPerson(LocalPlayer():GetPos() + Vector(math.random(-750, 750), math.random(-750, 750),
					math.random(50, 50)), Angle(0, math.random(1, 360), 0))
			LocalPlayer().ShadowManTick = CurTime()
		end
	elseif IsValid(BenadrylSound) then
		BenadrylSound:Stop()
		BenadrylSound = nil
	end
end)

hook.Add("HUDPaint", "MiscItemVisions", function()
	if LocalPlayer():Team() ~= TEAM_SURVIVOR then
		return
	end

	if LocalPlayer():GetNWBool("SurvivorBenadrylFull") then
		if not LocalPlayer().BenadrylVisionTick then
			LocalPlayer().BenadrylVisionTick = 10
		end

		if not LocalPlayer().BenadrylVision then
			LocalPlayer().BenadrylVision = math.random(0, 30)
		end

		if LocalPlayer().BenadrylVisionTick < 1 then

			local Overlay = Material("slashco/ui/overlays/benadryl_visions")
			Overlay:SetInt("$frame", math.floor(LocalPlayer().BenadrylVision))

			Overlay:SetFloat("$alpha", LocalPlayer().BenadrylVisionTick / 8)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		end

		if LocalPlayer().BenadrylVisionTick < 0 then
			LocalPlayer().BenadrylVision = math.random(0, 30)
			LocalPlayer().BenadrylVisionTick = 1 + (math.random() * 5)
		end

		LocalPlayer().BenadrylVisionTick = LocalPlayer().BenadrylVisionTick - (RealFrameTime() * 1)
	end

	if LocalPlayer():GetNWBool("JugCurseActivate") then
		local Overlay = Material("slashco/ui/overlays/jug_freeze")

		if LocalPlayer().JugFrame < 61 then
			Overlay:SetInt("$frame", math.floor(LocalPlayer().JugFrame))
			Overlay:SetFloat("$alpha", 1)
		else
			Overlay:SetInt("$frame", 60)
			Overlay:SetFloat("$alpha", (1 - ((LocalPlayer().JugFrame - 61) / 60)))

			if math.floor(LocalPlayer().JugFrame) == 61 then
				LocalPlayer():EmitSound("slashco/jug_curse.mp3")
			end

		end

		LocalPlayer().JugFrame = LocalPlayer().JugFrame + RealFrameTime() * 30
		if LocalPlayer().JugFrame < 120 then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Overlay)
			surface.DrawTexturedRect(0, 0 - (ScrW() / 6), ScrW(), ScrW())
		end
	else
		LocalPlayer().JugFrame = 0
	end
end)

g_SCLoadedSounds = {} --set as global to protect against lua restarts
function SlashCo.ReadSound(fileName)
	local sound
	local filter
	if not g_SCLoadedSounds[fileName] then
		sound = CreateSound(game.GetWorld(), fileName, filter)
		if sound then
			sound:SetSoundLevel(0)
			g_SCLoadedSounds[fileName] = { sound, filter }
		end
	else
		sound = g_SCLoadedSounds[fileName][1]
		filter = g_SCLoadedSounds[fileName][2]
	end
	if sound then
		sound:Stop()
		sound:Play()
	end
	return sound
end

SC_CLIENT_LOADED = true

---load patch files; these are specifically intended to modify existing addon code

local shared_patches = file.Find("slashco/patch/shared/*.lua", "LUA")
for _, v in ipairs(shared_patches) do
	include("slashco/patch/shared/" .. v)
end

local client_patches = file.Find("slashco/patch/client/*.lua", "LUA")
for _, v in ipairs(client_patches) do
	include("slashco/patch/client/" .. v)
end