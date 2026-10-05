local function survivorButtons(ply, button)
	if ply:GetNWBool("Taunt_MNR") or ply:GetNWBool("Taunt_Griddy") or ply:GetNWBool("Taunt_Cali") then
		ply:SetNWBool("Taunt_MNR", false)
		if button ~= KEY_W then
			ply:SetNWBool("Taunt_Griddy", false)
			ply:SetNWBool("Taunt_Cali", false)
		end
	end

	if SlashCo.IsKeyPressed("USE_ITEM", ply, button) then
		SlashCo.UseItem(ply)
		return
	end --Using their Item

	if SlashCo.IsKeyPressed("DROP_ITEM", ply, button) then
		SlashCo.DropItem(ply)
		return
	end --Dropping their Item

	if SlashCo.IsKeyPressed("PING", ply, button) then
		ply:SurvivorPing()
		return
	end

	if SlashCo.IsKeyPressed("TAUNT_MN", ply, button) then
		if ply.LastTaunt and CurTime() - ply.LastTaunt < 2 then
			return
		end
		ply.LastTaunt = CurTime()

		ply:SetNWBool("Taunt_MNR", true) --Monday Night
		ply:SetNWBool("Taunt_Griddy", false)
		ply:SetNWBool("Taunt_Cali", false)
		ply:EmitSound("slashco/ping_item.mp3", 0, 80, 0.4)
		return
	end

	if SlashCo.IsKeyPressed("TAUNT_HTG", ply, button) then
		if ply.LastTaunt and CurTime() - ply.LastTaunt < 2 then
			return
		end
		ply.LastTaunt = CurTime()

		ply:SetNWBool("Taunt_Griddy", true) --Hittin the griddy
		ply:SetNWBool("Taunt_MNR", false)
		ply:SetNWBool("Taunt_Cali", false)
		ply:EmitSound("slashco/ping_item.mp3", 0, 80, 0.4)
		return
	end

	if SlashCo.IsKeyPressed("TAUNT_CG", ply, button) then
		if ply.LastTaunt and CurTime() - ply.LastTaunt < 2 then
			return
		end
		ply.LastTaunt = CurTime()

		ply:SetNWBool("Taunt_Cali", true) --California girls
		ply:SetNWBool("Taunt_Griddy", false)
		ply:SetNWBool("Taunt_MNR", false)
		ply:EmitSound("slashco/ping_item.mp3", 0, 80, 0.4)
		return
	end
end

hook.Add("PlayerButtonDown", "SlashCo:SurvivorFunctions", function(ply, button)
	local team = ply:Team()
	if team ~= TEAM_SURVIVOR and team ~= TEAM_LOBBY then
		return
	end

	survivorButtons(ply, button)
end)

--Door Ramming
hook.Add("KeyPress", "SlashCo:SurvivorFunctions", function(ply, button)
	local team = ply:Team()
	if team ~= TEAM_SURVIVOR and team ~= TEAM_LOBBY then
		return
	end

	local lookent = ply:GetEyeTrace().Entity

	if button ~= IN_ATTACK or ply:GetVelocity():Length() <= 250 then
		return
	end

	if not IsValid(lookent) or lookent:GetPos():Distance(ply:GetPos()) > 120 then
		return
	end

	if ply:SlamDoor(lookent) then
		ply:ViewPunch(Angle(7, 0, 0))
		timer.Simple(0.2, function()
			if not IsValid(ply) then
				return
			end

			ply:ViewPunch(Angle(-15, 0, 0))
		end)
	end
end)

hook.Add("KeyPress", "SlashCo:SurvivorStruggles", function(ply, key)
	local team = ply:Team()
	if team ~= TEAM_SURVIVOR then
		return
	end

	--Covenant Tackle
	if ply:GetNWBool("SurvivorTackled") then
		if key == 11 or key == 14 then
			if ply.LastTackleStruggleKey ~= key then
				ply.LastTackleStruggleKey = key
				ply.TackleStruggle = (ply.TackleStruggle or 0) + 1
			end
		end

		return
	end

	--Hoovydundy RopeGrab
	if ply:GetNWBool("SurvivorGrabbed") then
		if key == 11 or key == 14 then
			if ply.LastRopeStruggleKey ~= key then
				ply.LastRopeStruggleKey = key
				ply.RopeStruggle = (ply.RopeStruggle or 0) + 1
			end
		end

		return
	end

	--Princess drag
	if ply:GetNWBool("SurvivorDragged") then
		if key == 11 or key == 14 then
			if ply.LastDragStruggleKey ~= key then
				ply.LastDragStruggleKey = key
				ply.DragStruggle = (ply.DragStruggle or 0) + 1
			end
		end

		return
	end
end)

local PLAYER = FindMetaTable("Player")

GameData.ActivePings = GameData.ActivePings or {}
GameData.NextPingID = GameData.NextPingID or 0
local MaxPings = 100
local function shouldRemovePing(curTime, pingInfo, newPing)
	if newPing then
		-- IMPORTANT: This part MUST stay synchronized with the cl_pings.lua -> shouldRemovePing function! else the client may remove a ping when they shouldn't!

		if not pingInfo.Permanent and pingInfo.Player == newPing.Player then
			return true
		end

		-- We allow the same entity to be pinged multiple times if it's by different teams!
		if pingInfo.Entity and pingInfo.Entity == newPing.Entity and pingInfo.Team == newPing.Team then
			return true
		end
	end

	if pingInfo.Entity and not IsValid(pingInfo.Entity) then
		return true
	end

	if pingInfo.Player and not IsValid(pingInfo.Player) then
		if pingInfo.Permanent then
			pingInfo.Player = nil -- They shall remain
			return false
		else
			return true
		end
	end

	if pingInfo.Permanent then return false end

	if pingInfo.ExpiryTime and curTime > pingInfo.ExpiryTime then
		return true
	end

	return false
end

local function clearDeadPings(newPing) -- newPing if there is one to avoid duplicates
	local curTime = CurTime()
	local idx = 0
	while idx <= #GameData.ActivePings do
		idx = idx + 1
		local pingInfo = GameData.ActivePings[idx]
		if not pingInfo then break end

		if shouldRemovePing(curTime, pingInfo, newPing) then
			table.remove(GameData.ActivePings, idx)
			idx = idx - 1 -- table.remove shifted all entries! so we must check the same index again!
		end
	end

	local excess = #GameData.ActivePings - MaxPings
	idx = 1
	while excess > 0 and idx <= #GameData.ActivePings do
		if GameData.ActivePings[idx].Permanent then
			idx = idx + 1
		else
			table.remove(GameData.ActivePings, idx)
			excess = excess - 1
		end
	end
end

-- We ONLY want to call this when a player joins into an active round!
function SlashCo.NetworkPings(ply, targetTeam)
	targetTeam = targetTeam or ply:Team()

	clearDeadPings()

	local pings = {}
	for _, pingInfo in ipairs(GameData.ActivePings) do
		if #pings >= 127 then break end
		if not SlashCo.CanSeePing(targetTeam, pingInfo.Team) then continue end

		table.insert(pings, pingInfo)
	end

	net.Start("SlashCo:SurvivorPings")
		net.WriteBool(true) -- this is a full update of all active pings
		net.WriteUInt(#pings, 7)
		for _, pingInfo in ipairs(pings) do
			net.WriteUInt(pingInfo.ID, 16)
			SlashCo.WriteOptional(pingInfo.ExpiryTime, net.WriteFloat)
			net.WriteUInt(pingInfo.Team, 10)
			net.WriteString(pingInfo.Type)
			SlashCo.WriteOptional(pingInfo.Name, net.WriteString)
			SlashCo.WriteOptional(pingInfo.Player, net.WriteEntity)
			SlashCo.WriteOptional(pingInfo.Entity, net.WriteEntity)
			SlashCo.WriteOptional(pingInfo.Position, net.WriteVector)
		end
	net.Send(ply)
end

-- RaphaelIT7: Should only be called from PLAYER:SurvivorPing!
function PLAYER:SurvivorPing_SV(pingInfo, tickCount)
	GameData.NextPingID = GameData.NextPingID + 1

	pingInfo.ID = GameData.NextPingID
	
	clearDeadPings(pingInfo)
	table.insert(GameData.ActivePings, pingInfo)

	net.Start("SlashCo:SurvivorPings")
		net.WriteBool(false) -- not a full update
		net.WriteUInt(1, 7) -- count of pings
		net.WriteUInt(pingInfo.ID, 16)
		SlashCo.WriteOptional(pingInfo.ExpiryTime, net.WriteFloat)
		net.WriteUInt(pingInfo.Team, 10)
		net.WriteString(pingInfo.Type)
		SlashCo.WriteOptional(pingInfo.Name, net.WriteString)
		SlashCo.WriteOptional(pingInfo.Player, net.WriteEntity)
		SlashCo.WriteOptional(pingInfo.Entity, net.WriteEntity)
		SlashCo.WriteOptional(pingInfo.Position, net.WriteVector)
		net.WriteUInt(tickCount, 32)

		local players = {}
		for _, ply in player.Iterator() do
			if not SlashCo.CanSeePing(ply:Team(), pingInfo.Team) then continue end

			table.insert(players, ply)
		end

	net.Send(players)
end

local function slamDoor(door_ent, pos)
	local localpos = door_ent:WorldToLocal(pos)
	if localpos.x < 0 then
		door_ent:SetKeyValue("opendir", "1")
	else
		door_ent:SetKeyValue("opendir", "2")
	end

	local oldSpeed = door_ent:GetInternalVariable("m_flSpeed")

	door_ent:Fire("SetSpeed", 1000)
	door_ent:Fire("Open")
	timer.Simple(0.1, function()
		if IsValid( door_ent ) then
			door_ent:Fire("SetSpeed", 1)
			door_ent:Fire("Open")
		end
	end)

	for i = 1, 10 do
		timer.Simple(i / 8, function()
			if IsValid( door_ent ) then
				door_ent:Fire("Open")
			end
		end)
	end

	timer.Simple(0.5, function()
		if IsValid(door_ent) then
			door_ent:Fire("SetSpeed", oldSpeed) --100
			door_ent:SetKeyValue("opendir", "0")
		end
	end)
end

function PLAYER:SlamDoor(door_ent)
	door_ent = SlashCo.GetValidDoor(door_ent)
	if not door_ent then return end

	if SlashCo.IsDoorOpen(door_ent) then
		return
	end

	-- RaphaelIT7: We prevent door slam on locked doors due to them else completely breaking somehow
	if door_ent:GetInternalVariable("m_bLocked") then
		return
	end

	door_ent:EmitSound("ambient/materials/door_hit1.wav", 80)

	local pos = self:GetPos()
	local name = door_ent:GetName()
	slamDoor(door_ent, pos)
	for _, v in ipairs(ents.FindInSphere(door_ent:WorldSpaceCenter(), 100)) do
		if v:GetName() == name then
			slamDoor(v, pos)
		end
	end

	return true
end