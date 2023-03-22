local SlashCo = SlashCo

--Setting up your own custom Slasher.

SlashCo.CustomSlashers = {

    --{ 
--      /\ Uncomment the bracket /\

        --Name the Slasher here
        NAME = "Custom Slasher",

        --The ID will be set automatically, don't worry about it.
        ID = 0,

        --The Class of the Slasher ( 1 - Cryptid, 2 - Demon, 3 - Umbra)
        CLS = 1,

        --The Danger Level of the Slasher ( 1 - Moderate, 2 - Considerable, 3 - Devastating)
        DNG = 1,

        --Model path for the base model of your slasher.
        Model = "models/slashco/slashers/myslasher/myslasher.mdl",

        --Kill Delay, or how long you have to wait until you cna kill another survivor after killing one.
        KillDelay = 1.5,

        --How many Gas Cans to deplete/add to the global count. (Could make the game unplayable if you deplete without forethought)
        GasCanMod = 0,

        --Prowling Speed
        ProwlSpeed = 150,

        --Chasing Speed
        ChaseSpeed = 290,

        --Base Perception (How far you can see footstep notifications from)
        Perception = 1.0,

        --Base Eyesight level (1 - 10)
        Eyesight = 5,

        --How far you can kill a survivor from
        KillDistance = 135,

        --The farthest away a survivor can be to start chasing them (MAINTAIN distance is this but multiplied by 3)
        ChaseRange = 70

        --How long you can spend not maintaining the chase before it's cancelled.
        ChaseDuration = 10.0,

        --How long the jumpscare lasts
        JumpscareDuration = 1.5,

        --Path for chase music
        ChaseMusic = "slashco/slasher/chase.wav",

        --Path for jumpscare sound
        KillSound = "slashco/slasher/kill.mp3",

        --Menu description
        Description = "The Custom Slasher [...].\n\n-Info 1\n-Info 2",

        --Briefing note
        ProTip = "-This is a Custom Slasher."

--      \/ Uncomment the bracket \/
    --}

}

hook.Add("Tick", "HandleCustomSlasherAbilities", function()

    if #ents.FindByClass("sc_generator") < 1 then return end

    local SO = SlashCo.CurRound.OfferingData.SO

for i = 1, #team.GetPlayers(TEAM_SLASHER) do

    local slasherid = team.GetPlayers(TEAM_SLASHER)[i]:SteamID64()
    local slasher = team.GetPlayers(TEAM_SLASHER)[i]

    if SlashCoSlasher[slasher:GetNWString("Slasher")].SlasherID < 10 then return end

    --[[
        The main ability handler which runs every tick.

        You have up to 5 variables to use.

        Your code here:
    ]]

    v1 = slasher.SlasherValue1 --Variable 1
    v2 = slasher.SlasherValue2 --Variable 2
    v3 = slasher.SlasherValue3 --Variable 3
    v4 = slasher.SlasherValue4 --Variable 4
    v5 = slasher.SlasherValue5 --Variable 5

end

end)