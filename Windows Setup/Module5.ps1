# Ensure the script is run as an administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Module5.ps1`"" -Verb RunAs
    exit
}

# Restart the computer
Write-Host "Restarting the computer to complete the process..."
shutdown /r /t 60