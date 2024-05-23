# Ensure the script is run as an administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Module1.ps1`"" -Verb RunAs
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

function Enable-UltimatePerformance {
    # Name of the Ultimate Performance power plan
    $planName = "Ultimate Performance"

    try {
        # Function to extract the GUID from the powercfg output
        function Get-PowerPlanGuid {
            param (
                [string]$planName
            )
            $output = powercfg -list | Select-String -Pattern $planName
            if ($output) {
                # Extract the GUID from the output
                if ($output -match "Power Scheme GUID: ([a-fA-F0-9\-]+)") {
                    return $matches[1]
                }
            }
            return $null
        }

        # Check if the 'Ultimate Performance' power plan exists
        $guid = Get-PowerPlanGuid -planName $planName

        if (-not $guid) {
            # Create the 'Ultimate Performance' power plan
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
            Write-Output "Ultimate Performance power plan created."

            # Check again if the 'Ultimate Performance' power plan now exists
            $guid = Get-PowerPlanGuid -planName $planName
        }

        if ($guid) {
            # Set the 'Ultimate Performance' power plan as active
            powercfg -setactive $guid
            Write-Output "Ultimate Performance power plan enabled with GUID: $guid"
        } else {
            Write-Error "Failed to create or find the Ultimate Performance power plan."
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}

function Set-NeverSleep {
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -monitor-timeout-dc 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
    Write-Host "Screen set to never turn off or go to sleep."
}

function Set-HAGS {
    # Enable Hardware-accelerated GPU scheduling
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    $regName = "HwSchMode"
    $regValue = 2

    # Check if the registry path exists
    if (-Not (Test-Path $regPath)) {
        Write-Host "Registry path does not exist. Creating the path..."
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set the registry value
    try {
        Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord
        Write-Host "Hardware-accelerated GPU scheduling has been enabled successfully."
    } catch {
        Write-Host "Failed to enable Hardware-accelerated GPU scheduling: $_"
    }
}

function Set-StorageSense {
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
Enable-UltimatePerformance
Set-NeverSleep
Set-HAGS
Set-StorageSense
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
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Module2.ps1`"" -Wait