--include( "globals.lua" )
include("ui/fonts.lua")
--include( "ui/data_info.lua" )

CreateClientConVar("slashcohud_show_lowhealth", 1, true, false, "Whether to display the survivor's hud as blinking yellow when at low health.", 0, 1)
CreateClientConVar("slashcohud_show_healthvalue", 0, true, false, "Whether to display the value of the survivor's health on their hud.", 0, 1)

local SlashCoItems = SlashCoItems
local prevHp, SetTime, ShowDamage, prevHp1, aHp, TimeToFuel, TimeUntilFueled
local FuelingCan
local IsFueling
local maxHp = 100 --ply:GetMaxHealth() seems to be 200
local prompt = 0
local ref_eyeang = Angle(0, 0, 0)
local voice_cooldown = 0
local global_pings = {}

local GeneratorIcon = Material("slashco/ui/icons/slasher/progbar_icon")

local function FindPos(search)

    if type(search) == "Entity" then
        return search:GetPos()
    elseif type(search) == "Vector" then
        return search
    end

end

net.Receive("mantislashcoGasPourProgress", function()

    TimeToFuel = net.ReadUInt(8)
    FuelingCan = net.ReadEntity()
    IsFueling = net.ReadBool()
    TimeUntilFueled = net.ReadFloat()

end)

local function removePing(key)
    global_pings[key] = nil
    --table.RemoveByValue(global_pings, key)
end

net.Receive("mantislashcoSurvivorPings", function()
    local ping = net.ReadTable()

    for k, v in pairs(global_pings) do
        local pn = v
        if pn.Player == ping.Player then
            removePing(k)
            break
        end
    end

    if ping.Type == "GENERATOR" then
        LocalPlayer():EmitSound("slashco/ping_generator.mp3")
    elseif ping.Type ~= "LOOK HERE" and ping.Type ~= "LOOK AT THIS" then
        LocalPlayer():EmitSound("slashco/ping_item.mp3")
    end

    ping.ID = math.random(2^31-1)
    global_pings[ping.ID] = ping

    if ping.ExpiryTime and ping.ExpiryTime > 0 then
        timer.Simple(ping.ExpiryTime, function()
            removePing(ping.ID)
        end)
    end

end)

hook.Add("HUDPaint", "SurvivorHUD", function()

    local ply = LocalPlayer()

    if ply:Team() ~= TEAM_SURVIVOR then
        return
    end

    local gas
    if IsFueling then
        gas = (TimeUntilFueled - CurTime()) / TimeToFuel
        if not input.IsButtonDown(KEY_E) then
            --print("not e")
            IsFueling = false
        elseif CurTime() >= TimeUntilFueled then
            --print("not fuel")
            IsFueling = false
        end
    end

    --//item display//--

    local HeldItem = ply:GetNWString("item", "none")
    if SlashCoItems[HeldItem or "none"] then
        local parsedItem = markup.Parse("<font=TVCD>---     " .. string.upper(SlashCoItems[HeldItem].Name) .. "     ---</font>")
        if SlashCoItems[HeldItem].DisplayColor then
            surface.SetDrawColor(SlashCoItems[HeldItem].DisplayColor(ply))
        else
            surface.SetDrawColor(0, 0, 128, 255)
        end
        surface.DrawRect(ScrW() * 0.975 - parsedItem:GetWidth() - 8, ScrH() * 0.95 - 24, parsedItem:GetWidth() + 8, 27)
        parsedItem:Draw(ScrW() * 0.975 - 4, ScrH() * 0.95, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        local offset = 0
        if SlashCoItems[HeldItem].OnUse then
            draw.SimpleText("[R] USE", "TVCD", ScrW() * 0.975 - 4, ScrH() * 0.95 - 30, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            offset = 30
        end
        if SlashCoItems[HeldItem].OnDrop then
            draw.SimpleText("[Q] DROP", "TVCD", ScrW() * 0.975 - 4, ScrH() * 0.95 - 30 - offset, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        --surface.SetDrawColor(255, 255, 255, 255)
        --surface.SetMaterial(Material(SlashCoItems[HeldItem].Icon))
        --surface.DrawTexturedRect(ScrW() * 0.975-100, ScrH() * 0.95-130, 100, 100)
    end

    --//gas fuel meter//--

    local hitPos = ply:GetShootPos()
    if IsFueling and IsValid(FuelingCan) then
        local genPos = FuelingCan:GetPos()
        local realDistance = hitPos:Distance(genPos)
        if realDistance < 100 then
            genPos = genPos:ToScreen()
            local fade = math.Round((100 - realDistance) * 2.8)
            local parsedLiters = markup.Parse("<font=TVCD>" .. math.Round(gas * 10) .. "L</font>") --this only exists to find the length lol
            local width = 206 + parsedLiters:GetWidth()
            local xClamp = math.Clamp(genPos.x, ScrW() * 0.025 + width / 2, ScrW() * 0.975 - width / 2)
            local yClamp = math.Clamp(genPos.y, ScrH() * 0.05 + 24, ScrH() * 0.95 - 51)
            local half = math.Clamp((gas * 8), 0, 8) % 1 >= 0.5

            surface.SetDrawColor(0, 128, 0, fade)
            surface.DrawRect(xClamp - width / 2, yClamp - 13, width, 27)
            draw.SimpleText(math.Round(gas * 10) .. "L", "TVCD", xClamp + 205 - width / 2, yClamp, Color(255, 255, 255, fade), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("FUEL " .. string.rep("█", gas * 8) .. (half and "▌" or ""), "TVCD", xClamp + 2 - width / 2, yClamp, Color(255, 255, 255, fade), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            IsFueling = false
        end
    end

    --//voice prompts//--

    if input.IsKeyDown(KEY_T) then

        draw.SimpleText("[SAY]", "TVCD", ScrW() / 2, ScrH() / 2 - 35, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local ht = (ref_eyeang[1] - LocalPlayer():EyeAngles()[1]) * 10
        local xt = (ref_eyeang[2] - LocalPlayer():EyeAngles()[2]) * 10

        local selected = false
        local yes_select = false
        local no_select = false
        local follow_select = false
        local spot_select = false
        local help_select = false
        local run_select = false

        if math.abs((-250) - xt) < 50 and math.abs((0) - ht) < 50 then
            yes_select = true
            selected = true
        end

        if math.abs((250) - xt) < 50 and math.abs((0) - ht) < 50 then
            no_select = true
            selected = true
        end

        if math.abs((-150) - xt) < 50 and math.abs((-100) - ht) < 50 then
            follow_select = true
            selected = true
        end

        if math.abs((150) - xt) < 50 and math.abs((-100) - ht) < 50 then
            spot_select = true
            selected = true
        end

        if math.abs((-150) - xt) < 50 and math.abs((100) - ht) < 50 then
            help_select = true
            selected = true
        end

        if math.abs((150) - xt) < 50 and math.abs((100) - ht) < 50 then
            run_select = true
            selected = true
        end

        if yes_select then
            draw.SimpleText("[ \"YES\" ]", "TVCD", ScrW() / 2 - 250, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            prompt = 1
        else
            draw.SimpleText("  \"YES\"  ", "TVCD", ScrW() / 2 - 250, ScrH() / 2, Color(255, 255, 255, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if no_select then
            draw.SimpleText("[ \"NO\" ]", "TVCD", ScrW() / 2 + 250, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            prompt = 2
        else
            draw.SimpleText("  \"NO\"  ", "TVCD", ScrW() / 2 + 250, ScrH() / 2, Color(255, 255, 255, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if follow_select then
            draw.SimpleText("[ \"FOLLOW ME\" ]", "TVCD", ScrW() / 2 - 150, ScrH() / 2 + 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            prompt = 3
        else
            draw.SimpleText("  \"FOLLOW ME\"  ", "TVCD", ScrW() / 2 - 150, ScrH() / 2 + 100, Color(255, 255, 255, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if spot_select then
            draw.SimpleText("[ \"SLASHER HERE\" ]", "TVCD", ScrW() / 2 + 150, ScrH() / 2 + 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            prompt = 4
        else
            draw.SimpleText("  \"SLASHER HERE\"  ", "TVCD", ScrW() / 2 + 150, ScrH() / 2 + 100, Color(255, 255, 255, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if help_select then
            draw.SimpleText("[ \"HELP ME\" ]", "TVCD", ScrW() / 2 - 150, ScrH() / 2 - 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            prompt = 5
        else
            draw.SimpleText("  \"HELP ME\"  ", "TVCD", ScrW() / 2 - 150, ScrH() / 2 - 100, Color(255, 255, 255, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if run_select then
            draw.SimpleText("[ \"RUN\" ]", "TVCD", ScrW() / 2 + 150, ScrH() / 2 - 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            prompt = 6
        else
            draw.SimpleText("  \"RUN\"  ", "TVCD", ScrW() / 2 + 150, ScrH() / 2 - 100, Color(255, 255, 255, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if not selected then
            draw.SimpleText("[]", "TVCD", ScrW() / 2 + xt, ScrH() / 2 - ht, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

    else

        ref_eyeang = LocalPlayer():EyeAngles()

        if prompt > 0 and voice_cooldown <= 0 then

            net.Start("mantislashcoSurvivorVoicePrompt")
            net.WriteUInt(prompt, 3)
            net.SendToServer()

            voice_cooldown = 2

            prompt = 0
        end

    end

    if voice_cooldown > 0 then
        voice_cooldown = voice_cooldown - RealFrameTime()
    end

    --//prompts for items//--

    if LocalPlayer():GetVelocity():Length() > 250 then
        local lookent = LocalPlayer():GetEyeTrace().Entity
        if lookent:GetClass() == "prop_door_rotating" or lookent:GetClass() == "func_door_rotating" then
            if lookent:GetPos():Distance(LocalPlayer():GetPos()) < 150 then
                draw.SimpleText("[LMB TO SLAM OPEN!]", "TVCD", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    --(displaying them)
    for k, v in pairs(global_pings) do
        if v.Entity == nil then
            continue
        end

        if type(v.Entity) ~= "Vector" and not IsValid(v.Entity) then
            removePing(k)
            continue
        end

        if not IsValid(v.Player) then
            removePing(k)
            continue
        end

        local pos = (FindPos(v.Entity)):ToScreen()

        local showText = v.Type or "a"

        local showName = true

        local textColor = Color(255, 255, 255, 255)

        if v.Type == "ITEM" then
            showText = v.Name or "ITEM"
        elseif v.Type == "SURVIVOR" then
            showName = true
            showText = v.SurvivorName
            textColor = Color(50, 50, 255, 255)
        elseif v.Type == "SLASHER" then
            showName = true
            textColor = Color(255, 50, 50, 255)
        elseif v.Type == "GENERATOR" then
            showName = true
            textColor = Color(50, 255, 50, 255)

            pos = (FindPos(v.Entity:GetPos() + Vector(0, 0, 40))):ToScreen()
            --showName = false
            --surface.SetMaterial(GeneratorIcon)
            --surface.DrawTexturedRectRotated(pos.x, pos.y, ScrW() / 32, ScrW() / 32, 0)
            --showText = "     "
        end

        if showName then
            draw.SimpleText(v.Player:GetName(), "TVCD_small", pos.x, pos.y - 25, Color(255, 255, 255, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("[" .. showText .. "]", "TVCD", pos.x, pos.y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    --//item selection crosshair//--

    for _, v in pairs(ents.FindInSphere(hitPos, 100)) do
        if v.IsSelectable and not (IsFueling and FuelingCan == v) then
            local gasPos = v:GetPos()
            local trace = util.QuickTrace(hitPos, gasPos - hitPos, ply)
            if not trace.Hit or trace.Entity == v then
                local realDistance = hitPos:Distance(gasPos)
                gasPos = gasPos:ToScreen()
                local centerDistance = math.Distance(ScrW() / 2, ScrH() / 2, gasPos.x, gasPos.y)
                draw.SimpleText("[", "Indicator", gasPos.x - centerDistance / 2 - 12, gasPos.y, Color(255, 255, 255, (100 - realDistance) * (300 - centerDistance) * 0.02), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("]", "Indicator", gasPos.x + centerDistance / 2 + 12, gasPos.y, Color(255, 255, 255, (100 - realDistance) * (300 - centerDistance) * 0.02), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                if realDistance < 200 and centerDistance < 25 then
                    draw.SimpleText("[MMB] PING", "TVCD", ScrW() / 2, ScrH() / 2 + 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end

    --//health//--

    local hp = ply:Health()

    if hp > (prevHp or 100) then
        --reset damage indicator upon healing
        prevHp = math.Clamp(hp, 0, 100)
        SetTime = 0
    end

    if (CurTime() >= (SetTime or 0)) then
        if ShowDamage then
            --update prevHp once the indicator time is up
            prevHp = math.Clamp(hp, 0, 100)
            ShowDamage = false
        end

        if hp < (prevHp or 100) then
            --start the damage indicator time
            prevHp1 = math.Clamp(hp, 0, 100)
            ShowDamage = true
            SetTime = CurTime() + 2.1
        end
    elseif hp < prevHp1 then
        --reset indicator time if more damage is taken
        prevHp1 = math.Clamp(hp, 0, 100)
        SetTime = CurTime() + 2.1
    end

    aHp = Lerp(FrameTime() * 3, (aHp or 100), hp)
    local displayPrevHpBar = (CurTime() % 0.7 > 0.35) and math.Round(math.Clamp(((prevHp or 100) - hp) / maxHp, 0, 1) * 26.9) or 0
    local parsed

    if hp >= 25 or not GetConVar("slashcohud_show_lowhealth"):GetBool() then
        local hpOver = math.Clamp(hp - maxHp, 0, 100)
        local hpAdjust = math.Clamp(hp, 0, 100) - hpOver
        local displayHpBar = math.Round(math.Clamp(hpAdjust / maxHp, 0, 1) * 27)
        local displayHpOverBar = math.Round(math.Clamp(hpOver / maxHp, 0, 1) * 27)
        parsed = markup.Parse("<font=TVCD>HP <colour=0,255,255,255>" .. string.rep("█", displayHpOverBar) .. "</colour>" --overheal
                .. string.rep("█", displayHpBar) --hp
                .. "<colour=255,0,0,255>" .. string.rep("█", displayPrevHpBar) .. "</colour></font>") --indicator
    else
        local displayHpBar = (CurTime() % 0.7 > 0.35) and math.Round(math.Clamp(hp / maxHp, 0, 1) * 27) or 0
        parsed = markup.Parse("<font=TVCD>HP <colour=255,255,0,255>" .. string.rep("█", displayHpBar) .. "</colour><colour=255,0,0,255>" --hp
                .. string.rep("█", displayPrevHpBar) .. "</colour></font>") --indicator
    end

    surface.SetDrawColor(0, 0, 128, 255)

    if not GetConVar("slashcohud_show_healthvalue"):GetBool() then
        surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 410, 27)
    else
        local displayHp = math.Round(aHp)
        local parsedValue = markup.Parse("<font=TVCD>" .. displayHp .. "</font>")
        surface.DrawRect(ScrW() * 0.025, ScrH() * 0.95 - 24, 420 + parsedValue:GetWidth(), 27)
        parsedValue:Draw(ScrW() * 0.025 + 417, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    parsed:Draw(ScrW() * 0.025 + 4, ScrH() * 0.95, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end)

--register a new vgui panel in another file
--useful stuff to know:
--Panel:LocalCursorPos() returns the cursor position relative to the panel

local voicePanel
hook.Add("PlayerButtonDown", "OpenVoice", function(ply, button)
    if not IsFirstTimePredicted() or ply:Team() ~= TEAM_SURVIVOR then
        return
    end
    if button == KEY_H then
        voicePanel = vgui.Create("DPanel") --the panel you made should replace DPanel here
        voicePanel:SetSize(600, 600)
        voicePanel:MakePopup()
        voicePanel:DockMargin(0, 0, 0, 0)
        voicePanel:SetKeyboardInputEnabled(true)
        voicePanel:Center()
        function voicePanel:OnKeyCodeReleased(keyCode)
            if keyCode == KEY_H then
                self:Remove()
            end
        end
    elseif button == 109 then
        net.Start("mantislashcoSurvivorPreparePing")
        net.SendToServer()
    end
end)

hook.Add("Think", "Slasher_Chasing_Light", function()
    for s = 1, #ents.FindByClass("sc_crimclone") do
        local clone = ents.FindByClass("sc_crimclone")[s]
        if clone:GetNWBool("MainRageClone") then
            local tlight = DynamicLight(clone:EntIndex() + 1)
            if (tlight) then
                tlight.pos = clone:LocalToWorld(Vector(0, 0, 20))
                tlight.r = 255
                tlight.g = 0
                tlight.b = 255
                tlight.brightness = 5
                tlight.Decay = 1000
                tlight.Size = 250
                tlight.DieTime = CurTime() + 1
            end
        end
    end

    for s = 1, #team.GetPlayers(TEAM_SLASHER) do
        local slasher = team.GetPlayers(TEAM_SLASHER)[s]
        if slasher:GetNWBool("TrollgeStage2") then

            local tlight = DynamicLight(slasher:EntIndex() + 1)
            if (tlight) then
                tlight.pos = slasher:LocalToWorld(Vector(0, 0, 20))
                tlight.r = 255
                tlight.g = 0
                tlight.b = 0
                tlight.brightness = 5
                tlight.Decay = 1000
                tlight.Size = 2500
                tlight.DieTime = CurTime() + 1
            end

        end

        if slasher:GetNWBool("TylerFlash") then

            local dlight = DynamicLight(slasher:EntIndex())
            if (dlight) then
                dlight.pos = slasher:LocalToWorld(Vector(0, 0, 20))
                dlight.r = 255
                dlight.g = 0
                dlight.b = 0
                dlight.brightness = 8
                dlight.Decay = 1000
                dlight.Size = 300
                dlight.DieTime = CurTime() + 1
            end

        end

        if not slasher:GetNWBool("InSlasherChaseMode") and not slasher:GetNWBool("SidGunRage") and not slasher:GetNWBool("WatcherRage") then
            return
        end

        local dlight = DynamicLight(slasher:EntIndex())
        if (dlight) then
            dlight.pos = slasher:LocalToWorld(Vector(0, 0, 20))
            dlight.r = 255
            dlight.g = 0
            dlight.b = 0
            dlight.brightness = 6
            dlight.Decay = 1000
            dlight.Size = 250
            dlight.DieTime = CurTime() + 1
        end

    end

end)