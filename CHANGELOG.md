## Notes
All newly added sounds will be from the SlashCo VR version.<br>

> [!WARNING]
> When we release these changes, revert `gamemodes/slashco/slashco.txt` -> `workshopid` back to the main addon -> `2844428843`

## gameplay changes
[+] A dark fog that dynamically adjusts to the environment lighting.<br>
[+] Added a new item "Tesla Coil"<br>
(It stuns all slashers on the entire map for 20 seconds)<br>
[+] Added a clientside sound that is played when a Slasher sees a survivor the first time.<br>
[+] Added basic slasher documents<br>
(This is still WIP and is unfinished)<br>
[+] Added a status light to the generators showing if their running or not<br>
[+] Added a fuel display to the generators allowing one to see how much fuel is missing<br>
[+] Implemented quick escape reward (10 credits)<br>
[+] Different game intro sounds are played based off the slasher difficulty.<br>
[+] Playing the dangerLevel sound when spawning into a round<br>
[+] Implemented quick escape and slow escape.<br>
(If you escape before the round went on for 10 minutes it counts as a quick escape, if you escape after 20 minutes its a slow escape)<br>
[+] Added ambient sounds which volume and sound track are based off the Slasher's anger.<br>
[+] After `15` minutes(the warning time) of playing, the player receives a warning sound indicating that they got 5 minutes left before they would have a slow escape<br>
[+] When the warning time is reached, fuel cans will start making noises making it more easy to find them<br>
[#] You can now hold the USE key when fuling a generator instead of having to let go of it and press it again<br>
[#] Disable broken door collisions after it stopped moving<br>
(if you accidentally walked on it previously, your movement would become jittery as the prediction would fail).<br>
[#] Allow one to drop the used deathward<br>
[#] Removed player limit.<br>
[#] New lobby map file (more players spawns)<br>
[#] Make the chat global in the lobby<br>

## Slasher Changes

### Tyler
[+] Added a camera shake to his effect, intensity is based off his distance<br>
[+] Added new sound for when he's below 50 anger<br>
[+] Implement endless chase if the time is up<br>
(when the round time reaches the defined slow time of 20min, this chase is disabled by default)<br>
[+] If a player is holding a fuel can, Tyler will destroy the fuel can first instead of killing the player<br>
[+] Added Tyler theme which is played as background music after the first chase.<br>
[+] Added three new songs from SlashCo VR to play when hes tyler the creator.<br>
[#] Made his HUD effect local and based off his distance to the player<br>
[#] Move all sounds into `slashco/slasher/igor`<br>
[#] Switched all code over to use the new audiosystem and the new anger system<br>
[#] When the escape helicopter is called, activates endless chase.<br>
[#] Improved tyler hide time duration.<br>
[#] He will **always** spawn after `10` seconds into the round<br>
[#] The Helicopter will **always** arrive after `30` seconds when escaping<br>

### The Watcher
[+] Added footstep sounds from SlashCo VR<br>
[+] Added background music from SlashCo VR<br>
[#] Move all sounds into `slashco/slasher/watcher`<br>
[#] Reduced Prowl speed (200 - 185).<br>

### Princess
[+] If a player is holding a baby, Princess will eat the baby now.<br>
[+] Added new footstep sounds<br>
[#] When Princess eats/kills a player or baby, they will be stunned for 4.5 seconds.<br>

### Abomignat
[#] Increased Prowl speed (150 - 200) and Chase speed (293 - 325).<br>
[#] Increased Chase duration (5s - 7s).<br>
[#] Increased Lunge damage (50 - 100).<br>
[#] Increased Crawling speed (350 - 400).<br>

### Amogus
[#] Moved Gascan disguise position to the ground level.<br>
[#] Fixed chase animation not being used.<br>

### Bababooey
[#] Increased Chase speed (298 - 305).<br>

### Borgmire
[#] Increased Chase speed (325 - 335).<br>
[#] Decreased Chase cooldown (8s - 3s).<br>
[#] Now he can freely move and aim when holding a survivor.<br>

### Dolphinman
[+] Added a breathing sound when hiding.<br>
[+] Added proper footstep sounds<br>
[#] Increased KillDelay (0.25s - 0.50s).<br>
[#] Decreased hunt power gain on kill when hunting (25% - 15%).<br>
[#] Decreased hunt power loss on standing (50% - 25%).<br>
[#] Eyesight decreased. (3 - 2)<br>
[#] Gains 25% hunt power when killing without hunting.<br>
[#] KillDellay is increased to 5s when no hunting.<br>
[#] Start gaining hunt power when the escape helicopter spawns.<br>

### Freesmiley
[#] Balkan Boost users are marked until the effect run out.<br>
[#] Increased Chase duration (5s - 9s).<br>

### Manspider
[#] Increased Prowl speed (150 - 250) and Chase speed (290 - 315).<br>

### Sid
[#] Decreased KillDelay (7s - 5s)<br>

### Thirsty
[#] Increased base Prowl speed (100 - 120) and base Chase speed (260 - 280).<br>
[#] Decreased Pacified duration (same duration of Sid).<br>
[#] Increased max milkies (4 - 6).<br>
[#] After 4 milkies, Thirst meter will not increase anymore and will give you a permanent visibility buff.<br>

### Trollge
[+] Added footstep sounds from SlashCo VR<br>
[+] Added background music from SlashCo VR<br>
[+] Added two sounds for when he's blinded by pocket sand<br>
[#] Can see the halos of Balkan Boost holders.<br>
[#] On contact with a Balkan Boost, instantly change to stage 3.<br>
[#] Switched all sounds to use the new audiosystem.<br>
[#] Move all sounds into `slashco/slasher/trollge`<br>
[#] Optimized his code slightly<br>

### Covenant
[+] Added footstep sounds to covenant and his members.<br>
[#] Translated abilities into other languages<br>
[#] Now spawns correctly all covenant members.<br>
[#] Now all covenant members correctly enter chase mode when Covenant does.<br>
[#] First kill summons "LTG Rocks", rest of victims will be summoned as "Cloaks".<br>
[#] Properly added a minimum distance to be able to kill a player.<br>
[#] "LTG Rocks" can now hit with the Saturn Stick (only on Chase).<br>
[#] Reduced Chase duration (160s - 60s).<br>
[#] Reduced Chase speed (297 - 275).<br>
[#] Increased "Cloaks" Prowl speed (100 - 150).<br>
[#] Fixed "Cloaks" ability, Tackle now stuns survivors for 1.2s, Cloak will remain freezed for 4.5s after using it.<br>
[#] "Cloaks" can mark survivors when tackled.<br>
[#] Changed Danger level to Devastating.<br>

### Male07
[#] Fixed him leaving a NPC causing the NPC to T-Pose for one frame.<br>
[#] Fixed some engine squence warnings related to the slasher's model being set to a plate.<br>

## Item changes

### Baby
[#] A random slasher is now teleported instead of always the second one.<br>

### Balkan Boost
[+] Added the Balkan Boost<br>

### Nightvision goggles
[+] Added the Nightvision goggles<br>

### Deathward
[+] Added a proper death/revive animation.<br>
(Additionally everyone can now hear you respawn. You better run.)<br>
[#] Raised price from `50` to `80` credits.<br>
[#] Allow one to drop the used deathward.<br>

### PocketSand
[+] Created a effect for when its used.<br>
(The effect's range matches the range of where slashers would be blinded)<br>

### Benadryl
[+] Added Hat man that spawns when you eat it.<br>
[+] Added all the Shadow voices from SlashCo VR<br>

## Offering changes

### Duality
[#] It now requires 2 generators to escape.<br>

## Other changes
[+] Precached a lot of things to reduce in game laggs.<br>
[+] Precached the next map<br>
(The download of the next map starts in the lobby as soon as it is selected to reduce loading times later on).<br>
[+] Added missing clientside prediction for Impervious<br>
(going through doors/players as male07 is now far smoother).<br>
[+] Spectators have an animation and watch the helicopter take off in the lobby.<br>
(going through doors/players as male07 is now far smoother).<br>
[+] Implemented a new audiosystem for lobby and future ambient sounds<br>
[+] Support live language changes<br>
[+] Added sound/vision fade in when spawning into a round<br>
[#] Implemented a failsafe in case the slashers or survivors disconnect<br>
(the game ends if no survivors or slashers exist after 90 seconds)<br>
[#] Solved a spectator prediction issue, making movement/noclipping jittery<br>
(It was a gmod bug)<br>
[#] Stopped player from suiciding when the helicopter is taking off in the lobby.<br>
[#] The picked slasher in the lobby can freely spectate instead of being locked in the spectator camera.<br>
[#] solved an error caused by entities being created too early.<br>
[#] cleaned up the entire code.<br>
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
(It's physics object didn't follow the helicopter causing a invisible box with collisions to exist)<br>
[#] Syncronized Helicopter voice lines for all players<br>
[#] Fixed a possible error with princess<br>
[#] Live update points and wins when their changed<br>
[#] Show the ready state of other players in the lobby (if they picked slasher or survivor)<br>
[#] Show the spectator ui to the slasher when their waiting to be spawned.<br>
[#] Fixed `gmod_hands` sometimes spawning and causing errors<br>
[#] Fixed a bug with particle emitters used for footsteps and decoy causing issues when they don't clean up quick enouth & optimized the code of it to only use a single emitter now.<br>
[#] Fixed a error caused by the console using the `say` command.<br>
[-] Removed hardcoded 7-player limit.<br>
(If the helicopter is full, additional players will be somewhat bugged, but it should work fine.)<br>

## Lua API Changes
This documentation wasn't finished yet<br>

[+] Added `SlashCo.SetGlobalFogMult`, `SlashCo.GetGlobalFogMult`, `SlashCo.SetGlobalFogColor`, `SlashCo.GetGlobalFogColor` functions<br>
[+] Added `Player:SetFogMult`, `Player:GetFogMult`, `Player:MarkAsSeenBySlasher`, `Player:WasSeenBySlasher`, `Player:FindPlayersInView`, `Player:IsStuck` functions<br>
[+] Added `SlashCo.States`, `SlashCo.DifficultyLevel`, `SlashCo.SlasherClass`, `SlashCo.DangerLevel` enums<br>
[+] Added `SlashCo.GetRoundTime`, `SlashCo.IsQuickEscape`, `SlashCo.IsSlowEscape`, `SlashCo.GetRoundStartTime` functions<br>
[+] Added `SlashCo.GetDangerColor`, `SlashCo.GetDangerSound`, `SlashCo.GetNameColor`, `SlashCo.GetClassColor`, `SlashCo.CopyColor` functions<br>
[#] Changed `SlashCo.OfferingData` keys.<br>
\-> Renamed `SO` to `Singularity`<br>
\-> Renamed `DO` to `Duality`<br>
\-> Renamed `SatO` to `Satiation`<br>
