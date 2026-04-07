local offerBox, selectedOffer
offerBox = GameData.OfferBox

local function OfferChosen()
	local selectedOfferInfo = SCInfo.OrderedOffering[selectedOffer]
	if not selectedOfferInfo then return end

	SlashCo.SendValue("sendOffer", selectedOfferInfo.ID)
end

local function SetOfferLabel()
	local selectedOfferInfo = SCInfo.OrderedOffering[selectedOffer]
	if not selectedOfferInfo then return end

	offerBox.OfferLabel:SetText(string.upper(SlashCo.Language("Offering_name", selectedOfferInfo.Name)))
	offerBox.OfferModel:SetModel("models/slashco/other/offerings/o_" .. selectedOfferInfo.ID .. ".mdl")

	local desc = SlashCo.Language(selectedOfferInfo.Name .. "_desc")
	if selectedOfferInfo.MinimumPlayers then
		desc = desc .. [[


]] .. SlashCo.Language("Offering_required_minimum_players", selectedOfferInfo.MinimumPlayers)
	end

	offerBox.OfferDesc:SetText(desc)
end

if GameData.IsLobby then
	SlashCo.AudioSystem.PrecacheSound("slashco/ui/terminalbutton_1.mp3", "", "OfferSelect")
	SlashCo.AudioSystem.PrecacheSound("slashco/ui/terminalbutton_2.mp3", "", "OfferConfirm")
	SlashCo.AudioSystem.PrecacheSound("slashco/ui/item_deselect.mp3", "", "OfferDecline")
end

local function SelectThisOffering(offerID)
	if offerBox.Left.Offers[selectedOffer] then
		offerBox.Left.Offers[selectedOffer]:SetEnabled(true)
	end

	selectedOffer = offerID
	SetOfferLabel()
	offerBox.Left.Offers[selectedOffer]:SetEnabled(false)

	SlashCo.AudioSystem.PlayPrecachedChannel("OfferSelect")
end

local function DrawOfferSelectorBox()
	if IsValid(offerBox) then
		return
	end

	offerBox = vgui.Create("DFrame")
	GameData.OfferBox = offerBox

	offerBox:SetTitle("[" .. string.upper(SlashCo.Language("offering_idle")) .. "...]")
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
	confirmSelect:SetText(SlashCo.Language("ItemConfirm"))
	function confirmSelect.DoClick()
		local selectedOfferInfo = SCInfo.OrderedOffering[selectedOffer]
		if not selectedOfferInfo then return end

		if (selectedOfferInfo.MinimumPlayers or 0) > team.NumPlayers(TEAM_LOBBY) then
			SlashCo.AudioSystem.PlayPrecachedChannel("OfferDecline")
			return
		end

		OfferChosen(selectedOffer)
		SlashCo.AudioSystem.PlayPrecachedChannel("OfferConfirm")
		offerBox:Remove()
	end

	function confirmSelect.Paint(_, w, h)
		if confirmSelect:IsHovered() then
			local selectedOfferInfo = SCInfo.OrderedOffering[selectedOffer]
			if selectedOfferInfo and (selectedOfferInfo.MinimumPlayers or 0) > team.NumPlayers(TEAM_LOBBY) then
				surface.SetDrawColor(128, 0, 0)
			else
				surface.SetDrawColor(0, 0, 128)
			end
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
	for offerID, offerInfo in SortedPairs(SCInfo.OrderedOffering) do
		local offer = vgui.Create("DButton", leftSide)
		function offer.DoClick()
			if (offerInfo.MinimumPlayers or 0) > team.NumPlayers(TEAM_LOBBY) then
				confirmSelect:SetTooltip(SlashCo.Language("Offering_required_minimum_players", offerInfo.MinimumPlayers))
			else
				confirmSelect:SetTooltip(nil)
			end

			SelectThisOffering(offerID)
		end

		offer:Dock(TOP)
		offer:SetHeight(30)
		offer:DockMargin(0, 5, 0, 0)
		offer:SetText(string.upper(SlashCo.Language("Offering_name", offerInfo.Name)))
		offer:SetFont("TVCD_small")
		offer:SetTextColor(color_white)
		local wi = offer:GetTextSize()
		if wi > width then
			width = wi
		end

		if selectedOffer == offerID then
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

		leftSide.Offers[offerID] = offer

		if not selectedOffer then
			-- Auto selects the first item by default
			selectedOffer = offerID
		end
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