# Define a list of programs to install
$programsToInstall = Get-Content programs.txt

# Set the error action preference to automatically handle non-terminating errors
$ErrorActionPreference = "Continue"

# Update all installed packages
winget update --all

# Use the winget show command to check if each program is already installed
foreach($program in $programsToInstall) {
  try {
    $showOutput = winget show $program
    if($showOutput -notmatch "not installed") {
      # If the program is already installed, skip it
      continue
    }

    # Use the winget install command with the --force flag to install the program
    winget install $program --force
  } catch {
    # If an error occurs, log it so that we can investigate later
    Write-Error "Failed to install $program. Error message: $($_.Exception.Message)"
  }
}