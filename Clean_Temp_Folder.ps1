$tempFolder = "$env:temp"

# Get all items in the temp folder
$tempItemsBefore = Get-ChildItem $tempFolder -Recurse

# Remove all items in the temp folder
foreach ($item in $tempItemsBefore) {
    # Skip the item if it cannot be deleted
    if (!(Remove-Item $item.FullName -Recurse -Force -ErrorAction SilentlyContinue)) {
        continue
    }
}

# Confirm that the temp folder is empty
$tempItemsAfter = Get-ChildItem $tempFolder
if ($tempItemsAfter.Count -le $tempItemsBefore.Count) {
    Write-Host "Temp folder cleaned."
    pause
}
else {
    Write-Host "The temp folder could not be emptied."
    pause
}