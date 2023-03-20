AddCSLuaFile()
AddCSLuaFile("bababooey.lua")

if not SlashCoSlasher then SlashCoSlasher = {} end

include("bababooey.lua")

function TranslateSlasherClass(id)

    if id == 0 then return "Unknown" end
    if id == 1 then return "Cryptid" end
    if id == 2 then return "Demon" end
    if id == 3 then return "Umbra" end

end

function TranslateDangerLevel(id)

    if id == 0 then return "Unknown" end
    if id == 1 then return "Moderate" end
    if id == 2 then return "Considerable" end
    if id == 3 then return "Devastating" end

end

function GetRandomSlasher()

    local keys = table.GetKeys( SlashCoSlasher )
	local rand = math.random( 1, #keys)
	local rand_name = keys[rand] --random id for this roll

    return rand_name

end

--Slasher Animation Controller
hook.Add("CalcMainActivity", "SlasherAnimator", function(ply, _)

	if ply:Team() ~= TEAM_SLASHER then
		return
	end

    if type( SlashCoSlasher[ply:GetNWString("Slasher")].Animator ) ~= "function" then return end

	ply.CalcIdeal, ply.CalcSeqOverride = SlashCoSlasher[ply:GetNWString("Slasher")].Animator(ply)

   	return ply.CalcIdeal, ply.CalcSeqOverride
end)

hook.Add( "PlayerFootstep", "SlasherFootstep", function( ply, _, _, _, _, _ ) --pos, foot, sound, volume, rf

    if ply:Team() ~= TEAM_SLASHER then return end

    if type( SlashCoSlasher[ply:GetNWString("Slasher")].Footstep ) ~= "function" then return end

    return SlashCoSlasher[ply:GetNWString("Slasher")].Footstep(ply)

end)