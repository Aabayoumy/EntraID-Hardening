<#
.SYNOPSIS
    Gets Entra ID tenant information including tenant name, id, owners, and global admins.

.DESCRIPTION
    Retrieves the current Entra ID (Azure AD) tenant's display name and id, and lists all users with the Owner and Global Administrator roles.

.EXAMPLE
    PS> Get-EntraIDTenantInfo

    TenantName   : Contoso Ltd
    TenantId     : 12345678-90ab-cdef-1234-567890abcdef
    Owners       : {@{DisplayName=John Doe; UserPrincipalName=johndoe@contoso.com}, ...}
    GlobalAdmins : {@{DisplayName=Jane Admin; UserPrincipalName=jane@contoso.com}, ...}
#>

function Get-EntraIDTenantInfo {
    [CmdletBinding()]
    param()

    # Ensure Microsoft.Graph module is available
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
        Write-Error "Microsoft.Graph PowerShell module is required. Install it with: Install-Module Microsoft.Graph"
        return
    }

    Import-Module Microsoft.Graph -ErrorAction Stop

    # Connect if not already connected
    if (-not (Get-MgContext)) {
        Connect-MgGraph -Scopes "Directory.Read.All"
    }

    # Get tenant info
    $org = Get-MgOrganization | Select-Object -First 1

    # Get all directory roles
    $roles = Get-MgDirectoryRole

    # Find Global Administrator role
    $globalAdminRole = $roles | Where-Object { $_.DisplayName -eq "Company Administrator" }
    $globalAdmins = @()
    if ($globalAdminRole) {
        $globalAdmins = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id | Where-Object { $_.ODataType -eq "#microsoft.graph.user" } | Select-Object DisplayName, UserPrincipalName
    }

    # Find Owner role (if available)
    $ownerRole = $roles | Where-Object { $_.DisplayName -eq "Owner" }
    $owners = @()
    if ($ownerRole) {
        $owners = Get-MgDirectoryRoleMember -DirectoryRoleId $ownerRole.Id | Where-Object { $_.ODataType -eq "#microsoft.graph.user" } | Select-Object DisplayName, UserPrincipalName
    }

    [PSCustomObject]@{
        TenantName   = $org.DisplayName
        TenantId     = $org.Id
        Owners       = $owners
        GlobalAdmins = $globalAdmins
    }
}
