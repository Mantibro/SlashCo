local PANEL = {}

local red = Color(255, 0, 0)

function PANEL:Init()
	self.Max = 100
	self.Current = 100
	self.LabelText = "Meter"
	self.ValueLabelText = "%"
	self.ShowMax = false
	self.Prefix = false

	self:MakeMeter()
	self:MakeLabels()
	self:UpdateValueLabel()
end

---internal: makes the meter (crazy)
function PANEL:MakeMeter()
	local meter = self:Add("DPanel")
	meter:Dock(BOTTOM)
	meter:SetTall(40)
end

---internal: sets the right-side label to the correct value
function PANEL:UpdateValueLabel()
	if self.ShowMax then
		if self.Prefix then
			self.ValueLabel:SetText(string.format("%s%s/%s%s",
					self.ValueLabelText,
					self.Current,
					self.ValueLabelText,
					self.Max))

			return
		end

		self.ValueLabel:SetText(string.format("%s%s/%s%s",
				self.Current,
				self.ValueLabelText,
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
	label:SetText(self.LabelText)
end

vgui.Register("slashco_slasher_meter", PANEL, "Panel")