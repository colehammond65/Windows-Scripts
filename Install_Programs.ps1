# Define a list of programs to install
$programsToInstall = Get-Content programs.txt

# Set the error action preference to automatically handle non-terminating errors
$ErrorActionPreference = "Continue"

# Update all installed packages
winget upgrade --all

foreach($program in $programsToInstall) {
  try {
    # Use the winget install command with the --force flag to install the program
    winget install $program --force --quiet
  } catch {
    # If an error occurs, log it so that we can investigate later
    Write-Error "Failed to install $program. Error message: $($_.Exception.Message)"
    pause
  }
}