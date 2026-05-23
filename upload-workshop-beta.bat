@echo off

REM curl -o _workshop/maps/sc_lobby_v2.bsp https://slashco-maps.raphaelit7.com/sc_lobby_v2.bsp?download=true
COPY gamemodes\slashco\slashco.txt _workshop\gamemodes\slashco\slashco.txt /y

REM replace gamemode info contents for beta upload
cmd /c powershell -Command "(Get-Content _workshop\gamemodes\slashco\slashco.txt) -replace '\"title\"\t+\"SlashCo\"','\"title\"		\"SlashCo (Beta)\"' | Set-Content _workshop\gamemodes\slashco\slashco.txt"
cmd /c powershell -Command "(Get-Content _workshop\gamemodes\slashco\slashco.txt) -replace '\"workshopid\"\t+\"2844428843\"','\"workshopid\"	\"3453013573\"' | Set-Content _workshop\gamemodes\slashco\slashco.txt"

"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmad.exe" create -folder "_workshop/" -out "_workshop.gma"
"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe" update -id "3453013573" -addon "_workshop.gma"
del _workshop.gma
pause