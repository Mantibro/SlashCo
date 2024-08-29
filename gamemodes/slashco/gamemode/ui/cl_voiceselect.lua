local PANEL = {}

local voiceText = {
    {
        prompt = SlashCo.Language("vocal_no"),
        snd = "no"
    },
    {
        prompt = SlashCo.Language("vocal_follow"),
        snd = "follow"
    },
    {
        prompt = SlashCo.Language("vocal_slasher"),
        snd = "spot"
    },
    {
        prompt = SlashCo.Language("vocal_yes"),
        snd = "yes"
    },
    {
        prompt = SlashCo.Language("vocal_run"),
        snd = "run"
    },
    {
        prompt = SlashCo.Language("vocal_help"),
        snd = "help"
    }
}

function PANEL:Init()
    local voices = {}

    self:SetSize(ScrW(), ScrH())
    self:SetCursor("blank")
    self:SetKeyboardInputEnabled(true)
    self:MakePopup()
    self:Center()

    local voiceSay = vgui.Create("DLabel", self)
    voices.say = voiceSay
    voiceSay:SetSize(300,50)
    voiceSay:Center()
    voiceSay:SetContentAlignment(5)
    voiceSay:SetFont("TVCD")
    voiceSay.Prompt = SlashCo.Language("vocal_say")

    local rad = math.pi/3
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

        local angle = rad * (k+0.5)
        element:SetPos((self:GetWide() / 2) + math.sin(angle) * 300 - (element:GetWide() / 2),
                (self:GetTall() / 2) + math.cos(angle) * 150 - (element:GetTall() / 2))
    end

    local voiceCursor = vgui.Create("DLabel", self)
    voiceCursor:SetSize(100,50)
    voiceCursor:SetFont("TVCD")
    voiceCursor:SetText("[  ]")

    self.VoiceCursor = voiceCursor
    self.Voices = voices
end

local red = Color(255, 64, 64)
local green = Color(64, 255, 64)
--local blue = Color(64, 64, 255)

function PANEL:Think()
    local x, y = self:CursorPos()
    self.VoiceCursor:SetPos( x - 30, y - 25)

    self.CursorSelect = nil

    local say = self.Voices.say
    if say:DistanceFrom(x, y) < 100 then
        say:SetText("[ " .. say.Prompt .. " ]")
        self.CursorSelect = false
        say:SetTextColor(say.Prompt == SlashCo.Language("vocal_cancel") and red or color_white)
    else
        say.Prompt = SlashCo.Language("vocal_cancel")
        say:SetTextColor(color_white)
        say:SetText(SlashCo.Language("vocal_cancel"))
    end

    for _, v in ipairs(self.Voices) do
        if v:DistanceFrom(x, y) < 100 then
            v:SetText("[ " .. v.Prompt .. " ]")
            v:SetTextColor(green)
            self.CursorSelect = v.snd
        else
            v:SetText(v.Prompt)
            v:SetTextColor(color_white)
        end
    end

    if self.CursorSelect == nil then
        self.VoiceCursor:SetText("[  ]")
    else
        self.VoiceCursor:SetText("")
    end
end

function PANEL:OnKeyCodeReleased(keyCode)
    if keyCode == KEY_G then
        self:Remove()

        if self.CursorSelect then
            net.Start("mantislashcoSurvivorVoicePrompt")
            net.WriteString(self.CursorSelect)
            net.SendToServer()
        end
    end
end

vgui.Register("sc_voiceselect", PANEL, "Panel")