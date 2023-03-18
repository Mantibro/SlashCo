local SlashCo = SlashCo

local ConvoCount = 19

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
    }
}

SlashCo.LobbyBanter = function()

    local survivors = team.getPlayers(TEAM_SURVIVOR)

    if #survivors < 2 then return 5 end

    local convo = math.random(1,ConvoCount)

    local firstSpoken = NULL

    local totalLength = SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2 + SlashCo.LobbyConvos[convo].Length3

    local function playVocal(conv, id)
        survivors[math.random(1, #survivors)]:EmitSound("slashco/survivor/voice/maleconv_"..conv.."_"..id..".mp3")
    end

    playVocal(convo, 1)

    timer.Simple(SlashCo.LobbyConvos[convo].Length1, playVocal(convo, 2))

    timer.Simple(SlashCo.LobbyConvos[convo].Length1 + SlashCo.LobbyConvos[convo].Length2, playVocal(convo, 3))

    return totalLength

end