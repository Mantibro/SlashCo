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

	if ply:GetNWBool("SurvivorJumpscare_1") == true  then

		local Overlay = Material("slashco/ui/overlays/jumpscare_1")
		Overlay:SetInt( "$frame", 0 )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_2") == true then

		local Overlay = Material("slashco/ui/overlays/jumpscare_2")
		Overlay:SetInt( "$frame", 0 )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_3") == true then

		local Overlay = Material("slashco/ui/overlays/jumpscare_3")
		Overlay:SetInt( "$frame", 0 )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_4") == true then

		local Overlay = Material("slashco/ui/overlays/jumpscare_4")
		Overlay:SetInt( "$frame", 0 )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	elseif ply:GetNWBool("SurvivorJumpscare_5") == true then

		local Overlay = Material("slashco/ui/overlays/jumpscare_5")
		Overlay:SetInt( "$frame", 0 )

		surface.SetDrawColor(255,255,255,255)	
		surface.SetMaterial(Overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	end
end)
