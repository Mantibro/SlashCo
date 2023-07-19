local PANEL = {}

local red = Color(255, 0, 0)
local darkRed = Color(192, 0, 0)

function PANEL:Init()
	local icon = vgui.Create("Panel", self)
	self.Icon = icon
	icon.Rotate = math.random(-7, 7)
	icon.Mat = Material("slashco/ui/icons/slasher/s_7_s1")
	icon:SetWide(100)
	icon:Dock(RIGHT)
	function icon.Paint(_, w, h)
		surface.SetMaterial(icon.Mat)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectRotated(w / 2, h / 2, 80, 80, icon.Rotate)
	end

	local label = vgui.Create("DLabel", self)
	self.Label = label
	label:Dock(TOP)
	label:SetTall(60)
	label:SetContentAlignment(6)
	label:SetFont("HalfCutTitle")
	label:SetText("chase")
	label:SetTextColor(red)

	local key = vgui.Create("DLabel", self)
	self.Key = key
	key:Dock(TOP)
	key:SetContentAlignment(3)
	key:SetFont("TVCD")
	key:SetText("[LMB]")
	key:SetTextColor(darkRed)
end

vgui.Register("slashco_slasher_control", PANEL, "Panel")