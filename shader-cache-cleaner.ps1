# Requires administrator privileges
# Run PowerShell as Administrator to use this script

$ErrorActionPreference = "SilentlyContinue"

# Common shader cache locations
$cachePaths = @(
    "$env:LOCALAPPDATA\D3DSCache",
    "$env:LOCALAPPDATA\NVIDIA\GLCache",
    "$env:LOCALAPPDATA\AMD\GLCache",
    "$env:LOCALAPPDATA\AMD\DxCache",
    "$env:LOCALAPPDATA\AMD\VkCache",
    "$env:LOCALAPPDATA\Intel\GLCache",
    "$env:PROGRAMDATA\NVIDIA Corporation\NV_Cache",
    # Steam shader cache
    "$env:PROGRAMFILES (x86)\Steam\steamapps\shadercache",
    # Origin shader cache
    "$env:PROGRAMDATA\Origin\ShaderCache",
    # Epic Games shader cache
    "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\Cache"
)

Write-Host "Starting shader cache cleanup..." -ForegroundColor Green
Write-Host "This script will remove shader caches for DirectX, OpenGL, and Vulkan" -ForegroundColor Yellow
Write-Host "Please close any games or graphics applications before proceeding." -ForegroundColor Yellow

$totalSpaceFreed = 0

foreach ($path in $cachePaths) {
    if (Test-Path $path) {
        # Calculate size before deletion
        $size = (Get-ChildItem -Path $path -Recurse | Measure-Object -Property Length -Sum).Sum
        $sizeInMB = [math]::Round($size / 1MB, 2)
        
        # Attempt to remove all files and folders in the cache directory
        Write-Host "Clearing cache in: $path" -ForegroundColor Cyan
        try {
            Remove-Item -Path "$path\*" -Recurse -Force
            Write-Host "Successfully cleared $sizeInMB MB" -ForegroundColor Green
            $totalSpaceFreed += $size
        }
        catch {
            Write-Host "Error clearing cache in $path: $_" -ForegroundColor Red
        }
    }
}

$totalSpaceFreedMB = [math]::Round($totalSpaceFreed / 1MB, 2)
Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "Total space freed: $totalSpaceFreedMB MB" -ForegroundColor Green
Write-Host "`nNote: Some shader caches may be regenerated when you next run applications." -ForegroundColor Yellow

# Pause to keep the window open
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
