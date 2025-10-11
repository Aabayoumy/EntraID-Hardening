function Set-EntraIDHardeningSetting {
<#
.SYNOPSIS
    Sets a specific EntraID-Hardening module setting.

.DESCRIPTION
    Updates a setting in the module's settings file and in memory.

.PARAMETER Name
    The name of the setting to set.

.PARAMETER Value
    The value to assign to the setting.

.EXAMPLE
    Set-EntraIDHardeningSetting -Name BreakGlassUserUPNs -Value @("admin@contoso.com", "emergency@contoso.com")
#>
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        $Value
    )
    Set-EntraIDHardeningSetting -Name $Name -Value $Value
}
