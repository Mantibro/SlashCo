AddCSLuaFile()

-- Source engine definition for enum DoorState_t 
local doorStates = {
	DOOR_STATE_CLOSED = 0,
	DOOR_STATE_OPENING = 1,
	DOOR_STATE_OPEN = 2,
	DOOR_STATE_CLOSING = 3,
	DOOR_STATE_AJAR = 4,
}

SlashCo = SlashCo or {}
function SlashCo.IsDoorOpen(ent)
	if ent:GetClass() ~= "prop_door_rotating" then
		return false
	end

	if CLIENT then
		-- m_eDoorState is networked by the engine :)
		return ent:GetInternalVariable("m_eDoorState") ~= doorStates.DOOR_STATE_CLOSED
	else
		return ent.IsOpen or false
	end
end

if CLIENT then return end
-- Server only functions

local function DoorBreakRng(door)
	door.OpenCount = (door.OpenCount or 0) + 1

	if math.random(1, 200 - door.OpenCount) == 1 then
		SlashCo.BustDoor(door, door, 200)
	end
end

local function OnDoorStateChanged(door, state)
	door.IsOpen = state

	if state then
		DoorBreakRng(door)
	end
end

--initialize door state listener
local function SetupMapLua()
	local mapLua = ents.Create("lua_run")
	mapLua:SetName("triggerhook")
	mapLua:Spawn()
	mapLua:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

	for _, ent in ipairs(ents.FindByClass("prop_door_rotating")) do
		OnDoorStateChanged(ent, ent:GetInternalVariable("m_eDoorState") ~= doorStates.DOOR_STATE_CLOSED)

		ent:Fire("AddOutput", "OnOpen triggerhook:RunPassedCode:hook.Run( 'DoorOpen' ):0:-1")
		ent:Fire("AddOutput", "OnClose triggerhook:RunPassedCode:hook.Run( 'DoorClose' ):0:-1")
	end
end

hook.Add("InitPostEntity", "SlashCo:SetupMapLua", SetupMapLua)

hook.Add("PlayerUse", "SlashCo:Doors", function(ply, ent)
	if ent:GetClass() ~= "prop_door_rotating" then return end

	if (ent.NextDoorUse or 0) > CurTime() then
		return false -- Block use
	end

	ent.NextDoorUse = CurTime() + 0.2
end)

hook.Add("DoorOpen", "SlashCo:Doors", function()
	OnDoorStateChanged(CALLER, true)
end)

hook.Add("DoorClose", "SlashCo:Doors", function()
	OnDoorStateChanged(CALLER, false)
end)