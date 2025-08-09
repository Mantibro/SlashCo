@echo off

"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmad.exe" create -folder "_workshop/" -out "_workshop.gma"
"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe" update -id "3453013573" -addon "_workshop.gma"
del _workshop.gma
pause