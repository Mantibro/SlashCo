local SlashCo = SlashCo

local ConvoCount = 26

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
    }

}

SlashCo.LobbyBanter = function()

    local survivors = team.GetPlayers(TEAM_SURVIVOR)

    if #survivors < 2 then return 5 end

    local convo = math.random(1,ConvoCount)

    local firstSpoken = NULL

    local totalLength = SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2 + SlashCo.LobbyConvos[convo].Length3

    local function playVocal(conv, id)
        survivors[math.random(1, #survivors)]:EmitSound("slashco/survivor/voice/maleconv_"..conv.."_"..id..".mp3")
    end

    playVocal(convo, 1)

    timer.Simple(SlashCo.LobbyConvos[convo].Length1, function() playVocal(convo, 2) end)

    timer.Simple(SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2, function()  playVocal(convo, 3) end)

    return totalLength

end

net.Receive("mantislashcoSurvivorVoicePrompt", function() 

    local ply = net.ReadEntity()
    local prompt = net.ReadUInt(3)

    if prompt == 1 then
        ply:EmitSound("slashco/survivor/voice/prompt_yes"..math.random(1,5)..".mp3")
    elseif prompt == 2 then
        ply:EmitSound("slashco/survivor/voice/prompt_no"..math.random(1,6)..".mp3")
    elseif prompt == 3 then
        ply:EmitSound("slashco/survivor/voice/prompt_follow"..math.random(1,6)..".mp3")
    elseif prompt == 4 then
        ply:EmitSound("slashco/survivor/voice/prompt_spot"..math.random(1,5)..".mp3")
    elseif prompt == 5 then
        ply:EmitSound("slashco/survivor/voice/prompt_help"..math.random(1,6)..".mp3")
    elseif prompt == 6 then
        ply:EmitSound("slashco/survivor/voice/prompt_run"..math.random(1,7)..".mp3")
    end
end)

SlashCo.EscapeVoicePrompt = function()

    local function playVoice(ply) ply:EmitSound("slashco/survivor/voice/prompt_escape"..math.random(1,5)..".mp3") end

    local survs = team.GetPlayers(TEAM_SURVIVOR)

    local speaking_survs = {}

    if #survs < 2 then
        playVoice(survs[1])
        return
    end

    table.insert(speaking_survs, survs[1])

    for i = 1, #survs do

        local survivor = surv[i]

        for s = 1, #speaking_survs do 
            if speaking_survs[s] == survivor then 
                goto SKIP 
            end

            if survivor:GetPos():Distance(speaking_survs[s]:GetPos()) > 750 then
                table.insert(speaking_survs, survs[i])
                goto SKIP 
            end
        end

        ::SKIP::

    end

    for s = 1, #speaking_survs do 
        playVoice(speaking_survs[s])
    end

end