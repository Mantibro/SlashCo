include( "ui/fonts.lua" )


hook.Add("HUDPaint", "SurvivorJumpscared", function()

	local ply = LocalPlayer() 

	if ply:GetNWBool("WatcherSurveyed") == true  then
		if al == nil then al = 0 end
		if al < 100 then al = al+(FrameTime()*100) end

		local Overlay = Material("slashco/ui/overlays/watcher_see")

		Overlay:SetFloat( "$alpha", 1 - (al/100) )

		surface.SetDrawColor(255,255,255,60)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	else
		al = nil
	end

	if ply:GetNWBool("SurvivorJumpscare_10") == true then
		local Overlay = Material("slashco/ui/overlays/watcher_see")

		Overlay:SetFloat( "$alpha", 1 )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_12") == true then

		if f == nil then f = 0 end
		f = f+(FrameTime()*20)
		if f > 59 then f = 11 end

		local Overlay = Material("slashco/ui/overlays/jumpscare_12")
		Overlay:SetInt( "$frame", math.floor(f) )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_13") == true then
		local Overlay = Material("slashco/ui/overlays/jumpscare_13")

		Overlay:SetFloat( "$alpha", 1 )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	else
		f = nil
	end
end)