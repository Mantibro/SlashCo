local PANEL = {}

local red = Color(255, 0, 0)

function PANEL:Init()
	self.Max = 100
	self.Current = 0
	self.LabelText = "Meter"
	self.ValueLabelText = "%"
	self.ShowMax = false
	self.Prefix = false

	self.nDCurrent = 0
	self.FlashAmt = 0

	self:MakeMeter()
	self:MakeLabels()
	self:UpdateValueLabel()

	self.Anim = Derma_Anim("Flash", self, function(pnl, _, delta)
		pnl.FlashAmt = (1 - delta ^ 2) * 128
	end)
end

---convenience function to set all the meter values at once
function PANEL:Setup(name, max, component, componentIsPrefix, showMax)
	if name then
		self:SetName(name)
	end
	if max then
		self:SetMax(max)
	end
	if component then
		self:SetComponent(component, componentIsPrefix)
	end
	if showMax then
		self:SetShowMax(showMax)
	end
end

---set the label for the meter
function PANEL:SetName(value)
	self.LabelText = value
	self.Label:SetText(" " .. SlashCoLanguage(self.LabelText))
end

---set the value of the meter
function PANEL:SetValue(value)
	self.Current = math.Clamp(value, 0, self.Max)
	self:UpdateValueLabel()
end

---set the max value the meter can reach
function PANEL:SetMax(value)
	self.Max = value
	self.Current = math.Clamp(value, 0, self.Current)
	self:UpdateValueLabel()
end

---set the "component" of the value display (ie. the % sign or maybe a $ sign)
---if isPrefix is true, the component goes before the number
function PANEL:SetComponent(component, isPrefix)
	self.ValueLabelText = component
	self.Prefix = isPrefix
end

---set whether the number display shows the max value
function PANEL:SetShowMax(showMax)
	self.ShowMax = showMax
	self:UpdateValueLabel()
end

---ties the value of the meter to a netvar
function PANEL:TieInt(netvar, doFlash, fallback)
	fallback = fallback or 0
	self:SetValue(LocalPlayer():GetNWInt(netvar, fallback))

	function self.TieCheck()
		local val = math.Clamp(LocalPlayer():GetNWInt(netvar, fallback), 0, self.Max)
		if val ~= self.Current then
			self:SetValue(LocalPlayer():GetNWInt(netvar, fallback))

			if doFlash then
				self:Flash()
			end
		end
	end
end

---removes any ties
function PANEL:Untie()
	self.TieCheck = nil
end

---plays a flash animation
function PANEL:Flash()
	if self.CustomColors then
		return
	end

	self.Anim:Start(1)
end

---set custom colors (disables flashing)
function PANEL:SetColors(empty, full)
	self.CustomColors = true
	self.EmptyColor = empty or Color(128, 0, 0)
	self.FullColor = full or red
end

---internal: runs the flash animation
function PANEL:Think()
	if self.Anim:Active() then
		self.Anim:Run()
	end

	if self.TieCheck then
		self.TieCheck()
	end
end

---internal: makes the meter (crazy)
function PANEL:MakeMeter()
	local meter = self:Add("Panel")
	meter:Dock(BOTTOM)
	meter:SetTall(40)

	function meter.Paint(_, w, h)
		surface.SetDrawColor(255, 0, 0)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(3, 3, w - 6, h - 6)

		self.nDCurrent = math.Clamp(Lerp(0.08, self.nDCurrent, self.Current / self.Max), 0, self.Max)

		if self.nDCurrent > 0.998 then
			if self.CustomColors then
				surface.SetDrawColor(self.FullColor.r, self.FullColor.g, self.FullColor.b)
			else
				surface.SetDrawColor(255, 0, 0)
			end
		else
			if self.CustomColors then
				surface.SetDrawColor(self.EmptyColor.r, self.EmptyColor.g, self.EmptyColor.b)
			else
				surface.SetDrawColor(128 + self.FlashAmt, 0, 0)
			end
		end

		surface.DrawRect(5, 5, (w - 10) * self.nDCurrent, h - 10)
	end
end

---internal: sets the right-side label to the correct value
function PANEL:UpdateValueLabel()
	if self.ShowMax then
		if self.Prefix then
			self.ValueLabel:SetText(string.format("%s%s/%s",
					self.ValueLabelText,
					self.Current,
					self.Max))

			return
		end

		self.ValueLabel:SetText(string.format("%s/%s%s",
				self.Current,
				self.Max,
				self.ValueLabelText))

		return
	end

	if self.Prefix then
		self.ValueLabel:SetText(self.ValueLabelText .. self.Current)
		return
	end

	self.ValueLabel:SetText(self.Current .. self.ValueLabelText)
end

---internal: makes the two labels
function PANEL:MakeLabels()
	local valueLabel = self:Add("DLabel")
	self.ValueLabel = valueLabel
	valueLabel:Dock(RIGHT)
	valueLabel:SetWide(160)
	valueLabel:SetFont("TVCD")
	valueLabel:SetTextColor(red)
	valueLabel:SetContentAlignment(3)
	valueLabel:DockMargin(0, 0, 4, 4)

	local label = self:Add("DLabel")
	self.Label = label
	label:Dock(FILL)
	label:SetFont("HalfCutTitle")
	label:SetTextColor(red)
	label:SetContentAlignment(1)
	label:DockMargin(4, 0, 0, -8)
	label:SetText(" " .. SlashCoLanguage(self.LabelText))
end

vgui.Register("slashco_slasher_meter", PANEL, "Panel")