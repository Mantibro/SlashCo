local PANEL = {}

local gasCansPerGenerator = 4 --this is set here since SlashCo.GasCansPerGenerator is serverside only for some reason

local red = Color(255, 0, 0)
local darkRed = Color(128, 32, 32)
local lightRed = Color(255, 128, 128)
local grey = Color(50, 50, 50)
local dark = Color(10, 0, 0)
local survivorIcon = Material("slashco/ui/icons/slasher/s_survivor")
local survivorDeadIcon = Material("slashco/ui/icons/slasher/s_survivor_dead")

function PANEL:Init()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	self:Dock(FILL)
	self.Controls = {}
	self.Meters = {}
	self.Gens = {}
	self.ControlTies = {}
	self.CrosshairSpin = 0
	self.CrosshairTight = 0
	self.CrosshairProngs = 3
	self.CrosshairAngles = 120
	self.CrosshairAlpha = 0

	local right = vgui.Create("Panel", self)
	self.Right = right
	right:SetWide(420)
	right:Dock(RIGHT)

	self:MakeTitleCard()
	self:MakeSurvivorsCard()
	self:MakeGeneratorsCard()
	self:MakeCrosshair()

	--[[
	local left = vgui.Create("Panel", self)
	self.Left = left
	left:SetWide(420)
	left:Dock(LEFT)
	--]]
end

---[SLASHER DISPLAY]---

---sets the slasher title
function PANEL:SetTitle(name)
	self.TitleCard.Label:SetText(" " .. SlashCo.Language(name))
end

---sets up the slasher avatar table to simplify setting avatars
function PANEL:SetAvatarTable(avatars)
	self.AvatarTable = avatars

	if self.AvatarTable["default"] then
		self:SetAvatar("default")
	end
end

---sets the slasher avatar to a new material or index of the avatar table
function PANEL:SetAvatar(avatar)
	if type(avatar) == "IMaterial" then
		self.TitleCard.Icon.Mat = avatar
	else
		self.TitleCard.Icon.Mat = self.AvatarTable[avatar]
	end
end

---[METERS]---

---makes a new meter on the right side
function PANEL:AddMeter(name, max, component, componentIsPrefix, showMax, zPos)
	local meter = self.Right:Add("slashco_slasher_meter")
	self.Meters[name] = meter
	meter:SetTall(95)
	meter:Dock(BOTTOM)
	meter:SetZPos(zPos or -100)
	meter:DockMargin(0, 0, 8, 8)
	meter:Setup(name, max, component, componentIsPrefix, showMax)
	self.Right:InvalidateChildren()
end

---sets the value of a meter
function PANEL:SetMeterValue(name, value)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:SetValue(value)
end

---sets the name of a meter
---returns true and fails if a meter is already named as such
function PANEL:SetMeterName(name, newName)
	if not self.Meters[name] or self.Meters[newName] then
		return true
	end

	self.Meters[name]:SetName(newName)
	self.Meters[newName] = self.Meters[name]
	self.Meters[name] = nil
end

---sets the max value of a meter
function PANEL:SetMeterMax(name, max)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:SetMax(max)
end

---set the "component" of the value display (ie. the % sign or maybe a $ sign)
---if isPrefix is true, the component goes before the number
function PANEL:SetMeterComponent(name, component, isPrefix)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:SetComponent(component, isPrefix)
end

---show or hide a meter entirely
function PANEL:SetMeterVisible(key, value)
	if not self.Meters[key] then
		return
	end

	if value then
		self.Meters[key]:Show()
	else
		self.Meters[key]:Hide()
	end

	self.Right:InvalidateChildren()
end

---whether the meter shows its max value
function PANEL:SetMeterShowMax(name, showMax)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:ShowMax(showMax)
end

---ties the value of the meter to a netvar
function PANEL:TieMeterInt(name, netvar, doFlash, fallback)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:TieInt(netvar, doFlash, fallback)
end

---removes the meter's current tie
function PANEL:UntieMeter(name)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:Untie()
end

---flashes a meter
function PANEL:FlashMeter(name)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:Flash()
end

---set custom colors (disables flashing)
function PANEL:SetMeterColors(name, empty, full)
	if not self.Meters[name] then
		return
	end

	self.Meters[name]:SetColors(empty, full)
end

---gets the specified meter
function PANEL:GetMeter(name)
	return self.Meters[name]
end

---[CONTROLS]---

---add a new control to the right side
---icon can be either the icon table or just one icon
---setting the icon to "chase" will set the icon table to the default chase icons
function PANEL:AddControl(key, text, icon, zPos)
	local control = self.Right:Add("slashco_slasher_control")
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

---sets whether on-hud models always show children
---this lets the slasher see player's items and generator objects at all times
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
---icons are automatically set to the control's text and disabled state
---index = "<control text>" -> icon for when the control has that text
---= "d/<control text>" -> icon for when the control has that text and is disabled
---= "default" -> the default icon, as a fallback
---= "d/" -> the default icon when the control is disabled
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

---Makes the enabled state of the control tied to a net variable
function PANEL:TieControl(key, netvar, isInverse, doShake, fallback)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:Tie(netvar, isInverse, doShake, fallback)
end

---Tie the message of the control to a net variable
function PANEL:TieControlText(key, netvar, enabledText, disabledText, doShake, fallback)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:TieText(netvar, enabledText, disabledText, doShake, fallback)
end

---Makes the visibility state of the control tied to a net variable
function PANEL:TieControlVisible(key, netvar, isInverse, doShake, fallback)
	if not self.Controls[key] then
		return
	end

	if fallback == nil then
		fallback = true
	end
	isInverse = isInverse or false

	local state = true
	if type(netvar) == "table" then
		for _, v in ipairs(netvar) do
			if not LocalPlayer():GetNWBool(v, fallback) then
				state = false
				break
			end
		end
	else
		state = LocalPlayer():GetNWBool(netvar, fallback)
	end

	self.ControlTies[key] = {
		netvar = netvar,
		prevVal = state,
		func = function(val)
			self:SetControlVisible(key, val ~= isInverse)
		end,
		doShake = doShake,
		fallback = fallback
	}
	self:SetControlVisible(key, state ~= isInverse)
end

---Removes the current netvar tie of a control
function PANEL:UntieControl(key)
	if not self.Controls[key] then
		return
	end

	self.Controls[key]:Untie()
	self.ControlTies[key] = nil
end

---Makes the standard chase and kill controls automagically
function PANEL:ChaseAndKill(noChase, noKill)
	if not noKill then
		self:AddControl("LMB", "kill survivor")
		self:TieControl("LMB", "CanKill")
	end

	if noChase then
		return
	end

	self:AddControl("RMB", "start chasing", "chase")
	self:TieControl("RMB", "CanChase")
	self:TieControlText("RMB", "InSlasherChaseMode", "stop chasing", "start chasing", true, false)
end

---shakes a control's icon a little
function PANEL:ShakeControl(key)
	if not self.Controls[key] then
		return
	end
	self.Controls[key]:Shake()
end

---gets the specified control panel
function PANEL:GetControl(key)
	return self.Controls[key]
end

---[CROSSHAIR]---

---make the crosshair spin
function PANEL:SetCrosshairSpin(amount)
	self.CrosshairSpin = amount
end

---make the crosshair smaller on the inside
function PANEL:SetCrosshairTighten(amount)
	self.CrosshairTight = amount
end

---enable crosshair or not
function PANEL:SetCrosshairEnabled(state)
	if state then
		self.Crosshair:Show()
	else
		self.Crosshair:Hide()
	end
end

---make the crosshair tighten and spin when you're looking at an entity
---can also specify a control to be driven
---vararg is networked booleans to check for
function PANEL:TieCrosshairEntity(entity, distance, control, netVars, settings)
	if not settings then
		settings = {
			SpinOn = 50,
			TightenOn = 4,
			ProngsOn = 4,
			SpinOff = 0,
			TightenOff = 0,
			ProngsOff = 3
		}
	end
	local checkVars = type(netVars)
	if checkVars == "table" then
		netVars.InvertOutput = netVars.InvertOutput or false
	end

	self.GoCrosshair = true
	function self.CrosshairTieEntity()
		local varCheck = true
		if checkVars == "string" then
			varCheck = self:CheckNetVars(false, false, netVars)
		elseif checkVars == "table" then
			varCheck = self:CheckNetVars(netVars.IsOr, netVars.InvertInput, unpack(netVars)) ~= netVars.InvertOutput
		end

		local ent = LocalPlayer():GetEyeTrace().Entity
		if IsValid(ent) and ent:GetClass() == entity and LocalPlayer():GetPos():Distance(ent:GetPos()) < distance
				and varCheck then

			if not self.GoCrosshair then
				if control then
					self:SetControlEnabled(control, true)
					self:ShakeControl(control)
				end
				if settings.SpinOn then
					self:SetCrosshairSpin(settings.SpinOn)
				end
				if settings.TightenOn then
					self:SetCrosshairTighten(settings.TightenOn)
				end
				if settings.ProngsOn then
					self:SetCrosshairProngs(settings.ProngsOn)
				end
				if settings.AlphaOn then
					self:SetCrosshairAlpha(settings.AlphaOn)
				end

				self.GoCrosshair = true
			end
		else
			if self.GoCrosshair then
				if control then
					self:SetControlEnabled(control, false)
					self:ShakeControl(control)
				end
				if settings.SpinOff then
					self:SetCrosshairSpin(settings.SpinOff)
				end
				if settings.TightenOff then
					self:SetCrosshairTighten(settings.TightenOff)
				end
				if settings.ProngsOff then
					self:SetCrosshairProngs(settings.ProngsOff)
				end
				if settings.AlphaOff then
					self:SetCrosshairAlpha(settings.AlphaOff)
				end

				self.GoCrosshair = nil
			end
		end
	end
end

---tie the settings of the crosshair to a set of netvars
function PANEL:TieCrosshair(netVars, settings, control)
	if not settings then
		settings = {
			TightenOn = 4,
			TightenOff = 0
		}
	end
	local checkVars = type(netVars)
	if checkVars == "table" then
		netVars.InvertOutput = netVars.InvertOutput or false
	end

	local varCheckPre = true
	if checkVars == "string" then
		varCheckPre = self:CheckNetVars(false, false, netVars)
	elseif checkVars == "table" then
		varCheckPre = self:CheckNetVars(netVars.IsOr, netVars.InvertInput, unpack(netVars)) ~= netVars.InvertOutput
	end
	self.GoCrosshair2 = not varCheckPre
	function self.CrosshairTie()
		local varCheck = true
		if checkVars == "string" then
			varCheck = self:CheckNetVars(false, false, netVars)
		elseif checkVars == "table" then
			varCheck = self:CheckNetVars(netVars.IsOr, netVars.InvertInput, unpack(netVars)) ~= netVars.InvertOutput
		end

		if varCheck then
			if not self.GoCrosshair2 then
				if control then
					self:SetControlEnabled(control, true)
					self:ShakeControl(control)
				end
				if settings.SpinOn then
					self:SetCrosshairSpin(settings.SpinOn)
				end
				if settings.TightenOn then
					self:SetCrosshairTighten(settings.TightenOn)
				end
				if settings.ProngsOn then
					self:SetCrosshairProngs(settings.ProngsOn)
				end
				if settings.AlphaOn then
					self:SetCrosshairAlpha(settings.AlphaOn)
				end

				self.GoCrosshair2 = true
			end
		else
			if self.GoCrosshair2 then
				if control then
					self:SetControlEnabled(control, false)
					self:ShakeControl(control)
				end
				if settings.SpinOff then
					self:SetCrosshairSpin(settings.SpinOff)
				end
				if settings.TightenOff then
					self:SetCrosshairTighten(settings.TightenOff)
				end
				if settings.ProngsOff then
					self:SetCrosshairProngs(settings.ProngsOff)
				end
				if settings.AlphaOff then
					self:SetCrosshairAlpha(settings.AlphaOff)
				end

				self.GoCrosshair2 = nil
			end
		end
	end
end

---make the crosshair no longer tied to anything
function PANEL:UntieCrosshair(doTie, doEntity, settings)
	if doTie then
		self.CrosshairTie = nil
	end
	if doEntity then
		self.CrosshairTieEntity = nil
	end
	if not settings then
		settings = {
			Spin = 0,
			Tighten = 0,
			Prongs = 3,
			Alpha = 255
		}
	end
	if settings.Spin then
		self:SetCrosshairSpin(settings.Spin)
	end
	if settings.Tighten then
		self:SetCrosshairTighten(settings.Tighten)
	end
	if settings.Prongs then
		self:SetCrosshairProngs(settings.Prongs)
	end
	if settings.Alpha then
		self:SetCrosshairAlpha(settings.Alpha)
	end
end

---set the amount of prongs the crosshair has
function PANEL:SetCrosshairProngs(amount)
	self.CrosshairProngs = math.max(amount, 1)
	self.CrosshairAngles = 360 / amount
end

function PANEL:SetCrosshairAlpha(amount)
	self.CrosshairAlpha = amount
end

---[UTILITY]---

---Checks multiple netvars at once
---if isOr is true, a single netvar being true makes the whole thing true, otherwise all must be true
---if invert is set, the entire result is flipped
function PANEL:CheckNetVars(isOr, invertInput, ...)
	invertInput = invertInput or false

	local result = isOr
	for _, v in pairs({ ... }) do
		if LocalPlayer():GetNWBool(v, invertInput) ~= invertInput then
			result = not result
			break
		end
	end

	return result
end

---[INTERNAL]---

---internal: draws the crosshair
local dir = Vector(0, -1, 0)
local nSpin, nTight, nAng, nAlpha = 0, 0, 0, 0
function PANEL:MakeCrosshair()
	local crosshair = self:Add("Panel")
	self.Crosshair = crosshair

	function crosshair.PaintOver(_, w, h)
		nSpin = math.Clamp(Lerp(0.04, nSpin, self.CrosshairSpin), 0, 1000)
		nTight = math.Clamp(Lerp(0.08, nTight, self.CrosshairTight), 0, 1000)
		nAng = math.Clamp(Lerp(0.08, nAng, self.CrosshairAngles), 0, 1000)
		nAlpha = math.Clamp(Lerp(0.04, nAlpha, self.CrosshairAlpha), 0, 255)

		surface.SetDrawColor(255, 0, 0, nAlpha)
		local vel = LocalPlayer():EyeAngles():Right():Dot(LocalPlayer():GetVelocity())
		local ang = Angle(0, nAng, 0)
		for i = 1, math.max(self.CrosshairProngs, 1) do
			surface.DrawLine(
					w / 2 + dir.x * w / (4 + nTight / 2),
					h / 2 + dir.y * h / (4 + nTight / 2),
					w / 2 + dir.x * w / (8 + nTight * 2),
					h / 2 + dir.y * h / (8 + nTight * 2))
			dir:Rotate(ang + Angle(0, (vel + nSpin) * (0.0045 / math.max(self.CrosshairProngs, 1)), 0))
		end
	end

	--this element is mainly for demons
	crosshair:Hide()
end

---internal: reorient the hud when the resolution changes
function PANEL:PerformLayout()
	local size = ScrH() / 12
	self.Crosshair:SetSize(size, size)
	self.Crosshair:SetPos((ScrW() - size) / 2, (ScrH() - size) / 2)

	for k, v in ipairs(self.Gens) do
		local x, y = ScrW() / 2 + 180 * k - 90 * self.GenCount - 170, 0
		v:SetPos(x, y)

		for _, v1 in ipairs(v.Entries) do
			v1.DefaultPos = {
				x + (v:GetWide() / 2) - math.cos(v1.angle) * 50 - (v1:GetWide() / 2),
				y + (v:GetTall() / 2) + math.sin(v1.angle) * 50 - (v1:GetTall() / 2)
			}
			v1.CenteredPos = {
				(ScrW() / 2) - math.cos(v1.angle) * 100 - (v1:GetWide()),
				(ScrH() / 2) + math.sin(v1.angle) * 100 - (v1:GetTall())
			}
			v1:SetPos(unpack(v1.DefaultPos))
		end
	end
end

---internal: shows the slasher's name and avatar
function PANEL:MakeTitleCard()
	local card = vgui.Create("Panel", self)
	self.TitleCard = card
	card:Dock(BOTTOM)
	card:SetTall(120)

	local icon = vgui.Create("Panel", card)
	card.Icon = icon
	icon.Mat = Material("slashco/ui/icons/slasher/s_0")
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
	label:SetText(" "..SlashCo.Language("Slasher"))
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
			modelPanel:SetAmbientLight(darkRed)
			modelPanel:SetDirectionalLight(BOX_TOP, lightRed)
			modelPanel:SetDirectionalLight(BOX_FRONT, lightRed)
			modelPanel:SetNoKids(not self.AllSeeing)
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
	local entry = vgui.Create("DModelPanel", GetHUDPanel())
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
	entry.Shake = Derma_Anim("Shake", nil, function(_, _, delta)
		entry.XShake = (math.random() - 0.5) * (1 - delta) * 5
		entry.YShake = (math.random() - 0.5) * (1 - delta) * 35
		entry.ZShake = (math.random() - 0.5) * (1 - delta) * 35
	end)

	entry.YSpin = 0
	entry.Spin = Derma_Anim("Spin", nil, function(_, _, delta)
		if delta < 0.5 then
			entry.YSpin = (2 * (delta ^ 2)) * 360
		else
			entry.YSpin = (1 - ((-2 * delta + 2) ^ 2) / 2) * 360
		end
	end)

	entry.angle = math.pi / ((gasCansPerGenerator + 1) / 2) * i
	--local x, y = gen:GetPos()

	function entry.Think()
		entry:SetCamPos(Vector(80 + entry.XShake, entry.YShake, entry.ZShake))
		if entry.Shake:Active() then
			entry.Shake:Run()
		end
		if entry.Spin:Active() then
			entry.Spin:Run()
		end
	end

	function entry.LayoutEntity(_, ent)
		local YWiggle = math.sin(CurTime()) * 10
		ent:SetAngles(LocalPlayer():LocalEyeAngles() + Angle(5,
				(YWiggle + entry.YSpin + (i * 360 / (gasCansPerGenerator + 1))) % 360, 5))
	end
	--entry.angle = angle

	--[[
	entry.DefaultPos = {
		x + (gen:GetWide() / 2) - math.cos(angle) * 50 - (entry:GetWide() / 2),
		y + (gen:GetTall() / 2) + math.sin(angle) * 50 - (entry:GetTall() / 2)
	}
	entry.CenteredPos = {
		(ScrW() / 2) - math.cos(angle) * 100 - (entry:GetWide()),
		(ScrH() / 2) + math.sin(angle) * 100 - (entry:GetTall())
	}
	entry:SetPos(unpack(entry.DefaultPos))
	--]]
end

---internal: shows the generator display up top
function PANEL:MakeGeneratorsCard()
	local gens = ents.FindByClass("sc_generator")
	local genCount = #gens
	self.GenCount = genCount
	if genCount < 1 then
		return
	end

	for k, v in ipairs(gens) do
		local gen = self:Add("slashco_projector")
		table.insert(self.Gens, gen)
		gen:SetSize(160, 160)
		--gen:SetPos(ScrW() / 2 + 160 * k - 80 * genCount - 160)
		gen:SetEntity(v)
		gen:SetFOV(22)
		gen:SetDistance(400)
		self:ModelFog(gen)

		gen.CansRemaining = gasCansPerGenerator

		gen.Entries = {}
		PANEL:MakeGenEntry(gen, 0, "models/items/car_battery01.mdl")

		for i = 1, gasCansPerGenerator do
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

					timer.Create("SlashCoOrientEntries", 0.26, 1, function()
						for _, v1 in ipairs(gen.Entries) do
							local x, y = unpack(v1.CenteredPos)
							v1:SetPos(x, y)
							v1:SetSize(100, 100)
						end
					end)
				end
			else
				if gen.HasCenter then
					for _, v1 in ipairs(gen.Entries) do
						local x, y = unpack(v1.DefaultPos)
						v1:MoveTo(x, y, 0.25, 0, 1.5)
						v1:SizeTo(50, 50, 0.25, 0, 1.5)
					end
					gen.HasCenter = false

					timer.Create("SlashCoOrientEntries", 0.26, 1, function()
						for _, v1 in ipairs(gen.Entries) do
							local x, y = unpack(v1.DefaultPos)
							v1:SetPos(x, y)
							v1:SetSize(50, 50)
						end
					end)
				end
			end
		end
	end
end

---internal: handles visibility ties
function PANEL:Think()
	for k, v in pairs(self.ControlTies) do
		if not IsValid(self.Controls[k]) then
			self.ControlTies[k] = nil
			continue
		end

		local val = true
		if type(v.netvar) == "table" then
			for _, v1 in ipairs(v.netvar) do
				if LocalPlayer():GetNWBool(v1, v.fallback) then
					val = false
					break
				end
			end
		else
			val = LocalPlayer():GetNWBool(v.netvar, v.fallback)
		end

		if val ~= v.prevVal then
			v.func(val)
			v.prevVal = val

			if v.doShake then
				self.Controls[k]:Shake()
			end
		end
	end

	if self.AlsoThink then
		self:AlsoThink()
	end

	if self.CrosshairTie and not self.DoNotTieCrosshair then
		self.CrosshairTie()
	end

	if self.CrosshairTieEntity and not self.DoNotTieCrosshairEntity then
		self.CrosshairTieEntity()
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

local function findGenPanel(gen)
	if not SlashCo.SlasherHud() then
		return
	end

	local panel
	for _, v in ipairs(SlashCo.SlasherHud().Gens) do
		if v.Entity == gen then
			panel = v
		end
	end

	return panel
end

hook.Add("scValue_genHint", "slashCoGenHint", function(gen)
	local panel = findGenPanel(gen)
	if not IsValid(panel) then
		return
	end

	for _, v in ipairs(panel.Entries) do
		v.Shake:Start(1)
	end
end)

hook.Add("scValue_genProg", "slashCoGetGenProg", function(gen, hasBattery, cansRemaining)
	local panel = findGenPanel(gen)
	if not IsValid(panel) then
		return
	end

	if panel.HasBattery ~= hasBattery then
		panel.HasBatteryNew = hasBattery
	end

	if panel.CansRemaining ~= cansRemaining then
		panel.CansRemainingNew = cansRemaining
	end

	--this timer was formerly just to add a 0.25 second delay, nothing special
	timer.Simple(0, function()
		if not IsValid(panel) then
			return
		end

		local playSound

		if panel.HasBatteryNew then
			playSound = true

			panel.Entries[1]:SetAmbientLight(grey)
			panel.Entries[1]:SetDirectionalLight(BOX_TOP, lightRed)
			panel.Entries[1]:SetDirectionalLight(BOX_FRONT, lightRed)
			panel.Entries[1].Spin:Start(1)
			panel.HasBattery = panel.HasBatteryNew
			panel.HasBatteryNew = nil
		end

		if panel.CansRemainingNew then
			playSound = true

			for i = 2, 1 + gasCansPerGenerator - panel.CansRemainingNew do
				if 5 - i < panel.CansRemaining then
					panel.Entries[i].Spin:Start(1)
				end

				panel.Entries[i]:SetAmbientLight(grey)
				panel.Entries[i]:SetDirectionalLight(BOX_TOP, lightRed)
				panel.Entries[i]:SetDirectionalLight(BOX_FRONT, lightRed)
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