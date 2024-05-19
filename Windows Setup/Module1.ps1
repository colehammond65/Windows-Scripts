# Ensure the script is run as an administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\module1.ps1`"" -Verb RunAs
    exit
}

# Main script content
function Set-SystemName {
    $newName = Read-Host -Prompt "Enter the new system name"
    try {
        Rename-Computer -NewName $newName -Force -PassThru
        Write-Host "System name set to $newName. A restart is required for this change to take effect."
    } catch {
        Write-Host "Failed to rename the computer. Please run this script as an administrator." -ForegroundColor Red
    }
}

function Disable-FocusAssist {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    New-ItemProperty -Path $path -Name "NOC_GLOBAL_SETTING_TOASTS_ENABLED" -Value 1 -PropertyType DWORD -Force
    Write-Host "Focus Assist disabled."
}

function Set-NeverSleep {
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -monitor-timeout-dc 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
    Write-Host "Screen set to never turn off or go to sleep."
}

function Set-HighPerformancePowerPlan {
    powercfg -setactive SCHEME_MIN
    Write-Host "Power plan set to High performance."
}

function Configure-StorageSense {
    $storageSensePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
    if (-not (Test-Path $storageSensePath)) {
        New-Item -Path $storageSensePath -Force | Out-Null
    }
    New-ItemProperty -Path $storageSensePath -Name "01" -Value 1 -PropertyType DWORD -Force
    New-ItemProperty -Path $storageSensePath -Name "2048" -Value 1 -PropertyType DWORD -Force
    New-ItemProperty -Path $storageSensePath -Name "2064" -Value 1 -PropertyType DWORD -Force
    New-ItemProperty -Path $storageSensePath -Name "2049" -Value 1 -PropertyType DWORD -Force
    Write-Host "Storage Sense enabled and configured to run daily and delete temp files after one day."
}

function Disable-WindowsTimeline {
    $timelinePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Timeline"
    if (-not (Test-Path $timelinePath)) {
        New-Item -Path $timelinePath -Force | Out-Null
    }
    New-ItemProperty -Path $timelinePath -Name "EnableActivityFeed" -Value 0 -PropertyType DWORD -Force
    New-ItemProperty -Path $timelinePath -Name "PublishUserActivities" -Value 0 -PropertyType DWORD -Force
    New-ItemProperty -Path $timelinePath -Name "UploadUserActivities" -Value 0 -PropertyType DWORD -Force
    Write-Host "Windows Timeline disabled."
}

function Enable-ClipboardHistory {
    $clipboardPath = "HKCU:\Software\Microsoft\Clipboard"
    if (-not (Test-Path $clipboardPath)) {
        New-Item -Path $clipboardPath -Force | Out-Null
    }
    New-ItemProperty -Path $clipboardPath -Name "EnableClipboardHistory" -Value 1 -PropertyType DWORD -Force
    Write-Host "Clipboard History enabled."
}

function Disable-MouseAcceleration {
    $mousePath = "HKCU:\Control Panel\Mouse"
    if (-not (Test-Path $mousePath)) {
        New-Item -Path $mousePath -Force | Out-Null
    }
    New-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value 0 -PropertyType String -Force
    New-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value 0 -PropertyType String -Force
    New-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value 0 -PropertyType String -Force
    Write-Host "Mouse Acceleration disabled."
}

function Set-NetworkPrivate {
    $networkListManager = New-Object -ComObject "HNetCfg.HNetShare.1"
    $networkConnections = Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=TRUE"
    foreach ($connection in $networkConnections) {
        $network = $networkListManager.EnumEveryConnection | Where-Object { $_.Name -eq $connection.Description }
        if ($network -ne $null) {
            $network = [WMI]$network
            $network.SetCategory(1)
        } else {
            Write-Host "Unable to set network category for: $($connection.Description)" -ForegroundColor Yellow
        }
    }
    Write-Host "Current network set to private."
}

function Enable-DarkMode {
    $personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (-not (Test-Path $personalizePath)) {
        New-Item -Path $personalizePath -Force | Out-Null
    }
    New-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme" -Value 0 -PropertyType DWORD -Force
    New-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 0 -PropertyType DWORD -Force
    Write-Host "Dark mode enabled."
}

function Enable-SetTimezoneAutomatically {
    Set-Service tzautoupdate -StartupType Automatic
    Start-Service tzautoupdate
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 2
    Write-Host "Set timezone automatically enabled."
}

function Enable-24HourTime {
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "HH:mm"
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "HH:mm:ss"
    Write-Host "24-hour time format enabled."
}

function Disable-GameMode {
    $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $gameBarPath)) {
        New-Item -Path $gameBarPath -Force | Out-Null
    }
    New-ItemProperty -Path $gameBarPath -Name "AutoGameModeEnabled" -Value 0 -PropertyType DWORD -Force
    Write-Host "Game Mode disabled."
}

# Main script execution
Set-SystemName
Disable-FocusAssist
Set-NeverSleep
Set-HighPerformancePowerPlan
Configure-StorageSense
Disable-WindowsTimeline
Enable-ClipboardHistory
Disable-MouseAcceleration
Set-NetworkPrivate
Enable-DarkMode
Enable-SetTimezoneAutomatically
Enable-24HourTime
Disable-GameMode

Write-Host "Configuration complete. Some changes may require a restart to take effect."

# Start Module 2
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\module2.ps1`"" -Wait