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

	--Covenant Tackle
	if ply:GetNWBool("SurvivorTackled") then
		if button == IN_MOVERIGHT or button == IN_MOVELEFT and ply.LastTackleStruggleKey ~= button then
			ply.LastTackleStruggleKey = button
			ply.TackleStruggle = (ply.TackleStruggle or 0) + 1
		end

		return
	end

	local lookent = ply:GetEyeTrace().Entity

	if button ~= IN_ATTACK or ply:GetVelocity():Length() <= 250 then
		return
	end

	if lookent:GetPos():Distance(ply:GetPos()) > 120 then
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

local PLAYER = FindMetaTable("Player")
local slamDoor, typeCheck, sayPrompt

GameData.ActivePings = GameData.ActivePings or {}
GameData.NextPingID = GameData.NextPingID or 0
local function shouldRemovePing(curTime, mustClear, idx, pingInfo, newPing)
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

	-- We remove every ping that is above 100 (oldest first) to avoid network overflows
	if mustClear and idx < (count - 100) then
		return true
	end

	if pingInfo.ExpiryTime and curTime > pingInfo.ExpiryTime then
		return true
	end

	return false
end

local function clearDeadPings(newPing) -- newPing if there is one to avoid duplicates
	local curTime = CurTime()
	local count = #GameData.ActivePings
	local mustClear = count > 100
	local idx = 0
	while idx <= #GameData.ActivePings do
		idx = idx + 1
		local pingInfo = GameData.ActivePings[idx]
		if not pingInfo then break end

		if shouldRemovePing(curTime, mustClear, idx, pingInfo, newPing) then
			table.remove(GameData.ActivePings, idx)
			idx = idx - 1 -- table.remove shifted all entries! so we must check the same index again!
		end
	end
end

-- We ONLY want to call this when a player joins into an active round!
function SlashCo.NetworkPings(ply)
	clearDeadPings()
	local maxCount = math.Clamp(#GameData.ActivePings, 0, 127)
	net.Start("SlashCo:SurvivorPings")
		net.WriteBool(true) -- this is a full update of all active pings
		net.WriteUInt(maxCount, 7)
		for idx, pingInfo in ipairs(GameData.ActivePings) do
			if idx > maxCount then break end

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

function PLAYER:SurvivorPing()
	if self.LastPinged and CurTime() - self.LastPinged < 3 then
		return
	end
	self.LastPinged = CurTime()

	self:LagCompensation(true)
	local trace = self:GetEyeTrace()
	self:LagCompensation(false)

	GameData.NextPingID = GameData.NextPingID + 1
	local pingInfo = {
		ID = GameData.NextPingID,
		ExpiryTime = 0, -- Time in seconds!
		Team = self:Team(), -- Idea: Allow slasher's to ping too
	}

	pingInfo.Player = self

	if pingInfo.Team == TEAM_SPECTATOR then
		pingInfo.Type = "GHOST"
		pingInfo.Position = trace.HitPos
		pingInfo.ExpiryTime = 5
		pingInfo.Player = nil
	elseif self:GetNWBool("SurvivorBenadrylFull") then
		pingInfo.Type = "SLASHER"
		pingInfo.Position = trace.HitPos
		pingInfo.ExpiryTime = 5
	elseif not IsValid(trace.Entity) then
		pingInfo.Position = trace.HitPos
		pingInfo.Type = "LOOK HERE"
		pingInfo.ExpiryTime = 10
	else
		local look = trace.Entity
		if look.PingType then
			pingInfo.Entity = look
			pingInfo.Type = look.PingType
			if look.PingExpiryTime then
				pingInfo.ExpiryTime = look.PingExpiryTime
			end

			if look.OnPing then
				-- RaphaelIT7: ToDo (Idea) - we can give a reward to the first survivor who found a generator
				look:OnPing(self)
			end
		elseif look:GetModel() == "models/ldi/basketball.mdl" then
			pingInfo.Type = "BASKETBALL"
			pingInfo.ExpiryTime = 15
		elseif look:IsPlayer() then
			if look:Team() == TEAM_SURVIVOR then
				pingInfo.Type = "SURVIVOR"
				pingInfo.SurvivorName = string.upper(look:Nick())
				pingInfo.Position = trace.HitPos
				pingInfo.ExpiryTime = 5
			elseif look:Team() == TEAM_SLASHER then
				if not look:GetNWBool("AmogusSurvivorDisguise") then
					pingInfo.Type = "SLASHER"
					pingInfo.Position = trace.HitPos
					pingInfo.ExpiryTime = 5
				else
					pingInfo.Type = "SURVIVOR"
					pingInfo.SurvivorName = string.upper(table.Random(team.GetPlayers(TEAM_SURVIVOR)):Nick())
					pingInfo.Position = trace.HitPos
					pingInfo.ExpiryTime = 5
				end
			end
		else
			pingInfo.Type = "LOOK AT THIS"
			pingInfo.ExpiryTime = 10
		end
	end

	if pingInfo.ExpiryTime and pingInfo.ExpiryTime == -1 then
		pingInfo.ExpiryTime = nil
		pingInfo.Permanent = true -- Permanent pings always remain!
	end

	if pingInfo.Type == "DEAD BODY" and pingInfo.Entity then
		local deadguy = player.GetBySteamID64(pingInfo.Entity.SurvivorSteamID)
		if IsValid(deadguy) then
			deadguy:SetNWBool("ConfirmedDead", true)
		end
	end

	if pingInfo.Team == TEAM_SURVIVOR then
		if typeCheck[pingInfo.Type] then
			sayPrompt(self, typeCheck[pingInfo.Type])
		elseif pingInfo.Type == "ITEM" and pingInfo.Entity then
			local class = pingInfo.Entity:GetClass()
			for _, v in pairs(SlashCoItems) do
				local input = v.EntClass
				if not input then
					continue
				end

				if v.EntClass == class then
					sayPrompt(self, string.sub(input, 4))
					pingInfo.Name = v.Name
					break
				end
			end
		end
	end

	if pingInfo.ExpiryTime then
		if pingInfo.ExpiryTime ~= 0 then
			pingInfo.ExpiryTime = CurTime() + pingInfo.ExpiryTime
		else
			pingInfo.ExpiryTime = nil
		end
	end

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

		local players = team.GetPlayers(pingInfo.Team == TEAM_SPECTATOR and TEAM_SURVIVOR or pingInfo.Team)
		table.Add(players, team.GetPlayers(TEAM_SPECTATOR))
	net.Send(players)
end

function PLAYER:SlamDoor(door_ent)
	if door_ent:GetClass() ~= "prop_door_rotating" then
		return
	end

	if door_ent.IsOpen then
		return
	end

	if not SlashCo.CheckDoorWL(door_ent) then
		return
	end

	if door_ent:GetInternalVariable("m_flSpeed") > 500 then
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

function sayPrompt(ply, input)
	if GameData.IsLobby and SlashCo.LobbyData.LOBBYSTATE == 2 then
		return
	end

	ply:EmitSound("slashco/survivor/voice/prompt_" .. input .. math.random(1, 3) .. ".mp3")
end

typeCheck = {
	["LOOK HERE"] = "look",
	["LOOK AT THIS"] = "look",
	["HELICOPTER"] = "helicopter",
	["GENERATOR"] = "generator",
	["PLUSH DOG"] = "dogg",
	["BASKETBALL"] = "ballin",
	["DEAD BODY"] = "deadbody",
	["SLASHER"] = "slasher"
}

function slamDoor(door_ent, pos)
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