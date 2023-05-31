local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self.Controls = {}
    self.Meters = {}

    local controlsHolder = vgui.Create("DPanel", self)
    self.ControlsHolder = controlsHolder
    controlsHolder:Dock(RIGHT)
end

function PANEL:PerformLayout()
    self.ControlsHolder:SetWidth(self:GetWide()/4)
end

function PANEL:MakeTitle()

end

function PANEL:AddControl(key, text, func)
    local control = vgui.Create("DPanel", self.ControlsHolder)
    self.Meters[key] = control
    DPanel:Dock(BOTTOM)
end

vgui.Register("slashco_slasher_stockhud", PANEL, "Panel")

local frame = vgui.Create("DFrame")
frame:Dock(FILL)
frame.Paint = nil
frame:MakePopup()
local slashie = vgui.Create("slashco_slasher_stockhud", frame)