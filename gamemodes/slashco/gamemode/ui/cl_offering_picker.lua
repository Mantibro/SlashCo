local offerBox, selectedOffer

local function OfferChosen()
    SlashCo.SendValue("sendOffer", selectedOffer)
end

local function SetOfferLabel()
    offerBox.OfferLabel:SetText(string.upper(SCInfo.Offering[selectedOffer].Name .. " Offering"))
    offerBox.OfferModel:SetModel("models/slashco/other/offerings/o_" .. selectedOffer .. ".mdl")
    offerBox.OfferDesc:SetText(SCInfo.Offering[selectedOffer].Description)
end

local function SelectThisOffering(offerID)
    offerBox.Left.Offers[selectedOffer]:SetEnabled(true)
    selectedOffer = offerID
    SetOfferLabel()
    offerBox.Left.Offers[selectedOffer]:SetEnabled(false)
end

local function DrawOfferSelectorBox()
    if IsValid(offerBox) then
        return
    end

    selectedOffer = selectedOffer or 1

    offerBox = vgui.Create("DFrame")
    offerBox:SetTitle("[MAKE AN OFFERING...]")
    offerBox:SetSize(800, 500)
    offerBox:Center()
    offerBox:MakePopup()
    offerBox:SetSizable(true)
    offerBox:SetKeyboardInputEnabled(false)
    offerBox.btnMaxim:Hide()
    offerBox.btnMinim:Hide()
    offerBox.lblTitle:SetFont("TVCD")
    offerBox.lblTitle:SetTextColor(color_white)

    local confirmSelect = vgui.Create("DButton", offerBox)
    offerBox.Confirm = confirmSelect
    confirmSelect:SetSize(160, 30)
    confirmSelect:SetFont("TVCD")
    confirmSelect:SetTextColor(color_white)
    confirmSelect:SetText("CONFIRM")
    function confirmSelect.DoClick()
        OfferChosen(selectedOffer)
        offerBox:Remove()
    end
    function confirmSelect.Paint(_, w, h)
        if confirmSelect:IsHovered() then
            surface.SetDrawColor(0, 0, 128)
        else
            surface.SetDrawColor(64, 64, 64)
        end
        surface.DrawRect(0, 0, w, h)
    end

    local leftSide = vgui.Create("DScrollPanel", offerBox)
    offerBox.Left = leftSide
    leftSide:Dock(LEFT)
    leftSide:GetCanvas():DockPadding(0, -5, 0, 0)
    leftSide:DockMargin(0, 0, 5, 0)

    leftSide.Offers = {}
    local width = 0
    for k, p in SortedPairs(SCInfo.Offering) do
        local offer = vgui.Create("DButton", leftSide)
        function offer.DoClick()
            SelectThisOffering(k)
        end
        offer:Dock(TOP)
        offer:SetHeight(30)
        offer:DockMargin(0, 5, 0, 0)
        offer:SetText(string.upper(p.Name))
        offer:SetFont("TVCD_small")
        offer:SetTextColor(color_white)
        local wi = offer:GetTextSize()
        if wi > width then
            width = wi
        end

        if selectedOffer == k then
            offer:SetEnabled(false)
        end

        function offer.Paint(_, w, h)
            if not offer:IsEnabled() then
                surface.SetDrawColor(128, 0, 0)
            else
                if offer:IsHovered() then
                    surface.SetDrawColor(0, 0, 128)
                else
                    surface.SetDrawColor(64, 64, 64)
                end
            end
            surface.DrawRect(0, 0, w, h)
        end

        leftSide.Offers[k] = offer
    end
    leftSide:SetWidth(math.min(width + 10, 250))

    -- Model panel
    local modelHolder = vgui.Create("Panel", offerBox)
    offerBox.ModelHolder = modelHolder
    modelHolder:Dock(TOP)
    modelHolder:SetHeight(200)
    function modelHolder.Paint(_, w, h)
        surface.SetDrawColor(0, 0, 128)
        surface.DrawRect(0, 0, w, h)
    end

    local offerModel = vgui.Create("DModelPanel", modelHolder)
    offerBox.OfferModel = offerModel
    offerModel:SetPos(200, 30)
    offerModel:SetSize(350, 200)
    offerModel:SetLookAt(Vector(0, 0, 10))
    offerModel:SetFOV(40)
    offerModel:SetCamPos(Vector(60, 0, 0))

    function modelHolder.PerformLayout()
        offerModel:SetSize(modelHolder:GetTall() * 2, modelHolder:GetTall())
        offerModel:Center()
    end

    local offerLabel = vgui.Create("DLabel", offerBox)
    offerBox.OfferLabel = offerLabel
    offerLabel:Dock(TOP)
    offerLabel:DockMargin(0, 5, 0, 5)
    offerLabel:SetContentAlignment(8)
    offerLabel:SetFont("TVCD")
    offerLabel:SetHeight(22)

    local offerDesc = vgui.Create("DLabel", offerBox)
    offerBox.OfferDesc = offerDesc
    offerDesc:Dock(FILL)
    offerDesc:SetFont("TVCD_small")
    offerDesc:SetWrap(true)
    offerDesc:SetContentAlignment(7)

    SetOfferLabel()

    function offerBox.Paint(_, w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end
    function offerBox.btnClose.Paint()
        if offerBox.btnClose:IsHovered() then
            surface.SetTextColor(255, 0, 0)
        else
            surface.SetTextColor(255, 255, 255)
        end
        surface.SetFont("TVCD")
        surface.SetTextPos(0, 0)
        surface.DrawText("[X]")
    end
    function offerBox:PerformLayout()
        self.btnClose:SetSize(48, 24)
        self.btnClose:SetPos(self:GetWide() - 48 - 4, 1)

        self.lblTitle:SetPos(0, 2)
        self.lblTitle:SetSize(self:GetWide() - 25, 20)

        confirmSelect:SetPos(offerBox:GetWide() - 160 - 5, offerBox:GetTall() - 30 - 5)
    end
end

hook.Add("scValue_openOfferingPicker", "slashCo_OfferingPicker", function()
    DrawOfferSelectorBox()
end)