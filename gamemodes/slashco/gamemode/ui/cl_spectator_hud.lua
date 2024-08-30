net.Receive("mantislashcoLobbySlasherInformation", function()
	LobbySlasherInfo = net.ReadTable()
end)

local blur = Material("pp/blurscreen")
function SlashCo.Blur(panel)
	local x, y = 0, 0
	if panel then
		x, y = panel:LocalToScreen(0, 0)
	end

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(blur)

	local clipping = DisableClipping(false)
	for i = 1, 5 do
		blur:SetFloat("$blur", (i / 4) * 4)
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
	end
	DisableClipping(clipping)
end

local logo_mat = Material("slashco/ui/slashco_skull")
local function spinSkull(r)
	local flip = ((math.sin(r) > 0) ~= (math.cos(r) > 0)) and 90 or -90
	local shift1 = (math.cos(r) > 0) and math.sin(r) or (math.sin(r + math.pi))
	local shift2 = (math.cos(r) > 0) and math.cos(r) or (math.cos(r + math.pi))

	render.SetMaterial(logo_mat)
	cam.Start3D(Vector(-136, 0, 0), Angle(90, 0, 0), 55)
		render.SuppressEngineLighting(true)
		render.DrawQuadEasy(Vector(0, 0, -600), Vector(0, shift1, shift2), 100, 100, color_white, flip)
		render.SuppressEngineLighting(false)
	cam.End3D()
end

local spin = 0
local flash = 0

hook.Add("HUDPaint", "Spectator_Vision", function()
	local ply = LocalPlayer()

	if ply:Team() ~= TEAM_SPECTATOR then
		return
	end

	--Cool Spectator Lobby Menu

	if #team.GetPlayers(TEAM_SURVIVOR) < 1 and game.GetMap() == "sc_lobby" then
		local srvwin_count = CL_srvwin_count or 0
		local slswin_count = CL_slswin_count or 0

		SlashCo.Blur()

		spin = spin + (0.5 / (spin + 0.5)) / (spin + 1)

		if spin > math.pi * 4 + 1 then
			spin = 1
		end

		local blip = "☞ [,] ☜"
		if #team.GetPlayers(TEAM_LOBBY) > 6 then
			blip = "☓ [,] ☓"
		else
			flash = flash + RealFrameTime()
			if flash > 1 then flash = 0 end

			if flash > 0.5 then
				blip = "☛[,]☚"
			end
		end

		spinSkull(spin)

		draw.SimpleText(SlashCo.Language("Welcome", string.upper(LocalPlayer():Nick())), "TVCD", ScrW() / 2, ScrH() / 3.5,
				Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText("SLASHCO", "LobbyFont2", ScrW() / 2, ScrH() / 4,
				Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(blip, "TVCD", ScrW() / 2, ScrH() / 2,
				Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local players = CL_LobbyPlayers or #team.GetPlayers(TEAM_LOBBY)

		draw.SimpleText("[" .. players .. " / 7]", "TVCD", ScrW() / 2, ScrH() / 2.5,
				Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText("[" .. srvwin_count .. " " .. SlashCo.Language("SurvivorWins") .. "]  [" .. slswin_count .. " " .. SlashCo.Language("SlasherWins") .. "]",
				"TVCD", ScrW() * 0.5, ScrH() * 0.75, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if LobbySlasherInfo ~= nil then
		if LobbySlasherInfo.player ~= LocalPlayer():SteamID64() then
			return
		end

		if slashershow_tick == nil then
			slashershow_tick = 0
		end
		slashershow_tick = slashershow_tick + 0.25

		draw.SimpleText("You will play as: " .. LobbySlasherInfo.slasher, "LobbyFont2", ScrW() * 0.5, ScrH() * 0.6, Color(255, 0, 0, slashershow_tick), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	if game.GetMap() == "sc_lobby" then
		return
	end

	local show_slasher_anticipation = false

	if SlasherTeam then
		for i = 1, #SlasherTeam do
			if SlasherTeam[i].s_id == LocalPlayer():SteamID64() then
				if LocalPlayer():GetNWString("Slasher") and LocalPlayer():GetNWString("Slasher") ~= show_slasher_anticipation then
					local shower = "UNASSIGNED!"
					if SlashCoSlashers[LocalPlayer():GetNWString("Slasher")] then
						shower = SlashCo.Language(LocalPlayer():GetNWString("Slasher"))
					end
					show_slasher_anticipation = shower
				end
			end
		end
	end

	if show_slasher_anticipation ~= false then
		draw.SimpleText(SlashCo.Language("slasher_anticipation", show_slasher_anticipation), "LobbyFont2", ScrW() * 0.5, (ScrH() * 0.4), Color(255, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		return
	end

	if input.IsKeyDown(KEY_Q) then
		return
	end

	if GetGlobalBool("SpectatorsCanPing") then
		draw.SimpleText(SlashCo.Language("surv_ping", "MMB"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 230, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	draw.SimpleText("[" .. SlashCo.Language("spectating") .. "]", "TVCD", ScrW() * 0.5, ScrH() * 0.05, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	draw.SimpleText(SlashCo.Language("hide_info", "Q"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 290, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("toggle_halo", "ALT"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 200, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("toggle_halo_gas", "E"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 170, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("player_follow", "LMB"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 140, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("player_cycle", "RMB"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 110, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("switch_view", "SPACE"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 80, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("toggle_light", "R"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 50, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
end)

if CLIENT then
	hook.Add("PlayerButtonDown", "TestConfig_ID", function(ply, button)
		if ply ~= LocalPlayer() then
			return
		end
		if not IsFirstTimePredicted() then
			return
		end
		if button ~= 107 or not SlashCoTestConfig then
			return
		end

		if IsValid(ply:GetEyeTrace().Entity) then
			ply:ChatPrint("ENTITY SPAWNPOINT ID: " .. ply:GetEyeTrace().Entity:GetNWInt("SpawnPoint_ID"))
		end
	end)
end


hook.Add("KeyPress", "ToggleLight", function(ply, key)
	if not IsFirstTimePredicted() then
		return
	end
	if ply ~= LocalPlayer() or LocalPlayer():Team() ~= TEAM_SPECTATOR or SERVER then
		return
	end
	if SlasherSteamID ~= nil and SlasherSteamID == LocalPlayer():SteamID64() then
		return
	end

	if key == 8192 then
		vision = not vision
		local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
		Sndd:Play()
		Sndd:ChangeVolume(0.5, 0)
		Sndd:ChangePitch(100, 0)
	end

	if key == 262144 then
		showHalos = not showHalos
		local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
		Sndd:Play()
		Sndd:ChangeVolume(0.5, 0)
		Sndd:ChangePitch(100, 0)
	end

	if key == 32 then
		showGasCanHalos = not showGasCanHalos
		local Sndd = CreateSound(ply, Sound("slashco/blip.wav"))
		Sndd:Play()
		Sndd:ChangeVolume(0.5, 0)
		Sndd:ChangePitch(100, 0)
	end
end)

hook.Add("Think", "Spectator_Vision_Light", function()
	if vision == nil then
		vision = false
	end

	if LocalPlayer():Team() ~= TEAM_SPECTATOR then
		return
	end
	if not vision then
		return
	end

	if SlasherSteamID ~= nil and SlasherSteamID == LocalPlayer():SteamID64() then
		return
	end

	--Eyesight - an arbitrary range from 1 - 10 which decides how illuminated the Slasher 'vision is client-side. (1 - barely any illumination, 10 - basically fullbright )

	local dlight = DynamicLight(LocalPlayer():EntIndex() + 984)
	if dlight then
		dlight.pos = LocalPlayer():GetShootPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 1
		dlight.Decay = 1000
		dlight.Size = 2500
		dlight.DieTime = CurTime() + 0.1
	end
end)

local cutscene_views = {
	{
		Start = {Vector(388, 768, 110), Angle(25,0,0)},
		Stop = {Vector(388, 176, 110), Angle(25,50,0)},
		Speed = 1
	},
	{
		Start = {Vector(499, 843, 16), Angle(-17, 107, 0)},
		Stop = {Vector(829, 710, -114), Angle(-26, 137, 0)},
		Speed = 0.75
	},
	{
		Start = {Vector(1462, -926,43), Angle(-5, 149, 0)},
		Stop = {Vector(1462, -926, 403), Angle(15, 148.,0)},
		Speed = 1
	},
	{
		Start = {Vector(134, 443, 437), Angle(-2, -92, 0)},
		Stop = {Vector(440, 886, 281), Angle(-21, -143,0)},
		Speed = 0.5
	},
	{
		Start = {Vector(844, 930, 148), Angle(27, -89, 0)},
		Stop = {Vector(401,932, 148), Angle(22, -49,0)},
		Speed = 0.7
	},
	{
		Start = {Vector(-71, 642, 20), Angle(-5, 155, 0)},
		Stop = {Vector(-707, 644, 22), Angle(-5, 155, 0)},
		Speed = 1
	},
	{
		Start = {Vector(-88, 112, 127), Angle(11, -151, 0)},
		Stop = {Vector(-86, -422, 50), Angle(3, 135,0)},
		Speed = 1
	},
	{
		Start = {Vector(490, -80, 53), Angle(-11,-68, 0)},
		Stop = {Vector(815, -94, 63), Angle(-9, -118,0)},
		Speed = 0.25
	}
}
local cur_scene = nil
local cur_pos = Vector(0,0,0)
local cur_ang = Angle(0,0,0)

hook.Add("CalcView", "LobbySpecCam", function(pl, pos, ang, fov)
	if game.GetMap() ~= "sc_lobby" then
		return
	end

	if pl:Team() ~= TEAM_SPECTATOR then
		return
	end

	if not cur_scene then
		cur_scene = math.random(1, #cutscene_views)
		cur_pos = cutscene_views[cur_scene].Start[1]
		cur_ang = cutscene_views[cur_scene].Start[2]
	end

	local cur_dist = cur_pos:Distance( cutscene_views[cur_scene].Stop[1] )

	if cur_dist > 1 then
		local add = (cutscene_views[cur_scene].Stop[1] - cur_pos):GetNormalized()*RealFrameTime() * 30
		cur_pos = cur_pos + add * cutscene_views[cur_scene].Speed

		local total_dist = cutscene_views[cur_scene].Start[1]:Distance( cutscene_views[cur_scene].Stop[1] )
		local fraction = 1-(cur_dist / total_dist)
		cur_ang.pitch = cutscene_views[cur_scene].Start[2].pitch + ( (cutscene_views[cur_scene].Stop[2].pitch - cutscene_views[cur_scene].Start[2].pitch) * (fraction/360) )
		cur_ang.yaw = cutscene_views[cur_scene].Start[2].yaw + ( (cutscene_views[cur_scene].Stop[2].yaw - cutscene_views[cur_scene].Start[2].yaw) * (fraction/360) )
	else
		cur_scene = math.random(1, #cutscene_views)
		cur_pos = cutscene_views[cur_scene].Start[1]
		cur_ang = cutscene_views[cur_scene].Start[2]
	end

	return GAMEMODE:CalcView(pl, cur_pos, cur_ang, fov)
end)
