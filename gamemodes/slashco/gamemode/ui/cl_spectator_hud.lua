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
local slashershow_tick = 0
hook.Add("SlashCo:DrawHUD", "Spectator_Vision", function()
	local plyTeam = GameData.LocalPlayer:Team()
	if plyTeam ~= TEAM_SPECTATOR then
		return
	end

	--Cool Spectator Lobby Menu
	if GameData.IsLobby and team.NumPlayers(TEAM_SURVIVOR) == 0 then
		local srvwin_count = GameData.LocalPlayer:GetSurvivorRoundsWon(0)
		local slswin_count = GameData.LocalPlayer:GetSlasherRoundsWon(0)

		SlashCo.Blur()

		spin = spin + (0.5 / (spin + 0.5)) / (spin + 1)

		if spin > math.pi * 4 + 1 then
			spin = 1
		end

		local blip = "☞ [" .. SlashCo.GetKeyButtonName("TOGGLE_SPECTATOR") .. "] ☜"
		if GameData.IsNewPlayer then
			blip = SlashCo.Language("newplayer_spawnnotice", SlashCo.GetKeyButtonName("TOGGLE_SPECTATOR")) --"Press [R] to Spawn"
		else
			if team.NumPlayers(TEAM_LOBBY) > (GameData.MaxPlayers - 1) then
				blip = "☓ [" .. SlashCo.GetKeyButtonName("TOGGLE_SPECTATOR") .. "] ☓"
			else
				flash = flash + RealFrameTime()
				if flash > 1 then flash = 0 end

				if flash > 0.5 then
					blip = "☛[" .. SlashCo.GetKeyButtonName("TOGGLE_SPECTATOR") .. "]☚"
				end
			end
		end

		spinSkull(spin)

		draw.SimpleText(SlashCo.Language("Welcome", string.upper(GameData.LocalPlayer:Nick())), "TVCD", ScrW() / 2, ScrH() / 3.5,
				color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText("SLASHCO", "LobbyFont2", ScrW() / 2, ScrH() / 4,
				color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(blip, "TVCD", ScrW() / 2, ScrH() / 2,
				color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText("[" .. team.NumPlayers(TEAM_LOBBY) .. " / " .. GameData.MaxPlayers .. "]", "TVCD", ScrW() / 2, ScrH() / 2.5,
				color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText("[" .. srvwin_count .. " " .. SlashCo.Language("SurvivorWins") .. "]  [" .. slswin_count .. " " .. SlashCo.Language("SlasherWins") .. "]",
				"TVCD", ScrW() * 0.5, ScrH() * 0.75, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local pickedSlasher = GameData.LocalPlayer:GetPickedSlasher()
	if pickedSlasher and pickedSlasher ~= "" then
		if slashershow_tick < 255 then
			slashershow_tick = slashershow_tick + (FrameTime() * 10)
		else
			slashershow_tick = 255
		end

		draw.SimpleText(SlashCo.Language("slasher_lobbyselection", pickedSlasher), "LobbyFont2", ScrW() * 0.5, ScrH() * 0.6, Color(255, 0, 0, slashershow_tick), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	if GameData.IsLobby then return end

	local show_slasher_anticipation = false

	if SlasherTeam then
		local localSlasher = GameData.LocalPlayer:GetNWString("Slasher")
		for _, slasherData in ipairs(SlasherTeam) do
			if slasherData.steamid == GameData.LocalSteamID64 then
				if localSlasher and localSlasher ~= show_slasher_anticipation then
					local shower = "UNASSIGNED!"
					if SlashCoSlashers[localSlasher] then
						shower = SlashCo.Language(localSlasher)
					end

					show_slasher_anticipation = shower
				end
			end
		end
	end

	if show_slasher_anticipation ~= false then
		draw.SimpleText(SlashCo.Language("slasher_anticipation", show_slasher_anticipation), "LobbyFont2", ScrW() * 0.5, (ScrH() * 0.4), Color(255, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		--return
	end

	if input.IsKeyDown(KEY_Q) then
		return
	end

	if not show_slasher_anticipation then
		if SlashCo.CanSpectatorsPing() then
			draw.SimpleText(SlashCo.Language("surv_ping", SlashCo.GetKeyButtonName("PING")), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 230, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		end
		
		draw.SimpleText("[" .. SlashCo.Language("spectating") .. "]", "TVCD", ScrW() * 0.5, ScrH() * 0.05, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	draw.SimpleText(SlashCo.Language("hide_info", "Q"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 290, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("toggle_halo", string.upper(input.LookupBinding("+walk") or "ALT")), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 200, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("toggle_halo_gas", string.upper(input.LookupBinding("+use") or "E")), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 170, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("player_follow", "LMB"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 140, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("player_cycle", "RMB"), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 110, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("switch_view", SlashCo.GetKeyButtonName("SPECTATE_PLAYER")), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 80, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(SlashCo.Language("toggle_light", string.upper(input.LookupBinding("+reload") or "R")), "TVCD", ScrW() * 0.975, (ScrH() * 0.95) - 50, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
end)

if CLIENT then
	hook.Add("PlayerButtonDown", "TestConfig_ID", function(ply, button)
		if ply ~= GameData.LocalPlayer then
			return
		end
		if not IsFirstTimePredicted() then
			return
		end
		if button ~= KEY_COUNT or not SlashCoTestConfig then
			return
		end
		
		local eyeTrace = ply:GetEyeTrace()
		if IsValid(eyeTrace.Entity) then
			ply:ChatPrint("ENTITY SPAWNPOINT ID: " .. eyeTrace.Entity:GetNWInt("SpawnPoint_ID"))
		end
	end)
end

hook.Add("KeyPress", "SlashCo:ToggleLight", function(ply, key)
	if not IsFirstTimePredicted() then return end
	if ply ~= GameData.LocalPlayer or GameData.LocalPlayer:Team() ~= TEAM_SPECTATOR or SERVER then return end
	if GameData.IsLobby then return end

	if key == IN_RELOAD then
		GameData.vision = not GameData.vision
		local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
		Sndd:Play()
		Sndd:ChangeVolume(0.5, 0)
		Sndd:ChangePitch(100, 0)
	end

	if key == IN_WALK then
		GameData.showHalos = not GameData.showHalos
		local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
		Sndd:Play()
		Sndd:ChangeVolume(0.5, 0)
		Sndd:ChangePitch(100, 0)
	end

	if key == IN_USE then
		GameData.showGasCanHalos = not GameData.showGasCanHalos
		local Sndd = CreateSound(ply, Sound("slashco/blip.mp3"))
		Sndd:Play()
		Sndd:ChangeVolume(0.5, 0)
		Sndd:ChangePitch(100, 0)
	end
end)

hook.Add("Think", "SlashCo:SpectatorVisionLight", function()
	if GameData.vision == nil then
		GameData.vision = false
	end

	if GameData.LocalPlayer:Team() ~= TEAM_SPECTATOR then return end
	if not GameData.vision then return end

	--Eyesight - an arbitrary range from 1 - 10 which decides how illuminated the Slasher 'vision is client-side. (1 - barely any illumination, 10 - basically fullbright )

	local dlight = DynamicLight(GameData.LocalPlayer:EntIndex())
	if dlight then
		dlight.pos = GameData.LocalPlayer:GetShootPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 2
		dlight.Decay = 1000
		dlight.Size = 1000
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
local cur_pos = Vector(0, 0, 0)
local cur_ang = Angle(0, 0, 0)

hook.Add("CalcView", "LobbySpecCam", function(pl, pos, ang, fov)
	if not GameData.IsLobby then
		return
	end

	if pl:Team() ~= TEAM_SPECTATOR then
		return
	end

	if SlashCo.IsLobbyStarting() then
		local helicopter = SlashCo.Helicopter
		if not helicopter:IsValid() then return end

		local helicopterPos = helicopter:GetPos()
		local helicopterAng = helicopter:GetAngles()

		local posOffset = Vector(-150, -80, 100)
		local rotatedOffset = helicopterAng:Forward() * posOffset.x + helicopterAng:Right() * posOffset.y + helicopterAng:Up() * posOffset.z

		cur_pos = helicopterPos + rotatedOffset
		cur_ang = helicopterAng + Angle(20, -10, 0)
		return GAMEMODE:CalcView(pl, cur_pos, cur_ang, fov)
	end

	if GameData.LocalIsSlasher then
		return
	end

	if not cur_scene then
		cur_scene = math.random(1, #cutscene_views)
		cur_pos = cutscene_views[cur_scene].Start[1]
		cur_ang = cutscene_views[cur_scene].Start[2]

		net.Start("SlashCo:SpectatorSceneToPVS")
			net.WriteVector(cur_pos)
		net.SendToServer()
	end

	local cur_dist = cur_pos:Distance( cutscene_views[cur_scene].Stop[1] )

	if cur_dist > 1 then
		local add = (cutscene_views[cur_scene].Stop[1] - cur_pos):GetNormalized() * RealFrameTime() * 30
		cur_pos = cur_pos + add * cutscene_views[cur_scene].Speed

		local total_dist = cutscene_views[cur_scene].Start[1]:Distance( cutscene_views[cur_scene].Stop[1] )
		local fraction = 1-(cur_dist / total_dist)
		cur_ang.pitch = cutscene_views[cur_scene].Start[2].pitch + ( (cutscene_views[cur_scene].Stop[2].pitch - cutscene_views[cur_scene].Start[2].pitch) * (fraction/360) )
		cur_ang.yaw = cutscene_views[cur_scene].Start[2].yaw + ( (cutscene_views[cur_scene].Stop[2].yaw - cutscene_views[cur_scene].Start[2].yaw) * (fraction/360) )
	else
		cur_scene = math.random(1, #cutscene_views)
		cur_pos = cutscene_views[cur_scene].Start[1]
		cur_ang = cutscene_views[cur_scene].Start[2]

		net.Start("SlashCo:SpectatorSceneToPVS")
			net.WriteVector(cur_pos)
		net.SendToServer()
	end

	return GAMEMODE:CalcView(pl, cur_pos, cur_ang, fov)
end)
