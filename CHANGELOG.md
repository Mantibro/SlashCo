## Note
All newly added sounds will be from the SlashCo VR version.

## gameplay changes
[+] A dark fog that dynamically adjusts to the environment lighting.
[+] Added a new item "Tesla Coil"
(It stuns all slashers on the entire map for 20 seconds)
[+] Added a clientside sound that is played when a Slasher sees a survivor the first time.
[+] Added basic slasher documents
(This is still WIP and is unfinished)
[+] Added a status light to the generators showing if their running or not
[+] Added a fuel display to the generators allowing one to see how much fuel is missing
[+] Implemented quick escape reward (10 credits)
[+] Different game intro sounds are played based off the slasher difficulty.
[+] Playing the dangerLevel sound when spawning into a round
[+] Implemented quick escape and slow escape.
(If you escape before the round went on for 10 minutes it counts as a quick escape, if you escape after 20 minutes its a slow escape)
[+] Added ambient sounds which volume and sound track are based off the Slasher's anger.
[#] Disable broken door collisions after it stopped moving
(if you accidentally walked on it previously, your movement would become jittery as the prediction would fail).
[#] Allow one to drop the used deathward
[#] Removed player limit.
[#] New lobby map file (more players spawns)

## Slasher Changes

### Tyler
[+] Added a camera shake to his effect, intensity is based off his distance
[+] Added new sound for when he's below 50 anger
[+] Implement endless chase if the time is up
(when the round time reaches the defined slow time of 20min, this chase is disabled by default)
[+] If a player is holding a fuel can, Tyler will destroy the fuel can first instead of killing the player
[+] Added Tyler theme which is played as background music after the first chase.
[+] Added three new songs from SlashCo VR to play when hes tyler the creator.
[#] Made his HUD effect local and based off his distance to the player
[#] Move all sounds into `slashco/slasher/igor`
[#] Switched all code over to use the new audiosystem and the new anger system
[#] Beacon Arming activates destroyer mode.
[#] On spawn of the escape helicopter, goes perma destroyer.
[#] Improved tyler hide time duration.

### The Watcher
[+] Added footstep sounds from SlashCo VR
[+] Added background music from SlashCo VR
[#] Move all sounds into `slashco/slasher/watcher`
[#] Reduced Prowl speed (200 - 185).

### Princess
[+] If a player is holding a baby, Princess will eat the baby now.
[#] When Princess eats/kills a player or baby, they will be stunned for 4.5 seconds.

### Abomignat
[#] Increased Prowl speed (150 - 200) and Chase speed (293 - 325).
[#] Increased Chase duration (5s - 7s).
[#] Increased Lunge damage (50 - 100).
[#] Increased Crawling speed (350 - 400).

### Amogus
[#] Moved Gascan disguise position to the ground level.
[#] Fixed chase animation not being used.

### Bababooey
[#] Increased Chase speed (298 - 305).

### Borgmire
[#] Increased Chase speed (325 - 335).
[#] Decreased Chase cooldown (8s - 3s).
[#] Now he can freely move and aim when holding a survivor.

### Dolphinman
[+] Added a breathing sound when hiding.
[#] Increased KillDelay (0.25s - 0.50s).
[#] Decreased hunt power gain on kill when hunting (25% - 15%).
[#] Decreased hunt power loss on standing (50% - 25%).
[#] Eyesight decreased. (3 - 2)
[#] Gains 25% hunt power when killing without hunting.
[#] KillDellay is increased to 5s when no hunting.
[#] Start gaining hunt power when the escape helicopter spawns.

### Freesmiley
[#] Balkan Boost users are marked until the effect run out.
[#] Increased Chase duration (5s - 9s).

### Manspider
[#] Increased Prowl speed (150 - 250) and Chase speed (290 - 315).

### Sid
[#] Decreased KillDelay (7s - 5s)

### Thirsty
[#] Increased base Prowl speed (100 - 120) and base Chase speed (260 - 280).
[#] Decreased Pacified duration (same duration of Sid).
[#] Increased max milkies (4 - 6).
[#] After 4 milkies, Thirst meter will not increase anymore and will give you a permanent visibility buff.

### Trollge
[#] Can see the halos of Balkan Boost holders.
[#] On contact with a Balkan Boost, instantly change to stage 3.

### Covenant
[+] Added footstep sounds to covenant and his members.
[#] Translated abilities into other languages
[#] Now spawns correctly all covenant members.
[#] Now all covenant members correctly enter chase mode when Covenant does.
[#] First kill summons "LTG Rocks", rest of victims will be summoned as "Cloaks".
[#] Properly added a minimum distance to be able to kill a player.
[#] "LTG Rocks" can now hit with the Saturn Stick (only on Chase).
[#] Reduced Chase duration (160s - 60s).
[#] Reduced Chase speed (297 - 275).
[#] Increased "Cloaks" Prowl speed (100 - 150).
[#] Fixed "Cloaks" ability, Tackle now stuns survivors for 1.2s, Cloak will remain freezed for 4.5s after using it.
[#] "Cloaks" can mark survivors when tackled.
[#] Changed Danger level to Devastating.

## Item changes

### Baby
[#] A random slasher is now teleported instead of always the second one.

### Balkan Boost
[+] Added the Balkan Boost

### Nightvision goggles
[+] Added the Nightvision goggles

## Offering changes

### Duality
[#] It now requires 2 generators to escape.

## Other changes
[+] Precached a lot of things to reduce in game laggs.
[+] Precached the next map
(The download of the next map starts in the lobby as soon as it is selected to reduce loading times later on).
[+] Added missing clientside prediction for Impervious
(going through doors/players as male07 is now far smoother).
[+] Spectators have an animation and watch the helicopter take off in the lobby.
(going through doors/players as male07 is now far smoother).
[+] Implemented a new audiosystem for lobby and future ambient sounds
[+] Support live language changes
[+] Added sound/vision fade in when spawning into a round
[#] Implemented a failsafe in case the slashers or survivors disconnect
(the game ends if no survivors or slashers exist after 90 seconds)
[#] Solved a spectator prediction issue, making movement/noclipping jittery
(It was a gmod bug)
[#] Stopped player from suiciding when the helicopter is taking off in the lobby.
[#] The picked slasher in the lobby can freely spectate instead of being locked in the spectator camera.
[#] solved an error caused by entities being created too early.
[#] cleaned up the entire code.
[#] Fixed auto refresh errors/bugs that made development more painful.
[#] Fixed lobby-ready status clipping into player count
[#] Fixed spectators being able to leave noclip
[#] Rendering difficulty colors in the round info screen now
[#] Changed helicopter escape music to use the new audio system
[#] Fixed a game crash caused by a infinite loop if no map was found
[#] Moved a bit away from NW to improve networking and possibly support replays/demos.
[#] Converted almost all .wav files into .mp3 and into mono to solve some 3d sound issues (might also solve #29)
[#] Fixed player model selector being always broken(fixes #33)
[#] Fixed round end panels stacking and never removing the old panel
[#] Fixed helicopter collisions being left behind
(It's physics object didn't follow the helicopter causing a invisible box with collisions to exist)
[#] Syncronized Helicopter voice lines for all players
[#] Fixed a possible error with princess
[#] Live update points and wins when their changed
[#] Show the ready state of other players in the lobby (if they picked slasher or survivor)
[#] Show the spectator ui to the slasher when their waiting to be spawned.
[#] Fixed `gmod_hands` sometimes spawning and causing errors
[#] Fixed a bug with particle emitters used for footsteps and decoy causing issues when they don't clean up quick enouth & optimized the code of it to only use a single emitter now.
[-] Removed hardcoded 7-player limit.
(If the helicopter is full, additional players will be somewhat bugged, but it should work fine.)

## Lua API Changes
This documentation wasn't finished yet

[+] Added `SlashCo.States`, `SlashCo.DifficultyLevel`, `SlashCo.SlasherClass`, `SlashCo.DangerLevel` enums
[+] Added `SlashCo.GetDangerColor`, `SlashCo.GetDangerSound`, `SlashCo.GetNameColor`, `SlashCo.GetClassColor` functions
[#] Changed `SlashCo.OfferingData` keys.
\-> Renamed `SO` to `Singularity`
\-> Renamed `DO` to `Duality`
\-> Renamed `SatO` to `Satiation`