@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'EntraID-Hardening.psm1'

    # Version number of this module.
    ModuleVersion     = '0.1.0'

    # ID used to uniquely identify this module
    GUID              = 'b1e2c3d4-5678-4abc-9def-1234567890ab'

    # Author of this module
    Author            = 'Ahmed Bayoumy'

    # Company or vendor of this module
    CompanyName       = 'www.abayoumy.tech'

    # Copyright statement for this module
    Copyright         = '(c) 2025 Ahmed Bayoumy. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Creates a break-glass security group, a named location for suspicious countries, and a Conditional Access policy blocking those locations — excluding the break-glass group.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @('Deploy-GeoBlock', 'Get-EntraIDHardeningSettings', 'Set-EntraIDHardeningSetting', 'Get-EntraIDTenantInfo')

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule
    PrivateData       = @{}

    # HelpInfo URI
    HelpInfoURI       = ''

    # Default command prefix
    DefaultCommandPrefix = ''
}
