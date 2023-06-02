local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self.Controls = {}
    self.Meters = {}

    local right = vgui.Create("DPanel", self)
    self.Right = right
    right:SetWide(420)
    right:Dock(RIGHT)

    self:MakeTitleCard()

    local left = vgui.Create("DPanel", self)
    self.Left = left
    left:SetWide(420)
    left:Dock(LEFT)
end

function PANEL:PerformLayout()
end

local red = Color(255, 0, 0)

function PANEL:MakeTitleCard()
    local titleCard = vgui.Create("Panel", self)
    self.TitleCard = titleCard
    titleCard:Dock(BOTTOM)
    titleCard:SetTall(120)

    local icon = vgui.Create("Panel", titleCard)
    titleCard.Icon = icon
    icon.Mat = Material("slashco/ui/icons/slasher/s_7_s1")
    icon:SetWide(titleCard:GetTall())
    icon:Dock(LEFT)
    function icon.Paint(_, w, h)
        surface.SetMaterial(icon.Mat)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectRotated(w / 2, h / 2, 96, 96, 7)
    end

    local label = vgui.Create("DLabel", titleCard)
    titleCard.Label = label
    label:Dock(FILL)
    label:SetContentAlignment(1)
    label:SetFont("HalfCutTitle")
    label:SetText("tyler")
    label:SetTextColor(red)
end

function PANEL:SetTitle(name)
    self.TitleCard.Label:SetText(name)
end

function PANEL:SetAvatarTable(avatars)
    self.AvatarTable = avatars
end

function PANEL:SetAvatar(avatar)
    if type(avatar) == "material" then
        self.TitleCard.Icon = avatar
    else
        self.TitleCard.Icon = self.AvatarTable[avatar]
    end
end

function PANEL:AddControl(key, text, func)
    local control = vgui.Create("DPanel", self.ControlsHolder)
    self.Meters[key] = control
    DPanel:Dock(BOTTOM)
end

vgui.Register("slashco_slasher_stockhud", PANEL, "Panel")

--[[
local frame = vgui.Create("DFrame")
frame:Dock(FILL)
frame.Paint = nil
frame:MakePopup()
local slashie = vgui.Create("slashco_slasher_stockhud", frame)
--]]