local PANEL = {}

local survivorIcon = Material("slashco/ui/icons/slasher/s_survivor")
local survivorDeadIcon = Material("slashco/ui/icons/slasher/s_survivor_dead")

function PANEL:Init()
	self:SetMouseInputEnabled(false)

	self:Dock(FILL)
	self.Controls = {}
	self.Meters = {}

	local right = vgui.Create("Panel", self)
	self.Right = right
	right:SetWide(420)
	right:Dock(RIGHT)

	self:MakeTitleCard()
	self:MakeSurvivorsCard()

	local left = vgui.Create("Panel", self)
	self.Left = left
	left:SetWide(420)
	left:Dock(LEFT)
end

function PANEL:PerformLayout()
end

local red = Color(255, 0, 0)

function PANEL:MakeTitleCard()
	local card = vgui.Create("Panel", self)
	self.TitleCard = card
	card:Dock(BOTTOM)
	card:SetTall(120)

	local icon = vgui.Create("Panel", card)
	card.Icon = icon
	icon.Mat = Material("slashco/ui/icons/slasher/s_7_s1")
	icon:SetWide(card:GetTall())
	icon:Dock(LEFT)
	function icon.Paint(_, w, h)
		surface.SetMaterial(icon.Mat)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectRotated(w / 2, h / 2, 96, 96, 7)
	end

	local label = vgui.Create("DLabel", card)
	card.Label = label
	label:Dock(FILL)
	label:SetContentAlignment(1)
	label:SetFont("HalfCutTitle")
	label:SetText("tyler")
	label:SetTextColor(red)
end

function PANEL:MakeSurvivorsCard()
	if not SurvivorTeam then
		return
	end

	local card = vgui.Create("Panel", self)
	self.SurvivorsCard = card
	card:Dock(BOTTOM)
	card:SetTall(80)

	for k, v in ipairs(SurvivorTeam) do
		local survivor = card:Add("Panel")
		survivor.Rotate = math.random(-7, 7)
		survivor.Entity = player.GetBySteamID64(v)
		survivor:Dock(LEFT)
		survivor:SetWide(80)
		function survivor.Paint(_, w, h)
			surface.SetDrawColor(255, 255, 255, 255)

			if survivor.NotAlive then
				surface.SetMaterial(survivorDeadIcon)
				surface.DrawTexturedRectRotated(w / 2 + survivor.dX, h / 2 + survivor.dY, 64, 64, survivor.Rotate)
			else
				surface.SetMaterial(survivorIcon)
				surface.DrawTexturedRectRotated(w / 2, h / 2, 48, 48, survivor.Rotate)
			end
		end

		local anim = Derma_Anim("DieShake", survivor, function(pnl, _, delta)
			pnl.dX = (math.random() - 0.5) * (1 - delta) * 4
			pnl.dY = (math.random() - 0.5) * (1 - delta) * 4
		end)
		function survivor.Think()
			if survivor.Entity:Team() ~= TEAM_SURVIVOR then
				if not survivor.NotAlive then
					anim:Start(1)
					survivor.Model:Hide()
				end
				survivor.NotAlive = true
			else
				if survivor.NotAlive then
					survivor.Model:Show()
				end
				survivor.NotAlive = nil
			end

			if anim:Active() then
				anim:Run()
			end
		end

		local model = survivor:Add("slashco_projector")
		survivor.Model = model
		model:Dock(FILL)
		model:SetEntity(survivor.Entity)
		model:SetFOV(18)
		model:SetRotation(survivor.Rotate)
	end
end

function PANEL:SetTitle(name)
	self.TitleCard.Label:SetText(name)
end

function PANEL:SetAvatarTable(avatars)
	self.AvatarTable = avatars
end

function PANEL:SetAvatar(avatar)
	if type(avatar) == "IMaterial" then
		self.TitleCard.Icon.Mat = avatar
	else
		self.TitleCard.Icon.Mat = self.AvatarTable[avatar]
	end
end

function PANEL:AddControl(key, text)
	local control = vgui.Create("slashco_slasher_control", self.Right)
	self.Controls[key] = control
	control:SetTall(100)
	control:Dock(BOTTOM)
end

vgui.Register("slashco_slasher_stockhud", PANEL, "Panel")

if IsValid(g_SlasherHud) then
	g_SlasherHud:Remove()
end

-- [[
g_SlasherHud = vgui.Create("slashco_slasher_stockhud")

g_SlasherHud:SetTitle("AMONG US")
g_SlasherHud:SetAvatar(Material("slashco/ui/icons/slasher/s_4"))
g_SlasherHud:AddControl("K", "le chase")
--]]