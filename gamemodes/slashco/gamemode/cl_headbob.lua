--local HBAP = 0
local HBPitchPost = 0
local HBRoll = 0
local HBRollPost = 0
local HBPosZ = 0
local add = 0
local PitchReset = false

local noHeadbob = CreateClientConVar("slashco_disable_headbob", 0, true, false, "Disable camera bobbing effect for survivors.", 0, 1)
function HeadBob(pl, pos, ang, fov)
	if pl:Team() ~= TEAM_SURVIVOR or pl:GetNWBool("SurvivorSidExecution") then return end
	if noHeadbob:GetBool() then return end

	local velCoef = pl:GetVelocity():Length() / 300
	local v = {}
	v.pos = pos
	v.ang = ang
	v.fov = fov

	if pl:IsOnGround() then
		if pl:KeyDown(IN_FORWARD) or pl:KeyDown(IN_BACK) or pl:KeyDown(IN_MOVELEFT) or pl:KeyDown(IN_MOVERIGHT) then
			HBPosZ = HBPosZ + (pl:GetVelocity():Length() / 17) * FrameTime()
			PitchReset = false

			HBPitch = (HBPitch or 0) + (pl:GetVelocity():Length() / 17) * FrameTime() --/17
			HBRoll = (HBRoll or 0) + (pl:GetVelocity():Length() / 25) * FrameTime() --/25
			HBPitchPost = math.sin(HBPitch) * 0.25 * velCoef
			HBRollPost = math.cos(HBRoll) * 0.15 * velCoef
			v.ang.pitch = v.ang.pitch + HBPitchPost
			v.ang.roll = v.ang.roll + HBRollPost
		else --Reset view pitch
			if not PitchReset then
				HBPitch = HBPitchPost
				HBRoll = HBRollPost
				PitchReset = true
			end

			HBPitch = Lerp(0.01, HBPitch, 0)
			HBRoll = Lerp(0.01, HBRoll, 0)
			v.ang.pitch = v.ang.pitch + HBPitch
			v.ang.roll = v.ang.roll + HBRoll
		end

		if pl:KeyDown(IN_MOVELEFT) then
			add = Lerp(0.01, add, -7 * velCoef)
		else
			add = Lerp(0.01, add, 0)
		end

		if pl:KeyDown(IN_MOVERIGHT) then
			add = Lerp(0.01, add, 7 * velCoef)
		else
			add = Lerp(0.01, add, 0)
		end
	end

	pl.OLDANG = v.ang
	pl.OLDPOS = v.pos
	v.pos.z = v.pos.z - math.cos(HBPosZ) * (pl:GetVelocity():Length() / 1000)
	v.ang.roll = v.ang.roll + add

	return GAMEMODE:CalcView(pl, v.pos, v.ang, v.fov)
end
hook.Add("CalcView", "octoSlashCoCalcViewHeadBob", HeadBob)