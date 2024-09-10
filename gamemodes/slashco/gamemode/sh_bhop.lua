local max = CreateConVar("slashco_max_bhop_speed", 1, FCVAR_REPLICATED, "Max bhop speed, multiple of max run speed", -9999, 9999)

local function limitSpeed(ply, data)
	if not ply:IsOnGround() or not ply:KeyPressed(IN_JUMP) then
		return
	end

	local baseSpeed = ply:GetRunSpeed() * max:GetFloat()
	local curSpeed = data:GetVelocity():Length()

	if curSpeed > baseSpeed then
		data:SetVelocity((data:GetVelocity() * baseSpeed) / curSpeed)
	end
end

if SERVER then
	hook.Add("SetupMove", "RestrictBhopping", limitSpeed)
else
	hook.Add("Move", "RestrictBhopping", limitSpeed)

	function bhop(cmd)
		if max:GetFloat() >= 0 and max:GetFloat() <= 1 then
			return
		end

		local lply = LocalPlayer()
		if not IsValid(lply) then return end
		if not lply:Alive() then return end

		if bit.band(cmd:GetButtons(), IN_JUMP) == 2 and lply:GetMoveType() ~= MOVETYPE_NOCLIP and lply:WaterLevel() <= 1 and not lply:OnGround() then
			cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
		end
	end

	hook.Add("CreateMove", "AutoBhop", bhop)
end