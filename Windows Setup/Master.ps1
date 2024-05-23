# URLs of the scripts
$scriptUrls = @(
    "https://raw.githubusercontent.com/colehammond65/PowerShell-Scripts/main/Windows%20Setup/bootstrap.bat",
    "https://raw.githubusercontent.com/colehammond65/PowerShell-Scripts/main/Windows%20Setup/Module1.ps1",
    "https://raw.githubusercontent.com/colehammond65/PowerShell-Scripts/main/Windows%20Setup/Module2.ps1",
    "https://raw.githubusercontent.com/colehammond65/PowerShell-Scripts/main/Windows%20Setup/Module3.ps1",
    "https://raw.githubusercontent.com/colehammond65/PowerShell-Scripts/main/Windows%20Setup/Module4.ps1",
    "https://raw.githubusercontent.com/colehammond65/PowerShell-Scripts/main/Windows%20Setup/programs.txt"
)

# Get the current user's Desktop folder path
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$scriptsPath = [System.IO.Path]::Combine($desktopPath, "PowerShellScripts")

# Create the PowerShellScripts directory if it doesn't exist
if (-not (Test-Path -Path $scriptsPath)) {
    New-Item -ItemType Directory -Path $scriptsPath | Out-Null
}

foreach ($url in $scriptUrls) {
    $scriptName = [System.IO.Path]::GetFileName($url)
    $scriptPath = [System.IO.Path]::Combine($scriptsPath, $scriptName)

    # Download the script
    Invoke-WebRequest -Uri $url -OutFile $scriptPath

    # Unblock the script (if necessary)
    Unblock-File -Path $scriptPath
}

# Ensure Module1.ps1 exists before trying to run it
$module1Path = [System.IO.Path]::Combine($scriptsPath, "Module1.ps1")
if (Test-Path -Path $module1Path) {
    # Execute the Module1.ps1 script with elevated privileges
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$module1Path`"" -Verb RunAs
} else {
    Write-Host "Module1.ps1 not found at path: $module1Path"
}
