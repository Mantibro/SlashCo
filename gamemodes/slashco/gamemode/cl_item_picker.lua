local selectedItem, selectedMap
local itemSelectFrame, mapForce
local SlashCoItems = SlashCoItems
local MGSelection = false
local mapPrice = 50

local function BlockConfirm()
    itemSelectFrame.Confirm:SetText("XXXXXXX")
    function itemSelectFrame.Confirm.Paint(_, w, h)
        surface.SetDrawColor(128, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end
    itemSelectFrame.Confirm:SetEnabled(false)
end

local function SetConfirm()
    if MGSelection and (not selectedMap or selectedMap == mapForce) then
        BlockConfirm()
        return
    end

    if not MGSelection and LocalPlayer():GetNWString("item", "none") ~= "none" or LocalPlayer():GetNWString("item2", "none") ~= "none" then
        BlockConfirm()
        return
    end

    itemSelectFrame.Confirm:SetText("CONFIRM")
    function itemSelectFrame.Confirm.Paint(_, w, h)
        if itemSelectFrame.Confirm:IsHovered() then
            surface.SetDrawColor(0, 0, 128)
        else
            surface.SetDrawColor(64, 64, 64)
        end
        surface.DrawRect(0, 0, w, h)
    end
    function itemSelectFrame.Confirm.DoClick()
        if MGSelection then
            SlashCo.SendValue("pickMap", selectedMap)
        else
            SlashCo.SendValue("pickItem", selectedItem)
        end
        itemSelectFrame:Remove()
    end
    itemSelectFrame.Confirm:SetEnabled(true)
end

local function setItemLabel()
    itemSelectFrame.ItemModel:SetModel(SlashCoItems[selectedItem].Model)
    itemSelectFrame.ItemModel:SetCamPos(SlashCoItems[selectedItem].CamPos)
    itemSelectFrame.ItemDescription:SetText(SlashCoItems[selectedItem].Description)
    itemSelectFrame.ItemLabel:SetText(string.upper(SlashCoItems[selectedItem].Name))

    if (SlashCoItems[selectedItem].MaxAllowed) then
        local numRemain = SlashCoItems[selectedItem].MaxAllowed()
        local slot = SlashCoItems[selectedItem].IsSecondary and "item2" or "item"
        for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
            if v:GetNWString(slot, "none") == selectedItem then
                numRemain = numRemain - 1
            end
        end
        itemSelectFrame.ItemValues:SetText("[" .. SlashCoItems[selectedItem].Price .. " POINTS] [" .. numRemain .. " REMAINING]")
        if numRemain <= 0 then
            BlockConfirm()
        else
            SetConfirm()
        end
    else
        itemSelectFrame.ItemValues:SetText("[" .. SlashCoItems[selectedItem].Price .. " POINTS]")
        SetConfirm()
    end
end

--forward declaration so that SetupBase can call this function
local DrawItemSelectorBox

local function SetupBase()
    itemSelectFrame = vgui.Create("DFrame")

    local confirmSelect = vgui.Create("DButton", itemSelectFrame)
    itemSelectFrame.Confirm = confirmSelect
    confirmSelect:SetSize(160, 30)
    confirmSelect:SetFont("TVCD")
    confirmSelect:SetTextColor(color_white)

    local MapGuaranteeSelect = vgui.Create("DButton", itemSelectFrame)
    itemSelectFrame.MapGuaranteeSelect = MapGuaranteeSelect
    MapGuaranteeSelect:SetSize(300, 30)
    MapGuaranteeSelect:SetFont("TVCD")
    MapGuaranteeSelect:SetTextColor(color_white)
    function MapGuaranteeSelect.Paint(_, w, h)
        if MapGuaranteeSelect:IsHovered() then
            surface.SetDrawColor(0, 0, 128)
        else
            surface.SetDrawColor(64, 64, 64)
        end
        surface.DrawRect(0, 0, w, h)
    end
    function MapGuaranteeSelect.DoClick()
        MGSelection = not MGSelection
        DrawItemSelectorBox()
    end

    local leftSide = vgui.Create("DScrollPanel", itemSelectFrame)
    itemSelectFrame.Left = leftSide
    leftSide:Dock(LEFT)
    leftSide:GetCanvas():DockPadding(0, -5, 0, 0)
    leftSide:DockMargin(0, 0, 5, 0)
    leftSide.Items = {}

    local modelHolder = vgui.Create("Panel", itemSelectFrame)
    itemSelectFrame.ModelHolder = modelHolder
    modelHolder:Dock(TOP)
    modelHolder:SetHeight(200)
    function modelHolder.Paint(_, w, h)
        surface.SetDrawColor(0, 0, 128)
        surface.DrawRect(0, 0, w, h)
    end

    local itemModel = vgui.Create("DModelPanel", modelHolder)
    itemSelectFrame.ItemModel = itemModel
    itemModel:SetLookAt(vector_origin)
    itemModel:SetFOV(40)

    function modelHolder.PerformLayout()
        itemModel:SetSize(modelHolder:GetTall() * 2, modelHolder:GetTall())
        itemModel:Center()
    end

    local itemLabel = vgui.Create("DLabel", itemSelectFrame)
    itemSelectFrame.ItemLabel = itemLabel
    itemLabel:Dock(TOP)
    itemLabel:DockMargin(0, 5, 0, 0)
    itemLabel:SetContentAlignment(8)
    itemLabel:SetFont("TVCD")
    itemLabel:SetHeight(22)

    local values = vgui.Create("DLabel", itemSelectFrame)
    itemSelectFrame.ItemValues = values
    values:Dock(TOP)
    values:DockMargin(0, 0, 0, 5)
    values:SetContentAlignment(8)
    values:SetHeight(22)
    values:SetFont("TVCD")

    local itemDesc = vgui.Create("DLabel", itemSelectFrame)
    itemSelectFrame.ItemDescription = itemDesc
    itemDesc:Dock(FILL)
    itemDesc:SetFont("TVCD_small")
    itemDesc:SetWrap(true)
    itemDesc:SetContentAlignment(7)

    itemSelectFrame.btnMaxim:Hide()
    itemSelectFrame.btnMinim:Hide()
    itemSelectFrame.lblTitle:SetFont("TVCD")
    itemSelectFrame.lblTitle:SetTextColor(color_white)
    function itemSelectFrame.Paint(_, w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end
    function itemSelectFrame.btnClose.Paint()
        if itemSelectFrame.btnClose:IsHovered() then
            surface.SetTextColor(255, 0, 0)
        else
            surface.SetTextColor(255, 255, 255)
        end
        surface.SetFont("TVCD")
        surface.SetTextPos(0, 0)
        surface.DrawText("[X]")
    end

    function itemSelectFrame:PerformLayout()
        self.btnClose:SetSize(48, 24)
        self.btnClose:SetPos(self:GetWide() - 48 - 4, 1)

        self.lblTitle:SetPos(0, 2)
        self.lblTitle:SetSize(self:GetWide() - 25, 20)

        confirmSelect:SetPos(itemSelectFrame:GetWide() - 160 - 5, itemSelectFrame:GetTall() - 30 - 5)
        MapGuaranteeSelect:SetPos(itemSelectFrame:GetWide() - 550 - 5, itemSelectFrame:GetTall() - 30 - 5)
    end

    itemSelectFrame:SetSize(800, 500)
    itemSelectFrame:Center()
    itemSelectFrame:MakePopup()
    itemSelectFrame:SetSizable(true)
    itemSelectFrame:SetKeyboardInputEnabled(false)
end

local function SetupItems()
    itemSelectFrame:SetTitle("[PICK YOUR ITEM...]")
    selectedItem = selectedItem or "Baby"

    local leftSide = itemSelectFrame.Left
    local width = 0

    for _, v in pairs(leftSide:GetCanvas():GetChildren()) do
        v:Remove()
    end

    for k, v in SortedPairs(SlashCoItems) do
        if not v.Price then
            continue
        end
        local item = vgui.Create("DButton", leftSide)
        function item.DoClick()
            leftSide.Items[selectedItem]:SetEnabled(true)
            selectedItem = k
            setItemLabel()
            leftSide.Items[selectedItem]:SetEnabled(false)
        end
        item:Dock(TOP)
        item:SetHeight(30)
        item:DockMargin(0, 5, 0, 0)
        item:SetText(string.upper(v.Name))
        item:SetFont("TVCD_small")
        item:SetTextColor(color_white)
        local wi = item:GetTextSize()
        if wi > width then
            width = wi
        end

        if selectedItem == k then
            item:SetEnabled(false)
        end

        function item.Paint(_, w, h)
            if not item:IsEnabled() then
                surface.SetDrawColor(128, 0, 0)
            else
                if item:IsHovered() then
                    surface.SetDrawColor(0, 0, 128)
                else
                    surface.SetDrawColor(64, 64, 64)
                end
            end
            surface.DrawRect(0, 0, w, h)
        end
        leftSide.Items[k] = item
    end

    leftSide:SetWidth(math.min(width + 10, 250))
    leftSide:InvalidateChildren()

    itemSelectFrame.ModelHolder:Show()
    setItemLabel()
end

local function SetupMaps()
    itemSelectFrame:SetTitle("[GUARANTEE A MAP...]")
    local leftSide = itemSelectFrame.Left
    local width = 0

    for _, v in pairs(leftSide:GetCanvas():GetChildren()) do
        v:Remove()
    end

    for k, v in SortedPairs(SCInfo.Maps) do
        if k == "" or k == "error" then
            continue
        end

        local item = vgui.Create("DButton", leftSide)
        function item.DoClick()
            if selectedMap then
                leftSide.Items[selectedMap]:SetEnabled(true)
            end
            itemSelectFrame.ItemLabel:SetText(string.upper(v.NAME))
            selectedMap = k
            SetConfirm()
            leftSide.Items[selectedMap]:SetEnabled(false)
        end
        item:Dock(TOP)
        item:SetHeight(30)
        item:DockMargin(0, 5, 0, 0)
        item:SetText(string.upper(v.NAME))
        item:SetFont("TVCD_small")
        item:SetTextColor(color_white)
        local wi = item:GetTextSize()
        if wi > width then
            width = wi
        end

        if selectedMap == k then
            item:SetEnabled(false)
        end

        function item.Paint(_, w, h)
            if not item:IsEnabled() then
                surface.SetDrawColor(128, 0, 0)
            else
                if item:IsHovered() then
                    surface.SetDrawColor(0, 0, 128)
                else
                    surface.SetDrawColor(64, 64, 64)
                end
            end
            surface.DrawRect(0, 0, w, h)
        end

        leftSide.Items[k] = item
    end

    leftSide:SetWidth(math.min(width + 10, 250))
    leftSide:InvalidateChildren()
    if selectedMap then
        itemSelectFrame.ItemLabel:SetText(string.upper(SCInfo.Maps[selectedMap].NAME))
    else
        itemSelectFrame.ItemLabel:SetText("SELECT A MAP")
    end
    SetConfirm()

    itemSelectFrame.ModelHolder:Hide()
    itemSelectFrame.ItemValues:SetText("[" .. mapPrice .. " POINTS]")
    itemSelectFrame.ItemDescription:SetText("Bribe the helicopter driver to go to a location of your choosing--highest payer wins. Price increases with each consecutive purchase.")
end

function DrawItemSelectorBox()
    if not IsValid(itemSelectFrame) then
        SetupBase()
    end

    itemSelectFrame.MapGuaranteeSelect:SetText(MGSelection and "ITEM SELECTION" or "MAP GUARANTEE")

    if MGSelection then
        SetupMaps()
        return
    end

    SetupItems()
end

hook.Add("slashCoValue", "slashCo_ItemPicker", function(str, vals)
    if str == "openItemPicker" then
        DrawItemSelectorBox()
        return
    end

    if str == "mapGuar" then
        mapForce = vals[1]
        mapPrice = vals[2]

        if IsValid(itemSelectFrame) and MGSelection then
            SetConfirm()
            itemSelectFrame.ItemValues:SetText("[" .. mapPrice .. " POINTS]")
        end
    end
end)