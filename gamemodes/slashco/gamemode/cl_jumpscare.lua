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

	elseif ply:GetNWBool("SurvivorJumpscare_1") == true  then

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

	elseif ply:GetNWBool("DisplayTylerTheDestroyerEffects") == true  then

		local Overlay = Material("slashco/ui/overlays/tyler_static")

		local DestroyerFace = Material("slashco/ui/overlays/tyler_destroyer_face")

		Overlay:SetFloat( "$alpha", math.Rand(0.1,0.3) )

		DestroyerFace:SetFloat( "$alpha", math.Rand(-1.5,0.4) )

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
