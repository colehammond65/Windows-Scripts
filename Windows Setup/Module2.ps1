# Ensure the script is run as an administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Module2.ps1`"" -Verb RunAs
    exit
}

function Update-Windows {
    Write-Host "Updating Windows..."
    Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot
    Write-Host "Windows update completed."
}

function Update-MicrosoftStoreApps {
    Write-Host "Updating Microsoft Store apps..."
    $packages = Get-AppxPackage | Where-Object { $_.IsFramework -eq $false }
    foreach ($package in $packages) {
        Write-Host "Updating $($package.Name)..."
        try {
            Add-AppxPackage -DisableDevelopmentMode -Register "$($package.InstallLocation)\AppXManifest.xml"
        } catch {
            Write-Host "Failed to update $($package.Name). Error: $_" -ForegroundColor Red
        }
    }
    Write-Host "Microsoft Store apps update completed."
}

function Update-EverythingElse {
    Write-Host "Updating other software using winget..."
    winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
    Write-Host "Winget updates completed."
}

# Main script execution
Update-Windows
Update-MicrosoftStoreApps
Update-EverythingElse

Write-Host "All updates completed."

# Start Module 3
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Module3.ps1`"" -Wait
