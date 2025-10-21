function Initialize-BreakGlass {
    <#
    .SYNOPSIS
      Creates a break-glass security group and adds specified users to it.

    .DESCRIPTION
      1. Creates a "BreakGlassEmergencyAccess" security group if it doesn't exist.
      2. Adds specified break-glass user(s) to that group.
      3. Returns the groupId of the break-glass group.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        [Parameter(Mandatory = $true)]
        [string[]]$UserUPNs
    )
    # Create or get Break-Glass Group
    $existingGroup = Get-MgGroup -Filter "displayName eq '$GroupName'" -ConsistencyLevel eventual -CountVariable cnt
    if ($existingGroup -and $cnt -gt 0) {
        $groupId = $existingGroup.Id
        Write-Output "Using existing group '$GroupName' (ID: $groupId)."
    }
    else {
        Write-Output "Creating break-glass group..."
        $groupParams = @{
            DisplayName     = $GroupName
            MailEnabled     = $false
            SecurityEnabled = $true
            MailNickname    = "BreakGlass"
            Description     = "Emergency access accounts excluded from blocking policies"
        }
        $group = New-MgGroup -BodyParameter $groupParams
        $groupId = $group.Id
        Write-Output "Created group '$GroupName' (ID: $groupId)."
    }

    # Add users to Break-Glass Group
    if (-not $UserUPNs) {
        Write-Warning "No BreakGlassUserUPNs found in settings. Skipping user addition."
    } else {
        foreach ($upn in $UserUPNs) {
            $user = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue
            if ($null -eq $user) {
                Write-Warning "User $upn not found; skipping."
                continue
            }
            $memberCheck = Get-MgGroupMember -GroupId $groupId -All | Where-Object { $_.Id -eq $user.Id }
            if ($memberCheck) {
                Write-Output "User $upn already in break-glass group."
            }
            else {
                Write-Output "Adding $upn to break-glass group..."
                New-MgGroupMember -GroupId $groupId -DirectoryObjectId $user.Id
            }
        }
    }
    $Global:BreakGlassGroupId = $groupId
    return $groupId
}
