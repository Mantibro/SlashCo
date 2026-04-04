## Notes
Some newly added sounds will be from the SlashCo VR version.<br>

> [!WARNING]
> When we release these changes, revert `gamemodes/slashco/slashco.txt` -> `workshopid` back to the main addon -> `2844428843`

## GamePlay changes
[+] A dark fog that dynamically adjusts to the environment lighting.<br>
-> In the background this is an entire fog system that was implemented.<br>
[+] Added player perks (WIP)<br>
[+] Different game intro sounds are played based off the slasher difficulty.<br>
[+] Playing the dangerLevel sound when spawning into a round<br>
[+] Implemented quick escape and slow escape. (+10 or -10 credits)<br>
-> If you escape before the round went on for 10 minutes it counts as a quick escape, if you escape after 20 minutes its a slow escape<br>
[+] Added `slashco_unstuck` console command that can be used to unstuck yourself if you somehow get stuck due to any kind of bug<br>
[+] Added `slashco_give_points` console command to increase a player current points amount.<br>
[+] Added `slashco_banslasher`, `slashco_unbanslasher` allowing hosts to ban one or multiple slashers. The ban **remains indefinetly** until removed manually!<br>
[+] Added Late Join support allowing people to join as survivors in the first 3 minutes of a round.<br>
[+] Added support for stacking effects<br>
-> Previously, one item's effect would have overwritten the currently active effect<br>
[+] Maps will always spawn 3 generators now. The amount needed to complete the objective increase every 6 survivors.<br>
[+] Added point reward for being the first person to find / ping a generator<br>
[+] Added a fuel display to the generators allowing one to see how much fuel is missing<br>
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c467fc49-9bfe-4372-8559-ff618ced4eac" />

[+] Show how many remaining generators are left in the objective<br>
<img width="285" height="43" alt="image" src="https://github.com/user-attachments/assets/0d54494d-c482-4038-9ec0-56a9e85725d0" />

[+] Added a status light to the generators showing if their running or not<br>
<img width="1040" height="617" alt="image" src="https://github.com/user-attachments/assets/3bc456d5-aaae-46ae-a7b7-bd27c704c641" />

[#] You can now hold the USE key when fuling a generator instead of having to let go of it and press it again<br>
[#] Disable broken door collisions after it stopped moving<br>
(if you accidentally walked on it previously, your movement would become jittery as the prediction would fail).<br>
[#] Removed player limit.<br>
-> In the main menu you now got the option `Max Players` which by default is `7` but can be increased.<br>
-> Servers can set the `slashco_maxplayers` convar<br>
-> If the helicopter is full, additional players will be somewhat bugged, but it should work fine.<br>
[#] Synchronized for all survivors the helicopter voicelines<br>
[#] Precached almost every used sound and model to avoid in-game stutters.<br>
-> The stutters sometimes were caused by GMod having to first load the sound before it could play it- now it loads everything when joining, avoiding that from happening in-game.<br>
[#] Play a sound when an item can't be used<br>
[#] Slightly reduced fall damage<br>

### Document Objective
A new objective to find documents was added, BUT it still needs to be implemented on many maps.<br>
When there are more than 4 survivors, you'll have to find 1 document for every 2 additional survivors.<br>

### Overtime
When a round goes longer than 15 minutes, players will hear a warning sound<br>
Batteries, fuel cans, and documents will begin to randomly play a sound to help survivors find the remaining ones.<br>
When a round goes for 20 minutes or more, it's considered a slow escape, and there will be a penalty.<br>

### Keyboard UI
Using the `slashco_openkeyboardbinds` command OR using the `F8` key by default, you can open the Keyboard UI to rebind keys if some are conflicting<br>

<img width="971" height="550" alt="image" src="https://github.com/user-attachments/assets/430f0a3b-271d-4ba1-aaf6-51e8bfe9cf8b" />

## Server changes
[+] Added `slashco_proximity_chat`, `slashco_proximity_voice` and `slashco_proximity_range` to control the voice & text chat.<br>
[#] Made console messages not throw an error<br>
-> For example using `say Hello` would have resulted in an error<br>
[#] Made a lot of entities use `EFL_KEEP_ON_RECREATE_ENTITIES` to avoid deletion when `game.CleanUpMap()` was used<br>

## Lobby changes
[+] Extended the Lobby a bit and improved performance slightly<br>
[+] Show the level & EP in the lobby HUD below the points<br>
[#] New lobby map file (more players spawns)<br>
[#] Make the chat global in the lobby<br>
[#] Disabled collisions between lobby players, avoiding issues when playing with 6+ survivors who all try to queeze into the elevator.<br>
[#] Made item picker show items in an ordered list by name instead of being random<br>
[#] Flip Slasher & Survivor in Lobby HUD to fit the order<br>

### Nightmare Offering
[+] Changed the lobby lighting & background music just to fit the impending nightmare<br>

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/575d8912-f217-4394-aec1-d61d409b3a34" />

### Document System
In the Lobby you can now find the document terminal with information about Slashers<br>

<img width="1086" height="708" alt="image" src="https://github.com/user-attachments/assets/633c0fa9-6a60-4ebe-bdb0-c2795a50792d" />

### Perk System
You can find perks in the same terminal as documents and equip them depending on your current level. (WIP)<br>

<img width="1086" height="708" alt="image" src="https://i.imgur.com/VEHLo8L.png" />

## Slasher Changes
[+] Gave slashers the ability to ping like survivors<br>
[#] Moved all slasher sounds into `slashco/slasher/'slashername'`<br>
[#] Almost all slashers are in some form dynamically balanced based of the survivor count!<br>
[#] Most slashers have been switched to use the new anger system<br>
-> Based on the slasher's anger the background music will change, indicating for the survivors how mad the slashers are / how dangerous they have become already<br>
[#] Fixed Slasher's step notification mass creating & deleting particle emitters<br>
-> Only a single one is used now & simply reused each time.<br>
-> This could have caused a lot of errors when they didn't clean up quick enouth<br>
[#] Breaking a door open will now check if there is another door nearby (for double doors) and break that one too<br>
[#] Implemented some failsafe logic to somewhat handle the case that a slasher cannot be spawned if a Lua error occurred.<br>
[#] The generator's color in the stock UI changes if a generator is running or not.<br>

### Tyler
[+] Added a camera shake to his effect, intensity is based off his distance<br>
[+] Added new sound for when he's below 50 anger<br>
[+] Implement endless chase if the time is up<br>
-> When the round time reaches the defined slow time of 20min, this chase is disabled by default<br>
[+] If a player is holding a fuel can, Tyler will destroy the fuel can first instead of killing the player<br>
[+] Added Tyler theme which is played as background music after the first chase.<br>
-> The volume of the background music indicates how close he is to becoming the destroyer once it's almost completely gone, he'll switch.<br>
[+] Added three new songs from SlashCo VR to play when hes tyler the creator.<br>
[#] Made his HUD effect local and based off his distance to the player<br>
[#] Switched all code over to use the new audiosystem and the new anger system<br>
[#] When the escape helicopter is called, activates endless chase.<br>
[#] Improved tyler hide time duration.<br>
[#] He will **always** spawn after `10` seconds into the round<br>
[#] The Helicopter will **always** arrive after `30` seconds when escaping<br>
[#] Reduced the amount of GasCans that spawn during his round.<br>

### The Watcher
[+] Added footstep sounds from SlashCo VR<br>
[+] Added background music from SlashCo VR<br>
[#] Reduced Prowl speed (200 - 185).<br>

### Princess
[+] If a player is holding a baby, Princess will eat the baby now.<br>
[+] Added new footstep sounds<br>
[#] When Princess eats/kills a player or baby, they will be stunned for 4.5 seconds.<br>

### Abomignat
[+] Added 3 seconds of cooldown to his abilities after leaving crawling state.<br>
[#] Increased Prowl speed (150 - 200) and Chase speed (293 - 325).<br>
[#] Increased Chase duration (5s - 7s).<br>
[#] Increased Lunge damage (50 - 100).<br>
[#] Increased Crawling speed (350 - 400).<br>

### Amogus
[#] Moved Gascan disguise position to the ground level.<br>
[#] Fixed chase animation not being used.<br>

### Borgmire
[+] Added a new ability: Kick.<br>
-> Upon use, Borgmire will get a speed boost for a few seconds before performing a kick.<br>
-> Survivors in the range would get damage and high knockback.<br>
[#] 'Throw' ability now requires 50% anger amount to be usable.<br>
[#] Decreased Chase cooldown (8s - 5s).<br>
[#] Now he can freely move and aim when holding a survivor.<br>

### Criminal
[+] Added background music.<br>

### Dolphinman
[+] Added proper footstep sounds<br>
[+] Gains 20% hunt power when killing without hunting.<br>
[+] Starts gaining hunt power when the escape helicopter is called.<br>
[#] Increased KillDelay (0.25s - 0.50s).<br>
[#] Decreased hunt power gain on kill when hunting (25% - 15%).<br>
[#] Decreased hunt power loss on standing (50% - 25%).<br>
[#] Eyesight decreased. (3 - 2)<br>

### Freesmiley
[+] Added new float and stun animations.<br>
[#] Balkan Boost users are marked until the effect run out.<br>
[#] Increased Chase duration (5s - 9s).<br>

### Manspider
[#] Increased Prowl speed (150 - 250) and Chase speed (290 - 315).<br>
[#] Added a new ability: Climbing.<br>
-> Allows Manspider to climb into walls, jump between them and even make a nest there.<br>
-> Landing on top of a survivor after jumping from a wall will deal them damage.<br>

### Sid
[+] Added the ability to grab a cookie from a survivor's hand.<br>
[+] Added a new animation for the cookie ability.<br>
[+] Sid will activate his rage if the beacon is used and he eated at least 3 cookies.<br>
[#] Decreased KillDelay (7s - 5s)<br>

### Thirsty
[#] Increased base Prowl speed (100 - 120) and base Chase speed (260 - 280).<br>
[#] Decreased Pacified duration (same duration of Sid).<br>
[#] Increased max milkies (4 - 6).<br>
[#] Upon reaching 6 milkies, Thirst meter will not increase anymore and will give Thirsty a permanent visibility buff.<br>

### Trollge
[+] Added footstep sounds from SlashCo VR<br>
[+] Added background music from SlashCo VR<br>
[+] Added two sounds for when he's blinded by pocket sand<br>
[+] Trollge will switch to stage 3 if the beacon is used and he collected max blood.<br>
[#] Can see the halos of Balkan Boost holders.<br>
[#] On contact with a Balkan Boost, instantly change to stage 3.<br>
[#] Switched all sounds to use the new audiosystem.<br>
[#] Optimized his code slightly<br>
[#] Blocked his claw attack while being freezed after using the dash.<br>

### Covenant
[+] Added Covenant as a playable slasher during the selection screen.<br>
[+] Added footstep sounds to Covenant and his members.<br>
[#] Translated abilities into other languages<br>
[#] Now spawns correctly all Covenant members.<br>
[#] Now all Covenant members correctly enter chase mode when Covenant does.<br>
[#] First kill summons "LTG Rocks", rest of victims will be summoned as "Cloaks".<br>
[#] Properly added a minimum distance to be able to kill a player.<br>
[#] "LTG Rocks" can now hit with the Saturn Stick (only on Chase).<br>
[#] Reduced Chase duration (160s - 60s).<br>
[#] Reduced Chase speed (297 - 275).<br>
[#] Increased "Cloaks" Prowl speed (100 - 150).<br>
[#] Fixed "Cloaks" ability, Tackle now stuns survivors for 5s, Cloak will remain freezed for 6s after using it.<br>
-> Survivors can escape sooner by spamming left and right movement keys.<br>
[#] "Cloaks" can mark survivors when tackled.<br>
[#] Changed Danger level to Devastating.<br>

### Male07
[#] Fixed him leaving a NPC causing the NPC to T-Pose for one frame.<br>
[#] Fixed some engine squence warnings related to the slasher's model being set to a plate.<br>

### Speedrunner
[+] Added a new ability: Mining.<br>
-> An ore will spawn in a random position.<br>
-> Speedrunner can start mining this ore to gain 15 - 35 speed after 5 seconds.<br>
-> After that, all the gas cans of the map will get randomly teleported.<br>
-> Survivors can also mine this ore to prevent the above, but the mining duration for them is 10 seconds.<br>
[+] Added new stun and mining animations.<br>

### Bren
[+] Added new Slasher Bren.<br>

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/27ffbd1a-735c-4210-9cad-6bd47e3998c1" />


## Item changes
[#] Allow stacking of effect/duration on most items.<br>
-> Doesn't work with Balkan Boost<br>

### Baby
[#] A random slasher is now teleported instead of always the second one.<br>

### Balkan Boost
[+] Added the Balkan Boost<br>
-> After 30 seconds of waiting, the survivor receive a massive speed boost.<br>
-> When the effect runs out, the survivor is permanently slowed down.<br>

### BeerKeg
[+] Added the beerkeg<br>
-> It deafens all slashers nearby for 25+ seconds<br>
-> Survivors take 50 damage if hit<br>
-> Prepare your ears for the tinnitus<br>

### Benadryl
[+] Added Hat man that spawns when you eat it.<br>
[+] Added all the Shadow voices from SlashCo VR<br>

### Brick
[#] Now it can be used to apply knockback to slashers and break doors.<br>
-> It has a 1/5 chance of breaking when colliding with something.

### Costco Pizza
[+] Added Costco Frozen Pizza<br>
-> Fully blocks any incoming damage (except insta kill) but has a 1/3 chance of breaking<br>

### Deathward
[+] Added a proper death/revive animation.<br>
-> Additionally everyone can now hear you respawn. You better run.<br>
[#] Raised price from `50` to `80` credits.<br>
[#] Allow one to drop the used deathward.<br>

### GasCan
[#] Reduced survivor's speed when holding a gascan to 150.<br>

### Jello Cup
[+] Added Jello Cup<br>
-> Heals 1/3 of your max health (can go above up to 1.5x of max health)<br>
-> Reduces any damage by 10x for a random time between 20 - 50 seconds<br>

### Jonkler Cart
[+] Added Evil Jonkler Cart<br>
-> Alert the slasher with a loud sound.<br>
-> Increases the anger amount of slashers standing around it.<br>

### Newports
[+] Added the Newport Menthols<br>
-> Reduce the amount of fog by 3x for a random time between 140 - 200 seconds.<br>

### Nightvision goggles
[+] Added the Nightvision goggles<br>
-> Takes your item slot in exchange of an enhanced vision in the dark, can be throw away anytime.<br>

### PocketSand
[+] Created a effect for when its used.<br>
-> The effect's range matches the range of where slashers would be blinded<br>

### Porchlight
[+] Added the Porch Light<br>
-> Creates a light so bright that can randomly stun any slasher that makes contact with it.<br>

### Tesla Coil
[+] Added the tesla coil<br>
-> Stuns all slashers on the map for 7 seconds<br>

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/35c91132-177e-4948-889f-bc58634a003d" />

## Offering changes

### Duality
[#] Now requires 2 generators to escape.<br>

## Other changes
[+] Precached a lot of things to reduce in game laggs.<br>
[+] Precached the next map<br>
-> The download of the next map starts in the lobby as soon as it is selected to reduce loading times later on.<br>
[+] Added missing clientside prediction for Impervious<br>
-> Going through doors/players as male07 is now far smoother.<br>
[+] Spectators have an animation and watch the helicopter take off in the lobby.<br>
[+] Implemented a new audiosystem for almost every sound in the gamemode<br>
[+] Support live language changes<br>
[+] Added sound/vision fade in when spawning into a round<br>
[#] Implemented a failsafe in case the slashers or survivors disconnect<br>
-> The game ends if no survivors or slashers exist after 5 minutes<br>
-> If there's enough survivors in-game but not the required slashers, a selection screen would show up to choose a new slasher.
[#] Solved a spectator prediction issue, making movement/noclipping jittery<br>
-> It was a gmod bug<br>
[#] Stopped player from suiciding when the helicopter is taking off in the lobby.<br>
[#] The picked slasher in the lobby can freely spectate instead of being locked in the spectator camera.<br>
[#] Solved an error caused by entities being created too early.<br>
[#] Cleaned up the entire code.<br>
[#] Fixed auto refresh errors/bugs that made development more painful.<br>
[#] Fixed lobby-ready status clipping into player count<br>
[#] Fixed spectators being able to leave noclip<br>
[#] Rendering difficulty colors in the round info screen now<br>
[#] Changed helicopter escape music to use the new audio system<br>
[#] Fixed a game crash caused by a infinite loop if no map was found<br>
[#] Moved a bit away from NW to improve networking and possibly support replays/demos.<br>
[#] Converted almost all .wav files into .mp3 and into mono to solve some 3d sound issues (might also solve #29)<br>
[#] Fixed player model selector being always broken(fixes #33)<br>
[#] Fixed round end panels stacking and never removing the old panel<br>
[#] Fixed helicopter collisions being left behind<br>
-> It's physics object didn't follow the helicopter causing a invisible box with collisions to exist<br>
[#] Syncronized Helicopter voice lines for all players<br>
[#] Fixed a possible error with Princess<br>
[#] Live update points and wins when their changed<br>
[#] Show the ready state of other players in the lobby (if they picked slasher or survivor)<br>
[#] Show the spectator ui to the slasher when their waiting to be spawned.<br>
[#] Fixed `gmod_hands` sometimes spawning and causing errors<br>
[#] Fixed a possible error with an entity having an invalid `PrintName` causing an error when the item is attempted to be dropped<br>
[#] Made all HUDs render differently / in PostHUD to properly show even when the main menu is open.<br>
[#] Made `PLAYER:SetItem` validate the input<br>
[-] Removed all hardcoded `sc_lobby` parts to now allow any map marked as a lobby to be used as one.<br>

## Lua API Changes
This documentation wasn't finished yet<br>

[+] Added `SlashCo.GetBannedSlashers`, `SlashCo.IsSlasherBanned`, `SlashCo.BanSlasher`, `SlashCo.UnbanSlasher` functions<br>
[+] Added `SlashCo.SetGlobalFogMult`, `SlashCo.GetGlobalFogMult`, `SlashCo.SetGlobalFogColor`, `SlashCo.GetGlobalFogColor` functions<br>
[+] Added `Player:SetFogMult`, `Player:GetFogMult`, `Player:MarkAsSeenBySlasher`, `Player:WasSeenBySlasher`, `Player:FindPlayersInView`, `Player:IsStuck` functions<br>
[+] Added `SlashCo.States`, `SlashCo.DifficultyLevel`, `SlashCo.SlasherClass`, `SlashCo.DangerLevel` enums<br>
[+] Added `SlashCo.GetRoundTime`, `SlashCo.IsQuickEscape`, `SlashCo.IsSlowEscape`, `SlashCo.GetRoundStartTime` functions<br>
[+] Added `SlashCo.GetDangerColor`, `SlashCo.GetDangerSound`, `SlashCo.GetNameColor`, `SlashCo.GetClassColor`, `SlashCo.CopyColor` functions<br>
[+] Added `SlashCo.AddDangerLevel` and `SlashCo.AddSlasherClass` funcitons<br>
[+] Added `SlashCo:OnObjectiveComplete(objectiveName)` lua hook<br>
[#] Changed `SlashCo.OfferingData` keys.<br>
\-> Renamed `SO` to `Singularity`<br>
\-> Renamed `DO` to `Duality`<br>
\-> Renamed `SatO` to `Satiation`<br>
[#] Changed all net messages from formats like `mantislashcoSurvivorPings` to `SlashCo:SurvivorPings` as an example<br>

## Mapping changes (slashco.fdg changes)
[+] Added `info_sc_document`, `func_sc_lobby_elevator_ready_zone`, `info_sc_lobby_documentscreen`, `info_sc_lobby_briefingscreen`, `sc_itemstash`, `sc_offertable`, `sc_cagelight`, `sc_effect_sparks`, `info_sc_blackout_trollge_path`(WIP) map entities<br>
[+] Added `IsLobby` & `Normal Lights Name` key fields to `info_sc_settings`<br>
[#] Made `info_sc_helicopter`, `info_sc_helicopter_intro`, `info_sc_helicopter_start` show the actual helicopter model<br>

[-] Removed `hl2mp.fgd` include<br>