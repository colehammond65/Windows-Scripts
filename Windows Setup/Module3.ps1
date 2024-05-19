# Ensure the script is run as an administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\module3.ps1`"" -Verb RunAs
    exit
}

# Function to install programs with winget
function Install-Programs {
    param (
        [string[]]$programs
    )
    foreach ($program in $programs) {
        if ($program) {
            Write-Host "Installing $program..."
            winget install --id $program --silent --accept-source-agreements --accept-package-agreements
        }
    }
    Write-Host "All specified programs have been installed."
}

# Read programs from the file
$programsFile = "$PSScriptRoot\programs.txt"
if (-Not (Test-Path $programsFile)) {
    Write-Host "The file 'programs.txt' was not found in the script directory." -ForegroundColor Red
    exit
}

$programList = Get-Content -Path $programsFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

# Install the programs
Install-Programs -programs $programList

# Start Module 4
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\module4.ps1`"" -Wait