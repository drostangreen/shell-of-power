# Replaces the old method of replacing ImmutableID
# Done after deleting on-prem AD account and restoring cloud only to retain email

# The Tenant ID from the Overview page of Entra
$TENANTID = Read-Host -Prompt "Enter Tenant ID from Entra ID"

# Ask for CSV to use with User IDs. Enter to skip and enter manually
$filePath = Read-Host -Prompt "File path for .csv file with user ids (Enter to skip)"

if ([string]::IsNullOrEmpty($filePath)) {
    # From each user's page in Entra | Also accepts UPN
    # Can have one or as many as needed just keep same syntax
    Write-Host "Enter list of User IDs seperated by commas (e.g. userid1,userid2,userid3)"
    Write-Host "User IDs can be Object IDs or UPNs"
    $listInput = Read-Host -Prompt "User IDs"
    $OBJECTIDs = $listInput -split ',' | ForEach-Object { $_.Trim() }
} else {
    $columnName = Read-Host -Prompt "Name of the Column with the User Ids"
    $OBJECTIDs_file = Import-Csv -Path $filePath
    $OBJECTIDs = $OBJECTIDs_file.$columnName
}


# Connect to Graph API and grant required permissions
Connect-MgGraph -TenantId $TENANTID -Scopes "Group.Read.All, Group.ReadWrite.All, User.Read.All, User.ReadWrite.All, Directory.Read.All, Directory.ReadWrite.All"

# Set ImmutableID to $null
foreach ($OBJECTID in $OBJECTIDs) {
	Invoke-MgGraphRequest -Method PATCH -Uri https://graph.microsoft.com/v1.0/Users/$OBJECTID -Body @{OnPremisesImmutableId = $null}
}

# View the ImmutableID status on each user
foreach ($OBJECTID in $OBJECTIDs) {
	Get-MgUser -UserId $OBJECTID -Property UserPrincipalName,OnPremisesImmutableId | Select-Object UserPrincipalName,OnPremisesImmutableId
}

$disconnect = Read-Host -Prompt "Would you like to Disconnect from Graph Session? (Y|n)"

# Ask to disconnect from Graph API to prevent future issues with connecting
if ($disconnect.ToLower() -ne 'n') {
    Disconnect-MgGraph
} else {
    Write-Host "You are still logged into Graph"
    Write-Host "Make sure to run 'Disconnect-MgGraph' when finished"
}
