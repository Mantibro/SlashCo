include("ui/fonts.lua")

local selectedItem
local itemSelectFrame
local SlashCoItems = SlashCoItems

local function HideItemSelection()
	if IsValid(itemSelectFrame) then
		itemSelectFrame:Remove()
		itemSelectFrame = nil
		selectedItem = "Baby"
	end
end

local function ItemChosen(itemID)
	net.Start("mantislashcoPickItem")
	net.WriteString(itemID)
	net.SendToServer()
end

local function BlockConfirm()
	itemSelectFrame.Confirm:SetText("XXXXXXX")
	function itemSelectFrame.Confirm.Paint(_, w, h)
		surface.SetDrawColor(128, 0, 0)
		surface.DrawRect(0, 0, w, h)
	end
	itemSelectFrame.Confirm:SetEnabled(false)
end

local function SetConfirm()
	if LocalPlayer():GetNWString("item", "none") ~= "none" or LocalPlayer():GetNWString("item2", "none") ~= "none" then
		BlockConfirm()
	else
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
			ItemChosen(selectedItem)
			HideItemSelection()
		end
		itemSelectFrame.Confirm:SetEnabled(true)
	end
end

local function setItemLabel()
	itemSelectFrame.ItemLabel:SetText(string.upper(SlashCoItems[selectedItem].Name))
	if (SlashCoItems[selectedItem].MaxAllowed) then
		local numRemain = SlashCoItems[selectedItem].MaxAllowed()
		local slot = "item"
		if SlashCoItems[selectedItem].IsSecondary then
			slot = "item2"
		end
		for _, v in ipairs(team.GetPlayers(TEAM_SURVIVOR)) do
			if v:GetNWString(slot, "none") == selectedItem then
				numRemain = numRemain - 1
			end
		end
		itemSelectFrame.ItemValues:SetText("["..SlashCoItems[selectedItem].Price.." POINTS] ["..numRemain.." REMAINING]")
		if numRemain <= 0 then
			BlockConfirm()
		else
			SetConfirm()
		end
	else
		itemSelectFrame.ItemValues:SetText("["..SlashCoItems[selectedItem].Price.." POINTS]")
		SetConfirm()
	end
end

local function SelectThisItem(itemID)
	itemSelectFrame.Left.Items[selectedItem]:SetEnabled(true)

	selectedItem = itemID
	itemSelectFrame.ItemModel:SetModel(SlashCoItems[selectedItem].Model)
	itemSelectFrame.ItemModel:SetCamPos(SlashCoItems[selectedItem].CamPos)
	itemSelectFrame.ItemDescription:SetText(SlashCoItems[selectedItem].Description)
	setItemLabel()

	itemSelectFrame.Left.Items[selectedItem]:SetEnabled(false)
end

local function DrawItemSelectorBox()
	if IsValid(itemSelectFrame) then return end

	-- Slasher selectionBox
	itemSelectFrame = vgui.Create("DFrame")
	itemSelectFrame:SetTitle("[PICK YOUR ITEM...]")

	selectedItem = selectedItem or "Baby"

	local confirmSelect = vgui.Create("DButton", itemSelectFrame)
	itemSelectFrame.Confirm = confirmSelect
	confirmSelect:SetSize(160, 30)
	confirmSelect:SetFont("TVCD")
	confirmSelect:SetTextColor(color_white)

	local leftSide = vgui.Create("DScrollPanel", itemSelectFrame)
	itemSelectFrame.Left = leftSide
	leftSide:Dock(LEFT)
	leftSide:GetCanvas():DockPadding(0, -5, 0, 0)
	leftSide:DockMargin(0, 0, 5, 0)

	leftSide.Items = {}
	local width = 0
	for k, p in SortedPairs(SlashCoItems) do
		if not p.Price then continue end
		local item = vgui.Create("DButton", leftSide)
		function item.DoClick()
			SelectThisItem(k)
		end
		item:Dock(TOP)
		item:SetHeight(30)
		item:DockMargin(0, 5, 0, 0)
		item:SetText(string.upper(p.Name))
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
	leftSide:SetWidth(math.min(width+10, 250))

	-- Model panel
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
	itemModel:SetModel(SlashCoItems[selectedItem].Model)
	itemModel:SetCamPos(SlashCoItems[selectedItem].CamPos)

	function modelHolder.PerformLayout()
		itemModel:SetSize(modelHolder:GetTall()*2, modelHolder:GetTall())
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

	setItemLabel()

	local itemDesc = vgui.Create("DLabel", itemSelectFrame)
	itemSelectFrame.ItemDescription = itemDesc
	itemDesc:Dock(FILL)
	itemDesc:SetText(SlashCoItems[selectedItem].Description)
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

		confirmSelect:SetPos(itemSelectFrame:GetWide()-160-5, itemSelectFrame:GetTall()-30-5)
	end

	itemSelectFrame:SetSize(800, 500)
	itemSelectFrame:Center()
	itemSelectFrame:MakePopup()
	itemSelectFrame:SetSizable(true)
	itemSelectFrame:SetKeyboardInputEnabled(false)
end

net.Receive("mantislashcoStartItemPicking", function()
	DrawItemSelectorBox()
end)
