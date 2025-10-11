# EntraID-Hardening PowerShell Module

## Overview

This module helps automate the creation of a break-glass security group, a named location for suspicious countries, and a Conditional Access policy blocking those locations (excluding the break-glass group).

## Usage

1. **Import the module from the current directory:**
   ```powershell
   Import-Module "$PWD/EntraID-Hardening.psd1"
   ```

2. **Run the Deploy-GeoBlock function, specifying your break-glass user UPNs:**
   ```powershell
   Deploy-GeoBlock -BreakGlassUserUPNs @("admin@contoso.com")
   ```

3. **To see the function's help:**
   ```powershell
   Get-Help Deploy-GeoBlock -Full
   ```

## Notes

- You must have the `Microsoft.Graph.Identity.SignIns` module installed and be able to connect to Microsoft Graph with the required permissions.
- The function will create or update the break-glass group, add users, create the named location, and set up the Conditional Access policy as described.

## Structure

- `EntraID-Hardening.psd1` — Module manifest
- `EntraID-Hardening.psm1` — Module loader (loads all functions from Public/ and Private/)
- `Public/` — Public functions (exported)
- `Private/` — Private/internal functions
