SlashCo = SlashCo or {}

if CLIENT then
	---gets the slasher hud panel
	function SlashCo.SlasherHud()
		return GameData.LocalPlayer.SlasherHud
	end

	---reinitializes the slasher hud panel and returns it
	function SlashCo.InitSlasherHud()
		if IsValid(GameData.LocalPlayer.SlasherHud) then
			GameData.LocalPlayer.SlasherHud:Remove()
		end

		GameData.LocalPlayer.SlasherHud = GetHUDPanel():Add("slashco_slasher_stockhud")
		GameData.LocalPlayer:SlasherFunction("InitHud", GameData.LocalPlayer.SlasherHud)
		return GameData.LocalPlayer.SlasherHud
	end

	---internal: reinitializes the slasher hud panel if there's a lua reload
	-- [[
	if GameData.LocalPlayer and IsValid(GameData.LocalPlayer.SlasherHud) then
		GameData.LocalPlayer.SlasherHud:Remove()
		--end
		GameData.LocalPlayer.SlasherHud = GetHUDPanel():Add("slashco_slasher_stockhud")
		GameData.LocalPlayer:SlasherFunction("InitHud", GameData.LocalPlayer.SlasherHud)
	end
	--]]

	hook.Add("scValue_SlasherHudFunc", "SlashCoReceiveHudFunc", function(funcName, ...)
		if not IsValid(GameData.LocalPlayer.SlasherHud) or not GameData.LocalPlayer.SlasherHud[funcName] then
			return
		end

		GameData.LocalPlayer.SlasherHud[funcName](GameData.LocalPlayer.SlasherHud, ...)
	end)

	return
end

local PLAYER = FindMetaTable("Player")

---pass a function to a slasher's hud
---the SendValue function this uses doesn't send keyed tables or materials right now
function PLAYER:SlasherHudFunc(funcName, ...)
	SlashCo.SendValue(self, "SlasherHudFunc", funcName, ...)
end

--debug code
--[[
if IsValid(g_SlasherHud) then
	g_SlasherHud:Remove()
end

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