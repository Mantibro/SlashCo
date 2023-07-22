local PANEL = {}

local red = Color(255, 0, 0)
local darkRed = Color(128, 0, 0)

function PANEL:Init()
	self.Enabled = true
	self.Icon = Material("slashco/ui/icons/slasher/s_7_s1")
	self.dX = 0
	self.dY = 0

	local icon = vgui.Create("Panel", self)
	self.IconPanel = icon
	icon.Rotate = math.random(-7, 7)
	icon:SetWide(100)
	icon:Dock(RIGHT)
	function icon.Paint(_, w, h)
		surface.SetMaterial(self.Icon)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectRotated(w / 2 + self.dX, h / 2 + self.dY, 80, 80, icon.Rotate)
	end

	local label = vgui.Create("DLabel", self)
	self.Label = label
	label:Dock(TOP)
	label:SetTall(60)
	label:SetContentAlignment(6)
	label:SetFont("HalfCutTitle")
	label:SetText("chase")
	label:SetTextColor(red)

	local keyLabel = vgui.Create("DLabel", self)
	self.KeyLabel = keyLabel
	keyLabel:Dock(TOP)
	keyLabel:SetContentAlignment(3)
	keyLabel:SetFont("TVCD")
	keyLabel:SetText("[LMB]")
	keyLabel:SetTextColor(red)

	self.Anim = Derma_Anim("Shake", self, function(pnl, _, delta)
		pnl.dX = (math.random() - 0.5) * (1 - delta) * 8
		pnl.dY = (math.random() - 0.5) * (1 - delta) * 8
	end)
end

---convenience function to set all of the control's properties in one function
---icon can be either the icon table or just one icon
function PANEL:Setup(key, text, icon)
	if type(icon) == "table" then
		self:SetIconTable(icon)

		self.Icon = select(2, next(self.IconTable))
	elseif type(icon) == "IMaterial" then
		self.Icon = icon
	end

	self:SetKey(key)
	self:SetText(text)
end

---sets whether the control displays as enabled or disabled
---if enabled, the control will set its icon to "<text>" as long asdontSetIcon is nil/false
---if disabled, the control will set its icon to "d/<text>" as long as dontSetIcon is nil/false
function PANEL:SetEnabled(state, dontSetIcon)
	if state then
		self.Enabled = true
		self.Label:SetTextColor(red)
		self.KeyLabel:SetTextColor(red)

		if not dontSetIcon then
			self:SetIcon(self.Text)
		end
	else
		self.Enabled = nil
		self.Label:SetTextColor(darkRed)
		self.KeyLabel:SetTextColor(darkRed)

		if not dontSetIcon then
			self:SetIcon("d/"..self.Text)
		end
	end
end

---sets a new icon table
---updates the icon if allowed
function PANEL:SetIconTable(icons, dontSetIcon)
	self.IconTable = icons

	if not dontSetIcon then
		if self.Enabled then
			self:SetIcon(self.Text)
		else
			self:SetIcon("//"..self.Text)
		end
	end
end

---sets the icon to a new material or an element of the icon table
function PANEL:SetIcon(icon)
	if type(icon) == "IMaterial" then
		self.Icon = icon
	elseif self.IconTable and self.IconTable[icon] then
		self.Icon = self.IconTable[icon]
	end
end

---sets a new key to display
function PANEL:SetKey(key)
	self.Key = key
	self.KeyLabel:SetText(string.format("[%s]", string.upper(key)))
end

---sets the text for the control and updates the icon
function PANEL:SetText(text, dontSetIcon)
	self.Text = text
	self.Label:SetText(text)

	if not dontSetIcon then
		self:SetIcon(text)
	end
end

---plays a shake animation
function PANEL:Shake()
	self.Anim:Start(1)
end

---internal: runs the shake animation
function PANEL:Think()
	if self.Anim:Active() then
		self.Anim:Run()
	end
end

vgui.Register("slashco_slasher_control", PANEL, "Panel")