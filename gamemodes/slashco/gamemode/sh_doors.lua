AddCSLuaFile()

local SlashCo = SlashCo or {}

if SERVER then
	SlashCo.OpenDoors = SlashCo.OpenDoors or {}

	local function setDoorState(door, state)
		if state == false then
			state = nil
		end

		door.IsOpen = state
		SlashCo.SendValue(nil, "door", door, state)
		SlashCo.OpenDoors[door:EntIndex()] = state
	end

	--initialize door state listener
	local function SetupMapLua()
		local mapLua = ents.Create("lua_run")
		mapLua:SetName("triggerhook")
		mapLua:Spawn()

		for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
			setDoorState(v, v:GetInternalVariable("m_eDoorState") ~= 0)
			v:CallOnRemove("slashCoDoorDeleted", function(ent)
				setDoorState(ent)
			end)

			v:Fire("AddOutput", "OnOpen triggerhook:RunPassedCode:hook.Run( 'DoorOpen' ):0:-1")
			v:Fire("AddOutput", "OnClose triggerhook:RunPassedCode:hook.Run( 'DoorClose' ):0:-1")
		end
	end

	hook.Add("InitPostEntity", "SetupMapLua", SetupMapLua)
	hook.Add("DoorOpen", "SlashCoDoors", function()
		setDoorState(CALLER, true)
	end)
	hook.Add("DoorClose", "SlashCoDoors", function()
		setDoorState(CALLER)
	end)

	--send door states to late players
	local load_queue = {}
	hook.Add("PlayerInitialSpawn", "slashCoDoorLoad", function(ply)
		load_queue[ply] = true
	end)
	hook.Add("SetupMove", "slashCoDoorLoad", function(ply, _, cmd)
		if load_queue[ply] and not cmd:IsForced() then
			load_queue[ply] = nil

			SlashCo.SendValue(nil, "allDoors", table.GetKeys(SlashCo.OpenDoors))
		end
	end)

	return
end

hook.Add("scValue_door", "SlashCoDoor", function(door, state)
	door.IsOpen = state
end)

hook.Add("scValue_allDoors", "SlashCoAllDoors", function(doors)
	for _, v in ipairs(doors) do
		Entity(v).IsOpen = true
	end
end)