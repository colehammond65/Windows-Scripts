# Get a list of installed programs from the registry
$programs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
                               HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
            Select-Object DisplayName, DisplayVersion, Publisher

# Filter out programs without a publisher or with an empty/null entry
$programs = $programs | Where-Object { $_.DisplayName -and $_.Publisher }

# Format the output as "Publisher.ProgramName"
$output = $programs | ForEach-Object {
    # Clean up the publisher and program name
    $publisher = $_.Publisher -replace '[^a-zA-Z0-9]', ''
    $programName = $_.DisplayName -replace '[^a-zA-Z0-9]', ''
    
    # Combine the publisher and program name
    "$publisher.$programName"
}

# Save the output to a text file named "programs.txt" in the current directory
$output | Out-File ".\programs.txt" -Encoding utf8

# Optional: Display the output in the console
$output
