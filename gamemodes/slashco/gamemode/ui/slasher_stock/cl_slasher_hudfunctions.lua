SlashCo = SlashCo or {}
local ply = LocalPlayer()

---gets the slasher hud panel
function SlashCo.SlasherHud()
	return ply.SlasherHud
end

---reinitializes the slasher hud panel and returns it
function SlashCo.InitSlasherHud()
	if IsValid(ply.SlasherHud) then
		ply.SlasherHud:Remove()
	end

	ply.SlasherHud = GetHUDPanel():Add("slashco_slasher_stockhud")
	ply:SlasherFunction("InitHud")
	return ply.SlasherHud
end

---internal: reinitializes the slasher hud panel if there's a lua reload
if IsValid(ply.SlasherHud) then
	ply.SlasherHud:Remove()
	ply.SlasherHud = GetHUDPanel():Add("slashco_slasher_stockhud")
	ply:SlasherFunction("InitHud")
end

--debug code
--[[
g_SlasherHud = GetHUDPanel():Add("slashco_slasher_stockhud")

local iconTable = {
	["cungus"] = Material("slashco/ui/icons/slasher/s_7"),
	["d/cungus"] = Material("slashco/ui/icons/slasher/s_7_s1"),
	["bugnus"] = Material("slashco/ui/icons/slasher/s_17"),
	["le chase"] = Material("slashco/ui/icons/slasher/s_4"),
}

g_SlasherHud:SetTitle("AMONG US")
--g_SlasherHud:SetAvatar(Material("slashco/ui/icons/slasher/s_4"))
g_SlasherHud:AddControl("K", "le chase", "chase")
g_SlasherHud:AddControl("SPACE", "walk")
g_SlasherHud:AddControl("G", "cungus", iconTable, 2)
g_SlasherHud:AddControl("H", "adw", iconTable)
g_SlasherHud:SetControlEnabled("SPACE", false)
g_SlasherHud:ShakeControl("G")
g_SlasherHud:AddMeter("Swigga")
g_SlasherHud:AddMeter("keppuku", 30, "", nil, true)

timer.Create("meterTest", 0.1, 0, function()
	g_SlasherHud:SetMeterValue("Swigga", math.random(100))
end)

timer.Create("meterTest1", 1, 0, function()
	g_SlasherHud:SetMeterValue("keppuku", math.random(40))
	g_SlasherHud:FlashMeter("keppuku")
end)
--g_SlasherHud:SetAllSeeing(true)

--]]