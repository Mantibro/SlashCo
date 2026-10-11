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
SlashCo.ValidDoors = {
	["prop_door_rotating"] = true,
	["func_door_rotating"] = true,
}

function SlashCo.IsValidDoor(ent)
	return IsValid(ent) and SlashCo.ValidDoors[ent:GetClass()] or false
end

function SlashCo.GetValidDoor(ent)
	if SlashCo.IsValidDoor(ent) then
		return ent
	end

	-- RaphaelIT7: We check the parent so that a prop that got a func_door_rotating as a parent can also be slammed
	local parent = ent:GetParent()
	if not SlashCo.IsValidDoor(parent) then
		return nil
	end

	return parent
end

local DOOR_NETWORK_SLOT = 31 -- we use the boolean slot 31 for networking the state
local DOOR_LOCK_SLOT = 30 -- m_bLocked is only networked for prop_door_rotating
local DOOR_NAME_SLOT = 3 -- :GetName() is not available clientside so we network the names
function SlashCo.IsDoorLocked(ent)
	if CLIENT and ent:GetClass() == "func_door_rotating" then
		return ent:GetDTBool(DOOR_LOCK_SLOT)
	end

	return ent:GetInternalVariable("m_bLocked")
end

function SlashCo.GetDoorName(ent)
	if not SlashCo.IsValidDoor(ent) then return end

	return ent:GetDTString(DOOR_NAME_SLOT)
end

function SlashCo.IsDoorOpen(ent)
	local class = ent:GetClass()
	if class ~= "prop_door_rotating" then
		if class ~= "func_door_rotating" then
			return false
		end

		if CLIENT then
			-- Gmod does not give access to m_toggle_state? (BUG?)
			--return ent:GetInternalVariable("m_toggle_state") ~= doorStates.DOOR_STATE_CLOSED
			return ent:GetDTBool(DOOR_NETWORK_SLOT)
		end
		-- For server we fall through down where it will use ent.IsOpen
	end

	if CLIENT then
		-- m_eDoorState is networked by the engine :)
		return ent:GetInternalVariable("m_eDoorState") ~= doorStates.DOOR_STATE_CLOSED
	else
		return ent.IsOpen or false
	end
end

-- RaphaelIT7: We prevent door slam on locked doors due to them else completely breaking somehow
function SlashCo.GetSlammableDoor(ent)
	local door = SlashCo.GetValidDoor(ent)
	if not door or SlashCo.IsDoorOpen(door) or SlashCo.IsDoorLocked(door) then
		return nil
	end

	return door
end

function SlashCo.PlayDoorSlamSound(door, excludeSendTo)
	SlashCo.AudioSystem.PlaySound({
		soundPath = "ambient/materials/door_hit1.wav",
		identifier = "DoorSlam",
		entity = door,
		soundLevel = 80,
		volume = 1,
		fadeIn = 0,
		deleteWhenDone = true,
		excludeSendTo = excludeSendTo,
	})
end

--Door Ramming
hook.Add("KeyPress", "SlashCo:DoorRamming", function(ply, button)
	if button ~= IN_ATTACK then
		return
	end

	local team = ply:Team()
	if team ~= TEAM_SURVIVOR and team ~= TEAM_LOBBY then
		return
	end

	if ply:GetVelocity():Length() <= 250 then
		return
	end

	local lookent = ply:GetEyeTrace().Entity
	if not IsValid(lookent) or lookent:GetPos():Distance(ply:GetPos()) > 120 then
		return
	end

	-- RaphaelIT7: We can't really predict the door opening...
	if SERVER then
		if not ply:SlamDoor(lookent, true) then
			return
		end
	else
		local door = SlashCo.GetSlammableDoor(lookent)
		if not door then
			return
		end

		local name = SlashCo.GetDoorName(door)
		if not IsFirstTimePredicted() then
			local doorInfo = GameData.PredictedDoorSlam[name]
			if doorInfo then
				doorInfo._time = UnPredictedCurTime() + 0.5
			end

			return
		end

		SlashCo.PlayDoorSlamSound(door)

		local modifiedDoors = {
			_time = UnPredictedCurTime() + 0.5,
			_hitdoor = door,
		}
		local pos = door:GetPos()
		for _, v in ipairs(ents.FindInSphere(door:WorldSpaceCenter(), 100)) do
			if SlashCo.GetDoorName(v) == name then
				v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				v.PredictedDoorSlam = true
				table.insert(modifiedDoors, v)
			end
		end

		GameData.PredictedDoorSlam[name] = modifiedDoors
	end
	
	-- RaphaelIT7: They cause prediction errors since we got no good way of predicting them yet (they do nothing clientside)
	--[[ply:SetViewPunchAngles(Angle(7, 0, 0))
	timer.Simple(0.2, function()
		if not IsValid(ply) then return end

		ply:SetViewPunchAngles(Angle(-15, 0, 0))
	end)]]
end)

if CLIENT then
	-- RaphaelIT7 (ToDo): This is wacky, originally I wanted to use the tick count but predicting that properly sucked
	GameData.PredictedDoorSlam = GameData.PredictedDoorSlam or {}
	hook.Add("Tick", "SlashCo:DoorSlam", function()
		local time = CurTime()
		for name, doors in pairs(GameData.PredictedDoorSlam) do
			if time < doors._time then continue end

			-- RaphaelIT7: Since we got no idea if our time even is right, we always check the door state to know the truth
			if IsValid(doors._hitdoor) and not SlashCo.IsDoorOpen(doors._hitdoor) then return end

			for _, door in ipairs(doors) do
				if IsValid(door) then
					door:SetCollisionGroup(COLLISION_GROUP_NONE)
					door.PredictedDoorSlam = nil
				end
			end

			GameData.PredictedDoorSlam[name] = nil
		end
	end)
end

if CLIENT then return end
-- Server only functions

local function SetDoorLocked(door, state)
	door:SetDTBool(DOOR_LOCK_SLOT, state)
end

hook.Add("AcceptInput", "SlashCo:DoorLock", function(ent, input)
	if ent:GetClass() ~= "func_door_rotating" then
		return
	end

	input = string.lower(input)
	if input == "lock" then
		SetDoorLocked(ent, true)
	elseif input == "unlock" then
		SetDoorLocked(ent, false)
	end
end)

local function DoorBreakRng(door)
	door.OpenCount = (door.OpenCount or 0) + 1

	if math.random(1, 200 - door.OpenCount) == 1 then
		SlashCo.BustDoor(door, door, 200)
	end
end

local function OnDoorStateChanged(door, state)
	door.IsOpen = state

	if door:GetClass() == "func_door_rotating" then
		door:SetDTBool(DOOR_NETWORK_SLOT, state) -- RaphaelIT7: We use DT for this
	end

	if state then
		DoorBreakRng(door)
	end
end

local function SetDoorName(door)
	door:SetDTString(DOOR_NAME_SLOT, door:GetName())
end

--initialize door state listener
local function SetupMapLua()
	local mapLua = ents.Create("lua_run")
	mapLua:SetName("triggerhook")
	mapLua:Spawn()
	mapLua:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

	for _, ent in ipairs(ents.FindByClass("func_door_rotating")) do
		SetDoorName(ent)
		SetDoorLocked(ent, ent:GetInternalVariable("m_bLocked"))
	end

	for _, ent in ipairs(ents.FindByClass("prop_door_rotating")) do
		SetDoorName(ent)
		OnDoorStateChanged(ent, ent:GetInternalVariable("m_eDoorState") ~= doorStates.DOOR_STATE_CLOSED)

		-- RaphaelIT7: GMod Bug! We cannot use SlashCo: as : is parsed as next argument...
		ent:Fire("AddOutput", "OnOpen triggerhook:RunPassedCode:hook.Run( 'SlashCo_DoorOpen' ):0:-1")
		ent:Fire("AddOutput", "OnClose triggerhook:RunPassedCode:hook.Run( 'SlashCo_DoorClose' ):0:-1")
	end
end

hook.Add("InitPostEntity", "SlashCo:SetupMapLua", SetupMapLua)

hook.Add("PlayerUse", "SlashCo:Doors", function(ply, ent)
	if not SlashCo.IsValidDoor(ent) then return end

	if (ent.NextDoorUse or 0) > CurTime() then
		return false -- Block use
	end

	ent.NextDoorUse = CurTime() + 0.2
end)

hook.Add("SlashCo_DoorOpen", "SlashCo:Doors", function()
	OnDoorStateChanged(CALLER, true)
end)

hook.Add("SlashCo_DoorClose", "SlashCo:Doors", function()
	OnDoorStateChanged(CALLER, false)
end)