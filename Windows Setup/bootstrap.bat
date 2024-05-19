@echo off
set "script_path=%~dp0\Module1.ps1"
echo Set UAC = CreateObject("Shell.Application") > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "powershell.exe", "-ExecutionPolicy Bypass -File ""%script_path%""", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
pause
