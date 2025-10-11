function Deploy-GeoBlock {
<#
.SYNOPSIS
  Creates a break-glass security group, a named location for suspicious countries, and a Conditional Access policy blocking those locations — excluding the break-glass group.

.DESCRIPTION
  1. Connects to MS Graph.  
  2. Creates a "BreakGlassEmergencyAccess" security group.  
  3. Adds specified break-glass user(s) to that group.  
  4. Creates a named location "Suspicious Countries - High Risk".  
  5. Creates a CA policy "Block Access from Suspicious Countries" in report-only mode, excluding the break-glass group.  

#>
    Import-Module Microsoft.Graph.Identity.SignIns -ErrorAction Stop

    try {
        Write-Output "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "Group.ReadWrite.All", "Directory.ReadWrite.All", "Policy.ReadWrite.ConditionalAccess" -NoWelcome
        # 1. Create Break-Glass Group
        $groupName = $Global:EntraIDHardeningSettings.BreakGlassGroupName
        $existingGroup = Get-MgGroup -Filter "displayName eq '$groupName'" -ConsistencyLevel eventual -CountVariable cnt
        if ($existingGroup -and $cnt -gt 0) {
            $groupId = $existingGroup.Id
            Write-Output "Using existing group '$groupName' (ID: $groupId)."
        }
        else {
            Write-Output "Creating break-glass group..."
            $groupParams = @{
                DisplayName     = $groupName
                MailEnabled     = $false
                SecurityEnabled = $true
                MailNickname    = "BreakGlass"
                Description     = "Emergency access accounts excluded from blocking policies"
            }
            $group = New-MgGroup -BodyParameter $groupParams
            $groupId = $group.Id
            Write-Output "Created group '$groupName' (ID: $groupId)."
        }

        # 2. Add users to Break-Glass Group from settings
        $breakGlassUserUPNs = $Global:EntraIDHardeningSettings.BreakGlassUserUPNs
        if (-not $breakGlassUserUPNs) {
            Write-Warning "No BreakGlassUserUPNs found in settings. Skipping user addition."
        } else {
            foreach ($upn in $breakGlassUserUPNs) {
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

        # 3. Create Named Location
        $namedLocationName = "Suspicious Countries - High Risk"
        $existingLoc = Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$namedLocationName'" -All
        if ($existingLoc) {
            $namedLocationId = $existingLoc.Id
            Write-Output "Using existing named location '$namedLocationName' (ID: $namedLocationId)."
        }
        else {
            Write-Output "Creating named location for suspicious countries..."
            $countries = @(
                "RU", "CN", "KP", "IR",  # Tier1
                "UA", "NG", "RO", "BY", "PK",  # Tier2
                "BO", "HN", "VE", "DZ", "EC", "KG", "LK"  # Tier3
            )
            $locParams = @{
                "@odata.type"                     = "#microsoft.graph.countryNamedLocation"
                DisplayName                       = $namedLocationName
                CountriesAndRegions               = $countries
                IncludeUnknownCountriesAndRegions = $true
            }
            $loc = New-MgIdentityConditionalAccessNamedLocation -BodyParameter $locParams
            $namedLocationId = $loc.Id
            Write-Output "Created named location '$namedLocationName' (ID: $namedLocationId)."
        }

        # 4. Create Conditional Access Policy
        $policyName = "Block Access from Suspicious Countries"
        $existingPolicy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$policyName'" -All
        if ($existingPolicy) {
            Write-Warning "Conditional Access policy '$policyName' already exists; skipping creation."
        }
        else {
            Write-Output "Creating Conditional Access policy in report-only mode..."
            $policyParams = @{
                DisplayName   = $policyName
                State         = "enabledForReportingButNotEnforced"
                Conditions    = @{
                    Users        = @{
                        IncludeUsers  = @("All")
                        ExcludeGroups = @($groupId)
                    }
                    Applications = @{
                        IncludeApplications = @("All")
                    }
                    Locations    = @{
                        IncludeLocations = @($namedLocationId)
                    }
                }
                GrantControls = @{
                    Operator        = "OR"
                    BuiltInControls = @("block")
                }
            }
            New-MgIdentityConditionalAccessPolicy -BodyParameter $policyParams
            Write-Output "Policy '$policyName' created in report-only mode."
        }

    }
    catch {
        Write-Error "ERROR: $($_.Exception.Message)"
    }
    finally {
        Disconnect-MgGraph
        Write-Output "Disconnected from Microsoft Graph."
    }
}
