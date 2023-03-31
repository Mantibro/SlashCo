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

    local rad = (6.28318531) / 6
    for k, v in ipairs(voiceText) do
        local element = vgui.Create("DLabel", self)
        table.insert(voices, element)
        element:SetSize(300,50)
        element:SetFont("TVCD")
        element:SetContentAlignment(5)
        element.Paint = function()
            return
        end
        element.Prompt = v.prompt
        element.snd = v.snd
        element:SetPos((self:GetWide() / 2) + math.sin(rad * k) * 150 - (element:GetWide() / 2),
                (self:GetTall() / 2) + math.cos(rad * k) * 150 - (element:GetTall() / 2))
    end

    local voiceCursor = vgui.Create("DLabel", self)
    voiceCursor:SetSize(100,50)
    voiceCursor:SetFont("TVCD")
    voiceCursor:SetText( "[  ]" )

    self.VoiceCursor = voiceCursor
    self.Voices = voices
end

local CursorSelect = false

function PANEL:Think()
    local x, y = self:CursorPos()
    self.VoiceCursor:SetPos( x - 30, y - 25)

    CursorSelect = false

    for k, v in ipairs( self.Voices ) do

        if v:DistanceFrom( x, y ) < 50 then
            v:SetText( "[ "..v.Prompt.." ]" )
            CursorSelect = v.snd
        else
            v:SetText( v.Prompt )
        end

    end

    if not CursorSelect then 
        self.VoiceCursor:SetText( "[  ]" )
    else
        self.VoiceCursor:SetText( "" )
    end
end


function PANEL:OnKeyCodeReleased(keyCode)
    if keyCode == KEY_T then
        self:Remove()

        if CursorSelect then
            net.Start("mantislashcoSurvivorVoicePrompt")
            net.WriteString(CursorSelect)
            net.SendToServer()
        end
    end
end

vgui.Register("sc_voiceselect", PANEL, "Panel")