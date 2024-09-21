
surface.CreateFont("ScoreboardDefault", {
	font	= "CA Alternative Three",
	size	= 22,
	weight	= 800
})

surface.CreateFont("ScoreboardDefaultTitle", {
	font	= "CA Alternative Three",
	size	= 15,
	weight	= 800
})


net.Receive("mantislashcoSendRoundData", function()
	PlayerData = net.ReadTable()
end)

--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = {
	Init = function(self)
		self.Mute = self:Add("DImageButton")
		self.Mute:SetSize(32, 32)
		self.Mute:Dock(LEFT)

		self.Shift = self:Add("Panel")
		self.Shift:SetSize(32, 32)
		self.Shift:Dock(LEFT)
		self.Shift:Hide()

		self.AvatarButton = self:Add("DButton")
		self.AvatarButton:Dock(LEFT)
		self.AvatarButton:SetSize(32, 32)
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar = vgui.Create("AvatarImage", self.AvatarButton)
		self.Avatar:SetSize(32, 32)
		self.Avatar:SetMouseInputEnabled(false)

		self.Name = self:Add("DLabel")
		self.Name:Dock(FILL)
		self.Name:SetFont("ScoreboardDefault")
		self.Name:SetTextColor(color_black)
		self.Name:DockMargin(8, 0, 0, 0)

		self:Dock(TOP)
		self:DockPadding(3, 3, 3, 3)
		self:SetHeight(32 + 3 * 2)
		self:DockMargin(2, 0, 2, 2)
	end,
	Setup = function(self, pl)
		if pl == LocalPlayer() then
			self.Mute:Hide()
			self.Shift:Show()
		end

		self.Player = pl

		self.team_status = TEAM_SPECTATOR
		self.teamcolor = color_white
		self.teamorder = 1500

		self.IsDead = self.Player:GetNWBool("ConfirmedDead")

		self.Avatar:SetPlayer(pl)

		if PlayerData == nil then
			self:Think(self)
			return
		end

		if self.IsDead then
			self.team_status = TEAM_SURVIVOR
			self.teamcolor = Color(64, 64, 192, 255)
			self.teamorder = 1000

			self:Think(self)
			return
		end

		for _, v in ipairs(PlayerData.survivors) do
			local check = v.id or v.steamid

			if check == pl:SteamID64() then
				self.team_status = TEAM_SURVIVOR
				self.teamcolor = Color(128, 128, 255, 255)
				self.teamorder = 0

				if LocalPlayer():Team() == TEAM_SPECTATOR and pl:Team() == TEAM_SPECTATOR then
					self.teamcolor = Color(64, 64, 192, 255)
					self.teamorder = 500
				end

				self:Think(self)
				return
			end
		end

		for _, v in ipairs(PlayerData.slashers) do
			local check = v.s_id or v.steamid

			if check == pl:SteamID64() then
				self.team_status = TEAM_SLASHER
				self.teamcolor = Color(255, 64, 64, 255)
				self.teamorder = -500

				self:Think(self)
				return
			end
		end
	end,
	Think = function(self)
		if not IsValid(self.Player) or self.Player:GetNWBool("ConfirmedDead") ~= self.IsDead then
			self:SetZPos(9999) -- Causes a rebuild
			self:Remove()
			return
		end

		if self.PName == nil or self.PName ~= self.Player:Nick() then
			self.PName = self.Player:Nick()
			self.Name:SetText(self.PName)
		end

		--
		-- Change the icon of the mute button based on state
		--

		if self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
			self.Muted = self.Player:IsMuted()
			if self.Muted then
				self.Mute:SetImage("icon32/muted.png")
			else
				self.Mute:SetImage("icon32/unmuted.png")
			end

			self.Mute.DoClick = function()
				self.Player:SetMuted(not self.Muted)
			end
			self.Mute.OnMouseWheeled = function(s, delta)
				self.Player:SetVoiceVolumeScale(self.Player:GetVoiceVolumeScale() + (delta / 100 * 5))
				s.LastTick = CurTime()
			end

			self.Mute.PaintOver = function(s, w, h)
				if not IsValid(self.Player) then return end

				local a = 255 - math.Clamp(CurTime() - (s.LastTick or 0), 0, 3) * 255
				if a <= 0 then return end

				draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, a * 0.75))
				draw.SimpleText(math.ceil(self.Player:GetVoiceVolumeScale() * 100) .. "%", "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		--
		-- Connecting players go at the very bottom
		--
		if self.Player:Team() == TEAM_CONNECTING then
			self:SetZPos(2000 + self.Player:EntIndex())
			return
		end

		--
		-- This is what sorts the list. The panels are docked in the z order,
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		self:SetZPos(self.Player:EntIndex() + self.teamorder - 50)
	end,
	Paint = function(self, w, h)
		if (not IsValid(self.Player)) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		--if (self.Player:Team() == TEAM_CONNECTING) then
		--	draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200, 200))
		--	return
		--end

		draw.RoundedBox(4, 0, 0, w, h,self.teamcolor)
	end
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable(PLAYER_LINE, "DPanel")

--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = {
	Init = function(self)
		self.Header = self:Add("Panel")
		self.Header:Dock(TOP)
		self.Header:SetHeight(300)

		self.Name = self.Header:Add("DLabel")
		self.Name:SetFont("ScoreboardDefaultTitle")
		self.Name:SetTextColor(color_white)
		self.Name:SetPos(65, 115)
		self.Name:SetSize(600, 200)
		self.Name:SetExpensiveShadow(2, Color(0, 0, 0, 200))

		self.StateName = self.Header:Add("DLabel")
		self.StateName:SetFont("ScoreboardDefaultTitle")
		self.StateName:SetTextColor(color_white)
		self.StateName:SetPos(65, 180)
		self.StateName:SetSize(600, 200)
		self.StateName:SetExpensiveShadow(2, Color(0, 0, 0, 200))

		self.Scores = self:Add("DScrollPanel")
		self.Scores:Dock(FILL)

		local game_state = SlashCo.Language("InLobby")

		if game.GetMap() ~= "sc_lobby" then
			local offer = "Regular"
			if PlayerData.offering ~= "" then offer = PlayerData.offering end
			game_state = SlashCo.Language("InGame", offer)
		end

		self.StateName:SetText(game_state)

		local mat = vgui.Create("Material", self)
		mat:SetPos(0, 120)
		mat:SetSize(20, 20)
		mat:SetMaterial("slashco/ui/slashco_score")
	end,
	PerformLayout = function(self)
		self:SetSize(500, ScrH() - 200)
		self:SetPos(ScrW() / 2 - 250, 100)
	end,
	Reset = function()
		local plyrs = player.GetAll()
		for _, pl in ipairs(plyrs) do
			if not IsValid(pl.ScoreEntry) then continue end
			pl.ScoreEntry:Setup(pl)
		end
	end,
	Think = function(self)
		self.Name:SetText(GetHostName())

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for _, pl in ipairs(plyrs) do
			if IsValid(pl.ScoreEntry) then continue end

			pl.ScoreEntry = vgui.CreateFromTable(PLAYER_LINE, pl.ScoreEntry)
			pl.ScoreEntry:Setup(pl)

			self.Scores:AddItem(pl.ScoreEntry)
		end
	end
}

SCORE_BOARD = vgui.RegisterTable(SCORE_BOARD, "EditablePanel")

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardShow()
	Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()
	if not IsValid(g_Scoreboard) and PlayerData ~= nil then
		g_Scoreboard = vgui.CreateFromTable(SCORE_BOARD)
	end

	if IsValid(g_Scoreboard) then
		g_Scoreboard:Reset()
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled(false)
	end
end

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardHide()
	Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()
	if IsValid(g_Scoreboard) then
		g_Scoreboard:Hide()
	end
end

--[[---------------------------------------------------------
	Name: gamemode:HUDDrawScoreBoard()
	Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()
	--draw.SimpleText("nutd!!!!.", "LobbyFont1", ScrW() * 0.5, (ScrH() * 0.5), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end
