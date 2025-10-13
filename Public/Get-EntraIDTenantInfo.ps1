<#
.SYNOPSIS
    Gets Entra ID tenant information including tenant name, id, and global admins.

.DESCRIPTION
    Retrieves the current Entra ID (Azure AD) tenant's display name and id, and lists all users with the Global Administrator role.

.EXAMPLE
    PS> Get-EntraIDTenantInfo


    Id          : 12345678-90ab-cdef-1234-567890abcdef
    DisplayName : Contoso Ltd

    ** Global Administrators **
    Faculty-admin - facultyadmin@contoso704.onmicrosoft.com
    ladmin - ladmin@contoso704.onmicrosoft.com
    hybriduser03 - hybriduser03@contoso704.onmicrosoft.com
    scanner - scanner@contoso704.onmicrosoft.com
    License SKU: Microsoft_Entra_Suite
    Purchased (Enabled): 25
    Assigned (Consumed): 6

    License SKU: RIGHTSMANAGEMENT_ADHOC
    Purchased (Enabled): 10000
    Assigned (Consumed): 2

    License SKU: FLOW_FREE
    Purchased (Enabled): 10000
    Assigned (Consumed): 13

    License SKU: SPE_E5
    Purchased (Enabled): 50
    Assigned (Consumed): 45
    
#>

function Get-EntraIDTenantInfo {
    [CmdletBinding()]
    param()
    # Import Microsoft Graph module (install if needed)
    Import-Module Microsoft.Graph  -NoWelcome -ErrorAction Stop

    # Connect with minimal scopes required
    Connect-MgGraph -Scopes "Directory.Read.All", "RoleManagement.Read.Directory"

    # Get tenant (organization) info
    $orgInfo = Get-MgOrganization | Format-List Id, DisplayName | Out-String
    $orgInfo.Trim().Split("`n") | ForEach-Object { Write-Host $_ -ForegroundColor Green }

    
    # Get Global Administrator role ID
    $role = Get-MgDirectoryRole | Where-Object { $_.DisplayName -eq "Global Administrator" }
    if ($null -eq $role) { Write-Warning "Global Administrator role not enabled." ; return }

    # Get all members assigned to Global Administrator
    $admins = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id

    # Filter to only user objects and print info
    Write-Host "** Global Administrators **" 
    $admins | Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user' }  | ForEach-Object {
        $user = Get-MgUser -UserId $_.Id -Property UserPrincipalName, DisplayName 
        Write-Host "$($user.DisplayName) - $($user.UserPrincipalName)" -ForegroundColor Blue
    }

    # Get all subscribed license SKUs for the tenant
    $licenses = Get-MgSubscribedSku

    # Display license usage info for each SKU
    foreach ($license in $licenses) {
        $skuPartNumber = $license.SkuPartNumber
        $enabled = $license.PrepaidUnits.Enabled
        $consumed = $license.ConsumedUnits
        Write-Host "License SKU: $skuPartNumber" -ForegroundColor Blue
        Write-Host "  Purchased (Enabled): $enabled" -ForegroundColor Blue
        Write-Host "  Assigned (Consumed): $consumed" -ForegroundColor Blue
        Write-Host "" -ForegroundColor Blue
    }



}
