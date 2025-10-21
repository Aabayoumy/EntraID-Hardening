# EntraID-Hardening PowerShell Module

## Overview

This module helps automate the creation of a break-glass security group, a named location for suspicious countries, and a Conditional Access policy blocking those locations (excluding the break-glass group). The module is fully modular, with each public function in its own file under `Public/`.

## Usage

1. **Import the module from the current directory:**
   ```powershell
   Import-Module "$PWD/EntraID-Hardening.psd1"
   ```

2. **Run the Deploy-GeoBlock function:**
   ```powershell
   Deploy-GeoBlock
   ```
   This will:
   - Create or update the break-glass group (using `Initialize-BreakGlass`)
   - Add users from your settings to the group
   - Create the named location for suspicious countries
   - Set up the Conditional Access policy

3. **To use the break-glass group logic directly:**
   ```powershell
   Initialize-BreakGlass -GroupName "BreakGlassEmergencyAccess" -UserUPNs @("admin@contoso.com")
   ```
   - This function creates or updates the break-glass group and adds the specified users.
   - The group ID is saved in the global variable `$Global:BreakGlassGroupId` for use by other functions.

4. **To see the function's help:**
   ```powershell
   Get-Help Deploy-GeoBlock -Full
   Get-Help Initialize-BreakGlass -Full
   ```

---

### Get-EntraIDTenantInfo

Retrieves Entra ID (Azure AD) tenant information, including tenant name, id, global administrators, and license information.

**Parameters:**
- `-DisplayGlobalAdmins` (bool, default: `$true`): If `$true`, displays the list of Global Administrators. If `$false`, omits this section.
- `-DisplayLicense` (bool, default: `$true`): If `$true`, displays license SKU and service plan information. If `$false`, omits this section.

**Examples:**
```powershell
# Show all information (default)
Get-EntraIDTenantInfo

# Show only license information
Get-EntraIDTenantInfo -DisplayGlobalAdmins:$false

# Show only global administrators
Get-EntraIDTenantInfo -DisplayLicense:$false

# Show only tenant name and id
Get-EntraIDTenantInfo -DisplayGlobalAdmins:$false -DisplayLicense:$false
```

## Notes

- You must have the `Microsoft.Graph.Identity.SignIns` module installed and be able to connect to Microsoft Graph with the required permissions.
- The functions will create or update the break-glass group, add users, create the named location, and set up the Conditional Access policy as described.
- The break-glass group ID is stored in `$Global:BreakGlassGroupId` after running `Initialize-BreakGlass` or `Deploy-GeoBlock`.

## Structure

- `EntraID-Hardening.psd1` — Module manifest
- `EntraID-Hardening.psm1` — Module loader (loads all functions from Public/ and Private/)
- `Public/` — Public functions (exported, one per file)
- `Private/` — Private/internal functions

## Recent Changes

- Refactored break-glass group logic into `Initialize-BreakGlass` (now in `Public/Initialize-BreakGlass.ps1`)
- `Deploy-GeoBlock` now calls `Initialize-BreakGlass` for group setup
- Suppressed output from Connect-MgGraph and Disconnect-MgGraph
- Group ID is saved in `$Global:BreakGlassGroupId` for cross-function use
