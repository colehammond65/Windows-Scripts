#Import the Active Directory module
Import-Module ActiveDirectory

#Prompt for the user to disable and remove from groups
$username = Read-Host "Enter the username"
$user = Get-ADUser -Identity $username

#Check if the user was found
if ($user -eq $null) {
    # Display an error message
    Write-Error "User not found"
}
else {
    # Get the distribution groups the user is a member of
    $groups = Get-ADPrincipalGroupMembership -Identity $user | Where-Object {$_.GroupCategory -eq "Distribution"}

    # Remove the user from each group
    foreach ($group in $groups) {
        Remove-ADPrincipalGroupMembership -Identity $user -MemberOf $group
    }

    # Disable the user
    Disable-ADAccount -Identity $user
}