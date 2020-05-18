powershell /c compress-archive .\* game.zip -f

cmd /c Xcopy /E /I "C:\Program Files\Love" .\dist

powershell /c mv game.zip .\dist\game.love

cmd /c copy /b .\dist\love.exe+.\dist\game.love .\dist\game.exe
cmd /c del /F .\dist\readme.txt .\dist\changes.txt .\dist\love.exe .\dist\lovec.exe .\dist\Uninstall.exe .\dist\game.love