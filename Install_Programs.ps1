# Read the list of programs from the text file
$programs = Get-Content -Path "programs.txt"

# Install each program using Winget
foreach ($program in $programs) {
    Write-Host "Installing $program ..."
    winget install $program
}
pause