local pmSelectFrame

local function HidePlayermodelSelection()
	if IsValid(pmSelectFrame) then
		pmSelectFrame:Remove()
		pmSelectFrame = nil
	end
end

local function PlayerModelChosen(mod)
	RunConsoleCommand("cl_slashco_playermodel", mod)
end

function DrawThePlayermodelSelectorBox()
	if IsValid(pmSelectFrame) then return end

	pmSelectFrame = vgui.Create("DFrame")
	pmSelectFrame:SetTitle( SlashCoLanguage("playermodel_choose") )

	local val = 1
	for c = 0, 2 do
		for i = 0, 2 do
			local item = vgui.Create("SpawnIcon", pmSelectFrame)
			function item.DoClick()
				PlayerModelChosen("models/slashco/survivor/male_0"..val..".mdl")
				HidePlayermodelSelection()
			end
			item:SetSize(80, 80)
			item:SetPos(5 + i*80, 29 + c*80)
			item:SetModel("models/slashco/survivor/male_0"..val..".mdl")
			item:SetTooltip("Male 0"..val)
			val = val+1
		end
	end
	
	pmSelectFrame.btnMaxim:Hide()
	pmSelectFrame.btnMinim:Hide()
	pmSelectFrame.lblTitle:SetFont("TVCD")
	pmSelectFrame.lblTitle:SetTextColor(color_white)
	function pmSelectFrame.Paint(_, w, h)
		surface.SetDrawColor(0, 0, 128)
		surface.DrawRect(0, 0, w, h)
	end
	function pmSelectFrame.btnClose.Paint()
		if pmSelectFrame.btnClose:IsHovered() then
			surface.SetTextColor(255, 0, 0)
		else
			surface.SetTextColor(255, 255, 255)
		end
		surface.SetFont("TVCD")
		surface.SetTextPos(0, 0)
		surface.DrawText("[X]")
	end

	function pmSelectFrame:PerformLayout()
		local titlePush = 0

		if IsValid(self.imgIcon) then
			self.imgIcon:SetPos(5, 5)
			self.imgIcon:SetSize(16, 16)
			titlePush = 16
		end

		self.btnClose:SetSize(48, 24)
		self.btnClose:SetPos(self:GetWide() - 48 - 4, 1)

		self.lblTitle:SetPos(titlePush, 2)
		self.lblTitle:SetSize(self:GetWide() - 25 - titlePush, 20)
	end

	pmSelectFrame:SetSize(80*3+10, 80*3+24+10)
	pmSelectFrame:Center()
	pmSelectFrame:MakePopup()
	pmSelectFrame:SetKeyboardInputEnabled(false)
end

