local function survivorButtons(ply, button)
	if ply:GetNWBool("Taunt_MNR") or ply:GetNWBool("Taunt_Griddy") or ply:GetNWBool("Taunt_Cali") then
		ply:SetNWBool("Taunt_MNR", false)
		if button ~= KEY_W then
			ply:SetNWBool("Taunt_Griddy", false)
			ply:SetNWBool("Taunt_Cali", false)
		end
	end
	if button == KEY_R then
		SlashCo.UseItem(ply)
		return
	end --Using their Item
	if button == KEY_Q then
		SlashCo.DropItem(ply)
		return
	end --Dropping their Item
	if button == MOUSE_MIDDLE then
		ply:SurvivorPing()
		return
	end
	if button == KEY_1 then
		if ply.LastTaunt and CurTime() - ply.LastTaunt < 2 then
			return
		end
		ply.LastTaunt = CurTime()

		ply:SetNWBool("Taunt_MNR", true) --Monday Night
		ply:SetNWBool("Taunt_Griddy", false)
		ply:SetNWBool("Taunt_Cali", false)
		ply:EmitSound("slashco/ping_item.mp3", SNDLVL_45dB, 80, 0.4)
		return
	end
	if button == KEY_2 then
		if ply.LastTaunt and CurTime() - ply.LastTaunt < 2 then
			return
		end
		ply.LastTaunt = CurTime()

		ply:SetNWBool("Taunt_Griddy", true) --Hittin the griddy
		ply:SetNWBool("Taunt_MNR", false)
		ply:SetNWBool("Taunt_Cali", false)
		ply:EmitSound("slashco/ping_item.mp3", SNDLVL_45dB, 80, 0.4)
		return
	end
	if button == KEY_3 then
		if ply.LastTaunt and CurTime() - ply.LastTaunt < 2 then
			return
		end
		ply.LastTaunt = CurTime()

		ply:SetNWBool("Taunt_Cali", true) --California girls
		ply:SetNWBool("Taunt_Griddy", false)
		ply:SetNWBool("Taunt_MNR", false)
		ply:EmitSound("slashco/ping_item.mp3", SNDLVL_45dB, 80, 0.4)
		return
	end
end

--Door Ramming
hook.Add("PlayerButtonDown", "SurvivorFunctions", function(ply, button)
	if ply:Team() ~= TEAM_SURVIVOR then
		return
	end

	survivorButtons(ply, button)

	if game.GetMap() == "sc_lobby" then
		return
	end

	--Covenant Tackle
	if ply:GetNWBool("SurvivorTackled") then
		if button == KEY_D or button == KEY_A and ply.LastTackleStruggleKey ~= button then
			ply.LastTackleStruggleKey = button
			ply.TackleStruggle = ply.TackleStruggle or 0
			ply.TackleStruggle = ply.TackleStruggle + 1
		end
	end

	local lookent = ply:GetEyeTrace().Entity

	if button ~= MOUSE_FIRST or ply:GetVelocity():Length() <= 250 then
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

function PLAYER:SurvivorPing()
	if self.LastPinged and CurTime() - self.LastPinged < 3 then
		return
	end
	self.LastPinged = CurTime()

	self:LagCompensation(true)
	local trace = self:GetEyeTrace()
	self:LagCompensation(false)

	local look
	local ping_info = {
		ExpiryTime = 0
	}

	ping_info.Player = self

	if self:Team() == TEAM_SPECTATOR then
		ping_info.Type = "GHOST"
		look = trace.HitPos
		ping_info.ExpiryTime = 5
		ping_info.Player = nil
	elseif self:GetNWBool("SurvivorBenadrylFull") then
		ping_info.Type = "SLASHER"
		look = trace.HitPos
		ping_info.ExpiryTime = 5
	elseif not IsValid(trace.Entity) then
		look = trace.HitPos
		ping_info.Type = "LOOK HERE"
		ping_info.ExpiryTime = 10
	else
		look = trace.Entity

		if look.PingType then
			ping_info.Type = look.PingType
		elseif look:GetModel() == "models/ldi/basketball.mdl" then
			ping_info.Type = "BASKETBALL"
			ping_info.ExpiryTime = 15
		elseif look:IsPlayer() then
			if look:Team() == TEAM_SURVIVOR then
				ping_info.Type = "SURVIVOR"
				ping_info.SurvivorName = string.upper(look:Nick())
				look = trace.HitPos
				ping_info.ExpiryTime = 5
			elseif look:Team() == TEAM_SLASHER then
				if not look:GetNWBool("AmogusSurvivorDisguise") then
					ping_info.Type = "SLASHER"
					look = trace.HitPos
					ping_info.ExpiryTime = 5
				else
					ping_info.Type = "SURVIVOR"
					ping_info.SurvivorName = string.upper(table.Random(team.GetPlayers(TEAM_SURVIVOR)):Nick())
					look = trace.HitPos
					ping_info.ExpiryTime = 5
				end
			end
		else
			ping_info.Type = "LOOK AT THIS"
			ping_info.ExpiryTime = 10
		end
	end

	if ping_info.Type == "DEAD BODY" then
		local deadguy = player.GetBySteamID64(look.SurvivorSteamID)
		if IsValid(deadguy) then
			deadguy:SetNWBool("ConfirmedDead", true)
		end
	end

	if typeCheck[ping_info.Type] then
		sayPrompt(self, typeCheck[ping_info.Type])
	elseif ping_info.Type == "ITEM" and type(look) == "Entity" then
		local class = look:GetClass()
		for _, v in pairs(SlashCoItems) do
			local input = v.EntClass
			if not input then
				continue
			end
			if v.EntClass == class then
				sayPrompt(self, string.sub(input, 4))
				ping_info.Name = v.Name
				break
			end
		end
	end

	ping_info.Entity = look
	net.Start("mantislashcoSurvivorPings")
	net.WriteTable(ping_info)
	local players = team.GetPlayers(TEAM_SURVIVOR)
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

	door_ent:EmitSound("ambient/materials/door_hit1.wav", 80)

	local pos = self:GetPos()
	local name = door_ent:GetName()
	slamDoor(door_ent, pos)
	for _, v in ipairs(ents.FindInSphere(door_ent:WorldSpaceCenter(), 150)) do
		if v:GetName() == name then
			slamDoor(v, pos)
		end
	end

	return true
end

function sayPrompt(ply, input)
	if game.GetMap() == "sc_lobby" and SlashCo.LobbyData.LOBBYSTATE == 2 then
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
		if IsValid( door_ent ) then
			door_ent:Fire("SetSpeed", oldSpeed) --100
			door_ent:SetKeyValue("opendir", "0")
		end
	end)
end