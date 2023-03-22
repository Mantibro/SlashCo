SCInfo = {}

--[[SCInfo.Slasher = {

    {
        Name = "The Watcher",
        Class = "Umbra",
        Danger = "Considerable",
        Description = "The Observing Slasher whose power relies on sight.\n\n-The Watcher can Survey the map every once in a while to locate all survivors.\n-He will be slowed down if he is looked at, but anyone who does so will be located.\n-The Watcher can stalk Survivors to build up his special ability, Full Surveillance.",
        ProTip = "-This Slasher suffers from a loss of speed while observed.",
        SpeedRating = "★★★★☆",
        EyeRating = "★★★★☆",
        DiffRating = "★★☆☆☆"
    },

    {
        Name = "Abomignat",
        Class = "Cryptid",
        Danger = "Considerable",
        Description = "The Monstrous Slasher which uses basic abilities to achieve quick kills.\n\n-Abomignat can use its sharp claws to quickly damage Survivors.\n-It can perform a short-range high-speed lunge to finish off its victims.\n-Its Crawling Mode can enable swift map traversal.",
        ProTip = "-This Slasher enters bursts of speed while attacking.",
        SpeedRating = "★★★☆☆",
        EyeRating = "★★★★☆",
        DiffRating = "★☆☆☆☆"
    },

    {
        Name = "Criminal",
        Class = "Umbra",
        Danger = "Devastating",
        Description = "The Tormented Slasher which relies on confusion and\nentrapment to catch his victims.\n\n-Criminal is only able to attack while standing still.\n-He can summon clones around himself as a tool of confusion.\n",
        ProTip = "-This Slasher was seen surrounded by fake copies of itself.",
        SpeedRating = "★★★★☆",
        EyeRating = "★★☆☆☆",
        DiffRating = "★★★★★"
    },

    {
        Name = "Free Smiley Dealer",
        Class = "Cryptid",
        Danger = "Devastating",
        Description = "The Summoner Slasher which uses his minions to take control of the map.\n\n-Free Smiley Dealer can summon two types of minions, Pensive and Zany.\nBoth will alert him when a Survivor is detected.\n-Pensive can stun a Survivor for a short while.\n-Zany will charge at Survivors and damage them.",
        ProTip = "-This Slasher does not work alone.",
        SpeedRating = "★☆☆☆☆",
        EyeRating = "★★★☆☆",
        DiffRating = "★★☆☆☆"
    },

    {
        Name = "Leuonard",
        Class = "Demon",
        Danger = "Devastating",
        Description = "The Horny Slasher which rapes.\n\n-Leuonard's Rape will increase over time.\n-He must fuck a dog to decrease Rape.\n-Reaching 100% Rape will cause Leuonard to become powerful, but hard to control.",
        ProTip = "-This Slasher seems to have a fondness for dogs.",
        SpeedRating = "★★★★☆",
        EyeRating = "★★★☆☆",
        DiffRating = "★★★★☆"
    }

}]]

--[[
SCIngfo.Item = {

    {
        Name = "Fuel Can",
        Price = 15,
        Description = "A jerry can full of high-octane gas. Useful for refuelling Cars and \nGenerators. Taking it with you will reduce how much gas you will find\nwithin the Zone. \nOnce you drop this item, you will not be able to store it again."
    },

    {
        Name = "The Deathward",
        Price = 50,
        Description = "A ceramic, skull-shaped charm. Will save you from certain death,\nbut only once. Your team can only have a limited amount of them.\nThis item will take up your Item Slot, even if spent."
    },

    {
        Name = "Milk Jug",
        Price = 10,
        Description = "A jug of fresh milk. Consuming it will grant you a large speed boost\n for a short while.\nA certain Slasher seems to really like this item."
    },

    {
        Name = "Cookie",
        Price = 15,
        Description = "A large chocolate chip cookie. Consuming it will grant you a speed boost\nfor a limited time. \nA certain Slasher seems to really like this item."
    },

    {
        Name = "Mayonnaise",
        Price = 15,
        Description = "A large jar full of highly caloric mayonnaise. Consuming it will grant \nyou a massive boost to your health."
    },

    {
        Name = "Step Decoy",
        Price = 10,
        Description = "A worn, metallic boot. \nIf placed on a solid surface, it will imitate footsteps sounds which can\ndistract Slashers."
    },

    {
        Name = "The Baby",
        Price = 35,
        Description = "A decrepit-looking doll of a baby. Upon use, this item will halve your \nhealth and teleport you away from the slasher. \nThe lower your health, the more likely you are to\nsuffer a premature death upon use."
    },

    {
        Name = "B-Gone Soda",
        Price = 20,
        Description = "A can of strange soda. It has a sweet smell. \nConsuming it will turn you invisible for a short while."
    },

    {
        Name = "Distress Beacon",
        Price = 45,
        Description = "A personal emergency terminal. \nIf at least one Generator has been activated and you are the last one alive, upon use \nthis item will alert the Slashco headquarters to send emergency rescue. \nOnly one can be taken."
    },

    {
        Name = "Devil's Gamble",
        Price = 40,
        Description = "A seemingly cursed die. \nUpon use, this item will grant you a random effect."
    }

    ]]
--[[{
        Name = "The Rock",
        Price = 25,
        Description = "A strange, rock-shaped, rock-behaving device.\nWhile it's held, your footsteps will not make any noise, however\nyou will be slowed down slightly."
    }]]--[[


}
]]

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
        DeadPlayers = " could not make it out alive.",
        LeftBehindPlayers = " had to be left behind.",
        Fail = "The dispatched SlashCo Workers could not be rescued.",
        OnlyOneAlive = " was the only one to survive.",
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
        Description = "The Slasher will be a Demon,\nand its items will be scarce,\nBut\nThe items will have greater effect.",
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

SCInfo.Main = {

    Base = "Welcome to the SlashCo Power Recovery Program.\n\nYour assignment is refuelling and activating two Generators present in an area called the Slasher Zone.\n\nYou will need to pour four cans of fuel and insert a car battery into each, however it might turn out not to be an easy task.\n\nAn evil entity known as a Slasher will be present in the zone with you. The only way you can successfully complete your \ntask is by knowing how to survive.\n\nYou will be dropped off by a helicopter, which will also pick you up after both of the generators have been activated.\n\nIf you ever find yourself left stranded without a team, the helicopter can come rescue you prematurely if you signal \nit with a Distress Beacon, one of which you will always be able to find within the Slasher Zone.\nRescue will come only if at least one generator has been activated.\n\nBefore you set off to the Slasher Zone, you can choose an Item in the lobby in exchange for Points you earn during rounds as Survivor.",
    SlasherBase = "As a Slasher, your goal is to kill all of the Survivors before they manage to escape.\n\nYou can track the progress of the Survivors' assignment with a bar which indicates the Game Progress.\n\nEach Slasher has unique abilities which can help achieve your goal in different ways, furthermore, Slashers are divided\ninto three different Classes, each of which has a different ability kind.\n\nCryptid:\nThe abilities of Cryptids are simple and easy to understand. They consist of relatively straightforward ways of\nhelping you kill Survivors.\n\nDemon:\nA Demon's abilities depend on the Items they have consumed, which will be spawned all around the map, and at times the\nGame Progress of the round, meaning that a Demon's goals is not just killing Survivors, but also finding and consuming\nItems to grow their power.\n\nUmbra:\nThe powers of Slashers of the Umbra class grow as the Game Progress increases, meaning they are weak at first, but the\ncloser the Survivors get to completing their assignment, their abilities strengthen.",

}