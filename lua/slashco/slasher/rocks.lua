local SLASHER = {}

SLASHER.Name = "Rocks"
SLASHER.ID = "rocks"
SLASHER.Class = 1
SLASHER.DangerLevel = 1
SLASHER.IsSelectable = false
SLASHER.Model = "models/slashco/slashers/covenant/rocks.mdl"
SLASHER.GasCanMod = 0
SLASHER.KillDelay = 3
SLASHER.ProwlSpeed = 150
SLASHER.ChaseSpeed = 297
SLASHER.Perception = 1.0
SLASHER.Eyesight = 3
SLASHER.KillDistance = 135
SLASHER.ChaseRange = 1000
SLASHER.ChaseRadius = 0.7
SLASHER.ChaseDuration = 160.0
SLASHER.ChaseCooldown = 1
SLASHER.JumpscareDuration = 1.5
SLASHER.ChaseMusic = ""
SLASHER.KillSound = ""
SLASHER.Description = ""
SLASHER.ProTip = ""
SLASHER.SpeedRating = "★★★★★"
SLASHER.EyeRating = "★★☆☆☆"
SLASHER.DiffRating = "★★★☆☆"

SLASHER.OnSpawn = function(slasher)
end

SLASHER.OnTickBehaviour = function(slasher)
	slasher:SetNWFloat("Slasher_Eyesight", SLASHER.Eyesight)
	slasher:SetNWInt("Slasher_Perception", SLASHER.Perception)
end

SLASHER.OnPrimaryFire = function(slasher, target)
	--SlashCo.Jumpscare(slasher, target)
end

SLASHER.OnSecondaryFire = function(slasher)
	--SlashCo.StartChaseMode(slasher)
end

SLASHER.OnMainAbilityFire = function(slasher)
end

SLASHER.OnSpecialAbilityFire = function(slasher)
end

SLASHER.Animator = function(ply)
	local chase = ply:GetNWBool("InSlasherChaseMode")

	if ply:IsOnGround() then
		if not chase then
			ply.CalcIdeal = ACT_HL2MP_WALK
			ply.CalcSeqOverride = ply:LookupSequence("prowl")
		else
			ply.CalcIdeal = ACT_HL2MP_RUN
			ply.CalcSeqOverride = ply:LookupSequence("chase")
		end
	else
		ply.CalcSeqOverride = ply:LookupSequence("float")
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

SLASHER.Footstep = function()
	return true
end

SlashCo.RegisterSlasher(SLASHER, "Rocks")