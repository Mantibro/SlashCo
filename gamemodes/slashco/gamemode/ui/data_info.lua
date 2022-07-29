SCInfo = {}

SCInfo.Slasher = {

    {
        Name = "Bababaooey",
        Class = "Cryptid",
        Danger = "Moderate",
        Description = "The Phantom Slasher which specialises in illusion abilities to catch survivors off-guard.\n\n-Bababooey can turn himself invisible.\n-He can create a phantom clone of himself to scare and locate Survivors.",
        ProTip = "-This Slasher has the ability to vanish into thin air."
    },

    {
        Name = "Sid",
        Class = "Demon",
        Danger = "Considerable",
        Description = "The Psychotic Slasher which keeps his rage in check with Cookies.\n\n-Sid gains speed while chasing over time, but starts out slow.\n-Cookies will pacify him for a while.\n-Sid's special ability allows him to devastate Survivors at long range.",
        ProTip = "-Loud gunshots have been heard in zones where this Slasher was present."
    },

    {
        Name = "Trollge",
        Class = "Umbra",
        Danger = "Devastating",
        Description = "Troll.",
        ProTip = "-Its eyesight seems to be limited to moving objects."
    },

    {
        Name = "Amogus",
        Class = "Cryptid",
        Danger = "Moderate",
        Description = "The Imposter Slasher who is the master of deception and hiding in plain sight.\n\n-Amogus can assume the form of one of a Survivor.\n-He can assume the form of a Fuel Can.\n-Amogus is really loud while running.",
        ProTip = "-This Slasher can disguise itself as a human."
    },

    {
        Name = "Thirsty",
        Class = "Demon",
        Danger = "Considerable",
        Description = "The Milk Slasher whose abilities depend on his level of Thirst.\n\n-Thirsty must drink Jugs of Milk to reset his thirst.\n-The Thirstier he is, the slower he is, but can sense the position of players.\n-Thirsty is really quiet.",
        ProTip = "-This Slasher is heavily linked with Milk Jugs."
    },

    {
        Name = "Male_07",
        Class = "Umbra",
        Danger = "Devastating",
        Description = "The Omniscient Slasher which can possess one of his many clones.\n\n-Male_07 will turn into a monstrous entity after a long enough chase.\n-He can keep his deadlier human form for longer as the game progresses.",
        ProTip = "-1.\n-2."
    },

    {
        Name = "Tyler",
        Class = "Demon",
        Danger = "Devastating",
        Description = "The Balance Slasher who controls the progress of the round.\n\n-Tyler has two forms. Creator, and Destroyer.\n-Tyler, the Creator will create gas cans for survivors upon being found.\nTyler, the Destroyer will destroy anything in its path.",
        ProTip = "-Noticeably fewer Fuel Cans were spotted in this Slasher's Zone."
    },

    {
        Name = "Borgmire",
        Class = "Cryptid",
        Danger = "Devastating",
        Description = "The Brute Slasher who can overpower survivors with overwhelming strength.\n\n-Borgmire is most effective in short chases.\n-He can pick up and throw nearby Survivors for heavy damage.",
        ProTip = "-This Slasher seems to suffer from exhaustion during long chases."
    },

    {
        Name = "The Free Smiley Dealer",
        Class = "Umbra",
        Danger = "Considerable",
        Description = "The Summoner Slasher who can raise minions to help with the Hunt.\n\n-T.\n-T.\nT.",
        ProTip = "-."
    }

}

SCInfo.Item = {

    {
        Name = "Fuel Can",
        Price = 15,
        Description = "A jerry can full of high-octane gas. Useful for refuelling Cars and Generators. \nTaking it with you will reduce how much gas you will find within the Zone. \nOnce you drop this item, you will not be able to store it again."
    },

    {
        Name = "The Deathward",
        Price = 95,
        Description = "A ceramic, skull-shaped charm. Will save you from certain death, but only once. \nYour team can only have a limited amount of them.\nThis item will take up your Item Slot, even if spent."
    },

    {
        Name = "Milk Jug",
        Price = 35,
        Description = "A jug of fresh milk. Consuming it will grant you a large speed boost for a short while. \nEspecially useful when encountering a certain Slasher."
    },

    {
        Name = "Cookie",
        Price = 30,
        Description = "A large chocolate chip cookie. Consuming it will grant you a speed boost for a limited time. \nEspecially useful when encountering a certain Slasher."
    },

    {
        Name = "Mayonnaise",
        Price = 15,
        Description = "A large jar full of highly caloric mayonnaise. Consuming it will grant you a massive boost \nto your health. \nEspecially useful when encountering a certain Slasher."
    },

    {
        Name = "Step Decoy",
        Price = 5,
        Description = "A worn, metallic boot. \nIf placed on a solid surface, it will imitate footsteps sounds which can distract Slashers."
    },

    {
        Name = "The Baby",
        Price = 65,
        Description = "A decrepit-looking doll of a baby. Upon use, this item will halve your health and teleport \nyou away from the slasher. \nThe lower your health, the more likely you are to suffer a premature death upon use."
    },

    {
        Name = "B-Gone Soda",
        Price = 35,
        Description = "A can of strange soda. It has a sweet smell. \nConsuming it will turn you invisible for a short while."
    },

    {
        Name = "Distress Beacon",
        Price = 85,
        Description = "A personal emergency terminal. \nIf at least one Generator has been activated and you are the last one alive, upon use \nthis item will alert the Slashco headquarters to send emergency rescue. \nOnly one can be taken."
    },

    {
        Name = "Devil's Gamble",
        Price = 45,
        Description = "A seemingly cursed die. \nUpon use, this item will grant you a random effect."
    },

    {
        Name = "Personal Radio Set",
        Price = 0,
        Description = "A full set of short-wave radio transmitters which will allow your team to communicate remotely. \nOnly one can be taken."
    }

}

SCInfo.RoundEnd = {

    {
        On = "The assignment was successful.",
        Off = "The assignment was unsuccessful." ,
        DB = "The assignment was only partially successful."
    },

    {
        FullTeam = "All of the dispatched SlashCo Workers were rescued.",
        NonFullTeam = "Not all of the dispatched SlashCo Workers could be rescued.",
        AlivePlayers = " were reported present on the rescue helicopter.",
        DeadPlayers = " were confirmed dead.",
        LeftBehindPlayers = " had to be left behind.",
        Fail = "The dispatched SlashCo Workers could not be rescued.",
        OnlyOneAlive = " was the only one to survive.",
        OnlyOneDead = " was confirmed dead."
    },

    {
        Loss =  " are now presumed either dead or missing in action.",
        LossOnlyOne =  " is now presumed either dead or missing in action.",
        LossComplete =  "The Dispatched SlashCo Workers are now presumed either dead or missing in action.",
        DBWin = " had to be rescued before the assignment could be completed."
    }

}

SCInfo.Offering = {

    {
        Name = "Exposure",
        Rarity = 1,
        Description = "Will make Gas Cans easier to find,\nBut\nYou will not find more than you need.",
        GasCanMod = 0
    },
        
    {
        Name = "Satiation",
        Rarity = 1,
        Description = "The Slasher will be a Demon, and its items will be scarce,\nBut\nThe items will have greater effect.",
        GasCanMod = 0
    },

    {
        Name = "Drainage",
        Rarity = 2,
        Description = "Gas cans will be plentiful,\nBut\nGenerators will leak fuel over time.",
        GasCanMod = 6
    },

    {
        Name = "Duality",
        Rarity = 3,
        Description = "Only one generator will need to be powered,\nBut\nYou will face two Slashers.",
        GasCanMod = 0
    },

    {
        Name = "Singularity",
        Rarity = 3,
        Description = "Gas Cans will be plentiful,\nBut\nThe Slasher will grow much more powerful.",
        GasCanMod = 6
    }

}