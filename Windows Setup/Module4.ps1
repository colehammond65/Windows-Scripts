# Ensure the script is run as an administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\module4.ps1`"" -Verb RunAs
    exit
}

# Function to calculate directory size
function Get-DirectorySize {
    param ($path)
    try {
        if (Test-Path $path) {
            $size = (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            return $size
        }
    } catch {
        return 0
    }
}

# Function to clear a directory and return freed space
function Clear-Directory {
    param ($path)
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

$totalFreedSpace = 0

Write-Host "Cleaning, please wait..."

# Clear Windows Temp folders
$totalFreedSpace += Clear-Directory "C:\Windows\Temp"
$totalFreedSpace += Clear-Directory "$env:TEMP"
$totalFreedSpace += Clear-Directory "$env:TMP"

# Clear user Temp folders
$totalFreedSpace += Clear-Directory "$env:USERPROFILE\AppData\Local\Temp"

# Clear Recycle Bin
try {
    $recycleBin = New-Object -ComObject Shell.Application
    $recycleBinItems = $recycleBin.Namespace(0xA).Items()
    $recycleBinSize = ($recycleBinItems | Measure-Object -Property Size -Sum).Sum
    $recycleBinItems | ForEach-Object { $_.InvokeVerb("empty") }
    $totalFreedSpace += $recycleBinSize
} catch {}

# Clear Windows Update Cache
$totalFreedSpace += Clear-Directory "C:\Windows\SoftwareDistribution\Download"

# Clear Nvidia Shader Cache
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\NVIDIA\DXCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\NVIDIA\GLCache"

# Clear AMD Shader Cache
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\AMD\GLCache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\AMD\DxCache"

# Clear Intel Shader Cache
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Intel\ShaderCache"

# Clear other common shader cache locations
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache"

# Additional Cleanups inspired by BleachBit
$totalFreedSpace += Clear-Directory "$env:APPDATA\Microsoft\Windows\Recent"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Microsoft\Office\Recent"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
$totalFreedSpace += Clear-Directory "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
$totalFreedSpace += Clear-Directory "$env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\cache2"

# Additional BleachBit Cleaners
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

# Convert bytes to a human-readable format
function Convert-Size {
    param ($size)
    if ($size -ge 1TB) { return "{0:N2} TB" -f ($size / 1TB) }
    if ($size -ge 1GB) { return "{0:N2} GB" -f ($size / 1GB) }
    if ($size -ge 1MB) { return "{0:N2} MB" -f ($size / 1MB) }
    if ($size -ge 1KB) { return "{0:N2} KB" -f ($size / 1KB) }
    return "$size bytes"
}

$freedSpaceReadable = Convert-Size $totalFreedSpace
Write-Host "Total space freed: $freedSpaceReadable"

# Restart the computer
Write-Host "Restarting the computer to complete the process..."
shutdown /r /t 60