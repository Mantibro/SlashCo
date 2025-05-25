--set up language

SlashCo = SlashCo or {}

SlashCo.LangTable = {}
include("slashco/lang/en.lua")
SlashCo.LangTableFallback = table.Copy(SlashCo.LangTable)
SlashCo.CurrentLang = SlashCo.CurrentLang or "en"

function SlashCo.LoadLanguage()
	local lang_files, _ = file.Find("slashco/lang/*.lua", "LUA")
	for _, v in ipairs(lang_files) do
		local lang = string.lower(language.GetPhrase("slashco.language"))
		if lang == string.lower(string.Replace(v, ".lua", "")) then
			include("slashco/lang/" .. v)

			if file.Exists("slashco/patch/lang/" .. v, "LUA") then
				include("slashco/patch/lang/" .. v)
			end

			if SlashCo.CurrentLang != lang then
				SlashCo.CurrentLang = lang
				hook.Run("SlashCo:LanguageChanged") -- In case any system needs a hook, why doesn't gmod have a hook already :(
			end

			break
		end
	end
end
SlashCo.LoadLanguage()

cvars.AddChangeCallback("gmod_language", function()
	SlashCo.LoadLanguage()
end, "SlashCo:LanguageChanged")

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

include("sh_shared.lua")
include("sh_content.lua")
include("ui/cl_scoreboard.lua")
include("cl_headbob.lua")
include("ui/cl_fonts.lua")

include("items/items_init.lua")
include("slasher/slasher_init.lua")
include("documents/cl_documents.lua")

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
include("ui/cl_pings.lua")
include("ui/cl_documents.lua")
include("sh_values.lua")
include("sh_doors.lua")
include("sh_chattext.lua")
include("sh_bhop.lua")
include("sh_roundpoints.lua")
include("sh_canbeseen.lua")
include("sh_player.lua")

include("ui/cl_projector.lua")
include("ui/cl_voiceselect.lua")
include("ui/slasher_stock/cl_slasher_control.lua")
include("ui/slasher_stock/cl_slasher_meter.lua")
include("ui/slasher_stock/cl_slasher_stock.lua")
include("ui/slasher_stock/sh_slasher_hudfunctions.lua")
include("cl_limitedzone.lua")
include("cl_thirdperson.lua")

CreateClientConVar("slashco_cl_disable_pp", 0, true, false, "Disable post processing effects for survivors.", 0, 1)
CreateClientConVar("slashco_cl_playermodel", "models/slashco/survivor/male_01.mdl", true, true,
		"SlashCo Survivor Playermodel")

--[[
cvars.AddChangeCallback("slashco_cl_playermodel", function(_, _, newVal)
	if newVal ~= "models/slashco/survivor/male_0*.mdl" then
		--print("[SlashCo] Bad Playermodel. It will be randomized instead.")
	end
end)
--]]

SlashCoTestConfig = false

local disable = {
	CHudHealth = true,
	CHudBattery = true,
	CHudWeaponSelection = true
}

hook.Add("HUDShouldDraw", "DisableDefaultHUD", function(name)
	return not disable[name]
end)

local skyBoxVec = Vector(0, 0, 100000)
function GM:SetupWorldFog() -- A basic world fog that dynamicly changes depending on the environment
	if GameData.IsLobby then return end
	if GameData.LocalPlayer:Team() == TEAM_SPECTATOR then return end

	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogColor(0, 0, 0)
	render.FogMaxDensity(1)

	local targetFogStart = 200
	local pos = GameData.LocalPlayer:GetPos()
	local isVisible = util.IsSkyboxVisibleFromPoint(pos)
	local targetFogEnd = 3000

	if not isVisible then
		targetFogEnd = 1000 -- Were somewere hidden, like in a basement.
	else
		targetFogEnd = 2000 -- Were somewere like in a building but outside light still reaches the player
	end

	local tr = util.TraceLine({
		start = pos,
		endpos = pos + skyBoxVec,
		collisiongroup = COLLISION_GROUP_WORLD,
		mask = MASK_VISIBLE,
	})

	if tr.HitSky then
		targetFogEnd = 3000
	end

	if GetGlobal2Bool("DisableWorldFog") then
		targetFogStart = 9000
		targetFogEnd = 10000
	end

	local col = render.GetLightColor(pos)
	local brighness = (0.299 * col[1] + 0.587 * col[2] + 0.114 * col[3]) * 50
	brighness = math.min(brighness, 1) - 0.5

	targetFogEnd = targetFogEnd + (targetFogEnd * brighness)

	if (targetFogStart * 1.5) >= targetFogEnd then
		targetFogEnd = targetFogStart * 1.5
	end

	local mult = GameData.LocalPlayer:GetNW2Float("FogMult", 1)
	GameData.LastFogStart = Lerp(0.005, GameData.LastFogStart or 3000, targetFogStart * mult)
	GameData.LastFogEnd = Lerp(0.005, GameData.LastFogEnd or 3000, targetFogEnd * mult)
	--print(targetFogEnd, brighness, GameData.LastFogEnd)

	render.FogStart(GameData.LastFogStart)
	render.FogEnd(GameData.LastFogEnd)

	return true
end

function GM:DrawDeathNotice()
	return false
end

local fx_t = 0

hook.Add("RenderScreenspaceEffects", "BloomEffect", function()
	if GameData.LocalPlayer:Team() ~= TEAM_SURVIVOR then
		return
	end

	if GetConVar("slashco_cl_disable_pp"):GetBool() then
		return
	end

	GameData.LocalPlayer:ItemFunction("Screenspace")
	DrawBokehDOF(0.35, 1, 12)
	DrawSharpen(5, 0.15)
	DrawBloom(0.85, 2, 9, 9, 1, 1, 1, 1, 1)

	local hp = GameData.LocalPlayer:Health()
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
	if ply ~= GameData.LocalPlayer or ply:Team() ~= TEAM_LOBBY then
		return
	end

	if key == IN_RELOAD then
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

	for k, v in pairs(_ents) do
		if IsValid(v) and (v:IsPlayer() and not v:CanBeSeen() or v:IsDormant()) then
			table.remove(_ents, k)
		end
	end

	halo.Add(_ents, haloColor, math.abs(math.sin(CurTime())) * 2, math.abs(math.sin(CurTime())) * 2, passes or 1, nil, noZ)
end

hook.Add("PreDrawHalos", "octoSlashCoClientPreDrawHalos", function()
	g_SlashCoDrawingHalos = true

	local ply = GameData.LocalPlayer
	local _team = ply:Team()
	if _team == TEAM_SLASHER then
		SlashCo.DrawHalo(ents.FindByClass("sc_generator"), "yellow")
		SlashCo.DrawHalo(ents.FindByClass("sc_babaclone"))
		SlashCo.DrawHalo(ents.FindByClass("sc_maleclone"))
		ply:SlasherFunction("PreDrawHalos")

		g_SlashCoDrawingHalos = false
		return
	end

	if _team == TEAM_SPECTATOR then
		if showHalos then
			SlashCo.DrawHalo(ents.FindByClass("sc_generator"), "yellow")
			SlashCo.DrawHalo(team.GetPlayers(TEAM_SURVIVOR), "blue")
			SlashCo.DrawHalo(team.GetPlayers(TEAM_SLASHER), "red")
			if showGasCanHalos then
				SlashCo.DrawHalo(ents.FindByClass("sc_gascan"), "gray")
			end
		end

		g_SlashCoDrawingHalos = false
		return
	end

	if _team == TEAM_SURVIVOR then
		ply:ItemFunction("PreDrawHalos")

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
	local ply = GameData.LocalPlayer
	if not ply:CanSeeFlashlights() then
		for _, target in ipairs(cache) do
			if target.DynamicFlashlight then
				target.DynamicFlashlight:Remove()
				target.DynamicFlashlight = nil
			end
		end

		return
	end

	for _, target in ipairs(cache) do
		if target:GetNW2Bool("DynamicFlashlight") and (target:CanBeSeen() or target == ply) then
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

net.Receive("mantislashco_GiveSlasherData", function()
	local SlasherTable = net.ReadTable()
	local ply = GameData.LocalPlayer
	if not ply:IsValid() then
		return
	end

	GameProgress = SlasherTable.GameProgress
	SurvivorTeam = SlasherTable.AllSurvivors
	SlasherTeam = SlasherTable.AllSlashers
	GameReady = SlasherTable.GameReadyToBegin

	if ply:Team() == TEAM_SLASHER then
		hook.Run("BaseSlasherHUD")
	end
end)

SlashCo.GlobalSounds = SlashCo.GlobalSounds or {}

timer.Create("PermanentSounds", 1, 0, function()
	for _, v in pairs(SlashCo.GlobalSounds) do
		if not v.permanent then
			continue
		end

		if not v.snd:IsPlaying() then
			v.snd:Stop()
			v.snd:Play()
		end
	end
end)

local function removeAllSounds(entID)
	for _, v in pairs(SlashCo.GlobalSounds) do
		if v.entID ~= entID then
			continue
		end

		v.permanent = false
		v.snd:Stop()
	end
end

local function removeSound(soundPath, entID)
	if soundPath == "" then
		removeAllSounds(entID)
		return
	end

	local entry = SlashCo.GlobalSounds[entID .. soundPath]
	if not entry then
		return
	end

	entry.permanent = false
	entry.snd:Stop()
end

local function addSound(soundPath, entID)
	local soundLevel = net.ReadUInt(14)
	local vol = net.ReadFloat()
	local permanent = net.ReadBool()

	local ent = Entity(entID)
	if not IsValid(ent) then
		return
	end

	local snd
	if SlashCo.GlobalSounds[entID .. soundPath] then
		snd = SlashCo.GlobalSounds[entID .. soundPath].snd
	else
		snd = CreateSound(ent, soundPath)
	end

	snd:Stop() -- it won't play again otherwise
	snd:Play()

	snd:SetSoundLevel(soundLevel)
	snd:ChangeVolume(vol)

	SlashCo.GlobalSounds[entID .. soundPath] = { snd = snd, permanent = permanent, entID = entID }
end

net.Receive("mantislashco_GlobalSound", function()
	local isRemove = net.ReadBool()
	local soundPath = net.ReadString()
	local entID = net.ReadUInt(MAX_EDICT_BITS)

	if isRemove then
		removeSound(soundPath, entID)
	else
		addSound(soundPath, entID)
	end
end)

local KillIcon = Material("slashco/ui/icons/slasher/s_0")
local KillDisabledIcon = Material("slashco/ui/icons/slasher/kill_disabled")

local SurvivorIcon = Material("slashco/ui/icons/slasher/s_survivor")
local SurvivorDeadIcon = Material("slashco/ui/icons/slasher/s_survivor_dead")

hook.Add("HUDPaint", "AwaitingPlayersHUD", function()
	if GameData.IsLobby then
		return
	end

	if GameData.LocalPlayer:Team() ~= TEAM_SPECTATOR then
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

		if GameData.LocalSteamID64 == SurvivorTeam[i].id then
			draw.SimpleText(SCInfo.Survivor, "LobbyFont2", ScrW() * 0.5, ScrH() * 0.7,
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

net.Receive("mantislashco_SendGlobalInfoTable", function()
	SCInfo = net.ReadTable()
end)

net.Receive("mantislashco_Briefing", function()
	BriefingTable = net.ReadTable()
end)

local b_tick = -500
hook.Add("PostDrawOpaqueRenderables", "LobbyScreens", function()
	if not GameData.IsLobby then
		return
	end

	if bDrawingDepth or bDrawingSkybox or isDraw3DSkybox then return end

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

		local slasherID = BriefingTable.ID
		local slasherClass = BriefingTable.CLASS
		local slasherDanger = BriefingTable.DANGER
		local slasherName = BriefingTable.NAME
		local pro_tip = BriefingTable.TIP

		cam.Start3D2D(pos, angle, 0.09)

		local monitorsize = 1300
		local txtcolor = color_white
		local slasherClassTranslated = SlashCo.Language(TranslateSlasherClass(slasherClass))
		local slasherDangerTranslated = SlashCo.Language(TranslateDangerLevel(slasherDanger))

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(-monitorsize / 2, -monitorsize / 2, monitorsize, monitorsize)

		surface.SetDrawColor(0, 0, 0, 255)
		draw.SimpleText(SlashCo.Language("briefing"), "BriefingFont", 25 - monitorsize / 2, 25 - monitorsize / 2, color_white)
		draw.SimpleText(SlashCo.Language("Name", ""), "BriefingFont", 25 - monitorsize / 2, 250 - monitorsize / 2, color_white)

		txtcolor = SlashCo.CopyColor(SlashCo.GetNameColor(slasherName))
		txtcolor[4] = b_tick - 0

		draw.SimpleText(SlashCo.Language(slasherName), "BriefingFont", 900 - monitorsize / 2, 250 - monitorsize / 2, txtcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(SlashCo.Language("Class", ""), "BriefingFont", 25 - monitorsize / 2, 350 - monitorsize / 2, color_white)

		txtcolor = SlashCo.CopyColor(SlashCo.GetClassColor(slasherClass))
		txtcolor[4] = b_tick - 255

		draw.SimpleText(slasherClassTranslated, "BriefingFont", 900 - monitorsize / 2, 350 - monitorsize / 2, txtcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(SlashCo.Language("DangerLevel", ""), "BriefingFont", 25 - monitorsize / 2, 450 - monitorsize / 2, color_white)

		txtcolor = SlashCo.CopyColor(SlashCo.GetDangerColor(slasherDanger))
		txtcolor[4] = b_tick - 255

		draw.SimpleText(slasherDangerTranslated, "BriefingFont", 900 - monitorsize / 2, 450 - monitorsize / 2, txtcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(SlashCo.Language("Notes") .. ":", "BriefingFont", 25 - monitorsize / 2, 700 - monitorsize / 2, color_white)

		local icondrawid = 0
		if b_tick > 200 then
			draw.SimpleText(SlashCo.Language(pro_tip), "BriefingNoteFont", 25 - monitorsize / 2, 800 - monitorsize / 2, color_white)

			if slasherID ~= nil and slasherID ~= 0 then
				icondrawid = slasherID
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

net.Receive("mantislashco_HelicopterVoice", function()
	local t = net.ReadUInt(4)
	local id = net.ReadUInt(4)

	if t == SlashCo.HelicopterVoices.INTRO then
		GameData.LocalPlayer:EmitSound("slashco/helipilot/helipilot_intro" .. id .. ".mp3", 100)
		return
	end

	if t == SlashCo.HelicopterVoices.APPROACH then
		GameData.LocalPlayer:EmitSound("slashco/helipilot/helipilot_approach" .. id .. ".mp3", 100)
		return
	end

	if t == SlashCo.HelicopterVoices.LAND then
		GameData.LocalPlayer:EmitSound("slashco/helipilot/helipilot_land" .. id .. ".mp3", 100)
		return
	end

	if t == SlashCo.HelicopterVoices.BEACON then
		GameData.LocalPlayer:EmitSound("slashco/helipilot/helipilot_beacon" .. id .. ".mp3", 100)
		return
	end
end)

local AmbientMusic
local AmbientLength
local AmbientVol = 0.8

net.Receive("mantislashco_MapAmbientPlay", function()
	timer.Simple(math.random(1, 8), function()
		SlashCoMapAmbience()
	end)
end)

function SlashCoMapAmbience()
	if GameData.LocalPlayer:Team() == TEAM_SLASHER then
		return
	end

	local snd = "sound/slashco/maps/" .. GameData.Map .. ".mp3"
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

hook.Add("Think", "amb_vol", function()
	if g_AmbientStop then
		AmbientVol = 0
	end

	if IsValid(AmbientMusic) then
		AmbientMusic:SetVolume(AmbientVol)
	end

	if GameData.LocalPlayer:GetNWBool("SurvivorChased") then
		if AmbientVol > 0 then
			AmbientVol = AmbientVol - RealFrameTime()
		end
	else
		if AmbientVol < 0.8 then
			AmbientVol = AmbientVol + (RealFrameTime() / 100)
		end
	end
end)

g_SCLoadedSounds = g_SCLoadedSounds or {} --set as global to protect against lua restarts
function SlashCo.ReadSound(fileName)
	local _sound
	local filter
	if not g_SCLoadedSounds[fileName] then
		_sound = CreateSound(game.GetWorld(), fileName, filter)
		if _sound then
			_sound:SetSoundLevel(0)
			g_SCLoadedSounds[fileName] = { _sound, filter }
		end
	else
		_sound = g_SCLoadedSounds[fileName][1]
		filter = g_SCLoadedSounds[fileName][2]
	end

	if _sound then
		_sound:Stop()
		_sound:Play()
	end

	return _sound
end

local function WasSeenBySlasher(_, _, old, new)
	if new then
		SlashCo.AudioSystem.CreateChannel("slashco/survivor/seen_by_slasher.mp3", "mono noplay", function(channel)
			channel:SetVolume(0)
			channel:Play()
			SlashCo.AudioSystem.FadeTo(channel, 1)
			SlashCo.AudioSystem.ParentChannelToEntity(channel, GameData.LocalPlayer)

			timer.Create("SlashCo:SeenBySlasherSound", 1, 0, function() -- Properly unregister the channel when it finished playing.
				if not IsValid(channel) or channel:GetState() != GMOD_CHANNEL_PLAYING then
					SlashCo.AudioSystem.DestroyChannel(channel)
					timer.Remove("SlashCo:SeenBySlasherSound")
				end
			end)
		end)
	end
end

local function SetupWasSeenHook()
	local ply = GameData and GameData.LocalPlayer or LocalPlayer()

	ply:SetNW2VarProxy("WasSeenBySlasher", WasSeenBySlasher)

	-- Plays the sound if the player was already seen
	-- WasSeenBySlasher(nil, nil, nil, ply:WasSeenBySlasher())
end

hook.Add("InitPostEntity", "SlashCo:WasLocalPlayerSeenBySlasher", SetupWasSeenHook)
if game.GetWorld() != NULL then
	SetupWasSeenHook()
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