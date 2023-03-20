AddCSLuaFile()
AddCSLuaFile("bababooey.lua")
AddCSLuaFile("sid.lua")
AddCSLuaFile("trollge.lua")

if not SlashCoSlasher then SlashCoSlasher = {} end

include("bababooey.lua")
include("sid.lua")
include("trollge.lua")

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

if CLIENT then

    local StepNotice = Material("slashco/ui/particle/step_notice")

    hook.Add( "Think", "Slasher_Vision_Light", function()

        if LocalPlayer():Team() ~= TEAM_SLASHER then return end
    
        local Eyesight = LocalPlayer():GetNWInt("Slasher_Eyesight")
    
        --Eyesight - an arbitrary range from 1 - 10 which decides how illuminated the Slasher 'vision is client-side. (1 - barely any illumination, 10 - basically fullbright ) 
    
        local dlight = DynamicLight( LocalPlayer():EntIndex() )
        if ( dlight ) then
            dlight.pos = LocalPlayer():GetShootPos()
            dlight.r = 50 + (Eyesight * 2)
            dlight.g = 50 + (Eyesight * 2)
            dlight.b = 50 + (Eyesight * 2)
            dlight.brightness = Eyesight / 50
            dlight.Decay = 1000
            dlight.Size = 250 * Eyesight
            dlight.DieTime = CurTime() + 1
        end



        local slasherpos = LocalPlayer():GetPos()
        local PerceptionReal = LocalPlayer():GetNWInt("Slasher_Perception")

		if inchase then PerceptionReal = 0 end

		if timeSinceLast == nil then timeSinceLast = 0 end
		timeSinceLast = timeSinceLast + FrameTime()/3
		if timeSinceLast > 0.2 then timeSinceLast = 0 end 
		--Survivor Step Notice
		for i = 1, #team.GetPlayers(TEAM_SURVIVOR) do

			local survivor = team.GetPlayers(TEAM_SURVIVOR)[i]

			if survivor:GetNWBool("BGoneSoda") or survivor:GetNWString("item", "none") == "Rock" then goto gone end

			local vel = (survivor:GetVelocity()):Length()

			local range = 3 * vel * PerceptionReal

			local pos = survivor:GetPos()

			local em = ParticleEmitter(pos)
    		local part = em:Add(	StepNotice,	pos	) 

    		if part and timeSinceLast == 0 and  (  slasherpos	):Distance(	pos	) < range and survivor:IsOnGround() then 
          		part:SetColor(255,255,255,math.random(255))
          		part:SetVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):GetNormal() * 20)
          		part:SetDieTime(1)
          		part:SetLifeTime(0)
          		part:SetStartSize(25)
          		part:SetEndSize(0)
    		end

			em:Finish()

			::gone::
			
		end

		--Step Decoy Step Notice
		for i = 1, #ents.FindByClass( "sc_stepdecoy" ) do

			local boot = ents.FindByClass( "sc_stepdecoy" )[i]

			local vel = 300

			local range = 3 * vel * PerceptionReal

			local offsetpos = Vector(math.random(-2, 2),math.random(-2, 2),0)

			local pos = boot:GetPos() + offsetpos

			local em = ParticleEmitter(pos)
    		local part = em:Add(	StepNotice,	pos	) 

    		if part and timeSinceLast == 0 and  (  slasherpos	):Distance(	pos	) < range then 
          		part:SetColor(255,255,255,math.random(255))
          		part:SetVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):GetNormal() * 20)
          		part:SetDieTime(1)
          		part:SetLifeTime(0)
          		part:SetStartSize(25)
          		part:SetEndSize(0)
    		end
			
			em:Finish()

		end

        if type( SlashCoSlasher[LocalPlayer():GetNWString("Slasher")].ClientSideEffect ) ~= "function" then return end
        SlashCoSlasher[LocalPlayer():GetNWString("Slasher")].ClientSideEffect()

    end )





    hook.Add("RenderScreenspaceEffects", "SlasherVision", function()
    
        if LocalPlayer():Team() ~= TEAM_SLASHER then return end
    
        local Eyesight = LocalPlayer():GetNWInt("Slasher_Eyesight")
    
        local tab = {
            ["$pp_colour_addr"] = 0.01,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0.1,
            ["$pp_colour_contrast"] = 1 + Eyesight / 5,
            ["$pp_colour_colour"] = Eyesight / 5,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
    
        DrawColorModify( tab ) --Draws Color Modify effect
    end )




end