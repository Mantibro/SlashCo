include( "ui/fonts.lua" )


hook.Add("HUDPaint", "SurvivorJumpscared", function()

	local ply = LocalPlayer()

	if ply:GetNWBool("DisplayTrollgeTransition") == true  then

		local Overlay = Material("slashco/ui/overlays/trollge_overlays")
		Overlay:SetInt( "$frame", 0 )

		surface.SetDrawColor(255,255,255,60)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	if ply:GetNWBool("ThirstyFuck") == true  then
		local Overlay = Material("slashco/ui/overlays/thirsty_fuck")

		surface.SetDrawColor(255,255,255,60)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		if c == nil then
			surface.PlaySound("slashco/slasher/thirsty_rage1.mp3")
			surface.PlaySound("slashco/slasher/thirsty_rage2.mp3")
			c = true
		end

	end

	if ply:GetNWBool("SidFuck") == true  then
		local Overlay = Material("slashco/ui/overlays/sid_fuck")

		surface.SetDrawColor(255,255,255,60)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		if c == nil then
			surface.PlaySound("slashco/slasher/sid_rage_drone.mp3")
			c = true
		end

	end

	if ply:GetNWBool("WatcherSurveyed") == true  then
		if al == nil then al = 0 end
		if al < 100 then al = al+(FrameTime()*100) end

		Overlay:SetFloat( "$alpha", 1 - (al/100) )

		local Overlay = Material("slashco/ui/overlays/watcher_see")

		surface.SetDrawColor(255,255,255,60)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	end

	if ply:GetNWBool("SurvivorJumpscare_1") == true  then

		if f == nil then f = 0 end
		f = f+(FrameTime()*20)
		if f > 45 then return end

		local Overlay = Material("slashco/ui/overlays/jumpscare_1")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())


	elseif ply:GetNWBool("SurvivorJumpscare_2") == true then

		if f == nil then f = 0 end
		if f < 39 then f = f+(FrameTime()*30) end

		local Overlay = Material("slashco/ui/overlays/jumpscare_2")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())


	elseif ply:GetNWBool("SurvivorJumpscare_3") == true then

		if f == nil then f = 0 end
		f = f+(FrameTime()*30)
		if f > 86 then return end

		local Overlay = Material("slashco/ui/overlays/jumpscare_3")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())


	elseif ply:GetNWBool("SurvivorJumpscare_4") == true then

		if f == nil then f = 0 end
		f = f+(FrameTime()*20)
		if f > 59 then f = 50 end

		local Overlay = Material("slashco/ui/overlays/jumpscare_4")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	
	elseif ply:GetNWBool("SurvivorJumpscare_5") == true then

		if f == nil then f = 0 end
		f = f+(FrameTime()*20)
		if f > 29 then f = 25 end

		local Overlay = Material("slashco/ui/overlays/jumpscare_5")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_6") == true then

		if f == nil then f = 0 end
		f = f+(FrameTime()*20)
		if f > 49 then return end

		local Overlay = Material("slashco/ui/overlays/jumpscare_6")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_7") == true then

		if f == nil then f = 0 end
		f = f+(FrameTime()*20)
		if f > 39 then f = 25 end

		local Overlay = Material("slashco/ui/overlays/jumpscare_7")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_9") == true then

		if f == nil then f = 0 end
		f = f+(FrameTime()*20)
		if f > 59 then f = 58 end

		local Overlay = Material("slashco/ui/overlays/jumpscare_9")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_10") == true then
		local Overlay = Material("slashco/ui/overlays/watcher_see")

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("DisplayTylerTheDestroyerEffects") == true  then

		local Overlay = Material("slashco/ui/overlays/tyler_static")

		local DestroyerFace = Material("slashco/ui/overlays/tyler_destroyer_face")

		Overlay:SetFloat( "$alpha", math.Rand(0.2,0.23) )

		DestroyerFace:SetFloat( "$alpha", math.Rand(0,0.1) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(DestroyerFace)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	else
		f = nil
	end
end)

hook.Add("CalcView", "ThirdPersonSurvivorView", function(ply, pos, angles, fov)

	if ply:Team() ~= TEAM_SURVIVOR then return end

	if ply:GetNWBool("SurvivorSidExecution") then

		pos = ply:LocalToWorld( Vector(120,120,60) )
		angles = ply:LocalToWorldAngles( Angle(0,-135,0) )

		return GAMEMODE:CalcView(ply, pos, angles, fov)
	else
		return
	end

end)
