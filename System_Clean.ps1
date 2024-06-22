# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as administrator, restart the script with elevated privileges
if (-not (Test-Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = [Environment]::GetCommandLineArgs() -join ' '

    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $arguments" -Verb RunAs

    # Exit the current script
    exit
}

# Function to calculate directory size
function Get-DirectorySize {
    param ($path)
    try {
        if (Test-Path -Path $path) {
            $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            if ($items) {
                $validItems = $items | Where-Object { $_.PSIsContainer -eq $false -and $_.GetType().GetProperty("Length") -ne $null }
                if ($validItems) {
                    $size = ($validItems | Measure-Object -Property Length -Sum).Sum
                    return [math]::Max([int64]0, [int64]$size)  # Ensure the size is non-negative and use Int64
                } else {
                    return 0  # No valid items found with "Length" property, return 0
                }
            } else {
                return 0  # No items found, return 0
            }
        } else {
            return 0  # Directory doesn't exist, return 0
        }
    } catch {
        return 0  # Error occurred, return 0
    }
}

# Function to clear a directory and return freed space
function Clear-Directory {
    param ($path)
    Write-Host "Cleaning directory: $path"  # Show the current directory being processed
    try {
        $initialSize = Get-DirectorySize $path
        if ($initialSize -gt 0) {
            Get-ChildItem $path -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
        $finalSize = Get-DirectorySize $path
        return $initialSize - $finalSize
    } catch {
        return 0
    }
}

function Invoke-DiskCleanup {
    # Define the registry keys and values to apply
    $registryKeys = @(
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Content Indexer Cleaner"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\D3D Shader Cache"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Device Driver Packages"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Diagnostic Data Viewer database files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\DownloadsFolder"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Language Pack"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\RetailDemo Offline Content"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files"
            Name = "StateFlags0007"
            Value = "00000002"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files"
            Name = "StateFlags0007"
            Value = "00000002"
        }
    )

    # Apply each registry setting
    foreach ($key in $registryKeys) {
        New-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Value -PropertyType DWORD -Force | Out-Null
    }

    # Run Disk Cleanup
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:7"
}

$totalFreedSpace = 0

Write-Host "Cleaning, please wait..."

# Clear Temp folders
$totalFreedSpace += Clear-Directory "C:\Windows\Temp"
$totalFreedSpace += Clear-Directory "$env:TEMP"
$totalFreedSpace += Clear-Directory "$env:TMP"
$totalFreedSpace += Clear-Directory "$env:USERPROFILE\AppData\Local\Temp"

# Clear Windows Update Cache
$totalFreedSpace += Clear-Directory "C:\Windows\SoftwareDistribution\Download"

# Clear Shader Cache
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\NVIDIA\DXCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\NVIDIA\GLCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\AMD\GLCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\AMD\DxCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Intel\ShaderCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache"

#Misc
$totalFreedSpace += Clear-Directory "$env:APPDATA\Microsoft\Windows\Recent"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Microsoft\Office\Recent"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\cache2"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Temp\*"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\CrashDumps"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Microsoft\Windows\Cookies"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Microsoft\Windows\Recent"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\history.dat"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\cookies.sqlite"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Packages\*\AC\INetCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Packages\*\AC\INetCookies"

# Clear Recycle Bin
try {
    $recycleBin = New-Object -ComObject Shell.Application
    $recycleBinItems = $recycleBin.Namespace(0xA).Items()
    $recycleBinSize = ($recycleBinItems | Measure-Object -Property Size -Sum).Sum
    $recycleBinItems | ForEach-Object { $_.InvokeVerb("empty") }
    $totalFreedSpace += [math]::Max([int64]0, [int64]$recycleBinSize)  # Ensure the size is non-negative and use Int64
} catch {
    Write-Error "Error clearing Recycle Bin: $_"
}

# Convert bytes to a human-readable format
function Convert-Size {
    param ($size)
    if ($size -ge 1TB) { return "{0:N2} TB" -f ($size / 1TB) }
    if ($size -ge 1GB) { return "{0:N2} GB" -f ($size / 1GB) }
    if ($size -ge 1MB) { return "{0:N2} MB" -f ($size / 1MB) }
    if ($size -ge 1KB) { return "{0:N2} KB" -f ($size / 1KB) }
    return "$size bytes"
}

# Print end screen and run disk clean-up
$freedSpaceReadable = Convert-Size $totalFreedSpace
Write-Host "Cleanup Complete"
Write-Host "Total space freed: $freedSpaceReadable"
Write-Host "Running Disk Clean-up for good measure"
Write-Host "Press any key to close..."
Invoke-DiskCleanup
[void][System.Console]::ReadKey($true)