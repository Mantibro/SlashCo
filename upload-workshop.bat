@echo off

REM curl -o _workshop/maps/sc_lobby_v2.bsp https://slashco-maps.raphaelit7.com/sc_lobby_v2.bsp?download=true

"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmad.exe" create -folder "_workshop/" -out "_workshop.gma"
"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe" update -id "2844428843" -addon "_workshop.gma"
del _workshop.gma
pause