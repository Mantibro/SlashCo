local PANEL = {}

local voiceText = {
    {
        prompt = "NO",
        snd = "no"
    },
    {
        prompt = "YES",
        snd = "yes"
    },
    {
        prompt = "FOLLOW ME",
        snd = "follow"
    },
    {
        prompt = "SLASHER HERE",
        snd = "spot"
    },
    {
        prompt = "RUN",
        snd = "run"
    },
    {
        prompt = "HELP ME",
        snd = "help"
    }
}

function PANEL:Init()

    local voices = {}

    self:SetSize(ScrW() / 3, ScrH() / 3)
    self:MakePopup()
    self:SetKeyboardInputEnabled(true)
    self:Center()
    self:SetCursor("blank")

    local voiceSay = vgui.Create("DLabel", self)
    voiceSay:SetSize(100,50)
    voiceSay:Center()
    voiceSay:SetFont("TVCD")
    voiceSay:SetText( "[SAY]" )

    --[[
    voices[1] = vgui.Create("DLabel", self)
    voices[1]:SetSize(150,50)
    voices[1]:SetFont("TVCD")
    voices[1]:SetContentAlignment(5)
    voices[1].Paint = function()
        return
    end
    voices[1].Prompt = "YES"
    voices[1].snd = "yes"

    voices[2] = vgui.Create("DLabel", self)
    voices[2]:SetSize(150,50)
    voices[2]:SetFont("TVCD")
    voices[2]:SetContentAlignment(5)
    voices[2].Paint = function()
        return
    end
    voices[2].Prompt = "NO"
    voices[2].snd = "no"

    voices[3] = vgui.Create("DLabel", self)
    voices[3]:SetSize(250,50)
    voices[3]:SetFont("TVCD")
    voices[3]:SetContentAlignment(5)
    voices[3].Paint = function()
        return
    end
    voices[3].Prompt = "FOLLOW ME"
    voices[3].snd = "follow"

    voices[4] = vgui.Create("DLabel", self)
    voices[4]:SetSize(250,50)
    voices[4]:SetFont("TVCD")
    voices[4]:SetContentAlignment(5)
    voices[4].Paint = function()
        return
    end
    voices[4].Prompt = "SLASHER HERE"
    voices[4].snd = "spot"

    voices[5] = vgui.Create("DLabel", self)
    voices[5]:SetSize(250,50)
    voices[5]:SetFont("TVCD")
    voices[5]:SetContentAlignment(5)
    voices[5].Paint = function()
        return
    end
    voices[5].Prompt = "RUN"
    voices[5].snd = "run"

    voices[6] = vgui.Create("DLabel", self)
    voices[6]:SetSize(250,50)
    voices[6]:SetFont("TVCD")
    voices[6]:SetContentAlignment(5)
    voices[6].Paint = function()
        return
    end
    voices[6].Prompt = "HELP ME"
    voices[6].snd = "help"
    --]]

    for k, v in ipairs(voiceText) do
        local element = vgui.Create("DLabel", self)
        table.insert(voices, element)
        element:SetSize(250,50)
        element:SetFont("TVCD")
        element:SetContentAlignment(5)
        element.Paint = function()
            return
        end
        element.Prompt = v.prompt
        element.snd = v.snd

        local rad = (6.28318531) / 6
        local cur_rad = rad * k

        if voices[k] ~= nil then
            voices[k]:SetPos((self:GetWide() / 2) + math.sin( cur_rad ) * 150 - (element:GetWide() / 2),
                    (self:GetTall() / 2) + math.cos( cur_rad ) * 150 - (element:GetTall() / 2))
        end
    end

    local voiceCursor = vgui.Create("DLabel", self)
    voiceCursor:SetSize(100,50)
    voiceCursor:SetFont("TVCD")
    voiceCursor:SetText( "[  ]" )

    self.VoiceCursor = voiceCursor
    self.Voices = voices
end

function PANEL:Think()
    local x, y = self:CursorPos()
    self.VoiceCursor:SetPos( x - 30, y - 25)

    local showCursor = true

    for k, v in ipairs( self.Voices ) do

        if v:DistanceFrom( x, y ) < 50 then
            v:SetText( "[ "..v.Prompt.." ]" )
            showCursor = false
        else
            v:SetText( v.Prompt )
        end

    end

    if showCursor then 
        self.VoiceCursor:SetText( "[  ]" )
    else
        self.VoiceCursor:SetText( "" )
    end
end


function PANEL:OnKeyCodeReleased(keyCode)
    if keyCode == KEY_T then
        self:Remove()
    end
end

vgui.Register("sc_voiceselect", PANEL, "Panel")