include('shared.lua')

function ENT:Initialize()


end

code = 0
net.Receive( "radio", function( len, ply )

    local ply = net.ReadEntity()

    local DermaPanel = vgui.Create( "DFrame" )	-- Create a panel to parent it to
    DermaPanel:SetSize( 500, 200 )	-- Set the size
    DermaPanel:SetTitle(" ")
    DermaPanel:Center()				-- Center it
    DermaPanel:MakePopup()			-- Make it a popup

    
    local DermaNumSlider = vgui.Create( "DNumSlider", DermaPanel )
    DermaNumSlider:SetPos( 50, 50 )				-- Set the position
    DermaNumSlider:SetSize( 300, 100 )			-- Set the size
    DermaNumSlider:SetText( "Radio Frequency" )	-- Set the text above the slider
    DermaNumSlider:SetMin( 0 )				 	-- Set the minimum number you can slide to
    DermaNumSlider:SetMax( 256 )				-- Set the maximum number you can slide to
    DermaNumSlider:SetDecimals( 0 )				-- Decimal places - zero for whole number
    
    
    -- If not using convars, you can use this hook + Panel.SetValue()
    DermaNumSlider.OnValueChanged = function( self, value )
        code = math.Round(value)
    end

    local DermaButton = vgui.Create( "DButton", DermaPanel ) // Create the button and parent it to the frame
DermaButton:SetText( "Scan" )					// Set the text on the button
DermaButton:SetPos( 25, 50 )					// Set the position on the frame
DermaButton:SetSize( 250, 30 )					// Set the size
DermaButton.DoClick = function()
 
    if code > 108.00 and code < 111.00 then
	    RunConsoleCommand( "cl_playerpaint" )
    else
        LocalPlayer():ChatPrint("All you get is static.")
        ply:EmitSound( "npc/overwatch/radiovoice/die"..math.random( 1,3)..".wav", 75, 100, 1, CHAN_AUTO )
    end
end

end )
 

