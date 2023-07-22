local PANEL = {}

local gasCansPerGenerator = 4 --this is set here since SlashCo.GasCansPerGenerator is serverside only for some reason

local red = Color(255, 0, 0)
local darkRed = Color(128, 32, 32)
local lightRed = Color(255, 128, 128)
local grey = Color(50, 50, 50)
local dark = Color(6, 6, 6)
local survivorIcon = Material("slashco/ui/icons/slasher/s_survivor")
local survivorDeadIcon = Material("slashco/ui/icons/slasher/s_survivor_dead")

function PANEL:Init()
	self:SetMouseInputEnabled(false)

	self:Dock(FILL)
	self.Controls = {}
	self.Meters = {}
	self.Gens = {}

	local right = vgui.Create("Panel", self)
	self.Right = right
	right:SetWide(420)
	right:Dock(RIGHT)

	self:MakeTitleCard()
	self:MakeSurvivorsCard()
	self:MakeGeneratorsCard()

	local left = vgui.Create("Panel", self)
	self.Left = left
	left:SetWide(420)
	left:Dock(LEFT)
end

---sets the slasher title
function PANEL:SetTitle(name)
	self.TitleCard.Label:SetText(name)
end

---sets up the slasher avatar table to simplify setting avatars
function PANEL:SetAvatarTable(avatars)
	self.AvatarTable = avatars
end

---sets the slasher avatar to a new material or index of the avatar table
function PANEL:SetAvatar(avatar)
	if type(avatar) == "IMaterial" then
		self.TitleCard.Icon.Mat = avatar
	else
		self.TitleCard.Icon.Mat = self.AvatarTable[avatar]
	end
end

---add a new control to the right side
function PANEL:AddControl(key, text, icon, zPos)
	local control = vgui.Create("slashco_slasher_control", self.Right)
	self.Controls[key] = control
	control:SetTall(100)
	control:Dock(BOTTOM)
	control:Setup(key, text, icon)
	control:SetZPos(zPos or 0)
	self.Right:InvalidateChildren()
end

---remove a control
function PANEL:RemoveControl(key)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:Remove()
	self.Controls[key] = nil
end

---sets a control's text
---will automatically set the icon to one of the same index (in the icon table)
function PANEL:SetControlText(key, text, dontSetIcon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetText(text, dontSetIcon)
end

---set a control's "enabled" state (disabled controls are darker)
---if enabled, the control will set its icon to "<text>" as long asdontSetIcon is nil/false
---if disabled, the control will set its icon to "d/<text>" as long as dontSetIcon is nil/false
function PANEL:SetControlEnabled(key, state, dontSetIcon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetEnabled(state, dontSetIcon)
end

---sets whether on-hud models always have their "look-at"/model fog behavior or not
---doesn't affect updates to generator stats
function PANEL:SetAllSeeing(value)
	self.AllSeeing = value
end

---show or hide a control entirely
function PANEL:SetControlVisible(key, value)
	if not self.Controls[key] then
		return
	end

	if value then
		self.Controls[key]:Show()
	else
		self.Controls[key]:Hide()
	end

	self.Right:InvalidateChildren()
end

---sets a new icon table for a control
---this is already done when a control is made
---updates the icon if allowed
function PANEL:SetControlIconTable(key, icons, dontSetIcon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetIconTable(icons, dontSetIcon)
end

---override a control's icon
---either material or an index of the icon table
function PANEL:SetControlIcon(key, icon)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:SetIcon(icon)
end

---changes the key of a control; will swap keys with whatever control was already set there
function PANEL:SetControlKey(key, newKey)
	if not self.Controls[key] then
		return
	end

	if self.Controls[newKey] then
		self.Controls[newKey]:SetKey(key)
	end
	self.Controls[key]:SetKey(newKey)

	self.Controls[key], self.Controls[newKey] = self.Controls[newKey], self.Controls[key]
end

---internal: shows the slasher's name and avatar
function PANEL:MakeTitleCard()
	local card = vgui.Create("Panel", self)
	self.TitleCard = card
	card:Dock(BOTTOM)
	card:SetTall(120)

	local icon = vgui.Create("Panel", card)
	card.Icon = icon
	icon.Mat = Material("slashco/ui/icons/slasher/s_7_s1")
	icon:SetWide(card:GetTall())
	icon:Dock(LEFT)
	function icon.Paint(_, w, h)
		surface.SetMaterial(icon.Mat)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectRotated(w / 2, h / 2, 96, 96, 7)
	end

	local label = vgui.Create("DLabel", card)
	card.Label = label
	label:Dock(FILL)
	label:SetContentAlignment(1)
	label:SetFont("HalfCutTitle")
	label:SetText("tyler")
	label:SetTextColor(red)
end

---internal: adds a red tint to on-hud models when not viewed
---this serves many purposes--it contributes to the hud style, obscures game info from the slasher,
---and helps differentiate between generators/players
function PANEL:ModelFog(modelPanel)
	function modelPanel.AlsoThink()
		--override
	end

	function modelPanel.Think()
		if LocalPlayer():GetEyeTrace().Entity == modelPanel.Entity then
			modelPanel:SetAmbientLight(grey)
			modelPanel:SetDirectionalLight(BOX_TOP, color_white)
			modelPanel:SetDirectionalLight(BOX_FRONT, color_white)
			modelPanel:SetNoKids(false)
			modelPanel.Seen = true
		else
			if self.AllSeeing then
				modelPanel:SetAmbientLight(grey)
				modelPanel:SetDirectionalLight(BOX_TOP, color_white)
				modelPanel:SetDirectionalLight(BOX_FRONT, color_white)
				modelPanel:SetNoKids(false)
			else
				modelPanel:SetAmbientLight(darkRed)
				modelPanel:SetDirectionalLight(BOX_TOP, lightRed)
				modelPanel:SetDirectionalLight(BOX_FRONT, lightRed)
				modelPanel:SetNoKids(true)
			end
			modelPanel.Seen = false
		end

		modelPanel:AlsoThink()
	end
end

---internal: makes the survivor indicators above the slasher name card
function PANEL:MakeSurvivorsCard()
	if not SurvivorTeam then
		return
	end

	local card = vgui.Create("Panel", self)
	self.SurvivorsCard = card
	card:Dock(BOTTOM)
	card:SetTall(80)

	for _, v in ipairs(SurvivorTeam) do
		local survivor = card:Add("Panel")
		survivor.Rotate = math.random(-7, 7)
		survivor.Entity = player.GetBySteamID64(v.id)
		survivor:Dock(LEFT)
		survivor:SetWide(80)
		function survivor.Paint(_, w, h)
			surface.SetDrawColor(255, 255, 255, 255)

			if survivor.NotAlive then
				surface.SetMaterial(survivorDeadIcon)
				surface.DrawTexturedRectRotated(w / 2 + survivor.dX, h / 2 + survivor.dY, 64, 64, survivor.Rotate)
			else
				surface.SetMaterial(survivorIcon)
				surface.DrawTexturedRectRotated(w / 2, h / 2, 48, 48, survivor.Rotate)
			end
		end

		local anim = Derma_Anim("DieShake", survivor, function(pnl, _, delta)
			pnl.dX = (math.random() - 0.5) * (1 - delta) * 4
			pnl.dY = (math.random() - 0.5) * (1 - delta) * 4
		end)
		function survivor.Think()
			if not IsValid(survivor.Entity) or survivor.Entity:Team() ~= TEAM_SURVIVOR then
				if not survivor.NotAlive then
					anim:Start(1)
					survivor.Model:Hide()
				end
				survivor.NotAlive = true
			else
				if survivor.NotAlive then
					survivor.Model:Show()
				end
				survivor.NotAlive = nil
			end

			if anim:Active() then
				anim:Run()
			end
		end

		local model = survivor:Add("slashco_projector")
		survivor.Model = model
		model:Dock(FILL)
		model:SetEntity(survivor.Entity)
		model:SetFOV(20)
		model:SetRotation(survivor.Rotate)
		self:ModelFog(model)
	end
end

---internal: makes the can/battery display
function PANEL:MakeGenEntry(gen, i, model)
	local entry = vgui.Create("DModelPanel", self)
	table.insert(gen.Entries, entry)

	entry:SetSize(50, 50)
	entry:SetModel(model or "models/props_junk/metalgascan.mdl")
	entry:SetFOV(25)
	entry:SetLookAt(vector_origin)
	entry:SetAmbientLight(dark)
	entry:SetDirectionalLight(BOX_TOP, color_black)
	entry:SetDirectionalLight(BOX_FRONT, color_black)

	entry.XShake = 0
	entry.YShake = 0
	entry.ZShake = 0
	entry.Anim = Derma_Anim("DieShake", survivor, function(pnl, _, delta)
		entry.XShake = (math.random() - 0.5) * (1 - delta) * 5
		entry.YShake = (math.random() - 0.5) * (1 - delta) * 35
		entry.ZShake = (math.random() - 0.5) * (1 - delta) * 35
	end)

	local angle = math.pi / ((gasCansPerGenerator + 1) / 2) * i
	local x, y = gen:GetPos()

	function entry.Think()
		entry:SetCamPos(Vector(80 + entry.XShake, entry.YShake, entry.ZShake))
		if entry.Anim:Active() then
			entry.Anim:Run()
		end
	end

	function entry.LayoutEntity(_, ent)
		ent:SetAngles(LocalPlayer():LocalEyeAngles() + Angle(5, (i * 360 / (gasCansPerGenerator + 1)) % 360, 5))
	end
	entry.DefaultPos = {
		x + (gen:GetWide() / 2) - math.cos(angle) * 50 - (entry:GetWide() / 2),
		y + (gen:GetTall() / 2) + math.sin(angle) * 50 - (entry:GetTall() / 2)
	}
	entry.CenteredPos = {
		(ScrW() / 2) - math.cos(angle) * 100 - (entry:GetWide()),
		(ScrH() / 2) + math.sin(angle) * 100 - (entry:GetTall())
	}
	entry:SetPos(unpack(entry.DefaultPos))
end

---internal: shows the generator display up top
function PANEL:MakeGeneratorsCard()
	local gens = ents.FindByClass("sc_generator")
	local genCount = #gens
	if genCount < 1 then
		return
	end

	for k, v in ipairs(gens) do
		local gen = self:Add("slashco_projector")
		table.insert(self.Gens, gen)
		gen:SetSize(160, 160)
		gen:SetPos(ScrW() / 2 + 160 * k - 80 * genCount - 160)
		gen:SetEntity(v)
		gen:SetFOV(20)
		gen:SetDistance(400)
		self:ModelFog(gen)

		gen.CansRemaining = gasCansPerGenerator

		gen.Entries = {}
		PANEL:MakeGenEntry(gen, 0, "models/items/car_battery01.mdl")

		for i = 1, 4 do
			PANEL:MakeGenEntry(gen, i)
		end

		function gen.AlsoThink()
			if gen.Seen then
				if not gen.HasCenter then
					for _, v1 in ipairs(gen.Entries) do
						local x, y = unpack(v1.CenteredPos)
						v1:MoveTo(x, y, 0.25, 0, 0.5)
						v1:SizeTo(100, 100, 0.25, 0, 0.5)
					end
					gen.HasCenter = true
				end
			else
				if gen.HasCenter then
					for _, v1 in ipairs(gen.Entries) do
						local x, y = unpack(v1.DefaultPos)
						v1:MoveTo(x, y, 0.25, 0, 1.5)
						v1:SizeTo(50, 50, 0.25, 0, 1.5)
					end
					gen.HasCenter = false
				end
			end
		end
	end
end

---internal: removes panels that don't get removed automatically
function PANEL:OnRemove()
	for _, v in ipairs(self.Gens) do
		for _, v1 in ipairs(v.Entries) do
			v1:Remove()
		end
	end
end

vgui.Register("slashco_slasher_stockhud", PANEL, "Panel")

hook.Add("scValue_genProg", "slashCoGetGenProg", function(gen, hasBattery, cansRemaining)
	if not g_SlasherHud then
		return
	end

	local panel
	for _, v in ipairs(g_SlasherHud.Gens) do
		if v.Entity == gen then
			panel = v
		end
	end

	if not panel then
		return
	end

	if panel.HasBattery ~= hasBattery then
		panel.HasBatteryNew = hasBattery
	end

	if panel.CansRemaining ~= cansRemaining then
		panel.CansRemainingNew = cansRemaining
	end

	timer.Simple(0.25, function()
		local playSound

		if panel.HasBatteryNew then
			playSound = true

			panel.Entries[1]:SetAmbientLight(grey)
			panel.Entries[1]:SetDirectionalLight(BOX_TOP, color_white)
			panel.Entries[1]:SetDirectionalLight(BOX_FRONT, color_white)
			panel.Entries[1].Anim:Start(1)
			panel.HasBattery = panel.HasBatteryNew
			panel.HasBatteryNew = nil
		end

		if panel.CansRemainingNew then
			playSound = true

			for i = 2, 1 + gasCansPerGenerator - panel.CansRemainingNew do
				if 5 - i < panel.CansRemaining then
					panel.Entries[i].Anim:Start(1)
				end

				panel.Entries[i]:SetAmbientLight(grey)
				panel.Entries[i]:SetDirectionalLight(BOX_TOP, color_white)
				panel.Entries[i]:SetDirectionalLight(BOX_FRONT, color_white)
			end

			panel.CansRemaining = panel.CansRemainingNew
			panel.CansRemainingNew = nil
		end

		if playSound then
			if panel.HasBattery and panel.CansRemaining <= 0 then
				surface.PlaySound("slashco/slashco_progress_full.mp3")
			else
				surface.PlaySound("slashco/slashco_progress.mp3")
			end
		end
	end)
end)

if IsValid(g_SlasherHud) then
	g_SlasherHud:Remove()
end

-- [[
g_SlasherHud = vgui.Create("slashco_slasher_stockhud")

local iconTable = {
	["cungus"] = Material("slashco/ui/icons/slasher/s_7"),
	["d/cungus"] = Material("slashco/ui/icons/slasher/s_7_s1"),
	["bugnus"] = Material("slashco/ui/icons/slasher/s_17"),
	["le chase"] = Material("slashco/ui/icons/slasher/s_4"),
}

g_SlasherHud:SetTitle("AMONG US")
g_SlasherHud:SetAvatar(Material("slashco/ui/icons/slasher/s_4"))
g_SlasherHud:AddControl("K", "le chase", iconTable)
g_SlasherHud:AddControl("G", "cungus", iconTable, 2)
g_SlasherHud:AddControl("H", "adw", iconTable)
g_SlasherHud:SetControlEnabled("G", false)

--]]