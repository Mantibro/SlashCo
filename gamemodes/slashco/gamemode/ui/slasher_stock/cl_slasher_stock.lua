local PANEL = {}

local red = Color(255, 0, 0)
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

---sets the slasher title
function PANEL:SetTitle(name)
	self.TitleCard.Label:SetText(name)
end

---sets up the slasher avatar table to simplify setting avatars
function PANEL:SetAvatarTable(avatars)
	self.AvatarTable = avatars
end

---sets the slasher avatar to a new material or index of the avatar table
function PANEL:SetAvatar(avatar)
	if type(avatar) == "IMaterial" then
		self.TitleCard.Icon.Mat = avatar
	else
		self.TitleCard.Icon.Mat = self.AvatarTable[avatar]
	end
end

---add a new control to the right side
function PANEL:AddControl(key, text, icon, zPos)
	local control = vgui.Create("slashco_slasher_control", self.Right)
	self.Controls[key] = control
	control:SetTall(100)
	control:Dock(BOTTOM)
	control:Setup(key, text, icon)
	control:SetZPos(zPos)
	self.Right:InvalidateChildren()
end

---remove a control
function PANEL:RemoveControl(key)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:Remove()
	self.Controls[key] = nil
	self.Right:InvalidateChildren()
end

---sets a control's text
---will automatically set the icon to one of the same index (in the icon table)
function PANEL:SetControlText(key, text, dontSetIcon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetText(text, dontSetIcon)
end

---set a control's "enabled" state (disabled controls are darker)
---if enabled, the control will set its icon to "<text>" as long asdontSetIcon is nil/false
---if disabled, the control will set its icon to "d/<text>" as long as dontSetIcon is nil/false
function PANEL:SetControlEnabled(key, state, dontSetIcon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetEnabled(state, dontSetIcon)
end

---show or hide a control entirely
function PANEL:SetControlVisible(key, value)
	if not self.Controls[key] then
		return
	end

	if value then
		self.Controls[key]:Show()
	else
		self.Controls[key]:Hide()
	end

	self.Right:InvalidateChildren()
end

---sets a new icon table for a control
---this is already done when a control is made
---updates the icon if allowed
function PANEL:SetControlIconTable(key, icons, dontSetIcon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetIconTable(icons, dontSetIcon)
end

---override a control's icon
---either material or an index of the icon table
function PANEL:SetControlIcon(key, icon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetIcon(icon)
end

---changes the key of a control; will swap keys with whatever control was already set there
function PANEL:SetControlKey(key, newKey)
	if not self.Controls[key] then
		return
	end

	if self.Controls[newKey] then
		self.Controls[newKey]:SetKey(key)
	end
	self.Controls[key]:SetKey(newKey)

	self.Controls[key], self.Controls[newKey] = self.Controls[newKey], self.Controls[key]
end

---internal: shows the slasher's name and avatar
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

---internal: makes the survivor indicators above the slasher name card
function PANEL:MakeSurvivorsCard()
	if not SurvivorTeam then
		return
	end

	local card = vgui.Create("Panel", self)
	self.SurvivorsCard = card
	card:Dock(BOTTOM)
	card:SetTall(80)

	for _, v in ipairs(SurvivorTeam) do
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
		model:SetFOV(20)
		model:SetRotation(survivor.Rotate)
		model:SetAmbientLight(Color(100, 0, 0))
	end
end

vgui.Register("slashco_slasher_stockhud", PANEL, "Panel")

if IsValid(g_SlasherHud) then
	g_SlasherHud:Remove()
end

-- [[
g_SlasherHud = vgui.Create("slashco_slasher_stockhud")

local iconTable = {
	["cungus"] = Material("slashco/ui/icons/slasher/s_7"),
	["d/cungus"] = Material("slashco/ui/icons/slasher/s_7_s1"),
	["bugnus"] = Material("slashco/ui/icons/slasher/s_17"),
	["le chase"] = Material("slashco/ui/icons/slasher/s_4"),
}

g_SlasherHud:SetTitle("AMONG US")
g_SlasherHud:SetAvatar(Material("slashco/ui/icons/slasher/s_4"))
g_SlasherHud:AddControl("K", "le chase", iconTable)
g_SlasherHud:AddControl("G", "cungus", iconTable)
g_SlasherHud:AddControl("H", "adw", iconTable)
g_SlasherHud:SetControlEnabled("G", false)
--]]