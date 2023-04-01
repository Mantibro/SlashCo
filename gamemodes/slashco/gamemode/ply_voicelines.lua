local SlashCo = SlashCo

local ConvoCount = 30

SlashCo.LobbyConvos = {

    {
        Length1 = 4,
        Length2 = 4,
        Length3 = 4
    },

    {
        Length1 = 2,
        Length2 = 2,
        Length3 = 3
    },

    {
        Length1 = 5.5,
        Length2 = 4,
        Length3 = 2
    },

    {
        Length1 = 2.5,
        Length2 = 2,
        Length3 = 3
    },

    {
        Length1 = 4,
        Length2 = 2,
        Length3 = 10
    },

    {
        Length1 = 5,
        Length2 = 5,
        Length3 = 3
    },

    {
        Length1 = 4,
        Length2 = 1,
        Length3 = 4
    },

    {
        Length1 = 3,
        Length2 = 2,
        Length3 = 3
    },

    {
        Length1 = 11,
        Length2 = 1,
        Length3 = 1
    },

    {
        Length1 = 13,
        Length2 = 1,
        Length3 = 6
    },

    {
        Length1 = 2,
        Length2 = 2,
        Length3 = 4
    },

    {
        Length1 = 5,
        Length2 = 3,
        Length3 = 3
    },

    {
        Length1 = 0.85,
        Length2 = 2,
        Length3 = 4
    },

    {
        Length1 = 6,
        Length2 = 2,
        Length3 = 1
    },

    {
        Length1 = 5,
        Length2 = 2,
        Length3 = 2
    },

    {
        Length1 = 4,
        Length2 = 3,
        Length3 = 3
    },

    {
        Length1 = 5,
        Length2 = 2,
        Length3 = 3
    },

    {
        Length1 = 3,
        Length2 = 9.5,
        Length3 = 6
    },

    {
        Length1 = 2,
        Length2 = 3,
        Length3 = 2
    },

    {
        Length1 = 1.5,
        Length2 = 1.3,
        Length3 = 3
    },

    {
        Length1 = 1.8,
        Length2 = 4,
        Length3 = 3
    },

    {
        Length1 = 10,
        Length2 = 3,
        Length3 = 4
    },

    {
        Length1 = 2,
        Length2 = 3,
        Length3 = 3
    },

    {
        Length1 = 6,
        Length2 = 1.5,
        Length3 = 3
    },

    {
        Length1 = 11,
        Length2 = 1,
        Length3 = 1
    },

    {
        Length1 = 4,
        Length2 = 3,
        Length3 = 2
    },

    {
        Length1 = 6,
        Length2 = 5,
        Length3 = 3
    },

    {
        Length1 = 3,
        Length2 = 3,
        Length3 = 4
    },

    {
        Length1 = 5,
        Length2 = 9,
        Length3 = 5
    },

    {
        Length1 = 5,
        Length2 = 5,
        Length3 = 2
    }

}

local function sayPrompt(ply, input)
    ply:EmitSound("slashco/survivor/voice/prompt_" .. input .. math.random(1, 3) .. ".mp3")
end

local typeCheck = {
    ["LOOK HERE"] = "look",
    ["LOOK AT THIS"] = "look",
    ["HELICOPTER"] = "helicopter",
    ["GENERATOR"] = "generator",
    ["PLUSH DOG"] = "dogg",
    ["BASKETBALL"] = "ballin",
    ["SLASHER"] = "slasher"
}

SlashCo.LobbyBanter = function()

    local survivors = team.GetPlayers(TEAM_SURVIVOR)

    if #survivors < 2 then
        return 5
    end

    local convo = math.random(1, ConvoCount)

    local totalLength = SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2 + SlashCo.LobbyConvos[convo].Length3

    local function playVocal(conv, id, plyid)
        survivors[plyid]:EmitSound("slashco/survivor/voice/maleconv_" .. conv .. "_" .. id .. ".mp3")
    end

    local firstid = math.random(1, #survivors)
    playVocal(convo, 1, firstid)

    local secondid = math.random(1, #survivors)
    if secondid == firstid then
        secondid = 1
    end
    if secondid == firstid then
        secondid = 2
    end

    local thirdid = math.random(1, #survivors)
    if thirdid == secondid then
        thirdid = 1
    end
    if thirdid == secondid then
        thirdid = 2
    end

    timer.Simple(SlashCo.LobbyConvos[convo].Length1, function()
        playVocal(convo, 2, secondid)
    end)

    timer.Simple(SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2, function()
        playVocal(convo, 3, thirdid)
    end)

    return totalLength

end

net.Receive("mantislashcoSurvivorVoicePrompt", function(_, ply)
    if ply.VoicePromptCooldown and CurTime() - ply.VoicePromptCooldown < 1 then
        return
    end
    ply.VoicePromptCooldown = CurTime()

    local prompt = net.ReadString()
    ply:EmitSound("slashco/survivor/voice/prompt_".. prompt .. math.random(1, 5) .. ".mp3")
end)

SlashCo.EscapeVoicePrompt = function()

    if team.NumPlayers(TEAM_SURVIVOR) < 1 then
        return
    end

    local function playVoice(ply)
        ply:EmitSound("slashco/survivor/voice/prompt_escape" .. math.random(1, 5) .. ".mp3")
    end

    local survs = team.GetPlayers(TEAM_SURVIVOR)

    local speaking_survs = {}

    if #survs < 2 then
        playVoice(survs[1])
        return
    end

    table.insert(speaking_survs, survs[1])

    for i = 1, #survs do

        local survivor = survs[i]

        for s = 1, #speaking_survs do
            if speaking_survs[s] == survivor then
                goto SKIP
            end

            if survivor:GetPos():Distance(speaking_survs[s]:GetPos()) > 750 then
                table.insert(speaking_survs, survs[i])
                goto SKIP
            end
        end

        :: SKIP ::

    end

    for s = 1, #speaking_survs do
        playVoice(speaking_survs[s])
    end

end

net.Receive("mantislashcoSurvivorPreparePing", function(_, ply)

    if ply.LastPinged and CurTime() - ply.LastPinged < 3 then
        return
    end
    ply.LastPinged = CurTime()

    local look = ply:GetEyeTrace().Entity
    local ping_info = {}
    ping_info.ExpiryTime = 0
    if look:EntIndex() ~= 0 then
        if look.PingType then
            ping_info.Type = look.PingType
        elseif look:GetModel() == "models/ldi/basketball.mdl" then
            ping_info.Type = "BASKETBALL"
            ping_info.ExpiryTime = 15
        elseif look:IsPlayer() then
            if look:Team() == TEAM_SURVIVOR then
                ping_info.Type = "SURVIVOR"
                ping_info.SurvivorName = string.upper(look:Nick())
                look = ply:GetEyeTrace().HitPos
                ping_info.ExpiryTime = 5
            elseif look:Team() == TEAM_SLASHER then

                if not look:GetNWBool("AmogusSurvivorDisguise") then
                    ping_info.Type = "SLASHER"
                    look = ply:GetEyeTrace().HitPos
                    ping_info.ExpiryTime = 5
                else
                    ping_info.Type = "SURVIVOR"
                    ping_info.SurvivorName = string.upper(table.Random(team.GetPlayers(TEAM_SURVIVOR)):Nick())
                    look = ply:GetEyeTrace().HitPos
                    ping_info.ExpiryTime = 5
                end
            end
        else
            ping_info.Type = "LOOK AT THIS"

            ping_info.ExpiryTime = 10
        end
    else
        look = ply:GetEyeTrace().HitPos

        ping_info.Type = "LOOK HERE"

        ping_info.ExpiryTime = 10
    end

    if typeCheck[ping_info.Type] then
        sayPrompt(ply, typeCheck[ping_info.Type])
    elseif ping_info.Type == "ITEM" and type(look) == "Entity" then
        local class = look:GetClass()
        for _, v in pairs(SlashCoItems) do
            local input = v.EntClass
            if not input then continue end
            if v.EntClass == class then
                sayPrompt(ply, string.sub(input, 4))
                ping_info.Name = string.upper(v.Name)
                break
            end
        end
    end

    ping_info.Entity = look
    ping_info.Player = ply
    net.Start("mantislashcoSurvivorPings")
    net.WriteTable(ping_info)
    net.Send(team.GetPlayers(TEAM_SURVIVOR))
end)